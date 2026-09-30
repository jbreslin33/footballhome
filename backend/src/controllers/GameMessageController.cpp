#include "GameMessageController.h"

#include <iostream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}}); }

long long idFromPath(const std::string& path) {
    // /api/game-message/<id>/recipients
    const std::string key = "/game-message/";
    auto p = path.find(key); if (p == std::string::npos) return 0;
    p += key.size(); auto e = path.find('/', p);
    try { return std::stoll(path.substr(p, e == std::string::npos ? std::string::npos : e - p)); } catch (...) { return 0; }
}

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

// The game's teams: what its calendar event is tagged with, else home/away.
constexpr const char* kTeamsOf = R"SQL(
    COALESCE(
        (SELECT array_agg(DISTINCT fet.team_id) FROM fh_events fe JOIN fh_event_teams fet ON fet.fh_event_id = fe.id WHERE fe.match_id = $1::int),
        (SELECT array_remove(ARRAY[m.home_team_id, m.away_team_id], NULL) FROM matches m WHERE m.id = $1::int)))SQL";

} // namespace

void GameMessageController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/:matchId/recipients", [this](const Request& r) { return handleRecipients(r); });
}

Response GameMessageController::handleRecipients(const Request& request) {
    const long long matchId = idFromPath(request.getPath());
    if (matchId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "match id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        const std::string mid = std::to_string(matchId), uid = std::to_string(userId);

        auto gate = db->query(std::string(R"SQL(
            WITH teams_of AS (SELECT )SQL") + kTeamsOf + R"SQL( AS ids)
            SELECT EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id WHERE a.user_id = u.id AND al.name IN ('club','super'))
                OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                            WHERE co.person_id = u.person_id AND tc.ended_at IS NULL AND tc.team_id = ANY(t.ids)) AS allowed
              FROM users u CROSS JOIN teams_of t WHERE u.id = $2::int)SQL", {mid, uid});
        if (gate.empty() || !gate[0]["allowed"].as<bool>())
            return jsonError(HttpStatus::FORBIDDEN, "Messaging a game is for its coaches.");

        auto rows = db->query(std::string(R"SQL(
            WITH teams_of AS (SELECT )SQL") + kTeamsOf + R"SQL( AS ids),
            roster AS (
                SELECT DISTINCT tp.person_id FROM team_persons tp, teams_of t
                 WHERE tp.removed_at IS NULL AND tp.team_id = ANY(t.ids)
            )
            SELECT p.id AS person_id,
                   NULLIF(trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), '') AS name,
                   (p.parent_person_id IS NOT NULL) AS via_parent,
                   COALESCE(rv.response, 'none') AS rsvp,
                   ph.phone_number AS phone, em.email AS email
              FROM roster r
              JOIN persons p ON p.id = r.person_id
              -- The answer given to this game (its calendar event), latest first.
              LEFT JOIN LATERAL (
                    SELECT x.response FROM fh_event_rsvps x
                      JOIN fh_events fe ON fe.id = x.fh_event_id AND fe.match_id = $1::int
                     WHERE x.person_id = p.id
                     ORDER BY x.responded_at DESC LIMIT 1) rv ON true
              -- Contact: the parent's for youth, falling back to the player's own.
              LEFT JOIN LATERAL (
                    SELECT x.phone_number FROM person_phones x
                     WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                       AND COALESCE(x.can_receive_sms, true)
                     ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                              x.is_primary DESC NULLS LAST, x.id LIMIT 1) ph ON true
              LEFT JOIN LATERAL (
                    SELECT x.email FROM person_emails x
                     WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                     ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                              x.is_primary DESC NULLS LAST, x.id LIMIT 1) em ON true
             ORDER BY p.last_name, p.first_name)SQL", {mid});

        json people = json::array();
        for (const auto& r : rows) {
            people.push_back({{"personId", r["person_id"].as<long long>()}, {"name", str(r, "name")},
                              {"rsvp", str(r, "rsvp")}, {"viaParent", r["via_parent"].as<bool>()},
                              {"email", r["email"].is_null() ? json(nullptr) : json(str(r, "email"))},
                              {"phone", r["phone"].is_null() ? json(nullptr) : json(str(r, "phone"))}});
        }
        return jsonOut(HttpStatus::OK, {{"success", true}, {"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/game-message/recipients] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
