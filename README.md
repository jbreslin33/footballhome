# Football Home ⚽

A comprehensive team management system for football/soccer leagues, built with C++, Vanilla JavaScript, and PostgreSQL.

## 🚀 Quick Start (New Machine)

### Prerequisites

- macOS or Linux
- Git

### First-Time Setup (4 steps, then syncs forever)

```bash
# Step 1: Clone
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome

# Step 2: Credentials
cp .env.example env
# Edit env with your Twilio / Google OAuth / Docker Hub credentials (optional)

# Step 3: Install system dependencies (Podman, Node.js, npm packages)
./setup.sh

# Step 4: Build images + start containers (DB auto-loads schema + bootstrap data)
make build
```

You now have a running system at **http://localhost:3000** with an empty database (schema + lookup tables only).

```bash
# From here on, it's just syncs (run these now AND every week):
make sync-apsl
make sync-csl
make sync-casa
```

**What each step does:**

| Step | Command | What it does | Run again? |
|------|---------|-------------|------------|
| 1 | `git clone` | Gets the code | Never |
| 2 | `cp .env.example env` | Creates credentials file | Never |
| 3 | `./setup.sh` | Installs Podman, Node.js, npm packages, vis-network | Never (unless new machine) |
| 4 | `make build` | Builds Docker images, starts containers, DB loads schema | Only if images change |
| 5+ | `make sync-*` | Scrape → parse → curate → UPSERT league data | Weekly (or whenever you want fresh data) |

## 🔄 Ongoing Workflow

### Weekly League Update (non-destructive, idempotent)

```bash
make backup              # safety net (pg_dump → backups/)
make sync-apsl           # scrape → parse → curate → UPSERT
make sync-csl            # scrape → parse → curate → UPSERT
make sync-casa           # scrape → parse → curate → UPSERT
```

Each `sync` command is **fully isolated** to one league. Running it on an empty DB does a full load. Running it on a live DB updates changed data. User-generated data (RSVPs, tactical boards, practices) is never touched.

### Fix a Curation Issue

```bash
# Edit the league's config.json to add a clubFamilies entry
# e.g., "falco fc": "falcons" in csl/config.json

make parse-csl           # re-generate SQL with new curation rule
make sync-csl            # UPSERT corrected data (or just: make sync-csl does both)
```

### Debugging Sub-Steps

```bash
make scrape-apsl         # fetch HTML only (no parse or load)
make parse-apsl          # regenerate SQL from cached HTML only
make audit               # run data quality checks
make shell-db            # connect to database shell
```

### Backup & Restore

```bash
make backup              # pg_dump → backups/backup-YYYYMMDD-HHMMSS.sql
make restore             # restore latest (or BACKUP=file.sql)
```

### Dev Reset (destructive — wipes ALL data)

```bash
make dev-reset           # nuclear: destroys DB volume, rebuilds from scratch
make sync-apsl           # re-sync leagues
make sync-csl
make sync-casa
```

⚠️ This destroys all user-generated data. Use `make backup` first if needed.

## 🏗️ Architecture

```
Internet → nginx → Frontend (Vanilla JS) → C++ Backend → PostgreSQL
```

**Stack:**
- **Frontend**: Vanilla JavaScript FSM-based SPA (port 3000)
- **Backend**: Custom C++ HTTP server (port 3001)
- **Database**: PostgreSQL 15 with pg_cron (port 5432)

### Design Principles

1. **Leagues are isolated** — each league has its own sync command, its own SQL files, its own scraper. Syncing one league never touches another.
2. **Everything is idempotent** — `make sync-*` uses UPSERT (`ON CONFLICT DO UPDATE`). Run it once or a hundred times, same result.
3. **Curation rules are the real asset** — scrapers and parsers are plumbing. The `clubFamilies` mappings in each league's `config.json` are what make cross-league deduplication work correctly. These grow over time as new edge cases are found.
4. **User data is sacred** — league syncs never delete user-generated data (RSVPs, practices, tactical boards, chat).

## 🔐 Demo Login

- **Email**: `soccer@lighthouse1893.org`
- **Password**: `1893Soccer!`

## 📁 Project Structure

```
├── frontend/                  # Vanilla JS frontend with FSM
│   ├── js/
│   │   ├── screens/          # Screen components (extend Screen base class)
│   │   ├── screen-manager.js # FSM controller
│   │   └── app.js            # Application entry
│   └── css/
├── backend/                   # C++ HTTP server
│   ├── src/
│   │   ├── core/             # HTTP framework (Router, Request, Response)
│   │   ├── controllers/      # Route handlers
│   │   ├── services/         # Business logic
│   │   ├── models/           # Database models
│   │   └── database/         # PostgreSQL client
│   └── CMakeLists.txt
├── database/
│   ├── data/                 # Bootstrap SQL (schema + lookups + seasons + admin users)
│   ├── scraped-html/         # Cached HTML from league websites
│   └── scripts/
│       ├── leagues/          # Per-league pipelines
│       │   └── north-america/usa/
│       │       ├── apsl/     # config.json, scrape.sh, parse.sh, generate-sql.js, curate-sql.js, load.sh, sql/
│       │       ├── csl/
│       │       └── casa/
│       ├── scrapers/         # Match event scrapers
│       ├── domain/           # Domain models + repositories
│       └── infrastructure/   # Parsers + fetchers
├── backups/                  # pg_dump snapshots (gitignored)
├── Makefile                  # All targets (make help for full list)
└── docker-compose.yml        # Container orchestration
```

