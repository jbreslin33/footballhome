#include "DivisionController.h"
#include <iostream>
#include <sstream>
#include <regex>

// Helper function to escape JSON strings
static std::string escapeJson(const std::string& input) {
    std::string output;
    for (char c : input) {
        switch (c) {
            case '"':  output += "\\\""; break;
            case '\\': output += "\\\\"; break;
            case '\b': output += "\\b"; break;
            case '\f': output += "\\f"; break;
            case '\n': output += "\\n"; break;
            case '\r': output += "\\r"; break;
            case '\t': output += "\\t"; break;
            default:
                if (c < 0x20) {
                    output += "\\u00";
                    output += "0123456789abcdef"[c >> 4];
                    output += "0123456789abcdef"[c & 0x0f];
                } else {
                    output += c;
                }
        }
    }
    return output;
}

DivisionController::DivisionController() {
    db_ = Database::getInstance();
}

void DivisionController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering division routes with prefix: " << prefix << std::endl;
    
    // Get all divisions
    router.get(prefix + "/divisions", [this](const Request& request) {
        return this->handleGetDivisions(request);
    });
    
    // Get divisions for a specific club
    router.get(prefix + "/clubs/:clubId/divisions", [this](const Request& request) {
        return this->handleGetClubDivisions(request);
    });
    
    // Get division players
    router.get(prefix + "/divisions/:divisionId/players", [this](const Request& request) {
        return this->handleGetDivisionPlayers(request);
    });

    // Update division player
    router.put(prefix + "/divisions/:divisionId/players/:playerId", [this](const Request& request) {
        return this->handleUpdateDivisionPlayer(request);
    });
}

Response DivisionController::handleGetDivisions(const Request& request) {
    std::cout << "=== handleGetDivisions ===" << std::endl;
    
    try {
        // Query to get all sport divisions
        std::string query = 
            "SELECT sd.id, sd.display_name, c.display_name as club_name "
            "FROM sport_divisions sd "
            "JOIN clubs c ON sd.club_id = c.id "
            "ORDER BY c.display_name, sd.display_name";
        
        pqxx::result result = db_->query(query);
        
        std::cout << "Found " << result.size() << " divisions" << std::endl;
        
        // Build JSON array of divisions
        std::ostringstream divisionsJson;
        divisionsJson << "[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) divisionsJson << ",";
            first = false;
            
            divisionsJson << "{";
            divisionsJson << "\"id\":\"" << row["id"].c_str() << "\",";
            divisionsJson << "\"display_name\":\"" << row["display_name"].c_str() << "\",";
            divisionsJson << "\"club_name\":\"" << row["club_name"].c_str() << "\"";
            divisionsJson << "}";
        }
        
        divisionsJson << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Divisions retrieved successfully", divisionsJson.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetDivisions: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
}

