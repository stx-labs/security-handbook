# SSH keys

[Developers](./devs.md) MUST use SSH keys which are backed by [hardware security keys](./hardware_security_keys.md) when interacting with [GitHub](./github.md).  While it is possible to use an SSH key backed by a GPG key, a YubiKey allows having multiple SSH keys on a device, and the configuration is much more streamlined.

## MacOS Setup

### SSH

You MUST install `openssh` from `brew`, since the native `ssh` lacks `FIDO2` support:
```
brew update
brew install openssh
```

### YubiKey

You MUST set a PIN on your YubiKey.  You MAY use the `Yubico Authenticator` to do this, which is available via Mac App Store.  Advanced users MAY instead use `ykman` from `brew`, but must be careful to set a FIDO specific PIN:
```
ykman fido access change-pin
Enter your new PIN: 
Repeat for confirmation: 
FIDO PIN updated.
```

## Generate a key

Use `ssh-keygen` with the following args to create a key backed by the hardware device:
```
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "comment"
```
You MUST change `comment` to reflect how/where this key will be used (e.g. authentication, signing).

Update the file permissions:
```
chmod 600 ~/.ssh/id_ed25519_sk
```

You MAY add additional keys by specifying a UID:
```
ssh-keygen -t ed25519-sk -O resident -O verify-required -O application=ssh:<UID> -C "comment"
```
