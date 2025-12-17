# Football Home Copilot Instructions

## 🏗 Architecture Overview
- **Frontend**: Vanilla JavaScript Single Page Application (SPA) using a custom Finite State Machine (FSM) for navigation.
  - **No Frameworks**: Do not suggest React, Vue, or Angular patterns. Use raw DOM manipulation and the custom `Screen` class structure.
  - **State Management**: Handled by `ScreenManager` and `NavigationStateMachine` in `frontend/js/`.
- **Backend**: Custom C++17 HTTP Server.
  - **No Frameworks**: Do not suggest Crow, Drogon, or Boost.Beast unless explicitly requested. The server uses standard sockets and a custom `Router`/`Controller` implementation.
  - **Database Access**: Uses `libpqxx` for PostgreSQL interactions.
- **Database**: PostgreSQL with `pg_cron`.
  - **Schema Management**: SQL scripts in `database/data/` executed alphabetically (e.g., `00-schema.sql`, `01-core-lookups.sql`).

## 🔧 Development Workflow
- **Primary Control Script**: Always use `./dev.sh` for builds and lifecycle management.
  - **Full Rebuild**: `./dev.sh` (destroys containers/volumes, cleans caches, rebuilds from scratch).
  - **Refresh Data**: `./dev.sh --refresh` (re-scrapes all data: APSL + CASA + GroupMe, updates SQL files, then rebuilds).
  - **NOTE**: No quick restart option exists. All rebuilds are full rebuilds.
  - **Terminal Output**: Avoid using `tail` command for viewing terminal output. Use `head`, `grep`, or pipe directly instead.
- **Database Changes**: 
- **Database Changes**: 
  - **Persistent Data**: Add a new numbered SQL file in `database/data/` (e.g., `75-club-admins.sql`). Data inserted here persists across full rebuilds.
  - **Schema Changes**: Add to appropriate numbered file, then run full rebuild (`./dev.sh`).
  - **Alphabetical Execution**: SQL files in `database/data/` are executed alphabetically by init scripts.

## 🔄 Data Scraping Architecture (OOP)
- **Scrapers**: Object-oriented Node.js scrapers in `database/scripts/`
  - Base classes: `Scraper`, `DataFetcher`, `HtmlParser`
  - Services: `IdGenerator`, `SqlGenerator`, `DuplicateDetector`
  - Models: `League`, `Team`, `Player`, `Match`, `Venue`
- **Scraper Implementations**:
  - `ApslScraper`: APSL league (apslsoccer.com) - ✅ Working
  - `CasaScraper`: CASA league (casasoccerleagues.com + Google Sheets) - 🔄 Needs parsing implementation
  - `GroupMeScraper`: 4 chat implementations (Training, APSL, Boys Club, Old Timers) - ⚠️ Untested
  - `VenueScraper`: Google Places API - ⚠️ Untested
- **Workflow**: 
  1. Scrapers generate SQL files in `database/data/` (committed to git for reproducibility)
  2. `./dev.sh` loads SQL files during database initialization
  3. Use `./dev.sh --refresh` to re-scrape and update SQL files
  4. Use specific flags for selective scraping: `--apsl`, `--casa`, `--lighthouse`, `--groupme`
- **Parsing Pattern**: When implementing new parsers, recover old scraper logic from git history if needed:
  - Old scrapers in commit `4e50246^` (before OOP migration)
  - Port working HTML parsing logic to OOP parser classes
  - Test with real data using team filters: `--team "Lighthouse"`

## 📝 Coding Conventions
### Frontend (Vanilla JS)
- **Screens**: All views must extend the `Screen` class pattern found in `frontend/js/screens/`.
  - Pattern: `class MyScreen { constructor(nav, auth) { ... } show() { ... } }`
- **Navigation**: Use `this.navigation.goTo('screen-name')` instead of `window.location`.
- **DOM**: Use `document.getElementById` or `querySelector`. Avoid `innerHTML` for complex updates; prefer `createElement`.

### Backend (C++)
- **Controllers**: Implement business logic in `src/controllers/` inheriting from `Controller`.
- **Routing**: Register routes in `HttpServer::setupRoutes()` in `src/main.cpp`.
  - Example: `router_.useController("/api/teams", team_controller_);`
- **JSON**: Use `Response::json(string)` for outputs.

### Database
- **Initialization**: Data is loaded via `docker-entrypoint-initdb.d` mapping to `database/data`.
- **Queries**: Write raw SQL in C++ models using `pqxx::work`.

## 🔍 Key Files
- `dev.sh`: Main entry point for all dev tasks.
- `frontend/js/app.js`: Frontend bootstrap and screen registration.
- `backend/src/main.cpp`: Backend server setup and route registration.
- `backend/src/core/Router.cpp`: Custom routing logic.

## 👥 User & Club Architecture

### User-Club Relationship
- Users are associated with clubs via the `club_admins` table
- Foreign key: `club_admins.admin_id` → `admins.id` (NOT users.id)
- When a user logs in:
  1. Query `users` table for email/password
  2. LEFT JOIN to `admins` table (some users may not be admins)
  3. LEFT JOIN to `club_admins` table to get `club_id` and club name
  4. Return club info in login response so frontend knows which club the user belongs to

### Club Hierarchy
- Club (e.g., "Lighthouse 1893 SC")
  - Can have multiple Sport Divisions (e.g., "1893 SC Soccer", "Boys Club", "Old Timers")
  - Each Sport Division has multiple Teams
  - Each Team has multiple Players

### Database Tables
- `users`: id, email, password_hash, first_name, last_name, is_active, etc.
- `admins`: id, admin_level, notes
- `club_admins`: id, club_id, admin_id, admin_role, is_primary, is_active
- `clubs`: id, display_name, slug, is_active
- `sport_divisions`: id, club_id, display_name
- `teams`: id, sport_division_id, display_name
- `team_players`: team_id, player_id, jersey_number
- `division_players`: Aggregated view of all players in a division (via division_teams.sql views)

### Persistent Data Initialization
- Manual users added to `50-users-manual.sql`
- Admin role assignment in `51-admins.sql`
- Coach info in `52-coaches.sql`
- Club admin associations in `75-club-admins.sql`
- All persist across full rebuilds via SQL init scripts
