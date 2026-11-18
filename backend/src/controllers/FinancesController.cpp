#include "FinancesController.h"

#include <chrono>
#include <cstdlib>
#include <mutex>
#include <iostream>
#include <optional>

#include "../database/Database.h"
#include "../models/ProgramBudget.h"
#include "../models/CoachingPlan.h"
#include "../models/CashFlow.h"
#include "../models/Expenses.h"
#include "../models/PaymentsOverview.h"
#include "../models/PersonPayments.h"
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
// Every #finances load checks LeagueApps payments and updates the DB first
// (owner 11/14 "how are you not checking on every fiances page load lol you
// should be checking la … and updating db"): new transactions, then the
// reconcile (refresh every row, drop what LA deleted). The page's parallel
// requests share one pass (mutex + 1-minute throttle). A failed LA call is
// logged and the page renders from the DB.
void refreshPaymentsFromLa() {
    static std::mutex m;
    std::lock_guard<std::mutex> lock(m);
    const auto t0 = std::chrono::steady_clock::now();
    try {
        PersonPayments p;
        const int fresh = p.syncFromLa();
        const int dropped = p.reconcileFromLa(false, 1);
        std::cout << "[finances] LA payments: " << fresh << " new/updated, reconcile " << (dropped < 0 ? std::string("skipped") : std::to_string(dropped) + " dropped")
                  << " in " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - t0).count() << " ms" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "[finances] LA payments refresh failed: " << e.what() << std::endl;
    }
}
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
        [this](const Request& r, const LaSyncMap&) { Response d; if (!gate(r, &d)) return d; refreshPaymentsFromLa(); return handleSummary(r); });
    router.get(prefix + "/expenses", [this](const Request& r) { return handleExpenses(r); });
    // Cash flow splits dues ahead by team from today's members (mig 977), so
    // it syncs the same four programs first.
    laGet(router, prefix + "/cash-flow", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { Response d; if (!gate(r, &d)) return d; refreshPaymentsFromLa(); return handleCashFlow(r); });
    // 🧩 Programs (mig 1390): a budget per program per season — players per
    // program come from today's members, so it syncs the four programs first.
    laGet(router, prefix + "/programs", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { Response d; if (!gate(r, &d)) return d; refreshPaymentsFromLa(); return handlePrograms(r); });
    // a plan season's fields / a youth league entry → the programs again
    laPost(router, prefix + "/program-plan", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { return handleProgramSave(r, false); });
    laPost(router, prefix + "/program-entry", {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { return handleProgramSave(r, true); });
    // 🧑‍🏫 Coaching plan (mig 1491): every paid coach's hours and money per
    // season, from the normalized schedule — ?year=2026-27 ("" = this year).
    router.get(prefix + "/coaching", [this](const Request& r) { return handleCoaching(r); });
}

Response FinancesController::handleCoaching(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, CoachingPlan(WelcomeLog::kLighthouseClubId, request.getQueryParam("year")).toJson()); }
    catch (const std::invalid_argument& e) { return jsonError(HttpStatus::BAD_REQUEST, e.what()); }
    catch (const std::exception& e) { std::cerr << "[finances coaching] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the coaching plan."); }
}

Response FinancesController::handlePrograms(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, ProgramBudget::build(WelcomeLog::kLighthouseClubId, request.getQueryParam("scenario") == "capacity" ? "capacity" : "expected")); }
    catch (const std::exception& e) { std::cerr << "[finances programs] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the programs."); }
}

// { program, year, season ("all" = every plan season), fields: {…} } or, for an
// entry, { program, year, season, league_season_id, age_band, teams, remove }.
Response FinancesController::handleProgramSave(const Request& request, bool entry) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        const json b = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        const std::string program = b.value("program", ""), year = b.value("year", ""), season = b.value("season", "");
        if (entry) {
            if (!b.contains("league_season_id") || !b["league_season_id"].is_number_integer()) return jsonError(HttpStatus::BAD_REQUEST, "Which league?");
            ProgramBudget::saveEntry(WelcomeLog::kLighthouseClubId, program, year, season, b["league_season_id"].get<int>(),
                                     b.value("age_band", std::string{}), b.contains("teams") ? b["teams"] : json(nullptr), b.value("remove", false));
        } else {
            if (!b.contains("fields") || !b["fields"].is_object()) return jsonError(HttpStatus::BAD_REQUEST, "What changes?");
            ProgramBudget::savePlan(WelcomeLog::kLighthouseClubId, program, year, season, b["fields"], bearerUserId(request));
        }
        return jsonOut(HttpStatus::OK, ProgramBudget::build(WelcomeLog::kLighthouseClubId, b.value("scenario", "") == "capacity" ? "capacity" : "expected"));
    } catch (const std::invalid_argument& e) { return jsonError(HttpStatus::BAD_REQUEST, e.what()); }
    catch (const std::exception& e) { std::cerr << "[finances program save] " << e.what() << std::endl; return jsonError(HttpStatus::BAD_REQUEST, "Could not save the change."); }
}

Response FinancesController::handleCashFlow(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, CashFlow::build(WelcomeLog::kLighthouseClubId)); }
    catch (const std::exception& e) { std::cerr << "[finances cash-flow] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load money in and out"); }
}

// Year plan "Full rosters" (mig 1345): { entry_id, players }.
// Year plan team count (mig 1348): how many sides an entry puts in.
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
