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
  - Assignment: sticky by default — each player keeps a "home job" for speed/efficiency; NO forced rotation.
  - Gaps (regular absent / short numbers): fill first with someone who's done the job before, then whoever has done the fewest jobs lately. Cross-training happens organically via absences/overlap.
  - Late RSVPs re-run the fill logic; home jobs never get bumped, only gap-fills reshuffle.
  - APSL game-day job set:
    - Sub cards: 1 guy who starts on bench. If he's subbed in, job passes to whoever was subbed off; if he's injured, reassign to another guy.
    - Conduct non-ball warmup.
    - Conduct ball warmup.
    - Warm up goalie.
    - Tents: 4 guys put them up. Per-game toggle (default ON = we bring them); toggled off, those 4 get other jobs.
    - Water: 2 guys, 1 case each, reimbursed.
    - Bench discipline: make sure everyone on bench has pinnies on and stays seated on the bench — no standing or using a ball on the sidelines.

- [ ] Sim: resume at Slice 35 (M3 doc close-out), then M4 (2v1/2v2/3v2 + off-ball behaviors — seven already implemented/unit-tested, unwired per ADR §22.27), M5 (PressTrigger4v2), then add an 11v11 milestone (formation anchoring, team attack/defend mode, GK, basic restarts; check snapshot frame capacity at 22 slots). Full game = biggest scenario tile; drills stay the teaching path. See sim/DESIGN.md §15.

## Done

<!-- - [x] 2026-10-21 example item -->
