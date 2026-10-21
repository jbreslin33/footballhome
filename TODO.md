# Football Home — TODO

Running list of fixes and feature ideas. Add items anywhere; move them to **Done** with the date when shipped.

## Bugs / fixes

- [ ]

## Features

- [ ] Finish #teams page: category pills should show the real rosters, and reflect who actually gets to RSVP based on categories. (Another session is working on this.)
- [ ] #invoices page:
  - "Manager of soccer duties" is too generic for the calendar — that's the invoice's sum-of-hours title. For the calendar check-off (hours filled by actually working), each entry needs the real event name.
  - Ref fees: green (on the invoice) by default, with a toggle to turn one red = leave off the invoice.
  - Ref fees: amount editable per fee.
  - Hour events: hours editable per event too.
- [ ] #jobs page — event jobs for games, practices, and other events:
  - Jobs are assigned per event based on who is actually going (RSVP + attendance); footballhome auto-assigns.
  - Practice job set: cones (pick up, into shed), balls (gather into bags, into shed), goals (put away any used), lights (6 LED lights w/ stands on generator — 1 player per light for take-down, 4 players carry lights to shed + tarp them), generator (someone shuts it off).
  - Jobs have a short title (balls, cones, lights, generator…) with detailed description on click.
  - Done/not-done check-off: default to DONE at end of event; only flag the exceptions by clicking "didn't do".
  - Job definitions + copy live in DB rows (per event kind), per the never-hardcode-copy rule.

## Done

<!-- - [x] 2026-10-21 example item -->
