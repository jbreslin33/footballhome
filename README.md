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

# 3. Unlock encrypted credentials (ask team for the key file)
git-crypt unlock /path/to/footballhome.key

# 4. Full setup (scrape data + build + start)
./dev.sh

# Access at http://localhost:3000
```

**Note**: The `.env` file with Twilio credentials is encrypted. New team members need the git-crypt key to unlock it.

**Podman/Docker**: This project defaults to Podman but supports Docker as a fallback. The `dev.sh` script automatically detects `podman-compose` or `docker-compose`.

## 🔧 Development Workflows

```bash
# Full rebuild with fresh APSL data (5-15 min)
./dev.sh

# Quick restart after code changes (keeps database)
./dev.sh --quick

# Just update APSL league data
./dev.sh --scrape-only

# Rebuild without scraping (after git pull)
./dev.sh --no-scrape

# Show all options
./dev.sh --help
```

### dev.sh: verbose diagnostics

The `dev.sh` script now includes additional diagnostic flags to help find build and database initialization bottlenecks:

- `--verbose` : Enable shell tracing, collect slow SQL statements, and show per-service build timings.
- `--summary-only` : Run builds and start services but skip live log-followers and DB sampling. Useful when you only want a compact summary.
- `--persist-slow-sql` and `--slow-sql-out=<PATH>` : Save the collected slow-SQL log to a path for later analysis.
- `--persist-db-sample` and `--db-sample-out=<PATH>` : Save the DB resource sampler log (docker stats) to a path.
- `--alert-pattern=<REGEX>` : Customize the realtime alert regex used to highlight warnings/errors in logs.

Examples:

```bash
# Verbose run with persisted logs
./dev.sh --verbose --persist-slow-sql --slow-sql-out=/tmp/slow_sql.tsv --persist-db-sample --db-sample-out=/tmp/db_stats.log

# Quick restart with summary-only output
./dev.sh --quick --summary-only

# Customize alert pattern to include 'duration' lines
./dev.sh --verbose --alert-pattern='error|duration|deadlock'
```

## 🏗️ Architecture

```
Internet → nginx → Frontend (Vanilla JS) → C++ Backend → PostgreSQL
```

**Stack:**
- **Frontend**: Vanilla JavaScript FSM-based UI (port 3000)
- **Backend**: Custom C++ HTTP server (port 3001)
- **Database**: PostgreSQL with APSL league data (port 5432)
- **Admin**: pgAdmin interface (port 5050)

## 🔐 Demo Login

- **Email**: `jbreslin@footballhome.org`
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
│   │   ├── models/           # Database models
│   │   └── database/         # PostgreSQL client
│   └── CMakeLists.txt
├── database/                  # PostgreSQL setup
│   ├── data/                 # SQL data files
│   │   ├── *.sql            # INSERT format
│   │   └── *.copy.sql       # COPY format (100x faster)
│   └── scripts/
│       └── apsl-scraper/    # APSL league data scraper
├── docker/                   # Docker configuration
│   └── postgres/
│       └── init-with-progress.sh
├── docker-compose.yml        # Container orchestration
└── dev.sh                    # Unified development script
```

## 🏈 Features

### League Management
- **APSL Integration**: Automatically scrapes teams, players, rosters, matches from American Premier Soccer League
- **Multiple Leagues**: Support for APSL, CASA, TCWL with division tracking
- **Bulk Data Loading**: PostgreSQL COPY format for 100x faster database initialization

### Team Management
- **Roster Management**: Track players, jersey numbers, positions
- **Multiple Teams**: Users can manage multiple teams across leagues
- **Role-Based Access**: Admin, Coach, Player roles with appropriate permissions

### Event Management
- **Practice Scheduling**: Create and manage team practices
- **Match Tracking**: View upcoming and past matches from league schedule
- **RSVP System**: Players can respond to events

### Technical Features
- **Fast Database Initialization**: COPY format loads 1000s of rows in seconds
- **Automatic Data Updates**: Scraper regenerates both INSERT and COPY SQL formats
- **Health Monitoring**: Built-in health checks and progress logging
- **Docker Development**: Complete containerized workflow with single command

## 🗄️ Database

### Data Sources

1. **Manual Data** (in `database/data/`):
   - Core lookups (sports, event types, statuses)
   - Venues
   - Manual users and teams

2. **Scraped APSL Data** (auto-generated):
   - Leagues and conferences
   - Clubs and sport divisions
   - Teams and rosters
   - Players (1000+ from APSL)
   - Match schedules

### Database Initialization

The system uses two SQL formats for optimal performance:

- **`.sql` files**: Traditional INSERT statements with `ON CONFLICT DO UPDATE`
- **`.copy.sql` files**: PostgreSQL COPY format (100x faster for bulk inserts)

The init script automatically prefers `.copy.sql` when available.

### Regenerating APSL Data

```bash
# Scrape latest APSL data (generates both .sql and .copy.sql)
./dev.sh --scrape-only

# Review changes
git diff database/data/

# Commit if needed
git add database/data/
git commit -m "Update APSL data"
```

## 🐳 Docker Services

```bash
# View logs
docker logs -f footballhome_backend
docker logs -f footballhome_db
docker logs -f footballhome_frontend

# Access database directly
docker exec -it footballhome_db psql -U footballhome footballhome

# Restart single service
docker compose restart backend

# Stop everything
docker compose down

# Stop and remove volumes (fresh database)
docker compose down -v
```

## 📊 pgAdmin

Access database admin at http://localhost:5050

- **Email**: `admin@footballhome.org`
- **Password**: `admin`

Connection settings are pre-configured in `docker/pgadmin-servers.json`.

## 🔍 Troubleshooting

### Database won't initialize
```bash
# Check database logs
docker logs footballhome_db

# Verify SQL files exist
ls -lh database/data/*.copy.sql

# Force full rebuild
docker compose down -v
./dev.sh
```

### Backend won't start
```bash
# Check backend logs
docker logs footballhome_backend

# Rebuild C++ backend
docker compose build --no-cache backend
docker compose up -d backend
```

### Slow database loading
The system uses COPY format for fast bulk loading. If you see slow performance:
- Ensure `.copy.sql` files are generated (run `./dev.sh --scrape-only`)
- Check init script prefers COPY files in `docker/postgres/init-with-progress.sh`

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
