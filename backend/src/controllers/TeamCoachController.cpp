#include "TeamCoachController.h"
#include <iostream>
#include <regex>
#include <sstream>

TeamCoachController::TeamCoachController()
    : model_(std::make_unique<TeamCoach>()) {}

void TeamCoachController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/teams/:teamId/coaches/:personId
    router.post(prefix + "/:teamId/coaches/:personId", [this](const Request& request) {
        return this->handleAssign(request);
    });

    // DELETE /api/teams/:teamId/coaches/:personId
    router.del(prefix + "/:teamId/coaches/:personId", [this](const Request& request) {
        return this->handleUnassign(request);
    });
}

Response TeamCoachController::handleAssign(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int teamId = 0, personId = 0;
    if (!extractIds(request.getPath(), teamId, personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
                             "teamId and personId must be integers");
    }

    try {
        TeamCoach::AssignResult r = model_->assign(teamId, personId);

        std::ostringstream json;
        json << "{"
             << "\"teamId\":"   << teamId   << ","
             << "\"personId\":" << personId << ","
             << "\"coachId\":"  << r.coachId
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "TeamCoachController::handleAssign error: " << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response TeamCoachController::handleUnassign(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int teamId = 0, personId = 0;
    if (!extractIds(request.getPath(), teamId, personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
                             "teamId and personId must be integers");
    }

    try {
        int ended = model_->unassign(teamId, personId);

        std::ostringstream json;
        json << "{"
             << "\"teamId\":"   << teamId   << ","
             << "\"personId\":" << personId << ","
             << "\"ended\":"    << ended
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "TeamCoachController::handleUnassign error: " << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

bool TeamCoachController::extractIds(const std::string& path,
                                     int& teamId, int& personId) const {
    static const std::regex re(R"(/api/teams/(\d+)/coaches/(\d+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) {
        return false;
    }
    try {
        teamId   = std::stoi(m[1].str());
        personId = std::stoi(m[2].str());
    } catch (const std::exception&) {
        return false;
    }
    return true;
}

