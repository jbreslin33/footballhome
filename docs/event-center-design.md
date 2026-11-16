# Event Center — viewer tiers, panels, one page for everyone

Owner 2026-11-14: *"the coach screen should just be more enhanced then
player/parent. the admin just more enhanced then coach"* · *"we just check
what they are and have a class for each possibility … use correct class
for each user to show what needs showing"* · *"do we need my section now?
lets think of proper build with oop concepts on front and back end"*.

## The rule

Every person sees the **same** Event Center. What changes between people
is only *how much* is on it, decided by two independent questions:

1. **Which tier is the viewer for this event?** Player/parent → Coach →
   Admin. Each tier is a strict superset of the one below: nothing a
   player sees moves, disappears or changes look when a coach opens the
   same event; the coach only gets more.
2. **Does this thing exist for the viewer's teams/section?** A data
   question, answered by DB rows — never by a hard-coded section check.
   Example: the Men's GroupMe shows because `chat_integrations` has a row
   for Men's; the parents' group appears the day its row is added.

A panel shows when both answers are yes.

The tier is **per event**, not per person. A U10 coach is Coach on U10
events and Player/parent on their kid's U12 game or a Men's game they
play in. Admin is the only tier that is the same on every event.

## Back end (C++)

| Class | Job |
|---|---|
| `EventAccess` (`models/EventAccess.{h,cpp}`) | `tierFor(person, fhEvent)` → `Player`/`Coach`/`Admin`. The ONE permission answer; every endpoint that gates on "coach of this event or admin" asks it. Backed by the SQL function `fh_event_viewer_tier(event, person)` (mig 1362) so the calendar feed computes the same answer per row. View-as is handled by passing the effective (viewed) person. |
| `EventScope` → `PlayerScope` → `CoachScope` → `AdminScope` *(slice 2)* | Which events the calendar lists. Player = own + kids' + invites/call-ups; Coach adds every event of the teams they coach; Admin adds everything. |
| `Notice` → `DuesNotice`, `VolunteerShiftNotice`, `RegGapNotice`, `BannerNotice` *(slice 3)* | Things about the person (and their kids), collected by `NoticeBoard`; words from `message_templates`. `GET /api/me/notices`. |
| `SectionFeature` → `GroupMeFeature` *(slice 3)* | Section-level extras that exist only when a DB row says so. `GET /api/me/sections`. |

Tier definitions (`fh_event_viewer_tier`):

- **admin** — the person has a row in `admins` (any level).
- **coach** — an active `team_coaches` row on a team tagged on the event
  (`fh_event_teams`). Off-schedule days (`fh_coach_off_schedule`) don't
  remove the permission — they only change the hat label `my_role`.
- **player** — everyone else who can see the event (players, parents,
  call-ups, club staff).

`my_role` (coach/player/invited/staff) stays: it is the **hat label** on a
card, not a permission.

## Front end (plain JS)

| Class | Job |
|---|---|
| `PlayerViewer` → `CoachViewer` → `AdminViewer` (`lib/viewer.js`) | Picked per event from `viewer_tier` (`Viewer.for(tier)`). Screens ask the viewer — `canMark()`, `canInvite()`, `canRemind()`, `canContact()`, `canAnswerFor()`, `canEdit()` — and never check roles themselves. Each child adds to `super`. |
| `Panel` base *(slice 4)* | `minTier`, `applies(data)`, `render()`. Every fold on every pill is a Panel; a screen filters its panel list by viewer + data and draws what's left. |
| `EventScreen` → `PracticeScreen` / `GameCenterScreen` | Organised by event **kind** (unchanged). Role is composition (the viewer), never a subclass of a screen — that would mean a class per kind × role. |
| Event Center = `NoticeStrip` + `WeekCalendar` + `SectionPanels` *(slices 2–3)* | Same three pieces for every tier. `MyScreen` retires. |

"👀 See as player" (every kind, coach + admin) and "See as coach" (admin)
just swap the viewer object; the screen stays the same.

## Mine goes away

| Mine today | Home |
|---|---|
| Your week with Go / No | Calendar tiles — Go / No on your own events, one row per kid |
| Kids' pills | Calendar person chips (Me · Kid A · Kid B, default all) |
| Call-in | The tile + event page (it belongs to an event) |
| Dues, volunteer shifts, reg gaps, banners | Notices strip pinned above the calendar |
| GroupMe | Section panel, shown when the section has a chat row |

## Calendar for every tier

