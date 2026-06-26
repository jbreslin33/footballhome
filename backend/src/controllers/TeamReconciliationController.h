#pragma once
#include "../core/Controller.h"
#include "../models/TeamReconciliation.h"
#include <memory>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// TeamReconciliationController — REST surface for the team-reconciliation
// view that drives the lineups screen.
//
// Routes (registered under prefix "/api/teams"):
//   GET /api/teams/:teamId/reconciliation
//
// Bearer-presence auth (same JWT-verification TODO as the rest of Phases
// 1-3a).
// ────────────────────────────────────────────────────────────────────────────
class TeamReconciliationController : public Controller {
public:
    TeamReconciliationController();
    ~TeamReconciliationController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<TeamReconciliation> model_;

    Response handleGet(const Request& request);

    // Path parser: /api/teams/123/reconciliation → 123.
    static bool extractTeamId(const std::string& path, int& teamId);

    // Bearer presence check (no signature verification).
    static bool requireBearer(const Request& request);
};
