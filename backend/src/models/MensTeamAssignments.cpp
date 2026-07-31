#include "MensTeamAssignments.h"

#include <algorithm>
#include <pqxx/pqxx>
#include <sstream>
#include <utility>
#include "../database/Database.h"

// Group model (migration 250): this model reads/writes `team_persons`
// directly — the roster_assignments table, the v_team_members union
// view and the fn_grant_default_rsvp_eligibility trigger are all
// retired.  The public API stays keyed by leagueapps_user_id (the
// frontend board cards carry it); each query resolves the alias to a
// person via external_person_aliases at the SQL edge.
//
// Board mutex behavior: addAssignment still honors the caller-supplied
// mutexGroup (one-of within a column group).  Whether official teams
// participate in a mutex is now DATA (teams.mutex_group) — league
// rules allow multi-team players, so official team columns get a NULL
// mutex_group while staging/admin buckets keep theirs.
//
// Removal semantics: rows are CLOSED (removed_at + removed_reason),
// never hard-deleted — membership history is roster history.

namespace {

// Scalar subquery fragment: resolve a leagueapps user id (param $N)
// to a person id.  external_user_id is unique per alias row, so this
// is at most one person.
std::string personFromLa(const char* param) {
    return std::string(
        "(SELECT person_id FROM external_person_aliases "
        "  WHERE provider = 'leagueapps' AND external_user_id = ") +
        param + "::text)";
}

}  // namespace

MensTeamAssignments::MensTeamAssignments()
    : db_(Database::getInstance()),
      domain_("mens") {}

MensTeamAssignments::MensTeamAssignments(std::string domain)
    : db_(Database::getInstance()),
      domain_(std::move(domain)) {}

