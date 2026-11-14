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
2. **Calendar for every tier** — scopes, Go / No on tiles, person chips,
   auto-scroll, greyed earlier days. Removes `EventCenterScreen._staffView`.
3. **Notices + section panels** — Mine retires.
4. **`Panel` base**; EventScreen + PracticeScreen onto it.
5. **Game Center onto panels** — its `isCoach` (EligibilityController,
   keyed on roster teams rather than `fh_event_teams`) moves to
   `EventAccess`; its separate player-view layout goes.

Related: `docs/calendar-design.md`.