## ⚽ Features

### League Management
- **Multi-League Support**: APSL, CSL, CASA with automated scraping and SQL generation
- **Division Tracking**: Conferences, divisions, standings per league
- **Cross-League Curation**: Automatic deduplication of shared clubs via `clubFamilies` rules

### Team Management
- **Roster Management**: Track players, jersey numbers, positions
- **Multiple Teams**: Users can manage multiple teams across leagues
- **Role-Based Access**: Admin, Coach, Player roles with appropriate permissions

### Event Management
- **Practice Scheduling**: Create and manage team practices
- **Match Tracking**: View upcoming and past matches from league schedule
- **RSVP System**: Players can respond to events (SMS + in-app)

## 🗄️ Data Pipeline

### How Sync Works

Every league follows the same pipeline:

```
Website → Scrape HTML → Parse → Generate SQL → Curate (cross-league dedup) → UPSERT into DB
```

This is triggered by a single command per league: `make sync-apsl`

### Three Categories of Data

| Category | Source | Sync method | Recoverable? |
|----------|--------|-------------|-------------|
| Bootstrap (schema, lookups, seasons) | `database/data/*.sql` | Auto-loaded on first DB start | Always — from git |
| League data (teams, matches, standings, rosters) | League websites | `make sync-*` (scrape → UPSERT) | Always — re-scrape from website |
| User data (RSVPs, practices, tactical boards) | User input in app | Written by backend to DB | Only from `make backup` |

### Curation Rules (the real asset)

Each league's `config.json` contains `clubFamilies` — explicit mappings that tell the system which team names across leagues are the same club:

```json
{
  "clubFamilies": {
    "lighthouse boys club": "lighthouse-1893-sc",
    "lighthouse old timers club": "lighthouse-1893-sc",
    "falco fc": "falcons"
  }
}
```

The curation chain runs in dependency order:
- **APSL** — baseline (no dedup needed)
- **CSL** — curates against APSL clubs
- **CASA** — curates against APSL + CSL clubs

When you find a duplicate or mismatch, add a `clubFamilies` entry and re-sync. The rule is permanent — it fixes that edge case forever.

### External Source Systems

| Source | What it provides | Sync command |
|--------|-----------------|--------------|
| APSL website | clubs, teams, matches, standings, rosters | `make sync-apsl` |
| CSL website | clubs, teams, matches, standings, rosters | `make sync-csl` |
| CASA website | clubs, teams, matches, standings, rosters | `make sync-casa` |
| GroupMe API | group members, calendar events, RSVPs | `node scripts/import-all-groupme-users.js` |

All sources follow the same pattern: fetch → parse → curate → UPSERT.

## 🐳 Container Services

```bash
make ps             # Show running containers
make logs           # View all logs
make logs-db        # View database logs
make logs-backend   # View backend logs
make shell-db       # Connect to database shell
make up             # Start containers (no rebuild)
make down           # Stop containers
```

## 🔧 Troubleshooting

```bash
# Check what's running
make ps

# View logs for errors
make logs-backend

# Run data quality audit
make audit

# Check for duplicate clubs
make shell-db
# Then: SELECT name, count(*) FROM clubs GROUP BY name HAVING count(*) > 1;

# If a sync broke something
make restore        # roll back to last backup
```

## 📋 Make Targets Reference

Run `make help` for the full list. Key targets:

| Target | Description |
|--------|-------------|
| `make sync-apsl` | Full sync: scrape → parse → curate → UPSERT |
| `make sync-csl` | Full sync for CSL |
| `make sync-casa` | Full sync for CASA |
| `make build` | Build images + start containers |
| `make up` / `make down` | Start / stop containers |
| `make backup` / `make restore` | pg_dump snapshot / restore |
| `make scrape-apsl` | Fetch HTML only |
| `make parse-apsl` | Regenerate SQL from cached HTML only |
| `make shell-db` | Database shell |
| `make audit` | Data quality checks |
| `make dev-reset` | Nuclear: destroy + rebuild (wipes all data) |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👤 Author

**James Breslin**
- GitHub: [@jbreslin33](https://github.com/jbreslin33)
- Email: jbreslin@footballhome.org

---

Built with ❤️ for football/soccer team management
