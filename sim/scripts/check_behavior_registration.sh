#!/usr/bin/env bash
#
# scripts/check_behavior_registration.sh
#
# CI enforcement: every concrete IBehavior subclass under sim/src/behavior/
# MUST be referenced by AiController::defaultBehaviors() — or by an
# explicitly allowlisted scenario-specific factory in this script. An
# unreferenced behavior is dead code that also skips the utility-AI
# dispatch machinery, defeating the purpose of the abstraction.
#
# Slice 30.1 opening state: sim/src/behavior/ contains only IBehavior.hpp
# (the interface). This script's audit finds zero concrete subclasses,
# the loop is a no-op, and the exit code is 0. Slices 30.2, 31.2, 33.2
# add concrete behaviors and MUST also add them to
# AiController::defaultBehaviors() in the same commit — the CI gate will
# fail otherwise.
#
# Design refs: DESIGN.md §5.5, §25.2 (M3 utility-AI scaffolding),
# §25.3 Slice 30.1 exit gate.
#
# Exits 0 (clean) or 1 (violation). Prints violations to stderr.

set -euo pipefail

# SIM_ROOT = directory containing src/ and tests/ and scripts/.
# Works whether invoked from the workspace root on the host
# (SIM_ROOT=./sim) or from inside the sim container (SIM_ROOT=/src),
# same convention as the sibling check_no_*.sh scripts.
SIM_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SIM_ROOT"

# Registration sites: files whose contents count as "registering" a
# behavior when the behavior's class name appears (as a substring) in
# them. Substring match is intentionally coarse — false positives
# (e.g. a comment mentioning the class) are strictly conservative
# (they let the class pass), and the review discipline is enforced by
# code review, not by this script alone.
#
# Current allowlist:
#   src/controller/AiController.cpp — canonical defaultBehaviors() factory.
#
# Extend this list ONLY when a scenario has a bespoke behavior bag that
# AiController::defaultBehaviors() intentionally excludes (e.g. a
# tutorial scenario that ships without press). Every extension MUST be
# accompanied by a DESIGN.md note explaining why the exclusion is
# intentional.
ALLOWLIST_FACTORIES=(
    "src/controller/AiController.cpp"
)

# The interface header itself — never counted as a "concrete subclass".
INTERFACE_HEADER="src/behavior/IBehavior.hpp"

# Grep for concrete subclasses under src/behavior/. Matches:
#   class Foo : public IBehavior
#   class Foo final : public IBehavior
#   class Foo : public behavior::IBehavior
#   class Foo final : public behavior::IBehavior
# ...but NOT the IBehavior interface's own forward declarations elsewhere.
mapfile -t behavior_hits < <(
    grep -RIn --include='*.hpp' --include='*.h' \
        -E 'class[[:space:]]+[A-Z][A-Za-z0-9_]+([[:space:]]+final)?[[:space:]]*:[[:space:]]*(public[[:space:]]+)?(behavior::)?IBehavior\b' \
        src/behavior/ 2>/dev/null || true
)

fail=0
registered_count=0
missing_count=0

for hit in "${behavior_hits[@]}"; do
    # hit format: "src/behavior/Foo.hpp:23:class Foo final : public IBehavior {"
    hit_path="${hit%%:*}"

    # Skip the interface header. Its own file MAY contain forward
    # declarations of subclasses (uncommon but possible).
    if [[ "$hit_path" == "$INTERFACE_HEADER" ]]; then
        continue
    fi

    # Extract the class name — first identifier after `class` (optionally
    # followed by `final`).
    class_name="$(printf '%s\n' "$hit" \
        | sed -E 's/.*class[[:space:]]+([A-Z][A-Za-z0-9_]+).*/\1/')"

    if [[ -z "$class_name" || "$class_name" == "IBehavior" ]]; then
        continue
    fi

    registered=0
    for allow_file in "${ALLOWLIST_FACTORIES[@]}"; do
        if [[ ! -f "$allow_file" ]]; then
            continue
        fi
        if grep -q "$class_name" "$allow_file"; then
            registered=1
            break
        fi
    done

    if [[ $registered -eq 1 ]]; then
        registered_count=$((registered_count + 1))
    else
        printf 'ERROR: IBehavior subclass %q\n' "$class_name" >&2
        printf '       declared at %s\n' "$hit" >&2
        printf '       is not registered in any of:\n' >&2
        for allow_file in "${ALLOWLIST_FACTORIES[@]}"; do
            printf '           %s\n' "$allow_file" >&2
        done
        missing_count=$((missing_count + 1))
        fail=1
    fi
done

total=${#behavior_hits[@]}
# Subtract 1 for the interface header if it showed up (defensive — the
# grep pattern excludes it in principle, but if IBehavior.hpp ever
# starts forward-declaring subclasses the count would double).
if [[ $total -gt 0 ]]; then
    printf 'check_behavior_registration.sh: audited %d IBehavior declaration(s); %d registered, %d missing.\n' \
        "$total" "$registered_count" "$missing_count"
else
    printf 'check_behavior_registration.sh: OK (no concrete IBehavior subclasses found; interface-only tree)\n'
fi

exit $fail
