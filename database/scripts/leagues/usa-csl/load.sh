#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Load SQL to Database
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$SCRIPT_DIR/sql"

cd "$(dirname "$0")/../../../.."

echo "📥 Loading CSL SQL to database..."

# Load SQL files in order (including 107 rosters now that we use team name lookups)
for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/105.* "$SQL_DIR"/106.* "$SQL_DIR"/107.* "$SQL_DIR"/108.* "$SQL_DIR"/109.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        podman exec -i footballhome_db psql -U footballhome_user -d footballhome < "$file"
    fi
done

echo "✓ CSL loaded"
