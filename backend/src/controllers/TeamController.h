#pragma once
#include "../core/Controller.h"
#include "../models/Team.h"
#include <memory>

class TeamController : public Controller {
private:
    std::unique_ptr<Team> team_model_;

public:
    TeamController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetRoster(const Request& request);
    
    // Helper methods
    std::string extractTeamIdFromPath(const std::string& path);
    std::string createJSONResponse(bool success, const std::string& message);
};