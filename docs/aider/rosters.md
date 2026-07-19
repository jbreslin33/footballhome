# Aider Context: Rosters

Use this file as the first file you pass to aider for roster work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the roster task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses membership,
	RSVP, payment, or public match-card surfaces.
3. Use `docs/aider/membership.md` when roster inclusion depends on LeagueApps
	membership authority.
4. Add the relevant frontend board and backend payload files together when the
	task changes displayed roster data.

## Rosters Hub UI

Use for the top-level Rosters screen, roster category tabs, and routing into
mens/boys/girls/youth boards.

```text
/add frontend/js/screens/rosters.js frontend/js/screens/mens-roster.js frontend/js/screens/boys-roster.js frontend/js/screens/youth-roster.js frontend/js/components/FilterBar.js
```

## Mens Roster Board

Use for the men's roster assignment board, RSVP eligibility toggles, payment
badges on mens cards, and mens roster payload shape.

```text
/add frontend/js/screens/mens-roster.js backend/src/controllers/MensRosterController.cpp backend/src/controllers/MensRosterController.h backend/src/models/MensRoster.cpp backend/src/models/MensRoster.h backend/src/models/MensTeamAssignments.cpp backend/src/models/MensTeamAssignments.h
```

## Youth / Boys / Girls Rosters

Use for boys/girls/youth roster display, parent contact actions, youth payment
badges, and youth roster payload shape.

```text
/add frontend/js/screens/boys-roster.js frontend/js/screens/youth-roster.js backend/src/controllers/BoysRosterController.cpp backend/src/controllers/BoysRosterController.h backend/src/models/BoysRoster.cpp backend/src/models/BoysRoster.h backend/src/controllers/YouthRosterController.cpp backend/src/controllers/YouthRosterController.h backend/src/models/YouthRoster.cpp backend/src/models/YouthRoster.h
```

## Game-Day Roster

Use for match-day 18/20 roster selection, lineup roster data, and public match
card roster output.

```text
/add frontend/js/screens/game-day-lineup.js frontend/js/screens/public-team.js backend/src/controllers/EventController.cpp backend/src/controllers/EventController.h backend/src/controllers/PublicController.cpp backend/src/controllers/PublicController.h
```