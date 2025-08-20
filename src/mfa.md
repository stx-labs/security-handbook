# Multi-factor authentication

[Multi-factor
authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication)
ensures that if your username/passwords are ever compromised, an attacker will
not be able to authenticate as you, missing _something else_ – typically,
"_something you have_".

Here are the "multiple factors" we will be using:

1. Username
1. Password: "something you know"
1. Hardware security key: "something you have"

You MUST enable multi-factor authentication for all your accounts on all
services. For this to be effective, you MUST keep factors separate from each
other. This means that you MUST NOT store your second factor in your password
manager. Instead, use [hardware security keys](#using-hardware-devices).

## Which second factor

### Passkeys

The modern and most secure way to add a second factor to your account is
through **[passkeys](https://en.wikipedia.org/wiki/WebAuthn)**. They provide
good UX and are [resistant to
phishing](https://www.passkeycentral.org/introduction-to-passkeys/passkey-security#phishing-resistance).

If a service allows you to use passkeys as a second factor, you MUST prefer it
to any other method. Setting things up depend on each service, for instance:

1. [Google](https://myaccount.google.com/signinoptions/passkeys.md)
1. [GitHub](https://github.com/settings/security.md)

When authenticating to a service, you will be asked for a username and
password, then prompted to insert your security key, insert its [FIDO
PIN](./hardware_security_keys.md), and then touch it to confirm your presence.

Some services will also allow "passwordless" login, where the security key is
enough to authenticate.

### Time-based one-time password

If a service does not support passkeys (yet), they will use
[TOTPs](https://en.wikipedia.org/wiki/Time-based_one-time_password) as an
alternative.

Please see [here](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/oath.html#adding-a-new-account)
for how to setup TOTPs for your Yubikeys.

When authenticating to a service, you will be asked for your TOTP for that
account. Use the Yubico Authenticator to get it (instructions
[here](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/oath.html#authenticating-with-oath-and-yubico-authenticator)).

## What about recovery codes?

When setting up multi-factor authentication, some services will prompt you to
store some recovery codes to use in case you lose your hardware security key.
While it might be tempting to go on and store them in your password manager,
you MUST NOT do that, as it would defeat the purpose of the second factor.

Instead, either:

1. register multiple hardware second factors (so that you cannot lock yourself
   out) and destroy the recovery codes;
1. print out the recovery codes as store them in a safe.

## What about my phone number?

SMS-based two-factor authentication is insecure and MUST NOT be used; instead,
rely on hardware devices. SIMs can be unfortunately
[swapped](https://en.wikipedia.org/wiki/SIM_swap_scam). When that happens,
the attacker will control second factor.

If you need to use a service that will _only_ allow phone number 2FA, [reach
out](./contacts.md)!
