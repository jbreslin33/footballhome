# Aider Context: Calendar

Use this file as the first file you pass to aider for Google Calendar and
Football Home event-layer work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the calendar/event task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses calendar and
	RSVP boundaries.
3. Keep Google Calendar source-of-truth design in `docs/calendar-design.md`;
	keep only file-selection guidance here.
4. Validate calendar or RSVP behavior with the smallest relevant backend,
	frontend, script, or migration check before widening scope.

## Calendar Sync And Classification

Use when Google Calendar events are missing, stale, misclassified, or not showing
as Football Home events.

```text
/add scripts/gcal-sync.js scripts/gcal-classify.js backend/src/controllers/CalendarController.cpp backend/src/controllers/CalendarController.h docs/calendar-design.md database/migrations/119-gcal-schema.sql database/migrations/120-gcal-fix-soccer-prefix-index.sql database/migrations/121-gcal-team-aliases-and-junction.sql
```

## Calendar Frontend

Use for the public calendar screen, visible event cards, public RSVP buttons, or
calendar filter/display behavior.

```text
/add frontend/js/screens/calendar.js backend/src/controllers/CalendarController.cpp backend/src/controllers/CalendarController.h docs/calendar-design.md
```

## Player Calendar / My Schedule

Use for the signed-in player's week view, player-facing event list, and RSVP
state shown on My Schedule.

```text
/add frontend/js/screens/my.js backend/src/controllers/CalendarController.cpp backend/src/controllers/CalendarController.h docs/calendar-design.md
```

## Host Timers

Use when calendar sync timers, standing RSVP timers, or systemd install behavior
are wrong.

```text
/add scripts/setup/setup-gcal.sh systemd/gcal-sync.service systemd/gcal-sync.timer systemd/gcal-rsvp-apply-standing.service systemd/gcal-rsvp-apply-standing.timer scripts/gcal-sync.js scripts/gcal-classify.js scripts/gcal-rsvp-apply-standing.js docs/calendar-design.md
```