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
        SELECT p.id AS person_id, p.first_name, p.last_name, n.jersey_number,
               rs.display_name AS roster_status,
               COALESCE((SELECT jsonb_agg(k.kit_item_id ORDER BY k.kit_item_id)
                           FROM person_kit_issues k WHERE k.person_id = p.id), '[]'::jsonb)::text AS issued
          FROM team_persons tp
          JOIN persons p ON p.id = tp.person_id
          JOIN teams t ON t.id = tp.team_id
          LEFT JOIN person_uniform_numbers n
                 ON n.uniform_set_id = team_uniform_set_id(t.id) AND n.person_id = p.id
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

json KitBoard::sharedWith(long long teamId) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT COALESCE(o.label, o.name) AS label
          FROM teams t JOIN teams o ON team_uniform_set_id(o.id) = team_uniform_set_id(t.id) AND o.id <> t.id
         WHERE t.id = $1::int AND o.is_active AND o.board_sort_order IS NOT NULL
         ORDER BY o.board_sort_order, o.name)SQL", {std::to_string(teamId)});
    json out = json::array();
    for (const auto& r : rows) out.push_back(r["label"].c_str());
    return out;
}

// Only someone still on one of the set's teams holds a number; a row left
// behind by a player who has gone is free to give out.
std::string KitBoard::numberHolder(long long teamId, long long personId, const std::string& number) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,''))
               || ' (' || string_agg(COALESCE(ot.label, ot.name), ', ' ORDER BY ot.board_sort_order) || ')' AS name
          FROM teams t
          JOIN person_uniform_numbers n ON n.uniform_set_id = team_uniform_set_id(t.id)
          JOIN persons p ON p.id = n.person_id
          JOIN teams ot ON team_uniform_set_id(ot.id) = n.uniform_set_id
          JOIN team_persons tp ON tp.team_id = ot.id AND tp.person_id = p.id AND tp.removed_at IS NULL
         WHERE t.id = $1::int AND n.jersey_number = $3 AND n.person_id <> $2::int
         GROUP BY p.id, p.first_name, p.last_name
         LIMIT 1)SQL", {std::to_string(teamId), std::to_string(personId), number});
    return rows.empty() ? std::string() : std::string(rows[0]["name"].c_str());
}

bool KitBoard::setNumber(long long teamId, long long personId, const std::string& number,
                         long long byUserId) {
    auto* db = Database::getInstance();
    auto set = db->query("SELECT team_uniform_set_id($1::int) AS uniform_set_id", {std::to_string(teamId)});
    if (set.empty() || set[0]["uniform_set_id"].is_null()) return false;
    const std::string setId = std::to_string(set[0]["uniform_set_id"].as<long long>());

    if (number.empty()) {
        db->query("DELETE FROM person_uniform_numbers WHERE uniform_set_id = $1::int AND person_id = $2::int",
                  {setId, std::to_string(personId)});
        return true;
    }
    // Release the number from whoever left it behind (numberHolder has
    // already ruled out anyone still playing in this set).
    db->query("DELETE FROM person_uniform_numbers "
              " WHERE uniform_set_id = $1::int AND jersey_number = $3 AND person_id <> $2::int",
              {setId, std::to_string(personId), number});
    db->query("INSERT INTO person_uniform_numbers (uniform_set_id, person_id, jersey_number, assigned_by_user_id) "
              "VALUES ($1::int, $2::int, $3, NULLIF($4, '0')::int) "
              "ON CONFLICT (uniform_set_id, person_id) DO UPDATE "
              "   SET jersey_number = EXCLUDED.jersey_number, assigned_at = now(), "
              "       assigned_by_user_id = EXCLUDED.assigned_by_user_id",
              {setId, std::to_string(personId), number, std::to_string(byUserId)});
    return true;
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
