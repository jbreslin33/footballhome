# Aider Context: Members

Use this file as the first file you pass to aider for the Members screen.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the Members-screen task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses membership,
	payments, or roster boundaries.
3. For LeagueApps-derived membership freshness, use the membership source-of-truth
	pack instead of guessing from frontend symptoms.
4. Keep screen workflow notes here brief; move durable membership rules to
	`CONVENTIONS.md`.

## Members Screen UI

Use for the admin Members screen layout, filters, sorting, slim grouped member
cards (name + DOB + View), bulk actions, and person drill-down links. Contact
and LeagueApps Manager links live on Person profile, not on Members cards.

```text
/add frontend/js/screens/members.js frontend/js/components/FilterBar.js frontend/js/components/PersonActions.js frontend/js/screens/person.js
```

## Members API

Use for `/api/admin/members`, paused/active membership variants, grouped member
payloads, and membership sync trigger behavior.

```text
/add backend/src/controllers/AdminLaBackfillController.cpp backend/src/controllers/AdminLaBackfillController.h backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h backend/src/core/Controller.cpp backend/src/core/Controller.h
```

## Membership Source Of Truth

Use when the task involves whether member data is fresh from LeagueApps before
the screen renders.

```text
/add CONVENTIONS.md .github/copilot-instructions.md docs/aider/membership.md scripts/enforce-la-sync.sh backend/src/core/Controller.cpp backend/src/core/Controller.h backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h
```

## Person Profile From Members

Use when clicking a member card or person drill-down shows wrong membership,
contact, billing, or roster details.

```text
/add frontend/js/screens/person.js backend/src/controllers/PersonProfileController.cpp backend/src/controllers/PersonProfileController.h backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h
```
## People Directory / Workbench

Use for Club Admin People Directory and the Accounts / Players / Staff /
Duplicates / Data Issues lenses on the Lighthouse person graph.

```text
/add frontend/js/screens/people-workbench.js frontend/js/screens/admin-club.js backend/src/controllers/AdminLaBackfillController.cpp backend/src/controllers/AdminLaBackfillController.h docs/operations-design.md
```
