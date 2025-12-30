# Football Home Database

## Overview
PostgreSQL database with fully normalized schema supporting APSL and CASA league data, user management, and chat-based event coordination.

## Architecture

### Schema Design
- **Fully normalized** (3NF minimum) - no data duplication
- **Lookup tables** replace all text enums (match types, statuses, roles, etc.)
- **Source tracking** - every record tracks origin via `source_system_id` + `external_id`
- **Unified structure** - no `apsl_*` vs `casa_*` table duplication, differentiated by foreign keys

### Directory Structure

```
database/
├── data/               # SQL initialization files (loaded alphabetically)
│   ├── 00-schema.sql              # Core schema with lookup tables
│   ├── 01-*.sql                   # Foundational data (governing bodies, orgs)
│   ├── 10-leagues-apsl.sql        # APSL leagues
│   ├── 10-leagues-casa.sql        # CASA leagues
│   ├── 20-teams-apsl.sql          # APSL teams
│   ├── 20-teams-casa.sql          # CASA teams
│   ├── 30-players-apsl.sql        # APSL players
│   ├── 30-players-casa.sql        # CASA players
│   ├── 40-matches-apsl.sql        # APSL matches
│   ├── 40-matches-casa.sql        # CASA matches
│   ├── 60m-users.sql              # Manual user data
│   └── ZZ-pg-cron-setup.sh        # Scheduled job configuration
└── scripts/           # Node.js scrapers (OOP architecture)
    ├── ApslScraper.js             # APSL league scraper (working)
    ├── CasaScraper.js             # CASA league scraper (in progress)
    ├── GroupMeScraper.js          # GroupMe chat scraper (4 implementations)
    └── VenueScraper.js            # Google Places venue scraper
```

## SQL File Naming Convention

Files in `data/` use a structured naming pattern: `{number}-{table}-{source}.sql`

### Numbers (Load Order by Table)
Files are grouped by table, not by scraper:
- `00-*` - Schema and core infrastructure
- `01-02` - Foundational data (governing bodies, organizations, venues)
- `10-12` - League hierarchy (leagues, conferences, divisions)
- `20-21` - Teams (teams, team_divisions)
- `30-31` - Players (players, team_players)
- `40-42` - Matches (matches, match_events, match_lineups)
- `50-51` - Stats (player_stats, team_stats)
- `60-69` - Users/Identity (users, admins)
- `80-89` - Linking tables (external_identities)
- `90-99` - Views, functions, utilities
- `ZZ-*` - Post-initialization scripts

### Source Identifiers
**Scraped data** (no letter prefix):
- `-apsl` - Data from apslsoccer.com
- `-casa` - Data from casasoccerleagues.com + Google Sheets

**Other sources** (letter prefix):
- `m` - **Manual data** created by developers (not scraped, not app-generated)
- `u` - **UI dev data** created by users via web app (development environment)
- `p` - **UI prod data** created by users via web app (production environment)

### Examples
- `10-leagues-apsl.sql` - APSL leagues from web scraping
- `10-leagues-casa.sql` - CASA leagues from web scraping
- `20-teams-apsl.sql` - APSL teams from web scraping
- `20-teams-casa.sql` - CASA teams from web scraping
- `60m-users.sql` - Manually created user accounts
- `20u-teams.sql` - Teams created in dev environment UI
- `20p-teams.sql` - Teams created in production environment UI

### Load Order Logic
Alphabetical sorting ensures proper sequence:
1. `20-teams-apsl.sql` (scraped foundation)
2. `20-teams-casa.sql` (scraped foundation)
3. `20m-teams.sql` (manual additions)
4. `20p-teams.sql` or `20u-teams.sql` (UI changes, environment-specific)

## Data Sources

### 1. APSL (American Premier Soccer League)
- **Source**: apslsoccer.com web scraping
- **Scraper**: `scripts/ApslScraper.js` (working)
- **Coverage**: Leagues, conferences, divisions, teams, players, matches, stats
- **Files**: `10-leagues-apsl.sql`, `20-teams-apsl.sql`, `30-players-apsl.sql`, etc.

### 2. CASA (Connecticut Adult Soccer Association)
- **Source**: casasoccerleagues.com + Google Sheets
- **Scraper**: `scripts/CasaScraper.js` (in progress - needs parser implementation)
- **Coverage**: Teams, players, schedules
- **Files**: `10-leagues-casa.sql`, `20-teams-casa.sql`, `30-players-casa.sql`, etc.

### 3. Manual Data
- **Source**: Developer-created SQL files
- **Examples**: Admin users, club associations, test data
- **Files**: `*m-*.sql` (e.g., `60m-users.sql`, `61m-admins.sql`)

### 4. App-Generated Data
- **Source**: User actions via web UI
- **Backend**: C++ server appends to `-u` (dev) or `-p` (prod) SQL files
- **Purpose**: Data persistence across full rebuilds
- **Files**: `*u-*.sql` (dev), `*p-*.sql` (prod)

## Database Initialization

1. **Docker Compose** maps `database/data/` to `/docker-entrypoint-initdb.d/`
2. **PostgreSQL** executes files alphabetically on first container start
3. **`01-load-data.sh`** orchestrates SQL file loading in correct order
4. **pg_cron** scheduled jobs configured by `ZZ-pg-cron-setup.sh`

## Core Tables

### Hierarchy
```
governing_bodies → organizations → leagues → conferences → divisions → teams → players
```

### Key Tables
- **users** - Football Home member accounts (email/password)
- **teams** - League teams (APSL/CASA/custom)
- **players** - Player entities (scraped data + manually created)
- **matches** - Games/practices/events
- **team_players** - Roster memberships (junction table)
- **chats** - Platform-agnostic messaging groups
- **chat_members** - Chat participation (junction table)
- **external_identities** - GroupMe/Discord account linking

## Development Workflow

### Data Refresh
```bash
# Full rebuild (destroys all containers/volumes, reloads all SQL)
./dev.sh

# Refresh all scraped data (re-scrapes APSL/CASA/GroupMe, updates SQL files)
./dev.sh --refresh

# Selective scraping
./dev.sh --apsl              # APSL only
./dev.sh --casa              # CASA only
./dev.sh --groupme           # GroupMe only
./dev.sh --team "Lighthouse" # Single team filter
```

### Schema Changes
1. Edit `00-schema.sql`
2. Run `./dev.sh` (full rebuild)
3. No migrations needed - always full rebuild

### Adding Manual Data
1. Create/edit numbered SQL file (e.g., `75-club-admins.sql`)
2. Data persists across rebuilds (loaded alphabetically)

### App Data Persistence
- Backend must append INSERT/UPDATE statements to `-u` or `-p` files after DB operations
- Ensures user-created data survives full rebuilds
- See `backend/docs/SQLFileWriter.md` for implementation

## Scraper Architecture (OOP)

All scrapers use object-oriented design with:
- **Base Classes**: `Scraper`, `DataFetcher`, `HtmlParser`
- **Services**: `IdGenerator`, `SqlGenerator`, `DuplicateDetector`
- **Models**: `League`, `Team`, `Player`, `Match`, `Venue`

Output: SQL files in `database/data/` (committed to git)

## Notes
- All historical data preserved in git - no need for backup folders
- Always use full rebuilds via `./dev.sh` (no quick restart available)
- SQL files are the source of truth (version controlled)
- Database state is ephemeral (recreated on each build)
