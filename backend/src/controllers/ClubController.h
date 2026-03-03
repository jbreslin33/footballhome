#ifndef CLUB_CONTROLLER_H
#define CLUB_CONTROLLER_H

#include "../core/Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../database/Database.h"
#include <memory>
#include <pqxx/pqxx>

class ClubController : public Controller {
public:
    ClubController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;
    
    // Handlers
    Response handleGetAllClubs(const Request& request);
    Response handleGetClubDetail(const Request& request);
    
    // Helper methods
    std::string escapeJson(const std::string& input);
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
};

#endif
