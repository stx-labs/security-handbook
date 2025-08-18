# Threat Model

Security is never absolute, instead always relative to a set of threats. This
page describes the threat model for this handbook.

## A remote attacker going for _monies_ 💰

99% of the time, attackers will go after crypto (tokens, stablecoins, you name
it). 99% of those times, the attack will play by the following book:

1. [_Spear phishing_](https://en.wikipedia.org/wiki/Phishing): Email,
   Telegram messages, fake meeting invitations. Anything to get you to download
   and execute a malicious file/application (technically, a "payload").
1. _Local device compromise_: The malicious file/applications gives an attacker
   (full) control of your machine. They will leverage it to grab any secret you
   have access to _and_ to spread further (e.g., to other members of your
   organization).
1. _Grab and run_: The attacker will enumerate all secrets on your system
   (usernames, passwords, seeds to wallets, cryptographic keys, etc.) and steal
   them. Then (sometimes a few weeks after) they will use those secrets to
   steal crypto funds and/or impersonate you, so they can spread the attack
   further.
1. _Lateral movements_: Impersonating you (e.g., on Telegram) allows the
   attacker to reach out to your social network (e.g., BD partners, fellow
   developers, etc.) and spear phishing them. So the cycle begins again.

This handbook will mostly focus on the threat model we just described, since
they account for 99% of the crypto heist we have collectively seen so far as an
industry.

In a few cases, the threat model will also expand to include additional threats
(e.g., [evil maids](./traveling.md)). When that happens, you will find it
properly highlighted.

## The remaining 1%

It is easy to think about additional threats, e.g. sophisticated attackers that
have deep pockets and are willing to spend millions of dollars to circumvent
the defenses we (as an ecosystem and as an industry) put up.

Those threats _do exist_, but they are order of magnitudes _less_ frequent than
all the others. An attacker will not spend a few million dollars 0-day to
remotely compromise you if they can just get you to click on a link and install
their malware.

For these reasons, this handbook will focus on the 99% threats that are
_prevalent_, while giving advanced readers pointers on how to (try to) mitigate
the remaining 1%.

If you believe you are being targeted by an attacker outside the threat model
depicted above, [reach out](./contacts.md)!
