.PHONY: all help clean build up down rebuild logs test ps shell-db bootstrap load parse parse-apsl parse-csl parse-casa load-apsl load-csl load-casa events events-apsl events-csl refresh init-apsl init-csl init-casa init-all

# Default target - safe, non-destructive
all: up

# Help - show available targets
help:
	@echo "Football Home - Makefile Targets"
	@echo ""
	@echo "Standard targets:"
	@echo "  make             - Default: start containers (safe, non-destructive)"
	@echo "  make build       - Build images and start containers"
	@echo "  make up          - Start containers"
	@echo "  make down        - Stop containers"
	@echo "  make clean       - Destroy all containers and volumes"
	@echo "  make rebuild     - Nuclear: clean + build fresh (wipes all data)"
	@echo "  make logs        - View all container logs"
	@echo "  make test        - Run tests"
	@echo ""
	@echo "Daily use (load committed SQL into DB):"
	@echo "  make load        - Load all league SQL into database"
	@echo "  make load-apsl   - Load APSL SQL only"
	@echo "  make load-csl    - Load CSL SQL only (needs APSL loaded)"
	@echo "  make load-casa   - Load CASA SQL only (needs APSL+CSL loaded)"
	@echo ""
	@echo "League init (one-time onboarding, generates SQL files):"
	@echo "  make init-apsl   - Full APSL init: parse + load + events + export"
	@echo "  make init-csl    - Full CSL init: parse + load + events + export"
	@echo "  make init-casa   - Full CASA init: parse + load"
	@echo "  make init-all    - Init all leagues (fresh DB required: make rebuild first)"
	@echo ""
	@echo "Parse only (regenerate SQL from cached HTML, no DB needed):"
	@echo "  make parse       - Parse all leagues (in dependency order)"
	@echo "  make parse-apsl  - Parse APSL only (baseline, no dependencies)"
	@echo "  make parse-csl   - Parse CSL only (needs APSL parsed)"
	@echo "  make parse-casa  - Parse CASA only (needs APSL+CSL parsed)"
	@echo ""
	@echo "Events (scrape match events, needs DB with matches loaded):"
	@echo "  make events      - Scrape events for all leagues"
	@echo "  make events-apsl - Scrape APSL match events only"
	@echo "  make events-csl  - Scrape CSL match events only"
	@echo ""
	@echo "Full workflows:"
	@echo "  make rebuild && make load   - Fresh DB from committed SQL"
	@echo "  make rebuild && make init-all - Full init from cached HTML"
	@echo "  make refresh               - parse + rebuild + load (fast refresh)"
	@echo ""
	@echo "Manual scraping (fetch HTML from web):"
	@echo "  cd database/scripts/leagues/usa-apsl && ./scrape.sh"
	@echo "  cd database/scripts/leagues/usa-csl && ./scrape.sh"
	@echo "  cd database/scripts/leagues/usa-casa && ./scrape.sh"
	@echo ""
	@echo "Development:"
	@echo "  make ps          - Show running containers"
	@echo "  make shell-db    - Connect to database shell"
	@echo "  make logs-db     - View database logs"
	@echo "  make logs-backend - View backend logs"
	@echo ""

# ============================================================
# Standard Targets
# ============================================================

clean:
	@echo "🧹 Cleaning containers and volumes..."
	@command -v podman-compose >/dev/null 2>&1 && podman-compose --env-file env down -v 2>&1 | grep -v "no container with" | grep -v "Error:" || true
	@podman stop footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@podman rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@podman pod rm -f pod_footballhome 2>/dev/null || true
	@podman volume rm footballhome_db_data 2>/dev/null || true
	@podman volume rm footballhome_pgadmin_data 2>/dev/null || true
	@podman network rm footballhome_footballhome_network 2>/dev/null || true
	@echo "✓ Cleanup complete"

build:
	@echo "🔨 Building images and starting containers..."
	@podman-compose --env-file env build
	@podman-compose --env-file env up -d
	@echo "✓ Build complete and containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

