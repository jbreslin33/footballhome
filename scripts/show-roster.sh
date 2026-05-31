#!/bin/bash

set -euo pipefail

CONTAINER="${DB_CONTAINER:-footballhome_db}"
DB_USER="${DB_USER:-footballhome_user}"
DB_NAME="${DB_NAME:-footballhome}"
TEAM_QUERY="${*:-Lighthouse Boys Club U23}"
TEAM_QUERY_SQL="${TEAM_QUERY//\'/\'\'}"

run_psql() {
  podman exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" "$@"
}

if ! podman ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "ERROR: container '$CONTAINER' is not running."
  exit 1
fi

echo "Searching teams matching: $TEAM_QUERY"

TEAM_ROWS="$(run_psql -t -A -F '|' -v ON_ERROR_STOP=1 -c "
  SELECT t.id, t.name
  FROM teams t
  WHERE t.name ILIKE '%${TEAM_QUERY_SQL}%'
  ORDER BY t.id;
")"

if [ -z "${TEAM_ROWS//[[:space:]]/}" ]; then
  echo "No teams matched '$TEAM_QUERY'."
  exit 0
fi

echo
while IFS='|' read -r TEAM_ID TEAM_NAME; do
  [ -z "$TEAM_ID" ] && continue

  COUNT="$(run_psql -t -A -v ON_ERROR_STOP=1 -c "
    SELECT COUNT(*)
    FROM rosters r
    WHERE r.team_id = ${TEAM_ID};
  " | tr -d '[:space:]')"

  echo "Team: $TEAM_NAME (id=$TEAM_ID)"
  echo "Roster count: $COUNT"

  if [ "$COUNT" = "0" ]; then
    echo "Players: (none)"
    echo
    continue
  fi

  run_psql -t -A -v ON_ERROR_STOP=1 -c "
    SELECT COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '') AS name
    FROM rosters r
    JOIN players pl ON pl.id = r.player_id
    JOIN persons p ON p.id = pl.person_id
    WHERE r.team_id = ${TEAM_ID}
    ORDER BY LOWER(COALESCE(p.first_name, '')), LOWER(COALESCE(p.last_name, ''));
  "

  echo
done <<< "$TEAM_ROWS"
