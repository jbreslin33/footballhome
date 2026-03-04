#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Scrape HTML from Web
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

echo "🌐 Scraping CSL HTML from web..."

# Back up key HTML files before clearing cache
# This protects against 403 errors that would overwrite valid data
CACHE_DIR="database/scraped-html/csl"
BACKUP_DIR="$CACHE_DIR/.backup"
mkdir -p "$BACKUP_DIR"
if ls "$CACHE_DIR"/tables-*.html 1>/dev/null 2>&1; then
  cp "$CACHE_DIR"/tables-*.html "$BACKUP_DIR/"
  echo "   📦 Backed up standings HTML"
fi

# Clear old cached HTML to avoid mixing seasons
rm -f "$CACHE_DIR"/*.html

export SCRAPE_MODE=download
export SCRAPE_USE_CACHE=false
if node database/scripts/scrapers/CslStructureScraper.js; then
  # Verify the standings file has real data (not a 403 error page)
  TABLES_FILE=$(ls "$CACHE_DIR"/tables-*.html 2>/dev/null | head -1)
  if [ -n "$TABLES_FILE" ] && [ "$(wc -l < "$TABLES_FILE")" -gt 100 ]; then
    echo "✓ CSL HTML saved to $CACHE_DIR/"
    rm -rf "$BACKUP_DIR"
  else
    echo "⚠️  Scraped standings file looks invalid (too small or missing)"
    echo "   Restoring backup..."
    cp "$BACKUP_DIR"/*.html "$CACHE_DIR/" 2>/dev/null || true
    rm -rf "$BACKUP_DIR"
    echo "   ✓ Restored previous standings HTML"
  fi
else
  echo "⚠️  Scraper failed — restoring backup..."
  cp "$BACKUP_DIR"/*.html "$CACHE_DIR/" 2>/dev/null || true
  rm -rf "$BACKUP_DIR"
  echo "   ✓ Restored previous standings HTML"
fi
