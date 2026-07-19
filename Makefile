.PHONY: all help clean build deploy up restart down rebuild logs test ps shell-db load load-apsl load-csl load-casa parse parse-apsl parse-csl parse-casa scrape scrape-apsl scrape-csl scrape-casa scrape-standings scrape-apsl-standings scrape-csl-standings scrape-casa-standings scrape-teams scrape-apsl-teams scrape-csl-teams scrape-rosters scrape-casa-rosters scrape-schedule scrape-casa-schedule events events-apsl events-csl init init-apsl init-csl init-casa backup restore dev-mirror restore-mirror setup-dev-slots setup-dev-slot setup-dev-jbreslin setup-dev-lbreslin dev-init dev-up dev-down dev-restore-mirror dev-membership-sync dev-nginx dev-ps safe-rebuild er emergency-rebuild sync sync-apsl sync-csl sync-casa sync-lighthouse migrate vpn-up vpn-down vpn-status scrape-vpn-up scrape-vpn-down scrape-vpn-status scrape-vpn-shell scrape-vpn-logs scrape-vpn-rebuild lighthouse lighthouse-apsl lighthouse-apsl-standings lighthouse-apsl-team lighthouse-casa lighthouse-casa-liga1 lighthouse-casa-liga2 check-la-sync

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
	@echo "🏠 Lighthouse (the only thing that matters — each target is full scrape+parse+load):"
	@echo "  make lighthouse                       ⭐ Full Lighthouse refresh (runs all below)"
	@echo "  make lighthouse-apsl                  APSL: whole-league standings + Lighthouse team page"
	@echo "    make lighthouse-apsl-standings    └─ just whole-league standings"
	@echo "    make lighthouse-apsl-team         └─ just Lighthouse 1893 SC team page (roster+schedule)"
	@echo "  make lighthouse-casa                  CASA: both Lighthouse divisions"
	@echo "    make lighthouse-casa-liga1        └─ Philadelphia Liga 1 (Lighthouse Boys Club)"
	@echo "    make lighthouse-casa-liga2        └─ Philadelphia Liga 2 (Lighthouse Boys Club U23)"
	@echo ""
	@echo "Sync (legacy whole-league — idempotent, safe to run anytime):"
	@echo "  make sync          Sync all leagues"
	@echo "  make sync-lighthouse Sync Lighthouse-only APSL + CASA"
	@echo "  make sync-apsl     Sync APSL only"
	@echo "  make sync-csl      Sync CSL only"
	@echo "  make sync-casa     Sync CASA only"
	@echo ""
	@echo "Containers:"
	@echo "  make build         Build images and start containers"
	@echo "  make deploy        Build + replace backend container (for C++ changes)"
	@echo "  make up            Start containers"
	@echo "  make restart       Stop everything, start fresh, reload nginx"
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
	@echo "  make er                  🚨 Emergency rebuild — full one-shot recovery (preserves user data)"
	@echo "  make er FORCE=1          Same, no confirmation prompt"
	@echo "  make backup              Snapshot DB (pg_dump → backups/)"
	@echo "  make dev-mirror          Copy latest backup → backups/dev-mirror.sql.gz"
	@echo "  make restore             Restore latest backup (or BACKUP=file.sql)"
	@echo "  make restore-mirror      Restore prod mirror into *dev* DB (drop public first)"
	@echo "  ./scripts/dev/ship-to-live.sh   Print prod ship checklist (git pull → migrate/deploy)"
	@echo "  make safe-rebuild        Backup + rebuild (safety net)"
	@echo "  make export-user-data    Export manual attendance + lineups to SQL"
	@echo "  make load-user-data      Load exported user data (after sync)"
	@echo ""
	@echo "Per-developer server stacks (same host as prod — see docs/dev-environment.md):"
	@echo "  make setup-dev-slots                 Bootstrap ALL slots (jbreslin+lbreslin; setup.sh step)"
	@echo "  make setup-dev-jbreslin              Bootstrap only jbreslin (wrapper)"
	@echo "  make setup-dev-lbreslin              Bootstrap only lbreslin (wrapper)"
	@echo "  make setup-dev-slot DEV=jbreslin     Bootstrap one slot by slug"
	@echo "  make dev-init DEV=jbreslin           Create /srv/footballhome-dev-<slug> worktree"
	@echo "  make dev-up DEV=jbreslin             Start db+backend+frontend on that slot's ports"
	@echo "  make dev-restore-mirror DEV=jbreslin Load prod dump into that slot's DB"
	@echo "  make dev-membership-sync DEV=jbreslin  LeagueApps Membership → Sync now (CLI)"
	@echo "  make dev-nginx DEV=jbreslin          Install nginx vhost for <slug>.dev.footballhome.org"
	@echo "  make dev-ps DEV=jbreslin             Show that slot's containers"
	@echo "  make dev-down DEV=jbreslin           Stop slot (DEV_WIPE=1 also drops DB volume)"
	@echo "  Slots/ports: config/dev-slots.conf"
	@echo "  Full rebuild path: ./setup.sh   or   ./setup.sh --only dev-slots"
	@echo ""
	@echo "Sim runtime (C++ tactical simulator — see sim/DESIGN.md):"
	@echo "  make sim-deploy               Rebuild sim image + registry-consistency guard"
	@echo "  make sim-load-test-10min      10-min AsyncPgLog persistence load test"
	@echo "  make sim-load-test-orchestrator  20-match parallel orchestration load test"
	@echo ""
	@echo "VPN — scraper container (default, safe over SSH):"
	@echo "  make scrape-vpn-up       Start the dedicated scraper+VPN container (SSH-safe)"
	@echo "  make scrape-vpn-down     Stop and remove it"
	@echo "  make scrape-vpn-status   Show status + tunneled IP"
	@echo "  make scrape-vpn-shell    Open a shell inside it"
	@echo "  make scrape-vpn-logs     Tail container logs"
	@echo "  make scrape-vpn-rebuild  Rebuild the image from scratch"
	@echo ""
	@echo "VPN — host backend (legacy, drops SSH):"
	@echo "  make vpn-up              Alias for scrape-vpn-up (containerized)"
	@echo "  make vpn-down            Alias for scrape-vpn-down"
	@echo "  make vpn-status          Show host VPN status"
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
	@$(COMPOSE) --env-file env build --no-cache frontend
	@$(COMPOSE) --env-file env build backend
	@$(ENGINE) rm -f footballhome_frontend footballhome_backend footballhome_db 2>/dev/null || true
	@$(COMPOSE) --env-file env up -d
	@echo "✓ Build complete and containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

