# Introduction

You are reading the security handbook of the Stacks ecosystem.

## Target audience: everyone

The world out there is scary and adversarial. Regardless of what you do at
Stacks, you _MUST_ read this handbook and apply its best practices to keep you
(and the ecosystem) safe. Where appropriate, you will also find more specific
pointers (e.g., if you are a developer, a trader, etc.).

## How to use this handbook

Security always involves trade-offs (e.g., against usability). We need our
ecosystem to be safe, but we also need to get work done. This handbook tries to
make all this as easy as possible for you, by:

1. Clearly calling out what is non-negotiable from a security standpoint
   (`MUST`s).
1. Making it as easy as possible for you, the reader, to follow what is
   required...
1. ...while ensuring you understand _why_ requirements are there and what
  [threat model](./threat_model.md) they protect from.

In practice, this means that this handbook will tell _both_ the requirements
and how to implement them, so you do not need to reinvent the wheel or venture
on a number of side-quests.

Where possible, a secure setup should be the default (e.g., when using a
pre-configured laptop).

You _SHOULD NOT_ deviate from what is recommended unless you have an _excellent
reason to do that_. If you think that's the case, check with your line manager.
