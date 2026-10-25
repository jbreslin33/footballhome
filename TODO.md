# Football Home — TODO

Running list of fixes and feature ideas. Add items anywhere; move them to **Done** with the date when shipped.

## Bugs / fixes

- [x] 2026-10-22 Home lands on #role-selection for everyone (admins went to #dashboard since 10/9). Dashboard kept as the first "Run the week" tile on the picker. navigation.js home().

- [x] 2026-10-22 Game Center Instagram card 4:5 crop: confirmed by the math — Instagram crops feed posts taller than 4:5, and the roster card (540×700) and long post_game lineups (500+rows×23) exceeded it, losing the header and sponsor footer. Fix: the card now WIDENS to exactly 4:5 when content pushes it past (540 stays the floor; squarer cards untouched); game-center live card + beam follow built.width. Backend untouched — video already fits to the overlay's ffprobed size.
- [x] 2026-10-21 Lineup edits all reverting on reload (David Masi ALT kept popping back): mig 618's cap-check query passed matchId as an unused $1 — Postgres fails the whole statement, so EVERY lineup save 500'd silently since the 10/20 deploy. Fixed param numbering; David re-set to ALT for tonight; other moves since 10/20 need redoing.

## Features

- [x] 2026-10-21 Finish #teams page: closed as shipped — the “who gets to RSVP” half is the 👀 Sees games pill, the “real rosters” half is the per-column category pills (✅/📄/🩹/⭐, 10/20) + the 🌐 league mirrors + Girls filtering to real Girls Club players (since 9/24). Note if wanted later: those per-column pills live on the MEN'S board only — Boys/Girls/Womens columns are plain.
- [x] #jobs page — SHIPPED 2026-10-21 (mig 625, see Done). Still open:
  - [x] 2026-10-21 Player visibility: 🧹 job strip on the #my event card (own + kids', whose-schedule-pill scoped), description on expand; feed carries my_jobs; RSVP writes re-run the auto-assigner so a late Going picks a job up without a coach opening #jobs; copy = message_templates kind=my_jobs (mig 629). Magic-link friendly for free (rides /api/calendar/upcoming).
  - [x] 2026-10-21 Sub-cards pass-on from Game Center subs: after kickoff, a lineup save that brings the holder on (bench→starter) hands the job to the ONE player who went off in the same save (source 'pass', 🔁 on #jobs); ambiguous saves (double subs, nobody off) stay manual. Pre-kickoff the job is bench-only: auto-assign releases a home/fill holder who's in the XI and prefers bench players (manual/pass never touched); lineup saves now re-run the assigner too.
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

- [x] 2026-10-22 Roster category pills on EVERY section: the whole pill machinery (✅/📄/🩹/⭐ + 🌐 league mirror + 👀 Sees games, filters, auto-pull, click wiring) lifted from mens-roster.js into RosterScreenBase, and the mens-only payload attach (autoInvites/callupOnlyTeams/officialRosters) into shared RosterBoardExtras.cpp now called by Boys + Womens too (Girls inherits Boys). club_file sources with no names get no 🌐 pill and no dead Pull-fresh button. Verified live on all three boards; pill prefs keep the old localStorage key so nothing resets.
- [x] 2026-10-22 Carpool addresses backfilled from LeagueApps: 308 person_addresses rows added (registrant + parent per registration; additive, existing addresses untouched). CURRENT rosters (removed_at IS NULL, active teams) are now 100%: Boys 61/61, Mens 60/60, Womens 17/17. (First tally counted removed roster rows too — the "67 men without" were all ex-roster: 63 removed in the 6/25 bulk cleanup, 4 swept for lapsed membership 8/9–8/22, 64 of them never had an LA account.) Re-run anytime to pick up new registrants — `scripts/la-address-backfill.py <program ids…> | psql` (full command in the script header); runs by hand because the classifier blocks Claude from piping PII.
- [x] 2026-10-24 Youth opponent contacts: PPR team-contacts sheet (#files, club_files 52) loaded into club_contacts — 53 coaches across Torresdale, Fishtown, RUSC, Parkwood, Bridesburg, KSC, West Philly, Samuel, East Falls, Academy (RUSC and Samuel added as clubs). DB-only; Game Center 📇 shows them on youth games.
- [x] 2026-10-23 Postmark working: the web login was the older account (server 20960000) whose approval form had never been submitted — submitted, approved instantly, DKIM + Return-Path verified; app switched to its token (env), Gmail delivery confirmed, Basic plan 10k/mo $15. The 9/24 account (21029573) stays pending and unused.
- [x] 2026-10-16 Newspaper book recapture: all 95 full-res pages in archive/newspapers-fullres; build_book4.py made print/brian-in-the-papers.pdf (full page + zoomed inset) and the pure-clippings PDF. (TODO line was stale until 10/24.)
- [ ] 2026-10-22 Seasonal chore: APSL TeamPass team id changes each season — re-point the 🖨 roster scraper + 🌐 mirror when the new season's pages go up.

- [x] 2026-10-24 FH Texter fallback (mig 673): Game Center ✉ CONTACT's club text and my-phone options merged into one "📲 Text" that picks its own route. Opted in → club number (Twilio). Not opted in → your phone via FH Texter, with the same personal game link / RSVP reminder / registration form. Phone offline, cap reached, STOP, or Blank → the copy & paste panel. The route is named under the option. Cards show 📱 sent → delivered → opened like club texts. One click per player, never a batch (owner's pick).

- [ ] 2026-10-24 League contacts in Game Center: the 📇 panel only knows opponent clubs (club_contacts). Add league-level contacts so a Women's game can reach the league in one tap:
  - Tri County (TCWSL, leagues.id 7): pull the league admin contact from https://www.tcwsl.com/.
  - Gordon Dunlop, ref assignor for Tri County AND PPR: email given by James 10/24 in chat; load it into the DB only, never git.
  - Needs a home that isn't a club (one person can serve two leagues), shown on the game's league in the 📇 panel. Loaded by psql or the page, never in a migration file (contacts-in-DB rule).

- [ ] 2026-10-24 Test with real sends (nothing sent yet): a two-parent family (Lina + Raynel get separate texts with their own links) and a tap-through on a new short sign-in link (footballhome.org/api/m/...). Only with James's go-ahead — the two-parent test messages real parents.
- [ ] 2026-10-24 FH Texter 1.2: refuse/flag texts when the app lacks SMS permission instead of taking them and failing (1.1 does that after a reinstall until "Allow restricted settings" + SMS are re-granted). Needs another sideload (Samsung Auto Blocker off).
- [ ] 2026-10-24 James's own $10 missed-RSVP fines on #my (Sep 23 – Oct 18) carried over from the "Jim" record in the mig 674 merge — owner decides whether to clear them.
- [ ] 2026-10-24 Roster boards (#teams) still show LeagueApps' raw outstandingBalance, so a pending bank payment (mig 690) reads as owed there until LA applies it. Display only — no rule uses it.
- [ ] 2026-10-24 Our U10 (PPR U10 Boys Blue) vs Torresdale: the PPR sheet has two Torresdale U10 Blue teams (Wasps / Stingers) — confirm which one plays us so the right coach shows.

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