deploy:
	@echo "🚀 Building and deploying backend..."
	@$(MAKE) --no-print-directory check-la-sync
	@$(COMPOSE) --env-file env build backend
	# --depend is required because leagueapps-sync's `requires=footballhome_backend`
	# in podman-compose creates a hard dependency; without --depend a plain
	# `rm -f footballhome_backend` errors with 125 "has dependent containers"
	# and compose then falls back to `podman start` on the OLD container,
	# silently ignoring the freshly-built image. Losing this line means the
	# next `make deploy` for a C++ change appears to succeed but nothing
	# updates.
	@$(ENGINE) rm -f --depend footballhome_frontend 2>/dev/null || true
	@$(ENGINE) rm -f --depend footballhome_backend  2>/dev/null || true
	@$(COMPOSE) --env-file env up -d backend frontend leagueapps-sync
	@echo "✓ Deploy complete — new backend is live"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

# Pre-flight for `make deploy`: fails if any controller or model reads
# person_la_memberships without a preceding LaProgramSync entry point
# (see .github/copilot-instructions.md § Membership Data Flow).  Delegates
# to scripts/enforce-la-sync.sh so the same check works from a pre-commit
# hook.  Safe to run manually: `make check-la-sync`.
check-la-sync:
	@bash scripts/enforce-la-sync.sh

up:
	@echo "🚀 Starting containers..."
	@$(COMPOSE) --env-file env up -d
	@echo "✓ Containers started"
	@echo ""
	@echo "Frontend:  http://localhost:3000"
	@echo "Backend:   http://localhost:3001"

restart:
	@echo "🔄 Restarting all containers..."
	@$(COMPOSE) --env-file env down 2>&1 | grep -v "no container" || true
	@$(ENGINE) rm -f footballhome_db footballhome_backend footballhome_frontend 2>/dev/null || true
	@$(COMPOSE) --env-file env up -d
	@$(ENGINE) exec footballhome_frontend nginx -s reload 2>/dev/null || true
	@echo "✓ All containers restarted"
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

