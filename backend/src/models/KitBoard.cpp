#include "KitBoard.h"

#include <sstream>

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string pgArray(const std::vector<long long>& ids) {
    std::ostringstream out;
    out << '{';
    for (size_t i = 0; i < ids.size(); ++i) { if (i) out << ','; out << ids[i]; }
    out << '}';
    return out.str();
}

}  // namespace

json KitBoard::teams(const std::vector<long long>& scopeTeamIds) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT t.id, t.name, t.label, cs.code AS section,
               (SELECT count(*) FROM team_persons tp
                 WHERE tp.team_id = t.id AND tp.removed_at IS NULL) AS players
          FROM teams t
          LEFT JOIN club_sections cs ON cs.id = t.club_section_id
         WHERE t.is_active AND t.board_sort_order IS NOT NULL
           AND ($1::bigint[] = '{}' OR t.id = ANY($1::bigint[]))
         ORDER BY cs.sort_order NULLS LAST, t.board_sort_order, t.name)SQL", {pgArray(scopeTeamIds)});
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({
            {"id",      r["id"].as<long long>()},
            {"name",    r["name"].c_str()},
            {"label",   r["label"].is_null() ? json(nullptr) : json(r["label"].c_str())},
            {"section", r["section"].is_null() ? json(nullptr) : json(r["section"].c_str())},
            {"players", r["players"].as<int>()},
        });
    }
    return out;
}

json KitBoard::items() {
    auto rows = Database::getInstance()->query(
        "SELECT id, code, label, icon FROM kit_items WHERE is_active ORDER BY sort_order, id");
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({
            {"id",    r["id"].as<long long>()},
            {"code",  r["code"].c_str()},
            {"label", r["label"].c_str()},
            {"icon",  r["icon"].is_null() ? json(nullptr) : json(r["icon"].c_str())},
        });
    }
    return out;
}

json KitBoard::roster(long long teamId) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT p.id AS person_id, p.first_name, p.last_name, tp.jersey_number,
               rs.display_name AS roster_status,
               COALESCE((SELECT jsonb_agg(k.kit_item_id ORDER BY k.kit_item_id)
                           FROM person_kit_issues k WHERE k.person_id = p.id), '[]'::jsonb)::text AS issued
          FROM team_persons tp
          JOIN persons p ON p.id = tp.person_id
          LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
         WHERE tp.team_id = $1::int AND tp.removed_at IS NULL
         ORDER BY p.last_name, p.first_name, p.id)SQL", {std::to_string(teamId)});
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({
            {"person_id",     r["person_id"].as<long long>()},
            {"first_name",    r["first_name"].is_null() ? "" : r["first_name"].c_str()},
            {"last_name",     r["last_name"].is_null()  ? "" : r["last_name"].c_str()},
            {"jersey_number", r["jersey_number"].is_null() ? json(nullptr) : json(r["jersey_number"].c_str())},
            {"roster_status", r["roster_status"].is_null() ? json(nullptr) : json(r["roster_status"].c_str())},
            {"issued",        json::parse(r["issued"].c_str())},
        });
    }
    return out;
}

bool KitBoard::onTeam(long long teamId, long long personId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM team_persons WHERE team_id = $1::int AND person_id = $2::int AND removed_at IS NULL",
        {std::to_string(teamId), std::to_string(personId)}).empty();
}

std::string KitBoard::numberHolder(long long teamId, long long personId, const std::string& number) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name
          FROM team_persons tp JOIN persons p ON p.id = tp.person_id
         WHERE tp.team_id = $1::int AND tp.removed_at IS NULL
           AND tp.jersey_number = $3 AND tp.person_id <> $2::int
         LIMIT 1)SQL", {std::to_string(teamId), std::to_string(personId), number});
    return rows.empty() ? std::string() : std::string(rows[0]["name"].c_str());
}

void KitBoard::setNumber(long long teamId, long long personId, const std::string& number) {
    Database::getInstance()->query(
        "UPDATE team_persons SET jersey_number = NULLIF($3, '') "
        " WHERE team_id = $1::int AND person_id = $2::int AND removed_at IS NULL",
        {std::to_string(teamId), std::to_string(personId), number});
}

bool KitBoard::setIssued(long long personId, long long kitItemId, bool issued, long long byUserId) {
    auto* db = Database::getInstance();
    if (db->query("SELECT 1 FROM kit_items WHERE id = $1::int AND is_active",
                  {std::to_string(kitItemId)}).empty()) {
        return false;
    }
    if (issued) {
        db->query(
            "INSERT INTO person_kit_issues (person_id, kit_item_id, issued_by_user_id) "
            "VALUES ($1::int, $2::int, NULLIF($3, '0')::int) "
            "ON CONFLICT (person_id, kit_item_id) DO NOTHING",
            {std::to_string(personId), std::to_string(kitItemId), std::to_string(byUserId)});
    } else {
        db->query("DELETE FROM person_kit_issues WHERE person_id = $1::int AND kit_item_id = $2::int",
                  {std::to_string(personId), std::to_string(kitItemId)});
    }
    return true;
}
