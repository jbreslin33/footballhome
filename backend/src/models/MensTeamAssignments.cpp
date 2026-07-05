#include "MensTeamAssignments.h"

#include <algorithm>
#include <pqxx/pqxx>
#include <sstream>
#include "../database/Database.h"

MensTeamAssignments::MensTeamAssignments()
    : db_(Database::getInstance()) {}

MensTeamAssignments::ByUser MensTeamAssignments::loadAll() {
    ByUser out;
    const auto rows = db_->query(
        "SELECT leagueapps_user_id, team_id, on_roster, coach_sort_order "
        "  FROM mens_team_assignments "
        " WHERE removed_at IS NULL"
    );
    for (const auto& row : rows) {
        if (row["leagueapps_user_id"].is_null() || row["team_id"].is_null()) continue;
        const std::string uid = row["leagueapps_user_id"].c_str();
        Cell c;
        c.teamId   = row["team_id"].as<int>();
        c.onRoster = !row["on_roster"].is_null() && row["on_roster"].as<bool>();
        if (!row["coach_sort_order"].is_null()) {
            c.coachSortOrder = row["coach_sort_order"].as<int>();
        }
        out[uid].push_back(c);
    }
    return out;
}

std::vector<int> MensTeamAssignments::teamIdsForUser(long long userId) {
    std::vector<int> out;
    // ORDER BY id mirrors Node's unordered SELECT — Postgres heap order is
    // insertion order, equivalent to the serial PK ascending.  Required
    // for byte-equivalent JSON output (teamIds array order).
    const auto rows = db_->query(
        "SELECT team_id FROM mens_team_assignments "
        " WHERE leagueapps_user_id = $1 "
        "   AND removed_at IS NULL "
        " ORDER BY id",
        {std::to_string(userId)}
    );
    out.reserve(rows.size());
    for (const auto& row : rows) {
        if (!row["team_id"].is_null()) out.push_back(row["team_id"].as<int>());
    }
    return out;
}

std::vector<int> MensTeamAssignments::addAssignment(long long userId,
                                                     int teamId,
                                                     const std::string& mutexGroup) {
    // Single transaction so the mutex-sibling DELETE, delinquent restore
    // and the upsert land atomically — mirrors the Node BEGIN/COMMIT
    // semantics.
    auto tx = db_->beginTransaction();

    if (!mutexGroup.empty()) {
        tx->exec_params(
            "DELETE FROM mens_team_assignments a "
            "  USING mens_team_columns c "
            "  WHERE a.team_id = c.team_id "
            "    AND a.leagueapps_user_id = $1 "
            "    AND c.mutex_group = $2 "
            "    AND a.team_id <> $3 "
            "    AND a.removed_at IS NULL",
            userId, mutexGroup, teamId
        );
    }

    // If the SAME (user, team) row exists but was soft-deleted for
    // delinquency, restore it in place so audit history + assigned_at
    // are preserved.  Only touches 'delinquent' removals; other reasons
    // (manual removal etc.) are left alone.
    pqxx::result restored = tx->exec_params(
        "UPDATE mens_team_assignments "
        "   SET removed_at = NULL, "
        "       removed_reason = NULL, "
        "       removed_details = NULL "
        " WHERE leagueapps_user_id = $1 "
        "   AND team_id = $2 "
        "   AND removed_at IS NOT NULL "
        "   AND removed_reason = 'delinquent' "
        " RETURNING id",
        userId, teamId
    );

    if (restored.empty()) {
        tx->exec_params(
            "INSERT INTO mens_team_assignments (leagueapps_user_id, team_id, assigned_by_user_id) "
            "VALUES ($1, $2, NULL) "
            "ON CONFLICT (leagueapps_user_id, team_id) "
            "  WHERE removed_at IS NULL DO NOTHING",
            userId, teamId
        );
    }

    pqxx::result after = tx->exec_params(
        "SELECT team_id FROM mens_team_assignments "
        " WHERE leagueapps_user_id = $1 "
        "   AND removed_at IS NULL "
        " ORDER BY id",
        userId
    );

    std::vector<int> out;
    out.reserve(after.size());
    for (const auto& row : after) {
        if (!row["team_id"].is_null()) out.push_back(row["team_id"].as<int>());
    }

    db_->commit(tx);
    return out;
}

std::vector<int> MensTeamAssignments::removeAssignment(long long userId, int teamId) {
    // Admin-initiated remove is still a hard DELETE — respects the
    // admin's intent to purge the assignment entirely.  Auto-purgatory
    // uses bulkSoftDeleteForDelinquent() which preserves the row.
    db_->query(
        "DELETE FROM mens_team_assignments "
        " WHERE leagueapps_user_id = $1 AND team_id = $2 "
        "   AND removed_at IS NULL",
        {std::to_string(userId), std::to_string(teamId)}
    );
    return teamIdsForUser(userId);
}

std::optional<bool> MensTeamAssignments::setRosterStatus(long long userId,
                                                          int teamId,
                                                          bool onRoster) {
    const auto rows = db_->query(
        "UPDATE mens_team_assignments "
        "   SET on_roster = $3 "
        " WHERE leagueapps_user_id = $1 AND team_id = $2 "
        "   AND removed_at IS NULL "
        " RETURNING on_roster",
        {std::to_string(userId), std::to_string(teamId), onRoster ? "true" : "false"}
    );
    if (rows.empty()) return std::nullopt;
    return rows[0]["on_roster"].is_null() ? false : rows[0]["on_roster"].as<bool>();
}

// ────────────────────────────────────────────────────────────────────────────
// Delinquency soft-delete / auto-restore (2026-07-04)
// ────────────────────────────────────────────────────────────────────────────

