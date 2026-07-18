# Operations Design

This document holds active operational follow-ups that cross code areas. It is
not a general inbox; when an item becomes a standing rule, move it to
`CONVENTIONS.md`. When an item becomes a subsystem implementation plan, move it
to that subsystem's `DESIGN.md` or README.

## Email Delivery

Password reset email currently uses SMTP credentials from `env`. The fallback
provider is working, but sender branding and deliverability still need cleanup.

Open follow-ups:

- Re-encrypt `env.age` after any SMTP credential rotation so new servers decrypt
  the current runtime configuration.
- Spot-check forgot-password delivery to at least one non-Gmail mailbox and
  confirm the reset email is not spam-boxed.
- Revisit Google Workspace setup for a proper `footballhome.org` sender and
  update `SMTP_USER` / `MAIL_FROM` together when that account is ready.

## Instagram Token Refresh

Instagram long-lived tokens expire on a 60-day window. Add an automated refresh
job with a 50-day cadence so there is a 10-day safety margin.

Planned behavior:

- Call the Instagram refresh endpoint with `INSTAGRAM_ACCESS_TOKEN`.
- Parse the replacement token.
- Update the `INSTAGRAM_ACCESS_TOKEN` line in plaintext `env`.
- Re-encrypt `env.age` so the encrypted runtime bundle stays current.
- Log enough output to diagnose failures without printing the token value.

## Lead Conversion Lift

The Meta lead funnel needs stronger conversion follow-up after the initial email.

Open follow-ups:

- In Meta Ads Manager, add thank-you-screen website CTAs on active lead forms so
  high-intent submitters can continue directly to the relevant LeagueApps
  registration URL.
- Add a multi-touch follow-up sequence for unconverted leads:
  - Day 3: conversational nudge focused on questions and replies.
  - Day 10: social proof plus next-session urgency with the LeagueApps link.
- Add backend support for identifying leads due for follow-up by comparing lead
  contact history with active LeagueApps registration state.
- Add frontend filters/templates so operators can send the follow-up touches
  without copying text by hand.