.PHONY: all help clean build up down rebuild logs test ps shell-db bootstrap load parse parse-apsl parse-csl parse-casa load-apsl load-csl load-casa refresh

# Default target - safe, non-destructive
all: up

# Help - show available targets
help:
	@echo "Football Home - Makefile Targets"
	@echo ""
	@echo "Standard targets:"
	@echo "  make             - Default: start containers (safe, non-destructive)"
	@echo "  make all         - Same as 'make' (just start containers)"
	@echo "  make build       - Build images and start containers"
	@echo "  make up          - Start containers"
	@echo "  make down        - Stop containers"
	@echo "  make clean       - Destroy all containers and volumes"
	@echo "  make rebuild     - Nuclear: clean + build fresh (wipes all data)"
	@echo "  make logs        - View all container logs"
	@echo "  make test        - Run tests"
	@echo ""
	@echo "Database workflows:"
	@echo "  make bootstrap   - Rebuild DB with bootstrap data only (no leagues)"
	@echo "  make load        - Load all league SQL to running database"
	@echo "  make parse       - Parse/curate all leagues (regenerate SQL files)"
	@echo "  make refresh     - Full workflow: parse all + rebuild DB + load all"
	@echo ""
	@echo "Per-league operations:"
	@echo "  make parse-apsl  - Parse/curate APSL only"
	@echo "  make parse-csl   - Parse/curate CSL only (needs APSL SQL)"
	@echo "  make parse-casa  - Parse/curate CASA only (needs APSL + CSL SQL)"
	@echo "  make load-apsl   - Load APSL SQL to database"
	@echo "  make load-csl    - Load CSL SQL to database"
	@echo "  make load-casa   - Load CASA SQL to database"
	@echo ""
	@echo "Manual scraping (per-league):"
	@echo "  cd database/scripts/leagues/usa-apsl && ./scrape.sh"
	@echo "  cd database/scripts/leagues/usa-csl && ./scrape.sh"
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
	@podman-compose --env-file env down 2>&1 | grep -v "no container with" | grep -v "Error:" || true
	@podman stop footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@podman rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@podman volume rm footballhome_db_data 2>/dev/null || true
	@podman volume rm footballhome_footballhome_network 2>/dev/null || true
	@podman network rm footballhome_footballhome_network 2>/dev/null || true
	@podman pod rm -f pod_footballhome 2>/dev/null || true
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

load:
	@echo "📥 Loading league SQL in hierarchical order..."
	@echo "   1. APSL (baseline)"
	@cd database/scripts/leagues/usa-apsl && ./load.sh && cd - > /dev/null
	@echo ""
	@echo "   2. CSL (curated against APSL)"
	@cd database/scripts/leagues/usa-csl && ./load.sh && cd - > /dev/null
	@echo ""
	@echo "   3. CASA (curated against APSL + CSL)"
	@cd database/scripts/leagues/usa-casa && ./load.sh && cd - > /dev/null
	@echo ""
	@echo "✓ All leagues loaded"

# Individual league targets
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

load-apsl:
	@cd database/scripts/leagues/usa-apsl && ./load.sh

load-csl:
	@cd database/scripts/leagues/usa-csl && ./load.sh

load-casa:
	@cd database/scripts/leagues/usa-casa && ./load.sh

# Full refresh: parse all, then bootstrap DB, then load all
refresh: parse bootstrap load
	@echo "✓ Full refresh complete (parsed all leagues, fresh DB, loaded all data)"

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