MensTeamAssignments::ByUser MensTeamAssignments::loadAll() {
    ByUser out;
    // One row per (person, team) active membership on this domain's
    // teams.  DISTINCT ON collapses multi-alias persons (post-merge
    // accounts) onto their most recent LA alias so each membership
    // renders exactly one board card.
    const auto rows = db_->query(
        "SELECT DISTINCT ON (tp.person_id, tp.team_id) "
        "       epa.external_user_id AS leagueapps_user_id, "
        "       tp.team_id, tp.on_roster, tp.coach_sort_order "
        "  FROM team_persons tp "
        "  JOIN teams t ON t.id = tp.team_id "
        "   AND t.gender_category = $1 "
        "  JOIN external_person_aliases epa "
        "    ON epa.person_id = tp.person_id "
        "   AND epa.provider = 'leagueapps' "
        " WHERE tp.removed_at IS NULL "
        " ORDER BY tp.person_id, tp.team_id, epa.id DESC",
        {domain_}
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
    const auto rows = db_->query(
        "SELECT tp.team_id FROM team_persons tp "
        "  JOIN teams t ON t.id = tp.team_id "
        "   AND t.gender_category = $1 "
        " WHERE tp.person_id = " + personFromLa("$2") +
        "   AND tp.removed_at IS NULL "
        " ORDER BY tp.id",
        {domain_, std::to_string(userId)}
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
    // Single transaction so the mutex-sibling closure, delinquent
    // restore and the upsert land atomically.
    auto tx = db_->beginTransaction();

    if (!mutexGroup.empty()) {
        // Close (not delete) active memberships on mutex-sibling teams
        // — one-of within the column group (teams.mutex_group since
        // migration 250 folded roster_columns into teams).
        tx->exec_params(
            "UPDATE team_persons tp "
            "   SET removed_at = now(), "
            "       removed_reason = 'board_move' "
            "  FROM teams c "
            " WHERE c.id = tp.team_id "
            "   AND c.gender_category = $4 "
            "   AND tp.person_id = " + personFromLa("$1") +
            "   AND c.mutex_group = $2 "
            "   AND tp.team_id <> $3 "
            "   AND tp.removed_at IS NULL",
            userId, mutexGroup, teamId, domain_
        );
    }

    // If the SAME (person, team) row exists but was soft-deleted for
    // delinquency, restore it in place so audit history + joined_at
    // are preserved.  Only touches 'delinquent' removals; other reasons
    // (manual removal etc.) are left alone.
    pqxx::result restored = tx->exec_params(
        "UPDATE team_persons "
        "   SET removed_at = NULL, "
        "       removed_reason = NULL, "
        "       removed_details = NULL "
        " WHERE person_id = " + personFromLa("$1") +
        "   AND team_id = $2 "
        "   AND removed_at IS NOT NULL "
        "   AND removed_reason = 'delinquent' "
        "   AND NOT EXISTS (SELECT 1 FROM team_persons a "
        "        WHERE a.person_id = team_persons.person_id "
        "          AND a.team_id = team_persons.team_id "
        "          AND a.removed_at IS NULL) "
        " RETURNING id",
        userId, teamId
    );

    if (restored.empty()) {
        tx->exec_params(
            "INSERT INTO team_persons (team_id, person_id) "
            "SELECT $2, epa.person_id "
            "  FROM external_person_aliases epa "
            " WHERE epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = $1::text "
            "ON CONFLICT (team_id, person_id) "
            "  WHERE removed_at IS NULL DO NOTHING",
            userId, teamId
        );
    }

    db_->commit(tx);
    return teamIdsForUser(userId);
}

std::vector<int> MensTeamAssignments::removeAssignment(long long userId, int teamId) {
    // Close, don't delete — membership history is roster history.
    db_->query(
        "UPDATE team_persons "
        "   SET removed_at = now(), "
        "       removed_reason = 'admin_remove' "
        " WHERE person_id = (SELECT person_id FROM external_person_aliases "
        "                     WHERE provider = 'leagueapps' AND external_user_id = $1::text) "
        "   AND team_id = $2 "
        "   AND removed_at IS NULL",
        {std::to_string(userId), std::to_string(teamId)}
    );
    return teamIdsForUser(userId);
}

std::optional<bool> MensTeamAssignments::setRosterStatus(long long userId,
                                                          int teamId,
                                                          bool onRoster) {
    const auto rows = db_->query(
        "UPDATE team_persons "
        "   SET on_roster = $3 "
        " WHERE person_id = (SELECT person_id FROM external_person_aliases "
        "                     WHERE provider = 'leagueapps' AND external_user_id = $1::text) "
        "   AND team_id = $2 "
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
            "UPDATE team_persons tp "
            "   SET removed_at      = NOW(), "
            "       removed_reason  = 'delinquent', "
            "       removed_details = $2::jsonb "
            "  FROM teams t "
            " WHERE t.id = tp.team_id "
            "   AND t.gender_category = $3 "
            "   AND tp.person_id = " + personFromLa("$1") +
            "   AND tp.removed_at IS NULL "
            " RETURNING tp.id",
            uid, j.str(), domain_
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
        // row already exists on the same (person, team) pair — e.g. admin
        // re-added them while they were dues-owed) simply skips instead
        // of aborting the whole transaction.
        pqxx::result candidates = tx->exec_params(
            "SELECT tp.id, tp.team_id FROM team_persons tp "
            "  JOIN teams t ON t.id = tp.team_id "
            "   AND t.gender_category = $2 "
            " WHERE tp.person_id = " + personFromLa("$1") +
            "   AND tp.removed_at IS NOT NULL "
            "   AND tp.removed_reason = 'delinquent' "
            " ORDER BY tp.id",
            uid, domain_
        );

        for (const auto& row : candidates) {
            if (row["id"].is_null() || row["team_id"].is_null()) continue;
            const long long rowId  = row["id"].as<long long>();
            const int       teamId = row["team_id"].as<int>();

            // Check no active row would collide.
            pqxx::result active = tx->exec_params(
                "SELECT 1 FROM team_persons "
                " WHERE person_id = " + personFromLa("$1") +
                "   AND team_id = $2 "
                "   AND removed_at IS NULL "
                " LIMIT 1",
                uid, teamId
            );
            if (!active.empty()) continue;

            pqxx::result upd = tx->exec_params(
                "UPDATE team_persons "
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
        // INSERT ... SELECT resolves the alias; inserts nothing when
        // the LA user has no linked person yet.  ON CONFLICT DO
        // NOTHING is a no-op when an active row already exists (the
        // partial unique index catches it).  For delinquency-removed
        // rows the caller is expected to have already run
        // bulkRestoreForDelinquent so the row is active again.
        pqxx::result r = tx->exec_params(
            "INSERT INTO team_persons (team_id, person_id) "
            "SELECT $2, epa.person_id "
            "  FROM external_person_aliases epa "
            " WHERE epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = $1::text "
            "ON CONFLICT (team_id, person_id) "
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
    // supplied order.  N is bounded by teams.max_roster (~25) so the
    // extra round-trips vs a single UNNEST/VALUES statement don't
    // matter — and the per-row form keeps the code readable.
    int rank = 1;
    for (long long uid : userIdsInOrder) {
        pqxx::result r = tx->exec_params(
            "UPDATE team_persons "
            "   SET coach_sort_order = $3 "
            " WHERE person_id = " + personFromLa("$1") +
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
