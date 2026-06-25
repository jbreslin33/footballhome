#pragma once
#include "../database/Database.h"
#include <optional>
#include <string>
#include <utility>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// PersonMerge — encapsulates the (LA-person, GM-person) merge / unmerge
// workflow that lives behind /api/persons/merge, /api/persons/unmerge/:id,
// and /api/persons/:id/merges.
//
// Two tables drive everything:
//   persons          — canonical row; we DROP one and KEEP the other
//   person_merges    — audit log; one row per merge, with a JSONB
//                       `dropped_snapshot` capturing the dropped persons
//                       row PLUS every child-table row owned by it at
//                       merge time, so the operation is reversible.
//
// Child tables that have per-person rows are listed in childTables() with
// metadata about uniqueness constraints + primary-key columns:
//   - NoPersonUnique          → reparent every drop row unconditionally
//   - UniquePerson            → UNIQUE(person_id); keep wins, drop is
//                                snapshotted then deleted
//   - UniquePersonPlusCols    → UNIQUE(person_id, …extra cols); per-tuple
//                                decision (move if keep has no matching
//                                tuple; otherwise delete from drop)
//
// Each merge / unmerge runs inside an explicit transaction obtained from
// Database::beginTransaction() so the snapshot, the child-table moves and
// the audit insert all commit together — partial state is impossible.
// ────────────────────────────────────────────────────────────────────────────
class PersonMerge {
public:
    // (table, count) tuples in iteration order.  Empty if no rows of that
    // class were touched.  Frontend renders this verbatim.
    using TableCounts = std::vector<std::pair<std::string, int>>;

    struct MergeResult {
        int         mergeId  = 0;
        std::string mergedAt;          // ISO-8601 UTC
        int         kept     = 0;
        int         dropped  = 0;
        TableCounts reparented;
        TableCounts deletedConflicts;
    };

    struct UnmergeResult {
        int         mergeId   = 0;
        int         kept      = 0;
        int         restored  = 0;     // the previously-dropped person_id
        TableCounts movedBack;         // rows whose live record was moved back
        TableCounts reinserted;        // rows that had been deleted, re-INSERTed
    };

    struct MergeRow {
        int id                    = 0;
        int keptPersonId          = 0;
        int droppedPersonId       = 0;
        std::string mergedAt;
        std::optional<int> mergedByUserId;
        std::optional<std::string> reversedAt;
        std::optional<int> reversedByUserId;
        std::optional<std::string> droppedFirstName;
        std::optional<std::string> droppedLastName;
    };

    PersonMerge();

    // Throws std::invalid_argument on missing/invalid ids.
    // Throws std::runtime_error on DB error (rolls back).
    MergeResult   merge  (int laPersonId, int gmPersonId,
                          std::optional<int> mergedByUserId);

    // Throws std::invalid_argument for unknown mergeId or one already reversed.
    UnmergeResult unmerge(int mergeId,
                          std::optional<int> reversedByUserId);

    // GET — every non-reversed merge involving this person (as kept OR dropped).
    std::vector<MergeRow> listForPerson(int personId);

private:
    Database* db_;

    enum class Conflict {
        NoPersonUnique,        // table has no per-person uniqueness → reparent all
        UniquePerson,          // UNIQUE(person_id) only → keep wins outright
        UniquePersonPlusCols   // UNIQUE(person_id, …) → per-tuple decision
    };

    struct ChildTable {
        std::string table;
        Conflict    conflict;
        // Used only when conflict == UniquePersonPlusCols.
        std::vector<std::string> conflictCols;
        // Primary-key columns — used by unmerge() to UPDATE-or-INSERT a
        // snapshot row.  All tables use "id" except chat_external_members
        // which has a composite PK.
        std::vector<std::string> pkCols;
    };

    // Single source of truth for the child-table catalogue.  Mirrors the
    // CHILD_TABLES constant in meta-leads-webhook/person-data.js.
    static const std::vector<ChildTable>& childTables();
};
