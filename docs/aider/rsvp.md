# Aider Context: RSVP

Use this file as the first file you pass to aider for RSVP work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## Player RSVP Screen

Use for the signed-in player's My Schedule screen, per-event RSVP buttons,
recurring RSVP buttons, and the weekly player-facing event list.

```text
/add frontend/js/screens/my.js backend/src/controllers/CalendarController.cpp backend/src/controllers/CalendarController.h docs/calendar-design.md
```

## Public Calendar RSVP Buttons

Use for the public calendar event list and its RSVP button behavior.

```text
/add frontend/js/screens/calendar.js backend/src/controllers/CalendarController.cpp backend/src/controllers/CalendarController.h docs/calendar-design.md
```

## Standing RSVP Applier

Use when recurring RSVP preferences are saved correctly but not applied to
events after RSVP windows open.

```text
/add scripts/gcal-rsvp-apply-standing.js backend/src/controllers/CalendarController.cpp database/migrations/119-gcal-schema.sql docs/calendar-design.md
```

## RSVP Reminder Admin

Use for admin/coach reminder flows and non-responder lists.

```text
/add backend/src/controllers/EventReminderController.cpp backend/src/controllers/EventReminderController.h frontend/js/screens/club-events.js docs/calendar-design.md
```

## Legacy Event RSVP

Use only when the task explicitly involves the older chat/event RSVP flow, not
the player-facing Google Calendar RSVP layer.

```text
/add backend/src/controllers/EventController.cpp backend/src/controllers/EventController.h frontend/js/screens/club-events.js
```