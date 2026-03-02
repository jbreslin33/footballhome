.PHONY: all help clean build up down rebuild logs test ps shell-db load parse parse-apsl parse-csl parse-casa load-apsl load-csl load-casa events events-apsl events-csl init init-apsl init-csl init-casa scrape scrape-apsl scrape-csl scrape-casa backup restore safe-rebuild sync sync-apsl sync-csl sync-casa dev-reset

# Ensure Python user bin is in PATH (for podman-compose)
PYTHON_USER_BIN := $(shell python3 -m site --user-base 2>/dev/null)/bin
export PATH := $(PYTHON_USER_BIN):$(PATH)

# Auto-detect compose tool: prefer podman-compose, fall back to docker-compose
COMPOSE := $(shell PATH="$(PYTHON_USER_BIN):$$PATH" command -v podman-compose 2>/dev/null || command -v docker-compose 2>/dev/null)
# Auto-detect container engine: prefer podman, fall back to docker
ENGINE := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)
# DB exec command: use compose exec for docker, direct exec for podman
ifeq ($(findstring podman,$(ENGINE)),podman)
  DB_EXEC = $(ENGINE) exec -i footballhome_db
  DB_EXEC_IT = $(ENGINE) exec -it footballhome_db
else
  DB_EXEC = $(COMPOSE) --env-file env exec -T db
  DB_EXEC_IT = $(COMPOSE) --env-file env exec db
endif

# Default target - safe, non-destructive
all: up

# Help - show available targets
help:
	@echo "Football Home - Makefile Targets"
	@echo ""
	@echo "Primary workflow (idempotent sync per league):"
	@echo "  make sync        - Sync all leagues: scrape → parse → UPSERT (APSL → CSL → CASA)"
	@echo "  make sync-apsl   - Sync APSL only"
	@echo "  make sync-csl    - Sync CSL only"
	@echo "  make sync-casa   - Sync CASA only"
	@echo ""
	@echo "Development:"
	@echo "  make dev-reset   - Fresh DB from scratch: rebuild + load all leagues"
	@echo "  make up          - Start containers (safe, non-destructive)"
	@echo "  make build       - Build images and start containers"
	@echo "  make down        - Stop containers"
	@echo "  make ps          - Show running containers"
	@echo "  make shell-db    - Connect to database shell"
	@echo "  make logs        - View all container logs"
	@echo "  make logs-db     - View database logs"
	@echo "  make logs-backend - View backend logs"
	@echo "  make audit       - Run data quality audit"
	@echo ""
	@echo "Individual pipeline steps:"
	@echo "  make scrape      - Fetch fresh HTML from web (all leagues)"
	@echo "  make scrape-apsl/csl/casa  - Scrape individual league"
	@echo "  make parse       - Regenerate SQL from cached HTML (all leagues, no DB needed)"
	@echo "  make parse-apsl/csl/casa   - Parse individual league"
	@echo "  make load        - Load/UPSERT all league SQL into database"
	@echo "  make load-apsl/csl/casa    - Load individual league"
	@echo "  make events      - Scrape match events for APSL + CSL"
	@echo "  make events-apsl/csl       - Scrape events for individual league"
	@echo ""
	@echo "Backup & restore:"
	@echo "  make backup      - Snapshot DB to backups/ (pg_dump)"
	@echo "  make restore     - Restore latest backup (or BACKUP=file.sql)"
	@echo "  make safe-rebuild - Backup + rebuild (safety net for live data)"
	@echo ""

# ============================================================
# Standard Targets
# ============================================================

clean:
	@echo "🧹 Cleaning containers and volumes..."
	@$(COMPOSE) --env-file env down -v 2>&1 | grep -v "no container with" | grep -v "Error:" || true
	@$(ENGINE) stop footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@$(ENGINE) rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@$(ENGINE) pod rm -f pod_footballhome 2>/dev/null || true
	@$(ENGINE) volume rm footballhome_db_data 2>/dev/null || true
	@$(ENGINE) network rm footballhome_footballhome_network 2>/dev/null || true
	@echo "✓ Cleanup complete"

build:
	@echo "🔨 Building images and starting containers..."
	@$(COMPOSE) --env-file env build
	@$(COMPOSE) --env-file env up -d
	@echo "✓ Build complete and containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

up:
	@echo "🚀 Starting containers..."
	@$(COMPOSE) --env-file env up -d
	@echo "✓ Containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

down:
	@echo "🛑 Stopping containers..."
	@$(COMPOSE) --env-file env down

rebuild: clean
	@echo "🏗️  Full rebuild..."
	@./build.sh

logs:
	@$(COMPOSE) --env-file env logs -f

