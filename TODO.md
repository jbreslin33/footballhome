# Football Home — TODO

Running list of fixes and feature ideas. Add items anywhere; move them to **Done** with the date when shipped.

## Bugs / fixes

- [ ]

## Features

- [ ] Finish #teams page: category pills should show the real rosters, and reflect who actually gets to RSVP based on categories. (Another session is working on this.)
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

- [ ] Game v2 — 3D 11v11, manager mode, drills-as-configs: **all design and progress in `game/DESIGN.md`** (protocol in `game/PROTOCOL.md`); never tracked here. v1 archived at `archive/sim-2d-v1/`. Pending op note: after the next frontend deploy, `sudo podman rm -f footballhome_sim` (see the archive README).

## Done

- [x] 2026-10-21 Incremental backend deploys: persistent builder container + Dockerfile.fast; `make deploy` ≈ 1 min (was 8–10), `make deploy-clean` keeps the full hermetic build, builds flock-locked for parallel sessions. (-j stays 2: gcc-12 ≈ 2 GB/job on the 8 GB box.)
- [x] 2026-10-21 #invoices: calendar hour entries carry real event names (noteless day rows borrow the gcal events their window overlaps; sheet's labor line keeps the duty title).
- [x] 2026-10-21 #invoices: ref fees default GREEN onto a draft on open (mig 624); tap turns one red = off the sheet + remembered; tap again puts it back; amount editable per fee from the chip.
- [x] 2026-10-21 #invoices: hours editable per event — the 🟡 box takes any figure 0–24 (partial look only when below the event's own).
- [x] 2026-10-21 Lucca Santos = 📄 paper spot on Liga 1 (pseudo call-down: no standing Liga 1 games, per-game invites when wanted; plays via Reserves/APSL). Also fixed the 📄 toggle itself — text-vs-bigint la_user_id comparison 500'd every toggle since the alias-aware rewrite.
- [x] 2026-10-21 #teams: 🌐 league-roster mirror auto-pulls on every mens load, per-pill 🟡/green/red state with timestamps; Reserves got its own mirror (TeamPass section labels, migs 622/623).