- Mon–Sun grid with the red NOW line is standard for everyone, scoped by
  `EventScope` (a youth parent never sees Men's games).
- Earlier days of the week stay, greyed out like past events.
- Phone: on first open of the current week the page scrolls so the NOW
  line sits near the top with the last event before it visible. Not when
  stepping weeks or picking a date; coming back from an event restores
  the previous scroll. Wide screens don't scroll (all 7 days visible).

## Slices

1. **`EventAccess` + `viewer_tier`; viewer classes.** Feed, single-event
   GET and attendance GET carry `viewer_tier`; every "coach of this event
   or admin" gate in CalendarController asks `EventAccess`; `EventScreen`
   asks its viewer. No visible change. *(2026-11-14)*
2. **Calendar for every tier** — Go / No on tiles, person chips,
   auto-scroll, greyed earlier days; removed `EventCenterScreen._staffView`
   and the staff-only Mine / Club week pills (mig 1363). *(2026-11-14)*
   The feed's WHERE (`eligible` OR guardian OR call-in) already scopes per
   viewer, so the `EventScope` classes were NOT extracted yet — do it when
   a scope rule next changes, not as a no-op refactor. Until slice 3, Mine
   (MyScreen) rides inside the page by CSS order: dues + volunteer-shift
   banners above the calendar, the rest below, its own week hidden.
3. **Notices + section panels** — Mine retires. *(2026-11-14)* C++
   `NoticeBoard` (`models/NoticeBoard.{h,cpp}`: `Notice` → `DuesNotice`,
   `VolunteerShiftNotice`; `DuesStanding` also feeds the calendar feed's
   `dues` map) behind `GET /api/my/notices`; page side `lib/notices.js`
   (`NoticeView` → `DuesNoticeView`, `VolunteerShiftNoticeView`,
   `NoticeStrip`). 👤 Mine below the calendar = page links (words
   event_center link_*, mig 1366), `PushOptIn`, `SectionChat`
   (`components/section-chat.js` — in-app chat or the GroupMe feed, by the
   section's DB rows) and `FinesPanel` (`components/fines-panel.js`).
   MyScreen is no longer mounted anywhere (#my already redirects); its file
   stays only because `public-teams-list.js` borrows `_eventTitle` — delete
   it once that moves to `EventLabels`. The #my "Admin tools" toggle went
   with it (it only changed #my's own event list).
4. **`Panel` base**; EventScreen + PracticeScreen onto it.
5. **Game Center onto panels** — its `isCoach` (EligibilityController,
   keyed on roster teams rather than `fh_event_teams`) moves to
   `EventAccess`; its separate player-view layout goes.

## One Calendar — the 2026-11-16 evaluation and plan

Owner 2026-11-16: "#calendar is still confusing. rsvp, calendar and event
center should be one page. when you click an event it should take you to the
event with more details and lineups etc. practice and games should be
consistent interface and extend from same base class. we need total
evaluation."  Decisions: the page is called **Calendar**; games keep opening
on ⚔️ Starters & Bench; #rsvps folds in.

Found: three This Week doors (☑️ RSVP → #my → Event Center, 📋 Event Center —
the same page, 🗓️ Calendar — a second calendar, calendar.js, where a tap
opened a post/flyer menu or nothing for players).  GameCenterScreen (7.5k
lines) extends EventScreen in name only — it replaces render/_wire/onEnter
and keeps its own RSVP cards, attendance, invites, reminders, call-ins, poll.

1. **DONE (mig 1388)** — one 📅 Calendar page (EventCenterScreen, URL
   `#calendar`, screen key still `event-center`) for everyone: Week · Month ·
   Agenda (4 weeks); admins get ReleaseStrip + ClashStrip
   (`lib/calendar-ops.js`), ⚠ tag audit on tiles, unclassified Google events
   (tap → Google).  A tap always opens the event; 📷 post / 🖨️ flyer moved to
   the event's 👀 bar (`lib/event-posts.js`; games flyer only — their posts
   are Game Center pills).  calendar.js deleted; menu rows `player` and
   `game-center` off; `#calendar`/`#my`/`#event-center` land here.
2. **DONE 11/16 (214fb1e2, 6242037e, + split)** — a game loads only its own
   event (GET /api/calendar/events/:id) and the 15 s beat refreshes its
   RSVPs like a practice; the broken "RSVP & Player Details" sheet (wrote to
   a 410 endpoint) and Game Center's own game picker are deleted; the page
   tops out like a practice (👀 bar · pill row · your availability, draft
   bar on lineup pills only); 🎞 Weekend slideshows moved to the Calendar.
   game-center.js 7.5k → 4.2k lines: game-only parts in
   `screens/game-center/*.js` (tactics-plan, lineup-edit, opponent-contacts,
   roster-print, squad-notice, details-score, eligibility), mixed into
   GameCenterScreen by `lib/mixin.js` (parts never use `super`).
   Still open inside 2: Game Center keeps thin hooks over EventScreen
   (_markAttendance keyed by _fhEventId, its own invite/remind/text-mark
   loads with extra fields) — fold when touched.
   Was: **fold Game Center into the base.**  Delete GC's own RSVP cards,
   attendance marking, invites, reminders, call-ins and poll so games run
   EventScreen's (practice's) code; split the rest (lineup, posts, tactics)
   into modules under a slim game child.  Same shell for every kind: header,
   your availability, pills (👥 Players · details · carpool · jobs · chat;
   games + ⚔️ Lineup · 🎯 Tactics · 📇 Opponent · 📣 Posts; practices + Groups ·
   Plan).  Games still open on Starters & Bench.  RSVP screen is
   uptime-sensitive: test on a test event first.
3. **DONE 11/16 (mig 1391)** — #rsvps is the Calendar's 👥 By person half for
   admins (📅 By event · 👥 By person chips; RsvpBoardScreen hosted in
   #ec-people minus its header).  `goTo('rsvps', filters)` → Calendar, By
   person, filters kept; each history entry remembers its half; a phone
   reload mid-reminders returns to the board (resumeState).  Retired screens
   in browser history go through goTo's redirects.
4. **DONE 11/16** — `player-calendar` kept (👤 Mine → Players, the men's
   roster list) but titled **Players** from the same DB word as its link
   (event_center link_players); screen key unchanged.

Known: a month view loads in ~6.5 s (the upcoming feed is heavy per event;
a week ~1.4 s).

## Resume here (updated 2026-11-14)

Live on prod and pushed: slices 1–4 (04c69cf3, a832b432, be7b4554; fix
7b4fae69; slice 4 below). Migrations 1362, 1363, 1366, 1368 applied.
Backend deployed with EventAccess + NoticeBoard (slice 4 was frontend only).

**Before starting:** check `git diff --cached --name-status` before every
commit (a peer's staged `git rm` got swept into be7b4554 once).  The
orphaned 11/13 practice/game-center edits were committed as-is in 86a86a3c.

**Slice 4 — DONE: `Panel` base (EventScreen + PracticeScreen)**
- `lib/panel.js`: `new Panel({ key, minTier, applies(screen), html(screen) })`;
  `Panel.render(list, screen)` keeps those the viewer reaches, in order.
  `EventScreen.panels(pill)` → coming (player), jobs (coach), invites
  (coach, still to come), carpool (player, practice/pickup).
  `PracticeScreen.panels` adds team card (player) + 📞 calls (coach) on
  All Players, sides, plan + cones.  `pillHtml(key)` = `Panel.render`.
- Edit rights inside panels = server answer AND viewer:
  `_mayEditSides()` / `_mayEditCones()`; the 📋 Practice Plans button =
  `viewer.canEdit()`.
- 👀 See as: `this.seeAs` ('player' | 'coach' | null, reset per event);
  `get viewer()` returns the lower Viewer, `get realViewer()` the real one
  (data loads such as invites use the real one so nothing is missing on the
  way back).  Bar = `_seeAsHtml()`, words event_center see_as_* / tier_*
  (mig 1368).  Verified on prod as admin: as player the calls / jobs folds,
  P/A/L/E, ⋯ sheets, group editor, cone picker and plan button all go.
- Still open from slice 4: `att.canMark` / `att.canSetRsvp` remain because
  game-center.js:4800 and my.js read them — drop with slice 5 / my.js.
  Coach vs admin differ only by ✓/✗ answer-for on an open event; not yet
  eyeballed on a future event.

**Slice 5 — Game Center onto panels (part A DONE 11/14, panels pill by pill next)**
- DONE: one rule on the server — `EligibilityController::isMatchCoach` /
  `isEventCoach` = `EventAccess::canCoach` on the game's fh_event (fallback
  for an unbridged match: admin or home/away coach).  Lineup GET isCoach,
  lineup PUT gate and sides GET/PUT all use it.  Checked first: roster
  teams (fh_event_list_team_ids) vs fh_event_teams gave the same coaches on
  all 13 recent/upcoming games.  Side fix: a Liga 1 coach on a combined
  APSL/L1 game can now SAVE the lineup (the PUT used home/away only → 403).
- DONE: Game Center's own "👀 Player View / ✏️ Coach View" toggle is gone;
  the shared `_seeAsHtml()` bar sits atop every pill's head
  (`_gcSeeAsHtml()`, staff only, never on the #my door or under view-as).
  `viewMode` is a getter/setter over `seeAs`.  `isCoach` is a getter:
  raw `_isCoach` (lineup GET / drafter on own draft) AND not seeing as a
  player — so every coach tool hides; loads read `_isCoach`.
  `_staffView()` = realIsCoach && not player view (callins, ⋯ sheets, reg
  gaps, call-up section, message panel, card coachView).
  `_canPostSocial()` = `_mayPostSocial()` && not player view (🎞 weekend
  slideshows, post tools); loads use `_mayPostSocial()`.
  Attendance carries `viewer` (Viewer.fromAttendance) — the 🗓 P/A/L/E row
  asks `this.viewer.canMark()`.
- Verified on prod (game 75692422, after the 18:58 deploy): admin → player
  per pill: starters_bench 905→37 buttons, lineup 843→38, players 647→30
  (P/A/L/E 200→0), no console errors; back restores everything.
- PART B, lineup pills DONE: starters_bench / lineup body is one Panel
  list in `_render` (no `effectiveIsPlayerView` branch): player = db strip
  (maxTier player — the coach's sits in the toolbar), carpool off the
  official view, my eligibility, everyone's criteria, published-lineup note
  (maxTier player); coach = toolbar, reg gaps, 📣 group bar, everyone-plays
  note, card sections.  Coach-only locals are computed only past the
  `panelViewer.atLeast('coach')` early return.  `Panel` grew `maxTier` and
  asks `screen.panelViewer || screen.viewer`; Game Center's `panelViewer`
  = coach-or-up while isCoach (drafter on own draft included), else player.
  Coaches now also see the player panels (own starter eligibility, the
  closed EVERYONE criteria fold, carpool on draft views).
- PART B, pill tools DONE: `pillToolPanels(pill, byZone)` — game_day: 🎯
  plan, game details (coach), 🚗, 📇 (coach); post_game: score (coach);
  lineup: squad count + RSVP & Details (coach); lineup/starters_bench: 🎯,
  ✉️ message everyone (coach), 🚗, 📇 (coach), 🖨 official roster, 🖨
  roster sheet.  Verified per pill admin ↔ player on prod.  game_day /
  post_game have no body beyond their tools; 🎯 Tactics edits via
  `_tacticsCanEdit()` (isCoach getter, so See as covers it); 👥 All Players
  is EventScreen's list.  So Game Center has no separate player layout left.
  Lineup drafts keep their own per-draft edit right (isCoach flips per
  view) — not a tier.
- DONE: `att.canMark` / `att.canSetRsvp` dropped — `att` = { viewer, me,
  roster } on every screen; every gate asks the viewer.

**Event Center redo: slices 1–5 complete (11/14).**

Checked after (11/14): coach-vs-admin ✓/✗ on a future event (admin 64
cards, See as coach only their own); a non-admin coach via admin View as
(Ali Salah Alshami: coach on his youth practice — See as player only,
P/A/L/E, calls; player on the men's).  For that, auth.js now sends
?asPersonId on GET /api/calendar/events/:id and …/attendance (both
handlers already honoured it), and Event Center refuses every write under
View as (`_viewAsReadOnly()` in `_json`, the availability box and call-in;
`_saveFailed` shows it as a page note, never an alert — mig 1373).  A coach
whose coach-schedule days skip an event gets "not found" on it, as on their
phone — correct.

Left, optional: `EventScope` classes (feed SQL already scopes), real-phone
check of the auto-scroll, a volunteer pick from the strip end to end
(writes — do it by hand), SectionChat both-chats case.

**Loose ends**
- DONE 11/14: `screens/my.js` deleted (3,239 lines) — public-teams-list
  uses `EventLabels.title`; the `my` screen is gone from app.js / index.html
  (navigation already sends #my → Event Center 👤 Mine).  That retires the
  last `att.canMark` reader outside Game Center.
- `EventScope` classes (Player/Coach/AdminScope) not extracted — the feed
  SQL already scopes correctly; extract when a scope rule changes.
- Not yet verified: phone auto-scroll on a real phone (only simulated), a
  coach who is not an admin, a volunteer pick from the strip end to end.
- SectionChat shows GroupMe only for sections whose in-app chat is off
  (`messaging_enabled = false`, like the Men). If a section ever keeps its
  in-app chat AND gets a GroupMe, show both (the old #my had a separate
  box for that).

Related: `docs/calendar-design.md`.
