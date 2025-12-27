#ifndef STATS_CONTROLLER_H
#define STATS_CONTROLLER_H

#include "Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../database/DatabaseConnection.h"
#include <memory>
#include <pqxx/pqxx>

class StatsController : public Controller {
public:
    StatsController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::shared_ptr<DatabaseConnection> db_connection_;
    
    // Handlers
    Response handleGetStandings(const Request& request);
    Response handleGetPlayerStats(const Request& request);
    Response handleGetMatches(const Request& request);
    
    // Helper methods
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
};

#endif
