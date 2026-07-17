# Football Home Copilot Instructions

## ⚠️ CRITICAL RULES (READ FIRST)

### Repo Location
- **Workspace lives at `/srv/footballhome`** (moved from `/home/jbreslin/footballhome`).
- All absolute paths, systemd units, cron jobs, nginx configs, and backup scripts must use `/srv/footballhome`.
- Before assuming a path, `pwd` or check the workspace root.

### Container / DB Access Rules
**Podman runs ROOTFUL on this host.** All container/DB commands require `sudo`:
- ❌ `podman ps` → returns empty (rootless namespace, sees no containers)
- ❌ `make shell-db` → fails ("no such container")
- ❌ `docker …` → docker is not installed; the engine is `podman`
- ✅ `sudo podman ps`
- ✅ `sudo make shell-db`
- ✅ `sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome -c "SELECT …"`
- ✅ `sudo podman logs -f footballhome_backend`

**Before running anything containerized:** `sudo podman ps` to confirm what's up.

**Container names:**
- `footballhome_db` — Postgres (port 5432)
- `footballhome_backend` — C++ HTTP server (port 3001)
- `footballhome_frontend` — nginx (port 3000)
- `footballhome_sim` — sim service
- `footballhome_scraper` — long-lived scraper shell
- `footballhome_leagueapps_sync` — LA sync worker

**Engine:** `podman` (see `ENGINE := $(shell command -v podman ...)` in Makefile).

