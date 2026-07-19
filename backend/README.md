# Football Home — C++ Backend

Custom HTTP server built with C++17, libpqxx, and nlohmann/json. No frameworks.

## Controllers

Controllers live in `src/controllers/` and are registered in
`src/main.cpp::setupRoutes()`. Treat `main.cpp` as the route registry; this
README is only an orientation point so it does not drift behind the active API.

Common route families include:

- `/api/auth`, `/api/auth/google`: login, cookie sessions, Google OAuth.
- `/api/admin`, `/api/leads`, `/api/ads`, `/api/social`: operations surfaces.
- `/api/calendar`, `/api/events`, `/api/my`: Google Calendar/FH event layering,
	RSVP, reminders, and player self-service.
- `/api/mens-roster`, `/api/boys-roster`, `/api/youth-roster`, `/api/internal`:
	roster and eligibility surfaces.
- `/api/payments`, `/api/person-billing`, `/api/charge-flags`: payment and
	billing operations.
- `/api/sim`: simulator lobby/debug bridge.

## Build

Built via rootful Podman through the root `Makefile` and `docker-compose.yml`.
For normal backend changes, run from the repo root:

```bash
sudo make deploy
```

`make deploy` runs the LeagueApps sync guard before rebuilding/replacing the
backend and frontend containers.

## Dependencies

- C++17, CMake
- libpqxx (PostgreSQL)
- nlohmann/json
- OpenSSL, libcurl
```