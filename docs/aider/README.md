# Aider Context Maps

This directory holds task-oriented file packs for aider and other AI agents.
These files are routing maps, not source-of-truth design docs.

## How To Use

1. Add the context map for the area you are working on.
2. Read the task descriptions and choose the smallest matching pack.
3. Add one pack first, unless the task explicitly crosses areas.
4. Add neighboring tests before neighboring implementation files when both are
   relevant.
5. Keep durable rules in `CONVENTIONS.md`, active designs in subsystem design
   docs, and only file-selection guidance here.

## Maps

- `calendar.md`: Google Calendar sync, classification, public calendar, and My
  Schedule file packs.
- `communications.md`: Club Admin messages, socials, posters/flyers, and
  outbound communications file packs.
- `members.md`: admin Members screen and related member profile file packs.
- `membership.md`: LeagueApps membership source-of-truth and sync file packs.
- `payments.md`: payment screen, payment API, and LeagueApps payment freshness
  file packs.
- `rosters.md`: roster hub, category roster boards, and game-day roster file
  packs.
- `rsvp.md`: player RSVP, public RSVP, standing RSVP, and reminder file packs.
- `sim.md`: canonical simulator context map with slice coverage.

When a map starts duplicating design details, move those details back to the
owning design doc and leave only the file-selection rule here.