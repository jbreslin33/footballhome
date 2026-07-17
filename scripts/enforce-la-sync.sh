#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# enforce-la-sync.sh
#
# Grep-lint that fails if any C++ file under backend/src/controllers or
# backend/src/models reads the LA membership state table
# (person_la_memberships) without a preceding LA-sync entry point in the
# SAME translation unit.
#
# person_la_memberships is the membership state cache — reading it must be
# preceded by LaProgramSync::run() (§ Membership Data Flow, STRICT rule).
# leagueapps_programs is the (mostly) static config table (program_id,
# category, variant, registration_url) — reads of that alone are fine,
# they're config lookups not membership checks, and the lint ignores them.
#
# What counts as a valid entry point (any of these tokens visible in the
# containing translation unit is enough):
#   laGet(  laPost(  laPut(  laDel(       — Controller.h route helpers
#   LaProgramSync::run(                    — direct sync (legacy/cron OK)
#   Controller::syncPrograms(              — parallel fan-out helper
#   Controller::allLaProgramIds(           — dynamic resolver used with la*()
#
# Any .cpp / .h that greps for person_la_memberships but does NOT contain
# at least one of the tokens above is flagged.
#
# Exit non-zero on first violation.  Prints violating file + line so the
# developer can jump to the offense.
#
# Wire into CI: append `bash scripts/enforce-la-sync.sh` to `make check`
# or a pre-commit hook.  Currently invoked manually.
#
# ─────────────────────────────────────────────────────────────────────────────
# Allowlist — files that legitimately reference person_la_memberships:
#
#   LaProgramSync   — the sync service itself (writes the table).
#   PersonLinker    — upserts rows during sync (called by LaProgramSync).
#   LaPool          — the pool model that owns the table's semantics.
#   Controller      — the base class where la*() helpers live (definitions
#                     reference the token in comments).
#   Team, PersonPayments
#                   — model-layer files that read person_la_memberships
#                     but do NOT self-sync.  Their public entry points
#                     are ALWAYS called from controller paths that route
#                     through laGet()/laPost()/LaProgramSync::run()
#                     (verified manually).  The lint can't do call-site
#                     dataflow, so we assert-by-listing here.  If you
#                     add a new public entry point on any of these
#                     models that reads person_la_memberships from a
#                     non-synced caller, you break the rule and this
#                     allowlist is a lie — remove the entry and migrate
#                     the caller.
#   MensRoster, BoysRoster, YouthRoster
#                   — as of the roster laGet(static) migration these
#                     models accept pre-synced recs as a parameter and
#                     no longer call LaProgramSync themselves.  All
#                     three of their public run() entry points are only
#                     invoked from:
#                       * MensRosterController::handleGet
#                         (laGet(static, {mens}))
#                       * BoysRosterController::handleGet
#                         (laGet(static, {boys, girls}))
#                       * YouthRosterController::handleGet
#                         (laGet(static, {boys, girls}))
#                       * LeadsController::handleAnalytics
#                         (laGet(dynamic, {mens, boys, girls}))
#                     So every caller pre-syncs.  Allowlisted for the
#                     same reason as Team/PersonPayments.
#
# NOT allowlisted (they must contain a valid entry-point token in the
# translation unit — the lint verifies this every run):
#   (none currently)
allowlist_regex='^(backend/src/services/LaProgramSync|backend/src/models/(PersonLinker|LaPool|Team|PersonPayments|MensRoster|BoysRoster|YouthRoster)|backend/src/core/Controller)'

set -euo pipefail

cd "$(dirname "$0")/.."

# 1. Find every controller/model file that reads person_la_memberships.
mapfile -t suspects < <(
  grep -RIl --include='*.cpp' --include='*.h' \
       -E 'person_la_memberships' \
       backend/src/controllers backend/src/models \
    | grep -Ev "$allowlist_regex"
)

violations=0
for f in "${suspects[@]}"; do
  # 2. Does the same file also contain a valid LA-sync entry point?
  if grep -Eq 'laGet\(|laPost\(|laPut\(|laDel\(|LaProgramSync::run\(|Controller::syncPrograms\(|Controller::allLaProgramIds\(' "$f"; then
    continue
  fi
  echo "❌ $f reads person_la_memberships but never routes through la*() / LaProgramSync::run()"
  grep -nE 'person_la_memberships' "$f" | sed 's/^/    /'
  violations=$((violations + 1))
done

if [[ $violations -gt 0 ]]; then
  echo ""
  echo "$violations file(s) violate the STRICT LA-membership rule."
  echo "See .github/copilot-instructions.md § Membership Data Flow"
  echo "and backend/src/core/Controller.h (laGet/laPost/laPut/laDel)."
  exit 1
fi

echo "✓ LA-sync enforcement: all ${#suspects[@]} LA-touching files route through la*() / LaProgramSync"
