#include "FinancesController.h"

#include <cstdlib>
#include <iostream>
#include <optional>

#include "../database/Database.h"
#include "../models/CashFlow.h"
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
    // Cash flow splits dues ahead by team from today's members (mig 977), so
    // it syncs the same four programs first.
    laGet(router, prefix + "/cash-flow", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { return handleCashFlow(r); });
    router.post(prefix + "/budget-lines/:id", [this](const Request& r) { return handleBudgetLine(r); });
    router.post(prefix + "/plan-roster", [this](const Request& r) { return handlePlanRoster(r); });
}

Response FinancesController::handleCashFlow(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, CashFlow::build(WelcomeLog::kLighthouseClubId)); }
    catch (const std::exception& e) { std::cerr << "[finances cash-flow] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load money in and out"); }
}

Response FinancesController::handleBudgetLine(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        const json body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        std::optional<double> amount; std::optional<bool> settled;
        if (body.contains("amount")) {
            if (!body["amount"].is_number() || body["amount"].get<double>() < 0 || body["amount"].get<double>() >= 100000000)
                return jsonError(HttpStatus::BAD_REQUEST, "Enter an amount in dollars.");
            amount = body["amount"].get<double>();
        }
        if (body.contains("settled")) {
            if (!body["settled"].is_boolean()) return jsonError(HttpStatus::BAD_REQUEST, "settled must be true or false.");
            settled = body["settled"].get<bool>();
        }
        if (!amount && !settled) return jsonError(HttpStatus::BAD_REQUEST, "Nothing to change.");
        const std::string path = request.getPath();
        if (!Expenses::updateBudgetLine(WelcomeLog::kLighthouseClubId, std::stoi(path.substr(path.rfind('/') + 1)), amount, settled))
            return jsonError(HttpStatus::NOT_FOUND, "Budget line not found.");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { std::cerr << "[finances budget line] " << e.what() << std::endl; return jsonError(HttpStatus::BAD_REQUEST, "Could not change that budget line."); }
}

// Year plan "Full rosters" (mig 1345): { entry_id, players }.
Response FinancesController::handlePlanRoster(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        const json body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        if (!body.contains("entry_id") || !body["entry_id"].is_number_integer()) return jsonError(HttpStatus::BAD_REQUEST, "Which team?");
        if (!body.contains("players") || !body["players"].is_number_integer() || body["players"].get<int>() < 0 || body["players"].get<int>() > 200)
            return jsonError(HttpStatus::BAD_REQUEST, "Enter a number of players.");
        if (!Expenses::setPlanRoster(WelcomeLog::kLighthouseClubId, body["entry_id"].get<int>(), body["players"].get<int>()))
            return jsonError(HttpStatus::NOT_FOUND, "That team is not on the plan.");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { std::cerr << "[finances plan roster] " << e.what() << std::endl; return jsonError(HttpStatus::BAD_REQUEST, "Could not change that roster."); }
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
