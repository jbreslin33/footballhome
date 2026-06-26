#include "ClubLaPoolController.h"

#include <iostream>
#include <regex>

ClubLaPoolController::ClubLaPoolController()
    : model_(std::make_unique<LaPool>()) {}

ClubLaPoolController::~ClubLaPoolController() = default;

void ClubLaPoolController::registerRoutes(Router& router,
                                          const std::string& prefix) {
    router.get(prefix + "/:clubId/la-pool", [this](const Request& req) {
        return this->handleGet(req);
    });
}

Response ClubLaPoolController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int clubId = 0;
    if (!extractClubId(request.getPath(), clubId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid clubId");
    }

    const std::string genderRaw = request.getQueryParam("gender");
    const auto gender = LaPool::parseGender(genderRaw);

    try {
        auto result = model_->run(clubId, gender);
        return Response(HttpStatus::OK, result.body.dump());
    } catch (const std::exception& e) {
        std::cerr << "ClubLaPoolController::handleGet error: " << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

bool ClubLaPoolController::extractClubId(const std::string& path, int& clubId) {
    static const std::regex re(R"(/api/clubs/(\d+)/la-pool)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { clubId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

