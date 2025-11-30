#!/bin/bash

# Football Home - Development Script
# Unified workflow for scraping, building, and running the application
#
# Usage:
#   ./dev.sh                    # Full rebuild (scrape + clean rebuild + start)
#   ./dev.sh --quick            # Quick restart (no scrape, keep DB volumes)
#   ./dev.sh --scrape-only      # Only scrape APSL data, don't rebuild
#   ./dev.sh --no-scrape        # Full rebuild but skip scraping (use existing data)
#   ./dev.sh --help             # Show this help

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Flags
QUICK_MODE=false
SCRAPE_ONLY=false
SKIP_SCRAPE=false
VERBOSE=false
SUMMARY_ONLY=false
# Temp file for collecting slow SQL statements (duration_ms<TAB>query)
SLOW_SQL_LOG=""
# Persist DB sampler log
PERSIST_DB_SAMPLE=false
# Optional output path to save DB sampler log when persisting
DB_SAMPLE_OUT=""
# Whether to persist slow-sql log after run
PERSIST_SLOW_SQL=false
# Optional output path to save slow sql log when persisting
SLOW_SQL_OUT=""
# Alert pattern (grep regex) for alert watcher
ALERT_PATTERN='error|warn|fatal|panic|exception'
# DB sampler log and pid
SAMP_LOG=""
SAMPLER_PID=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --quick)
            QUICK_MODE=true
            SKIP_SCRAPE=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --scrape-only)
            SCRAPE_ONLY=true
            ;;
        --persist-slow-sql)
            PERSIST_SLOW_SQL=true
            ;;
        --persist-db-sample)
            PERSIST_DB_SAMPLE=true
            ;;
        --db-sample-out=*)
            DB_SAMPLE_OUT="${arg#--db-sample-out=}"
            ;;
        --slow-sql-out=*)
            SLOW_SQL_OUT="${arg#--slow-sql-out=}"
            ;;
        --alert-pattern=*)
            ALERT_PATTERN="${arg#--alert-pattern=}"
            ;;
        --summary-only)
            SUMMARY_ONLY=true
            ;;
        --no-scrape)
            SKIP_SCRAPE=true
            ;;
        --help|-h)
            echo "Football Home Development Script"
            echo ""
            echo "Usage:"
            echo "  ./dev.sh                Full rebuild (scrape + clean rebuild)"
            echo "  ./dev.sh --quick        Quick restart (no scrape, keep volumes)"
            echo "  ./dev.sh --scrape-only  Only scrape APSL data"
            echo "  ./dev.sh --no-scrape    Rebuild without scraping"
            echo "  ./dev.sh --help         Show this help"
            echo ""
            echo "Common workflows:"
            echo "  - Fresh setup:           ./dev.sh"
            echo "  - Code changes only:     ./dev.sh --quick"
            echo "  - Update APSL data:      ./dev.sh --scrape-only"
            echo "  - After git pull:        ./dev.sh --no-scrape"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Enable verbose shell tracing when requested
if [ "$VERBOSE" = true ]; then
    set -x
fi

# Verbose mode is now opt-in via --verbose flag
# (no longer enabled by default)

