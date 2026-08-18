#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/WomensRoster.h"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// WomensRosterController — REST surface for the women's dashboard.
//
// Routes (registered under prefix "/api/womens-roster"):
//   GET  /api/womens-roster[?includeAll=1&refreshLa=1&includeInactive=1]
//   POST /api/womens-roster/assign         body: {leagueAppsUserId, teamId, action}
//   POST /api/womens-roster/roster-status  body: {leagueAppsUserId, teamId, onRoster}
//   POST /api/womens-roster/reorder        body: {teamId, userIds:[...]}
//   GET  /api/womens-roster/columns
//
// Same bearer-presence auth + canManageTeam gate as Boys/Mens. Backing
// store is `teams` filtered to gender_category='womens' (migration 250 —
// MensTeamColumns/MensTeamAssignments domain "womens").
//
// Deliberately does NOT register /api/lineups/games (ad-hoc match
// create/edit) — that route already lives on MensRosterController and
// is documented there as shared by any team column, mens or womens. No
// RSVP-eligibility routes either (Mens-only feature).
// ────────────────────────────────────────────────────────────────────────────
class WomensRosterController : public Controller {
public:
    WomensRosterController();
    ~WomensRosterController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<WomensRoster>         model_;
    std::unique_ptr<MensTeamColumns>      columns_;
    std::unique_ptr<MensTeamAssignments>  assignments_;

    Response handleGet(const Request& request, const LaSyncMap& sync);
    Response handleAssign(const Request& request);
    Response handleRosterStatus(const Request& request);
    Response handleReorder(const Request& request);
    // GET /api/womens-roster/columns — lightweight column catalog (id,
    // label, color, mutexGroup), no LA sync and no player data. Powers
    // PersonScreen's cross-domain "add to roster" panel.
    Response handleColumns(const Request& request);
};
