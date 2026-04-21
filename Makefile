.PHONY: all help clean build deploy up down rebuild logs test ps shell-db load load-apsl load-csl load-casa parse parse-apsl parse-csl parse-casa scrape scrape-apsl scrape-csl scrape-casa scrape-standings scrape-apsl-standings scrape-csl-standings scrape-casa-standings scrape-teams scrape-apsl-teams scrape-csl-teams scrape-rosters scrape-casa-rosters scrape-schedule scrape-casa-schedule events events-apsl events-csl init init-apsl init-csl init-casa backup restore safe-rebuild sync sync-apsl sync-csl sync-casa sync-groupme sync-lighthouse migrate vpn-up vpn-down vpn-status

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
	@echo "Sync (primary workflow — idempotent, safe to run anytime):"
	@echo "  make sync          Sync all leagues + GroupMe"
	@echo "  make sync-lighthouse Sync Lighthouse-only APSL + CASA + GroupMe"
	@echo "  make sync-apsl     Sync APSL only"
	@echo "  make sync-csl      Sync CSL only"
	@echo "  make sync-casa     Sync CASA only"
	@echo "  make sync-groupme  Sync GroupMe events + RSVPs"
	@echo ""
	@echo "Containers:"
	@echo "  make build         Build images and start containers"
	@echo "  make deploy        Build + replace backend container (for C++ changes)"
	@echo "  make up            Start containers"
	@echo "  make down          Stop containers"
	@echo "  make rebuild       Destroy everything + fresh build (wipes DB)"
	@echo "  make migrate       Apply pending schema migrations (preserves data)"
	@echo ""
	@echo "Scraping (fetch fresh HTML from web — APSL/CSL auto-use VPN):"
	@echo "  make scrape                Scrape everything for all leagues"
	@echo "  make scrape-apsl           Scrape all APSL data (standings + teams) [VPN]"
	@echo "  make scrape-csl            Scrape all CSL data (standings + teams) [VPN]"
	@echo "  make scrape-casa           Scrape all CASA data (standings + rosters + schedule)"
	@echo "  make scrape-standings      Scrape standings for all leagues"
	@echo "  make scrape-apsl-standings Scrape APSL standings only [VPN]"
	@echo "  make scrape-csl-standings  Scrape CSL standings only [VPN]"
	@echo "  make scrape-casa-standings Scrape CASA standings only"
	@echo "  make scrape-teams          Scrape team pages (APSL + CSL) [VPN]"
	@echo "  make scrape-apsl-teams     Scrape APSL team pages (rosters + schedule) [VPN]"
	@echo "  make scrape-csl-teams      Scrape CSL team pages (rosters + schedule) [VPN]"
	@echo "  make scrape-rosters        Scrape rosters for all leagues"
	@echo "  make scrape-casa-rosters   Scrape CASA rosters (Google Sheets)"
	@echo "  make scrape-schedule       Scrape schedules for all leagues"
	@echo "  make scrape-casa-schedule  Scrape CASA schedule (SportsEngine API)"
	@echo "  (Skip VPN: NO_VPN=1 make scrape-apsl-standings)"
	@echo ""
	@echo "Debugging:"
	@echo "  make parse-apsl    Regenerate SQL from cached HTML (also: parse-csl, parse-casa)"
	@echo "  make shell-db      Connect to database shell"
	@echo "  make ps            Show running containers"
	@echo "  make logs          View all container logs"
	@echo "  make audit         Run data quality audit"
	@echo ""
	@echo "Backup & restore:"
	@echo "  make backup              Snapshot DB (pg_dump → backups/)"
	@echo "  make restore             Restore latest backup (or BACKUP=file.sql)"
	@echo "  make safe-rebuild        Backup + rebuild (safety net)"
	@echo "  make export-user-data    Export manual attendance + lineups to SQL"
	@echo "  make load-user-data      Load exported user data (after sync)"
	@echo ""
	@echo "VPN (automatic for APSL/CSL — manual controls):"
	@echo "  make vpn-up              Connect WireGuard VPN manually"
	@echo "  make vpn-down            Disconnect WireGuard VPN manually"
	@echo "  make vpn-status          Show VPN status + external IP"
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

deploy:
	@echo "🚀 Building and deploying backend..."
	@$(COMPOSE) --env-file env build backend
	@$(ENGINE) rm -f footballhome_frontend 2>/dev/null || true
	@$(ENGINE) rm -f footballhome_backend 2>/dev/null || true
	@$(COMPOSE) --env-file env up -d backend frontend
	@echo "✓ Deploy complete — new backend is live"
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
# Load (internal — used by sync-* targets)
# ============================================================

load: load-apsl load-csl load-casa
	@echo ""
	@echo "✓ All leagues loaded"

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

# --- Per-league per-datatype scrape targets ---

# Standings (all leagues)
scrape-standings: scrape-apsl-standings scrape-csl-standings scrape-casa-standings
	@echo "✓ All standings scraped"

scrape-apsl-standings:
	@cd database/scripts/leagues/north-america/usa/apsl && ./scrape-standings.sh

scrape-csl-standings:
	@cd database/scripts/leagues/north-america/usa/csl && ./scrape-standings.sh

