#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Scrape HTML from Web
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Fetches the APSL standings page using real Chrome (--dump-dom).
# Only fetches 1 page — the standings page that generate-sql.js needs.
# Team pages are NOT fetched here (fetch individually when needed for rosters).
#
# Uses your installed Chrome binary to avoid bot detection (identical TLS
# fingerprint to normal browsing). Puppeteer's bundled Chromium gets 403'd.
#
# Usage:
#   ./scrape.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
  echo "❌ Chrome not found. Install Google Chrome or update path in scrape.sh"
  exit 1
fi

CACHE_DIR="database/scraped-html/apsl"
URL="https://www.apslsoccer.com/Standings"
# Hash must match HtmlFetcher.getCacheFilename(URL) — standings-ffc8b689.html
OUTPUT="$CACHE_DIR/standings-ffc8b689.html"

# Back up existing file
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
echo "✓ APSL HTML saved to $CACHE_DIR/"
