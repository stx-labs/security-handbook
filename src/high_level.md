# At a high level

The [attacker](./threat_model.md) we are modeling for will only manage to
steal secrets they can access from your machine. They can't steal what is _not_
there or can't be reached from it.

The majority of the requirements and recommendations in this handbook will
diligently work in that direction: By ensuring your machine holds as few
secrets as possible (ideally none!). Then, multi-factor authentication through
external wallet keys will do the rest.

## What does this mean in practice?

### No cryptographic keys

You MUST NOT, under any circumstances, store cryptographic keys or wallet seeds
where an attacker can read them from your machine. You MUST NOT store
them in a password manager, as files, images, etc. Instead, use [hardware
wallets](./cryptographic_wallets.md).

**Why?**: An attacker compromising your device will not be able to steal
cryptographic keys from it _if they are not there_.

### 2FA: Always and on hardware devices

You MUST enable [two-factor authentication](./second_factors.md) on any and
all your accounts. The second factor MUST be a [hardware
device](./hardware_devices.md) (e.g., your smartphone, or a security key).

> Your organization will implement [Single
  sign-on](https://en.wikipedia.org/wiki/Single_sign-on) on as many services as
  possible. This way, you will only need to handle one account (e.g.,
  for Google Workspace).

**Why?**: An attacker who compromised your device might be able to get your
passwords, but they won't be sufficient without second factor (which will NOT
be on your device, but on separate hardware).

### Separate devices for work

You MUST use a [separate device](./work_devices.md) exclusively for work.

**Why?**: So that an attacker cannot compromise your _personal_ accounts _if_
they manage to compromise your work device.
