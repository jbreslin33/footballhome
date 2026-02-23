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
- ✅ Primary scripts: `build.sh`, `setup.sh`, `Makefile`
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

### Makefile Targets (run `make help` for full list)
| Category | Command | Description |
|----------|---------|-------------|
| **Standard** | `make` / `make up` | Start containers (safe, non-destructive) |
| | `make build` | Build images and start containers |
| | `make rebuild` | Nuclear: clean + build fresh (wipes all data) |
| | `make down` / `make clean` | Stop / destroy containers |
| **Daily use** | `make load` | Load all committed SQL into DB |
| | `make load-apsl` | Load APSL only |
| | `make load-csl` | Load CSL only (needs APSL loaded) |
| | `make load-casa` | Load CASA only (needs APSL+CSL loaded) |
| **League init** | `make init-apsl` | Full APSL: parse → curate → load → events → export |
| | `make init-csl` | Full CSL: parse → curate → load → events → export |
| | `make init-casa` | Full CASA: parse → curate → load (no events yet) |
| | `make init-all` | Init all leagues (requires `make rebuild` first) |
| **Parse only** | `make parse` | Regenerate SQL from cached HTML (all leagues, no DB needed) |
| | `make parse-apsl/csl/casa` | Parse individual league |
| **Events** | `make events` | Scrape match events for APSL + CSL |
| | `make events-apsl/csl` | Scrape events for individual league |
| **Workflows** | `make rebuild && make load` | Fresh DB from committed SQL |
| | `make rebuild && make init-all` | Full init from cached HTML |
| | `make refresh` | parse + rebuild + load (fast refresh) |
| **Dev** | `make shell-db` | Connect to database shell |
| | `make ps` / `make logs` | Show containers / view logs |

### Common Workflows

**Fresh database from committed SQL (most common):**
```bash
make rebuild && make load
```

**Full init from cached HTML (one-time onboarding or re-scrape):**
```bash
make rebuild && make init-all
```

**Regenerate SQL without touching DB:**
```bash
make parse   # regenerates sql/ files from cached HTML
```

**Fetch fresh HTML from web, then rebuild everything:**
```bash
cd database/scripts/leagues/usa-apsl && ./scrape.sh && cd -
cd database/scripts/leagues/usa-csl && ./scrape.sh && cd -
cd database/scripts/leagues/usa-casa && ./scrape.sh && cd -
make rebuild && make init-all
```

### Data Management Philosophy

**Two tiers of SQL files:**

1. **Bootstrap Data** (`database/data/` — loaded by `./build.sh`):
   - Schema definitions (`00-schema.sql`)
   - Lookup tables (match types, positions, source systems)
   - Manual reference data (seasons, conferences, divisions, admin users)
   - Loaded once during container initialization

2. **League Data** (`database/scripts/leagues/<league>/sql/` — loaded by `make load`):
   - Generated from scraped HTML by parse pipeline
   - Per-league SQL files numbered 100-109
   - Committed to git — SQL files ARE the source of truth
   - Loaded after bootstrap in dependency order (APSL → CSL → CASA)

**SQL File Numbering per League:**
| File | Content |
|------|---------|
| `100-*-orgs.sql` | Organizations |
| `101-*-clubs.sql` | Clubs |
| `102-*-teams.sql` | Teams |
| `103-*-division-teams.sql` | Division-team assignments |
| `104-*-standings.sql` | Standings |
| `105-*-players.sql` | Players (persons + players + team_players) |
| `106-*-matches.sql` | Matches |
| `107-*-rosters.sql` | Match rosters |
| `108-*-event-players.sql` | Event player records |
| `109-*-match-events.sql` | Match events (goals, cards, etc.) |
| `900-*-curation.sql` | Cross-league deduplication (UPDATE statements) |

**Data Restoration:**
- Development: `make rebuild && make load` (fresh DB from git)
- Full re-init: `make rebuild && make init-all` (re-parse from cached HTML)
- Production: `pg_dump` backups for live user data (RSVPs, chat, scores)

