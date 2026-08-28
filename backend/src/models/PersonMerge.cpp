#include "PersonMerge.h"
#include <iostream>
#include <pqxx/pqxx>
#include <sstream>
#include <stdexcept>
#include <string>

namespace {
    // ─── nullable column readers ──────────────────────────────────────────
    std::optional<std::string> nullableText(const pqxx::row& r, const char* c) {
        const auto& f = r[c];
        return f.is_null() ? std::nullopt
                           : std::optional<std::string>(f.as<std::string>());
    }
    std::optional<int> nullableInt(const pqxx::row& r, const char* c) {
        const auto& f = r[c];
        return f.is_null() ? std::nullopt : std::optional<int>(f.as<int>());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Static child-table catalogue.  Every table here must (a) exist in the
// schema and (b) have a `person_id` column referencing `persons(id)`.  When
// migrations add or drop a person-owning table, this list MUST be updated
// or the merge transaction will fail on the snapshot subquery.
//
// One person-owning reference cannot live here: persons.parent_person_id,
// which names a `persons` row rather than carrying a person_id column.  It
// is declared ON DELETE NO ACTION, so merging someone who is a parent of a
// youth player fails loudly on step 4's DELETE with an FK violation and the
// whole transaction rolls back.  That is a safe outcome — nothing is lost —
// but it does mean parents cannot currently be merged at all.  Reparenting
// their children onto the kept person is a real semantic decision (are the
// kids now the kept person's kids?) and deliberately not made here.
// ────────────────────────────────────────────────────────────────────────────
const std::vector<PersonMerge::ChildTable>& PersonMerge::childTables() {
    static const std::vector<ChildTable> kTables = {
        { "users",                   Conflict::UniquePerson,         {},                 {"id"} },
        { "person_emails",           Conflict::UniquePersonPlusCols, {"email"},          {"id"} },
        { "person_phones",           Conflict::UniquePersonPlusCols, {"phone_number"},   {"id"} },
        { "external_identities",     Conflict::NoPersonUnique,       {},                 {"id"} },
        { "players",                 Conflict::UniquePerson,         {},                 {"id"} },
        { "coaches",                 Conflict::UniquePerson,         {},                 {"id"} },
        { "chat_event_rsvps",        Conflict::UniquePersonPlusCols, {"chat_event_id"},  {"id"} },
        { "event_rsvps",             Conflict::UniquePersonPlusCols, {"chat_event_id"},  {"id"} },
        { "person_field_overrides",  Conflict::UniquePersonPlusCols, {"field_name"},     {"id"} },
        // Added 2026-08-28.  Every one of these has a person_id FK declared
        // ON DELETE CASCADE, so while they were missing from this catalogue
        // a merge did not "leave them alone" — step 4's DELETE FROM persons
        // destroyed them outright, with no snapshot and therefore no undo.
        // team_persons and fh_event_rsvps are the sharp ones: merging two
        // identities silently wiped the dropped person's entire roster
        // history and every RSVP they had ever given.
        //
        // Membership of THIS list is what makes a table survive a merge, so
        // when a migration adds a person-owning table, add it here too.  To
        // find stragglers:
        //   SELECT c.conrelid::regclass FROM pg_constraint c
        //    WHERE c.contype='f' AND c.confrelid='persons'::regclass;
        { "team_persons",            Conflict::UniquePersonPlusCols, {"team_id"},        {"id"} },
        { "fh_event_rsvps",          Conflict::UniquePersonPlusCols, {"fh_event_id"},    {"id"} },
        { "fh_event_attendance",     Conflict::UniquePersonPlusCols, {"fh_event_id"},    {"id"} },
        { "person_la_memberships",   Conflict::UniquePersonPlusCols, {"la_program_id"},  {"id"} },
        { "player_event_reminders",  Conflict::NoPersonUnique,       {},                 {"id"} },
        { "push_subscriptions",      Conflict::NoPersonUnique,       {},                 {"id"} },
        { "trail_test_attempts",     Conflict::NoPersonUnique,       {},                 {"id"} },
        { "trail_test_results",      Conflict::NoPersonUnique,       {},                 {"id"} },
        // These two carry person_id INSIDE their primary key, which the
        // unmerge PK-match in reverse() cannot express: it looks for the
        // snapshot row under the KEPT person, but a PK containing person_id
        // can never match there, so reverse() restores the row under the
        // dropped person while the reparented copy stays under the kept one
        // — a duplicate rather than a clean split.  Listing them anyway is
        // still strictly better than the alternative, which was outright
        // deletion with nothing recorded to argue about.
        { "rsvp_suspensions",        Conflict::UniquePersonPlusCols, {"starts_at"},      {"person_id", "starts_at"} },
        { "sim_player_profile",      Conflict::UniquePerson,         {},                 {"person_id"} },
        // Auth state: many rows per person, no per-person uniqueness.  We
        // reparent (rather than delete) so the kept identity inherits the
        // dropped identity's active sessions / unconsumed magic links —
        // matches the user-visible "these are the same person" intent and
        // is fully reversible via unmerge.
        { "sessions",                Conflict::NoPersonUnique,       {},                 {"id"} },
        { "magic_link_tokens",       Conflict::NoPersonUnique,       {},                 {"id"} },
    };
    return kTables;
}

PersonMerge::PersonMerge() : db_(Database::getInstance()) {
    if (!db_) throw std::runtime_error("PersonMerge: Database instance is null");
}

// ────────────────────────────────────────────────────────────────────────────
// merge(la, gm) — see PersonMerger.merge in meta-leads-webhook/person-data.js
//
// All work happens inside a single transaction.  On any exception we
// rollback and re-throw so the controller surfaces a clean 4xx/5xx.
// ────────────────────────────────────────────────────────────────────────────
PersonMerge::MergeResult PersonMerge::merge(int laPersonId, int gmPersonId,
                                            std::optional<int> mergedByUserId) {
    if (laPersonId == gmPersonId) {
        throw std::invalid_argument("merge: cannot merge a person into itself");
    }

    auto tx = db_->beginTransaction();
    try {
        // 1. Sanity-lock both persons.
        auto lockRs = tx->exec_params(
            "SELECT id, la_user_id FROM persons WHERE id = $1 OR id = $2 FOR UPDATE",
            laPersonId, gmPersonId);
        if (lockRs.size() != 2) {
            throw std::invalid_argument(
                "merge: one or both persons not found");
        }
        std::optional<std::string> keptLaUserId, droppedLaUserId;
        for (const auto& row : lockRs) {
            auto& slot = (row["id"].as<int>() == laPersonId) ? keptLaUserId : droppedLaUserId;
            if (!row["la_user_id"].is_null()) slot = row["la_user_id"].as<std::string>();
        }

        // 2. INSERT the audit row first, building the JSONB snapshot
        //    entirely inside Postgres.  We pre-compute the
        //    `jsonb_build_object('table_a', (...), 'table_b', (...), …)`
        //    expression in C++ from the catalogue; PG does the rest.
        std::ostringstream snapSql;
        snapSql << "WITH audit AS (\n"
                   "  INSERT INTO person_merges\n"
                   "    (kept_person_id, dropped_person_id, dropped_snapshot,"
                   "     merged_by_user_id)\n"
                   "  SELECT $1::int, $2::int,\n"
                   "         jsonb_build_object(\n"
                   "           'persons',  (SELECT to_jsonb(p) FROM persons p WHERE id = $2::int),\n"
                   "           'children', jsonb_build_object(";
        bool first = true;
        for (const auto& ct : childTables()) {
            if (!first) snapSql << ',';
            first = false;
            // table names + column names come from a hard-coded catalogue
            // so direct interpolation is safe.
            snapSql << "\n             '" << ct.table << "', "
                       "COALESCE((SELECT jsonb_agg(to_jsonb(t)) FROM "
                    << ct.table << " t WHERE person_id = $2::int), '[]'::jsonb)";
        }
        snapSql << "\n           )\n"
                   "         ),\n"
                   "         $3\n"
                   "  RETURNING id,\n"
                   "    to_char(merged_at AT TIME ZONE 'UTC',\n"
                   "            'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS merged_at_iso\n"
                   ")\n"
                   "SELECT id, merged_at_iso FROM audit";

        const std::string mergedBy = mergedByUserId.has_value()
            ? std::to_string(*mergedByUserId) : std::string{};

        // exec_params with 3 args; empty string for mergedBy + NULLIF cast
        // would be ideal but PG accepts NULL via empty if cast to int by
        // NULLIF — simpler: build SQL with explicit NULL when not present.
        // We rewrite the $3 reference to a literal NULL or cast.
        std::string finalSnapSql = snapSql.str();
        if (!mergedByUserId.has_value()) {
            // Replace ", $3\n" → ", NULL\n".  Only one occurrence in the
            // template; safe substitution.
            const std::string needle = "         $3\n";
            auto pos = finalSnapSql.find(needle);
            if (pos != std::string::npos) {
                finalSnapSql.replace(pos, needle.size(), "         NULL::int\n");
            }
        }

        pqxx::result auditRs = mergedByUserId.has_value()
            ? tx->exec_params(finalSnapSql, laPersonId, gmPersonId, *mergedByUserId)
            : tx->exec_params(finalSnapSql, laPersonId, gmPersonId);

        if (auditRs.empty()) {
            throw std::runtime_error("merge: audit insert returned no row");
        }
        const int mergeId = auditRs[0]["id"].as<int>();
        const std::string mergedAtIso = auditRs[0]["merged_at_iso"].as<std::string>();

        // 3. For each child table, reparent or delete-on-conflict, then
        //    delete any remaining drop rows (they're in the snapshot).
        TableCounts reparented, deletedConflicts;
        for (const auto& ct : childTables()) {
            int moved = 0;

            switch (ct.conflict) {
                case Conflict::NoPersonUnique: {
                    auto u = tx->exec_params(
                        "UPDATE " + ct.table +
                        " SET person_id = $1 WHERE person_id = $2",
                        laPersonId, gmPersonId);
                    moved = static_cast<int>(u.affected_rows());
                    break;
                }
                case Conflict::UniquePerson: {
                    auto u = tx->exec_params(
                        "UPDATE " + ct.table +
                        " SET person_id = $1\n"
                        " WHERE person_id = $2\n"
                        "   AND NOT EXISTS (SELECT 1 FROM " + ct.table +
                        " WHERE person_id = $1)",
                        laPersonId, gmPersonId);
                    moved = static_cast<int>(u.affected_rows());
                    break;
                }
                case Conflict::UniquePersonPlusCols: {
                    std::ostringstream guard;
                    for (size_t i = 0; i < ct.conflictCols.size(); ++i) {
                        if (i) guard << " AND ";
                        guard << "k." << ct.conflictCols[i]
                              << " IS NOT DISTINCT FROM d." << ct.conflictCols[i];
                    }
                    auto u = tx->exec_params(
                        "UPDATE " + ct.table + " d SET person_id = $1\n"
                        " WHERE d.person_id = $2\n"
                        "   AND NOT EXISTS (SELECT 1 FROM " + ct.table + " k\n"
                        "                    WHERE k.person_id = $1 AND " +
                            guard.str() + ")",
                        laPersonId, gmPersonId);
                    moved = static_cast<int>(u.affected_rows());
                    break;
                }
            }

            auto d = tx->exec_params(
                "DELETE FROM " + ct.table + " WHERE person_id = $1", gmPersonId);
            const int deleted = static_cast<int>(d.affected_rows());

            if (moved)   reparented.emplace_back(ct.table, moved);
            if (deleted) deletedConflicts.emplace_back(ct.table, deleted);
        }

        // 4. Drop the persons row, then resolve la_user_id onto the kept
        //    row.  Deleting first frees the dropped person's la_user_id
        //    from the unique index before we try to claim it, in case the
        //    kept person didn't already have one.  If BOTH persons had a
        //    (different) la_user_id, the kept person's own value wins —
        //    the dropped value is not lost, it's still in
        //    person_merges.dropped_snapshot for this merge row.
        tx->exec_params("DELETE FROM persons WHERE id = $1", gmPersonId);

        if (!keptLaUserId.has_value() && droppedLaUserId.has_value()) {
            tx->exec_params(
                "UPDATE persons SET la_user_id = $1 WHERE id = $2",
                *droppedLaUserId, laPersonId);
        } else if (keptLaUserId.has_value() && droppedLaUserId.has_value()
                   && *keptLaUserId != *droppedLaUserId) {
            std::cerr << "[PersonMerge::merge] kept person " << laPersonId
                      << " la_user_id=" << *keptLaUserId
                      << " and dropped person " << gmPersonId
                      << " la_user_id=" << *droppedLaUserId
                      << " conflict — kept value wins, dropped value preserved"
                         " in person_merges.dropped_snapshot" << std::endl;
        }

        db_->commit(tx);

        MergeResult out;
        out.mergeId          = mergeId;
        out.mergedAt         = mergedAtIso;
        out.kept             = laPersonId;
        out.dropped          = gmPersonId;
        out.reparented       = std::move(reparented);
        out.deletedConflicts = std::move(deletedConflicts);
        return out;

    } catch (...) {
        try { db_->rollback(tx); } catch (...) { /* swallow */ }
        throw;
    }
}

// ────────────────────────────────────────────────────────────────────────────
// unmerge(id) — reverse a previous merge using its audit snapshot.
//
// 1. Lock the audit row.  Refuse if reversed_at IS NOT NULL.
// 2. Re-INSERT the dropped persons row at its original id (slot is free
//    because the merge DELETEd it).  Bump the SERIAL sequence past any
//    id-collision with rows inserted since.
// 3. For each child table, walk every snapshot row:
//      • if the live PK-keyed row exists under `keep` → UPDATE its
//        person_id back to the dropped id (it was reparented at merge);
//      • else → re-INSERT the row from the snapshot (it was deleted as
//        a conflict at merge).
// 4. Stamp reversed_at / reversed_by_user_id on the audit row.
// ────────────────────────────────────────────────────────────────────────────
PersonMerge::UnmergeResult PersonMerge::unmerge(int mergeId,
                                                std::optional<int> reversedByUserId) {
    auto tx = db_->beginTransaction();
    try {
        // 1. Lock the audit row.
        auto auditRs = tx->exec_params(
            "SELECT kept_person_id, dropped_person_id, dropped_snapshot, reversed_at\n"
            "  FROM person_merges WHERE id = $1 FOR UPDATE",
            mergeId);
        if (auditRs.empty()) {
            throw std::invalid_argument("unmerge: merge not found");
        }
        const auto& a = auditRs[0];
        if (!a["reversed_at"].is_null()) {
            throw std::invalid_argument("unmerge: merge already reversed");
        }
        const int keepId = a["kept_person_id"].as<int>();
        const int dropId = a["dropped_person_id"].as<int>();
        const std::string snapshotJson = a["dropped_snapshot"].as<std::string>();

        // 2a. If the merge adopted the dropped person's la_user_id onto the
        //     kept person (because the kept person had none of their own —
        //     see merge() step 4), the kept row is still holding that value
        //     now.  Free it before restoring the dropped row below, or the
        //     unique index on persons.la_user_id would reject the INSERT.
        tx->exec_params(
            "UPDATE persons SET la_user_id = NULL "
            " WHERE id = $1 AND la_user_id = ($2::jsonb->'persons'->>'la_user_id')",
            keepId, snapshotJson);

        // 2b. Re-INSERT the persons row.  jsonb_populate_record materialises
        //    the JSONB object into a tuple that matches the persons row type,
        //    so we don't need to know the column list in C++ — handy because
        //    `persons` columns evolve over time.  This also restores the
        //    dropped person's own la_user_id exactly as it was pre-merge.
        tx->exec_params(
            "INSERT INTO persons SELECT (jsonb_populate_record(NULL::persons, "
            "$1::jsonb->'persons')).*",
            snapshotJson);

        // Advance the SERIAL sequence past the just-restored id, in case
        // higher ids have been inserted since the merge.
        tx->exec(
            "SELECT setval(pg_get_serial_sequence('persons','id'),\n"
            "              GREATEST((SELECT MAX(id) FROM persons),\n"
            "                       nextval(pg_get_serial_sequence('persons','id')) - 1))");

        // 3. For each child table, restore snapshot rows.
        //
        //    Both the UPDATE and INSERT phases materialise the snapshot
        //    array via jsonb_populate_recordset(NULL::<table>, …) so the
        //    snapshot tuples take their column types from the live table.
        //    No manual `::int`/`::text` casts on PK columns — they just
        //    work, even when the schema evolves.
        TableCounts movedBack, reinserted;
        for (const auto& ct : childTables()) {
            // PK match: "t.<pk> = s.<pk>" AND-joined for composite PKs.
            std::ostringstream pkMatch;
            for (size_t i = 0; i < ct.pkCols.size(); ++i) {
                if (i) pkMatch << " AND ";
                pkMatch << "t." << ct.pkCols[i] << " = s." << ct.pkCols[i];
            }

            // 3a. UPDATE phase — for every snapshot row whose PK still
            //     exists under `keep`, point that live row back at `drop`.
            auto upd = tx->exec_params(
                "WITH snap AS (\n"
                "  SELECT * FROM jsonb_populate_recordset(NULL::" + ct.table +
                ", $1::jsonb->'children'->'" + ct.table + "')\n"
                ")\n"
                "UPDATE " + ct.table + " t SET person_id = $2\n"
                "  FROM snap s\n"
                " WHERE t.person_id = $3 AND " + pkMatch.str(),
                snapshotJson, dropId, keepId);
            const int moved = static_cast<int>(upd.affected_rows());

            // 3b. INSERT phase — any snapshot row whose PK currently does
            //     NOT exist anywhere in the table was deleted as a
            //     conflict at merge time; restore by re-INSERTing it.
            auto ins = tx->exec_params(
                "INSERT INTO " + ct.table + "\n"
                "SELECT s.* FROM\n"
                "  jsonb_populate_recordset(NULL::" + ct.table +
                ", $1::jsonb->'children'->'" + ct.table + "') s\n"
                " WHERE NOT EXISTS (SELECT 1 FROM " + ct.table + " t WHERE " +
                    pkMatch.str() + ")",
                snapshotJson);
            const int added = static_cast<int>(ins.affected_rows());

            if (moved) movedBack.emplace_back(ct.table, moved);
            if (added) reinserted.emplace_back(ct.table, added);
        }

        // 4. Stamp the reversal.
        if (reversedByUserId.has_value()) {
            tx->exec_params(
                "UPDATE person_merges SET reversed_at = now(),\n"
                "    reversed_by_user_id = $2 WHERE id = $1",
                mergeId, *reversedByUserId);
        } else {
            tx->exec_params(
                "UPDATE person_merges SET reversed_at = now(),\n"
                "    reversed_by_user_id = NULL WHERE id = $1",
                mergeId);
        }

        db_->commit(tx);

        UnmergeResult out;
        out.mergeId    = mergeId;
        out.kept       = keepId;
        out.restored   = dropId;
        out.movedBack  = std::move(movedBack);
        out.reinserted = std::move(reinserted);
        return out;

    } catch (...) {
        try { db_->rollback(tx); } catch (...) { /* swallow */ }
        throw;
    }
}

// ────────────────────────────────────────────────────────────────────────────
// listForPerson(id) — GET /api/persons/:id/merges
// ────────────────────────────────────────────────────────────────────────────
std::vector<PersonMerge::MergeRow> PersonMerge::listForPerson(int personId) {
    static const std::string kSql = R"SQL(
        SELECT id, kept_person_id, dropped_person_id,
               to_char(merged_at AT TIME ZONE 'UTC',
                       'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS merged_at_iso,
               merged_by_user_id,
               CASE WHEN reversed_at IS NULL THEN NULL
                    ELSE to_char(reversed_at AT TIME ZONE 'UTC',
                                 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') END AS reversed_at_iso,
               reversed_by_user_id,
               (dropped_snapshot->'persons'->>'first_name') AS dropped_first_name,
               (dropped_snapshot->'persons'->>'last_name')  AS dropped_last_name
          FROM person_merges
         WHERE (kept_person_id = $1::int OR dropped_person_id = $1::int)
           AND reversed_at IS NULL
         ORDER BY merged_at DESC
    )SQL";

    pqxx::result rs = db_->query(kSql, {std::to_string(personId)});

    std::vector<MergeRow> out;
    out.reserve(rs.size());
    for (const auto& r : rs) {
        MergeRow row;
        row.id                = r["id"].as<int>();
        row.keptPersonId      = r["kept_person_id"].as<int>();
        row.droppedPersonId   = r["dropped_person_id"].as<int>();
        row.mergedAt          = r["merged_at_iso"].as<std::string>();
        row.mergedByUserId    = nullableInt (r, "merged_by_user_id");
        row.reversedAt        = nullableText(r, "reversed_at_iso");
        row.reversedByUserId  = nullableInt (r, "reversed_by_user_id");
        row.droppedFirstName  = nullableText(r, "dropped_first_name");
        row.droppedLastName   = nullableText(r, "dropped_last_name");
        out.push_back(std::move(row));
    }
    return out;
}
