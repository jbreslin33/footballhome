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
#   6. Players (105.00001)
#   7. Matches (106.00001)
#   8. Rosters (107.00001)
#   9. Event Players (108.00001)
#  10. Match Events (109.00001)
#  11. Curation (900.00001)
#
# Usage:
#   ./load.sh
#
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

echo "📥 Loading APSL SQL to database..."

# Load SQL files in order (including 107 rosters now that we use team name lookups)
for file in "$SQL_DIR"/100.* "$SQL_DIR"/101.* "$SQL_DIR"/102.* "$SQL_DIR"/103.* "$SQL_DIR"/104.* "$SQL_DIR"/105.* "$SQL_DIR"/106.* "$SQL_DIR"/107.* "$SQL_DIR"/108.* "$SQL_DIR"/109.* "$SQL_DIR"/900.*; do
    if [ -f "$file" ]; then
        echo "  Loading: $(basename "$file")"
        $DB_EXEC psql -U footballhome_user -d footballhome < "$file"
    fi
done

# Post-load: set team logos (teams must exist before this runs)
echo "  Setting APSL team logos..."
$DB_EXEC psql -U footballhome_user -d footballhome -c "
UPDATE teams SET logo_url = '/images/teams/logos/wc-predators.jpg' WHERE name = 'WC Predators' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/alloy-sc.jpg' WHERE name = 'Alloy Soccer Club' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/oaklyn-united.jpg' WHERE name = 'Oaklyn United FC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/real-central-nj.png' WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/philly-heritage.jpeg' WHERE name = 'Philadelphia Heritage SC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/vidas-united.jpg' WHERE name = 'Vidas United FC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/jersey-shore-boca.jpg' WHERE name = 'Jersey Shore Boca' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/gak.png' WHERE name = 'GAK' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/medford-strikers.png' WHERE name = 'Medford Strikers' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/sewell-old-boys.jpg' WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1;
"

# Post-load: assign coaches to APSL teams (teams must exist before this runs)
echo "  Assigning coaches to APSL teams..."
$DB_EXEC psql -U footballhome_user -d footballhome -c "
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT t.id, c.id, cr.id
FROM teams t
JOIN clubs cl ON t.club_id = cl.id
JOIN coaches c ON c.person_id = 1
JOIN coach_roles cr ON cr.name = 'head'
WHERE t.name = 'Lighthouse 1893 SC'
ON CONFLICT DO NOTHING;
"

echo "✓ APSL loaded"