### Database Changes
- **Schema Changes**: Update `00-schema.sql`, then `make rebuild` to apply
- **Manual Static Data**: Add/update numbered SQL files in `database/data/` (e.g., `026-club-admins.sql`)
- **Alphabetical Execution**: SQL files load alphabetically during initialization
- **File Numbering**: Use prefixes (a/b/c) when order matters (e.g., `020-persons.sql`, `020a-players.sql`)

## 🔄 Data Scraping Architecture

### Per-League Configuration (`config.json`)
Each league has a `config.json` in `database/scripts/leagues/<league>/` containing all league-specific values:

```json
{
  "leagueName": "APSL",
  "leagueSlug": "usa-apsl",
  "sourceSystemId": 1,
  "fileCode": "00001",
  "leagueDbId": 1,
  "activeSeason": "2025/2026",
  "orgIdBase": 100,
  "clubIdBase": 100,
  "teamIdBase": 100,
  "playerIdBase": 10000,
  "curateAgainst": [],
  "clubFamilies": { "team name": "club-slug", ... }
}
```

**Key fields:**
- `sourceSystemId` / `fileCode` / `leagueDbId`: Database foreign keys
- `orgIdBase` / `clubIdBase` / `teamIdBase` / `playerIdBase`: ID ranges to avoid collisions (APSL=100s, CSL=10000s, CASA=20000s)
- `curateAgainst`: Which upstream leagues to deduplicate against (APSL=none, CSL=APSL, CASA=APSL+CSL)
- `clubFamilies`: Maps team display names to canonical club slugs for cross-league deduplication

**Current leagues:**
| League | Slug | Source System | ID Bases | Curates Against |
|--------|------|---------------|----------|-----------------|
| APSL | usa-apsl | 1 | 100+ | — (baseline) |
| CASA | usa-casa | 2 | 20000+ | APSL, CSL |
| CSL | usa-csl | 3 | 10000+ | APSL |

### Per-League Directory Structure
```
database/scripts/leagues/usa-apsl/
├── config.json          # League configuration (IDs, season, club families)
├── scrape.sh            # Fetch HTML from web → scraped-html/apsl/
├── parse.sh             # generate-sql.js + curate-sql.js (no DB needed)
├── load.sh              # Load sql/ files into database
├── init.sh              # Full pipeline: parse + load + events + export
├── generate-sql.js      # Parse cached HTML → generate sql/ files (100-107)
├── curate-sql.js        # Cross-league dedup → generate 900-curation.sql
└── sql/                 # Generated SQL files (committed to git)
    ├── 100-00001-usa-apsl-orgs.sql
    ├── 101-00001-usa-apsl-clubs.sql
    ├── ...
    └── 900-00001-usa-apsl-curation.sql
```

### Parse Pipeline (offline, no DB needed)
1. **generate-sql.js** reads cached HTML from `database/scraped-html/<league>/`
2. Reads `config.json` for IDs, season, base values
3. Produces SQL files 100-107 in `sql/` directory
4. **curate-sql.js** reads its own + upstream leagues' `sql/` files
5. Matches clubs across leagues using `clubFamilies` mapping
6. Produces `900-*-curation.sql` with UPDATE statements

### Init Pipeline (one-time, needs DB)
The `init.sh` per league runs the full pipeline:
1. **generate-sql.js** — Parse cached HTML → SQL files (100-107)
2. **curate-sql.js** — Cross-league dedup → 900-curation.sql
3. **load.sh** — Load all SQL into database
4. **Event scraper** — Scrape match events from cached HTML into DB (APSL/CSL only)
5. **export-events-sql.js** — Export events from DB → SQL files (108-109)

Events require a live DB because event scrapers parse HTML match pages and write directly to the database, then export to SQL.

### Curation Chain (dependency order)
```
APSL (baseline, no dependencies)
  ↓ APSL sql/ files exist on disk
CSL (curates against APSL)
  ↓ APSL + CSL sql/ files exist on disk
CASA (curates against APSL + CSL)
```
- `make parse` runs all three in this order
- `make load` loads all three in this order
- Cross-league curation reads SQL files on disk, NOT the database