# 10-minute sim persistence load test — proves AsyncPgLog<InputRow> drops
# zero rows under simulated 100 ms Postgres latency for a full 10-minute
# match (DESIGN.md §16.5 exit criterion). Opt-in because it takes ~10
# minutes; the 5-second variant already runs in every sim image build
# via ctest. Uses a fresh debian:trixie-slim container to compile just
# the load-test binary, mirroring scripts/check_determinism_cross_arch.sh.
sim-load-test-10min:
	@echo "🧪 Running 10-minute AsyncPgLog load test (wall time ~10 min)..."
	@sudo podman run --rm \
		-v $(PWD)/sim:/work/sim:ro,z \
		-e DEBIAN_FRONTEND=noninteractive \
		-e FH_SIM_LOAD_10MIN=1 \
		docker.io/library/debian:trixie-slim \
		bash -c 'set -euo pipefail; \
			apt-get update -qq >/dev/null; \
			apt-get install -y -qq --no-install-recommends \
				g++ cmake ninja-build make pkg-config \
				libssl-dev libpqxx-dev ca-certificates >/dev/null; \
			cp -R /work/sim /tmp/sim; \
			cd /tmp/sim; \
			cmake -S . -B build-x -G Ninja -DCMAKE_BUILD_TYPE=Release >/dev/null; \
			cmake --build build-x --target test_async_pg_log_load >/dev/null; \
			./build-x/tests/test_async_pg_log_load'

# 20-match orchestration load test (Slice 14.7) — spawns N sim
# containers in parallel via POST /api/sim/matches, lets them tick
# idle, tears them down via POST /api/sim/matches/:id/stop, and
# verifies no orphan containers or DB rows survive. Uses the live
# stack (unlike sim-load-test-10min which spins up an ephemeral
# debian container). Overridable knobs at the top of the script.
sim-load-test-orchestrator:
	@bash sim/scripts/load_test_orchestrator.sh

# Rebuild the sim runtime image + verify registry consistency before
# declaring the deploy successful. Fixes the §21.8 M3-blocker footgun
# where a migration touching sim_attribute_registry / sim_concept_registry
# without a matching sim/src/common/M0Registry.generated.hpp regenerate +
# runtime rebuild crashes every new match spawn at bootstrap with
# `verifyM0RegistryConsistency: compile-time=N db=M` (2026-07-17 root
# cause of "ball and players don't render on 2v0" — see sim/DESIGN.md §21.8).
#
# Guard: after podman-compose builds the new image, spawns a throwaway probe
# container on the shared footballhome network, runs the exact bootstrap
# path (registry SELECTs + drift check) against the live footballhome_db,
# and refuses to succeed unless the probe reaches "listening on ...".
#
# In-flight matches keep their pre-existing image (immutable per container).
# New matches spawned via SimOrchestrator after this target succeeds pick
# up the fresh image.
sim-deploy:
	@echo "🎮 Rebuilding sim runtime image..."
	@$(COMPOSE) --env-file env build footballhome_sim
	@echo ""
	@echo "🔍 Verifying registry consistency (compile-time vs live DB)..."
	@bash sim/scripts/check_registry_consistency.sh
	@echo ""
	@echo "✓ sim runtime image is live and registry-consistent."
	@echo "  New matches spawned via SimOrchestrator will use this image."
	@echo "  In-flight matches keep their pre-existing image (immutable per container)."

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
# Full sync runs in 3 phases:
#   Phase 1: Scrape all leagues in parallel (network I/O)
#   Phase 2: Parse in dependency order (curation chain: APSL → CSL → CASA)
#   Phase 3: Load in dependency order
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
	@echo "✓ Full sync complete"

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
	@echo "✓ Lighthouse synced (APSL + CASA)"

# ============================================================
# Lighthouse-focused targets
#
# Naming convention (strict hierarchy, root → leaf):
#   lighthouse                          — everything
#   lighthouse-<league>                 — one league (all of it)
#   lighthouse-<league>-<sub>           — one slice of one league
#
# Every target is SELF-CONTAINED: it runs scrape → parse → load in one shot.
# Use the underlying scrape-*/parse-*/load-* targets only for debugging.
# ============================================================

