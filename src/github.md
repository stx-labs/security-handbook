# GitHub hardening

Since the Stacks ecosystem does the bulk of its development work in public repositories, it is crucial that those repositories be hardened against attack.  Any weakness in their configuration exposes our developers and users to attack vectors, as we have seen in previous attacks against the ecosystem from nation-state sponsored attackers.  The following policies MUST ALWAYS be implemented on EVERY repository.

## Commit signing

`git` does not, by default, do anything to verify that a commit comes from the user whose email address is tied to it.  This address is simply metadata, and a compromised developer machine can alter this data at any point in the commit/push process; we saw exactly this in previous attacks.

To combat this, you MUST require signed commits on your repositories.  You SHOULD require all users to enable `vigilant mode`, which adds an extra layer of obviousness when commits are unsigned.  This will prevent one infected developer from impersonating others.

## Branch protection

The `main` branch of a repository is the source of truth for external users, and where releases are normally taken.  So you MUST protect that branch against common problems, regardless of whether those problems arise from malice or simply negligence.  Rather than implement these rules piecemeal against every repository, you MUST implement them on the org level, so new repositories gain these protections without any extra effort.

First, you MUST disable force pushes against your main branch.  This prevents an infected developer from altering the history of a branch, in order to hide a malicious commit by making it appear to have happened in the past.

Next, you MUST require all changes to your main branch to go through the pull request process.  You SHOULD require two or more approvals for each PR.

Finally, you MUST protect the main branch from deletion.

## CI

Continuous integration is a powerful tool for preventing regressions in code, and allows us to make changes without unexpected side effects.  However, CI MUST be hardened in specific ways to avoid causing other problems.  

1. You MUST NOT include secrets in CI!  Instead use the github `secrets` APIs, which allow fine grained access control.  This can for example limit access to specific jobs run by specific people.
1. You MUST use OIDC for backend to backend authentication.  This allows the use of limited and expiring tokens in the place of passwords.
1. You MUST require reviews for deployments.  This limits the blast radius of any compromise, preventing infected code from reaching users.

