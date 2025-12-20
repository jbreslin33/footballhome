#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>

class TacticalBoardController : public Controller {
private:
    Database* db_;

public:
    TacticalBoardController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Board CRUD
    Response handleCreateBoard(const Request& request);
    Response handleGetBoard(const Request& request);
    Response handleUpdateBoard(const Request& request);
    Response handleDeleteBoard(const Request& request);
    
    // List boards by entity
    Response handleGetBoardsByMatch(const Request& request);
    Response handleGetBoardsByPractice(const Request& request);
    Response handleGetBoardsByTeam(const Request& request);
    Response handleGetBoardsByClub(const Request& request);
    
    // Lookup tables
    Response handleGetBoardTypes(const Request& request);
    Response handleGetStances(const Request& request);
    Response handleGetFieldThirds(const Request& request);
    Response handleGetPositionRoles(const Request& request);
    Response handleGetArrowTypes(const Request& request);
    Response handleGetLineStyles(const Request& request);
    
    // Tags
    Response handleGetTags(const Request& request);
    Response handleAddTag(const Request& request);
    
    // Helper methods
    std::string extractUserIdFromToken(const Request& request);
    std::string extractIdFromPath(const std::string& path, const std::string& pattern);
    std::string parseJsonString(const std::string& body, const std::string& key);
    int parseJsonInt(const std::string& body, const std::string& key, int defaultValue = 0);
    bool parseJsonBool(const std::string& body, const std::string& key, bool defaultValue = false);
};
