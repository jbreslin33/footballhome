#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <string>

class InternalRosterController : public Controller {
public:
    InternalRosterController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;

    // GET /api/internal/teams   — list the 6 Lighthouse summer teams
    Response handleGetTeams(const Request& request);

    // GET /api/internal/roster  — all Lighthouse pool players with working-roster info
    Response handleGetRoster(const Request& request, const LaSyncMap& sync);

    // PUT /api/internal/roster/:playerId/team  — assign/unassign player
    Response handleAssignPlayer(const Request& request);

    // POST /api/internal/players  — create new person+player and add to pool
    Response handleCreatePlayer(const Request& request);

    // DELETE /api/internal/roster/:playerId  — permanently remove player from DB
    Response handleDeletePlayer(const Request& request);

    // PUT /api/internal/roster/:playerId/attrs  — update position + injured
    Response handleUpdatePlayerAttrs(const Request& request);

    // Helpers
    std::string parseJsonString(const std::string& body, const std::string& key);
    int  parseJsonInt(const std::string& body, const std::string& key, int defaultValue = 0);
    std::string createJsonResponse(bool success, const std::string& message, const std::string& data = "");
    std::string extractPlayerId(const std::string& path);
};
