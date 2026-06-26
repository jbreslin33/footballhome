#include "MensTeamAssignments.h"

#include <algorithm>
#include <pqxx/pqxx>
#include "../database/Database.h"

MensTeamAssignments::MensTeamAssignments()
    : db_(Database::getInstance()) {}

MensTeamAssignments::ByUser MensTeamAssignments::loadAll() {
    ByUser out;
    const auto rows = db_->query(
        "SELECT leagueapps_user_id, team_id, on_roster FROM mens_team_assignments"
    );
    for (const auto& row : rows) {
        if (row["leagueapps_user_id"].is_null() || row["team_id"].is_null()) continue;
        const std::string uid = row["leagueapps_user_id"].c_str();
        Cell c;
        c.teamId   = row["team_id"].as<int>();
        c.onRoster = !row["on_roster"].is_null() && row["on_roster"].as<bool>();
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
    // Single transaction so the mutex-sibling DELETE and the upsert land
    // atomically — mirrors the Node BEGIN/COMMIT semantics.
    auto tx = db_->beginTransaction();

    if (!mutexGroup.empty()) {
        tx->exec_params(
            "DELETE FROM mens_team_assignments a "
            "  USING mens_team_columns c "
            "  WHERE a.team_id = c.team_id "
            "    AND a.leagueapps_user_id = $1 "
            "    AND c.mutex_group = $2 "
            "    AND a.team_id <> $3",
            userId, mutexGroup, teamId
        );
    }

    tx->exec_params(
        "INSERT INTO mens_team_assignments (leagueapps_user_id, team_id, assigned_by_user_id) "
        "VALUES ($1, $2, NULL) "
        "ON CONFLICT (leagueapps_user_id, team_id) DO NOTHING",
        userId, teamId
    );

    pqxx::result after = tx->exec_params(
        "SELECT team_id FROM mens_team_assignments "
        " WHERE leagueapps_user_id = $1 "
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
    db_->query(
        "DELETE FROM mens_team_assignments "
        " WHERE leagueapps_user_id = $1 AND team_id = $2",
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
        " RETURNING on_roster",
        {std::to_string(userId), std::to_string(teamId), onRoster ? "true" : "false"}
    );
    if (rows.empty()) return std::nullopt;
    return rows[0]["on_roster"].is_null() ? false : rows[0]["on_roster"].as<bool>();
}
