#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASA - Load SQL to Database
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_DIR="$SCRIPT_DIR/sql"

# Find project root (look for Makefile)
PROJECT_ROOT="$SCRIPT_DIR"
while [ ! -f "$PROJECT_ROOT/Makefile" ] && [ "$PROJECT_ROOT" != "/" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
cd "$PROJECT_ROOT"

# Auto-detect container engine
if command -v podman-compose &> /dev/null; then
    DB_EXEC="podman exec -i footballhome_db"
elif command -v docker-compose &> /dev/null; then
    DB_EXEC="docker-compose --env-file env exec -T db"
else
    echo "Error: No container compose tool found"; exit 1
fi

echo "📥 Loading CASA SQL to database..."

# Load available files:
# - 100: Organizations
# - 101: Clubs
# - 102: Teams
# - 103: Division Teams
# - 104: Standings (from schedule HTML)
# - 105: Players (persons + players from roster XLSX)
# - 106: Matches
# - 107: Rosters (player-team assignments)
# - 900: Cleanup scripts

for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/105.* "$SQL_DIR"/106.* "$SQL_DIR"/107.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        $DB_EXEC psql -U footballhome_user -d footballhome < "$file"
    fi
done

# Post-load: set team logos (teams must exist before this runs)
echo "  Setting CASA team logos..."
$DB_EXEC psql -U footballhome_user -d footballhome -c "
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse Boys Club' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse Boys Club U23' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/oaklyn-united.jpg' WHERE name = 'Oaklyn United FC II' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia SC Select' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/sewell-old-boys.jpg' WHERE name = 'Sewell''s Old Boys' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/alloy-sc.jpg' WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2;
"

# Post-load: assign coaches to CASA teams (teams must exist before this runs)
echo "  Assigning coaches to CASA teams..."
$DB_EXEC psql -U footballhome_user -d footballhome -c "
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT t.id, c.id, cr.id
FROM teams t
JOIN coaches c ON c.person_id = 1
JOIN coach_roles cr ON cr.name = 'head'
WHERE t.name IN ('Lighthouse Boys Club', 'Lighthouse Boys Club U23')
ON CONFLICT DO NOTHING;
"

echo "✓ CASA loaded"
