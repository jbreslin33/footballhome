#!/usr/bin/env bash
#
# scripts/check_behaviours.sh — the engine's behaviours and src/ai/behaviours.list agree.
#
# Every `// [behaviour: <code>]` tag in src/ names a code listed in src/ai/behaviours.list,
# and every code listed there (not marked "pending") is tagged at least once. One line per
# code. See the list's own header for why (the taxonomy and the engine are one system).
#
# Exits 0 (clean) or 1 (violation). Runs in the image build, beside check_no_floats.sh.

set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
LIST=src/ai/behaviours.list
fail=0

listed=$(grep -vE '^\s*(#|$)' "$LIST" | awk '{print $1}' | sort)
pending=$(grep -vE '^\s*(#|$)' "$LIST" | awk '$2=="pending"{print $1}' | sort)
tagged=$(grep -RhoE '//\s*\[behaviour:\s*[a-z0-9_]+\]' --include='*.cpp' --include='*.hpp' src \
           | sed -E 's/.*\[behaviour:\s*([a-z0-9_]+)\]/\1/' | sort -u)

dups=$(printf '%s\n' "$listed" | uniq -d)
if [[ -n "$dups" ]]; then echo "ERROR: listed twice in $LIST:" >&2; echo "$dups" >&2; fail=1; fi

unknown=$(comm -23 <(printf '%s\n' "$tagged") <(printf '%s\n' "$listed" | sort -u))
if [[ -n "$unknown" ]]; then
    echo "ERROR: tagged in the source but not in $LIST (add the line AND its game_engine_behaviours row):" >&2
    echo "$unknown" >&2; fail=1
fi

missing=$(comm -23 <(comm -23 <(printf '%s\n' "$listed" | sort -u) <(printf '%s\n' "$pending")) <(printf '%s\n' "$tagged"))
if [[ -n "$missing" ]]; then
    echo "ERROR: in $LIST but tagged nowhere in src/ (the behaviour was removed — delete its line and retire its row — or its tag was lost):" >&2
    echo "$missing" >&2; fail=1
fi

stale=$(comm -12 <(printf '%s\n' "$pending") <(printf '%s\n' "$tagged"))
if [[ -n "$stale" ]]; then
    echo "ERROR: marked pending in $LIST but tagged in the source — drop the word 'pending':" >&2
    echo "$stale" >&2; fail=1
fi

if [[ $fail -eq 0 ]]; then
    echo "check_behaviours.sh: OK ($(printf '%s\n' "$tagged" | grep -c .) tagged, $(printf '%s\n' "$pending" | grep -c . || true) pending)"
fi
exit $fail