up:
	@echo "🚀 Starting containers..."
	@podman-compose --env-file env up -d
	@echo "✓ Containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

down:
	@echo "🛑 Stopping containers..."
	@podman-compose --env-file env down

rebuild: clean
	@echo "🏗️  Full rebuild with all data..."
	@./build.sh

logs:
	@podman-compose --env-file env logs -f

test:
	@echo "🧪 Running tests..."
	@npm test

# ============================================================
# Custom Targets (Domain-Specific)
# ============================================================

bootstrap: clean
	@echo "🏗️  Bootstrap rebuild (no league data loaded automatically)..."
	@./build.sh
	@echo "✓ Bootstrap complete - database ready"
	@echo "  Run: make load    (to load all leagues)"

# ============================================================
# League Init (one-time onboarding, generates SQL files)
# ============================================================

# Full init for each league (parse + load + events + export SQL)
# These require a running DB with bootstrap data loaded
init-apsl:
	@cd database/scripts/leagues/usa-apsl && ./init.sh

init-csl:
	@cd database/scripts/leagues/usa-csl && ./init.sh

init-casa:
	@cd database/scripts/leagues/usa-casa && ./init.sh

# Init all leagues in dependency order (requires make rebuild first)
init-all: init-apsl init-csl init-casa
	@echo ""
	@echo "✓ All leagues initialized"
	@echo "  SQL files ready to commit in database/scripts/leagues/*/sql/"

# ============================================================
# Load (load committed SQL files into database)
# ============================================================

# Load all leagues (calls individual targets in dependency order)
load: load-apsl load-csl load-casa
	@echo ""
	@echo "✓ All leagues loaded (events included in SQL files)"

# Individual league load targets
load-apsl:
	@echo "📥 Loading APSL SQL..."
	@cd database/scripts/leagues/usa-apsl && ./load.sh

load-csl:
	@echo "📥 Loading CSL SQL..."
	@cd database/scripts/leagues/usa-csl && ./load.sh

load-casa:
	@echo "📥 Loading CASA SQL..."
	@cd database/scripts/leagues/usa-casa && ./load.sh

# ============================================================
# Parse (regenerate SQL from cached HTML, no DB needed)
# ============================================================

parse:
	@echo "📝 Parsing and curating all leagues..."
	@cd database/scripts/leagues/usa-apsl && ./parse.sh && cd - > /dev/null
	@cd database/scripts/leagues/usa-csl && ./parse.sh && cd - > /dev/null
	@cd database/scripts/leagues/usa-casa && ./parse.sh && cd - > /dev/null
	@echo "✓ All leagues parsed"

parse-apsl:
	@cd database/scripts/leagues/usa-apsl && ./parse.sh

parse-csl:
	@cd database/scripts/leagues/usa-csl && ./parse.sh

parse-casa:
	@cd database/scripts/leagues/usa-casa && ./parse.sh

# ============================================================
# Events (scrape match events, requires DB with matches loaded)
# ============================================================

events: events-apsl events-csl
	@echo ""
	@echo "✓ Event scraping complete"

events-apsl:
	@echo "⚽ Scraping APSL match events..."
	@cd database/scripts/scrapers && node ApslMatchEventScraper.js

events-csl:
	@echo "⚽ Scraping CSL match events..."
	@cd database/scripts/scrapers && node CslMatchEventScraper.js || echo "   ℹ️  CSL event scraper not yet ready"

# Full refresh: parse all, then bootstrap DB, then load all
refresh: parse bootstrap load
	@echo "✓ Full refresh complete (parsed all leagues, fresh DB, loaded all data including events)"

# ============================================================
# Development Helpers
# ============================================================

ps:
	@podman ps --filter "name=footballhome"

shell-db:
	@podman exec -it footballhome_db psql -U footballhome_user -d footballhome

logs-db:
	@podman logs -f footballhome_db

logs-backend:
	@podman logs -f footballhome_backend

audit:
	@echo "📊 Auditing database..."
	@node database/scripts/audit-database.js
