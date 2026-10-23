#include "GameRoster.h"

#include "../database/Database.h"

using nlohmann::json;

json GameRoster::team(const std::string& name) {
    auto* db = Database::getInstance();
    auto t = db->query(
        "SELECT id, name, level_band, COALESCE(formation_code, '') AS formation "
        "  FROM game_demo_teams WHERE name = $1", {name});
    if (t.empty()) return nullptr;
    const std::string tid = t[0]["id"].as<std::string>();

    json attributes = json::array();
    for (const auto& r : db->query(
             "SELECT code, name, category, description FROM game_attributes ORDER BY sort_order"))
        attributes.push_back({{"code", r["code"].as<std::string>()},
                              {"name", r["name"].as<std::string>()},
                              {"category", r["category"].as<std::string>()},
                              {"description", r["description"].as<std::string>()}});

    json players = json::array();
    for (const auto& r : db->query(
             "SELECT shirt, name, COALESCE(position, '') AS position, "
             "       COALESCE(description, '') AS description "
             "  FROM game_demo_players WHERE team_id = $1::int ORDER BY shirt", {tid})) {
        players.push_back({{"shirt", r["shirt"].as<int>()},
                           {"name", r["name"].as<std::string>()},
                           {"position", r["position"].as<std::string>()},
                           {"description", r["description"].as<std::string>()},
                           {"attrs", json::object()}});
    }
    for (const auto& r : db->query(
             "SELECT shirt, attribute, rating FROM game_demo_player_attributes "
             " WHERE team_id = $1::int", {tid})) {
        for (auto& p : players)
            if (p["shirt"] == r["shirt"].as<int>())
                p["attrs"][r["attribute"].as<std::string>()] = r["rating"].as<int>();
    }
    return {{"team", t[0]["name"].as<std::string>()},
            {"formation", t[0]["formation"].as<std::string>()},
            {"level_band", t[0]["level_band"].as<std::string>()},
            {"attributes", attributes},
            {"players", players}};
}

bool GameRoster::savePlayer(const std::string& team, int shirt, const json& attrs,
                            const json& description) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto p = tx->exec_params(
            "SELECT p.team_id FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id "
            " WHERE t.name = $1 AND p.shirt = $2",
            team, shirt);
        if (p.empty()) {
            db->rollback(tx);
            return false;
        }
        const int teamId = p[0][0].as<int>();
        if (description.is_string())
            tx->exec_params(
                "UPDATE game_demo_players SET description = NULLIF($3, '') "
                " WHERE team_id = $1 AND shirt = $2",
                teamId, shirt, description.get<std::string>());
        for (auto it = attrs.begin(); it != attrs.end(); ++it) {
            if (it.value().is_null()) {
                tx->exec_params(
                    "DELETE FROM game_demo_player_attributes "
                    " WHERE team_id = $1 AND shirt = $2 AND attribute = $3",
                    teamId, shirt, it.key());
            } else {
                tx->exec_params(
                    "INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating) "
                    "VALUES ($1, $2, $3, $4) "
                    "ON CONFLICT (team_id, shirt, attribute) DO UPDATE SET rating = EXCLUDED.rating",
                    teamId, shirt, it.key(), it.value().get<int>());
            }
        }
        db->commit(tx);
        return true;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}
