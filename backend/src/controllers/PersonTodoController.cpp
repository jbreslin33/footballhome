#include "PersonTodoController.h"

#include <iostream>

#include "../models/PersonTodos.h"
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

const char* const NO_ACCESS = "Only club admins and this player's coaches can give them to-dos.";

}  // namespace

void PersonTodoController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleSheet(r); });
    router.post(prefix, [this](const Request& r) { return handlePost(r); });
}

Response PersonTodoController::handleSheet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    long long personId = 0;
    try { personId = std::stoll(request.getQueryParam("person_id")); } catch (...) { personId = 0; }
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    try {
        json out = PersonTodos::sheet(personId, userId);
        if (!out["canGive"].get<bool>()) return jsonError(HttpStatus::FORBIDDEN, NO_ACCESS);
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "PersonTodoController::handleSheet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response PersonTodoController::handlePost(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    auto str = [&](const char* k) { return body.contains(k) && body[k].is_string() ? body[k].get<std::string>() : std::string(); };
    auto num = [&](const char* k) { return body.contains(k) && body[k].is_number_integer() ? body[k].get<long long>() : 0LL; };
    const long long personId = num("person_id");
    const std::string action = str("action");
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    try {
        if (!PersonTodos::canGive(userId, personId)) return jsonError(HttpStatus::FORBIDDEN, NO_ACCESS);
        int given = -1;
        if (action == "give") {
            const long long teamId = num("team_id");
            if (teamId > 0 && !canManageTeam(request, static_cast<int>(teamId)))
                return jsonError(HttpStatus::FORBIDDEN, "You don't manage that team");
            std::string err;
            given = PersonTodos::give(userId, personId, teamId, str("body"), str("repeat"), str("due_on"), err);
            if (!err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
        } else if (action == "take") {
            const bool all = body.contains("all") && body["all"].is_boolean() && body["all"].get<bool>();
            if (!PersonTodos::take(personId, num("id"), all)) return jsonError(HttpStatus::NOT_FOUND, "That item is gone");
        } else {
            return jsonError(HttpStatus::BAD_REQUEST, "Unknown action");
        }
        json out = PersonTodos::sheet(personId, userId);
        if (given >= 0) out["given"] = given;
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "PersonTodoController::handlePost: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
