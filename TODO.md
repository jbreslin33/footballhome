# Football Home — TODO

Running list of fixes and feature ideas. Add items anywhere; move them to **Done** with the date when shipped.

## Bugs / fixes

- [x] 2026-10-22 Home lands on #role-selection for everyone (admins went to #dashboard since 10/9). Dashboard kept as the first "Run the week" tile on the picker. navigation.js home().

- [x] 2026-10-22 Game Center Instagram card 4:5 crop: confirmed by the math — Instagram crops feed posts taller than 4:5, and the roster card (540×700) and long post_game lineups (500+rows×23) exceeded it, losing the header and sponsor footer. Fix: the card now WIDENS to exactly 4:5 when content pushes it past (540 stays the floor; squarer cards untouched); game-center live card + beam follow built.width. Backend untouched — video already fits to the overlay's ffprobed size.
- [x] 2026-10-21 Lineup edits all reverting on reload (David Masi ALT kept popping back): mig 618's cap-check query passed matchId as an unused $1 — Postgres fails the whole statement, so EVERY lineup save 500'd silently since the 10/20 deploy. Fixed param numbering; David re-set to ALT for tonight; other moves since 10/20 need redoing.

- [ ] 2026-10-29 Lucca Santos "can only see game, not practice": not a pill/reminder-link issue — men's practices are tagged APSL 35 + Liga 1 120, and a 📄 paper spot (mig 619) or call-up-only team (Reserves 938, mig 605) grants NOTHING from the roster row, practices included. Same for Armando Pena (APSL 📄) and Justin Figueroa (APSL 📄). Lucca/Armando see APSL games only through their ⭐ standing invite. Fix (pending James): paper/call-up rows still grant the team's PRACTICES (games stay invite-only) in CalendarController is_mine/eligible — decide whether they're then reminded/fined for practices like everyone else.

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
- [x] 2026-10-28 Seasonal chore checked: 2026/27 (started Sept) already wired — official_roster_sources APSL + Reserves = TeamPass 165430, Liga 1 = CASA sheet, all pulling OK 10/27. NEXT due Sept 2027: APSL TeamPass team id changes each season — re-point the 🖨 roster scraper + 🌐 mirror (new 2027/28 source rows).

- [x] 2026-10-24 FH Texter fallback (mig 673): Game Center ✉ CONTACT's club text and my-phone options merged into one "📲 Text" that picks its own route. Opted in → club number (Twilio). Not opted in → your phone via FH Texter, with the same personal game link / RSVP reminder / registration form. Phone offline, cap reached, STOP, or Blank → the copy & paste panel. The route is named under the option. Cards show 📱 sent → delivered → opened like club texts. One click per player, never a batch (owner's pick).

- [x] 2026-10-26 League contacts in Game Center: the 📇 panel only knows opponent clubs (club_contacts). Add league-level contacts so a Women's game can reach the league in one tap:
  - [x] 2026-10-26 Tri County: league office loaded like APSL/PPR (clubs 66 + club_competitions 156 status='league', DB only) — mailbox + 6 board members from tcwsl.com/V2/contact.shtml. leagueJson now resolves the game's tag through gcal_league_aliases, so 'Tri County'-tagged games find the TCWSL office.
  - [x] 2026-10-26 Gordon Dunlop (Referee Assignor) loaded on PPR (62) and TCWSL (66) league offices — club_contacts 201/202, DB only.
  - Gordon Dunlop, ref assignor for Tri County AND PPR: email given by James 10/24 in chat; load it into the DB only, never git.

