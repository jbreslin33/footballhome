#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Parse HTML and Generate SQL
# Creates: 100-organizations, 101-clubs, 102-teams, 103-division-teams,
#          104-standings, 105-players, 900-curation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")"

echo "📄 Parsing CSL HTML and generating SQL..."

# Note: CSL parsing requires extra memory due to large number of files (677 teams)
NODE_OPTIONS="--max-old-space-size=16384" node generate-sql.js

echo ""
echo "🔍 Curating CSL SQL (matching with APSL)..."
node curate-sql.js

echo ""
echo "✓ CSL SQL files curated in sql/"
echo ""
echo "Next steps:"
echo "  1. Review curated SQL files in sql/"
echo "  2. Run: ./load.sh"
