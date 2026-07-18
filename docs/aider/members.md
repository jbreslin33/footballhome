# Aider Context: Members

Use this file as the first file you pass to aider for the Members screen.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## Members Screen UI

Use for the admin Members screen layout, filters, sorting, grouped member cards,
bulk actions, and person drill-down links.

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