- [x] 2026-10-28 Real sends verified: two-parent family — Lina + Raynel each got their own FH Texter text with their own link for Angel (10/24, twice, all delivered; phone_relay_texts 4–7). Short sign-in links (footballhome.org/api/m/...): 19 sent, 3 tapped through to a sign-in (latest 10/27).
- [x] 2026-10-24 Coaches aren't fined (mig 693): James, Luke, Victor, Sheldon, Ali, Walter cleared; regular players keep the full schedule.
- [x] 2026-10-26 Roster boards (#teams) net a pending bank payment (mig 690) off LA's raw outstandingBalance: RosterBoardExtras::attach subtracts fh_membership_pending_bank_usd per registration on every board and adds pendingBankUsd (Jesueth's 10/20 $35 was the live case).
- [x] 2026-10-27 Our U10 (PPR U10 Boys Blue) vs Torresdale: GotSport (event 57473) has us playing BOTH — Strikers 9/19 + 10/25, Wasps 10/3 (L 1-6) + 11/8 home. The PPR sheet's "Stingers" (Patrick Gaghan, club_contacts 145) = GotSport's "Strikers"; Wasps = Alex Hughes-Taylor (144). Next Torresdale game is the Wasps, 11/8.

- [x] 2026-10-26 CASA Instagram 📸 buttons (mig 699): club_social_handles; handle field on #casa-contacts cards, 📸 per team on #casa-scores + "Open all" for unscored games; terminal check = "check all casa scores from insta" (.claude/skills/casa-insta-scores, CASA Chrome profile w/ VPN).
- [x] 2026-10-27 CASA Instagram handles: all 14 saved (8 via mig 731 on 10/26, the last six on 10/27 from James: Desert Hawks, Nomads FC, Persepolis FC, Philadelphia Lions, Phoenix + Phoenix SCM — the two Phoenix clubs share phoenixsc_official).

- [ ] #teams cleanup, Roster pill (the league side). Lanes from mig 777 (PROPOSED → PENDING ADD → OFFICIAL, OFFICIAL → DROPPING → PENDING DROP). Still open:
  - [ ] **Adds, split by pill.** Team pill = "is he one of ours?" → "＋ from LA" picks section LA registrants not on this team and puts them on it (reuse the card's /api/mens-roster/assign add). Roster pill = "what we owe the league" → "＋ To be added" picks only people already on the team but not on the official list (call-downs, paper spots, new signings) and sets a PROPOSED step (reuse the roster-status PUT). Then submit → PENDING ADD → the pull grants OFFICIAL. Adds count only in Projected.
  - [ ] **Mark a cut's drop as submitted.** A cut player whose team row was swept (no playing membership) has no roster status to move to PENDING DROP once we tell the league — needs a "drop submitted" mark on the list name.
  - [ ] Cut players off the Team pill: confirm a non-playing (pickup/inactive) membership doesn't keep a cut man showing as PLAYS (mig 810 changed what "cut" means).
  - [ ] Check teams.max_roster = 35 is the real league cap for APSL, Reserves and Liga 1 (Projected goes red past it).
  - [ ] Youth (file-based rosters): flag only, no auto-clear.
  - Not built on purpose: per-player dismiss of the cut flag — wait for a real case.

- [ ] Game v2 — 3D 11v11, manager mode, drills-as-configs: **all design and progress in `game/DESIGN.md`** (protocol in `game/PROTOCOL.md`); never tracked here. v1 archived at `archive/sim-2d-v1/`.

## Done

- [x] 2026-10-29 #teams Roster pill, cut + projected: on the league list without a live PLAYING LeagueApps membership = ✂ CUT — red row, still counts in the official total and keeps his #, red ✂ CUT block closing OFFICIAL ROSTER, derived via fh_in_leagueapps() (migs 807, 810, 811). PROJECTED ROSTER = official − cuts/dropping/pending drop + proposed/pending add, '→ N projected' on the banner, collapsible list with official #s, red past teams.max_roster (mig 809). Anthony Acevedo re-registered → back on Liga 1, proposed for Reserves (mig 813).
- [x] 2026-10-29 #teams men's cards: two dropdowns — Roster (league paperwork) and Team (Plays / Paper spot / Call-in + injured), replacing the 📄 toggle and health dropdown (mig 814). Somi Safavi proposed for APSL (mig 815). APSL Reserves TeamPass spellings aliased: Leo Santa, Lusayo Mwakatika (mig 808).
- [x] 2026-10-29 #leads: 📣 Live ads pill is the default; on load it asks Meta which ads are live and shows one column per live ad (3 now: Men's Club, Women's Club, Youth). The live youth ad files as "Youth (Grades K–9)" (was the old 1–6 funnel, mig 816). Every lead card shows when it came in ("Wed, 10/28, 10:20 PM · 10h ago"). Backup sync pulls every live ad's form.
- [x] 2026-10-29 Men's starter eligibility: weekday Liga 1 / APSL game week needs 0 practices (mig 804); otherwise practice days − 3, Mon–Sat (mig 805); Game Center says why (mig 806).
- [x] 2026-10-29 Server kept in RAM: vm.swappiness=10 in setup-base (screens hung while backend + postgres sat in swap).
- [x] 2026-10-28 Opponent coaches: write your own message in the Message dropdown (mig 803); FH Texter can text other teams' coaches; Opponents opened from a game defaults to "confirm the game".
- [x] 2026-10-28 Year-round promo: club post published to Instagram (Linktree, $35/month · uniform included, badges; migs 789–800); #ad-preview Pending approval + Hidden + Archive (migs 801, 802).
- [x] 2026-10-28 #awards: All-Stars to the PPR league director + club awards per team per season (mig 800). #teams season pills Fall · Winter · Spring · Summer (mig 795). PPR Indoor U10–U12 teams on the Boys board (mig 788).

- [x] 2026-10-27 #teams Players panel (migs 769–777): Roster | Team pills. Roster pill = the league's OFFICIAL ROSTER 1:1 in its order (full player cards, manual remove blocked server-side) + PROPOSED adds; league moves staged PROPOSED → PENDING ADD → OFFICIAL and OFFICIAL → DROPPING → PENDING DROP. Team pill = plays / paper / injured / call-downs. CASA pull grants On Roster by matched person (Liga 1 32 → 35); APSL list aliases for 4 spellings (migs 773/774).
- [x] 2026-10-27 Event Center = one Mon–Sun week calendar (migs 748, 750): type pills fill it, tap opens the event by kind, red NOW line, tiles show time + venue. OOP: EventScreen base → PracticeScreen + GameCenterScreen; one shared player card and CONTACT sheet, so practice cards text/email/call like game cards; practice opens on the big pill row (All Players · Groups · Practice Plan, mig 751).
- [x] 2026-10-26 Event Center slices (migs 738–744): Games · Practices · Pickup · All pills; No Response reminders (this event or all open); practice Who's Coming as RSVP cards; FH Texter sent → delivered / failed / opened on each card.
- [x] 2026-10-27 #casa-scores pills (mig 759): Not scored (+ auto-check report) · Upcoming · Scored · Postponed · Whole season; Instagram scores read headless on the server on a timer (mig 749).
- [x] 2026-10-27 Official league schedules for every team in league_fixtures, checked against the calendar (mig 758).
- [x] 2026-10-27 Game Center: bench cap = team's match-day squad, full bench offers "extend, this game only" (mig 760); several players per position + 👥 split squad A/B (migs 763, 765); CASA list decides the ⚠ registration gap, a sub's name taps itself (migs 767, 768).
- [x] 2026-10-26 Roll call card (/rc/<slug>?e=<id>) opens on its own event; Going / Not going under the event line; "all set" / "Action needed" status (mig 732); numbered one-per-line names.
- [x] 2026-10-26 Every RSVP records who tapped it (mig 729, answered_by_person_id). Going but not on the league roster → registration-form popup (mig 725).
- [x] 2026-10-26 Game Center 📇 email drafts to league contacts (migs 724/726/728): multi-recipient To list, big Open in Gmail button.
- [x] 2026-10-26 #invoices: APSL ref fees listed like every league (mig 718 undoes 717); turned-off ref fees stay off when the feed re-issues a game (mig 722); James's 2026.21/.22 sheet lines (migs 719–721, 735, 736).

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
