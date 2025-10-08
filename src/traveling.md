# Traveling

Traveling exposes you to special risks, like the [Evil Maid Attack](https://en.wikipedia.org/wiki/Evil_maid_attack).  This attack involves a malicious actor gaining access to one of your devices through an official role, and then using that access to steal data or implant malware.  It is not limited to maids in hotel rooms, but rather any time any device is out of your control.  This includes coffee shops, conferences, airport security, customs, shipping, etc.  As always, though, we should keep in mind our [threat model](./threat_model.md), unless we have specific reason to worry about 1% attack scenarios.

## Common attacks

### Physical

1. You MUST NEVER leave a device unlocked AND unattended.
1. You MUST use full disk encryption on any device which supports it.
1. You SHOULD power devices off before leaving them unattended, not simply lock them; this prevents a lockscreen compromise from granting access to the unencrypted disk contents.
1. You SHOULD choose hotels which have in-room safes, which will reduce the number of people who have access to it while you are at dinner or the pool.
1. You SHOULD keep a [low profile](https://a16zcrypto.com/posts/article/personal-physical-security/).
1. You MAY use a screen protector to mitigate shoulder surfing.

### Network

1. You SHOULD use a VPN when using WiFi.
1. You MAY get a local SIM card if you don't have a global carrier; but even then a VPN will protect you against some attacks (e.g. [stingrays](https://en.wikipedia.org/wiki/Stingray_phone_tracker)).

## Uncommon attacks

Mitigating uncommon attacks often requires extreme measures, which will impact your ability to do work.  Always remember your [thread model](./threat_model.md)!

1. You MAY choose to wipe your devices before flying, or crossing international borders.
1. You MAY choose to engage [Lockdown Mode](https://support.apple.com/en-us/105120).