### Scraper Implementations
- `ApslStructureScraper`: APSL league (apslsoccer.com) - ✅ Working
- `CslStructureScraper`: CSL league (cosmosoccerleague.com) - ✅ Working
- `CasaParser`: CASA league (casasoccerleagues.com + Google Sheets) - ✅ Working (no events)
- `GroupMeScraper`: 4 chat implementations (Training, APSL, Boys Club, Old Timers) - ⚠️ Untested
- `VenueScraper`: Google Places API - ⚠️ Untested

### Scraper Base Classes
- **Base Classes**: `Scraper`, `DataFetcher`, `HtmlParser` (in `database/scripts/`)
- **Services**: `IdGenerator`, `SqlGenerator`, `DuplicateDetector`
- **Models**: `League`, `Team`, `Player`, `Match`, `Venue`

## 📅 Season Management

### Manual Season Configuration
Seasons, conferences, and divisions are **manually managed** in bootstrap SQL files:
- `032-seasons.sql` — Season definitions with hardcoded IDs
- `033-conferences.sql` — Conference definitions (vary by league/season)
- `034-divisions.sql` — Division definitions within conferences

**Why manual?** Structure varies significantly by league:
- APSL: Conferences change yearly (Premier/First/Second reorganization)
- CSL: Single "Main" conference, stable structure
- CASA: Summer season, different schedule

### Season Rollover Process
When a new season starts:
1. Add new season row to `032-seasons.sql` (next available ID)
2. Add new conferences to `033-conferences.sql` (if structure changed)
3. Add new divisions to `034-divisions.sql`
4. Update `activeSeason` in each league's `config.json`
5. Run `make rebuild` to apply bootstrap changes
6. Run scrape → `make init-all` to generate new season data

### Adding a New League
1. Create directory: `database/scripts/leagues/<slug>/`
2. Create `config.json` with unique ID ranges (avoid collisions with existing leagues)
3. Add season/conference/division rows to bootstrap SQL (`032-034`)
4. Implement `generate-sql.js`, `curate-sql.js`, `scrape.sh`, `parse.sh`, `load.sh`, `init.sh`
5. Add `curateAgainst` entries in `config.json` for upstream leagues
6. Add Makefile targets: `init-<league>`, `load-<league>`, `parse-<league>`
7. Update `init-all`, `load`, `parse` to include new league in dependency order

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
- **Bootstrap SQL File Organization** (`database/data/`):
  - **Schema** (00): `00-schema.sql` — All table/index/constraint definitions
  - **Lookup Tables** (001-012): Static reference data (match types, admin levels, etc.)
  - **Core Entities** (013-040): Organizations, leagues, seasons, conferences, divisions
  - **Manual Data** (020-030): Developer-created reference data (persons, admins, users)
  - **Application Features** (050-080): Chat, events, stats, etc.
  - **Views & Functions** (090-099): Database views and helper functions
  - Files load alphabetically — use prefixes (a/b/c) when order matters within same number
- **League SQL File Organization** (`database/scripts/leagues/<league>/sql/`):
  - Files numbered 100-109, 900 (see SQL File Numbering table above)
  - Generated by parse pipeline, committed to git
  - Loaded by `make load` in dependency order (APSL → CSL → CASA)

## 🔍 Key Files
- `Makefile`: All build/load/parse/init targets with dependency management.
- `build.sh`: Bootstrap script — destroys containers, rebuilds, loads `database/data/`.
- `frontend/js/app.js`: Frontend bootstrap and screen registration.
- `backend/src/main.cpp`: Backend server setup and route registration.
- `backend/src/core/Router.cpp`: Custom routing logic.
- `database/scripts/leagues/*/config.json`: Per-league configuration (IDs, seasons, club families).
- `database/scripts/leagues/*/init.sh`: Full init pipeline per league.
- `database/scripts/leagues/*/generate-sql.js`: HTML→SQL generator per league.
- `database/scripts/leagues/*/curate-sql.js`: Cross-league deduplication per league.

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