### Sanity-Check Order Before Acting
Before running commands or making changes, in this order:
1. `pwd` — confirm you're in `/srv/footballhome`.
2. `make help` — list available targets (don't guess).
3. `sudo podman ps` — confirm what containers are running.
4. Read the relevant existing file — do not overwrite unread files.

### Membership Data Flow (STRICT — user directive, non-negotiable)

**LeagueApps is the sole source of truth for who is a member. The database is a CACHE of LA, never the authority. If it disagrees with LA, LA wins.**

**Every endpoint that renders anything derived from LA membership (rosters, member lists, pool, lineups, payments, RSVP eligibility, profile membership badges, everything) MUST do, in this order, on every request:**

1. **LA API** — call `LaProgramSync::run(programId)` for every LA program the response depends on. This is the ONLY way membership state is allowed to enter the response path.
2. **DB update** — `LaProgramSync` upserts persons/aliases/memberships and closes (`ended_at = now()`) any open `person_la_memberships` row whose person LA no longer returns as a member for that program.
3. **DB query** — read the response payload from Postgres (typically `person_la_memberships` joined to `leagueapps_programs`). NEVER shape response cards from the in-memory LA response.
4. **Render**.

**A person is a member of an LA program only when `registrationStatus` is `SPOT_RESERVED`, `SPOT_PENDING`, or `WAITING_LIST`. Anything else (DROPPED, CANCELED, DECLINED, REFUNDED, …) means NOT a member.**

**Two LA sub-programs per category (2026-07-14):**
- `active` variant (e.g. `5039300` Men, `5039250` Women, `5039252` Boys, `5039251` Girls) = full **Members** roster.
- `pickup` variant (e.g. `5070075` Men Pickup, `5064686` Women Pickup, `5064618` Boys Pickup, `5064662` Girls Pickup) = **Pickup Members** roster.
- The two are populated independently on the LA console. A person can be in one, the other, both, or neither. The Members roster == active variant members; the Pickup roster == pickup variant members. **Do not filter one based on the presence of the other.** No "if in pickup, hide from Members" hacks. Ever.

**BANNED patterns (all previously bit us):**
- ❌ Shaping response objects from `LeagueAppsService::fetchProgramRegistrations` return value directly. (Read from DB after `LaProgramSync::run` instead.)
- ❌ Any "if this person is in pickup, exclude them from members" DB filter, or the reverse. LA sub-group membership IS the filter.
- ❌ Any in-memory cached LA snapshot on a controller/model singleton used to skip the LA fetch on subsequent requests. Fetch every request.
- ❌ Client-side-only tab / chip / pill switching that filters an already-fetched payload without re-running the LA sync scoped to that tab.
- ❌ Reading `person_la_memberships` without a preceding `LaProgramSync::run` in the same code path.
- ❌ Trusting `is_pool`, `is_pickup`, `is_member`, or any DB-side boolean as the membership check. The check is always "does an open `person_la_memberships` row exist for `(person_id, la_program_id)` after LA sync?".

**Rule of thumb:** if the code path that produced a response did not call `LaProgramSync::run` for every LA program that feeds it, the code is wrong. No exceptions for rosters, no exceptions for admin screens, no exceptions for "just a badge", no exceptions for "the sync job runs every 5 min anyway".

### Terminal Command Rules
**User must see FULL, UNFILTERED output of every command you run — no exceptions.**

**NEVER use these on ANY command (build, scraper, `podman ps`, `ls`, `psql`, logs, git, etc.):**
- ❌ `| head` / `head -n` — truncates start of output
- ❌ `| tail` / `tail -n` — truncates end of output
- ❌ `| grep` — hides context around matches
- ❌ `| awk` / `| sed` / `| cut` for filtering display — same problem
- ❌ `tail -f` / `less` / `more` / any pager — blocks the terminal
- ❌ `> file.txt` / `&> file.log` — hides output from user
- ❌ `2>/dev/null` — hides errors
- ❌ `--quiet` / `-q` flags that suppress output

**WHY:** User needs to see complete output to diagnose issues. Filtering hides critical errors and forces them to re-run the command themselves.

**Examples:**
- ✅ `sudo podman ps` &nbsp;&nbsp;❌ `sudo podman ps | head -10`
- ✅ `./build.sh` &nbsp;&nbsp;❌ `./build.sh 2>&1 | head -100`
- ✅ `git status` &nbsp;&nbsp;❌ `git status | head -20`
- ✅ `sudo podman logs footballhome_backend` &nbsp;&nbsp;❌ `... | tail -50`
- ✅ `ls database/data/` &nbsp;&nbsp;❌ `ls database/data/ | head`

**If output is genuinely huge and would overwhelm:** tell the user first and ask which slice they want — do NOT silently truncate.

**Legitimate uses of head/tail/grep** (allowed):
- Inside a script the user will run later (not for display).
- Testing whether a pattern exists before acting: `grep -q PATTERN file && do-thing` (no output shown).
- The user explicitly asks you to filter.

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
| **Sync** | `make sync` | Sync all leagues: scrape → parse → UPSERT |
| | `make sync-apsl/csl/casa` | Sync individual league |
| **Containers** | `make build` | Build images + start containers |
| | `make up` / `make down` | Start / stop containers |
| | `make rebuild` | Destroy everything + fresh build (wipes DB) |
| | `make migrate` | Apply pending schema migrations (preserves data) |
| | `make shell-db` | Connect to database shell |
| | `make ps` / `make logs` | Show containers / view logs |
| | `make audit` | Run data quality audit |
| **Pipeline steps** | `make scrape` | Fetch fresh HTML from web (all leagues) |
| | `make scrape-apsl/csl/casa` | Scrape individual league |
| | `make parse` | Regenerate SQL from cached HTML (all leagues, no DB needed) |
| | `make parse-apsl/csl/casa` | Parse individual league |
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

**Fresh database (wipes everything, starts clean):**
```bash
make rebuild      # destroy containers + volumes, fresh build
make sync         # re-sync all leagues from web
```

**Regenerate SQL without touching DB:**
```bash
make parse   # regenerates sql/ files from cached HTML
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
| Bootstrap (schema, lookups) | `database/data/` SQL files | `make rebuild` | Always — from git |
| League data (standings, matches, rosters) | League websites | `make sync-*` (UPSERT) | Always — re-scrape from website |
| User data (RSVPs, practices, attendance) | User input in app | Written by backend to DB | Only from pg_dump backup |

**Two tiers of SQL files:**

1. **Bootstrap Data** (`database/data/` — loaded by `./build.sh`):
   - Schema definitions (`00-schema.sql`)
   - Lookup tables (match types, positions, source systems)
   - Manual reference data (seasons, conferences, divisions, admin users)
   - Loaded once during container initialization
   - These are permanent — needed for every rebuild

2. **League Data** (`database/scripts/leagues/<continent>/<country>/<league>/sql/` — loaded by `make sync-*`):
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
- Development reset: `make rebuild` then `make sync` (fresh DB + re-sync all leagues)
- Live restore: `make restore` (latest pg_dump) or `make restore BACKUP=file.sql`
- Safe rebuild: `make safe-rebuild` then `make sync` (pg_dump before wipe)

**Backup Strategy:**
- `make backup` runs pg_dump → `backups/backup-YYYYMMDD-HHMMSS.sql`
- Captures everything: schema + league data + user data
- `backups/` is gitignored — snapshots are local insurance
- **Always run `make backup` before any destructive operation**
- pg_dump is the source of truth for live databases

### Database Changes
- **Schema Changes (dev, no user data)**: Update `00-schema.sql`, then `make rebuild` + `make sync` to apply
- **Schema Changes (live, preserve data)**: Write a migration in `database/migrations/`, update `00-schema.sql` to match, then `make migrate`
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
5. Run `make rebuild` to apply bootstrap changes
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

#### Route Registration for LA-dependent endpoints

**Any endpoint whose response depends on LeagueApps membership state (rosters, member lists, profile, pool, lineups, payments, RSVP eligibility, badges, everything) MUST be registered through `Controller::laGet`/`laPost`/`laPut`/`laDel`, not the bare `router.get/post/…`.** This is the ONLY way the STRICT membership-data-flow rule (§ Membership Data Flow, above) is enforced at the framework layer — the la* helpers wrap the router call in a lambda that runs `LaProgramSync::run()` for every declared program BEFORE dispatching to the handler.

There are two overloads. Pick based on whether the program list is known at registration time.

**Static program list** (compile-time — the common case for per-tab routes):

```cpp
laGet(router, prefix + "/mens/members", {mensProgramId_},
    [this](const Request& req, const LaSyncMap& sync) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "…");
        return this->handleGetMembers("mens", mensProgramId_, sync);
    });
