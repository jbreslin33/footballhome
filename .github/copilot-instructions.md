# Football Home Copilot Instructions

## ⚠️ CRITICAL RULES (READ FIRST)

### Terminal Command Rules
**NEVER use these commands when showing build/scraper output:**
- ❌ `tail` - User wants FULL output, not last N lines
- ❌ `head` - User wants FULL output, not first N lines  
- ❌ `grep` - Do not filter build output
- ❌ `tail -f` - Do not use blocking/hanging commands
- ❌ Pipe to files (`> output.txt`) - Show output directly

**WHY:** User needs to see complete output to diagnose issues. Filtering hides critical errors.

**CORRECT:** `./build.sh` (full output)  
**WRONG:** `./build.sh 2>&1 | head -100` or `./build.sh | grep error`

### File Organization Rules
**Root folder is for:**
- ✅ Primary scripts: `build.sh`, `setup.sh`, `update.sh`
- ✅ Config files: `package.json`, `docker-compose.yml`, `.env.example`
- ✅ Documentation: `README.md`, `AI_TOOLS.md`, `*.md` design docs
- ✅ Wrapper scripts: `./claude`, `./aider`

**Root folder is NOT for:**
- ❌ Temporary HTML dumps (`team_schedule.html`, `standings_dump.html`)
- ❌ Temporary JSON files (`standings.json`)
- ❌ Scraper output (goes in `database/scraped-html/`)
- ❌ Test files or scratch files

**When scraping/debugging:**
- Write HTML to `database/scraped-html/[league]/`
- Write JSON to `database/scraped-html/[league]/`
- NEVER write temp files to project root

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

### Build & Update Commands
- **Full Rebuild**: `./build.sh` - Destroys containers/volumes, cleans caches, rebuilds from scratch
  - Reloads all SQL files from `database/data/` (bootstrap data)
  - Creates fresh database with current schema and bootstrap data
  - Use for: schema changes, major updates, fresh start
  
- **Update Scraped Data**: `./update.sh` - Runs scrapers and writes to database directly
  - Reads active targets from `database/scrape-targets.json`
  - Fetches fresh data from external sources (APSL, CASA, etc.)
  - Writes directly to running database (no SQL file generation)
  - Does NOT restart containers
  - Use for: refreshing match schedules, standings, rosters during development

### Data Management Philosophy

**Bootstrap Data (SQL Files in `database/data/`):**
- Schema definitions (`00-schema.sql`)
- Lookup tables (match types, positions, source systems)
- Manual reference data (organizations, leagues, seasons, admin users)
- Initial/seed data needed for fresh database creation
- Committed to git for reproducibility
- Loaded only during `./build.sh` (container initialization)

**Live Application Data (Database Only - NOT in SQL files):**
- Match scores and results (entered by users or updated by scrapers)
- RSVPs and user responses
- Chat messages
- Player statistics (calculated from match events)
- Standings (calculated or scraped, frequently updated)
- Any data modified during normal app usage
- Requires `pg_dump` backups for production
- NOT restored by running `./build.sh` (fresh database wipes this data)

**Data Restoration:**
- Development/Staging: Run `./build.sh` for fresh start with bootstrap data, then use `./update.sh` to refresh scraped data
- Production: Use `pg_dump` backups to restore live application data (user-generated content, scores, RSVPs, chat history)

### Database Changes
- **Schema Changes**: Update `00-schema.sql`, then run `./build.sh` to apply
- **Manual Static Data**: Add/update numbered SQL files in `database/data/` (e.g., `026-club-admins.sql`)
- **Alphabetical Execution**: SQL files load alphabetically during initialization
- **File Numbering**: Use prefixes (a/b/c) when order matters (e.g., `020-persons.sql`, `020a-players.sql`)

## 🔄 Data Scraping Architecture (OOP)

### Scrape Targets Configuration
- **Configuration File**: `database/scrape-targets.json`
  - Single source of truth for all scrape URLs and configurations
  - Each target: `source_system_id`, `url`, `description`, `config`, `fetch_frequency`, `is_active`
  - Target types: `reference_data`, `league_structure`, `roster_data`, `match_data`
  - Scrapers read config and write directly to database (no SQL file generation)