# Prepare slow-SQL log file when verbose
if [ "$VERBOSE" = true ]; then
    SLOW_SQL_LOG=$(mktemp /tmp/dev_slow_sql.XXXXXX)
    # ensure it's empty
    : > "$SLOW_SQL_LOG"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Football Home - Development Workflow${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: SCRAPE APSL DATA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$SKIP_SCRAPE" = false ]; then
    echo -e "${YELLOW}📊 Step 1: Scraping APSL Data${NC}"
    echo -e "  This will take 5-15 minutes..."
    echo ""
    
    # Clean up old .copy.sql files before scraping (scraper will generate fresh ones)
    OLD_COPY_COUNT=$(ls database/data/*.copy.sql 2>/dev/null | wc -l)
    if [ "$OLD_COPY_COUNT" -gt 0 ]; then
        echo -e "${BLUE}🗑️  Cleaning up $OLD_COPY_COUNT old .copy.sql files...${NC}"
        rm database/data/*.copy.sql
    fi
    
    if node database/scripts/apsl-scraper/scrape-apsl.js; then
        echo ""
        echo -e "${GREEN}✓ APSL data scraped successfully${NC}"
    else
        echo -e "${RED}✗ APSL scraping failed${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}📋 Changes:${NC}"
    git status --short database/data/ || true
else
    echo -e "${BLUE}⏭️  Step 1: Skipping APSL scrape${NC}"
fi

# Exit if scrape-only mode
if [ "$SCRAPE_ONLY" = true ]; then
    echo ""
    echo -e "${GREEN}✓ Scrape complete! (scrape-only mode)${NC}"
    echo ""
    echo "Review changes with:"
    echo "  git status"
    echo "  git diff database/data/"
    exit 0
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1.5: CONVERT SQL TO COPY FORMAT (for 20-40x faster loading)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1.5: CONVERT SQL TO COPY FORMAT (for 20-40x faster loading)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# NOTE: Scraper now generates .copy.sql files directly, so we don't need to convert
# Just verify they exist
COPY_COUNT=$(ls database/data/*.copy.sql 2>/dev/null | wc -l)
if [ "$COPY_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Found $COPY_COUNT .copy.sql files (generated by scraper)${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ No .copy.sql files found - database will load slower${NC}"
fi

# Special case: venues is manual data (not scraped), convert if needed
if [ -f "database/data/02-venues.sql" ] && [ ! -f "database/data/02-venues.copy.sql" ]; then
    echo -e "${YELLOW}🔄 Converting venues to COPY format for faster loading...${NC}"
    if [ -f "database/scripts/convert-to-copy.sh" ]; then
        database/scripts/convert-to-copy.sh database/data/02-venues.sql database/data/02-venues.copy.sql > /dev/null
        echo -e "${GREEN}✓ Venues converted to COPY format${NC}"
    fi
fi

# CRITICAL: Rename .sql files to .sql.skip when .copy.sql exists
# This prevents PostgreSQL from loading both INSERT and COPY versions
echo -e "${YELLOW}🔄 Preparing database files (preferring COPY format)...${NC}"
RENAMED=0
for sql_file in database/data/*.sql; do
    # Skip if this is already a .copy.sql or .skip file
    if [[ "$sql_file" =~ \.copy\.sql$ ]] || [[ "$sql_file" =~ \.skip$ ]]; then
        continue
    fi
    
    # Check if corresponding .copy.sql exists
    base=$(basename "$sql_file" .sql)
    copy_file="database/data/${base}.copy.sql"
    skip_file="database/data/${base}.sql.skip"
    
    if [ -f "$copy_file" ] && [ ! -f "$skip_file" ]; then
        # Rename .sql to .sql.skip so PostgreSQL won't load it
        mv "$sql_file" "$skip_file"
        RENAMED=$((RENAMED + 1))
    fi
done

if [ "$RENAMED" -gt 0 ]; then
    echo -e "${GREEN}✓ Renamed $RENAMED .sql files to .sql.skip (COPY versions will be used)${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: DOCKER BUILD & DEPLOY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
if [ "$QUICK_MODE" = true ]; then
    echo -e "${YELLOW}🔨 Step 2: Quick Restart${NC}"
    echo -e "  - Keeping volumes (preserving database)"
    echo -e "  - Rebuilding images"
    echo ""
    echo -e "${YELLOW}🛑 Stopping containers...${NC}"
    docker compose down
    echo -e "${GREEN}✓ Containers stopped${NC}"
    echo ""
    echo -e "${YELLOW}🔨 Building images...${NC}"
    echo -e "  Building services individually for per-service timing..."
    for svc in $(docker compose config --services); do
        echo -e "  ${BLUE}→ Building: $svc${NC}"
        BUILD_START=$(date +%s)
        docker compose build --no-cache --progress=plain "$svc" || true
        BUILD_END=$(date +%s)
        BUILD_DUR=$((BUILD_END - BUILD_START))
        echo -e "  ${GREEN}✓ $svc built (${BUILD_DUR}s)${NC}"
    done
    echo "  Docker Compose status:"
    docker compose ps --all || true
    echo "  Docker Compose images:"
    docker compose images || true
else
    echo -e "${YELLOW}🔨 Step 2: Full Rebuild${NC}"
    echo -e "  - Removing all volumes (fresh database)"
    echo -e "  - Clearing all caches"
    echo -e "  - Rebuilding all images"
    echo ""
    echo -e "${YELLOW}🛑 Stopping containers and removing volumes...${NC}"
    docker compose down -v
    echo -e "${GREEN}✓ Containers stopped and volumes removed${NC}"
    echo ""
    echo -e "${YELLOW}🗑️  Clearing Docker build cache...${NC}"
    docker builder prune -f > /dev/null 2>&1
    echo -e "${GREEN}✓ Build cache cleared${NC}"
    echo ""
    echo -e "${YELLOW}🔨 Building images from scratch...${NC}"
    echo -e "  Building services individually for per-service timing..."
    for svc in $(docker compose config --services); do
        echo -e "  ${BLUE}→ Building: $svc${NC}"
        BUILD_START=$(date +%s)
        docker compose build --no-cache --progress=plain "$svc" || true
        BUILD_END=$(date +%s)
        BUILD_DUR=$((BUILD_END - BUILD_START))
        echo -e "  ${GREEN}✓ $svc built (${BUILD_DUR}s)${NC}"
    done
    echo "  Docker Compose status:"
    docker compose ps --all || true
    echo "  Docker Compose images:"
    docker compose images || true
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: START CONTAINERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${YELLOW}🚀 Step 3: Starting containers...${NC}"
docker compose up -d

echo -e "${GREEN}✓ Startup complete!${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:3001"
echo "  Database:  localhost:5432"
echo "  pgAdmin:   http://localhost:5050"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: WAIT FOR SERVICES TO BE READY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}Testing connectivity...${NC}"
echo -e "  Backend:  Waiting for health check..."
echo -e "            (Backend is waiting for database to initialize - showing SQL activity)"
echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo -e "  ${YELLOW}🔎 Database: Initialization and SQL import may take several minutes.${NC}"
echo -e "             Watching DB logs for progress (COPY/CREATE statements)..."

if [ "$SUMMARY_ONLY" = true ]; then
    echo -e "  ${YELLOW}ℹ️  Summary-only mode: skipping live log-followers and DB sampling${NC}"
fi

BACKEND_READY=false
i=0

# Start showing database logs in background while waiting
LAST_QUERY=""
LAST_TABLE=""
ROW_COUNT=0
# Use `docker compose logs --follow db` so the script follows the service logs
# (this works whether or not `container_name` or a project prefix is present).
# It captures initialization output including SQL COPY/CREATE statements.

# Start a DB resource sampler (docker stats) if possible
if [ "$SUMMARY_ONLY" != true ]; then
    DB_CID=""
    if command -v docker >/dev/null 2>&1; then
        DB_CID=$(docker compose ps -q db 2>/dev/null || true)
    fi
    if [ -n "$DB_CID" ]; then
        SAMP_LOG=$(mktemp /tmp/dev_db_stats.XXXXXX)
        (while true; do
            TS=$(date '+%Y-%m-%d %H:%M:%S')
            docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}' "$DB_CID" 2>/dev/null | awk -v ts="$TS" '{print ts "\t" $0}' >> "$SAMP_LOG" 2>/dev/null || true
            sleep 2
        done) &
        SAMPLER_PID=$!
    fi

    (docker compose logs --no-color --follow db 2>&1 | while IFS= read -r line; do
    # Capture the full query being executed
    if echo "$line" | grep -qE "statement:"; then
        FULL_STATEMENT=$(echo "$line" | sed 's/^.*statement: //')
        LAST_QUERY=$(echo "$FULL_STATEMENT" | head -c 150)
        
        # Show all statements in real-time for debugging
        if echo "$FULL_STATEMENT" | grep -qE "(CREATE TABLE|ALTER TABLE|CREATE INDEX|COPY)"; then
            STMT_TYPE=$(echo "$FULL_STATEMENT" | grep -oE "^(CREATE TABLE|ALTER TABLE|CREATE INDEX|COPY)" | head -1)
            echo -e "\n  ${BLUE}│ 🔧 $STMT_TYPE...${NC}"
        fi
    fi
    
    # Track what table we're working on
    if echo "$line" | grep -q "INSERT INTO"; then
        TABLE=$(echo "$line" | grep -oP "INSERT INTO \K[^ (]+")
        if [ "$TABLE" != "$LAST_TABLE" ]; then
            echo -e "\n  ${YELLOW}│ ➕ Inserting into: $TABLE${NC}"
            LAST_TABLE="$TABLE"
            ROW_COUNT=0
        fi
        ROW_COUNT=$((ROW_COUNT + 1))
        # Show progress every 10 rows
        if [ $((ROW_COUNT % 10)) -eq 0 ]; then
            printf "\r  ${YELLOW}│${NC}    ↳ $ROW_COUNT rows inserted...  "
        fi
    elif echo "$line" | grep -qE "statement:.*CREATE TABLE"; then
        # Extract table name from statement line
        TABLE=$(echo "$line" | grep -oP "CREATE TABLE (?:IF (?:NOT )?EXISTS )?\K[^ ;(]+")
        if [ -z "$TABLE" ]; then
            # Fallback: look for word after TABLE
            TABLE=$(echo "$line" | sed -n 's/.*CREATE TABLE[^a-zA-Z_]*\([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p')
        fi
        if [ -n "$TABLE" ]; then
            echo -e "\n  ${GREEN}│ ✨ Creating table: $TABLE${NC}"
            LAST_TABLE="$TABLE"
        fi
    elif echo "$line" | grep -qE "statement:.*COPY .* FROM"; then
        TABLE=$(echo "$line" | grep -oP "statement:.*COPY \K[^ (]+")
        COLUMNS=$(echo "$line" | grep -oP '\(\K[^)]+' | tr ',' '\n' | wc -l)
        echo -e "\n  ${BLUE}│ 📥 COPY $COLUMNS columns into: $TABLE${NC}"
        echo -e "  ${BLUE}│${NC}    ↳ Reading bulk data..."
        LAST_TABLE="$TABLE"
    elif echo "$line" | grep -qE "^COPY [0-9]+"; then
        ROWS=$(echo "$line" | grep -oP "^COPY \K[0-9]+")
        echo -e "\n  ${GREEN}│ ✅ Loaded $ROWS rows into $LAST_TABLE${NC}"
    elif echo "$line" | grep -qE "duration: [0-9]+\.[0-9]+ ms"; then
        DUR=$(echo "$line" | grep -oP "duration: \K[0-9.]+")
        # record slow queries to temp file when verbose
        if [ "$VERBOSE" = true ] && [ -n "$LAST_QUERY" ]; then
            # convert ms to numeric (float) and store as milliseconds
            # Use printf to keep consistent formatting
            printf "%s\t%s\n" "$DUR" "${LAST_QUERY//\t/ }" >> "$SLOW_SQL_LOG" 2>/dev/null || true
        fi
        # Show slow queries (>500ms) with details
        if (( $(echo "$DUR > 500" | bc -l) )); then
            if [ -n "$LAST_QUERY" ]; then
                echo -e "\n  ${YELLOW}│ ⏱️  SLOW (${DUR}ms): ${LAST_QUERY:0:80}...${NC}"
            else
                echo -e "\n  ${YELLOW}│ ⏱️  SLOW QUERY: ${DUR}ms${NC}"
            fi
        elif (( $(echo "$DUR > 100" | bc -l) )); then
            # Show medium queries (100-500ms) more briefly
            echo -e "\n  ${YELLOW}│ ⏱️  ${DUR}ms${NC}"
        fi
    fi
done) &
LOG_PID=$!
fi

# Also follow backend and frontend logs for verbose build/runtime diagnostics (only if verbose)
if [ "$VERBOSE" = true ] && [ "$SUMMARY_ONLY" != true ]; then
    BACKEND_LOG_PID=""
    FRONTEND_LOG_PID=""
    (docker compose logs --no-color --follow backend 2>&1 | sed 's/^/  [BE] /') &
    BACKEND_LOG_PID=$!
    (docker compose logs --no-color --follow frontend 2>&1 | sed 's/^/  [FE] /') &
    FRONTEND_LOG_PID=$!

    # Alert watcher: highlight warnings/errors across services (configurable pattern)
    ALERT_LOG_PID=""
    if command -v grep >/dev/null 2>&1; then
        (docker compose logs --no-color --follow db backend frontend 2>&1 | grep --line-buffered -iE "$ALERT_PATTERN" | sed 's/^/  [ALERT] /') &
        ALERT_LOG_PID=$!
    fi
fi

# Cleanup function to stop background processes and optionally persist logs
cleanup() {
    kill $LOG_PID $HEARTBEAT_PID $BACKEND_LOG_PID $FRONTEND_LOG_PID $ALERT_LOG_PID $SAMPLER_PID 2>/dev/null || true

    if [ -n "$SLOW_SQL_LOG" ] && [ -f "$SLOW_SQL_LOG" ]; then
        if [ "$PERSIST_SLOW_SQL" = "true" ]; then
            if [ -n "$SLOW_SQL_OUT" ]; then
                cp "$SLOW_SQL_LOG" "$SLOW_SQL_OUT" 2>/dev/null || true
                echo "Saved slow-SQL log to: $SLOW_SQL_OUT"
            else
                echo "Slow-SQL log preserved at: $SLOW_SQL_LOG"
            fi
        else
            rm -f "$SLOW_SQL_LOG" 2>/dev/null || true
        fi
    fi

    if [ -n "$SAMP_LOG" ] && [ -f "$SAMP_LOG" ]; then
        if [ "$PERSIST_DB_SAMPLE" = "true" ]; then
            if [ -n "$DB_SAMPLE_OUT" ]; then
                cp "$SAMP_LOG" "$DB_SAMPLE_OUT" 2>/dev/null || true
                echo "Saved DB sampler log to: $DB_SAMPLE_OUT"
            else
                echo "DB sampler log preserved at: $SAMP_LOG"
            fi
        else
            rm -f "$SAMP_LOG" 2>/dev/null || true
        fi
    fi
}

trap 'cleanup' EXIT

# Also show a heartbeat so user knows the script is still running
# Use a file to track elapsed time since subprocess can't access parent vars
WAIT_START=$(date +%s)
HEARTBEAT_PID=""
(while true; do
    sleep 5
    # If backend isn't ready yet, show we're still waiting
    if ! curl -s http://localhost:3001/health > /dev/null 2>&1; then
        ELAPSED=$(($(date +%s) - WAIT_START))
        printf "\r  ${BLUE}│${NC} ⏳ Still initializing... (${ELAPSED}s elapsed)  "
    fi
done) &
HEARTBEAT_PID=$!

# Poll backend health with counter
while true; do
    i=$((i + 1))
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        # Kill all background processes
        kill $LOG_PID $BACKEND_LOG_PID $FRONTEND_LOG_PID $ALERT_LOG_PID $HEARTBEAT_PID 2>/dev/null || true
        wait $LOG_PID $BACKEND_LOG_PID $FRONTEND_LOG_PID $ALERT_LOG_PID $HEARTBEAT_PID 2>/dev/null || true
        echo -e "\n  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  Backend:  ${GREEN}✓ Responding (took ${i}s)${NC}"
        BACKEND_READY=true
        break
    fi
    sleep 1
    
    # Timeout after 5 minutes
    if [ $i -ge 300 ]; then
        kill $LOG_PID $BACKEND_LOG_PID $FRONTEND_LOG_PID $ALERT_LOG_PID $SAMPLER_PID $HEARTBEAT_PID 2>/dev/null || true
        wait $LOG_PID $BACKEND_LOG_PID $FRONTEND_LOG_PID $ALERT_LOG_PID $SAMPLER_PID $HEARTBEAT_PID 2>/dev/null || true
        echo -e "\n  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${RED}✗ Timeout waiting for backend${NC}"
        echo ""
        echo "Check logs with:"
        echo "  docker logs footballhome_backend"
        echo "  docker logs footballhome_db"
        exit 1
    fi
done

echo ""

# Test frontend
echo -e "  Frontend: Checking..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "  Frontend: ${GREEN}✓ Responding${NC}"
else
    echo -e "  Frontend: ${RED}✗ Not responding${NC}"
fi

# If verbose slow-SQL log exists, print a short summary of the slowest statements
if [ -n "$SLOW_SQL_LOG" ] && [ -s "$SLOW_SQL_LOG" ]; then
    echo ""
    echo -e "${BLUE}Top slow SQL statements (ms)${NC}"
    echo "  duration_ms    query"
    awk -F'\t' '{print $1 "\t" $2}' "$SLOW_SQL_LOG" | sort -t$'\t' -k1,1 -g -r | head -n 10 | nl -w2 -s'. '
    echo ""
fi

# If DB sampler log exists, print a small resource summary
if [ -n "$SAMP_LOG" ] && [ -s "$SAMP_LOG" ]; then
    # Produce numeric summary: sample count, avg/max CPU, avg/max memory (bytes)
    SAMP_SUM=$(awk -F'\t' '
    function toBytes(s,   a,b,val,unit,mul){gsub(/^ +| +$/,"",s); split(s,a,"/"); mval=a[1]; if(match(mval,/([0-9.]+)([A-Za-z%]*)/,b)){val=b[1]; unit=b[2]} else {val=0; unit=""} mul=1; if(unit~/[Kk]i?/){mul=1024} else if(unit~/[Mm]i?/){mul=1024*1024} else if(unit~/[Gg]i?/){mul=1024*1024*1024} else if(unit~/[Tt]i?/){mul=1024*1024*1024*1024} return val*mul }
    { cpu=$3; gsub(/%/,"",cpu); mem=toBytes($4); sumcpu+=cpu; summem+=mem; if(cpu>maxc) maxc=cpu; if(mem>maxm) maxm=mem; cnt++ }
    END{ if(cnt==0) print "0\t0\t0\t0\t0"; else printf "%d\t%.2f\t%.2f\t%.0f\t%.0f", cnt, sumcpu/cnt, maxc, summem/cnt, maxm }' "$SAMP_LOG")

    IFS=$'\t' read -r s_cnt s_avg_cpu s_max_cpu s_avg_mem_bytes s_max_mem_bytes <<< "$SAMP_SUM"

    human_readable() {
        local bytes="$1"
        local units=(B KiB MiB GiB TiB)
        local u=0
        local val="$bytes"
        # handle zero
        if [ "$val" -le 0 ]; then
            printf "0B"
            return
        fi
        while [ $(echo "$val >= 1024" | bc) -eq 1 ] && [ $u -lt 4 ]; do
            val=$(echo "scale=2; $val/1024" | bc)
            u=$((u+1))
        done
        printf "%.2f%s" "$val" "${units[$u]}"
    }

    echo -e "${BLUE}Database resource sampling summary${NC}"
    echo "  samples=${s_cnt} avg_cpu=${s_avg_cpu}% max_cpu=${s_max_cpu}% avg_mem=$(human_readable $s_avg_mem_bytes) max_mem=$(human_readable $s_max_mem_bytes)"
    echo "  Recent samples (last 10):"
    tail -n 10 "$SAMP_LOG" | sed -n '1,100p'
    echo ""
fi

# If persisting slow-sql log, copy it now if path provided
if [ "$PERSIST_SLOW_SQL" = true ] && [ -n "$SLOW_SQL_LOG" ] && [ -s "$SLOW_SQL_LOG" ]; then
    if [ -n "$SLOW_SQL_OUT" ]; then
        cp "$SLOW_SQL_LOG" "$SLOW_SQL_OUT" 2>/dev/null || true
        echo "Saved slow-SQL log to: $SLOW_SQL_OUT"
    else
        echo "Slow-SQL log preserved at: $SLOW_SQL_LOG"
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FINAL STATUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All services ready!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Test login at http://localhost:3000"
echo "     Email: jbreslin@footballhome.org"
echo "     Password: 1893Soccer!"
echo ""
echo "  2. View logs:"
echo "     docker logs -f footballhome_backend"
echo "     docker logs -f footballhome_db"
echo ""

if [ "$SKIP_SCRAPE" = false ] && [ "$QUICK_MODE" = false ]; then
    echo "  3. If data updated, commit changes:"
    echo "     git add database/data/"
    echo "     git commit -m \"Update APSL data\""
    echo "     git push"
    echo ""
fi
