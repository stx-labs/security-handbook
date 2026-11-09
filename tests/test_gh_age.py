"""Exercise the wrapper without real GitHub credentials or a security key."""
import os
import hashlib
from concurrent.futures import ThreadPoolExecutor
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
        self.script("real-gh", 'printf "%s\\n" "${GH_TOKEN:-no-token}"')
        self.env = dict(os.environ, HOME=str(self.home), GH_AGE_DIR=str(self.conf),
                        XDG_CONFIG_HOME=str(self.home / ".config"), GH_REAL=str(self.bin / "real-gh"),
                        PATH=str(self.bin) + ":" + os.environ["PATH"], TEST_ROOT=str(self.root))
        for name in ("GH_TOKEN", "GITHUB_TOKEN", "GH_ENTERPRISE_TOKEN", "GITHUB_ENTERPRISE_TOKEN"):
            self.env.pop(name, None)
        self.runtime = self.home / ".gh-age-runtime"
        self.state = self.runtime / hashlib.sha256(os.fsencode(self.conf.resolve())).hexdigest()

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
        self.runtime.mkdir(mode=0o755)
        self.runtime.chmod(0o755)
        result = self.run_wrapper("api", "user")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("mode 700", result.stderr)
        self.runtime.rmdir()
        self.runtime.symlink_to(self.root, target_is_directory=True)
        result = self.run_wrapper("api", "user")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unsafe runtime", result.stderr)

    def test_configuration_caches_are_isolated(self):
        self.assertEqual(self.run_wrapper("age-login").returncode, 0)
        other = self.home / "other"
        other.mkdir()
        result = self.run_wrapper("api", "user", GH_AGE_DIR=str(other))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no stored refresh token", result.stderr)
        self.assertNotIn("loginaccess", result.stdout)
        alias = self.home / "alias"
        alias.symlink_to(self.conf, target_is_directory=True)
        result = self.run_wrapper("api", "user", GH_AGE_DIR=str(alias))
        self.assertEqual(result.stdout.strip(), "loginaccess")

    def test_logout_removes_staged_token_files(self):
        self.assertEqual(self.run_wrapper("age-login").returncode, 0)
        for path in (self.state / "access.tmp", self.state / "expires_at.tmp",
                     self.conf / "refresh.age.tmp"):
            path.write_text("staged")
        self.assertEqual(self.run_wrapper("age-logout").returncode, 0)
        for path in (self.state / "access", self.state / "access.tmp",
                     self.state / "expires_at", self.state / "expires_at.tmp",
                     self.conf / "refresh.age", self.conf / "refresh.age.tmp"):
            self.assertFalse(path.exists(), str(path))

    def test_concurrent_first_invocations(self):
        # Give all processes time to reach runtime-directory creation together.
        self.script("mkdir", '''case "$*" in
  *"/.gh-age-runtime") /bin/sleep 0.2 ;;
esac
exec /bin/mkdir "$@"''')
        with ThreadPoolExecutor(max_workers=16) as pool:
            results = list(pool.map(lambda _: self.run_wrapper("--version"), range(32)))
        for result in results:
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_subcommand_help_and_option_values(self):
        for args in (("repo", "--help"), ("repo", "view", "-h"),
                     ("api", "--paginate", "--help"),
                     ("api", "--paginate", "--silent", "--help"),
                     ("api", "--include", "--help"),
                     ("repo", "view", "--repo", "owner/name", "--help"),
                     ("repo", "view", "--repo=owner/name", "--help")):
            with self.subTest(args=args):
                result = self.run_wrapper(*args)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), "no-token")
        for args in (("pr", "create", "--title", "--help"),
                     ("pr", "create", "--paginate", "--help"),
                     ("api", "--field", "--help"),
                     ("api", "--paginate", "--field", "--help"),
                     ("pr", "create", "--title", "-h"),
                     ("pr", "create", "--", "--help")):
            with self.subTest(args=args):
                result = self.run_wrapper(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("no stored refresh token", result.stderr)


if __name__ == "__main__":
    unittest.main()