# ── APSL ───────────────────────────────────────────────────────────────
lighthouse-apsl-standings:
	@echo "🏟️  Lighthouse → APSL standings (whole league)..."
	@FORCE_SCRAPE=1 $(MAKE) scrape-apsl-standings
	@$(MAKE) parse-apsl
	@$(MAKE) load-apsl
	@echo "✓ lighthouse-apsl-standings done"

lighthouse-apsl-team:
	@echo "🏠 Lighthouse → APSL team page (Lighthouse 1893 SC roster + schedule)..."
	@FORCE_SCRAPE=1 LIGHTHOUSE_ONLY=1 $(MAKE) scrape-apsl-teams
	@LIGHTHOUSE_ONLY=1 $(MAKE) parse-apsl
	@$(MAKE) load-apsl
	@echo "✓ lighthouse-apsl-team done"

lighthouse-apsl: lighthouse-apsl-standings lighthouse-apsl-team
	@echo "✅ lighthouse-apsl done (standings + team)"

# ── CASA ───────────────────────────────────────────────────────────────
lighthouse-casa-liga1:
	@echo "🏠 Lighthouse → CASA Philadelphia Liga 1 (Lighthouse Boys Club)..."
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 1" $(MAKE) scrape-casa-standings
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 1" $(MAKE) scrape-casa-schedule
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 1" $(MAKE) scrape-casa-rosters
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 1" $(MAKE) parse-casa
	@$(MAKE) load-casa
	@echo "✓ lighthouse-casa-liga1 done"

lighthouse-casa-liga2:
	@echo "🏠 Lighthouse → CASA Philadelphia Liga 2 (Lighthouse Boys Club U23)..."
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 2" $(MAKE) scrape-casa-standings
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 2" $(MAKE) scrape-casa-schedule
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 2" $(MAKE) scrape-casa-rosters
	@LIGHTHOUSE_ONLY=1 LIGHTHOUSE_DIVISION="Philadelphia Liga 2" $(MAKE) parse-casa
	@$(MAKE) load-casa
	@echo "✓ lighthouse-casa-liga2 done"

lighthouse-casa: lighthouse-casa-liga1 lighthouse-casa-liga2
	@echo "✅ lighthouse-casa done (Liga 1 + Liga 2)"

# ── Root: full Lighthouse refresh ─────────────────────────────────────
lighthouse: lighthouse-apsl lighthouse-casa
	@echo ""
	@echo "🏆 lighthouse done (APSL + CASA Liga 1/2)"

# ============================================================
# Backup & Restore (pg_dump snapshots)
# ============================================================

backup:
	@mkdir -p backups
	@echo "💾 Backing up database..."
	@$(DB_EXEC) pg_dump -U footballhome_user footballhome > backups/backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "✓ Backup saved: $$(ls -t backups/backup-*.sql | head -1)"

# Refresh the canonical file used by scripts/dev/restore-mirror.sh
# (dev Cursor/local stacks). Run on production after `make backup`.
dev-mirror:
	@mkdir -p backups
	$(eval LATEST := $(shell ls -t backups/backup-*.sql 2>/dev/null | head -1))
	@if [ -z "$(LATEST)" ]; then echo "❌ No backup found. Run: make backup"; exit 1; fi
	@cp "$(LATEST)" backups/dev-mirror.sql
	@gzip -kf backups/dev-mirror.sql
	@echo "✓ Dev mirror: backups/dev-mirror.sql.gz (from $(LATEST))"
	@echo "  Copy that file to your Cursor/local stack (gitignored), or host it and set DEV_MIRROR_URL."

restore:
	$(eval BACKUP_FILE := $(or $(BACKUP),$(shell ls -t backups/backup-*.sql 2>/dev/null | head -1)))
	@if [ -z "$(BACKUP_FILE)" ]; then echo "❌ No backup found. Run: make backup"; exit 1; fi
	@echo "♻️  Restoring from $(BACKUP_FILE)..."
	@$(DB_EXEC) psql -U footballhome_user -d footballhome < $(BACKUP_FILE)
	@echo "✓ Restored from $(BACKUP_FILE)"

