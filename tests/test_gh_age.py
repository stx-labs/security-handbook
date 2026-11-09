"""Exercise the wrapper without real GitHub credentials or a security key."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

WRAPPER = Path(__file__).resolve().parents[1] / "src/scripts/gh-age.sh"


class WrapperTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir(mode=0o700)
        self.conf = self.home / ".config/gh-age"
        self.conf.mkdir(parents=True)
        (self.conf / "identity").write_text("identity\n")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.script("flock", "exit 0")
        self.script("sleep", "exit 0")
        self.script("age", '''if [ "$1" = -d ]; then
  [ "${FAIL_DECRYPT:-0}" = 0 ] || exit 1
  printf oldrefresh
else
  [ "${FAIL_ENCRYPT:-0}" = 0 ] || exit 1
  cat >/dev/null
  printf encrypted > "$5"
fi''')
        self.script("curl", '''case "$*" in
  *login/device/code*) printf '%s' '{"device_code":"secretcode","user_code":"TEST-CODE","interval":1,"expires_in":600}' ;;
  *device_code@-*) cat >/dev/null; printf '%s' '{"access_token":"loginaccess","refresh_token":"loginrefresh","expires_in":28800}' ;;
  *refresh_token@-*) cat >/dev/null; printf called > "$TEST_ROOT/called"; printf '%s' '{"access_token":"access123","refresh_token":"newrefresh","expires_in":28800}' ;;
  *) exit 1 ;;
esac''')
        self.script("real-gh", 'printf "%s\\n" "$GH_TOKEN"')
        self.env = dict(os.environ, HOME=str(self.home), GH_REAL=str(self.bin / "real-gh"),
                        PATH=str(self.bin) + ":" + os.environ["PATH"], TEST_ROOT=str(self.root))
        self.state = self.home / ".gh-age-runtime"

    def script(self, name, source):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + source + "\n")
        path.chmod(0o755)

    def run_wrapper(self, *args, **extra_env):
        return subprocess.run(["sh", str(WRAPPER), *args], env=self.env | extra_env,
                              text=True, capture_output=True)

    def test_login_cache_and_refresh_failures(self):
        result = self.run_wrapper("age-login")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("TEST-CODE", result.stderr)
        self.assertEqual((self.conf / "refresh.age").read_text(), "encrypted")
        self.assertFalse(list(self.state.glob("login.*")))
        self.assertEqual(self.run_wrapper("api", "user").stdout.strip(), "loginaccess")
        (self.state / "access").unlink()
        result = self.run_wrapper("api", "user", FAIL_DECRYPT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "called").exists())
        self.assertEqual(self.run_wrapper("api", "user").stdout.strip(), "access123")
        (self.state / "access").unlink()
        result = self.run_wrapper("api", "user", FAIL_ENCRYPT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.conf / "refresh.age").exists())

    def test_runtime_permissions_and_symlink(self):
        self.state.mkdir(mode=0o755)
        self.state.chmod(0o755)
        result = self.run_wrapper("api", "user")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("mode 700", result.stderr)
        self.state.rmdir()
        self.state.symlink_to(self.root, target_is_directory=True)
        result = self.run_wrapper("api", "user")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unsafe runtime", result.stderr)


if __name__ == "__main__":
    unittest.main()
