# Football Home — Vanilla JS Frontend

Single-page application built with vanilla JavaScript, no frameworks. Runs in nginx at port 3000, volume-mounted so CSS/JS changes are live (no rebuild needed).

## Architecture

- **Screen-based SPA**: Each feature is a `Screen` class with `onEnter()` / `onExit()` lifecycle
- **ScreenManager**: FSM controller that handles transitions and history
- **Pure CSS**: Custom properties for theming, no external CSS frameworks
- **API proxy**: nginx forwards `/api/*` to C++ backend at port 3001

## Screens (38 total)

| Area | Screens |
|------|---------|
| Auth | login, oauth-success, role-selection, context-selection |
| Club | club-directory, club-detail, club-events |
| Team | team-selection, team-dashboard |
| Roster | roster-dashboard, roster-management, roster-category |
| Match | match-list, match-detail, match-form, match-management, match-options, match-rsvp-management, MatchShareScreen |
| Game Day | game-day-roster (player selection + Instagram card), game-day-lineup (formation builder) |
| Practice | practice-list, practice-form, practice-management, practice-options, practice-rsvp-management, practice-attendance, training-attendance |
| Division | DivisionSelectionScreen, DivisionMenuScreen, DivisionManagementScreen, DivisionRosterScreen |
| Admin | admin-system, admin-club, admin-team, admin-entity-list, admin-level-selection, admin-sport-division |

## File Structure

```
frontend/
├── index.html
├── css/
│   ├── main.css              # Core design system + screen styles
│   └── game-day-roster.css   # Game day card + overlay styles
├── js/
│   ├── app.js                # Entry point
│   ├── auth.js               # Auth service
│   ├── screen-base.js        # Base Screen class
│   ├── screen-manager.js     # FSM screen controller
│   ├── screens/              # 38 screen implementations
│   ├── entities/             # Player, Ball entities
│   └── tactical-board/       # Tactical board feature
├── images/teams/logos/       # Team logo images (png/jpg)
├── Dockerfile
└── nginx.conf
```

## Development

Files are volume-mounted into the nginx container — edit and refresh the browser. No rebuild needed for frontend changes.

This vanilla JS implementation demonstrates that web applications can be built with pure JavaScript while maintaining clean architecture, predictable state management, and excellent performance.