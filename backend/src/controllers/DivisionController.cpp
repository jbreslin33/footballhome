#include "DivisionController.h"
#include <iostream>
#include <sstream>
#include <regex>

DivisionController::DivisionController() {
    db_ = Database::getInstance();
}

void DivisionController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering division routes with prefix: " << prefix << std::endl;
    
    // Get division players
    router.get(prefix + "/divisions/:divisionId/players", [this](const Request& request) {
        return this->handleGetDivisionPlayers(request);
    });
}

Response DivisionController::handleGetDivisionPlayers(const Request& request) {
    std::cout << "=== handleGetDivisionPlayers ===" << std::endl;
    std::cout << "Path: " << request.getPath() << std::endl;
    
    try {
        // Extract division_id from path
        std::string divisionId = extractDivisionIdFromPath(request.getPath());
        if (divisionId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid division ID"));
        }
        
        std::cout << "Division ID: " << divisionId << std::endl;
        
        // Get status filter from query params (default to 'active')
        std::string status = request.getQueryParam("status");
        if (status.empty()) {
            status = "active";
        }
        std::cout << "Status filter: " << status << std::endl;
        
        // Build query based on status filter
        std::string query;
        std::vector<std::string> params;
        
        if (status == "all") {
            query = "SELECT dp.id, dp.player_id, dp.division_id, dp.status, "
                   "dp.registration_number, dp.last_active_season, dp.created_at, dp.updated_at, "
                   "p.first_name, p.last_name, p.date_of_birth, p.email, p.phone, "
                   "u.id as user_id, u.email as user_email "
                   "FROM division_players dp "
                   "JOIN players p ON dp.player_id = p.id "
                   "LEFT JOIN users u ON p.user_id = u.id "
                   "WHERE dp.division_id = $1 "
                   "ORDER BY p.last_name, p.first_name";
            params.push_back(divisionId);
        } else {
            query = "SELECT dp.id, dp.player_id, dp.division_id, dp.status, "
                   "dp.registration_number, dp.last_active_season, dp.created_at, dp.updated_at, "
                   "p.first_name, p.last_name, p.date_of_birth, p.email, p.phone, "
                   "u.id as user_id, u.email as user_email "
                   "FROM division_players dp "
                   "JOIN players p ON dp.player_id = p.id "
                   "LEFT JOIN users u ON p.user_id = u.id "
                   "WHERE dp.division_id = $1 AND dp.status = $2 "
                   "ORDER BY p.last_name, p.first_name";
            params.push_back(divisionId);
            params.push_back(status);
        }
        
        pqxx::result result = db_->query(query, params);
        
        std::cout << "Found " << result.size() << " players" << std::endl;
        
        // Build JSON array of players
        std::ostringstream playersJson;
        playersJson << "[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) playersJson << ",";
            first = false;
            
            playersJson << "{";
            playersJson << "\"id\":" << row["id"].as<int>() << ",";
            playersJson << "\"player_id\":" << row["player_id"].as<int>() << ",";
            playersJson << "\"division_id\":" << row["division_id"].as<int>() << ",";
            playersJson << "\"status\":\"" << row["status"].c_str() << "\",";
            
            if (!row["registration_number"].is_null()) {
                playersJson << "\"registration_number\":\"" << row["registration_number"].c_str() << "\",";
            } else {
                playersJson << "\"registration_number\":null,";
            }
            
            if (!row["last_active_season"].is_null()) {
                playersJson << "\"last_active_season\":\"" << row["last_active_season"].c_str() << "\",";
            } else {
                playersJson << "\"last_active_season\":null,";
            }
            
            playersJson << "\"first_name\":\"" << row["first_name"].c_str() << "\",";
            playersJson << "\"last_name\":\"" << row["last_name"].c_str() << "\",";
            
            if (!row["date_of_birth"].is_null()) {
                playersJson << "\"date_of_birth\":\"" << row["date_of_birth"].c_str() << "\",";
            } else {
                playersJson << "\"date_of_birth\":null,";
            }
            
            if (!row["email"].is_null()) {
                playersJson << "\"email\":\"" << row["email"].c_str() << "\",";
            } else {
                playersJson << "\"email\":null,";
            }
            
            if (!row["phone"].is_null()) {
                playersJson << "\"phone\":\"" << row["phone"].c_str() << "\"";
            } else {
                playersJson << "\"phone\":null";
            }
            
            playersJson << "}";
        }
        
        playersJson << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Players retrieved successfully", playersJson.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetDivisionPlayers: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
}

std::string DivisionController::extractDivisionIdFromPath(const std::string& path) {
    std::regex pattern("/divisions/(\\d+)");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

std::string DivisionController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{\"success\":" << (success ? "true" : "false") 
         << ",\"message\":\"" << message << "\"";
    if (!data.empty()) {
        json << ",\"data\":" << data;
    }
    json << "}";
    return json.str();
}
