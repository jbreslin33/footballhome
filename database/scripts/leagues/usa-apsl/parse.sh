#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Parses cached HTML and generates SQL files (orgs, clubs, teams, division_teams, standings, players, curation).
# Requires database with bootstrap data (run make bootstrap first).
#
# Creates:
#   sql/100.00001-organizations-usa-apsl.sql
#   sql/101.00001-clubs-usa-apsl.sql
#   sql/102.00001-teams-usa-apsl.sql
#   sql/103.00001-division-teams-usa-apsl.sql
#   sql/104.00001-standings-usa-apsl.sql
#   sql/105.00001-players-usa-apsl.sql
#   sql/900.00001-curation-usa-apsl.sql
#
# Usage:
#   ./parse.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Get to project root
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing APSL HTML and generating SQL..."

# Parse HTML → Generate SQL (no database needed)
node database/scripts/leagues/usa-apsl/generate-sql.js

echo "🔍 Curating APSL SQL (checking for pre-existing clubs)..."

# Curate SQL (match against other leagues if loaded first)
node database/scripts/leagues/usa-apsl/curate-sql.js

echo "✓ APSL SQL files curated and ready in database/scripts/leagues/usa-apsl/sql/"
