#pragma once
#include "../core/Controller.h"
#include "../models/TeamCoach.h"
#include <memory>

// ────────────────────────────────────────────────────────────────────────────
// TeamCoachController — REST surface for team↔coach assignment.
//
// Routes (mounted under `/api/teams`):
//   POST   /api/teams/:teamId/coaches/:personId   → assign / reactivate
//   DELETE /api/teams/:teamId/coaches/:personId   → soft-end assignment
//
// All routes require a Bearer auth token (presence-checked; signature
// verification is a system-wide refactor tracked separately — see the
// JwtAuthService TODO).
//
// The controller is intentionally thin: it parses path params, calls
// TeamCoach (the model), and renders the response. All DB / business
// logic lives in the model.
// ────────────────────────────────────────────────────────────────────────────
class TeamCoachController : public Controller {
public:
    TeamCoachController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleAssign(const Request& request);
    Response handleUnassign(const Request& request);

    // Parse "/api/teams/<teamId>/coaches/<personId>" into a pair of ints.
    // Returns false if the path doesn't match or either id is non-numeric.
    bool extractIds(const std::string& path, int& teamId, int& personId) const;

    // Presence check on a Bearer token. We deliberately don't verify the
    // signature here — that's the system-wide JwtAuthService refactor.
    bool requireBearer(const Request& request) const;

    std::unique_ptr<TeamCoach> model_;
};
