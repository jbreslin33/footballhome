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
- ✅ Documentation: `README.md`, `*.md` design docs

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
  - **Schema Management**: SQL scripts in `database/data/` executed alphabetically (e.g., `00-schema.sql`, `014-continents.sql`).

## 🔧 Development Workflow

### Makefile Targets (run `make help` for full list)
| Category | Command | Description |
|----------|---------|-------------|
| **Sync** | `make sync` | Sync all leagues: scrape → parse → UPSERT (idempotent) |
| | `make sync-apsl/csl/casa` | Sync individual league |
| **Dev** | `make dev-reset` | Fresh DB from scratch: rebuild + load all |
| | `make up` / `make build` | Start / build+start containers |
| | `make down` / `make clean` | Stop / destroy containers |
| | `make shell-db` | Connect to database shell |
| | `make ps` / `make logs` | Show containers / view logs |
| | `make audit` | Run data quality audit |
| **Pipeline steps** | `make scrape` | Fetch fresh HTML from web (all leagues) |
| | `make scrape-apsl/csl/casa` | Scrape individual league |
| | `make parse` | Regenerate SQL from cached HTML (all leagues, no DB needed) |
| | `make parse-apsl/csl/casa` | Parse individual league |
| | `make load` | Load/UPSERT all league SQL into database |
| | `make load-apsl/csl/casa` | Load individual league |
| | `make events` | Scrape match events for APSL + CSL |
| | `make events-apsl/csl` | Scrape events for individual league |
| **Backup** | `make backup` | pg_dump → backups/backup-YYYYMMDD-HHMMSS.sql |
| | `make restore` | Restore latest backup (or `BACKUP=file.sql`) |
| | `make safe-rebuild` | Backup + rebuild (safety net for live data) |

### Common Workflows

**Sync a league (primary workflow — idempotent, safe to run anytime):**
```bash
make sync-apsl    # scrape → parse → UPSERT for APSL
make sync         # all leagues in dependency order
```

**Fresh development database (wipes everything, starts clean):**
```bash
make dev-reset    # clean + build + load all leagues
```

**Regenerate SQL without touching DB:**
```bash
make parse   # regenerates sql/ files from cached HTML
```

**Fetch fresh HTML from web, then load into existing DB:**
```bash
make sync-apsl   # scrape + parse + UPSERT (idempotent)
```

### Data Management Philosophy

**Single idempotent pipeline per league:**

All SQL uses `ON CONFLICT ... DO UPDATE` (UPSERT), so the same command works for both initial load and updates. There is no separate "onboarding" vs "update" path.

```bash
make sync-apsl    # scrape → parse → UPSERT (works on empty or populated DB)
```

- SQL files are committed to git — you can review diffs between scrapes
- Curation rules (`clubFamilies` in config.json) are the living asset that grows over time
- League websites are always available to re-scrape — errors are recoverable

**Three categories of data:**

| Category | Source | Update Method | Recoverable? |
|----------|--------|---------------|-------------|
| Bootstrap (schema, lookups) | `database/data/` SQL files | `make dev-reset` | Always — from git |
| League data (standings, matches, rosters) | League websites | `make sync-*` (UPSERT) | Always — re-scrape from website |
| User data (RSVPs, practices, attendance) | User input in app | Written by backend to DB | Only from pg_dump backup |

**Two tiers of SQL files:**

1. **Bootstrap Data** (`database/data/` — loaded by `./build.sh`):
   - Schema definitions (`00-schema.sql`)
   - Lookup tables (match types, positions, source systems)
   - Manual reference data (seasons, conferences, divisions, admin users)
   - Loaded once during container initialization
   - These are permanent — needed for every rebuild

2. **League Data** (`database/scripts/leagues/<continent>/<country>/<league>/sql/` — loaded by `make load`):
   - Generated from scraped HTML by `make parse`
   - Per-league SQL files numbered 100-109
   - All use `ON CONFLICT ... DO UPDATE` (UPSERT) — safe to re-run anytime
   - Committed to git so you can review diffs between scrapes

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
- Development reset: `make dev-reset` (fresh DB from git + all league SQL)
- Live restore: `make restore` (latest pg_dump) or `make restore BACKUP=file.sql`
- Safe rebuild: `make safe-rebuild && make load` (pg_dump before wipe)

**Backup Strategy:**
- `make backup` runs pg_dump → `backups/backup-YYYYMMDD-HHMMSS.sql`
- Captures everything: schema + league data + user data
- `backups/` is gitignored — snapshots are local insurance
- **Always run `make backup` before any destructive operation**
- pg_dump is the source of truth for live databases
- `make dev-reset` is for dev resets only (destroys user data)

### Database Changes
- **Schema Changes**: Update `00-schema.sql`, then `make dev-reset` to apply
- **Manual Static Data**: Add/update numbered SQL files in `database/data/` (e.g., `024-admins.sql`)
- **Alphabetical Execution**: SQL files load alphabetically during initialization
- **File Numbering**: Use prefixes (a/b/c) when order matters (e.g., `020-persons.sql`, `020a-players.sql`)

## 🔄 Data Scraping Architecture

### Per-League Configuration (`config.json`)
Each league has a `config.json` in `database/scripts/leagues/<continent>/<country>/<league>/` containing all league-specific values:

