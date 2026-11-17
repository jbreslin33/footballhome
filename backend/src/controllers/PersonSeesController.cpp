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
    router.post(prefix + "/restrain", [this](const Request& r) { return handleRestrain(r); });
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
        }
        return jsonOut(HttpStatus::OK, {{"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "PersonSeesController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// 🚫 Restrain (mig 1443): the game_restraints trigger re-syncs the
// official-list invites, so the change shows on every screen at once.
Response PersonSeesController::handleRestrain(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    long long personId = 0, teamId = 0;
    bool restrained = true;
    try {
        const json body = json::parse(request.getBody());
        personId   = body.value("person_id", 0LL);
        teamId     = body.value("team_id", 0LL);
        restrained = body.value("restrained", true);
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "person_id, team_id and restrained are required");
    }
    if (personId <= 0 || teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id and team_id are required");
    try {
        auto* db = Database::getInstance();
        if (db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {std::to_string(userId)}).empty())
            return jsonError(HttpStatus::FORBIDDEN, "For club admins.");
        if (restrained)
            db->query("INSERT INTO game_restraints (person_id, team_id, created_by_user_id) VALUES ($1::int, $2::int, $3::int) "
                      "ON CONFLICT DO NOTHING",
                      {std::to_string(personId), std::to_string(teamId), std::to_string(userId)});
        else
            db->query("DELETE FROM game_restraints WHERE person_id = $1::int AND team_id = $2::int",
                      {std::to_string(personId), std::to_string(teamId)});
        json people = json::object();
        const std::string lit = "{" + std::to_string(personId) + "}";
        for (const auto& r : db->query("SELECT person_id, sees::text AS sees, suspended, injured FROM fh_person_sees($1::int[])", {lit}))
            people[r["person_id"].c_str()] = {{"sees", json::parse(r["sees"].c_str())},
                                              {"suspended", r["suspended"].as<bool>()},
                                              {"injured", r["injured"].as<bool>()}};
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"people", people}});
    } catch (const std::exception& e) {
        std::cerr << "PersonSeesController::handleRestrain: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
