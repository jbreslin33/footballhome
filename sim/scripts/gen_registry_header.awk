# sim/scripts/gen_registry_header.awk
#
# Reads one OR MORE sim registry-seed migration files (via awk's built-in
# multi-file input) and emits sim/src/common/M0Registry.generated.hpp on
# stdout.
#
# Extracts every INSERT INTO sim_attribute_registry (id, key, category, ...)
# VALUES and every INSERT INTO sim_concept_registry (...) VALUES block
# across all input files (in argument order — file boundaries are invisible
# to the parser: mode is per-INSERT, ended by ON CONFLICT / bare `;`), then
# emits:
#
#   * inline constexpr AttrId    k... = N;   for every attribute row
#   * inline constexpr ConceptId k... = N;   for every concept row
#   * an inline seedRegistries(...) helper that replays each row into
#     an in-memory AttributeRegistry / ConceptRegistry.
#
# Naming convention (see DESIGN.md §22.11):
#   key = "<category>.<snake_name>"   -> strip the "<category>." prefix
#   key = "<snake_name>"              -> keep as-is
#   Then snake_case -> PascalCase, prepend "k".
#
#   physical.max_walk_speed (cat physical) -> kMaxWalkSpeed
#   run_to_point            (cat movement) -> kRunToPoint
#
# Errors out (exit 1) if two rows would produce the same C++ identifier
# (per-registry uniqueness). Duplicate id values are NOT detected here —
# the DB PK enforces that when the migration is applied.
#
# Usage (single migration — the M0 baseline):
#   awk -f sim/scripts/gen_registry_header.awk \
#       database/migrations/200-sim-registries.sql \
#       > sim/src/common/M0Registry.generated.hpp
#
# Usage (M0 + extending migrations, in id order):
#   awk -f sim/scripts/gen_registry_header.awk \
#       database/migrations/200-sim-registries.sql \
#       database/migrations/208-sim-attr-dribble-efficiency.sql \
#       database/migrations/209-sim-attr-carry-speeds.sql \
#       > sim/src/common/M0Registry.generated.hpp
#
# Design refs: DESIGN.md §21.1 (ship-blocker item 3), §22.11 (this ADR).

BEGIN {
    mode = ""                      # "" | "attr" | "concept"
    n_attr = 0
    n_concept = 0
    delete attr_id
    delete attr_key
    delete attr_cat
    delete attr_cname
    delete concept_id
    delete concept_key
    delete concept_cat
    delete concept_cname
    delete seen_cname             # collision check across attrs (per registry)
    delete seen_cname_concept
}

# -----------------------------------------------------------------------
# Detect INSERT header lines. We only care about registry tables.
# The migration format is (as of 2026-07-11):
#   INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
# followed by one row per line, ending with ON CONFLICT ... or ;
# -----------------------------------------------------------------------
/^[[:space:]]*INSERT[[:space:]]+INTO[[:space:]]+sim_attribute_registry/ {
    mode = "attr"
    next
}
/^[[:space:]]*INSERT[[:space:]]+INTO[[:space:]]+sim_concept_registry/ {
    mode = "concept"
    next
}

# Any INSERT into another table ends the current mode.
/^[[:space:]]*INSERT[[:space:]]+INTO[[:space:]]+/ {
    mode = ""
    next
}

# ON CONFLICT or bare semicolon ends the current INSERT block.
/^[[:space:]]*ON[[:space:]]+CONFLICT/ { mode = ""; next }
/^[[:space:]]*;[[:space:]]*$/         { mode = ""; next }

# -----------------------------------------------------------------------
# Row-parsing helpers
# -----------------------------------------------------------------------
#   ( 1, 'physical.max_walk_speed', 'physical', 1.0, 'Ceiling m/s while walking'),
# We only need the first three columns: id, key, category. The rest is
# consumed and discarded.
# -----------------------------------------------------------------------

