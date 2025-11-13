#include "TeamController.h"
#include <sstream>
#include <regex>

TeamController::TeamController() {
    team_model_ = std::make_unique<Team>();
}

void TeamController::registerRoutes(Router& router, const std::string& prefix) {
    // Register route with parameter syntax
    router.get(prefix + "/:teamId/roster", [this](const Request& request) {
        return this->handleGetRoster(request);
    });
}

Response TeamController::handleGetRoster(const Request& request) {
    try {
        // Extract team ID from path like "/api/teams/d37eb44b-8e47-0005-9060-f0cbe96fe089/roster"
        std::string team_id = extractTeamIdFromPath(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting roster for team: " << team_id << std::endl;
        
        // Get team roster from database
        std::string roster_json = team_model_->getTeamRoster(team_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Team roster retrieved successfully\",";
        json << "\"data\":" << roster_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetRoster error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve team roster");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string TeamController::extractTeamIdFromPath(const std::string& path) {
    // Extract UUID from path like "/api/teams/d37eb44b-8e47-0005-9060-f0cbe96fe089/roster"
    std::regex uuid_regex(R"(/api/teams/([a-f0-9-]{36})/roster)");
    std::smatch match;
    
    if (std::regex_search(path, match, uuid_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string TeamController::createJSONResponse(bool success, const std::string& message) {
    std::ostringstream json;
    json << "{";
    json << "\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << message << "\"";
    json << "}";
    return json.str();
}