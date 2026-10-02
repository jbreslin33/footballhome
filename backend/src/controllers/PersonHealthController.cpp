#include "PersonHealthController.h"

#include <iostream>
#include <stdexcept>

#include "../database/Database.h"
#include "../models/PersonHealth.h"
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

bool isAdmin(long long userId) {
    return !Database::getInstance()->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                           {std::to_string(userId)}).empty();
}

bool isCoach(long long userId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM users u "
        "  JOIN coaches co      ON co.person_id = u.person_id "
        "  JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL "
        " WHERE u.id = $1::int LIMIT 1", {std::to_string(userId)}).empty();
}

std::string textField(const json& body, const char* key) {
    return body.contains(key) && body[key].is_string() ? body[key].get<std::string>() : std::string{};
}

}  // namespace

PersonHealthController::PersonHealthController() : model_(std::make_unique<PersonHealth>()) {}
PersonHealthController::~PersonHealthController() = default;

void PersonHealthController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleBoard(r); });
    router.put(prefix, [this](const Request& r) { return handleSet(r); });
}

Response PersonHealthController::handleBoard(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    try {
        if (!isAdmin(userId) && !isCoach(userId))
            return jsonError(HttpStatus::FORBIDDEN, "Health is for club admins and coaches.");
        return jsonOut(HttpStatus::OK, model_->board());
    } catch (const std::exception& e) {
        std::cerr << "PersonHealthController::handleBoard: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response PersonHealthController::handleSet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long personId = body.contains("person_id") && body["person_id"].is_number_integer()
        ? body["person_id"].get<long long>() : 0;
    const std::string status = textField(body, "status");
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    if (status.empty()) return jsonError(HttpStatus::BAD_REQUEST, "status required");

    try {
        if (!isAdmin(userId) && !model_->coachCovers(userId, personId))
            return jsonError(HttpStatus::FORBIDDEN, "That player is not on a team you coach.");
        const json health = model_->set(personId, status, textField(body, "since"),
                                        textField(body, "until"), userId);
        return jsonOut(HttpStatus::OK, {{"person_id", personId}, {"health", health}});
    } catch (const std::invalid_argument& e) {
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonHealthController::handleSet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save health");
    }
}
