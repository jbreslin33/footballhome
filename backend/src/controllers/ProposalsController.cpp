#include "ProposalsController.h"

#include <iostream>

#include "../models/Proposals.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

ProposalsController::ProposalsController() {}

bool ProposalsController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Proposals are for club admins.");
    return false;
}

void ProposalsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix,            [this](const Request& r) { return handleList(r); });
    router.get(prefix + "/:code", [this](const Request& r) { return handleOne(r); });
}

Response ProposalsController::handleList(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        return jsonOut(HttpStatus::OK, {{"proposals", Proposals::list()}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::list] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load proposals");
    }
}

Response ProposalsController::handleOne(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const std::string path = request.getPath();
    const std::string code = path.substr(path.find_last_of('/') + 1);
    try {
        json p = Proposals::one(code);
        if (p.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such proposal");
        return jsonOut(HttpStatus::OK, {{"proposal", p}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::one] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the proposal");
    }
}
