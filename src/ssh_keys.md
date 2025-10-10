# SSH keys

[Developers](./devs.md) MUST use SSH keys which are backed by [hardware security keys](./hardware_security_keys.md) when interacting with [GitHub](./github.md).  While it is possible to use an SSH key backed by a GPG key, a YubiKey allows having multiple SSH keys on a device, and the configuration is much more streamlined.

## Setup

### SSH

Use your package manager to install `OpenSSH` (use brew for MacOS).  See [this](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html) for more details.

### YubiKey

You MUST set a [PIN](./hardware_security_keys.md#set-a-fido-pin) on your YubiKey.

## Generate a key

Use `ssh-keygen` with the following args to create a key backed by the hardware device.  If you plan to store multiple ssh keys on your hardware device, you SHOULD ALWAYS identify the key using the `-O 'application=ssh:UID'` argument. The `UID` part is used internally on the card to specify in which slot to store the key, replacing the `-C comment` field, and is exported when regenerating keys on other devices.

The command for creating such keys will look like the following:
```
ssh-keygen -t ed25519-sk -O resident -O verify-required -O 'application=ssh:function-CARDNO'
```
You SHOULD structure your `UID` strings as `function-CARDNO`, where `function` is what the key will be used for, and `CARDNO` is the YubiKey serial number. You SHOULD NOT simply keep the string `function-CARDNO`.

Here is an example command to create some keys:

You SHOULD NOT specify a password when creating the key, since it will only be used to lock the empty file on the filesystem.

Update the file permissions:
```
chmod 600 ~/.ssh/id_ed25519_sk
```

## Regenerate a key on a separate machine

You MAY use this hardware backed SSH key on multiple machines. To do so, you MUST regenerate the key files on each machine:
```
cd ~/.ssh/
ssh-keygen -K
```

As before, you SHOULD NOT specify a password.
