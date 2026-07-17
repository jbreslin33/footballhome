#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/BoysRoster.h"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// BoysRosterController — REST surface for the boys dashboard.
//
// Routes (registered under prefix "/api/boys-roster"):
//   GET  /api/boys-roster[?includeAll=1&refreshLa=1]
//   POST /api/boys-roster/assign         body: {leagueAppsUserId, teamId, action}
//   POST /api/boys-roster/roster-status  body: {leagueAppsUserId, teamId, onRoster}
//   POST /api/boys-roster/reorder        body: {teamId, userIds:[...]}
//
// Same bearer-presence auth as the mens dashboard.  Backing store is
// roster_columns / roster_assignments filtered by domain='boys'.
// ────────────────────────────────────────────────────────────────────────────
class BoysRosterController : public Controller {
public:
    BoysRosterController();
    ~BoysRosterController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<BoysRoster>           model_;
    std::unique_ptr<MensTeamColumns>      columns_;
    std::unique_ptr<MensTeamAssignments>  assignments_;

    Response handleGet(const Request& request, const LaSyncMap& sync);
    Response handleAssign(const Request& request);
    Response handleRosterStatus(const Request& request);
    Response handleReorder(const Request& request);
};
