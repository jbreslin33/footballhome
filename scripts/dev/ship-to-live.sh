#!/usr/bin/env bash
# Print the canonical "merged to main → live site" checklist.
# Safe to run anywhere — it does not mutate production by itself.
set -euo pipefail

cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Football Home — ship merged main → live server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Prereq: PR merged into GitHub `main`.

On the PRODUCTION host (/srv/footballhome):

  cd /srv/footballhome
  git fetch origin main
  git checkout main
  git pull origin main

  # If database/migrations/* changed:
  sudo make migrate

  # If backend/ C++ changed:
  sudo make deploy

  # Frontend-only (js/html/css): pull is usually enough (bind mount).
  # Hard-refresh the browser.

  sudo make ps
  # Smoke: https://footballhome.org → Membership → Sync now

Optional — refresh the shared dev DB mirror for other coders:

  sudo make backup
  sudo make dev-mirror
  # share backups/dev-mirror.sql.gz or update DEV_MIRROR_URL

Docs: docs/dev-environment.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
