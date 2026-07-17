#include "YouthRosterController.h"

#include <iostream>
#include <sstream>

YouthRosterController::YouthRosterController()
    : model_(std::make_unique<YouthRoster>()) {}

YouthRosterController::~YouthRosterController() = default;

void YouthRosterController::registerRoutes(Router& router,
                                           const std::string& prefix) {
    // STRICT rule (§ Membership Data Flow): every LA-derived response
    // MUST run LaProgramSync on every feeding program BEFORE the
    // handler.  laGet(static) does this — the two youth sub-programs
    // (boys + girls) are synced in parallel, results handed to the
    // handler, and the model reads response payloads from Postgres.
    laGet(router, prefix,
          {model_->boysProgramId(), model_->girlsProgramId()},
          [this](const Request& req, const LaSyncMap& sync) {
              return this->handleGet(req, sync);
          });
}

Response YouthRosterController::handleGet(const Request& request,
                                          const LaSyncMap& sync) {
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

    // Extract recs from the sync map — the framework has already run
    // LaProgramSync::run for both programs (see registerRoutes above)
    // and closed any stale memberships.  We only need the raw records.
    static const std::vector<nlohmann::json> kEmpty;
    const auto boysIt  = sync.find(model_->boysProgramId());
    const auto girlsIt = sync.find(model_->girlsProgramId());
    const auto& boysRecs  = (boysIt  != sync.end()) ? boysIt->second.recs  : kEmpty;
    const auto& girlsRecs = (girlsIt != sync.end()) ? girlsIt->second.recs : kEmpty;

    try {
        auto result = model_->run(seasonEndYear, includeAll, boysRecs, girlsRecs);
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

