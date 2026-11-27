#include "RulesController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/ClubRules.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

RulesController::RulesController() {}

void RulesController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleRules(r); });
}

Response RulesController::handleRules(const Request& request) {
    const long long uid = bearerUserId(request);
    if (uid <= 0) return jsonError(denialStatus(request), "Sign in to see the rules.");
    try {
        int personId = 0;
        auto u = Database::getInstance()->query(
            "SELECT person_id FROM users WHERE id = $1::bigint", {std::to_string(uid)});
        if (!u.empty() && !u[0]["person_id"].is_null()) personId = u[0]["person_id"].as<int>();
        const bool everything = requireAdminLevel(request, {"club", "super"});
        return jsonOut(HttpStatus::OK, ClubRules::forPerson(personId, everything));
    } catch (const std::exception& e) {
        std::cerr << "[RulesController::rules] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the rules");
    }
}
