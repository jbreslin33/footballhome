#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape Team Pages (Rosters + Schedule)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches team detail pages from apslsoccer.com.
# Reads team IDs from cached standings HTML — no DB needed.
# Each team page contains both the roster and schedule.
#
# Usage:
#   ./scrape-teams.sh                  # Skip if cache < 7 days old
#   FORCE_SCRAPE=1 ./scrape-teams.sh   # Force re-fetch all team pages
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

FORCE_FLAG=""
if [ "${FORCE_SCRAPE:-0}" = "1" ]; then
  FORCE_FLAG="--force"
fi

node database/scripts/scrapers/scrape-team-pages.js --league apsl $FORCE_FLAG
