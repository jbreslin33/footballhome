#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Load SQL to Database
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$SCRIPT_DIR/sql"

cd "$(dirname "$0")/../../../.."

echo "📥 Loading CASA SQL to database..."

# Load available files:
# - 100: Organizations
# - 101: Clubs
# - 102: Teams
# - 103: Division Teams
# - 104: Standings (from schedule HTML)
# - [105: Players - Roster scraping needs fixing]
# - 900: Cleanup scripts

for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        podman exec -i footballhome_db psql -U footballhome_user -d footballhome < "$file"
    fi
done

echo "✓ CASA loaded"
