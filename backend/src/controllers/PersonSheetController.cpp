#include "PersonSheetController.h"

#include <iostream>

#include "../models/PersonSheet.h"
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

}  // namespace

PersonSheetController::PersonSheetController() : model_(std::make_unique<PersonSheet>()) {}
PersonSheetController::~PersonSheetController() = default;

void PersonSheetController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleCard(r); });
    router.post(prefix + "/volunteer", [this](const Request& r) { return handleVolunteer(r); });
}

Response PersonSheetController::handleCard(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    long long personId = 0;
    try { personId = std::stoll(request.getQueryParam("person_id")); } catch (...) { personId = 0; }
    std::string laUserId;
    for (char c : request.getQueryParam("la_user_id")) if (c >= '0' && c <= '9') laUserId.push_back(c);
    if (personId <= 0 && laUserId.empty()) return jsonError(HttpStatus::BAD_REQUEST, "person_id or la_user_id required");
    try {
        json card = model_->card(personId, laUserId, userId);
        if (card.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such person");
        if (!card["canSee"].get<bool>()) return jsonError(HttpStatus::FORBIDDEN, "The player sheet is for club admins and coaches.");
        return jsonOut(HttpStatus::OK, card);
    } catch (const std::exception& e) {
        std::cerr << "PersonSheetController::handleCard: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response PersonSheetController::handleVolunteer(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"})) return jsonError(denialStatus(request), "Club admins only");
    const long long userId = bearerUserId(request);
    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long personId = body.contains("person_id") && body["person_id"].is_number_integer()
        ? body["person_id"].get<long long>() : 0;
    if (personId <= 0 || !body.contains("on") || !body["on"].is_boolean())
        return jsonError(HttpStatus::BAD_REQUEST, "person_id and on required");
    try {
        if (model_->card(personId, "", userId).is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such person");
        model_->setVolunteer(personId, body["on"].get<bool>());
        return jsonOut(HttpStatus::OK, model_->card(personId, "", userId));
    } catch (const std::exception& e) {
        std::cerr << "PersonSheetController::handleVolunteer: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