Response DivisionController::handleGetClubDivisions(const Request& request) {
    std::cout << "=== handleGetClubDivisions ===" << std::endl;
    std::cout << "Path: " << request.getPath() << std::endl;
    
    try {
        // Extract club_id from path
        std::string path = request.getPath();
        std::string clubId;
        
        // Match /clubs/{uuid}/divisions
        std::regex pattern("/clubs/([a-f0-9-]{36})/divisions");
        std::smatch matches;
        if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
            clubId = matches[1].str();
        }
        
        if (clubId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid club ID"));
        }
        
        std::cout << "Club ID: " << clubId << std::endl;
        
        // Query to get all divisions for a specific club
        std::string query = 
            "SELECT sd.id, sd.display_name "
            "FROM sport_divisions sd "
            "WHERE sd.club_id = $1 "
            "ORDER BY sd.display_name";
        
        pqxx::result result = db_->query(query, {clubId});
        
        std::cout << "Found " << result.size() << " divisions for club" << std::endl;
        
        // Build JSON array of divisions
        std::ostringstream divisionsJson;
        divisionsJson << "[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) divisionsJson << ",";
            first = false;
            
            divisionsJson << "{";
            divisionsJson << "\"id\":\"" << row["id"].c_str() << "\",";
            divisionsJson << "\"display_name\":\"" << row["display_name"].c_str() << "\"";
            divisionsJson << "}";
        }
        
        divisionsJson << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Divisions retrieved successfully", divisionsJson.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetClubDivisions: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
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
            query = "SELECT DISTINCT "
                   "gen_random_uuid() as id, tp.player_id, $1::uuid as division_id, 'active' as status, "
                   "null::varchar as registration_number, '2024-2025' as last_active_season, "
                   "CURRENT_TIMESTAMP as created_at, CURRENT_TIMESTAMP as updated_at, "
                   "u.first_name, u.last_name, u.date_of_birth, u.email, u.phone "
                   "FROM sport_divisions sd "
                   "JOIN teams t ON sd.id = t.division_id "
                   "JOIN team_players tp ON t.id = tp.team_id "
                   "JOIN players p ON tp.player_id = p.id "
                   "JOIN users u ON p.id = u.id "
                   "WHERE sd.id = $1 "
                   "ORDER BY u.last_name, u.first_name";
            params.push_back(divisionId);
        } else {
            query = "SELECT DISTINCT "
                   "gen_random_uuid() as id, tp.player_id, $1::uuid as division_id, 'active' as status, "
                   "null::varchar as registration_number, '2024-2025' as last_active_season, "
                   "CURRENT_TIMESTAMP as created_at, CURRENT_TIMESTAMP as updated_at, "
                   "u.first_name, u.last_name, u.date_of_birth, u.email, u.phone "
                   "FROM sport_divisions sd "
                   "JOIN teams t ON sd.id = t.division_id "
                   "JOIN team_players tp ON t.id = tp.team_id "
                   "JOIN players p ON tp.player_id = p.id "
                   "JOIN users u ON p.id = u.id "
                   "WHERE sd.id = $1 AND 'active' = $2 "
                   "ORDER BY u.last_name, u.first_name";
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
            playersJson << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\",";
            playersJson << "\"player_id\":\"" << escapeJson(row["player_id"].c_str()) << "\",";
            playersJson << "\"division_id\":\"" << escapeJson(row["division_id"].c_str()) << "\",";
            playersJson << "\"status\":\"" << escapeJson(row["status"].c_str()) << "\",";
            
            if (!row["registration_number"].is_null()) {
                playersJson << "\"registration_number\":\"" << escapeJson(row["registration_number"].c_str()) << "\",";
            } else {
                playersJson << "\"registration_number\":null,";
            }
            
            if (!row["last_active_season"].is_null()) {
                playersJson << "\"last_active_season\":\"" << escapeJson(row["last_active_season"].c_str()) << "\",";
            } else {
                playersJson << "\"last_active_season\":null,";
            }
            
            playersJson << "\"first_name\":\"" << escapeJson(row["first_name"].c_str()) << "\",";
            playersJson << "\"last_name\":\"" << escapeJson(row["last_name"].c_str()) << "\",";
            
            if (!row["date_of_birth"].is_null()) {
                playersJson << "\"date_of_birth\":\"" << escapeJson(row["date_of_birth"].c_str()) << "\",";
            } else {
                playersJson << "\"date_of_birth\":null,";
            }
            
            if (!row["email"].is_null()) {
                playersJson << "\"email\":\"" << escapeJson(row["email"].c_str()) << "\",";
            } else {
                playersJson << "\"email\":null,";
            }
            
            if (!row["phone"].is_null()) {
                playersJson << "\"phone\":\"" << escapeJson(row["phone"].c_str()) << "\"";
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
    // Match UUID pattern: /divisions/{uuid}
    std::regex pattern("/divisions/([a-f0-9-]{36})");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

std::string DivisionController::extractPlayerIdFromPath(const std::string& path) {
    // Match UUID pattern: /players/{uuid}
    std::regex pattern("/players/([a-f0-9-]{36})");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

Response DivisionController::handleUpdateDivisionPlayer(const Request& request) {
    try {
        std::string divisionId = extractDivisionIdFromPath(request.getPath());
        std::string playerId = extractPlayerIdFromPath(request.getPath());
        
        if (divisionId.empty() || playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid division ID or player ID"));
        }
        
        std::string body = request.getBody();
        
        // Parse fields
        std::string firstName, lastName;
        
        std::regex fn_regex(R"rx("firstName"\s*:\s*"([^"]+)")rx");
        std::smatch fn_match;
        if (std::regex_search(body, fn_match, fn_regex)) firstName = fn_match[1].str();
        
        std::regex ln_regex(R"rx("lastName"\s*:\s*"([^"]+)")rx");
        std::smatch ln_match;
        if (std::regex_search(body, ln_match, ln_regex)) lastName = ln_match[1].str();
        
        // Update User (Name)
        if (!firstName.empty() && !lastName.empty()) {
            std::string sql = "UPDATE users SET first_name = $1, last_name = $2, updated_at = NOW() WHERE id = $3";
            db_->query(sql, {firstName, lastName, playerId});
        }
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Player updated successfully"));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleUpdateDivisionPlayer: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
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