# Restore into the *dev* compose DB (drops public schema first). See docs/dev-environment.md.
restore-mirror:
	@./scripts/dev/restore-mirror.sh

# ── Per-developer stacks on the production host ───────────────────────
# Idempotent bootstrap (also ./setup.sh step `dev-slots` on Linux).
# Re-run after a server migrate to recreate every row in config/dev-slots.conf.
# PROD_ROOT defaults inside the scripts to /srv/footballhome when unset.
setup-dev-slots:
	@DEV_SLOTS="$(DEV_SLOTS)" DEV_SLOTS_OBTAIN_CERT="$(DEV_SLOTS_OBTAIN_CERT)" \
	  LE_EMAIL="$(LE_EMAIL)" PROD_ROOT="$(PROD_ROOT)" \
	  ./scripts/setup/setup-dev-slots.sh

setup-dev-slot:
	@test -n "$(DEV)" || (echo "Usage: make setup-dev-slot DEV=jbreslin"; exit 1)
	@DEV_SLOTS_OBTAIN_CERT="$(DEV_SLOTS_OBTAIN_CERT)" LE_EMAIL="$(LE_EMAIL)" \
	  PROD_ROOT="$(PROD_ROOT)" \
	  ./scripts/setup/setup-dev-slot.sh $(DEV)

setup-dev-jbreslin:
	@DEV_SLOTS_OBTAIN_CERT="$(DEV_SLOTS_OBTAIN_CERT)" LE_EMAIL="$(LE_EMAIL)" \
	  PROD_ROOT="$(PROD_ROOT)" \
	  ./scripts/setup/setup-dev-jbreslin.sh

setup-dev-lbreslin:
	@DEV_SLOTS_OBTAIN_CERT="$(DEV_SLOTS_OBTAIN_CERT)" LE_EMAIL="$(LE_EMAIL)" \
	  PROD_ROOT="$(PROD_ROOT)" \
	  ./scripts/setup/setup-dev-lbreslin.sh

# Requires DEV=<slug> matching a row in config/dev-slots.conf
dev-init:
	@test -n "$(DEV)" || (echo "Usage: make dev-init DEV=jbreslin"; exit 1)
	@DEV=$(DEV) ./scripts/dev/dev-init.sh

dev-up:
	@test -n "$(DEV)" || (echo "Usage: make dev-up DEV=jbreslin"; exit 1)
	@DEV=$(DEV) ./scripts/dev/dev-up.sh

dev-down:
	@test -n "$(DEV)" || (echo "Usage: make dev-down DEV=jbreslin"; exit 1)
	@DEV=$(DEV) DEV_WIPE=$(DEV_WIPE) ./scripts/dev/dev-down.sh

dev-restore-mirror:
	@test -n "$(DEV)" || (echo "Usage: make dev-restore-mirror DEV=jbreslin"; exit 1)
	@DEV=$(DEV) ./scripts/dev/dev-restore-mirror.sh

dev-membership-sync:
	@test -n "$(DEV)" || (echo "Usage: make dev-membership-sync DEV=jbreslin"; exit 1)
	@DEV=$(DEV) ./scripts/dev/dev-membership-sync.sh

dev-nginx:
	@test -n "$(DEV)" || (echo "Usage: sudo make dev-nginx DEV=jbreslin"; exit 1)
	@DEV=$(DEV) ./scripts/dev/dev-nginx.sh

dev-ps:
	@test -n "$(DEV)" || (echo "Usage: make dev-ps DEV=jbreslin"; exit 1)
	@DEV=$(DEV) bash -c 'source scripts/dev/lib-dev-slot.sh && load_dev_slot "$$DEV" && cd "$$(pwd)" && dev_compose ps'

safe-rebuild: backup rebuild
	@echo "✓ Safe rebuild complete (backup in backups/)"
	@echo "  Run: make sync    (to re-sync league data)"
	@echo "  Or:  make restore (to restore from backup)"

