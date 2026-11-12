#!/usr/bin/env bash
# scripts/pyramid-pipeline.sh [model…] — rebuild the #apsl-pyramid proposal
# maps, one centre model at a time (mig 1298: city · mean · dense).
#   scripts/pyramid-pipeline.sh            every model, the official one last
#   scripts/pyramid-pipeline.sh mean       just that one (then the official
#                                          one's points are restored)
# Per model: set policy centre_model → refresh → pyramid-county-drive.py →
# refresh → pyramid-fine-borders.py → pyramid-sea-borders.py (must print 0
# SHORT) → pyramid-drive-times.py → fh_pyramid_model_snapshot().
# Drive times are cached by point, so a rerun only fetches what moved.
# Always leaves policy centre_model = the official model and the live
# pyramid_region_points on it — clubs, feeders and outlier lines follow the
# official model only.
set -euo pipefail
cd "$(dirname "$0")/.."
PSQL=${PSQL:-"sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome"}
q() { $PSQL -At -v ON_ERROR_STOP=1 -c "$1" < /dev/null; }

official=$(q "SELECT code FROM pyramid_centre_models WHERE is_official")
if [ $# -eq 0 ]; then
  models=$(q "SELECT code FROM pyramid_centre_models ORDER BY is_official, sort_order")
else
  models="$*"
fi

restore() {
  q "UPDATE pyramid_territory_policy SET centre_model = '$official'" > /dev/null
  q "SELECT fh_pyramid_proposal_refresh()" > /dev/null
}
trap 'echo "!! failed — restoring the official model ($official)"; restore' ERR

for m in $models; do
  echo "===== model $m ($(date +%T))"
  q "UPDATE pyramid_territory_policy SET centre_model = '$m'" > /dev/null
  q "SELECT fh_pyramid_proposal_refresh()" > /dev/null
  echo "== county-drive"; python3 scripts/pyramid-county-drive.py < /dev/null
  q "SELECT fh_pyramid_proposal_refresh()" > /dev/null
  echo "== fine-borders"; python3 scripts/pyramid-fine-borders.py < /dev/null
  echo "== sea-borders"; python3 scripts/pyramid-sea-borders.py < /dev/null
  echo "== drive-times"; python3 scripts/pyramid-drive-times.py < /dev/null
  echo "== snapshot $(q "SELECT fh_pyramid_model_snapshot()")"
done

last=$(echo "$models" | tail -n1)
if [ "$last" != "$official" ]; then
  echo "== restoring official model $official"
  restore
fi
q "UPDATE pyramid_territory_policy SET centre_model = '$official'" > /dev/null
echo "===== done ($(date +%T))"
