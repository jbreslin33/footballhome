#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CSL - Load SQL to Database
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$SCRIPT_DIR/sql"

cd "$(dirname "$0")/../../../.."

echo "📥 Loading CSL SQL to database..."

# NOTE: Skipping 107.* (rosters) - team external_id mismatch between standings and HTML filenames
# The roster HTML files use different IDs (10041, etc) than the teams loaded from standings (6797, etc)
# This causes roster INSERT failures with NULL team_id. Fix requires matching by team name instead.
for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/105.* "$SQL_DIR"/106.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        podman exec -i footballhome_db psql -U footballhome_user -d footballhome < "$file"
    fi
done

echo "✓ CSL loaded"
