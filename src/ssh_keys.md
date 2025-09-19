# SSH keys

[Developers](./devs.md) MUST use SSH keys which are backed by [hardware security keys](./hardware_security_keys.md) when interacting with [GitHub](./github.md).  While it is possible to use an SSH key backed by a GPG key, a YubiKey allows having multiple SSH keys on a device, and the configuration is much more streamlined.

## Setup

### SSH

Use your package manager to install `OpenSSH` (use brew for MacOS).  See [this](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html) for more details.

### YubiKey

You MUST set a [PIN](./hardware_security_keys.md#set-a-fido-pin) on your YubiKey.

## Generate a key

Use `ssh-keygen` with the following args to create a key backed by the hardware device.  You SHOULD ALWAYS specify an application `UID` string; this replaces the `-C comment` field and is exported when regenerating keys on other devices.
```
ssh-keygen -t ed25519-sk -O resident -O verify-required -O 'application=ssh:user-function-CARDNO'
```
You SHOULD specify the username, function, and YubiKey serial number in the UID string.

You SHOULD NOT specify a password when creating the key, since it will only be used to lock the empty file on the filesystem.

Update the file permissions:
```
chmod 600 ~/.ssh/id_ed25519_sk
```

## Regenerate a key on a separate machine

You MAY use this hardware backed SSH key on multiple machines. To do so, you MUST regenerate the key files on each machine:```
cd ~/.ssh/
ssh-keygen -K
```

As before, you SHOULD NOT specify a password.
