# Football Home — TODO

Running list of fixes and feature ideas. Add items anywhere; move them to **Done** with the date when shipped.

## Bugs / fixes

- [x] 2026-10-21 Lineup edits all reverting on reload (David Masi ALT kept popping back): mig 618's cap-check query passed matchId as an unused $1 — Postgres fails the whole statement, so EVERY lineup save 500'd silently since the 10/20 deploy. Fixed param numbering; David re-set to ALT for tonight; other moves since 10/20 need redoing.

## Features

- [ ] Finish #teams page: category pills should show the real rosters, and reflect who actually gets to RSVP based on categories. (Another session is working on this. NOTE 10/21: the “who gets to RSVP” part shipped as the 👀 Sees games pill — name settled, see Done.)
- [x] #jobs page — SHIPPED 2026-10-21 (mig 625, see Done). Still open:
  - [x] 2026-10-21 Player visibility: 🧹 job strip on the #my event card (own + kids', whose-schedule-pill scoped), description on expand; feed carries my_jobs; RSVP writes re-run the auto-assigner so a late Going picks a job up without a coach opening #jobs; copy = message_templates kind=my_jobs (mig 629). Magic-link friendly for free (rides /api/calendar/upcoming).
  - [ ] Sub-cards pass-on from Game Center subs (today: manual reassign on #jobs).
  - ~~original spec below~~ — event jobs for games, practices, and other events:
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

- [ ] Game v2 — 3D 11v11, manager mode, drills-as-configs: **all design and progress in `game/DESIGN.md`** (protocol in `game/PROTOCOL.md`); never tracked here. v1 archived at `archive/sim-2d-v1/`. Pending op note: after the next frontend deploy, `sudo podman rm -f footballhome_sim` (see the archive README).

## Done

- [x] 2026-10-21 On Roster is GRANTED, never typed, on online-mirror teams (APSL/Reserves/Liga 1): the 🌐 pull auto-sets it on an EXACT normalized name match (upgrades paperwork states only; suspended/possible_drop and absences never touched — revoke stays manual via the drift panel). Manual grant blocked server-side + the dropdown shows "On Roster (via 🌐)" disabled; moving someone OFF stays manual. Youth (file-based rosters) keep full manual control.

- [x] 2026-10-21 #teams 👀 Sees games pill (every column, all sections): the ONE list a team's game invites reach automatically — active roster + 🩹 injured (excused, still see games) + ⭐ standing invites; 📄 paper spots excluded; call-up-gated teams count only ⭐ rows (Reserves reads 0, honestly). Panel lists the names. Name decided: “Sees games” (not “Functional”/“Active” — Active misses riders and lies on gated teams).

- [x] 2026-10-21 Schedule release reworked (mig 627): a weekday game posts ALONE 7 days out; its week's other games wait for Sunday 8 PM (reverses mig 603's whole-week open that had Nov-1 games showing on Oct 21). Also fixed the UTC date-cast bug that let Sunday 8 PM+ kickoffs (Real Central) ride into the new week's feeds, and a per-row window-function hot loop that briefly hung the dashboard.

- [x] 2026-10-21 Game Center DB-truth strip (mig 626): "Last change <stamp> · DB ✓ <synced>" on the lineup for coaches AND players — stamp is match_lineup_metadata.updated_at (every save touches it), 🟡 while saving, red with the server's reason when a save/sync fails. Born from the silent-save bug: the board can no longer lie.

- [x] 2026-10-21 #jobs page shipped (mig 625): job_definitions per event kind (practice set + APSL game-day set, copy in DB), auto-assign on every open from RSVP/attendance (sticky job_homes never bumped, gap-fill by done-before then fewest-in-60-days, second jobs only when short), default-DONE with "didn't do" flags, per-event tents toggle, manual assign/unassign. Admin+coach gated, #jobs tile under All tools.

- [x] 2026-10-21 Incremental backend deploys: persistent builder container + Dockerfile.fast; `make deploy` ≈ 1 min (was 8–10), `make deploy-clean` keeps the full hermetic build, builds flock-locked for parallel sessions. (-j stays 2: gcc-12 ≈ 2 GB/job on the 8 GB box.)
- [x] 2026-10-21 #invoices: calendar hour entries carry real event names (noteless day rows borrow the gcal events their window overlaps; sheet's labor line keeps the duty title).
- [x] 2026-10-21 #invoices: ref fees default GREEN onto a draft on open (mig 624); tap turns one red = off the sheet + remembered; tap again puts it back; amount editable per fee from the chip.
- [x] 2026-10-21 #invoices: hours editable per event — the 🟡 box takes any figure 0–24 (partial look only when below the event's own).
- [x] 2026-10-21 Lucca Santos = 📄 paper spot on Liga 1 (pseudo call-down: no standing Liga 1 games, per-game invites when wanted; plays via Reserves/APSL). Also fixed the 📄 toggle itself — text-vs-bigint la_user_id comparison 500'd every toggle since the alias-aware rewrite.
- [x] 2026-10-21 #teams: 🌐 league-roster mirror auto-pulls on every mens load, per-pill 🟡/green/red state with timestamps; Reserves got its own mirror (TeamPass section labels, migs 622/623).
