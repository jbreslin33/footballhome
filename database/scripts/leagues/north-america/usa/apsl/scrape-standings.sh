#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape Standings Page
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches the APSL standings page using real Chrome (--dump-dom).
# One page, one request. Very safe.
#
# Usage:
#   ./scrape-standings.sh                  # Skip if cache < 7 days old
#   FORCE_SCRAPE=1 ./scrape-standings.sh   # Force re-fetch
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

CACHE_DIR="database/scraped-html/apsl"
URL="https://www.apslsoccer.com/Standings"
# Hash must match HtmlFetcher.getCacheFilename(URL) — standings-ffc8b689.html
OUTPUT="$CACHE_DIR/standings-ffc8b689.html"
CACHE_MAX_AGE_DAYS=7

# ── Weekly cache freshness check ──────────────────────────────────────
if [ -f "$OUTPUT" ] && [ "${FORCE_SCRAPE:-0}" != "1" ]; then
  FILE_AGE_SECONDS=$(( $(date +%s) - $(stat -c %Y "$OUTPUT" 2>/dev/null || echo 0) ))
  FILE_AGE_DAYS=$(( FILE_AGE_SECONDS / 86400 ))
  if [ "$FILE_AGE_DAYS" -lt "$CACHE_MAX_AGE_DAYS" ]; then
    echo "📂 APSL standings cache is fresh (${FILE_AGE_DAYS}d old, limit ${CACHE_MAX_AGE_DAYS}d) — skipping"
    echo "   To force: FORCE_SCRAPE=1 make scrape-apsl-standings"
    exit 0
  fi
  echo "📅 APSL standings cache is ${FILE_AGE_DAYS}d old (limit ${CACHE_MAX_AGE_DAYS}d) — will re-fetch"
fi

# ── Detect Chrome binary (cross-platform) ────────────────────────────
if [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v google-chrome-stable &> /dev/null; then
  CHROME="google-chrome-stable"
elif command -v google-chrome &> /dev/null; then
  CHROME="google-chrome"
else
  echo "❌ Chrome not found. Run ./setup.sh to install, or install Google Chrome manually."
  exit 1
fi

# ── Fetch ─────────────────────────────────────────────────────────────
mkdir -p "$CACHE_DIR/.backup"
if [ -f "$OUTPUT" ]; then
  cp "$OUTPUT" "$CACHE_DIR/.backup/"
fi

echo "🌐 Fetching APSL standings..."
echo "   URL: $URL"

HTML=$("$CHROME" --headless=new --dump-dom --disable-gpu --no-sandbox "$URL" 2>/dev/null) || true

# Validate: reject 403 error pages
if echo "$HTML" | grep -q '403 - Forbidden'; then
  echo "   ⚠️  Got 403 — restoring backup"
  cp "$CACHE_DIR/.backup/"*.html "$CACHE_DIR/" 2>/dev/null || true
  rm -rf "$CACHE_DIR/.backup"
  echo "   ✓ Using previous cached HTML"
  exit 0
fi

# Validate: check for real content
LEN=${#HTML}
if [ "$LEN" -lt 5000 ]; then
  echo "   ⚠️  Response too small ($LEN bytes) — restoring backup"
  cp "$CACHE_DIR/.backup/"*.html "$CACHE_DIR/" 2>/dev/null || true
  rm -rf "$CACHE_DIR/.backup"
  echo "   ✓ Using previous cached HTML"
  exit 0
fi

# Save
mkdir -p "$CACHE_DIR"
echo "$HTML" > "$OUTPUT"
rm -rf "$CACHE_DIR/.backup"
SIZE_KB=$((LEN / 1024))
echo "   ✅ Saved: $OUTPUT (${SIZE_KB} KB)"
echo "✓ APSL standings scraped"
