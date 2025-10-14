# Sharing Secrets

## In General: Don't!

[Developers](./devs.md) should NOT share secrets with each other (or anyone else) unless absolutely necessary.

When using secrets to authenticate to systems programmatically (such as GitHub CI or 3rd party APIs), prefer short-lived authentication tokens based on OIDC (or a similar protocol).

## For Exceptions, Use Approved Tools

In rare cases, you will need to share a short-lived secret with another member of your organization. For example: when provisioning a new account for a user and providing them a temporary, first-login password (which should be immediately changed after logging in).

In these situations, use the company adopted and approved secrets management tool to create and share secrets via short-lived, "self-destructing" links.

## Create A Self-Destructing Link

When creating these links, follow these best practices:

- Get on a video call with the party who will receive the secret and verify their identity before proceeding
- Create a short-lived and self-destructing link live while on the call with the recipient
  - Ensure that this link is very short lived (use the minimum time offered by the tool, such as 5, 10, or 15 minutes)
  - Ensure that this link can only be viewed the minimum numbers of times that the tool offers before expiring (ideally 1 time)

## Best Practices

- ALWAYS verify the identity of the recipient via video call before proceeding to share a secret.
- ALWAYS be vigilant and suspect [phishing attacks](./phishing.md).
- NEVER share secrets via communication tools (For example: Signal, WhatsApp, Slack, Discord, Telegram, etc.).
- NEVER share secrets with ANYONE outside of your organization.

Trust your gut. When something feels off, immediately stop what you're doing and inform your manager as well as the CTO. They will help you assess the situation and take any appropriate actions to safekeep our organization.
