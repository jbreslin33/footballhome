#!/usr/bin/env bash
#
# scripts/check_profile_write_policy.sh
#
# CI enforcement of DESIGN.md §22.14 (sim_player_profile write policy —
# first-touch INSERT only in M0).
#
# Rule: nothing outside ProfileStore.cpp is permitted to call `.save(`
# on what could plausibly be a ProfileStore instance. In M0, the only
# call site is ProfileStore::loadOrCreate's first-touch INSERT branch;
# every other write path is a bug (would either cause per-tick write
# amplification or break the §22.13 replay assumption that every DB
# profile row IS the M0 default byte-for-byte).
#
# This is a coarse grep — it flags any `.save(` call site across
# sim/src/. Rationale for accepting the coarseness (per §22.14):
#   (a) sim codebase today has no other `save` method on any type;
#   (b) if a legitimate unrelated save() appears later, add its path to
#       ALLOWLIST_FILES below with an in-file comment pointing to §22.14
#       so the exception is documented;
#   (c) parsing C++ to identify the receiver type is orders of magnitude
#       more machinery than the invariant warrants.
#
# When M3 concept-mastery lands and a legitimate match-end profile
# writer appears, supersede §22.14 with a new ADR and extend the
# ALLOWLIST_FILES list — do NOT silently disable this check.
#
# Design refs: DESIGN.md §14, §21.2 item 2, §22.13, §22.14.
#
# Exits 0 (clean) or 1 (violation). Prints violations to stderr.

set -euo pipefail

# SIM_ROOT = directory containing src/ and tests/ and scripts/.
SIM_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SIM_ROOT"

SCAN_DIRS=(
    "src"
)

# Files allowed to contain `.save(` call sites. Paths are relative to
# SIM_ROOT. Add to this list ONLY when a new call site is justified by a
# new/superseding ADR.
ALLOWLIST_FILES=(
    "src/persistence/ProfileStore.cpp"   # §22.14: sole M0 writer (first-touch INSERT inside loadOrCreate).
    "src/persistence/ProfileStore.hpp"   # method declaration (no call site).
)

fail=0

is_allowlisted() {
    local grep_line="$1"
    local path="${grep_line%%:*}"
    local allow
    for allow in "${ALLOWLIST_FILES[@]}"; do
        if [[ "$path" == "$allow" ]]; then
            return 0
        fi
    done
    return 1
}

raw=$(grep -RInE '\.save\(' \
        --include='*.cpp' --include='*.hpp' --include='*.h' \
        "${SCAN_DIRS[@]}" 2>/dev/null \
    | grep -vE ':\s*//' \
    | grep -vE '^[^:]+:[0-9]+:\s*\*' \
    || true)

if [[ -n "$raw" ]]; then
    hits=""
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        if is_allowlisted "$line"; then continue; fi
        hits+="${line}"$'\n'
    done <<< "$raw"
    if [[ -n "$hits" ]]; then
        echo "ERROR: .save( call outside allowlisted files — see DESIGN.md §22.14 (sim_player_profile write policy)" >&2
        printf '%s' "$hits" >&2
        fail=1
    fi
fi

if [[ $fail -eq 0 ]]; then
    echo "check_profile_write_policy.sh: OK"
fi
exit $fail
