#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parses cached HTML and generates SQL files (orgs, clubs, teams, curation).
# Requires database with bootstrap data (run make bootstrap first).
#
# Creates:
#   sql/100.00001-organizations-usa-apsl.sql
#   sql/101.00001-clubs-usa-apsl.sql
#   sql/102.00001-teams-usa-apsl.sql
#   sql/900.00001-curation-usa-apsl.sql
#
# Usage:
#   ./parse.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Get to project root
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing APSL HTML..."

# Parse HTML → populate database
export SCRAPE_MODE=parse
export SCRAPE_USE_CACHE=true
node database/scripts/scrapers/ApslStructureScraper.js

# Export database → SQL files
echo "  Exporting to SQL..."
cd database/scripts
EXPORT_LEAGUE=usa-apsl EXPORT_LEAGUE_ID=00001 EXPORT_OUTPUT_DIR=../scripts/leagues/usa-apsl/sql node export-correct-structure.js

echo "✓ APSL SQL files generated in database/scripts/leagues/usa-apsl/sql/"
