#include "YouthRosterController.h"

#include <iostream>
#include <sstream>

YouthRosterController::YouthRosterController()
    : model_(std::make_unique<YouthRoster>()) {}

YouthRosterController::~YouthRosterController() = default;

void YouthRosterController::registerRoutes(Router& router,
                                           const std::string& prefix) {
    router.get(prefix, [this](const Request& req) {
        return this->handleGet(req);
    });
}

Response YouthRosterController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int seasonEndYear = 0;
    const std::string seasonRaw = request.getQueryParam("seasonEndYear");
    if (!seasonRaw.empty()) {
        try { seasonEndYear = std::stoi(seasonRaw); }
        catch (const std::exception&) { seasonEndYear = 0; }
    }
    if (seasonEndYear == 0) seasonEndYear = YouthRoster::defaultSeasonEndYear();

    const bool includeAll = (request.getQueryParam("includeAll") == "1");

    try {
        auto result = model_->run(seasonEndYear, includeAll);
        if (result.noBuckets) {
            std::ostringstream body;
            body << "{\"error\":\"" << result.error << "\"}";
            return Response(HttpStatus::CONFLICT, body.str());
        }
        return Response(HttpStatus::OK, result.body.dump());
    } catch (const std::exception& e) {
        std::cerr << "YouthRosterController::handleGet error: " << e.what() << std::endl;
        std::ostringstream body;
        body << "{\"error\":\"Failed to fetch youth roster: " << e.what() << "\"}";
        return Response(HttpStatus::BAD_GATEWAY, body.str());
    }
}

bool YouthRosterController::requireBearer(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    return h.size() > 7 && h.compare(0, 7, "Bearer ") == 0;
}
