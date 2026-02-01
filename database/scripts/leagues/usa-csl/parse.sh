#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing CSL HTML and generating SQL..."

# Parse HTML → Generate SQL (no database needed)
node database/scripts/leagues/usa-csl/generate-sql.js

# Curate SQL (merge with APSL)
echo ""
echo "🔍 Curating CSL SQL (matching with APSL)..."
node database/scripts/leagues/usa-csl/curate-sql.js

echo ""
echo "✓ CSL SQL files curated in database/scripts/leagues/usa-csl/sql/"
echo ""
echo "Next steps:"
echo "  1. Review curated SQL files in sql/"
echo "  2. Run: ./load.sh"
