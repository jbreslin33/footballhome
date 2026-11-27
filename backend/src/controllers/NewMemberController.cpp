#include "NewMemberController.h"

#include <iostream>
#include "../models/NewMemberOnboarding.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
}

NewMemberController::NewMemberController() : model_(std::make_unique<NewMemberOnboarding>()) {}
NewMemberController::~NewMemberController() = default;

void NewMemberController::registerRoutes(Router& router, const std::string& prefix) {
    // LA → DB → render: every program syncs first (admins only — anyone
    // else syncs nothing and gets the 403).
    laGet(router, prefix + "/report",
          [](const Request& r) {
              return requireAdminLevel(r, {"club", "super"}) ? Controller::allLaProgramIds() : std::vector<int>{};
          },
          [this](const Request& r, const LaSyncMap&) { return handleReport(r); });
    router.post(prefix + "/dismiss", [this](const Request& r) { return handleDismiss(r); });
}

Response NewMemberController::handleReport(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"}))
        return jsonOut(denialStatus(request), {{"error", "Admins only"}});
    try {
        return jsonOut(HttpStatus::OK, model_->report());
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/new-members/report] " << e.what() << std::endl;
        return jsonOut(HttpStatus::INTERNAL_SERVER_ERROR, {{"error", "Could not load the onboarding report"}});
    }
}

Response NewMemberController::handleDismiss(const Request& request) {
    if (!requireAdminLevel(request, {"club", "super"}))
        return jsonOut(denialStatus(request), {{"error", "Admins only"}});
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonOut(HttpStatus::BAD_REQUEST, {{"error", std::string("Invalid JSON: ") + e.what()}}); }
    std::vector<long long> ids;
    if (body.contains("person_ids") && body["person_ids"].is_array())
        for (const auto& v : body["person_ids"]) if (v.is_number_integer()) ids.push_back(v.get<long long>());
    if (ids.empty()) return jsonOut(HttpStatus::BAD_REQUEST, {{"error", "person_ids required"}});
    try {
        return jsonOut(HttpStatus::OK, {{"dismissed", model_->dismiss(ids, bearerUserId(request))}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/new-members/dismiss] " << e.what() << std::endl;
        return jsonOut(HttpStatus::INTERNAL_SERVER_ERROR, {{"error", "Could not mark done"}});
    }
}
