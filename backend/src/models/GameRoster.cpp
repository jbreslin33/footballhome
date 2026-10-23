#include "GameRoster.h"

#include "../database/Database.h"

#include <algorithm>
#include <map>
#include <set>
#include <stdexcept>

using nlohmann::json;

json GameRoster::team(const std::string& name) {
    auto* db = Database::getInstance();
    auto t = db->query(
        "SELECT id, name, level_band, COALESCE(formation_code, '') AS formation, "
        "       club_team_id IS NOT NULL AS has_club "
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
             "       COALESCE(description, '') AS description, lineup_slot "
             "  FROM game_demo_players WHERE team_id = $1::int "
             " ORDER BY lineup_slot NULLS LAST, shirt", {tid})) {   // = the daemon's slot order
        players.push_back({{"shirt", r["shirt"].as<int>()},
                           {"lineup_slot", r["lineup_slot"].is_null() ? json(nullptr) : json(r["lineup_slot"].as<int>())},
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
    json slots = json::array(), numbers = json::array();
    for (const auto& r : db->query(
             "SELECT e->>'label' AS label, n.shirt_number "
             "  FROM formations f CROSS JOIN jsonb_array_elements(f.positions_json::jsonb) e "
             "  LEFT JOIN formation_slot_numbers n "
             "         ON n.formation_code = f.code AND n.slot = (e->>'slot')::int "
             " WHERE f.code = $1 ORDER BY (e->>'slot')::int", {t[0]["formation"].as<std::string>()})) {
        slots.push_back(r["label"].as<std::string>());
        // mig 643: the slot's traditional shirt number (9 = the striker)
        numbers.push_back(r["shirt_number"].is_null() ? json(nullptr) : json(r["shirt_number"].as<int>()));
    }
    return {{"team", t[0]["name"].as<std::string>()},
            {"formation", t[0]["formation"].as<std::string>()},
            {"slots", slots},
            {"numbers", numbers},
            {"game_center", t[0]["has_club"].as<bool>()},
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

namespace {

int teamIdOf(pqxx::work& tx, const std::string& team) {
    auto r = tx.exec_params("SELECT id FROM game_demo_teams WHERE name = $1", team);
    if (r.empty()) throw std::invalid_argument("No such game team.");
    return r[0][0].as<int>();
}

std::vector<std::string> slotLabels(pqxx::work& tx, int teamId) {
    std::vector<std::string> out;
    for (const auto& r : tx.exec_params(
             "SELECT e->>'label' FROM game_demo_teams t JOIN formations f ON f.code = t.formation_code, "
             "       jsonb_array_elements(f.positions_json::jsonb) e "
             " WHERE t.id = $1 ORDER BY (e->>'slot')::int", teamId))
        out.push_back(r[0].as<std::string>());
    return out;
}

// Club lineup position (positions.name) → how well it fits a formation
// slot label: lower is better, 99 = doesn't.
int fitRank(const std::string& slot, const std::string& pos) {
    static const std::map<std::string, std::vector<std::string>> fit = {
        {"GK",  {"Goalkeeper"}},
        {"RB",  {"Right Back", "Right Wing Back", "Right Midfielder", "Center Back B", "Center Back"}},
        {"LB",  {"Left Back", "Left Wing Back", "Left Midfielder", "Center Back", "Center Back B"}},
        {"CB",  {"Center Back", "Center Back B", "Sweeper", "Defensive Midfielder", "Defensive Midfielder B",
                 "Right Back", "Left Back"}},
        {"CDM", {"Defensive Midfielder", "Defensive Midfielder B", "Central Midfielder", "Center Back B"}},
        {"CM",  {"Central Midfielder", "Defensive Midfielder", "Defensive Midfielder B", "Attacking Midfielder",
                 "Striker B", "Right Midfielder", "Left Midfielder"}},
        {"CAM", {"Attacking Midfielder", "Striker B", "Central Midfielder", "Striker"}},
        {"RW",  {"Right Winger", "Right Midfielder", "Striker B", "Striker", "Left Midfielder"}},
        {"LW",  {"Left Winger", "Left Midfielder", "Striker B", "Striker", "Right Midfielder"}},
        {"ST",  {"Striker", "Striker B", "Attacking Midfielder"}},
    };
    auto it = fit.find(slot);
    if (it == fit.end()) return 99;
    for (std::size_t i = 0; i < it->second.size(); ++i)
        if (it->second[i] == pos) return static_cast<int>(i);
    return 99;
}

}  // namespace

void GameRoster::afterLineup(pqxx::work& tx, int teamId) {
    const auto labels = slotLabels(tx, teamId);
    tx.exec_params("UPDATE game_demo_players SET position = 'SUB' WHERE team_id = $1 AND lineup_slot IS NULL",
                   teamId);
    for (std::size_t i = 0; i < labels.size(); ++i)
        tx.exec_params("UPDATE game_demo_players SET position = $3 WHERE team_id = $1 AND lineup_slot = $2",
                       teamId, static_cast<int>(i + 1), labels[i]);
    // Roles from the lineup (mig 639/642, reworked mig 661). Since mig 652 a
    // player PLAYS min(his team model's demand, his ability): the model asks
    // for man-marking, the line step and the cover; these rows only say WHO
    // holds a role, at the player's own quality — never an inflated number
    // (the old marking 90 / line-step 68 / cover 95 rows made a 60-rated
    // squad play like a 90 one; fh-game-match, DESIGN §8.38).
    auto scheme = tx.exec_params(
        "SELECT 1 FROM game_demo_player_concepts WHERE team_id = $1 AND concept = 'libero' AND rating > 0 LIMIT 1",
        teamId);
    if (scheme.empty()) return;
    tx.exec_params("DELETE FROM game_demo_player_concepts WHERE team_id = $1 "
                   "   AND concept IN ('marking', 'man-mark', 'cover', 'libero', 'cover-shadow')", teamId);
    // The free man (+1) [Bielsa]: the best-reading starting CB knows the
    // libero's job and marks nobody.
    tx.exec_params(
        "INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating) "
        "SELECT s.team_id, s.shirt, v.c, CASE WHEN v.c = 'libero' THEN s.q ELSE 0 END FROM ("
        "  SELECT p.team_id, p.shirt, COALESCE(p.quality, t.quality, 68) AS q FROM game_demo_players p "
        "    JOIN game_demo_teams t ON t.id = p.team_id "
        "    LEFT JOIN game_demo_player_attributes a ON a.team_id = p.team_id AND a.shirt = p.shirt "
        "         AND a.attribute IN ('anticipation', 'decisions') "
        "   WHERE p.team_id = $1 AND p.position = 'CB' AND p.lineup_slot IS NOT NULL "
        "   GROUP BY p.team_id, p.shirt, p.quality, t.quality "
        "   ORDER BY COALESCE(sum(a.rating), 0) DESC, p.shirt LIMIT 1) s "
        " CROSS JOIN (VALUES ('marking'), ('man-mark'), ('libero')) v(c) "
        "ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating",
        teamId);
    // The starting 9 presses on a cover shadow (mig 642) [Bielsa].
    tx.exec_params("INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating) "
                   "SELECT p.team_id, p.shirt, 'cover-shadow', COALESCE(p.quality, t.quality, 68) "
                   "  FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id "
                   " WHERE p.team_id = $1 AND p.lineup_slot IS NOT NULL AND p.position = 'ST' "
                   "ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating", teamId);
}

void GameRoster::saveLineup(const std::string& team, const std::vector<int>& shirts) {
    if (shirts.size() != 11) throw std::invalid_argument("A lineup is 11 shirts, GK first.");
    if (std::set<int>(shirts.begin(), shirts.end()).size() != 11)
        throw std::invalid_argument("A player can only start once.");
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        const int teamId = teamIdOf(*tx, team);
        for (int s : shirts)
            if (tx->exec_params("SELECT 1 FROM game_demo_players WHERE team_id = $1 AND shirt = $2", teamId, s).empty())
                throw std::invalid_argument("Shirt " + std::to_string(s) + " isn't on this team.");
        tx->exec_params("UPDATE game_demo_players SET lineup_slot = NULL WHERE team_id = $1", teamId);
        for (std::size_t i = 0; i < shirts.size(); ++i)
            tx->exec_params("UPDATE game_demo_players SET lineup_slot = $3 WHERE team_id = $1 AND shirt = $2",
                            teamId, shirts[i], static_cast<int>(i + 1));
        afterLineup(*tx, teamId);
        db->commit(tx);
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

json GameRoster::gameCenterLineups(const std::string& team) {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
             "SELECT m.id, m.match_date::text AS d, COALESCE(m.title, '') AS title, "
             "       count(*) FILTER (WHERE ml.is_starter) AS starters "
             "  FROM game_demo_teams t "
             "  JOIN matches m ON t.club_team_id IN (m.home_team_id, m.away_team_id) "
             "  JOIN match_lineups ml ON ml.match_id = m.id AND ml.team_id = t.club_team_id "
             " WHERE t.name = $1 AND m.cancelled_at IS NULL "
             " GROUP BY m.id HAVING count(*) FILTER (WHERE ml.is_starter) > 0 "
             " ORDER BY m.match_date DESC, m.id DESC LIMIT 20", {team}))
        out.push_back({{"match_id", r["id"].as<long long>()}, {"date", r["d"].as<std::string>()},
                       {"title", r["title"].as<std::string>()}, {"starters", r["starters"].as<int>()}});
    return out;
}

json GameRoster::importGameCenterLineup(const std::string& team, long long matchId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        const int teamId = teamIdOf(*tx, team);
        auto club = tx->exec_params("SELECT club_team_id FROM game_demo_teams WHERE id = $1", teamId);
        if (club[0][0].is_null()) throw std::invalid_argument("This team has no Game Center.");
        const int clubTeam = club[0][0].as<int>();
        auto starters = tx->exec_params(
            "SELECT DISTINCT ON (pl.person_id) pl.person_id, COALESCE(pos.name, '') AS pos, "
            "       COALESCE(NULLIF(trim(pe.first_name || ' ' || pe.last_name), ''), 'Player ' || pe.id) AS name "
            "  FROM match_lineups ml JOIN players pl ON pl.id = ml.player_id "
            "  JOIN persons pe ON pe.id = pl.person_id "
            "  LEFT JOIN positions pos ON pos.id = ml.position_id "
            " WHERE ml.match_id = $1 AND ml.team_id = $2 AND ml.is_starter "
            " ORDER BY pl.person_id, ml.slot_number",
            matchId, clubTeam);
        if (starters.size() < 11) throw std::invalid_argument("That Game Center lineup doesn't have 11 starters yet.");

        // Everyone in the XI needs a game player row; newcomers get the
        // mig-636 random draw (+ man-marking if the team plays it).
        int added = 0;
        std::map<long long, int> shirtOf;
        for (const auto& r : starters) {
            const long long pid = r["person_id"].as<long long>();
            auto have = tx->exec_params("SELECT shirt FROM game_demo_players WHERE team_id = $1 AND person_id = $2",
                                        teamId, pid);
            if (!have.empty()) { shirtOf[pid] = have[0][0].as<int>(); continue; }
            auto ns = tx->exec_params("SELECT COALESCE(max(shirt), 0) + 1 FROM game_demo_players WHERE team_id = $1",
                                      teamId);
            const int shirt = ns[0][0].as<int>();
            tx->exec_params("INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position) "
                            "VALUES ($1, $2, $3, 640, $4, 'SUB')",
                            teamId, shirt, r["name"].as<std::string>(), pid);
            tx->exec_params(
                "INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating) "
                "SELECT $1::int, $2::int, a.code, CASE WHEN a.code = 'goalkeeping' AND $4::text = 'Goalkeeper' "
                "                              THEN 60 + abs(hashtext($1::int || ':' || $3::int || ':' || a.code)) % 21 "
                "                            WHEN a.code = 'goalkeeping' THEN 15 + abs(hashtext($1::int || ':' || $3::int || ':' || a.code)) % 21 "
                "                            ELSE 40 + abs(hashtext($1::int || ':' || $3::int || ':' || a.code)) % 36 END "
                "  FROM game_attributes a",
                teamId, shirt, pid, r["pos"].as<std::string>());
            shirtOf[pid] = shirt;
            ++added;
        }

        // Greedy seat: each formation slot in order takes the free starter
        // whose club position fits it best; leftovers fill what's left.
        const auto labels = slotLabels(*tx, teamId);
        if (labels.size() != 11) throw std::invalid_argument("The team's formation isn't 11 slots.");
        std::vector<int> shirts(11, -1);
        std::vector<bool> used(starters.size(), false);
        for (std::size_t s = 0; s < 11; ++s) {
            int best = -1, bestRank = 99;
            for (std::size_t i = 0; i < starters.size(); ++i) {
                if (used[i]) continue;
                const int rk = fitRank(labels[s], starters[i]["pos"].as<std::string>());
                if (rk < bestRank) { bestRank = rk; best = static_cast<int>(i); }
            }
            if (best >= 0) {
                used[best] = true;
                shirts[s] = shirtOf[starters[best]["person_id"].as<long long>()];
            }
        }
        for (std::size_t s = 0; s < 11; ++s) {
            if (shirts[s] >= 0) continue;
            for (std::size_t i = 0; i < starters.size(); ++i)
                if (!used[i]) {
                    used[i] = true;
                    shirts[s] = shirtOf[starters[i]["person_id"].as<long long>()];
                    break;
                }
        }
        tx->exec_params("UPDATE game_demo_players SET lineup_slot = NULL WHERE team_id = $1", teamId);
        for (std::size_t i = 0; i < 11; ++i)
            tx->exec_params("UPDATE game_demo_players SET lineup_slot = $3 WHERE team_id = $1 AND shirt = $2",
                            teamId, shirts[i], static_cast<int>(i + 1));
        afterLineup(*tx, teamId);
        json names = json::array();
        for (const auto& r : tx->exec_params(
                 "SELECT name FROM game_demo_players WHERE team_id = $1 AND lineup_slot IS NOT NULL ORDER BY lineup_slot",
                 teamId))
            names.push_back(r[0].as<std::string>());
        db->commit(tx);
        return {{"slots", names}, {"added", added}};
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}
