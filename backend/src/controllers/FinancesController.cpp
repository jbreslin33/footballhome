#include "FinancesController.h"

#include <cstdlib>
#include <iostream>

#include "../database/Database.h"
#include "../models/Expenses.h"
#include "../models/PaymentsOverview.h"
#include "../models/WelcomeLog.h"
#include "../services/LeagueFixtureSync.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {
int envIntOr(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); } catch (const std::exception&) { return fallback; }
}
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
} // namespace

FinancesController::FinancesController()
    : mensProgramId_  (envIntOr("LEAGUEAPPS_MENS_PROGRAM_ID",       5039300)),
      womensProgramId_(envIntOr("LEAGUEAPPS_WOMENS_PROGRAM_ID",     5039340)),
      boysProgramId_  (envIntOr("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",  5039252)),
      girlsProgramId_ (envIntOr("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID", 5039357)) {}

bool FinancesController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Finances are for club admins.");
    return false;
}

void FinancesController::registerRoutes(Router& router, const std::string& prefix) {
    // Membership numbers must come from a fresh LeagueApps sync (LA → DB →
    // render), hence laGet with the four membership programs.
    laGet(router, prefix + "/summary", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { return handleSummary(r); });
    router.get(prefix + "/expenses", [this](const Request& r) { return handleExpenses(r); });
}

Response FinancesController::handleSummary(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, PaymentsOverview::build(WelcomeLog::kLighthouseClubId)); }
    catch (const std::exception& e) { std::cerr << "[finances summary] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response FinancesController::handleExpenses(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        // Every league feed a referee policy reads, refreshed first (mig 488 rule: "refreshed on every access").
        json pulls = json::array();
        for (const auto& r : Database::getInstance()->query(
                "SELECT DISTINCT fixture_league_label AS l FROM ref_fee_policies WHERE club_id = $1::int AND is_active AND fixture_league_label IS NOT NULL ORDER BY 1",
                {std::to_string((long long)WelcomeLog::kLighthouseClubId)}))
            for (const auto& p : LeagueFixtureSync::refreshLeague(r["l"].c_str())) pulls.push_back(p);
        json out = Expenses::projection(WelcomeLog::kLighthouseClubId);
        out["games"] = Expenses::games(WelcomeLog::kLighthouseClubId);
        out["pulls"] = pulls;
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[finances expenses] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
