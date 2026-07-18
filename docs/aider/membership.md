# Aider Context: LeagueApps Membership

Use this file as the first file you pass to aider for LeagueApps membership work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## Source-Of-Truth Contract

Use when checking whether a route correctly syncs LeagueApps before reading
membership-derived data.

```text
/add CONVENTIONS.md .github/copilot-instructions.md scripts/enforce-la-sync.sh backend/src/core/Controller.cpp backend/src/core/Controller.h backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h
```

## Membership Sync Internals

Use for changing how LA registrations become persons, aliases, memberships,
phones, emails, or stale-ended rows.

```text
/add backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h backend/src/models/PersonLinker.cpp backend/src/models/PersonLinker.h database/migrations/081-person-la-memberships-registration-id.sql database/migrations/223-external-aliases-drop-name-uniqueness.sql
```

## Members / Admin Membership Surfaces

Use for admin member lists, unjoined members, person profile membership display,
and membership management screens.

```text
/add backend/src/controllers/AdminLaBackfillController.cpp backend/src/controllers/AdminLaBackfillController.h backend/src/controllers/LeadsController.cpp backend/src/controllers/PersonProfileController.cpp backend/src/controllers/PersonProfileController.h backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h
```

## Roster Membership Gates

Use when a roster, lineup, or eligibility screen includes/excludes players based
on active, paused, pickup, or category-specific memberships.

```text
/add backend/src/controllers/MensRosterController.cpp backend/src/models/MensRoster.cpp backend/src/controllers/BoysRosterController.cpp backend/src/models/BoysRoster.cpp backend/src/controllers/YouthRosterController.cpp backend/src/models/YouthRoster.cpp backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h
```