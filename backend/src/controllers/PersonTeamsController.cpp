#include "PersonTeamsController.h"

#include <iostream>

#include "../models/MensTeamAssignments.h"
#include "../models/PersonTeams.h"
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

long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number_integer()) return body[key].get<long long>();
    if (body[key].is_string()) {
        try { return std::stoll(body[key].get<std::string>()); } catch (...) { return 0; }
    }
    return 0;
}

bool managesAny(const json& board) {
    for (const auto& t : board["teams"]) if (t["canManage"].get<bool>()) return true;
    return false;
}

}  // namespace

PersonTeamsController::PersonTeamsController() : model_(std::make_unique<PersonTeams>()) {}
PersonTeamsController::~PersonTeamsController() = default;

void PersonTeamsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleBoard(r); });
    router.post(prefix, [this](const Request& r) { return handleChange(r); });
}

Response PersonTeamsController::handleBoard(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    long long personId = 0;
    try { personId = std::stoll(request.getQueryParam("person_id")); } catch (...) { personId = 0; }
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    try {
        json board = model_->board(personId, userId);
        if (!managesAny(board)) return jsonError(HttpStatus::FORBIDDEN, "Team moves are for club admins and coaches.");
        return jsonOut(HttpStatus::OK, board);
    } catch (const std::exception& e) {
        std::cerr << "PersonTeamsController::handleBoard: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response PersonTeamsController::handleChange(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long personId = intField(body, "person_id");
    const int teamId = static_cast<int>(intField(body, "team_id"));
    const int fromTeamId = static_cast<int>(intField(body, "from_team_id"));
    const std::string action = body.contains("action") && body["action"].is_string()
        ? body["action"].get<std::string>() : std::string{};
    if (personId <= 0 || teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id and team_id required");
    if (action != "add" && action != "remove" && action != "move")
        return jsonError(HttpStatus::BAD_REQUEST, "action must be add, remove or move");
    if (action == "move" && (fromTeamId <= 0 || fromTeamId == teamId))
        return jsonError(HttpStatus::BAD_REQUEST, "move needs a different from_team_id");

    try {
        if (!canManageTeam(request, teamId) || (action == "move" && !canManageTeam(request, fromTeamId)))
            return jsonError(HttpStatus::FORBIDDEN, "Not authorized to manage this team");

        const int leaving = action == "remove" ? teamId : (action == "move" ? fromTeamId : 0);
        if (leaving > 0) {
            if (!model_->onTeam(personId, leaving)) return jsonError(HttpStatus::NOT_FOUND, "He is not on that team");
            if (model_->onLeagueList(personId, leaving))
                return jsonError(HttpStatus::CONFLICT, "He is on the league's list for that team — only the league takes him off.");
        }

        if (action == "remove") {
            MensTeamAssignments().removeAssignmentForPerson(personId, teamId);
        } else {
            const auto domain = model_->boardDomain(teamId);
            if (!domain) return jsonError(HttpStatus::NOT_FOUND, "Not a team on the boards");
            MensTeamAssignments assignments(*domain);
            if (action == "add") assignments.addAssignmentForPerson(personId, teamId, "");
            else assignments.moveForPerson(personId, fromTeamId, teamId);
        }
        return jsonOut(HttpStatus::OK, model_->board(personId, userId));
    } catch (const std::exception& e) {
        std::cerr << "PersonTeamsController::handleChange: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
