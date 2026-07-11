#!/usr/bin/env bash
#
# scripts/check_no_floats.sh
#
# CI enforcement: no float/double/std::sin/std::cos/std::sqrt in the sim
# gameplay layers, no WorldView references outside awareness/ and match/.
#
# Design ref: DESIGN.md §9, §10, §19.
#
# Exits 0 (clean) or 1 (violation). Prints violations to stderr.

set -euo pipefail

# Directories forbidden from touching float / double / std::sin / std::cos / std::sqrt.
FORBIDDEN_MATH_DIRS=(
    "sim/src/physics"
    "sim/src/controller"
    "sim/src/behavior"
    "sim/src/scenario"
    "sim/src/match"
)

# Directories allowed to reference WorldView. Every other file may only
# reference AwarenessView. Scenario is on the list because scenario
# success/reset predicates run against the post-tick ground-truth (they
# never touch controllers or behaviors), so passing a WorldView here is
# the intended API (see DESIGN.md §5.6).
ALLOWED_WORLDVIEW_DIRS=(
    "sim/src/awareness"
    "sim/src/match"
    "sim/src/scenario"
)

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail=0

# --- 1. No float/double in gameplay dirs (excluding block comments) ----------
for dir in "${FORBIDDEN_MATH_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then continue; fi
    # Look for standalone 'float' or 'double' as a whole word.
    # Excludes comment lines starting with // and #.
    if hits=$(grep -RInE '\b(float|double)\b' \
                --include='*.cpp' --include='*.hpp' --include='*.h' \
                "$dir" 2>/dev/null \
                | grep -vE ':\s*//' \
                | grep -vE '^\s*\*' || true); then
        if [[ -n "$hits" ]]; then
            echo "ERROR: forbidden 'float' or 'double' in $dir:" >&2
            echo "$hits" >&2
            fail=1
        fi
    fi

    if hits=$(grep -RInE '\bstd::(sin|cos|tan|sqrt|atan|atan2|asin|acos|pow|exp|log)\b' \
                --include='*.cpp' --include='*.hpp' --include='*.h' \
                "$dir" 2>/dev/null || true); then
        if [[ -n "$hits" ]]; then
            echo "ERROR: forbidden std:: transcendental in $dir (use fx_*):" >&2
            echo "$hits" >&2
            fail=1
        fi
    fi
done

# --- 2. WorldView only allowed in awareness/ and match/ ---------------------
if [[ -d "sim/src" ]]; then
    # Build a grep exclude expression from allowed dirs.
    excl_args=()
    for d in "${ALLOWED_WORLDVIEW_DIRS[@]}"; do
        excl_args+=(--exclude-dir="$(basename "$d")")
    done
    # Search only sim/src excluding the allowed subtrees.
    # Filter out lines where the match is inside a `// ...` or ` * ...` comment,
    # same rule as the float/double check above.
    if hits=$(grep -RInw 'WorldView' \
                --include='*.cpp' --include='*.hpp' --include='*.h' \
                "${excl_args[@]}" \
                sim/src 2>/dev/null \
                | grep -vE ':\s*//' \
                | grep -vE '^\s*\*' || true); then
        if [[ -n "$hits" ]]; then
            echo "ERROR: 'WorldView' referenced outside awareness/ + match/:" >&2
            echo "$hits" >&2
            fail=1
        fi
    fi
fi

# --- 3. No -ffast-math / -Ofast / etc in build files ------------------------
# Only inspect actual build config; exclude this script and Markdown docs.
# Skip matches that appear inside a comment (# ...) on the same line.
BAD_FLAG_RE='(-ffast-math|-Ofast|-funsafe-math-optimizations|-fassociative-math)'
if hits=$(grep -RInE "$BAD_FLAG_RE" \
            --include='CMakeLists.txt' \
            --include='*.cmake' \
            --include='Dockerfile*' \
            --include='Makefile*' \
            --include='*.mk' \
            sim/ 2>/dev/null \
            | awk -F: 'BEGIN{IGNORECASE=1}{
                line=$0;
                # strip leading "file:line:" so we look only at the code text
                sub(/^[^:]+:[0-9]+:/, "", line);
                # find first # (comment start); if the flag appears only after it, skip
                hash_idx = index(line, "#");
                match(line, /-ffast-math|-Ofast|-funsafe-math-optimizations|-fassociative-math/);
                flag_idx = RSTART;
                if (hash_idx > 0 && flag_idx > hash_idx) next;
                print $0;
            }' || true); then
    if [[ -n "$hits" ]]; then
        echo "ERROR: banned math flag found:" >&2
        echo "$hits" >&2
        fail=1
    fi
fi

if [[ $fail -eq 0 ]]; then
    echo "check_no_floats.sh: OK"
fi
exit $fail
