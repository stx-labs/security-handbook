# Work devices

A separate work laptop allows ***you*** to **keep your work and life separate**, without having to worry about privacy or attacks spilling over your your personal accounts.

When under stress the minute you discover your work account has been hacked, you don’t want to also be worried about securing your personal finance, your network perimeter, your family devices, etc. We have been through this and it is *not nice*.

A work laptop also allows clearly separating the online identity you use for work and outside of it. For instance, it allows to easily create and use new accounts (GitHub, X, etc) for work, without having to constantly log-in and log-out or use separate browser profiles. For those of us who want to keep a reduced online footprint (e.g., do not link my personal X account with the one I use for Stacks) this also reduces the likelihood of using the wrong account in the first place and reveal the connection. For developers, a separate work device means separate CLI/git/SSH configuration, which could otherwise be very painful to manage.

## Context

### State-sponsored attackers

Our industry is continuously targeted by state-sponsored attackers that use this playbook:

1. Spear phishing
2. Local device compromise (including Telegram accounts, 1Password passwords, etc.)
3. Steal crypto
4. Spread and repeat

### We have seen this happening

We have witnessed multiple attacks against the Stacks ecosystem, ranging from developers being compromised when pulling and executing code from GitHub (even from internal repositories) to users falling victim of phishing and being tricked into executing malware on their devices.

The range of these attacks is wide and sophisticated and, as our ecosystem grows, the probability of succeed will only increase (due to an increased attack surface).

### How to fight back

We need to take steps to prevent this from happening, and implement better security strategies, roll out coordinated policies and ensure that everyone is aligned on what to do and what to avoid (e.g., [keep your MFA on a Yubikey and nowhere else](./mfa.md)).

#### Deploying hardened laptops

Our strategy is based on the [Swiss Cheese Model](https://en.wikipedia.org/wiki/Swiss_cheese_model). Hardened laptops ensure an additional layer of defense to keep us all safe.

One important part of hardening a laptop is to enable [full disk encryption](https://en.wikipedia.org/wiki/Disk_encryption#Full_disk_encryption).  This prevents an attacker from accessing the hard drive directly, either to read data or implant malware.  In order to maximize the effect of disk encryption, a [strong password](https://pages.nist.gov/800-63-4/sp800-63b/passwords/) MUST be used.

## **Endpoint Detection and Response (EDR)**

“*Endpoint Detection and Response*” or EDR is a fancy, enterprise term for a software that runs on your laptop and helps keeping it safe.  Companies in the ecosystem SHOULD pick an implementation that can be configured such that it will yield *low* false positives (e.g., it shouldn’t flag running `bitcoind` as malicious) and a good security posture. In other words, it will do its job and get out of the way, for all of us to do ours.

EDR SHOULD NOT prevent you from doing things your way (e.g., installing `homebrew`), but it SHOULD protect you in case a `homebrew` package gets [backdoored](https://www.stepsecurity.io/blog/ctrl-tinycolor-and-40-npm-packages-compromised) and tries to execute a malicious payload.

### Why are we pushing for an EDR?

You SHOULD pick and configure an EDR to do the following:

1. **Alert your organization** in case of anomalies (e.g. a debugger attached to a password manager, a process enumerating files, uploading your home directory somewhere, etc.).
    1. This will tell your organization when someone is hacked right away, giving yourselves a chance to jump ahead of the attack (e.g., disabling users, rotating keys, etc.).
    2. Without it, you would typically discover the hack when it’s too late.
2. **Prevent *some* attacks** altogether.
    1. EDR is no magic bullet and won’t stop 0-days or very sophisticated attacks.
    2. You SHOULD ONLY deploy a solution that protects against *all* malicious payloads we have seen used in web3.
3. Send an **audit trail** to a remote server.
    1. This way, if someone gets hacked and the attacker deploys anti-forensics measures to cover their traces, you will still have trace of what happened on the machine.
    2. With more visibility, comes more power to contain the attack and stop it from spreading. Without EDR, you will be running in the dark trying to figure out what the attacker did.
