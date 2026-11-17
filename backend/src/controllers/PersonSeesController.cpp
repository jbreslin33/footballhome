#include "PersonSeesController.h"

#include <iostream>
#include <sstream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message) {
    return jsonOut(s, {{"error", message}});
}

// Admins and live coaches — the #teams boards' viewers (PersonHealth's gate).
bool isStaff(long long userId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM admins WHERE user_id = $1::int "
        "UNION ALL SELECT 1 FROM users u JOIN coaches co ON co.person_id = u.person_id "
        "  JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL WHERE u.id = $1::int LIMIT 1",
        {std::to_string(userId)}).empty();
}

}  // namespace

void PersonSeesController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleGet(r); });
    router.post(prefix + "/set", [this](const Request& r) { return handleSet(r); });
    router.post(prefix + "/restrain", [this](const Request& r) { return handleSet(r); });
}

Response PersonSeesController::handleGet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    // ids=1,2,3 → a Postgres int[] literal of digits only.
    std::string lit = "{";
    {
        std::istringstream in(request.getQueryParam("ids"));
        std::string tok;
        int n = 0;
        while (std::getline(in, tok, ',')) {
            if (tok.empty() || tok.size() > 9 || tok.find_first_not_of("0123456789") != std::string::npos) continue;
            if (++n > 2000) break;
            lit += (lit.size() > 1 ? "," : "") + tok;
        }
    }
    lit += "}";
    try {
        if (!isStaff(userId)) return jsonError(HttpStatus::FORBIDDEN, "For club admins and coaches.");
        json people = json::object();
        if (lit != "{}") {
            auto* db = Database::getInstance();
            for (const auto& r : db->query("SELECT person_id, sees::text AS sees, suspended, injured FROM fh_person_sees($1::int[])", {lit})) {
                people[r["person_id"].c_str()] = {
                    {"sees", json::parse(r["sees"].c_str())},
                    {"suspended", r["suspended"].as<bool>()},
                    {"injured", r["injured"].as<bool>()},
                    {"rosters", json::array()},
                };
            }
            for (const auto& r : db->query("SELECT person_id, rosters::text AS rosters FROM fh_person_rosters($1::int[])", {lit})) {
                const std::string id = r["person_id"].c_str();
                if (people.contains(id)) people[id]["rosters"] = json::parse(r["rosters"].c_str());
            }
            // ＋ on SEES: a league call-down rule from a team he is on (team
            // row or official list) to one he does not see yet.
            for (const auto& r : db->query(R"SQL(
                    SELECT DISTINCT ON (x.person_id, c.to_team_id) x.person_id, c.to_team_id AS team_id, c.from_team_id,
                           COALESCE(NULLIF(t.short_label, ''), NULLIF(t.label, ''), t.name) AS team
                      FROM (SELECT tp.person_id, tp.team_id FROM team_persons tp
                             WHERE tp.removed_at IS NULL AND tp.person_id = ANY($1::int[])
                            UNION
                            SELECT n.person_id, s.games_team_id FROM official_roster_names n
                              JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active AND s.games_team_id IS NOT NULL
                             WHERE n.person_id = ANY($1::int[])) x
                      JOIN team_invite_caps c ON c.from_team_id = x.team_id
                      JOIN teams t ON t.id = c.to_team_id
                     WHERE NOT EXISTS (SELECT 1 FROM person_team_sees s WHERE s.person_id = x.person_id
                                          AND s.team_id = c.to_team_id AND s.sees AND s.ended_at IS NULL)
                       AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = x.person_id
                                          AND tp.team_id = c.to_team_id AND tp.removed_at IS NULL)
                     ORDER BY x.person_id, c.to_team_id, c.from_team_id)SQL", {lit})) {
                const std::string id = r["person_id"].c_str();
                if (!people.contains(id)) continue;
                if (!people[id].contains("call_down")) people[id]["call_down"] = json::array();
                people[id]["call_down"].push_back({{"team_id", r["team_id"].as<long long>()}, {"team", r["team"].c_str()},
                                                   {"from_team_id", r["from_team_id"].as<long long>()}});
            }
        }
        return jsonOut(HttpStatus::OK, {{"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "PersonSeesController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// 👁 Set SEES for one team (mig 1450): yes = standing call-down, no =
// restrained, null = the roster decides again. The fh_event_invites view
// computes every game from it at once — nothing to sync.
Response PersonSeesController::handleSet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    long long personId = 0, teamId = 0;
    std::string want;   // "yes" | "no" | "" (clear)
    try {
        const json body = json::parse(request.getBody());
        personId = body.value("person_id", 0LL);
        teamId   = body.value("team_id", 0LL);
        if (body.contains("sees")) want = body["sees"].is_null() ? "" : (body["sees"].get<bool>() ? "yes" : "no");
        else if (body.contains("restrained")) want = body.value("restrained", true) ? "no" : "";
        else return jsonError(HttpStatus::BAD_REQUEST, "sees is required (true, false or null)");
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "person_id, team_id and sees are required");
    }
    if (personId <= 0 || teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id and team_id are required");
    try {
        auto* db = Database::getInstance();
        if (db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {std::to_string(userId)}).empty())
            return jsonError(HttpStatus::FORBIDDEN, "For club admins.");
        const std::string p = std::to_string(personId), t = std::to_string(teamId), u = std::to_string(userId);
        std::string fromTeam;
        if (want == "yes") {
            // the team he comes down from: one he is on, with a league rule
            auto f = db->query(R"SQL(
                SELECT c.from_team_id FROM team_invite_caps c
                 WHERE c.to_team_id = $2::int
                   AND (EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = $1::int AND tp.team_id = c.from_team_id AND tp.removed_at IS NULL)
                        OR EXISTS (SELECT 1 FROM official_roster_names n JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active
                                    WHERE n.person_id = $1::int AND s.games_team_id = c.from_team_id))
                 ORDER BY c.from_team_id LIMIT 1)SQL", {p, t});
            if (f.empty()) return jsonError(HttpStatus::BAD_REQUEST, "No league call-down rule from a team he is on to that team.");
            fromTeam = f[0]["from_team_id"].c_str();
        }
        // close the open row unless it already says the same thing
        db->query("UPDATE person_team_sees SET ended_at = now(), ended_by_user_id = $3::int "
                  " WHERE person_id = $1::int AND team_id = $2::int AND ended_at IS NULL "
                  "   AND ($4 = '' OR sees <> ($4 = 'yes'))", {p, t, u, want});
        if (!want.empty())
            db->query("INSERT INTO person_team_sees (person_id, team_id, sees, from_team_id, created_by_user_id) "
                      "SELECT $1::int, $2::int, $4 = 'yes', NULLIF($5, '')::int, $3::int "
                      " WHERE NOT EXISTS (SELECT 1 FROM person_team_sees WHERE person_id = $1::int AND team_id = $2::int "
                      "                     AND ended_at IS NULL)", {p, t, u, want, fromTeam});
        json people = json::object();
        const std::string lit = "{" + std::to_string(personId) + "}";
        for (const auto& r : db->query("SELECT person_id, sees::text AS sees, suspended, injured FROM fh_person_sees($1::int[])", {lit}))
            people[r["person_id"].c_str()] = {{"sees", json::parse(r["sees"].c_str())},
                                              {"suspended", r["suspended"].as<bool>()},
                                              {"injured", r["injured"].as<bool>()}};
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "PersonSeesController::handleSet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