long long MensTeamAssignments::bulkSoftDeleteForDelinquent(
    const std::unordered_map<long long, DelinquencyDetail>& details)
{
    if (details.empty()) return 0;

    long long touched = 0;
    auto tx = db_->beginTransaction();

    for (const auto& [uid, d] : details) {
        // Manual JSONB build so we don't drag nlohmann in here — small
        // fixed schema, easy to inline.
        std::ostringstream j;
        j << "{\"daysOverdue\":" << d.daysOverdue;
        if (!d.nextBillDate.empty()) {
            j << ",\"nextBillDate\":\"" << d.nextBillDate << "\"";
        }
        if (d.hasBalance) {
            j << ",\"outstandingBalance\":" << d.outstandingBalance;
        }
        j << "}";

        pqxx::result r = tx->exec_params(
            "UPDATE mens_team_assignments "
            "   SET removed_at      = NOW(), "
            "       removed_reason  = 'delinquent', "
            "       removed_details = $2::jsonb "
            " WHERE leagueapps_user_id = $1 "
            "   AND removed_at IS NULL "
            " RETURNING id",
            uid, j.str()
        );
        touched += static_cast<long long>(r.size());
    }

    db_->commit(tx);
    return touched;
}

long long MensTeamAssignments::bulkRestoreForDelinquent(const std::vector<long long>& userIds) {
    if (userIds.empty()) return 0;
    long long touched = 0;
    auto tx = db_->beginTransaction();

    for (long long uid : userIds) {
        // Restore rows one-by-one so a partial-index collision (an active
        // row already exists on the same (user, team) pair — e.g. admin
        // re-added them during purgatory) simply skips instead of aborting
        // the whole transaction.
        pqxx::result candidates = tx->exec_params(
            "SELECT id, team_id FROM mens_team_assignments "
            " WHERE leagueapps_user_id = $1 "
            "   AND removed_at IS NOT NULL "
            "   AND removed_reason = 'delinquent' "
            " ORDER BY id",
            uid
        );

        for (const auto& row : candidates) {
            if (row["id"].is_null() || row["team_id"].is_null()) continue;
            const long long rowId  = row["id"].as<long long>();
            const int       teamId = row["team_id"].as<int>();

            // Check no active row would collide.
            pqxx::result active = tx->exec_params(
                "SELECT 1 FROM mens_team_assignments "
                " WHERE leagueapps_user_id = $1 "
                "   AND team_id = $2 "
                "   AND removed_at IS NULL "
                " LIMIT 1",
                uid, teamId
            );
            if (!active.empty()) continue;

            pqxx::result upd = tx->exec_params(
                "UPDATE mens_team_assignments "
                "   SET removed_at      = NULL, "
                "       removed_reason  = NULL, "
                "       removed_details = NULL "
                " WHERE id = $1 "
                " RETURNING id",
                rowId
            );
            touched += static_cast<long long>(upd.size());
        }
    }

    db_->commit(tx);
    return touched;
}

// ────────────────────────────────────────────────────────────────────────────
// Practice / Pickup auto-membership (2026-07-04)
// ────────────────────────────────────────────────────────────────────────────

long long MensTeamAssignments::bulkEnsureActive(const std::vector<long long>& userIds, int teamId) {
    if (userIds.empty()) return 0;

    long long inserted = 0;
    auto tx = db_->beginTransaction();

    for (long long uid : userIds) {
        // INSERT ON CONFLICT DO NOTHING is a no-op when an active row
        // already exists (partial unique index catches it).  It creates
        // a new active row when none exists — even if a soft-deleted
        // row is present for a non-delinquency reason (paused, manual)
        // — because the partial unique index only counts active rows.
        //
        // For delinquency-removed rows on the same (uid, team), the
        // caller is expected to have already run bulkRestoreForDelinquent
        // so the row is active and the ON CONFLICT fires cleanly.
        pqxx::result r = tx->exec_params(
            "INSERT INTO mens_team_assignments (leagueapps_user_id, team_id, assigned_by_user_id) "
            "VALUES ($1, $2, NULL) "
            "ON CONFLICT (leagueapps_user_id, team_id) "
            "  WHERE removed_at IS NULL DO NOTHING "
            "RETURNING id",
            uid, teamId
        );
        inserted += static_cast<long long>(r.size());
    }

    db_->commit(tx);
    return inserted;
}

// ────────────────────────────────────────────────────────────────────────────
// Coach-defined ordering (2026-07-04 pm)
// ────────────────────────────────────────────────────────────────────────────

long long MensTeamAssignments::reorderTeam(int teamId,
                                           const std::vector<long long>& userIdsInOrder) {
    if (userIdsInOrder.empty()) return 0;

    long long touched = 0;
    auto tx = db_->beginTransaction();

    // Simple loop: one UPDATE per user, coach_sort_order = 1..N in the
    // supplied order.  N is bounded by column max_roster (~25) so the
    // extra round-trips vs a single UNNEST/VALUES statement don't
    // matter — and the per-row form keeps the code readable.
    int rank = 1;
    for (long long uid : userIdsInOrder) {
        pqxx::result r = tx->exec_params(
            "UPDATE mens_team_assignments "
            "   SET coach_sort_order = $3 "
            " WHERE leagueapps_user_id = $1 "
            "   AND team_id = $2 "
            "   AND removed_at IS NULL "
            " RETURNING id",
            uid, teamId, rank
        );
        touched += static_cast<long long>(r.size());
        ++rank;
    }

    db_->commit(tx);
    return touched;
}
