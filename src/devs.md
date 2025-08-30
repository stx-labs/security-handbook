# For developers

Developers are a particularly vulnerable target for exploitation, since they must download and run code as part of their daily routine.  Recent attacks on the Stacks ecosystem began by exploiting developers, and then attempted to move laterally within and without the organization.

One specific attack vector which the Lazarus group is known to employ is fake interviews.  These have targeted both internal and external developers in the ecosystem.  This allows the attacker to request that a developer downloads a repository from GitHub, which is then used to infect the developer's machine.  Any locally stored credentials are extracted and exfiltrated; cryptographic wallets are drained, and exploit code is uploaded to any repository for which the developer has access.

Another attack vector which has often been employed against developers is the watering hole attack.  This targets resources which many developers are known to use, and can include anything from source repositories to coding help sites.  Examples include widely used Javascript packages on NPM, ads on websites like StackOverflow, etc.

To combat these kinds of attacks, we will be encouraging the use of separate, limited machines for all work coding.  Chromebooks, for example, have a limited attack surface, and can be configured to build and execute code in locked down containers and lightweight virtual machines.  This limits attacks in both directions; a RCE against a user's browser will not penetrate to the execution environment, nor will an infected dependency package penetrate to the user's general computing environment.
