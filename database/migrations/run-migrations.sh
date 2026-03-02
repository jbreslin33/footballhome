#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Forward-Only Migration Runner
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Applies unapplied SQL migrations in order.
# Tracks applied migrations in schema_migrations table.
# Safe to re-run — skips already-applied migrations.
#
# Usage:
#   make migrate              (via Makefile)
#   ./database/migrations/run-migrations.sh   (direct)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect container engine
ENGINE=$(command -v podman 2>/dev/null || command -v docker 2>/dev/null)
DB_EXEC="$ENGINE exec -i footballhome_db"

# Ensure schema_migrations table exists (for DBs created before this feature)
$DB_EXEC psql -U footballhome_user -d footballhome -q <<'SQL'
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
SQL

echo "📋 Checking migrations..."

APPLIED=0
SKIPPED=0

for migration in "$SCRIPT_DIR"/[0-9]*.sql; do
    [ -f "$migration" ] || continue
    filename=$(basename "$migration")

    # Check if already applied
    already_applied=$($DB_EXEC psql -U footballhome_user -d footballhome -tAc \
        "SELECT 1 FROM schema_migrations WHERE filename = '$filename';" 2>/dev/null)

    if [ "$already_applied" = "1" ]; then
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    echo "   ▶ Applying: $filename"
    $DB_EXEC psql -U footballhome_user -d footballhome < "$migration"

    # Record migration
    $DB_EXEC psql -U footballhome_user -d footballhome -q -c \
        "INSERT INTO schema_migrations (filename) VALUES ('$filename');"

    APPLIED=$((APPLIED + 1))
done

if [ $APPLIED -eq 0 ]; then
    echo "✓ No new migrations (${SKIPPED} already applied)"
else
    echo "✓ Applied ${APPLIED} migration(s) (${SKIPPED} skipped)"
fi
