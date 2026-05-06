#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape DOBs from authenticated team roster pages
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Logs in to app.teampass.com and scrapes DOBs for Lighthouse players.
# Requires VPN (apslsoccer.com / app.teampass.com block our IP).
# Credentials loaded from apsl-credentials.conf (decrypt with setup.sh).
#
# Usage:
#   ./scrape-dobs.sh           # VPN auto-connects
#   NO_VPN=1 ./scrape-dobs.sh  # Skip VPN (for local testing)
#   VPN_ACTIVE=1 ./scrape-dobs.sh  # Called from parent (VPN already up)
#
# After running, load DOBs into DB:
#   node database/scripts/scrapers/ApslDobScraper.js --load
#   (or run make apsl-load-dobs)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

# ── VPN ───────────────────────────────────────────────────────────────
if [ "${VPN_ACTIVE:-0}" != "1" ] && [ "${NO_VPN:-0}" != "1" ]; then
  exec "$PROJECT_ROOT/scripts/vpn-wrap.sh" env VPN_ACTIVE=1 "$SCRIPT_DIR/$(basename "$0")" "$@"
fi

# ── Ensure credentials are decrypted ──────────────────────────────────
if [ ! -f "$PROJECT_ROOT/apsl-credentials.conf" ]; then
  echo "❌  apsl-credentials.conf not found — run setup.sh to decrypt apsl-credentials.conf.age"
  exit 1
fi

echo "🔐 Scraping APSL DOBs (authenticated)..."
node database/scripts/scrapers/ApslDobScraper.js "$@"