function parse_row(line, out,   s, id, key, cat) {
    # Strip trailing comma and any trailing whitespace/newlines.
    sub(/[[:space:]]*,?[[:space:]]*$/, "", line)
    # Strip surrounding parentheses.
    if (match(line, /^[[:space:]]*\(/)) {
        line = substr(line, RSTART + RLENGTH)
    }
    if (match(line, /\)[[:space:]]*$/)) {
        line = substr(line, 1, RSTART - 1)
    }

    # id: first token, integer.
    if (!match(line, /^[[:space:]]*[0-9]+/)) return 0
    id = substr(line, RSTART, RLENGTH)
    sub(/^[[:space:]]*[0-9]+[[:space:]]*,[[:space:]]*/, "", line)
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)

    # key: single-quoted string.
    if (!match(line, /^'[^']*'/)) return 0
    key = substr(line, RSTART + 1, RLENGTH - 2)
    sub(/^'[^']*'[[:space:]]*,[[:space:]]*/, "", line)

    # category: single-quoted string.
    if (!match(line, /^'[^']*'/)) return 0
    cat = substr(line, RSTART + 1, RLENGTH - 2)

    out["id"] = id
    out["key"] = key
    out["cat"] = cat
    return 1
}

# snake_case identifier (possibly with leading "<cat>.") -> PascalCase.
# The category prefix is stripped when present.
function to_cname(key, cat,   local, parts, n, i, s, out) {
    local = key
    # Strip leading "<cat>." if present.
    if (index(local, cat ".") == 1) {
        local = substr(local, length(cat) + 2)
    }
    # Split on '_' and PascalCase each token.
    n = split(local, parts, "_")
    out = "k"
    for (i = 1; i <= n; i++) {
        s = parts[i]
        if (length(s) == 0) continue
        out = out toupper(substr(s, 1, 1)) substr(s, 2)
    }
    return out
}

# -----------------------------------------------------------------------
# Row lines: only meaningful inside a recognised INSERT block.
# -----------------------------------------------------------------------
mode != "" && /^[[:space:]]*\(/ {
    delete row
    if (!parse_row($0, row)) {
        printf("ERROR (gen_registry_header.awk): could not parse row: %s\n",
               $0) > "/dev/stderr"
        exit 1
    }
    cname = to_cname(row["key"], row["cat"])
    if (mode == "attr") {
        if (cname in seen_cname) {
            printf("ERROR (gen_registry_header.awk): duplicate C++ identifier %s (from key %s and %s)\n",
                   cname, seen_cname[cname], row["key"]) > "/dev/stderr"
            exit 1
        }
        seen_cname[cname] = row["key"]
        n_attr++
        attr_id[n_attr]    = row["id"]
        attr_key[n_attr]   = row["key"]
        attr_cat[n_attr]   = row["cat"]
        attr_cname[n_attr] = cname
    } else if (mode == "concept") {
        if (cname in seen_cname_concept) {
            printf("ERROR (gen_registry_header.awk): duplicate concept C++ identifier %s\n",
                   cname) > "/dev/stderr"
            exit 1
        }
        seen_cname_concept[cname] = row["key"]
        n_concept++
        concept_id[n_concept]    = row["id"]
        concept_key[n_concept]   = row["key"]
        concept_cat[n_concept]   = row["cat"]
        concept_cname[n_concept] = cname
    }
    next
}

# -----------------------------------------------------------------------
# Emit the header at end-of-input.
# -----------------------------------------------------------------------
END {
    if (n_attr == 0 && n_concept == 0) {
        print "ERROR (gen_registry_header.awk): no rows extracted \
from migration file. Migration format may have changed." > "/dev/stderr"
        exit 1
    }

    print "// AUTO-GENERATED - do not edit."
    print "// Source:    database/migrations/200-sim-registries.sql"
    print "//        +   database/migrations/208-sim-attr-dribble-efficiency.sql"
    print "//        +   database/migrations/209-sim-attr-carry-speeds.sql"
    print "//        +   database/migrations/216-sim-attr-press-resistance.sql"
    print "//        +   database/migrations/217-sim-attr-pass-power.sql"
    print "//        +   database/migrations/220-sim-attr-body-mass.sql"
    print "//        +   database/migrations/224-sim-concept-pressing.sql"
    print "//        +   database/migrations/225-sim-concept-marking-jockey.sql"
    print "//        +   database/migrations/226-sim-attr-m3-batch.sql"
    print "//        +   database/migrations/229-sim-concept-1v1-beat.sql"
    print "// Generator: sim/scripts/gen_registry_header.awk"
    print "// Regenerate on host (single line, wrapped for readability only):"
    print "//   awk -f sim/scripts/gen_registry_header.awk"
    print "//       database/migrations/200-sim-registries.sql"
    print "//       database/migrations/208-sim-attr-dribble-efficiency.sql"
    print "//       database/migrations/209-sim-attr-carry-speeds.sql"
    print "//       database/migrations/216-sim-attr-press-resistance.sql"
    print "//       database/migrations/217-sim-attr-pass-power.sql"
    print "//       database/migrations/220-sim-attr-body-mass.sql"
    print "//       database/migrations/224-sim-concept-pressing.sql"
    print "//       database/migrations/225-sim-concept-marking-jockey.sql"
    print "//       database/migrations/226-sim-attr-m3-batch.sql"
    print "//       database/migrations/229-sim-concept-1v1-beat.sql"
    print "//       > sim/src/common/M0Registry.generated.hpp"
    print "// See sim/DESIGN.md section 22.11."
    print ""
    print "#pragma once"
    print ""
    print "#include \"common/IdTypes.hpp\""
    print "#include \"registry/AttributeRegistry.hpp\""
    print "#include \"registry/ConceptRegistry.hpp\""
    print ""
    print "namespace fh::sim::m0 {"
    print ""
    print "// ---------------------------------------------------------"
    print "// Attribute IDs (from sim_attribute_registry INSERT rows)."
    print "// ---------------------------------------------------------"
    for (i = 1; i <= n_attr; i++) {
        printf("inline constexpr AttrId %-32s = %s;   // %s\n",
               attr_cname[i], attr_id[i], attr_key[i])
    }
    print ""
    print "// ---------------------------------------------------------"
    print "// Concept IDs (from sim_concept_registry INSERT rows)."
    print "// ---------------------------------------------------------"
    for (i = 1; i <= n_concept; i++) {
        printf("inline constexpr ConceptId %-28s = %s;   // %s\n",
               concept_cname[i], concept_id[i], concept_key[i])
    }
    print ""
    print "// ---------------------------------------------------------"
    print "// Seed the two in-memory registries with the migration's"
    print "// (id, key, category) tuples. Callers pass empty registries."
    print "// Idempotent - addEntry returns false on duplicate id."
    print "// ---------------------------------------------------------"
    print "inline void seedRegistries(registry::AttributeRegistry& attrs,"
    print "                           registry::ConceptRegistry&   concepts)"
    print "{"
    for (i = 1; i <= n_attr; i++) {
        printf("    attrs.addEntry(%s, \"%s\", \"%s\");\n",
               attr_cname[i], attr_key[i], attr_cat[i])
    }
    print ""
    for (i = 1; i <= n_concept; i++) {
        printf("    concepts.addEntry(%s, \"%s\", \"%s\");\n",
               concept_cname[i], concept_key[i], concept_cat[i])
    }
    print "}"
    print ""
    print "} // namespace fh::sim::m0"
}