```json
{
  "leagueName": "APSL",
  "leagueSlug": "apsl",
  "leaguePath": "north-america/usa/apsl",
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
- `leagueSlug`: Short identifier for filenames (e.g., `apsl`). Folder hierarchy provides geographic context.
- `leaguePath`: Relative path from `leagues/` directory (e.g., `north-america/usa/apsl`). Used for directory operations.
- `sourceSystemId` / `fileCode` / `leagueDbId`: Database foreign keys
- `orgIdBase` / `clubIdBase` / `teamIdBase` / `playerIdBase`: ID ranges to avoid collisions (APSL=100s, CSL=10000s, CASA=20000s)
- `curateAgainst`: Which upstream league slugs to deduplicate against (APSL=none, CSL=APSL, CASA=APSL+CSL)
- `clubFamilies`: Maps team display names to canonical club slugs for cross-league deduplication

**Current leagues:**
| League | Slug | Path | Source System | ID Bases | Curates Against |
|--------|------|------|---------------|----------|-----------------|
| APSL | apsl | north-america/usa/apsl | 1 | 100+ | — (baseline) |
| CASA | casa | north-america/usa/casa | 2 | 20000+ | APSL, CSL |
| CSL | csl | north-america/usa/csl | 3 | 10000+ | APSL |

### League Directory Hierarchy
Leagues are organized by continent → country → league:
```
database/scripts/leagues/
└── north-america/
    └── usa/
        ├── apsl/
        ├── casa/
        └── csl/
```

### Per-League Directory Structure
```
database/scripts/leagues/north-america/usa/apsl/
├── config.json          # League configuration (IDs, season, club families)
├── scrape.sh            # Fetch HTML from web → scraped-html/apsl/
├── parse.sh             # generate-sql.js + curate-sql.js (no DB needed)
├── load.sh              # Load sql/ files into database
├── init.sh              # Full pipeline: parse + load + events + export
├── generate-sql.js      # Parse cached HTML → generate sql/ files (100-107)
├── curate-sql.js        # Cross-league dedup → generate 900-curation.sql
└── sql/                 # Generated SQL files (committed to git)
    ├── 100.00001-organizations-apsl.sql
    ├── 101.00001-clubs-apsl.sql
    ├── ...
    └── 900.00001-curation-apsl.sql
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

### Active Scrapers
- `ApslStructureScraper`: Fetches APSL HTML (apslsoccer.com) — used by `make scrape-apsl`
- `CslStructureScraper`: Fetches CSL HTML (cosmosoccerleague.com) — used by `make scrape-csl`
- `CasaStructureScraper`: Fetches CASA HTML (casasoccerleagues.com) — used by `make scrape-casa`
- `ApslMatchEventScraper`: Scrapes match events into DB — used by `make events-apsl`
- `CslMatchEventScraper`: Scrapes match events into DB — used by `make events-csl`

### Supporting Infrastructure
- **Parsers**: `ApslMatchParser`, `CslMatchParser`, `ApslMatchEventParser`, `CslMatchEventParser`, `ApslStandingsParser`, `CslStandingsParser` (in `infrastructure/parsers/`)
- **Fetchers**: `HtmlFetcher` (in `infrastructure/fetchers/`)
- **Repositories**: Match, MatchEvent, Organization, League, Season, Conference, Division, Club, etc. (in `domain/repositories/`)
- **Models**: Organization, Club, League, Season, Conference, Division, ScrapedTeam (in `domain/models/`)
- **Base Classes**: `BaseGenerator`, `BaseSqlCurator` (in `database/scripts/leagues/`)

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
5. Run `make dev-reset` to apply bootstrap changes
6. Run `make sync` to scrape + parse + load new season data

### Adding a New League
1. Create directory: `database/scripts/leagues/<continent>/<country>/<league>/`
2. Create `config.json` with unique ID ranges, `leagueSlug`, and `leaguePath` (avoid collisions with existing leagues)
3. Add season/conference/division rows to bootstrap SQL (`032-034`)
4. Implement `generate-sql.js`, `curate-sql.js`, `scrape.sh`, `parse.sh`, `load.sh`, `init.sh`
5. Add `curateAgainst` entries in `config.json` for upstream league slugs
6. Add Makefile targets: `sync-<league>`, `load-<league>`, `parse-<league>`, `scrape-<league>`
7. Update `sync`, `load`, `parse`, `scrape` to include new league in dependency order

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
- **League SQL File Organization** (`database/scripts/leagues/<continent>/<country>/<league>/sql/`):
  - Files numbered 100-109, 900 (see SQL File Numbering table above)
  - Generated by parse pipeline, committed to git
  - Loaded by `make load` in dependency order (APSL → CSL → CASA)

## 🔍 Key Files
- `Makefile`: All build/load/parse/init targets with dependency management.
- `build.sh`: Bootstrap script — destroys containers, rebuilds, loads `database/data/`.
- `frontend/js/app.js`: Frontend bootstrap and screen registration.
- `backend/src/main.cpp`: Backend server setup and route registration.
- `backend/src/core/Router.cpp`: Custom routing logic.
- `database/scripts/leagues/<continent>/<country>/<league>/config.json`: Per-league configuration (IDs, seasons, club families).
- `database/scripts/leagues/<continent>/<country>/<league>/init.sh`: Full init pipeline per league.
- `database/scripts/leagues/<continent>/<country>/<league>/generate-sql.js`: HTML→SQL generator per league.
- `database/scripts/leagues/<continent>/<country>/<league>/curate-sql.js`: Cross-league deduplication per league.

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
- Persons added via `020-persons.sql`
- Users added via `021-users.sql`
- User emails via `022-user-emails.sql`
- Admin role assignment via `024-admins.sql`
- All persist across full rebuilds via SQL init scripts
