# Football Home ⚽

A comprehensive team management system for football/soccer leagues, built with C++, Vanilla JavaScript, and PostgreSQL.

## 🚀 Quick Start

### Prerequisites

- Podman (Docker alternative, no rate limits)
- Node.js (for data scraping)
- Git

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome

# 2. Run first-time setup (installs Podman, Node, etc.)
./setup.sh

# 3. Copy env template and fill in credentials
cp .env.example env
# Edit env with your Twilio / Google OAuth / Docker Hub credentials (optional)

# 4. Build and start (fresh DB from committed SQL)
make rebuild && make load

# Access at http://localhost:3000
```

**Note**: The `env` file (gitignored) holds optional credentials (Twilio, Google OAuth, Docker Hub). Copy `.env.example` to `env` and fill in values as needed.

**Podman/Docker**: This project defaults to Podman but supports Docker as a fallback.

## 🔧 Development Workflows

```bash
# Fresh DB from committed SQL (most common)
make rebuild && make load

# Full init from cached HTML (one-time or re-scrape)
make rebuild && make init

# Regenerate SQL from cached HTML (no DB needed)
make parse

# Fetch fresh HTML from web, then rebuild
make scrape && make rebuild && make init

# Quick refresh (parse + rebuild + load)
make refresh

# Safe rebuild with backup first
make safe-rebuild && make load

# Start/stop without rebuilding
make up          # Start containers
make down        # Stop containers
```

See `make help` for all available targets.

## 🏗️ Architecture

```
Internet → nginx → Frontend (Vanilla JS) → C++ Backend → PostgreSQL
```

**Stack:**
- **Frontend**: Vanilla JavaScript FSM-based UI (port 3000)
- **Backend**: Custom C++ HTTP server (port 3001)
- **Database**: PostgreSQL with league data (port 5432)

## 🔐 Demo Login

- **Email**: `soccer@lighthouse1893.org`
- **Password**: `1893Soccer!`

## 📁 Project Structure

```
├── frontend/                  # Vanilla JS frontend with FSM
│   ├── js/
│   │   ├── screens/          # Screen state machines
│   │   ├── screen-manager.js # FSM controller
│   │   └── app.js            # Application entry
│   └── css/
├── backend/                   # C++ HTTP server
│   ├── src/
│   │   ├── core/             # HTTP framework
│   │   ├── controllers/      # Route handlers
│   │   ├── services/         # Business logic
│   │   ├── models/           # Database models
│   │   └── database/         # PostgreSQL client
│   └── CMakeLists.txt
├── database/
│   ├── data/                 # Bootstrap SQL (schema + lookups)
│   ├── scraped-html/         # Cached HTML from league websites
│   └── scripts/
│       ├── leagues/          # Per-league pipeline (generate-sql, curate-sql, etc.)
│       │   └── north-america/usa/{apsl,csl,casa}/
│       ├── scrapers/         # Web scrapers (structure + event scrapers)
│       ├── domain/           # Domain models + repositories
│       └── infrastructure/   # Parsers + fetchers
├── backups/                  # pg_dump snapshots (gitignored)
├── Makefile                  # All build/load/parse/init targets
└── docker-compose.yml        # Container orchestration
```

## ⚽ Features

### League Management
- **Multi-League Support**: APSL, CSL, CASA with automated scraping and SQL generation
- **Division Tracking**: Conferences, divisions, standings per league
- **Cross-League Curation**: Automatic deduplication of shared clubs across leagues

### Team Management
- **Roster Management**: Track players, jersey numbers, positions
- **Multiple Teams**: Users can manage multiple teams across leagues
- **Role-Based Access**: Admin, Coach, Player roles with appropriate permissions

### Event Management
- **Practice Scheduling**: Create and manage team practices
- **Match Tracking**: View upcoming and past matches from league schedule
- **RSVP System**: Players can respond to events

## 🗄️ Data Pipeline

### Two Tiers of SQL

1. **Bootstrap Data** (`database/data/`) — Schema, lookups, manual reference data
2. **League Data** (`database/scripts/leagues/*/sql/`) — Generated from scraped HTML, committed to git

### Data Flow
```
Web → make scrape → cached HTML → make parse → SQL files → make load → DB
                                                    ↑
                                              committed to git
```

### Backup Strategy
```bash
make backup         # pg_dump → backups/backup-YYYYMMDD-HHMMSS.sql
make restore        # Restore latest (or BACKUP=file.sql)
make safe-rebuild   # Backup + rebuild (safety net)
```

## 🐳 Container Services

```bash
make ps             # Show running containers
make logs           # View logs
make shell-db       # Connect to database shell

# Access database directly
podman exec -it footballhome_db psql -U footballhome footballhome
```

##  Troubleshooting

```bash
# Check database logs
make logs

# Force full rebuild
make rebuild && make load

# Run data audit
make audit
```

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
