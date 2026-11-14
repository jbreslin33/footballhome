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

## Resume here (paused 2026-11-14)

Live on prod and pushed: slices 1–3 (04c69cf3, a832b432, be7b4554; fix
7b4fae69). Migrations 1362, 1363, 1366 applied. Backend deployed with
EventAccess + NoticeBoard.

**Before starting:** `git status` — another session had uncommitted edits in
`frontend/js/screens/practice.js` and `game-center.js` (and an untracked
`1346-lineup-move-contact.sql`). Ask over SendMessage before touching
those files, and check `git diff --cached --name-status` before every
commit (a peer's staged `git rm` got swept into be7b4554 once).

**Slice 4 — `Panel` base (EventScreen + PracticeScreen)**
- New `lib/panel.js`: `class Panel { key, minTier ('player'|'coach'|'admin'),
  applies(screen) → bool (does this exist for the event/team?), html(screen),
  mount(el, screen) }`. A screen keeps `panels(pill)` → Panel list, filters by
  `this.viewer.atLeast(p.minTier) && p.applies(this)`, wraps each in the
  existing `panelFoldHtml` (every panel is a closed fold — STANDING_OPEN
  list for the ones the owner names).
- Today's gates to convert are the `this.viewer.canX()` checks in
  `event-screen.js` (`_attendanceCell`, the card grid's canRemind /
  canContact / canSet, markAllBar, `_canInvite`) and `practice.js`'s
  `this.att.canMark` / `this.sides.canEdit` (groups, practice plan, cones).
  `att.canMark` / `att.canSetRsvp` are kept only for those not-yet-moved
  screens; drop them when nothing reads them.
- Add "👀 See as player" (coach + admin) / "See as coach" (admin) on every
  kind: swap `this.att.viewer` for a lower Viewer and re-render. No server
  change.

**Slice 5 — Game Center onto panels**
- Replace `isCoach` / `realIsCoach` (from `/api/lineup` →
  EligibilityController, keyed on the game's ROSTER teams) with
  `EventAccess` / `viewer_tier` — check the two team sets agree for every
  live game first (roster teams vs `fh_event_teams`); if not, decide which
  is right before switching.
- Its `viewMode` coach/player toggle and the separate player layout go:
  player view = the same panels with the coach ones filtered out.
- Lineup drafts flip `isCoach` per view (a drafter edits only their own
  draft) — that is an edit right on a draft, not a tier; keep it as its own
  check.
- ~7,400 lines; do it pill by pill.

**Loose ends**
- Delete `screens/my.js` once `public-teams-list.js` stops borrowing
  `MyScreen._eventTitle` (move it to `EventLabels`); then drop the `my`
  registration in `app.js` (navigation already redirects #my).
- `EventScope` classes (Player/Coach/AdminScope) not extracted — the feed
  SQL already scopes correctly; extract when a scope rule changes.
- Not yet verified: phone auto-scroll on a real phone (only simulated), a
  coach who is not an admin, a volunteer pick from the strip end to end.
- SectionChat shows GroupMe only for sections whose in-app chat is off
  (`messaging_enabled = false`, like the Men). If a section ever keeps its
  in-app chat AND gets a GroupMe, show both (the old #my had a separate
  box for that).

Related: `docs/calendar-design.md`.
