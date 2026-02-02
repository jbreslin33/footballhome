#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APSL - Load SQL to Database
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Loads APSL SQL files into running database.
# Database must be running (use make bootstrap or make up).
#
# Loads in order:
#   1. Organizations (100.00001)
#   2. Clubs (101.00001)
#   3. Teams (102.00001)
#   4. Division Teams (103.00001)
#   5. Standings (104.00001)
#   6. Curation (900.00001)
#
# Usage:
#   ./load.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$SCRIPT_DIR/sql"

cd "$(dirname "$0")/../../../.."

echo "📥 Loading APSL SQL to database..."

# Load SQL files in order
for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/105.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        podman exec -i footballhome_db psql -U footballhome_user -d footballhome < "$file"
    fi
done

echo "✓ APSL loaded"
