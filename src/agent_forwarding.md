# SSH Agent Forwarding

[SSH keys](./ssh_keys.md) backed by [hardware security keys](./hardware_security_keys.md) with `verify-required` need a PIN on every use. By default, the ssh-agent cannot prompt for the PIN when a request comes from a remote host, so agent forwarding fails with `agent refused operation`.

The fix is to install `ssh-askpass`, which gives the agent a GUI dialog to collect the PIN on your local machine, even when the signing request originates from a remote VM.

## Setup

### Install ssh-askpass

#### macOS

```
brew tap theseal/ssh-askpass
brew install ssh-askpass
```

#### Linux

```
# Debian/Ubuntu
sudo apt install ssh-askpass-gnome

# Fedora
sudo dnf install openssh-askpass
```

> **Important:** Ubuntu and other GNOME-based distributions default to gnome-keyring's ssh-agent, which does NOT support FIDO2 PIN entry. You MUST use OpenSSH's `ssh-agent` instead. Disable gnome-keyring's SSH component and start `ssh-agent` manually or via your shell profile.

### Configure the environment

Add to your shell rc file (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export SSH_ASKPASS=ssh-askpass
export SSH_ASKPASS_REQUIRE=force
```

The path varies by distro — run `which ssh-askpass` to confirm it resolves. On Debian/Ubuntu with `ssh-askpass-gnome`, the system typically symlinks `/usr/bin/ssh-askpass` automatically.

Then restart the agent:

```bash
pkill ssh-agent
source ~/.zshrc   # or ~/.bashrc
```

### Remote VM

1. Copy your signing public key to the VM:

```
scp ~/.ssh/id_ed25519_sk_rk_sign-SERIAL.pub VMHOST:~/.ssh/
```

2. On the VM, configure git to use the forwarded agent for commit signing:

```
git config --global gpg.format ssh
git config --global user.signingKey ~/.ssh/id_ed25519_sk_rk_sign-SERIAL.pub
git config --global commit.gpgsign true
```

You SHOULD NOT add an `IdentityFile` directive in the VM's `~/.ssh/config` — the forwarded agent handles authentication.

3. Ensure `sshd` allows forwarding on every hop:

```
AllowAgentForwarding yes
```

## How it works

```
VM: git commit
  -> forwarded agent -> local machine ssh-agent
  -> ssh-askpass pops up GUI PIN dialog on local machine
  -> enter PIN + touch YubiKey
  -> signed commit on VM
```

The PIN never leaves your local machine. The YubiKey never leaves your local machine. The VM only sees the signed result.

## Verify

```bash
# From your local terminal, through the VM
ssh VMHOST 'ssh -T git@github.com'

# On the VM
ssh-add -l                              # Should show your keys
git commit --allow-empty -m "test"      # PIN dialog on local machine + touch
git log --show-signature -1             # Good signature
```

## Troubleshooting

| Error                                 | Cause                                    | Fix                                                                                    |
| ------------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------- |
| `agent refused operation`             | Missing `ssh-askpass`                    | Install it and set the `SSH_ASKPASS` env vars                                          |
| `No private key found for public key` | ssh-keygen cannot find private key on VM | Use `key::` prefix: `git config --global user.signingKey "key::$(cat ~/.ssh/key.pub)"` |
| `Couldn't find key in agent`          | Agent not forwarded or wrong socket      | Check `echo $SSH_AUTH_SOCK` and `ssh-add -l`                                           |