scrape-casa-standings:
	@cd database/scripts/leagues/north-america/usa/casa && ./scrape-standings.sh

# Team pages — APSL/CSL only (each team page has rosters + schedule)
scrape-teams: scrape-apsl-teams scrape-csl-teams
	@echo "✓ All team pages scraped"

scrape-apsl-teams:
	@cd database/scripts/leagues/north-america/usa/apsl && ./scrape-teams.sh

scrape-csl-teams:
	@cd database/scripts/leagues/north-america/usa/csl && ./scrape-teams.sh

# Rosters (APSL/CSL via team pages, CASA via Google Sheets)
scrape-rosters: scrape-apsl-teams scrape-csl-teams scrape-casa-rosters
	@echo "✓ All rosters scraped"

scrape-casa-rosters:
	@cd database/scripts/leagues/north-america/usa/casa && ./scrape-rosters.sh

# Schedule (APSL/CSL via team pages, CASA via SportsEngine API)
scrape-schedule: scrape-apsl-teams scrape-csl-teams scrape-casa-schedule
	@echo "✓ All schedules scraped"

scrape-casa-schedule:
	@cd database/scripts/leagues/north-america/usa/casa && ./scrape-schedule.sh

# ============================================================
# Events (scrape match events, requires DB with matches loaded)
# ============================================================

events: events-apsl events-csl
	@echo ""
	@echo "✓ Event scraping complete"

events-apsl:
	@echo "⚽ Scraping APSL match events..."
	@scripts/vpn-wrap.sh bash -c 'cd database/scripts/scrapers && node ApslMatchEventScraper.js'

events-csl:
	@echo "⚽ Scraping CSL match events..."
	@scripts/vpn-wrap.sh bash -c 'cd database/scripts/scrapers && node CslMatchEventScraper.js' || echo "   ℹ️  CSL event scraper not yet ready"

# ============================================================
# Sync (primary workflow: scrape → parse → UPSERT, idempotent)
#
# Full sync runs in 4 phases:
#   Phase 1: Scrape all leagues in parallel (network I/O)
#   Phase 2: Parse in dependency order (curation chain: APSL → CSL → CASA)
#   Phase 3: Load in dependency order
#   Phase 4: Sync GroupMe events + RSVPs (needs teams loaded first)
#
# Individual sync-* targets still run sequentially per league.
# ============================================================

sync:
	@echo "⏬ Phase 1: Scraping all leagues..."
	@$(MAKE) scrape-apsl
	@$(MAKE) scrape-csl
	@$(MAKE) scrape-casa
	@echo ""
	@echo "✓ All leagues scraped"
	@echo ""
	@echo "📝 Phase 2: Parsing in dependency order..."
	@$(MAKE) parse-apsl
	@$(MAKE) parse-csl
	@$(MAKE) parse-casa
	@echo ""
	@echo "✓ All leagues parsed"
	@echo ""
	@echo "📥 Phase 3: Loading in dependency order..."
	@$(MAKE) load-apsl
	@$(MAKE) load-csl
	@$(MAKE) load-casa
	@echo ""
	@echo "✓ All leagues synced"
	@echo ""
	@echo "💬 Phase 4: Syncing GroupMe events + RSVPs..."
	@$(MAKE) sync-groupme
	@echo ""
	@echo "✓ Full sync complete (leagues + GroupMe)"

sync-apsl: scrape-apsl parse-apsl load-apsl
	@echo "✓ APSL synced"

sync-csl: scrape-csl parse-csl load-csl
	@echo "✓ CSL synced"

sync-casa: scrape-casa parse-casa load-casa
	@echo "✓ CASA synced"

sync-lighthouse:
	@echo "⏬ Syncing Lighthouse leagues..."
	@FORCE_SCRAPE=1 LIGHTHOUSE_ONLY=1 $(MAKE) sync-apsl
	@LIGHTHOUSE_ONLY=1 $(MAKE) sync-casa
	@$(MAKE) sync-groupme
	@echo "✓ Lighthouse synced (APSL + CASA + GroupMe)"

sync-groupme:
	@echo "💬 Syncing GroupMe events + RSVPs..."
	@node scripts/sync-groupme-events.js
	@echo "✓ GroupMe synced"

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
	@echo "  Run: make sync    (to re-sync league data)"
	@echo "  Or:  make restore (to restore from backup)"

export-user-data:
	@echo "📦 Exporting user data..."
	@node database/scripts/export-user-data.js

load-user-data:
	@echo "📥 Loading user data..."
	@./database/scripts/load-user-data.sh

# ============================================================
# Development Helpers
# ============================================================

migrate:
	@./database/migrations/run-migrations.sh

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

# ============================================================
# VPN (WireGuard — for IP-blocked scraping)
# ============================================================

vpn-up:
	@sudo scripts/setup/setup-wireguard.sh up

vpn-down:
	@sudo scripts/setup/setup-wireguard.sh down

vpn-status:
	@sudo scripts/setup/setup-wireguard.sh status

# vpn-scrape / vpn-sync removed — VPN is now automatic for APSL/CSL targets.
# Just run: make scrape  or  make sync
