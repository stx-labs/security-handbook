# For developers

Developers are a particularly vulnerable target for exploitation, since they must download and run code as part of their daily routine.  Most attacks begin by exploiting developers, and then attempt to move laterally within and without the organization.

One specific attack vector to be aware of is fake interviews.  These have targeted both internal and external developers in the ecosystem.  This allows the attacker to request that a developer downloads a repository from GitHub (or similar), which is then used to infect the developer's machine.  Any locally stored credentials are extracted and exfiltrated; cryptographic wallets are drained, and exploit code is uploaded to any repository for which the developer has access.

Another attack vector which has often been employed against developers is the watering hole attack.  This targets resources which many developers are known to use, and can include anything from source repositories to coding help sites.  Examples include widely used Javascript packages on NPM, ads on websites like StackOverflow, etc.

## How to protect yourself

1. You MUST follow [these](./phishing.md) guidelines to avoid being phished.
2. You MUST use hardware backed [SSH keys](./ssh_keys.md) when interacting with [GitHub](./github.md).
