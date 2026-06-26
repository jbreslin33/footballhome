#include "TeamReconciliationController.h"
#include <iostream>
#include <regex>

TeamReconciliationController::TeamReconciliationController()
    : model_(std::make_unique<TeamReconciliation>()) {}

// Out-of-line so the unique_ptr<TeamReconciliation> can see the full type at
// destruction site (the header only forward-declares it via the include
// of TeamReconciliation.h which itself forward-declares PersonLinker).
TeamReconciliationController::~TeamReconciliationController() = default;

void TeamReconciliationController::registerRoutes(Router& router,
                                                  const std::string& prefix) {
    router.get(prefix + "/:teamId/reconciliation", [this](const Request& req) {
        return this->handleGet(req);
    });
}

Response TeamReconciliationController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int teamId = 0;
    if (!extractTeamId(request.getPath(), teamId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid teamId");
    }

    try {
        auto result = model_->run(teamId);
        return Response(HttpStatus::OK, result.body.dump());
    } catch (const std::exception& e) {
        std::cerr << "TeamReconciliationController::handleGet error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

bool TeamReconciliationController::extractTeamId(const std::string& path, int& teamId) {
    static const std::regex re(R"(/api/teams/(\d+)/reconciliation)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { teamId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

