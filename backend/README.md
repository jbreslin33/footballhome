# Football Home — C++ Backend

Custom HTTP server built with C++17, libpqxx, and nlohmann/json. No frameworks.

## Controllers

| Controller | Prefix | Purpose |
|-----------|--------|---------|
| Auth | `/api/auth` | Login, register, logout, roles |
| Availability | `/api` | Player medical/academic status |
| Club | `/api/clubs` | Club directory + detail |
| Division | `/api` | Divisions, rosters by division |
| Eligibility | `/api` | Player eligibility engine |
| Event | `/api/events` | Matches, events, standings |
| GroupMe | `/api/groupme` | GroupMe sync + RSVP import |
| OAuth | `/api/oauth` | Google OAuth flow |
| Stats | `/api/stats` | Player/team statistics |
| SystemAdmin | `/api/admin` | System admin operations |
| TacticalBoard | `/api/tactical` | Tactical board CRUD |
| Team | `/api/teams` | Teams, rosters, practices, lineups |

## Build

Built via Docker (see `backend/Dockerfile`). The image is tagged `footballhome_backend`.

```bash
# From project root:
podman build --no-cache -t footballhome_backend -f backend/Dockerfile backend/
```

## Dependencies

- C++17, CMake
- libpqxx (PostgreSQL)
- nlohmann/json
- OpenSSL, libcurl
```