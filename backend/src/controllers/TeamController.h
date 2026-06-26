#pragma once
#include "../core/Controller.h"
#include "../models/Team.h"
#include "../database/Database.h"
#include <memory>

class TeamController : public Controller {
private:
    std::unique_ptr<Team> team_model_;
    Database* db_;  // direct DB access for new endpoints (live-match pin)

public:
    TeamController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetAllTeams(const Request& request);
    Response handleGetRoster(const Request& request);
    Response handleGetRosterStatuses(const Request& request);
    Response handleGetDivisionStandings(const Request& request);
    Response handleUpdateRosterMember(const Request& request);
    Response handleRemoveRosterMember(const Request& request);
    Response handleGetTeamAccolades(const Request& request);
    Response handleSetLiveMatch(const Request& request);
    Response handleGetShareInfo(const Request& request);

    // Helper methods
    std::string extractTeamIdFromPath(const std::string& path);
    std::string extractPlayerIdFromPath(const std::string& path);
    std::string extractTeamIdGeneric(const std::string& path);
    std::string extractTeamIdForLiveMatch(const std::string& path);
    bool hasBearerToken(const Request& request);
};