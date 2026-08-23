#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>
#include <vector>
#include <string>

class EligibilityController : public Controller {
private:
    Database* db_;

public:
    EligibilityController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Lineup management
    Response handleGetMatchLineup(const Request& request);
    Response handleSaveMatchLineup(const Request& request);
    Response handleGetLineupMetadata(const Request& request);
    Response handleSaveLineupMetadata(const Request& request);
    Response handleGetPositions(const Request& request);

    // Path/JSON helpers
    std::string extractIdFromPath(const std::string& path, const std::string& pattern);
    std::string extractUserIdFromToken(const Request& request);
    std::string parseJsonString(const std::string& body, const std::string& key);
    int parseJsonInt(const std::string& body, const std::string& key, int defaultValue = 0);
    bool parseJsonBool(const std::string& body, const std::string& key, bool defaultValue = false);
    std::string createJsonResponse(bool success, const std::string& message, const std::string& data = "");
};
