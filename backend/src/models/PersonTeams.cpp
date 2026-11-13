#include "PersonTeams.h"

#include "../database/Database.h"

using nlohmann::json;

json PersonTeams::board(long long personId, long long viewerUserId) {
    auto* db = Database::getInstance();
    const auto rows = db->query(
        "WITH viewer AS ("
        "  SELECT EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
        "                  WHERE a.user_id = $2::int AND al.name IN ('club', 'super')) AS admin), "
        "mine AS (SELECT tp.team_id FROM team_persons tp WHERE tp.person_id = $1::int AND tp.removed_at IS NULL), "
        "board AS (SELECT t.id, t.gender_category, COALESCE(t.label, t.name) AS label, "
        "                 COALESCE(t.short_label, t.label, t.name) AS short_label, t.board_sort_order "
        "            FROM teams t WHERE t.board_sort_order IS NOT NULL AND t.is_active), "
        "doms AS (SELECT DISTINCT b.gender_category FROM board b JOIN mine m ON m.team_id = b.id) "
        "SELECT b.id, b.gender_category, b.label, b.short_label, "
        "       EXISTS (SELECT 1 FROM mine m WHERE m.team_id = b.id) AS on_team, "
        "       fh_on_league_list(b.id, $1::int) AS locked, "
        "       (v.admin OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
        "                            JOIN users u ON u.person_id = co.person_id "
        "                           WHERE u.id = $2::int AND tc.team_id = b.id)) AS can_manage "
        "  FROM board b CROSS JOIN viewer v "
        " WHERE NOT EXISTS (SELECT 1 FROM doms) OR b.gender_category IN (SELECT gender_category FROM doms) "
        " ORDER BY (SELECT min(x.board_sort_order) FROM board x WHERE x.gender_category = b.gender_category) "
        "          , b.gender_category, b.board_sort_order",
        {std::to_string(personId), std::to_string(viewerUserId)});
    json teams = json::array();
    for (const auto& r : rows) {
        teams.push_back({
            {"teamId", r["id"].as<long long>()},
            {"domain", r["gender_category"].is_null() ? "" : r["gender_category"].c_str()},
            {"label", r["label"].c_str()},
            {"short", r["short_label"].c_str()},
            {"on", r["on_team"].as<bool>()},
            {"locked", r["locked"].as<bool>()},
            {"canManage", r["can_manage"].as<bool>()},
        });
    }
    return {{"personId", personId}, {"teams", teams}};
}

std::optional<std::string> PersonTeams::boardDomain(int teamId) {
    const auto rows = Database::getInstance()->query(
        "SELECT gender_category FROM teams WHERE id = $1::int AND board_sort_order IS NOT NULL AND is_active",
        {std::to_string(teamId)});
    if (rows.empty() || rows[0][0].is_null()) return std::nullopt;
    return std::string(rows[0][0].c_str());
}

bool PersonTeams::onTeam(long long personId, int teamId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM team_persons WHERE person_id = $1::int AND team_id = $2::int AND removed_at IS NULL",
        {std::to_string(personId), std::to_string(teamId)}).empty();
}

bool PersonTeams::onLeagueList(long long personId, int teamId) {
    return !Database::getInstance()->query(
        "SELECT 1 WHERE fh_on_league_list($1::int, $2::int)",
        {std::to_string(teamId), std::to_string(personId)}).empty();
}
