# Email hardening

There are many attack vectors which use email as a primary conduit.  These include (spear)phishing attacks, direct exploits, and many others.  We will go into more detail about each of them below.

## Phishing attacks

At its heart, a phishing attack is an attempt to extract information from a user by posing as a trusted contact.  Often this will be an email that tricks a user into logging into a well known site via a fake portal; this will be used to extract login credentials from the user.  In some cases the login credentials are themselves the goal, and will be used to impersonate the users and move laterally.  In other cases, the goal is access to the targeted site, perhaps a cryptocurrency exchange or source code repository.  Once inside funds can be stolen, attack code can be uploaded, and many other actions depending on the target.

Spear phishing attacks are like normal phishing attacks, except that are tailored to the specific target.  Instead of appearing to be an email from Coinbase, it will appear to be an email from a trusted colleague, or family member.  These attacks require more effort on the part of the attacker, but can bypass normal skepticism on the part of the target, and are therefore more effective.

One technique which many phishing attacks employ is to create a sense of urgency in the target.  A user of a cryptocurrency exchange might be told that their account has been locked, or that they must immediately register for an airdrop.  In any case the user will be told that without immediate action, they will suffer some sort of penalty, financial or otherwise.

To combat phishing attacks, there are a number of techniques which users can employ.

1. Turn off automatic image loading.  Images can be used to obscure link targets, and can even be used in direct exploits (see below).  Web bugs (invisible images) allow attackers to know that you are viewing an attack email from a vulnerable email client.
2. Turn off Javascript.  This can also be used to obscure link targets, for direct exploits, and allow notifying attackers.
3. Check the domain of all email senders.  An email purporting to be from Coinbase will never come from a Gmail account, or anywhere other than coinbase.com.  Often attackers' domains will begin with something reasonable, but then end in some foreign country code domain.
4. If there is any doubt about the source of an email, use a secondard communications path (slack, telephone, etc) to verify its legitimacy.
5. Configure email clients to popup link targets WITHOUT automatically loading them.  This prevents attackers from being able to exploit certain rendering bugs when you haven't even clicked on the link.
6. If there is any doubt about a link, manually go to a web browser and enter to the domain in question.  If a site needs you to handle something, there will be an option to do so after logging in.
