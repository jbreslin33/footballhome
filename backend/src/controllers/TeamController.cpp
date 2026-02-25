#include "TeamController.h"
#include <sstream>
#include <regex>
#include <iostream>

TeamController::TeamController() {
    team_model_ = std::make_unique<Team>();
}

void TeamController::registerRoutes(Router& router, const std::string& prefix) {
    // Get all teams
    router.get(prefix, [this](const Request& request) {
        return this->handleGetAllTeams(request);
    });
    
    // Get roster statuses (lookup table)
    router.get(prefix + "/roster-statuses", [this](const Request& request) {
        return this->handleGetRosterStatuses(request);
    });
    
    // Get team roster
    router.get(prefix + "/:teamId/roster", [this](const Request& request) {
        return this->handleGetRoster(request);
    });
    
    // Get division standings for a team
    router.get(prefix + "/:teamId/standings", [this](const Request& request) {
        return this->handleGetDivisionStandings(request);
    });
    
    // Update roster member (jersey number, position, captain status, roster status)
    router.put(prefix + "/:teamId/roster/:playerId", [this](const Request& request) {
        return this->handleUpdateRosterMember(request);
    });
    
    // Remove player from roster
    router.del(prefix + "/:teamId/roster/:playerId", [this](const Request& request) {
        return this->handleRemoveRosterMember(request);
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
        
        // Get team roster from database (now includes roster status)
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

Response TeamController::handleGetRosterStatuses(const Request& request) {
    try {
        std::cout << "🔍 Getting roster statuses" << std::endl;
        
        std::string statuses_json = team_model_->getRosterStatuses();
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Roster statuses retrieved successfully\",";
        json << "\"data\":" << statuses_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetRosterStatuses error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve roster statuses");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string TeamController::extractTeamIdFromPath(const std::string& path) {
    // Extract team ID (integer or UUID) from path like "/api/teams/35/roster"
    // or "/api/teams/d37eb44b-8e47-0005-9060-f0cbe96fe089/roster"
    std::regex id_regex(R"(/api/teams/([^/]+)/roster)");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string TeamController::extractPlayerIdFromPath(const std::string& path) {
    // Extract player ID from path like "/api/teams/team-id/roster/player-id"
    std::regex id_regex(R"(/api/teams/[^/]+/roster/([^/]+))");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

Response TeamController::handleUpdateRosterMember(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        std::string player_id = extractPlayerIdFromPath(request.getPath());
        
        if (team_id.empty() || player_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID or player ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔧 Updating roster member: " << player_id << " for team: " << team_id << std::endl;
        
        // Parse request body for updates
        std::string body = request.getBody();
        
        // Simple JSON parsing for jersey_number, position_id, is_captain, is_vice_captain, roster_status_id
        std::string jersey_number = "";
        std::string roster_status_id = "";
        bool is_captain = false;
        bool is_vice_captain = false;
        
        // Parse jersey_number
        std::regex jersey_regex(R"("jerseyNumber"\s*:\s*(\d+|null))");
        std::smatch jersey_match;
        if (std::regex_search(body, jersey_match, jersey_regex)) {
            std::string val = jersey_match[1].str();
            if (val != "null") {
                jersey_number = val;
            }
        }
        
        // Parse roster_status_id
        std::regex status_regex(R"("rosterStatusId"\s*:\s*(\d+))");
        std::smatch status_match;
        if (std::regex_search(body, status_match, status_regex)) {
            roster_status_id = status_match[1].str();
        }
        
        // Parse is_captain
        std::regex captain_regex(R"("isCaptain"\s*:\s*(true|false))");
        std::smatch captain_match;
        if (std::regex_search(body, captain_match, captain_regex)) {
            is_captain = (captain_match[1].str() == "true");
        }
        
        // Parse is_vice_captain  
        std::regex vc_regex(R"("isViceCaptain"\s*:\s*(true|false))");
        std::smatch vc_match;
        if (std::regex_search(body, vc_match, vc_regex)) {
            is_vice_captain = (vc_match[1].str() == "true");
        }

        // Parse firstName
        std::string first_name = "";
        std::regex first_name_regex(R"rx("firstName"\s*:\s*"([^"]+)")rx");
        std::smatch first_name_match;
        if (std::regex_search(body, first_name_match, first_name_regex)) {
            first_name = first_name_match[1].str();
        }

        // Parse lastName
        std::string last_name = "";
        std::regex last_name_regex(R"rx("lastName"\s*:\s*"([^"]+)")rx");
        std::smatch last_name_match;
        if (std::regex_search(body, last_name_match, last_name_regex)) {
            last_name = last_name_match[1].str();
        }
        
        // Update the roster entry
        bool success = team_model_->updateRosterMember(team_id, player_id, jersey_number, 
                                                        is_captain, is_vice_captain, roster_status_id,
                                                        first_name, last_name);
        
        if (success) {
            std::string json = createJSONResponse(true, "Roster member updated successfully");
            return Response(HttpStatus::OK, json);
        } else {
            std::string json = createJSONResponse(false, "Failed to update roster member");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleUpdateRosterMember error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to update roster member");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleRemoveRosterMember(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        std::string player_id = extractPlayerIdFromPath(request.getPath());
        
        if (team_id.empty() || player_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID or player ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🗑️ Removing roster member: " << player_id << " from team: " << team_id << std::endl;
        
        // Deactivate the player (soft delete)
        bool success = team_model_->removeRosterMember(team_id, player_id);
        
        if (success) {
            std::string json = createJSONResponse(true, "Player removed from roster");
            return Response(HttpStatus::OK, json);
        } else {
            std::string json = createJSONResponse(false, "Failed to remove player from roster");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleRemoveRosterMember error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to remove player from roster");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleGetAllTeams(const Request& request) {
    try {
        std::cout << "🔍 Getting all teams" << std::endl;
        
        // Get all teams from database
        std::string teams_json = team_model_->getAllTeams();
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Teams retrieved successfully\",";
        json << "\"data\":" << teams_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetAllTeams error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve teams");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleGetDivisionStandings(const Request& request) {
    try {
        std::string team_id = extractTeamIdGeneric(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting division standings for team: " << team_id << std::endl;
        
        std::string standings_json = team_model_->getDivisionStandings(team_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Division standings retrieved successfully\",";
        json << "\"data\":" << standings_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetDivisionStandings error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve division standings");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string TeamController::extractTeamIdGeneric(const std::string& path) {
    // Extract team ID from path like "/api/teams/123/standings" or "/api/teams/uuid/standings"
    // Matches any non-slash characters between /teams/ and /standings
    std::regex id_regex(R"(/api/teams/([^/]+)/standings)");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
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