test:
	@echo "🧪 Running tests..."
	@npm test

# ============================================================
# Custom Targets (Domain-Specific)
# ============================================================

# ============================================================
# League Init (one-time onboarding, generates SQL files)
# ============================================================

# Full init for each league (parse + load + events + export SQL)
# These require a running DB with bootstrap data loaded
init-apsl:
	@cd database/scripts/leagues/north-america/usa/apsl && ./init.sh

init-csl:
	@cd database/scripts/leagues/north-america/usa/csl && ./init.sh

init-casa:
	@cd database/scripts/leagues/north-america/usa/casa && ./init.sh

# Init all leagues in dependency order (includes event scraping — needs DB)
init: init-apsl init-csl init-casa
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
	@cd database/scripts/leagues/north-america/usa/apsl && ./load.sh

load-csl:
	@echo "📥 Loading CSL SQL..."
	@cd database/scripts/leagues/north-america/usa/csl && ./load.sh

load-casa:
	@echo "📥 Loading CASA SQL..."
	@cd database/scripts/leagues/north-america/usa/casa && ./load.sh

# ============================================================
# Parse (regenerate SQL from cached HTML, no DB needed)
# ============================================================

parse:
	@echo "📝 Parsing and curating all leagues..."
	@cd database/scripts/leagues/north-america/usa/apsl && ./parse.sh && cd - > /dev/null
	@cd database/scripts/leagues/north-america/usa/csl && ./parse.sh && cd - > /dev/null
	@cd database/scripts/leagues/north-america/usa/casa && ./parse.sh && cd - > /dev/null
	@echo "✓ All leagues parsed"

parse-apsl:
	@cd database/scripts/leagues/north-america/usa/apsl && ./parse.sh

parse-csl:
	@cd database/scripts/leagues/north-america/usa/csl && ./parse.sh

parse-casa:
	@cd database/scripts/leagues/north-america/usa/casa && ./parse.sh

# ============================================================
# Scrape (fetch fresh HTML from web)
# ============================================================

scrape: scrape-apsl scrape-csl scrape-casa
	@echo ""
	@echo "✓ All leagues scraped"

scrape-apsl:
	@cd database/scripts/leagues/north-america/usa/apsl && ./scrape.sh

scrape-csl:
	@cd database/scripts/leagues/north-america/usa/csl && ./scrape.sh

scrape-casa:
	@cd database/scripts/leagues/north-america/usa/casa && ./scrape.sh

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

# ============================================================
# Sync (primary workflow: scrape → parse → UPSERT, idempotent)
# ============================================================

sync: sync-apsl sync-csl sync-casa
	@echo ""
	@echo "✓ All leagues synced"

sync-apsl: scrape-apsl parse-apsl load-apsl
	@echo "✓ APSL synced"

sync-csl: scrape-csl parse-csl load-csl
	@echo "✓ CSL synced"

sync-casa: scrape-casa parse-casa load-casa
	@echo "✓ CASA synced"

# ============================================================
# Dev Reset (fresh database from scratch)
# ============================================================

dev-reset: rebuild load
	@echo ""
	@echo "✓ Development reset complete (fresh DB with all league data)"

# ============================================================
# Backup & Restore (pg_dump snapshots)
# ============================================================

backup:
	@mkdir -p backups
	@echo "💾 Backing up database..."
	@$(DB_EXEC) pg_dump -U footballhome_user footballhome > backups/backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "✓ Backup saved: $$(ls -t backups/backup-*.sql | head -1)"

restore:
	$(eval BACKUP_FILE := $(or $(BACKUP),$(shell ls -t backups/backup-*.sql 2>/dev/null | head -1)))
	@if [ -z "$(BACKUP_FILE)" ]; then echo "❌ No backup found. Run: make backup"; exit 1; fi
	@echo "♻️  Restoring from $(BACKUP_FILE)..."
	@$(DB_EXEC) psql -U footballhome_user -d footballhome < $(BACKUP_FILE)
	@echo "✓ Restored from $(BACKUP_FILE)"

safe-rebuild: backup rebuild
	@echo "✓ Safe rebuild complete (backup in backups/)"
	@echo "  Run: make load    (to load SQL files)"
	@echo "  Or:  make restore (to restore from backup)"

# ============================================================
# Development Helpers
# ============================================================

ps:
	@$(COMPOSE) --env-file env ps

shell-db:
	@$(DB_EXEC_IT) psql -U footballhome_user -d footballhome

logs-db:
	@$(COMPOSE) --env-file env logs -f db

logs-backend:
	@$(COMPOSE) --env-file env logs -f backend

audit:
	@echo "📊 Auditing database..."
	@node database/scripts/audit-database.js
