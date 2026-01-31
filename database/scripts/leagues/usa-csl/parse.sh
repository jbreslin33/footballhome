#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Parse HTML and Generate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")/../../../.."

echo "📄 Parsing CSL HTML and generating SQL..."

# Parse HTML → Generate SQL (no database needed)
node database/scripts/leagues/usa-csl/generate-sql.js

echo "✓ CSL SQL files generated in database/scripts/leagues/usa-csl/sql/"
echo ""
echo "Next steps:"
echo "  1. Review SQL files in sql/"
echo "  2. Manually curate (merge duplicates with APSL clubs)"
echo "  3. Run: ./load.sh"