```

**Dynamic program list** (resolved from the request — profile page, admin filters, cross-category rosters):

```cpp
laGet(router, prefix + "/la/:leagueAppsUserId",
    [](const Request&) { return Controller::allLaProgramIds(); },
    [this](const Request& req, const LaSyncMap& sync) {
        return this->handleGetByLaUserId(req, sync);
    });
```

`Controller::allLaProgramIds()` reads every row from `leagueapps_programs` (active variant first). Use it for endpoints that render membership across every category. For filtered subsets, write an inline resolver that mirrors the handler's own program-enumeration query.

**Handler shape:** always `Response handleName(const Request&, const LaSyncMap&)`. The `LaSyncMap` is `std::unordered_map<int, LaProgramSync::Result>` — one entry per program that was synced. Handlers should read response payloads from Postgres (which the sync just refreshed) and use the map only for optional post-sync inspection (e.g. Payments uses `sync.find(pid)` to check reachability). Adding `(void)sync;` at the top is fine when the handler doesn't need the map.

**Enforcement:** `make check-la-sync` (auto-run by `make deploy`) runs `scripts/enforce-la-sync.sh`, which greps for any file under `backend/src/controllers/` or `backend/src/models/` that reads `person_la_memberships` without a matching `laGet(`/`laPost(`/`laPut(`/`laDel(`/`LaProgramSync::run(`/`Controller::syncPrograms(`/`Controller::allLaProgramIds(` token in the same translation unit. Allowlist for downstream models (`Team`, `PersonPayments`, `MensRoster`, `BoysRoster`, `YouthRoster`) lives at the top of the lint script — extend it only when adding a new model whose readers are ALL called from already-synced controller paths.

Read the la* implementation in [backend/src/core/Controller.h](backend/src/core/Controller.h) and [backend/src/core/Controller.cpp](backend/src/core/Controller.cpp) before adding new routes.

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
