# Using `gh` securely

GitHub CLI (`gh`) uses an OAuth credential to access GitHub on your behalf.
That credential can have broad permissions, including access to private
repositories and the ability to push code. A stolen long-lived credential will
be reused until revoked.

If you use `gh`, you MUST install the `gh-age` wrapper described below.

The wrapper is a small script installed as `gh` ahead of the real GitHub CLI in
your `PATH`. You continue to run `gh` commands as usual; the script obtains an
access token, passes it to the real CLI, and protects the longer-lived refresh
token with your YubiKey. Login and logout use `gh age-login` and `gh
age-logout`.

This setup makes a tradeoff between convenience and protection against
[credential theft](./threat_model.md):

1. At login, it uses GitHub's device authorization flow and requests an
   expiring access token and a refresh token. It handles the response in memory
   and encrypts the refresh token using your YubiKey's FIDO2 credential.
2. The access token authorizes GitHub API calls. The wrapper stores it
   **unencrypted on disk** in a private per-user directory and supplies it to
   `gh` through `GH_TOKEN`. GitHub determines its lifetime (typically eight
   hours); the wrapper uses the expiry returned by GitHub.
3. When the access token is near expiry, the wrapper decrypts the refresh token
   with your [FIDO PIN](./hardware_security_keys.md#set-a-fido-pin) and
   touch, exchanges it for a new token pair, then asks you to verify again to
   encrypt the rotated refresh token. The key is required for both operations.

The YubiKey protects the refresh token at rest; it does **not** approve every
GitHub operation. A process with access to your account's files or environment
can steal and reuse the cached access token without the key until it expires or
is revoked. A persistent compromise can also wait for you to unlock the key or
capture credentials while they are in memory. The directory's permissions
protect against other local users, not processes running as you.
[EDR](./work_devices.md#endpoint-detection-and-response-edr) helps detect
malware on the device.

## Setup

You need `gh`, your YubiKey plugged in, and [SSH keys](./ssh_keys.md)
configured for GitHub (`ssh -T git@github.com`). Your key must support the
FIDO2 `hmac-secret` extension, and its FIDO PIN must be set. These instructions
use a USB key.

### 1. Install dependencies

```sh
brew install age jq flock go libfido2 pkg-config
go install filippo.io/typage/fido2prf/cmd/age-plugin-fido2prf@latest
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
export PATH="$HOME/go/bin:$PATH"
```

This installs [FiloSottile's FIDO2 plugin][1] using Go's default binary directory.
If you have set `GOBIN` or `GOPATH`, add the corresponding binary directory to
`PATH` instead. Confirm that `age-plugin-fido2prf` is on your `PATH`.

### 2. Remove existing `gh` credentials

Run this **before** step 4 (the wrapper blocks `gh auth logout`):

```sh
gh auth logout
```

1. Revoke **GitHub CLI** at
   [github.com/settings/applications][0]
   to invalidate all previously issued tokens across your machines.
2. Open **Keychain Access**, search for `gh:github.com`, and delete any
   remaining entries.
3. Remove any `export GH_TOKEN=$(gh auth token)` lines from your shell startup
   files or scripts.

### 3. Force SSH for Git

`gh`'s HTTPS credential helper bypasses the wrapper. Route all GitHub `git` traffic over SSH instead:

```sh
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global --unset-all credential.https://github.com.helper
git config --global --unset-all credential.https://gist.github.com.helper
```

Confirm no GitHub credential helpers remain (this should print nothing):

```sh
git config --global --get-regexp 'credential.*github'
```

### 4. Install the `gh` wrapper

Download the [wrapper](./scripts/gh-age.sh) from this handbook, or use a local
checkout of this repository. From the repository root, run:

```sh
mkdir -p ~/.local/bin
install -m 755 src/scripts/gh-age.sh ~/.local/bin/gh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc; rehash
whence -a gh   # ~/.local/bin/gh should appear first
```

If you downloaded the wrapper, use its downloaded path in the `install` command
instead of `src/scripts/gh-age.sh`.

> GUI apps, IDEs, and coding agents that don't read `~/.zshrc` should be
  pointed to `~/.local/bin/gh`.

### 5. Generate the FIDO2 identity

```sh
mkdir -p ~/.config/gh-age
umask 077
age-plugin-fido2prf -generate age-encryption.org > ~/.config/gh-age/identity
```

Insert only the intended YubiKey, then enter its FIDO PIN and touch it when
prompted. Check that the file begins with `AGE-PLUGIN-FIDO2PRF-1`. The identity
is tied to that YubiKey; it does not work with your backup key. If generation
fails, remove the incomplete identity file and retry.

### 6. Log in and verify

```sh
gh age-login
gh api user --jq .login   # prints your username
```

Open the GitHub URL shown by `gh age-login`, enter the one-time code and
authorize the application. Verify with your FIDO PIN and touch when prompted.

Verify that searching **Keychain Access** for `gh:github.com` returns nothing.

## Day-to-day usage

- **Prompts:** When the access token expires, `gh` will prompt for your [FIDO
  PIN](./hardware_security_keys.md#set-a-fido-pin) and a touch to read the
  refresh token, then again to save the rotated token. Login and verification
  also require these interactions. Noninteractive use requires a valid cached
  access token.
- **Scripts:** Call `gh` (or `gh auth token`) on demand. Do not export or cache
  tokens in environment variables or files.
- **Logging out:** Run `gh age-logout` to delete local tokens, and revoke
  **GitHub CLI** at [github.com/settings/applications][0] to invalidate them
  on GitHub.
- **Scope changes:** Run `gh age-login --scopes scope1,scope2` to authorize a
  new token with additional scopes. The wrapper requests `repo`, `read:org`,
  and `gist` by default. Native `gh auth refresh` does not update the stored
  refresh token.
- **Interrupted refresh:** If saving the rotated refresh token fails after
  GitHub has issued it, run `gh age-login` again.

[0]: https://github.com/settings/applications
[1]: https://github.com/FiloSottile/typage#age-plugin-fido2prf
