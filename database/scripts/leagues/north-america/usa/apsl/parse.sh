#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parses cached HTML and generates SQL files (orgs, clubs, teams, division_teams, standings, players, curation).
#
# Creates:
#   sql/100.00001-organizations-apsl.sql
#   sql/101.00001-clubs-apsl.sql
#   sql/102.00001-teams-apsl.sql
#   sql/103.00001-division-teams-apsl.sql
#   sql/104.00001-standings-apsl.sql
#   sql/105.00001-players-apsl.sql
#   sql/900.00001-curation-apsl.sql
#
# Usage:
#   ./parse.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")"

echo "📄 Parsing APSL HTML and generating SQL..."
node generate-sql.js

echo "🔍 Curating APSL SQL (checking for pre-existing clubs)..."
node curate-sql.js

echo "✓ APSL SQL files curated and ready in sql/"
