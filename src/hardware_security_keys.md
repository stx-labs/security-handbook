# Hardware security keys

Hardware security keys allow you to securely keep second factors and
cryptographic keys physically separated from your work device (e.g., your
laptop). In addition, these keys will not unlock their secrets _unless_ you
_touch_ them, proving you are physically present.

All this ensures that a remote attacker who controls your machine cannot use
your security key. We will use hardware security keys for [multi-factor
authentication](./mfa.md).

## Which key should you get?

We recommend getting _at least two_ [Yubikey
5C](https://smartmanagement.es/product/yubikey-5c-nfc/), providing connectivity
through USB-C (so you can plug it into your laptop and most phones) and NFC.

You MUST keep one of them on you at all times and leave the other in a safe
place (so that if you lose one, you have a backup).

We will be using these keys for:

- WebAuthn (_everyone_, used for passkeys)
- OATH - TOTP (_everyone_, used for TOTPs)
- FIDO2 (if you are a _developer_, used for SSH)
- SmartCard / PIV (if you are a _developer_, used for SSH when FIDO2 is not an option)

## Configuration

To configure your Yubikey(s), install the [Yubico
Authenticator](https://www.yubico.com/products/yubico-authenticator/). In case
you need them, here are its [full
docs](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/webdocs.pdf).

### Disable Yubico OTP

We will _not_ be using Yubico OTP, so you can disable it (if the authenticator
proposes it after you have plugged in the Yubikey).

### Set a FIDO PIN

You MUST [set a FIDO PIN on your
Yubikey(s)](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/fido2.html#creating-and-managing-the-fido2-pin).
This ensures that if it gets lost or stolen, an attacker cannot use it without
also knowing the PIN.

Go to the app Configuration, then navigate to "FIDO/Manage PIN". Follow the
instructions to set a 4-digits PIN.

If you are on iOS, you will need to use NFC instead of USB-C. Put your Yubikey
on a table, touch it with the top of your iPhone. It will prompt you to open
the authenticator.

### Set an OATH password

You MUST set a OATH password so that, similarly as we did for the FIDO PIN, a
lost Yubikey can't be used without it.

Read
[here](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/oath.html#password-protection)
for instructions.

When asked by the application, you can [protect your password with
FaceID](https://docs.yubico.com/software/yubikey/tools/authenticator/auth-guide/oath.html#password-protection)
(or similar) to improve UX.

## Using your hardware security key

Continue to use your hardware security key for:

1. [Multi-factor authentication](./mfa.md)
1. [SSH](./ssh_keys.md)