### Scraper Architecture
- **Base Classes**: `Scraper`, `DataFetcher`, `HtmlParser` (in `database/scripts/`)
- **Services**: `IdGenerator`, `SqlGenerator`, `DuplicateDetector`
- **Models**: `League`, `Team`, `Player`, `Match`, `Venue`

### Scraper Implementations
- `ApslScraper`: APSL league (apslsoccer.com) - ✅ Working
- `CslScraper`: CSL league (cosmosoccerleague.com) - ⚠️ Needs implementation
- `CasaScraper`: CASA league (casasoccerleagues.com + Google Sheets) - 🔄 Needs parsing implementation
- `GroupMeScraper`: 4 chat implementations (Training, APSL, Boys Club, Old Timers) - ⚠️ Untested
- `VenueScraper`: Google Places API - ⚠️ Untested

### Scraping Workflow
1. Configure targets in `database/scrape-targets.json`
2. Run `./update.sh` to fetch and write to database
3. Scrapers fetch fresh HTML/JSON from external sources
4. Parsers extract data and write directly to database tables
5. No SQL files generated (bootstrap data only in `database/data/`)
6. For fresh database: `./build.sh` (bootstrap) then `./update.sh` (scrape current data)

### Parsing Pattern
- When implementing new parsers, recover old scraper logic from git history if needed
- Old scrapers in commit `4e50246^` (before OOP migration)
- Port working HTML parsing logic to OOP parser classes
- Test scraped data via Super Admin dashboard (Matches, Standings, Data Quality reports)

## 📝 Coding Conventions

### 🎯 Core Principles (ALWAYS FOLLOW)
1. **Object-Oriented Programming (OOP)**: 
   - ALL code must use classes, inheritance, and encapsulation
   - Frontend: ES6 classes with proper constructors and methods
   - Backend: C++ classes with proper access modifiers (public/private/protected)
   - No procedural/functional code unless explicitly justified
   
2. **Database Normalization**: 
   - ALWAYS normalize database schemas (3NF minimum)
   - Avoid data duplication - use foreign keys and junction tables
   - Question any denormalized design before implementing

### Frontend (Vanilla JS)
- **Screens**: All views must extend the `Screen` class pattern found in `frontend/js/screens/`.
  - Pattern: `class MyScreen extends Screen { constructor(nav, auth) { super(); ... } render() { ... } onEnter(params) { ... } }`
- **Navigation**: Use `this.navigation.goTo('screen-name')` instead of `window.location`.
- **DOM**: Use `document.getElementById` or `querySelector`. Avoid `innerHTML` for complex updates; prefer `createElement`.
- **OOP Structure**: Group related functionality into classes with clear responsibilities

### Backend (C++)
- **Controllers**: Implement business logic in `src/controllers/` inheriting from `Controller`.
- **Routing**: Register routes in `HttpServer::setupRoutes()` in `src/main.cpp`.
  - Example: `router_.useController("/api/teams", team_controller_);`
- **JSON**: Use `Response::json(string)` for outputs.
- **OOP Structure**: Each feature should have dedicated classes (Controller, Service, Model)

### Database
- **Initialization**: Data is loaded via `docker-entrypoint-initdb.d` mapping to `database/data`.
- **Queries**: Write raw SQL in C++ models using `pqxx::work`.
- **Normalization**: Always use proper foreign keys, junction tables, and avoid redundant data
- **SQL File Organization**:
  - **Lookup Tables** (001-012): Static reference data (match types, admin levels, etc.)
  - **Core Entities** (013-040): Organizations, leagues, divisions, teams, base data
  - **Manual Data** (020-030): Developer-created reference data (persons, admins, users)
  - **Application Features** (050-080): Chat, events, stats, etc.
  - **Views & Functions** (090-099): Database views and helper functions
  - All files are bootstrap data (initial/seed data for fresh database)
  - Files load alphabetically - use prefixes (a/b/c) when order matters within same number
  - Live application data (scores, RSVPs, chat messages) NOT stored in SQL files

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
