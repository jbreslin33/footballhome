#!/bin/bash
# Load user data SQL files into the database
# Run AFTER make sync (requires league data to be loaded)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_DATA_DIR="$SCRIPT_DIR/../user-data"
DB_CONTAINER="footballhome_db"

echo "📥 Loading user data..."

for sqlfile in "$USER_DATA_DIR"/*.sql; do
  [ -f "$sqlfile" ] || continue
  filename=$(basename "$sqlfile")
  echo "  Loading $filename..."
  podman exec -i "$DB_CONTAINER" psql -U footballhome_user -d footballhome < "$sqlfile" 2>&1 | grep -v "^INSERT" || true
done

echo "✓ User data loaded"
