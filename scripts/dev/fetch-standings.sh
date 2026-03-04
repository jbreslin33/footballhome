#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Fetch Standings HTML using real Chrome (not Puppeteer)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Uses your actual installed Chrome browser to fetch HTML.
# This avoids bot detection because the TLS fingerprint is identical
# to normal browsing.
#
# Only fetches the 2 standings pages needed for generate-sql.js:
#   - APSL: https://www.apslsoccer.com/Standings/
#   - CSL:  https://www.cosmosoccerleague.com/CSL/Tables/
#
# Usage:
#   ./scripts/dev/fetch-standings.sh          # Fetch both
#   ./scripts/dev/fetch-standings.sh apsl     # APSL only
#   ./scripts/dev/fetch-standings.sh csl      # CSL only
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
  echo "❌ Chrome not found at: $CHROME"
  exit 1
fi

LEAGUE="${1:-all}"

fetch_page() {
  local url="$1"
  local output="$2"
  local label="$3"

  echo "🌐 Fetching $label..."
  echo "   URL: $url"

  # Use real Chrome --dump-dom (identical TLS fingerprint to normal browsing)
  local html
  html=$("$CHROME" --headless=new --dump-dom --disable-gpu --no-sandbox "$url" 2>/dev/null) || true

  # Validate: reject 403 error pages
  if echo "$html" | grep -q '403 - Forbidden'; then
    echo "   ❌ Got 403 Forbidden — IP may be blocked"
    echo "   Try switching to phone hotspot or VPN"
    return 1
  fi

  # Validate: check for actual content
  local len=${#html}
  if [ "$len" -lt 5000 ]; then
    echo "   ❌ Response too small ($len bytes) — likely blocked"
    return 1
  fi

  # Save to file
  mkdir -p "$(dirname "$output")"
  echo "$html" > "$output"
  local size_kb=$((len / 1024))
  echo "   ✅ Saved: $output (${size_kb} KB)"
  return 0
}

# APSL — URL without trailing slash produces hash ffc8b689
if [ "$LEAGUE" = "all" ] || [ "$LEAGUE" = "apsl" ]; then
  APSL_DIR="$PROJECT_ROOT/database/scraped-html/apsl"
  APSL_FILE="$APSL_DIR/standings-ffc8b689.html"
  fetch_page "https://www.apslsoccer.com/Standings" "$APSL_FILE" "APSL Standings"
  echo ""
fi

# CSL — URL with ?Table_Season=8022 produces hash 4ab2e129
if [ "$LEAGUE" = "all" ] || [ "$LEAGUE" = "csl" ]; then
  CSL_DIR="$PROJECT_ROOT/database/scraped-html/csl"
  CSL_FILE="$CSL_DIR/tables-4ab2e129.html"
  fetch_page "https://www.cosmosoccerleague.com/CSL/Tables/?Table_Season=8022" "$CSL_FILE" "CSL Standings"
  echo ""
fi

echo "✅ Done! Now run: make parse && make load"
