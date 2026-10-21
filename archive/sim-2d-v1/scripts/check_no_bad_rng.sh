#!/usr/bin/env bash
#
# scripts/check_no_bad_rng.sh
#
# CI enforcement: no std::*_distribution, no std::random_device / rand /
# default_random_engine, and no direct std::mt19937 / std::mt19937_64
# outside the allowlisted RngDet.hpp — in the sim gameplay tree
# (sim/src/).
#
# Rationale: std::mt19937_64's raw operator() output IS spec-portable per
# C++ standard §26.5.4.4, but std::*_distribution implementations are NOT
# portable across libstdc++ / libc++ / MSVC — a well-known determinism
# footgun. RngDet (sim/src/math/RngDet.hpp) wraps the engine and exposes
# only portable operations (nextU64, nextUnit, nextInt via rejection).
#
# Design refs: DESIGN.md §10 rule 3, §21.1 (ship-blocker item 2), §22.10.
#
# Exits 0 (clean) or 1 (violation). Prints violations to stderr.

set -euo pipefail

# SIM_ROOT = directory containing src/ and tests/ and scripts/.
# Works whether invoked from workspace root on the host (SIM_ROOT=./sim)
# or from inside the sim container (SIM_ROOT=/src).
SIM_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SIM_ROOT"

# Directories audited for RNG hygiene.
SCAN_DIRS=(
    "src"
)

# File(s) allowed to touch <random> / std::mt19937_64. Any grep hit
# whose file path (relative to SIM_ROOT) matches this list is skipped.
ALLOWLIST_FILES=(
    "src/math/RngDet.hpp"
)

fail=0

# Return 0 if the given file path (as printed by grep, "path:line:...") is
# in the allowlist, 1 otherwise.
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

# Run a grep across SCAN_DIRS, filter out block-comment (` * ...`) and
# line-comment (`// ...`) lines, drop allowlisted files, then report any
# survivors on stderr and bump $fail.
check_pattern() {
    local label="$1"
    local pattern="$2"
    local hits
    local raw
    # -RIn = recursive, binary-skip, line numbers.
    # --include limits to C/C++ sources; -E enables ERE.
    raw=$(grep -RInE "$pattern" \
            --include='*.cpp' --include='*.hpp' --include='*.h' \
            "${SCAN_DIRS[@]}" 2>/dev/null \
        | grep -vE ':\s*//' \
        | grep -vE '^[^:]+:[0-9]+:\s*\*' \
        || true)
    if [[ -z "$raw" ]]; then
        return 0
    fi
    hits=""
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        if is_allowlisted "$line"; then continue; fi
        hits+="${line}"$'\n'
    done <<< "$raw"
    if [[ -n "$hits" ]]; then
        echo "ERROR: $label found in sim/src/:" >&2
        printf '%s' "$hits" >&2
        fail=1
    fi
}

# --- 1. No std::*_distribution anywhere in gameplay. -----------------------
check_pattern \
    "std::*_distribution (not portable across stdlibs)" \
    'std::[A-Za-z_]+_distribution'

# --- 2. No std::random_device / std::default_random_engine / std::rand. ---
check_pattern \
    "std::random_device (non-deterministic seed source)" \
    '\bstd::random_device\b'

check_pattern \
    "std::default_random_engine (implementation-defined)" \
    '\bstd::default_random_engine\b'

check_pattern \
    "std::rand (non-reentrant, global state)" \
    '\bstd::rand\b'

# --- 3. No direct std::mt19937 / std::mt19937_64 outside RngDet.hpp. ------
check_pattern \
    "std::mt19937 outside RngDet.hpp (must go through RngDet wrapper)" \
    '\bstd::mt19937(_64)?\b'

# --- 4. No #include <random> outside RngDet.hpp. --------------------------
check_pattern \
    "#include <random> outside RngDet.hpp (must go through RngDet wrapper)" \
    '#[[:space:]]*include[[:space:]]*<random>'

if [[ $fail -eq 0 ]]; then
    echo "check_no_bad_rng.sh: OK"
fi
exit $fail
