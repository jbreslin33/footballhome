#!/usr/bin/env bash
#
# scripts/check_no_hardcoded_attrs.sh
#
# CI enforcement: no `Fixed64::fromDouble(...)` calls anywhere in the sim
# source tree (sim/src/) EXCEPT the sanctioned baseline VALUES file
# (common/M0Attributes.cpp) and the Fixed64 primitive itself (math/Fixed64.*
# where the conversion is *defined*).
#
# Rationale: gameplay attribute values must come from PlayerProfile loaded
# from the DB (§16.6, §22.9). Baseline M0 defaults live in ONE place —
# M0Attributes.cpp — and are used by ProfileStore::loadOrCreate when a
# first-time profile is materialised. Any other `Fixed64::fromDouble` in
# gameplay code is a hard-coded balance number sneaking past the profile
# path.
#
# NOTE: `Fixed64::fromFloat(...)` is NOT banned — it's a wire-boundary
# primitive used by BinaryV1Serializer (decoding f32 INPUTs/SNAPSHOTs).
# Only human-authored balance constants (fromDouble) are the target.
#
# Design refs: DESIGN.md §16.6, §22.9, §22.11.
#
# Exits 0 (clean) or 1 (violation). Prints violations to stderr.

set -euo pipefail

# SIM_ROOT = directory containing src/ and tests/ and scripts/.
SIM_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SIM_ROOT"

SCAN_DIRS=(
    "src"
)

# Files allowed to call Fixed64::fromDouble. Paths are relative to SIM_ROOT.
ALLOWLIST_FILES=(
    "src/common/M0Attributes.cpp"   # §22.11: sole source of M0 baseline VALUES.
    "src/math/Fixed64.hpp"          # declaration of fromDouble
    "src/math/Fixed64.cpp"          # definition of fromDouble
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

check_pattern() {
    local label="$1"
    local pattern="$2"
    local raw
    raw=$(grep -RInE "$pattern" \
            --include='*.cpp' --include='*.hpp' --include='*.h' \
            "${SCAN_DIRS[@]}" 2>/dev/null \
        | grep -vE ':\s*//' \
        | grep -vE '^[^:]+:[0-9]+:\s*\*' \
        || true)
    if [[ -z "$raw" ]]; then
        return 0
    fi
    local hits=""
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        if is_allowlisted "$line"; then continue; fi
        hits+="${line}"$'\n'
    done <<< "$raw"
    if [[ -n "$hits" ]]; then
        echo "ERROR: $label" >&2
        printf '%s' "$hits" >&2
        fail=1
    fi
}

# --- Fixed64::fromDouble (human-authored balance constants) ---------------
check_pattern \
    "Fixed64::fromDouble outside M0Attributes.cpp / Fixed64.{hpp,cpp} — hard-coded gameplay balance leaked past the profile path" \
    'Fixed64::fromDouble\b'

if [[ $fail -eq 0 ]]; then
    echo "check_no_hardcoded_attrs.sh: OK"
fi
exit $fail
