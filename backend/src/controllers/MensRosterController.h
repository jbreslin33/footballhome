#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/MensRoster.h"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// MensRosterController — REST surface for the mens dashboard.
//
// Routes (registered under prefix "/api/mens-roster"):
//   GET  /api/mens-roster[?includeAll=1]
//   POST /api/mens-roster/assign         body: {leagueAppsUserId, teamId, action}
//   POST /api/mens-roster/roster-status  body: {leagueAppsUserId, teamId, onRoster}
//
// Bearer-presence auth (same as Phases 1-7).
//
// `assigned_by_user_id` is NOT extracted from the bearer because the
// C++ backend currently uses an alg:none JWT just for presence checks
// (real userId decoding is per-controller and not yet generalised).  The
// schema column is nullable, so we write NULL — matching the test-token
// case in Node where req.userId would be undefined.
// ────────────────────────────────────────────────────────────────────────────
class MensRosterController : public Controller {
public:
    MensRosterController();
    ~MensRosterController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<MensRoster>           model_;
    std::unique_ptr<MensTeamColumns>      columns_;
    std::unique_ptr<MensTeamAssignments>  assignments_;

    Response handleGet(const Request& request);
    Response handleAssign(const Request& request);
    Response handleRosterStatus(const Request& request);

    static bool requireBearer(const Request& request);
};
