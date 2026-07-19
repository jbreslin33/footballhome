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

## Club Admin Communications

Club Admin now groups outbound tools under Communications: Messages, Socials,
and Posters & Assets. The message button should remain available contextually
on person/lead/roster/payment surfaces, but those entry points should converge
on one communications composer when the workflow grows beyond copy/paste.

Open follow-ups:

- Add a shared composer that can be opened from Members, Leads, Rosters, RSVPs,
  Payments, and event non-responder lists with recipient context prefilled.
- Keep poster and flyer assets reusable: printable exports, direct sharing, and
  social exports should come from the same asset source when possible.
- Add campaign grouping only when one workflow needs to bundle messages,
  socials, posters, and lead follow-ups around a single goal.

## Club Admin People

Club Admin should default to Lighthouse people only. Membership belongs under
People because `person_la_memberships` is attached to `persons`, but the Members
board remains a focused workflow inside the broader People area.

Open follow-ups:

- Add a People Directory workbench that shows one row per Lighthouse `persons`
  record with contact, account, player, coach/admin, membership, billing,
  roster, and RSVP status.
- Add Accounts, Players, Coaches & Admins, Duplicates / Merges, and Data Issues
  views under People as focused lenses on the same person graph.
- Keep scraped league/opponent-only people out of Club Admin by default. Put
  those records in System Admin / League Data until an identity-resolution
  workflow links them to a Lighthouse person.
- Add a later identity-resolution workflow for connecting current Lighthouse
  people to scraped league identities with admin-confirmed matches, not
  automatic name-only merges.