# ============================================================
# Emergency Rebuild — full automated recovery in one command
# ============================================================
# Wipes containers + DB, then restores everything that matters:
#   1. Export user data (lineups + manual attendance) to SQL
#   2. pg_dump full backup (paranoia safety net)
#   3. clean + build (image build cached if no source changes)
#   4. Wait for DB ready
#   5. Load all league SQL (teams/players/schedule)
#   6. Re-load user data (lineups + attendance)
#
# Usage:  make er           # interactive (prompts before destroying)
#         make er FORCE=1   # no prompt, for true emergencies
emergency-rebuild er:
	@echo "🚨 Emergency rebuild starting..."
	@if [ -z "$(FORCE)" ]; then \
		printf "This wipes the DB. User data (lineups + manual attendance) will be exported and re-loaded. Continue? [y/N] "; \
		read ans; [ "$$ans" = "y" ] || [ "$$ans" = "Y" ] || { echo "Aborted."; exit 1; }; \
	fi
	@echo ""
	@echo "[1/6] Exporting user data (lineups + manual attendance)..."
	@$(MAKE) -s export-user-data || echo "  (skipped — DB not reachable)"
	@echo ""
	@echo "[2/6] Snapshot pg_dump backup..."
	@$(MAKE) -s backup || echo "  (skipped — DB not reachable)"
	@echo ""
	@echo "[3/6] Clean + build containers..."
	@$(MAKE) -s clean
	@$(MAKE) -s build
	@echo ""
	@echo "[4/6] Waiting for DB to be ready..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do \
		$(DB_EXEC) pg_isready -U footballhome_user -d footballhome >/dev/null 2>&1 && break; \
		sleep 2; \
	done
	@echo ""
	@echo "[5/6] Loading league SQL (teams/players/schedule)..."
	@$(MAKE) -s load
	@echo ""
	@echo "[6/6] Re-loading user data..."
	@$(MAKE) -s load-user-data || echo "  (no user data to load)"
	@echo ""
	@echo "✅ Emergency rebuild complete."
	@echo "   Frontend: http://localhost:3000"
	@echo "   Backend:  http://localhost:3001"
	@echo ""
	@echo "Optional next steps:"
	@echo "   make scrape         # refresh standings/results from web"

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
# Google OAuth / login health
#
# `make verify-google-login` is a smoke test for post-deploy sanity.
# Run it right after any deploy that touches env, the backend
# container, or the login page.  It answers ONE question:
# "Can a real user actually click Sign in with Google right now?"
#
# Exits 0 on success, non-zero if the config is broken.  Never
# prints the secret values themselves.
# ============================================================

