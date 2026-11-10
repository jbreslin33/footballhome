#include "VolunteerController.h"

#include <iostream>

#include "../models/VolunteerShifts.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

VolunteerController::VolunteerController() {}

bool VolunteerController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Volunteer requests are for club admins.");
    return false;
}

void VolunteerController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/requests",     [this](const Request& r) { return handleRequests(r); });
    router.post(prefix + "/requests/:id", [this](const Request& r) { return handleDecide(r); });
}

Response VolunteerController::handleRequests(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        return jsonOut(HttpStatus::OK, {{"requests", VolunteerShifts::pending()}});
    } catch (const std::exception& e) {
        std::cerr << "[VolunteerController::requests] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load volunteer requests");
    }
}

Response VolunteerController::handleDecide(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const std::string path = request.getPath();
    long long id = 0;
    try { id = std::stoll(path.substr(path.find_last_of('/') + 1)); } catch (...) {}
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); } catch (...) {}
    try {
        auto r = VolunteerShifts::decide(id, body.value("decision", std::string{}), bearerUserId(request));
        if (!r.ok) return jsonError(static_cast<HttpStatus>(r.status), r.error);
        return jsonOut(HttpStatus::OK, r.body);
    } catch (const std::exception& e) {
        std::cerr << "[VolunteerController::decide] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the decision");
    }
}
