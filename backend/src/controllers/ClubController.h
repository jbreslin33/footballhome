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
    Response handleGetClubGameModel(const Request& request);
    Response handleGetClubGameModelStructure(const Request& request);
    Response handleListGameModelAdminEntities(const Request& request, const std::string& entity);
    Response handleCreateGameModelAdminEntity(const Request& request, const std::string& entity);
    Response handleDeleteGameModelAdminEntity(const Request& request, const std::string& entity, int id);
    
    // Helper methods
};

#endif
