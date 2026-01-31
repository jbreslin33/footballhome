.PHONY: all help clean build up down rebuild logs test ps shell-db bootstrap load

# Default target - standard convention
all: rebuild

# Help - show available targets
help:
	@echo "Football Home - Makefile Targets"
	@echo ""
	@echo "Standard targets:"
	@echo "  make all         - Default: full rebuild with all data"
	@echo "  make clean       - Destroy all containers and volumes"
	@echo "  make build       - Build container images"
	@echo "  make up          - Start containers"
	@echo "  make down        - Stop containers"
	@echo "  make rebuild     - clean + build + up (full data)"
	@echo "  make logs        - View all container logs"
	@echo "  make test        - Run tests"
	@echo ""
	@echo "Custom targets:"
	@echo "  make bootstrap   - Rebuild with bootstrap data only (no leagues)"
	@echo "  make load        - Load all league SQL files to running database"
	@echo ""
	@echo "Per-league operations (manual):"
	@echo "  cd database/scripts/leagues/usa-apsl"
	@echo "  ./scrape.sh      - Fetch HTML from web"
	@echo "  ./parse.sh       - Generate SQL from cached HTML"
	@echo "  ./load.sh        - Load APSL SQL to database"
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
	@echo "🔨 Building container images..."
	@podman-compose --env-file env build

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
	@echo "🏗️  Bootstrap-only rebuild (no league data)..."
	@mkdir -p .temp-league-data
	@mv database/scripts/leagues/*/sql/*.sql .temp-league-data/ 2>/dev/null || true
	@./build.sh
	@mv .temp-league-data/*.sql database/scripts/leagues/usa-apsl/sql/ 2>/dev/null || true
	@mv .temp-league-data/*.sql database/scripts/leagues/usa-csl/sql/ 2>/dev/null || true
	@mv .temp-league-data/*.sql database/scripts/leagues/usa-casa/sql/ 2>/dev/null || true
	@rmdir .temp-league-data 2>/dev/null || true
	@echo "✓ Bootstrap complete - database ready for scrapers"

load:
	@echo "📥 Loading all league SQL files..."
	@for league in database/scripts/leagues/*/; do \
		if [ -f "$$league/load.sh" ]; then \
			echo ""; \
			cd "$$league" && ./load.sh && cd - > /dev/null; \
		fi \
	done
	@echo ""
	@echo "✓ All leagues loaded"

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
