#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Parse and Curate SQL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e
cd "$(dirname "$0")"

echo "📄 Parsing CASA JSON and generating SQL..."

# Generate SQL from JSON (no database needed)
node generate-sql.js

# Curate SQL (merge with APSL + CSL)
echo ""
echo "🔍 Curating CASA SQL (matching with APSL + CSL)..."
node curate-sql.js

echo ""
echo "✓ CASA SQL files curated in sql/"
echo ""
echo "Next steps:"
echo "  1. Review curated SQL files in sql/"
echo "  2. Run: ./load.sh"
