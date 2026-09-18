#include "KitBoardController.h"

#include <algorithm>
#include <cctype>
#include <iostream>

#include "../database/Database.h"
#include "../models/KitBoard.h"
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

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}

long long intField(const json& body, const char* key) {
    if (!body.contains(key) || !body[key].is_number_integer()) return 0;
    return body[key].get<long long>();
}

std::string trim(std::string s) {
    auto notSpace = [](unsigned char c) { return !std::isspace(c); };
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), notSpace));
    s.erase(std::find_if(s.rbegin(), s.rend(), notSpace).base(), s.end());
    return s;
}

}  // namespace

KitBoardController::KitBoardController() : model_(std::make_unique<KitBoard>()) {}
KitBoardController::~KitBoardController() = default;

void KitBoardController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/teams",  [this](const Request& r) { return handleTeams(r); });
    router.get (prefix + "/roster", [this](const Request& r) { return handleRoster(r); });
    router.put (prefix + "/number", [this](const Request& r) { return handleSetNumber(r); });
    router.put (prefix + "/issued", [this](const Request& r) { return handleSetIssued(r); });
}

bool KitBoardController::Scope::covers(long long teamId) const {
    return isAdmin ||
           std::find(coachTeamIds.begin(), coachTeamIds.end(), teamId) != coachTeamIds.end();
}

bool KitBoardController::resolveScope(const Request& request, Scope* scope, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->userId = bearerUserId(request);
    auto* db = Database::getInstance();
    scope->isAdmin = !db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                {std::to_string(scope->userId)}).empty();
    if (scope->isAdmin) return true;

    auto teams = db->query(
        "SELECT DISTINCT tc.team_id FROM team_coaches tc "
        "  JOIN coaches c ON c.id = tc.coach_id "
        "  JOIN users u ON u.person_id = c.person_id "
        " WHERE u.id = $1::int AND tc.ended_at IS NULL",
        {std::to_string(scope->userId)});
    for (const auto& row : teams) scope->coachTeamIds.push_back(row["team_id"].as<long long>());
    if (scope->coachTeamIds.empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN,
                           "The kit board is for club admins and coaches of a team.");
        return false;
    }
    return true;
}

Response KitBoardController::handleTeams(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    try {
        return jsonOut(HttpStatus::OK, {{"teams", model_->teams(scope.coachTeamIds)}});
    } catch (const std::exception& e) {
        std::cerr << "KitBoardController::handleTeams: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response KitBoardController::handleRoster(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    long long teamId = 0;
    try { teamId = std::stoll(request.getQueryParam("team_id")); } catch (...) {}
    if (teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team_id required");
    if (!scope.covers(teamId)) return jsonError(HttpStatus::FORBIDDEN, "Not one of your teams.");
    try {
        return jsonOut(HttpStatus::OK, {{"team_id", teamId},
                                        {"shared_with", model_->sharedWith(teamId)},
                                        {"items",   model_->items()},
                                        {"players", model_->roster(teamId)}});
    } catch (const std::exception& e) {
        std::cerr << "KitBoardController::handleRoster: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /number  { team_id, person_id, jersey_number }   ("" or null clears)
Response KitBoardController::handleSetNumber(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;

    const long long teamId   = intField(body, "team_id");
    const long long personId = intField(body, "person_id");
    if (teamId <= 0 || personId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "team_id and person_id required");
    }
    if (!scope.covers(teamId)) return jsonError(HttpStatus::FORBIDDEN, "Not one of your teams.");

    std::string number;
    if (body.contains("jersey_number") && !body["jersey_number"].is_null()) {
        number = body["jersey_number"].is_string() ? body["jersey_number"].get<std::string>()
                                                   : body["jersey_number"].dump();
    }
    number = trim(number);
    if (number.size() > 3 || !std::all_of(number.begin(), number.end(),
                                          [](unsigned char c) { return std::isdigit(c); })) {
        return jsonError(HttpStatus::BAD_REQUEST, "A number is 1–3 digits.");
    }
    // "07" and "7" are the same shirt.
    while (number.size() > 1 && number[0] == '0') number.erase(0, 1);

    try {
        if (!model_->onTeam(teamId, personId)) {
            return jsonError(HttpStatus::BAD_REQUEST, "That player is not on this team.");
        }
        if (!number.empty()) {
            const std::string holder = model_->numberHolder(teamId, personId, number);
            if (!holder.empty()) {
                return jsonOut(HttpStatus::CONFLICT,
                               {{"error", "#" + number + " is already " + holder + "'s."},
                                {"holder", holder}});
            }
        }
        if (!model_->setNumber(teamId, personId, number, scope.userId)) {
            return jsonError(HttpStatus::BAD_REQUEST, "This team has no uniform set yet.");
        }
        return jsonOut(HttpStatus::OK, {{"team_id", teamId}, {"person_id", personId},
                                        {"jersey_number", number.empty() ? json(nullptr) : json(number)}});
    } catch (const std::exception& e) {
        std::cerr << "KitBoardController::handleSetNumber: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /issued  { team_id, person_id, kit_item_id, issued }
// team_id is the board the tick was made on — it is what a coach's scope is
// checked against; the record itself is per person.
Response KitBoardController::handleSetIssued(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;

    const long long teamId    = intField(body, "team_id");
    const long long personId  = intField(body, "person_id");
    const long long kitItemId = intField(body, "kit_item_id");
    if (teamId <= 0 || personId <= 0 || kitItemId <= 0 ||
        !body.contains("issued") || !body["issued"].is_boolean()) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "team_id, person_id, kit_item_id and issued (bool) required");
    }
    if (!scope.covers(teamId)) return jsonError(HttpStatus::FORBIDDEN, "Not one of your teams.");
    const bool issued = body["issued"].get<bool>();

    try {
        if (!model_->onTeam(teamId, personId)) {
            return jsonError(HttpStatus::BAD_REQUEST, "That player is not on this team.");
        }
        if (!model_->setIssued(personId, kitItemId, issued, scope.userId)) {
            return jsonError(HttpStatus::BAD_REQUEST, "Unknown kit item.");
        }
        return jsonOut(HttpStatus::OK, {{"person_id", personId}, {"kit_item_id", kitItemId},
                                        {"issued", issued}});
    } catch (const std::exception& e) {
        std::cerr << "KitBoardController::handleSetIssued: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
