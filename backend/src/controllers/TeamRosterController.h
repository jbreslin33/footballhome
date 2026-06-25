#pragma once
#include "../core/Controller.h"
#include "../models/TeamRoster.h"
#include <memory>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// TeamRosterController — REST surface for the team roster mutation route.
//
// Routes (registered under prefix "/api/teams"):
//   POST /api/teams/:teamId/roster/:personId   body: {"action": "add"|"remove"}
//
// Bearer-presence auth (same JWT-verification TODO as the rest of Phase 1+2).
// ────────────────────────────────────────────────────────────────────────────
class TeamRosterController : public Controller {
public:
    TeamRosterController();
    ~TeamRosterController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<TeamRoster> model_;

    Response handleSetMembership(const Request& request);

    // Path parser: /api/teams/123/roster/456 → (123, 456).  Returns false on
    // anything that doesn't match the expected shape.
    bool extractTeamAndPerson(const std::string& path,
                              int& teamId,
                              int& personId) const;

    // Pull `action` out of a JSON body without a JSON library — matches the
    // approach used by PersonMergeController for laPersonId/gmPersonId.
    // Returns "add", "remove", or empty string when no recognisable action is
    // present.
    static std::string extractAction(const std::string& body);

    // Bearer presence check (no signature verification).
    bool requireBearer(const Request& request) const;
};