verify-google-login:
	@echo "🔐 Google OAuth health check"
	@echo ""
	@echo "1) Startup env visible to backend:"
	@$(ENGINE) logs footballhome_backend 2>&1 \
	  | grep -E "OAuthController initialized|Client ID:|Client Secret:|Redirect URI:" \
	  | tail -4 \
	  || (echo "   ❌ backend has not logged OAuth init — is it running?" && exit 1)
	@echo ""
	@echo "2) /api/auth/google/status probe (what the login page sees):"
	@STATUS=$$(curl -sS http://localhost:3001/api/auth/google/status); \
	  echo "   $$STATUS"; \
	  case "$$STATUS" in \
	    *'"configured":true'*)  echo "   ✅ configured — Sign in with Google button will render" ;; \
	    *'"configured":false'*) echo "   ⚠️  NOT configured — button stays hidden (safe, no crash)"; echo "      → paste GOOGLE_OAUTH_CLIENT_ID / _SECRET into env, then: make restart" ;; \
	    *) echo "   ❌ unexpected response — check backend logs"; exit 1 ;; \
	  esac
	@echo ""
	@echo "3) /api/auth/google/login redirect target:"
	@LOC=$$(curl -sS -D - -o /dev/null http://localhost:3001/api/auth/google/login | awk '/^[Ll]ocation:/{print $$2}' | tr -d '\r'); \
	  if [ -n "$$LOC" ]; then \
	    echo "   ✅ 302 → $$(echo $$LOC | cut -c1-80)..."; \
	  else \
	    CODE=$$(curl -sS -o /dev/null -w "%{http_code}" http://localhost:3001/api/auth/google/login); \
	    echo "   ⚠️  HTTP $$CODE (expected 302).  Fine while unconfigured; fix before go-live."; \
	  fi
	@echo ""
	@echo "Done."

.PHONY: verify-google-login

# ============================================================
# ENV BACKUP / RESTORE (age passphrase encryption)
# ============================================================
# `env` holds every runtime secret (GOOGLE_OAUTH_*, JWT_SECRET,
# META_ADS_TOKEN, LEAGUEAPPS_*, ...) and is gitignored on purpose.
# `env.age` is the encrypted mirror we CAN commit / copy off-machine.
#
#   make backup-env    prompts twice for a passphrase, writes env.age
#   make restore-env   prompts once for the passphrase, writes env
#
# Never edits `env` in place — writes to a `.new` sibling and moves
# atomically only if age succeeds, so a bad passphrase or Ctrl-C
# can't leave you with a truncated file.
# ============================================================

backup-env:
	@if [ ! -f env ]; then echo "❌ env not found in $$(pwd)"; exit 1; fi
	@command -v age >/dev/null 2>&1 || { echo "❌ 'age' not installed. Try: sudo apt install age"; exit 1; }
	@echo "🔒 Encrypting env → env.age (you'll be prompted for a passphrase twice)"
	@age -p -o env.age.new env
	@mv env.age.new env.age
	@echo "✅ env.age refreshed ($$(stat -c%s env.age) bytes, contains all current secrets)"
	@echo "   Safe to copy to another machine or a USB drive."

restore-env:
	@if [ ! -f env.age ]; then echo "❌ env.age not found in $$(pwd)"; exit 1; fi
	@command -v age >/dev/null 2>&1 || { echo "❌ 'age' not installed. Try: sudo apt install age"; exit 1; }
	@if [ -f env ]; then \
	  echo "⚠️  env already exists — backing up to env.backup.$$(date +%s) before overwriting"; \
	  cp env env.backup.$$(date +%s); \
	fi
	@echo "🔓 Decrypting env.age → env (you'll be prompted for the passphrase)"
	@age -d -o env.new env.age
	@mv env.new env
	@chmod 600 env
	@echo "✅ env restored ($$(stat -c%s env) bytes). Restart the backend to pick up changes:"
	@echo "   make restart"

.PHONY: backup-env restore-env


# ============================================================
# VPN (WireGuard — for IP-blocked scraping)
#
# ALWAYS containerized. WireGuard runs inside an isolated podman
# network namespace; the host routing table is never modified, so
# SSH sessions stay alive. There is no host-VPN backend by design.
# ============================================================

scrape-vpn-up:
	@scripts/scrape-vpn.sh up

scrape-vpn-down:
	@scripts/scrape-vpn.sh down

scrape-vpn-status:
	@scripts/scrape-vpn.sh status

scrape-vpn-shell:
	@scripts/scrape-vpn.sh shell

scrape-vpn-logs:
	@scripts/scrape-vpn.sh logs

scrape-vpn-rebuild:
	@scripts/scrape-vpn.sh rebuild

# Friendly aliases
vpn-up:    scrape-vpn-up
vpn-down:  scrape-vpn-down
vpn-status: scrape-vpn-status

# ─────────────────────────────────────────────────────────────────────────
# Lighthouse history exhibit — Instagram poster campaign (20 posters).
# Generated 1-button-per-poster targets so the operator can fire any
# individual P# from the shell (mirrors the operator dashboard buttons).
# Each target skips the y/n confirm by passing --yes to the post script.
# ─────────────────────────────────────────────────────────────────────────

.PHONY: post-status post-next post-preview operator-server $(addprefix post-,1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) $(addprefix preview-,1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# Status — read-only summary of which P# have been posted.
post-status:
	@node scripts/social/post-to-instagram.js exhibit-status

# Next — post the lowest-numbered unposted poster (cron uses this).
post-next:
	@node scripts/social/post-to-instagram.js exhibit-next --yes

# Per-poster post targets (post-1 .. post-20). Skips the y/n confirm.
post-1:  ; @node scripts/social/post-to-instagram.js exhibit 1  --yes
post-2:  ; @node scripts/social/post-to-instagram.js exhibit 2  --yes
post-3:  ; @node scripts/social/post-to-instagram.js exhibit 3  --yes
post-4:  ; @node scripts/social/post-to-instagram.js exhibit 4  --yes
post-5:  ; @node scripts/social/post-to-instagram.js exhibit 5  --yes
post-6:  ; @node scripts/social/post-to-instagram.js exhibit 6  --yes
post-7:  ; @node scripts/social/post-to-instagram.js exhibit 7  --yes
post-8:  ; @node scripts/social/post-to-instagram.js exhibit 8  --yes
post-9:  ; @node scripts/social/post-to-instagram.js exhibit 9  --yes
post-10: ; @node scripts/social/post-to-instagram.js exhibit 10 --yes
post-11: ; @node scripts/social/post-to-instagram.js exhibit 11 --yes
post-12: ; @node scripts/social/post-to-instagram.js exhibit 12 --yes
post-13: ; @node scripts/social/post-to-instagram.js exhibit 13 --yes
post-14: ; @node scripts/social/post-to-instagram.js exhibit 14 --yes
post-15: ; @node scripts/social/post-to-instagram.js exhibit 15 --yes
post-16: ; @node scripts/social/post-to-instagram.js exhibit 16 --yes
post-17: ; @node scripts/social/post-to-instagram.js exhibit 17 --yes
post-18: ; @node scripts/social/post-to-instagram.js exhibit 18 --yes
post-19: ; @node scripts/social/post-to-instagram.js exhibit 19 --yes
post-20: ; @node scripts/social/post-to-instagram.js exhibit 20 --yes

# Per-poster preview targets (preview-1 .. preview-20). Render + show only;
# never posts. Useful for "look at slide N before clicking post-N".
preview-1:  ; @node scripts/social/post-to-instagram.js exhibit 1  preview
preview-2:  ; @node scripts/social/post-to-instagram.js exhibit 2  preview
preview-3:  ; @node scripts/social/post-to-instagram.js exhibit 3  preview
preview-4:  ; @node scripts/social/post-to-instagram.js exhibit 4  preview
preview-5:  ; @node scripts/social/post-to-instagram.js exhibit 5  preview
preview-6:  ; @node scripts/social/post-to-instagram.js exhibit 6  preview
preview-7:  ; @node scripts/social/post-to-instagram.js exhibit 7  preview
preview-8:  ; @node scripts/social/post-to-instagram.js exhibit 8  preview
preview-9:  ; @node scripts/social/post-to-instagram.js exhibit 9  preview
preview-10: ; @node scripts/social/post-to-instagram.js exhibit 10 preview
preview-11: ; @node scripts/social/post-to-instagram.js exhibit 11 preview
preview-12: ; @node scripts/social/post-to-instagram.js exhibit 12 preview
preview-13: ; @node scripts/social/post-to-instagram.js exhibit 13 preview
preview-14: ; @node scripts/social/post-to-instagram.js exhibit 14 preview
preview-15: ; @node scripts/social/post-to-instagram.js exhibit 15 preview
preview-16: ; @node scripts/social/post-to-instagram.js exhibit 16 preview
preview-17: ; @node scripts/social/post-to-instagram.js exhibit 17 preview
preview-18: ; @node scripts/social/post-to-instagram.js exhibit 18 preview
preview-19: ; @node scripts/social/post-to-instagram.js exhibit 19 preview
preview-20: ; @node scripts/social/post-to-instagram.js exhibit 20 preview

# Operator dashboard — starts a local-only HTTP server on 127.0.0.1:3010
# that serves the 20-button dashboard at http://localhost:3010/.
operator-server:
	@node scripts/operator-server.js

# ─────────────────────────────────────────────────────────────────────────
# Exhibit print export — generate Fireball-ready PDF + hi-res PNG per
# poster, plus a download page (frontend/exhibit/print.html) the print
# shop can use to grab whatever format they need.
# ─────────────────────────────────────────────────────────────────────────
.PHONY: print-export print-export-pdf print-export-png print-clean

# Full export — all kinds (PDF + hi-res PNG + preview PNG) for every poster.
print-export:
	@node scripts/export-exhibit-print.js

# PDF only (fast — for quick re-export after a copy change).
print-export-pdf:
	@node scripts/export-exhibit-print.js --kinds=pdf

# PNG only (hi-res + preview).
print-export-png:
	@node scripts/export-exhibit-print.js --kinds=hires,preview

# Wipe generated print files.
print-clean:
	@rm -rf frontend/exhibit/print && echo "Removed frontend/exhibit/print/"
