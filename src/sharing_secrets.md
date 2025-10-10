# Sharing Secrets

[Developers](./devs.md) should NOT share secrets with each other (or anyone else) unless absolutely necessary.

Occasionally, a secret will need to be passed from one developer to another in order to conduct our work. For example, communicating a secret to be used in GitHub Actions to a DevOps Engineering (who has the ability to write it to the repo's Secrets vault).

## Use Approved Tooling

Use the company adopted and approved secrets management tool to create and share secrets via short-lived, "self-destructing" links.

## Creating A Self-Destructing Link

When creating these links, follow these best practices:

- Get on a video call with the party who will receive the secret and verify their identity before proceeding
- Create a short-lived and self-destructing link live while on the call with the recipient
  - Ensure that this link is very short lived (5 minutes or less)
  - Ensure that this link Can be viewed only 1 time before expiring

## Best Practices

- ALWAYS verify the identity of the recipient via video call before proceeding to share a secret.
- ALWAYS be vigilant and suspect [phishing attacks](./phishing.md)
- NEVER share secrets via communication tools (For example: Signal, WhatsApp, Slack, Discord, Telegram, etc.).
- NEVER share secrets with ANYONE outside of Stacks Labs.
