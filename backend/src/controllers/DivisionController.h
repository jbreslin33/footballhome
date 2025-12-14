#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>

class DivisionController : public Controller {
private:
    Database* db_;

public:
    DivisionController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetDivisions(const Request& request);
    Response handleGetDivisionPlayers(const Request& request);
    Response handleUpdateDivisionPlayer(const Request& request);
    
    // Helper methods
    std::string extractDivisionIdFromPath(const std::string& path);
    std::string extractPlayerIdFromPath(const std::string& path);
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
};
