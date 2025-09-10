# Phishing attacks

At their heart, phishing attacks are an attempt to exploit trust.  They trick you into leaking credentials, divulging confidential information, downloading malicious code, sending money, etc.  Often they will attempt to create a sense of urgency, for financial or safety reasons, which may override your natural skepticism.  Spear phishing attacks are like normal phishing attacks, except that are tailored to the specific target; they require more effort on the part of the attacker, but can bypass normal skepticism on the part of the target, and are therefore more effective.

## The playbook

All the attacks we have witnessed so far against our ecosystem play by this book:

1. Phishing and social engineering: someone will reach out to you, impersonating someone you might know, and invite you on a call, try to hire you, ask for your help on a development project, etc.
2. Local device compromise: the short-term goal of the attacker is getting you to download/execute something which will compromise your device. For instance:
    1. They'll tell you to copy/paste something to "unblock a web-page" (hint: that "something" will hack you).
    2. To "update your audio drivers" or your "Zoom SDK":
        1. Then replace your Chrome wallet with a fake so that if you sign using a hardware you will send funds to the attacker. (use X's translate feature to read)
    3. To "update your Meet/Zoom client"
3. Secrets and crypto gone: A compromised device is game over. The attacker will steal all your passwords, drain your wallets, and Telegram/X accounts.
4. Lateral movements: the attacker will start impersonating you to infect more targets.

## What to look out for

1. Be extremely suspicious when someone reaches out through an unusual channel, e.g. if you usually chat on Slack and they are reaching out on Telegram, or someone sending you a random Calendly invite. If you have doubts, always double-check through another way (e.g., Slack or Signal) to make sure you are talking with the right person.
2. Be extremely suspicious when someone pressures you into downloading or executing something. It doesn't matter if you are late to a meeting, if you are trying to make a sale, or if your boss is pressuring you. Don't fall to the percieved sense of urgency. Do not download any update/driver/or execute commands, and reach out if you think something weird is happening.

## How to protect yourself

Once Stacks Labs will be fully setup, we will provide devices equipped with an EDR (Crowdstrike) that will warn if you are a victim to common threats and alert the team in case someone is trying to hack you.
Meanwhile, follow these recommendations:

1. No software wallets: you MUST NOT store wallet / seeds on your machine under any circumstances. Use [hardware devices](./cryptographic_wallets.md#hardware-wallets), such as a Ledger X.
    1. If you need to [share a wallet](./cryptographic_wallets.md#cold-wallets-1m) with a team member, do a 1/N on Asigna backed by a Ledger device instead of sharing the seed with your colleagues.
    2. For [very small amounts](./cryptographic_wallets.md#warm-wallets-1k) (e.g., <1000 USD), you MAY use a wallet app on your phone.  You MUST download it from the App Store and that is not a scam wallet).
2. [MFA](./mfa.md) everywhere: you MUST enable multi-factor authentication on ALL your work services. You MUST use Yubikeys (hardware security keys) for second factors. You MUST NOT store the second factor in a password manager.
3. Check email domains: an email purporting to be from Coinbase will never come from a Gmail account, or anywhere other than coinbase.com.  Often attackers' domains will begin with something reasonable, but then end in some foreign country code domain.
4. Check email headers: in Gmail, to the far right of the sender is a drop down menu.  One of the options is `Show original`, which will open a page containing the raw source of the email.  This will bypass attempts to obfuscate link targets.
5. You MUST use a secondary communications path (slack, telephone, etc) to verify the legitimacy of any communication where you doubt the authenticity.
6. You MUST manually go to a web browser and enter the domain when the source is in question.  If a site needs you to handle something, there will be an option to do so after logging in.
