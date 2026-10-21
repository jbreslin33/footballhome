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

- [ ] Sim: 11v11-first plan. Tick Slice 35 (M3 doc close-out), then build ONE parameterized `MatchScenario(pitch, slots per team, formations, rules_flags)` — 11v11, 4v4, 2v1, and coach-painted scenarios are all configs of it (Slice 17 zone constraints = the paint primitive). Slice order: (1) formation anchoring from formation codes (concepts return_to_base/stay_in_zone already migrated), (2) team possession state machine, (3) wire the seven built-but-unplugged off-ball behaviors (ADR §22.27), (4) GK primitive, (5) dumb restarts — kickoff/throw-in/goal-kick/corner, NO offside/fouls in v1, (6) MatchScenario + tile + u16 snapshot-frame capacity check at 22 slots, (7) nearest-player switch so one human can run a team. M4/M5 drills become subset configs shipped after the spine, as data not code. See sim/DESIGN.md §15.
  - Guardrails vs old code: open with an audit slice (walk Match/AiController/scenario factory, catalogue 1v1-shaped assumptions into DESIGN.md); fix formation-driven role assignment FIRST (behavior bags are enum-keyed today); keep a small-sided MatchScenario config (e.g. 3v3) with its own determinism golden in CI from day one so decomposability is enforced, not promised. Known pre-flagged items: u16 wire frame cap at 22 slots, replay checkpointing at long tick counts.
  - References when building: HELIOS/agent2d Delaunay ball-relative formations (RoboCup 2D), Google Research Football rule-based 11v11 AI (C++), Buckland "Programming Game AI by Example" Simple Soccer (support spots). Mine for AI design only — re-express in fixed point, never port floats.

## Done

<!-- - [x] 2026-10-21 example item -->
