#include "TacticalBoardController.h"
#include "../database/SqlFileLogger.h"
#include <string>
#include <sstream>
#include <iomanip>
#include <cctype>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>
#include <iostream>

// Helper function to decode base64url to string
static std::string base64UrlDecode(const std::string& input) {
    std::string base64 = input;
    
    // Convert base64url to base64
    for (size_t i = 0; i < base64.length(); ++i) {
        if (base64[i] == '-') base64[i] = '+';
        else if (base64[i] == '_') base64[i] = '/';
    }
    
    // Add padding if necessary
    while (base64.length() % 4 != 0) {
        base64 += '=';
    }
    
    // Decode base64
    BIO *bio, *b64;
    char *buffer = new char[base64.length()];
    
    bio = BIO_new_mem_buf(base64.c_str(), base64.length());
    b64 = BIO_new(BIO_f_base64());
    bio = BIO_push(b64, bio);
    
    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
    int decoded_length = BIO_read(bio, buffer, base64.length());
    BIO_free_all(bio);
    
    std::string result(buffer, decoded_length);
    delete[] buffer;
    
    return result;
}

// Helper function to escape JSON strings
static std::string escapeJson(std::string input) {
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
}TacticalBoardController::TacticalBoardController() {
    db_ = Database::getInstance();
}

void TacticalBoardController::registerRoutes(Router& router, const std::string& prefix) {
    // Lookup tables - GET only
    router.get(prefix + "/types", [this](const Request& request) {
        return this->handleGetBoardTypes(request);
    });
    
    router.get(prefix + "/stances", [this](const Request& request) {
        return this->handleGetStances(request);
    });
    
    router.get(prefix + "/field-thirds", [this](const Request& request) {
        return this->handleGetFieldThirds(request);
    });
    
    router.get(prefix + "/position-roles", [this](const Request& request) {
        return this->handleGetPositionRoles(request);
    });
    
    router.get(prefix + "/arrow-types", [this](const Request& request) {
        return this->handleGetArrowTypes(request);
    });
    
    router.get(prefix + "/line-styles", [this](const Request& request) {
        return this->handleGetLineStyles(request);
    });
    
    router.get(prefix + "/tags", [this](const Request& request) {
        return this->handleGetTags(request);
    });
    
    // Board CRUD
    router.post(prefix, [this](const Request& request) {
        return this->handleCreateBoard(request);
    });
    
    router.get(prefix + "/:boardId", [this](const Request& request) {
        return this->handleGetBoard(request);
    });
    
    router.put(prefix + "/:boardId", [this](const Request& request) {
        return this->handleUpdateBoard(request);
    });
    
    router.del(prefix + "/:boardId", [this](const Request& request) {
        return this->handleDeleteBoard(request);
    });
    
    // List boards by entity
    router.get(prefix + "/match/:matchId", [this](const Request& request) {
        return this->handleGetBoardsByMatch(request);
    });
    
    router.get(prefix + "/practice/:practiceId", [this](const Request& request) {
        return this->handleGetBoardsByPractice(request);
    });
    
    router.get(prefix + "/team/:teamId", [this](const Request& request) {
        return this->handleGetBoardsByTeam(request);
    });
    
    router.get(prefix + "/club/:clubId", [this](const Request& request) {
        return this->handleGetBoardsByClub(request);
    });
    
    // Tags
    router.post(prefix + "/:boardId/tags/:tagId", [this](const Request& request) {
        return this->handleAddTag(request);
    });
}

// Lookup table handlers
Response TacticalBoardController::handleGetBoardTypes(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, description, display_order "
        "FROM tactical_board_types ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetStances(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, description, display_order "
        "FROM tactical_stances ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetFieldThirds(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, description, display_order "
        "FROM tactical_field_thirds ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetPositionRoles(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, description, display_order "
        "FROM tactical_position_roles ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetArrowTypes(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, description, color, display_order "
        "FROM tactical_arrow_types ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\",";
        
        if (!row["color"].is_null()) {
            json << "\"color\":\"" << escapeJson(row["color"].c_str()) << "\",";
        } else {
            json << "\"color\":null,";
        }
        
        json << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetLineStyles(const Request& request) {
    auto result = db_->query(
        "SELECT id, code, name, display_order "
        "FROM tactical_line_styles ORDER BY display_order"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":" << row["id"] << ","
             << "\"code\":\"" << escapeJson(row["code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"displayOrder\":" << row["display_order"]
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetTags(const Request& request) {
    auto result = db_->query(
        "SELECT id, name, description, color, created_at "
        "FROM tactical_board_tags ORDER BY name"
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
        
        if (!row["description"].is_null()) {
            json << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\",";
        } else {
            json << "\"description\":null,";
        }
        
        if (!row["color"].is_null()) {
            json << "\"color\":\"" << escapeJson(row["color"].c_str()) << "\",";
        } else {
            json << "\"color\":null,";
        }
        
        json << "\"createdAt\":\"" << escapeJson(row["created_at"].c_str()) << "\""
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

// Board CRUD handlers
Response TacticalBoardController::handleCreateBoard(const Request& request) {
    try {
        std::string body = request.getBody();
        
        // Extract user ID from token
        std::string userId = extractUserIdFromToken(request);
        if (userId.empty()) {
            return Response::unauthorized(R"({"error":"Unauthorized"})");
        }
        
        // Parse required fields
        std::string name = parseJsonString(body, "name");
        int boardTypeId = parseJsonInt(body, "boardTypeId", 1);
        
        if (name.empty()) {
            return Response::badRequest(R"({"error":"Name is required"})");
        }
        
        // Parse optional fields
        std::string description = parseJsonString(body, "description");
        int stanceId = parseJsonInt(body, "stanceId", 0);
        int fieldThirdId = parseJsonInt(body, "fieldThirdId", 0);
        std::string formationHome = parseJsonString(body, "formationHome");
        std::string formationOpponent = parseJsonString(body, "formationOpponent");
        int canvasWidth = parseJsonInt(body, "canvasWidth", 1200);
        int canvasHeight = parseJsonInt(body, "canvasHeight", 800);
        bool isPublic = parseJsonBool(body, "isPublic", false);
        bool isTemplate = parseJsonBool(body, "isTemplate", false);
        
        // Build INSERT query - use NULL for optional stance_id and field_third_id
        std::ostringstream query;
        query << "INSERT INTO tactical_boards (name, description, created_by, board_type_id, "
              << "stance_id, field_third_id, formation_home, formation_opponent, "
              << "canvas_width, canvas_height, is_public, is_template) "
              << "VALUES ($1, $2, $3, $4, ";
        
        int paramNum = 5;
        
        // Handle NULL values for stance_id
        if (stanceId > 0) {
            query << "$" << paramNum++ << ", ";
        } else {
            query << "NULL, ";
        }
        
        // Handle NULL values for field_third_id
        if (fieldThirdId > 0) {
            query << "$" << paramNum++ << ", ";
        } else {
            query << "NULL, ";
        }
        
        // Remaining parameters
        query << "$" << paramNum++ << ", $" << paramNum++ << ", $" << paramNum++ << ", $" << paramNum++ 
              << ", $" << paramNum++ << ", $" << paramNum++ << ") RETURNING id";
        
        std::vector<std::string> params = {
            name,
            description,
            userId,
            std::to_string(boardTypeId)
        };
        
        if (stanceId > 0) {
            params.push_back(std::to_string(stanceId));
        }
        if (fieldThirdId > 0) {
            params.push_back(std::to_string(fieldThirdId));
        }
        
        params.push_back(formationHome);
        params.push_back(formationOpponent);
        params.push_back(std::to_string(canvasWidth));
        params.push_back(std::to_string(canvasHeight));
        params.push_back(isPublic ? "true" : "false");
        params.push_back(isTemplate ? "true" : "false");
        
        auto result = db_->query(query.str(), params);
        
        if (result.empty()) {
            return Response::internalError(R"({"error":"Failed to create board"})");
        }
        
        std::string boardId = result[0]["id"].c_str();
        
        // Log to SQL file for persistence
        std::ostringstream sqlLog;
        sqlLog << "INSERT INTO tactical_boards (id, name, description, created_by, board_type_id, "
               << "stance_id, field_third_id, formation_home, formation_opponent, "
               << "canvas_width, canvas_height, is_public, is_template) VALUES ('"
               << boardId << "', '" << name << "', '" << description << "', '" << userId << "', "
               << boardTypeId << ", ";
        
        if (stanceId > 0) {
            sqlLog << stanceId << ", ";
        } else {
            sqlLog << "NULL, ";
        }
        
        if (fieldThirdId > 0) {
            sqlLog << fieldThirdId << ", ";
        } else {
            sqlLog << "NULL, ";
        }
        
        sqlLog << "'" << formationHome << "', '" << formationOpponent << "', "
               << canvasWidth << ", " << canvasHeight << ", "
               << (isPublic ? "true" : "false") << ", " << (isTemplate ? "true" : "false") << ");";
        
        SqlFileLogger::log("tactical_boards", sqlLog.str());

        // --- Link to Team (if provided) ---
        std::string teamId = parseJsonString(body, "teamId");
        if (!teamId.empty()) {
            db_->execute(
                "INSERT INTO tactical_board_entities (tactical_board_id, team_id) VALUES ($1, $2)",
                {boardId, teamId}
            );
            
            std::ostringstream entityLog;
            entityLog << "INSERT INTO tactical_board_entities (tactical_board_id, team_id) VALUES ('"
                      << boardId << "', '" << teamId << "');";
            SqlFileLogger::log("tactical_board_entities", entityLog.str());
        }

        // --- Save Players ---
        // Note: A robust JSON parser would be better here, but we'll do basic extraction for now
        // Expected format: "players":[{"x":100,"y":200,"name":"Player","number":10,"team":"home","color":"#fff","playerId":"uuid"},...]
        
        size_t playersPos = body.find("\"players\":[");
        if (playersPos != std::string::npos) {
            size_t arrayStart = playersPos + 10;
            size_t arrayEnd = body.find(']', arrayStart);
            
            if (arrayEnd != std::string::npos) {
                std::string playersJson = body.substr(arrayStart + 1, arrayEnd - arrayStart - 1);
                
                // Split by objects "},{"
                size_t pos = 0;
                while (pos < playersJson.length()) {
                    size_t objEnd = playersJson.find("}", pos);
                    if (objEnd == std::string::npos) break;
                    
                    std::string playerObj = playersJson.substr(pos, objEnd - pos + 1);
                    
                    // Parse player fields
                    double x = 0, y = 0;
                    int number = 0;
                    std::string pName, pTeam, pColor, pId;
                    
                    // Simple parsing (assumes standard JSON formatting from frontend)
                    // X
                    size_t xPos = playerObj.find("\"x\":");
                    if (xPos != std::string::npos) {
                        size_t end = playerObj.find_first_of(",}", xPos);
                        try { x = std::stod(playerObj.substr(xPos + 4, end - xPos - 4)); } catch(...) {}
                    }
                    
                    // Y
                    size_t yPos = playerObj.find("\"y\":");
                    if (yPos != std::string::npos) {
                        size_t end = playerObj.find_first_of(",}", yPos);
                        try { y = std::stod(playerObj.substr(yPos + 4, end - yPos - 4)); } catch(...) {}
                    }
                    
                    // Number (jerseyNumber)
                    size_t numPos = playerObj.find("\"jerseyNumber\":");
                    if (numPos != std::string::npos) {
                        size_t end = playerObj.find_first_of(",}", numPos);
                        try { number = std::stoi(playerObj.substr(numPos + 15, end - numPos - 15)); } catch(...) {}
                    }
                    
                    // Name
                    pName = parseJsonString(playerObj, "name");
                    
                    // Team
                    pTeam = parseJsonString(playerObj, "team");
                    if (pTeam.empty()) pTeam = "home";
                    
                    // Color
                    pColor = parseJsonString(playerObj, "color");
                    if (pColor.empty()) pColor = "#ffffff";
                    
                    // Player ID
                    pId = parseJsonString(playerObj, "id"); // Frontend sends 'id' for player UUID if linked
                    
                    // Insert into DB
                    std::ostringstream pQuery;
                    pQuery << "INSERT INTO tactical_board_players (tactical_board_id, team, name, jersey_number, position_x, position_y, color, player_id) "
                           << "VALUES ($1, $2, $3, $4, $5, $6, $7, ";
                    
                    std::vector<std::string> pParams = {
                        boardId, pTeam, pName, std::to_string(number), std::to_string(x), std::to_string(y), pColor
                    };
                    
                    if (!pId.empty() && pId.length() > 10) { // Basic validation
                        pQuery << "$8)";
                        pParams.push_back(pId);
                    } else {
                        pQuery << "NULL)";
                    }
                    
                    db_->query(pQuery.str(), pParams);
                    
                    // Log to SQL file
                    std::ostringstream pLog;
                    pLog << "INSERT INTO tactical_board_players (tactical_board_id, team, name, jersey_number, position_x, position_y, color, player_id) VALUES ('"
                         << boardId << "', '" << pTeam << "', '" << pName << "', " << number << ", " << x << ", " << y << ", '" << pColor << "', ";
                    
                    if (!pId.empty() && pId.length() > 10) {
                        pLog << "'" << pId << "');";
                    } else {
                        pLog << "NULL);";
                    }
                    SqlFileLogger::log("tactical_board_players", pLog.str());
                    
                    pos = objEnd + 2; // Skip "},"
                }
            }
        }
        
        // --- Save Arrows ---
        size_t arrowsPos = body.find("\"arrows\":[");
        if (arrowsPos != std::string::npos) {
            size_t arrayStart = arrowsPos + 9;
            size_t arrayEnd = body.find(']', arrayStart);
            
            if (arrayEnd != std::string::npos) {
                std::string arrowsJson = body.substr(arrayStart + 1, arrayEnd - arrayStart - 1);
                
                size_t pos = 0;
                while (pos < arrowsJson.length()) {
                    size_t objEnd = arrowsJson.find("}", pos);
                    if (objEnd == std::string::npos) break;
                    
                    std::string arrowObj = arrowsJson.substr(pos, objEnd - pos + 1);
                    
                    double startX = 0, startY = 0, endX = 0, endY = 0;
                    std::string color;
                    
                    // Parse coordinates
                    size_t sxPos = arrowObj.find("\"startX\":");
                    if (sxPos != std::string::npos) {
                        size_t end = arrowObj.find_first_of(",}", sxPos);
                        try { startX = std::stod(arrowObj.substr(sxPos + 9, end - sxPos - 9)); } catch(...) {}
                    }
                    
                    size_t syPos = arrowObj.find("\"startY\":");
                    if (syPos != std::string::npos) {
                        size_t end = arrowObj.find_first_of(",}", syPos);
                        try { startY = std::stod(arrowObj.substr(syPos + 9, end - syPos - 9)); } catch(...) {}
                    }
                    
                    size_t exPos = arrowObj.find("\"endX\":");
                    if (exPos != std::string::npos) {
                        size_t end = arrowObj.find_first_of(",}", exPos);
                        try { endX = std::stod(arrowObj.substr(exPos + 7, end - exPos - 7)); } catch(...) {}
                    }
                    
                    size_t eyPos = arrowObj.find("\"endY\":");
                    if (eyPos != std::string::npos) {
                        size_t end = arrowObj.find_first_of(",}", eyPos);
                        try { endY = std::stod(arrowObj.substr(eyPos + 7, end - eyPos - 7)); } catch(...) {}
                    }
                    
                    color = parseJsonString(arrowObj, "color");
                    if (color.empty()) color = "#FFD700";
                    
                    // Insert
                    db_->query(
                        "INSERT INTO tactical_board_arrows (tactical_board_id, start_x, start_y, end_x, end_y, color, arrow_type_id, line_style_id) "
                        "VALUES ($1, $2, $3, $4, $5, $6, 1, 1)",
                        {boardId, std::to_string(startX), std::to_string(startY), std::to_string(endX), std::to_string(endY), color}
                    );
                    
                    // Log
                    std::ostringstream aLog;
                    aLog << "INSERT INTO tactical_board_arrows (tactical_board_id, start_x, start_y, end_x, end_y, color, arrow_type_id, line_style_id) VALUES ('"
                         << boardId << "', " << startX << ", " << startY << ", " << endX << ", " << endY << ", '" << color << "', 1, 1);";
                    SqlFileLogger::log("tactical_board_arrows", aLog.str());
                    
                    pos = objEnd + 2;
                }
            }
        }
        
        std::ostringstream response;
        response << "{\"id\":\"" << escapeJson(boardId) << "\",\"message\":\"Board created successfully\"}";
        
        Response r(HttpStatus::CREATED, response.str());
        r.setHeader("Content-Type", "application/json");
        return r;
        
    } catch (const std::exception& e) {
        std::ostringstream error;
        error << "{\"error\":\"" << escapeJson(e.what()) << "\"}";
        return Response::badRequest(error.str());
    }
}

Response TacticalBoardController::handleGetBoard(const Request& request) {
    std::string boardId = extractIdFromPath(request.getPath(), "/tactical-boards/([^/]+)");
    
    if (boardId.empty()) {
        return Response::badRequest(R"({"error":"Invalid board ID"})");
    }
    
    // Get board with all related data in one query
    auto boardResult = db_->query(
        "SELECT tb.id, tb.name, tb.description, tb.formation_home, tb.formation_opponent, "
        "tb.canvas_width, tb.canvas_height, tb.is_public, tb.is_template, "
        "tb.created_at, tb.updated_at, "
        "tbt.id as board_type_id, tbt.code as board_type_code, tbt.name as board_type_name, "
        "ts.id as stance_id, ts.code as stance_code, ts.name as stance_name, "
        "tft.id as field_third_id, tft.code as field_third_code, tft.name as field_third_name, "
        "u.email as creator_email "
        "FROM tactical_boards tb "
        "JOIN tactical_board_types tbt ON tb.board_type_id = tbt.id "
        "LEFT JOIN tactical_stances ts ON tb.stance_id = ts.id "
        "LEFT JOIN tactical_field_thirds tft ON tb.field_third_id = tft.id "
        "LEFT JOIN users u ON tb.created_by = u.id "
        "WHERE tb.id = $1",
        {boardId}
    );
    
    if (boardResult.empty()) {
        return Response::notFound(R"({"error":"Board not found"})");
    }
    
    auto& board = boardResult[0];
    
    std::ostringstream json;
    json << "{"
         << "\"id\":\"" << escapeJson(board["id"].c_str()) << "\","
         << "\"name\":\"" << escapeJson(board["name"].c_str()) << "\","
         << "\"description\":\"" << escapeJson(board["description"].c_str()) << "\","
         << "\"boardType\":{"
         << "\"id\":" << board["board_type_id"] << ","
         << "\"code\":\"" << escapeJson(board["board_type_code"].c_str()) << "\","
         << "\"name\":\"" << escapeJson(board["board_type_name"].c_str()) << "\""
         << "},";
    
    // Add stance if present
    if (!board["stance_id"].is_null()) {
        json << "\"stance\":{"
             << "\"id\":" << board["stance_id"] << ","
             << "\"code\":\"" << escapeJson(board["stance_code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(board["stance_name"].c_str()) << "\""
             << "},";
    }
    
    // Add field third if present
    if (!board["field_third_id"].is_null()) {
        json << "\"fieldThird\":{"
             << "\"id\":" << board["field_third_id"] << ","
             << "\"code\":\"" << escapeJson(board["field_third_code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(board["field_third_name"].c_str()) << "\""
             << "},";
    }
    
    json << "\"formationHome\":\"" << escapeJson(board["formation_home"].c_str()) << "\","
         << "\"formationOpponent\":\"" << escapeJson(board["formation_opponent"].c_str()) << "\","
         << "\"canvasWidth\":" << board["canvas_width"] << ","
         << "\"canvasHeight\":" << board["canvas_height"] << ","
         << "\"isPublic\":" << (std::string(board["is_public"].c_str()) == "t" ? "true" : "false") << ","
         << "\"isTemplate\":" << (std::string(board["is_template"].c_str()) == "t" ? "true" : "false") << ","
         << "\"createdBy\":\"" << escapeJson(board["creator_email"].c_str()) << "\","
         << "\"createdAt\":\"" << escapeJson(board["created_at"].c_str()) << "\","
         << "\"updatedAt\":\"" << escapeJson(board["updated_at"].c_str()) << "\",";
    
    // Get entity links
    auto entitiesResult = db_->query(
        "SELECT match_id, practice_id, team_id, club_id, sport_division_id "
        "FROM tactical_board_entities WHERE tactical_board_id = $1",
        {boardId}
    );
    
    json << "\"entities\":[";
    bool firstEntity = true;
    for (const auto& entity : entitiesResult) {
        if (!firstEntity) json << ",";
        firstEntity = false;
        
        if (!entity["match_id"].is_null()) {
            json << "{\"type\":\"match\",\"id\":\"" << escapeJson(entity["match_id"].c_str()) << "\"}";
        } else if (!entity["practice_id"].is_null()) {
            json << "{\"type\":\"practice\",\"id\":\"" << escapeJson(entity["practice_id"].c_str()) << "\"}";
        } else if (!entity["team_id"].is_null()) {
            json << "{\"type\":\"team\",\"id\":\"" << escapeJson(entity["team_id"].c_str()) << "\"}";
        } else if (!entity["club_id"].is_null()) {
            json << "{\"type\":\"club\",\"id\":\"" << escapeJson(entity["club_id"].c_str()) << "\"}";
        } else if (!entity["sport_division_id"].is_null()) {
            json << "{\"type\":\"division\",\"id\":\"" << escapeJson(entity["sport_division_id"].c_str()) << "\"}";
        }
    }
    json << "],";
    
    // Get players
    auto playersResult = db_->query(
        "SELECT tbp.id, tbp.team, tbp.name, tbp.jersey_number, tbp.position_x, tbp.position_y, tbp.color, tbp.player_id, "
        "tpr.id as role_id, tpr.code as role_code, tpr.name as role_name "
        "FROM tactical_board_players tbp "
        "LEFT JOIN tactical_position_roles tpr ON tbp.position_role_id = tpr.id "
        "WHERE tbp.tactical_board_id = $1 ORDER BY tbp.display_order, tbp.created_at",
        {boardId}
    );
    
    json << "\"players\":[";
    bool firstPlayer = true;
    for (const auto& player : playersResult) {
        if (!firstPlayer) json << ",";
        firstPlayer = false;
        
        json << "{"
             << "\"id\":\"" << escapeJson(player["id"].c_str()) << "\","
             << "\"team\":\"" << escapeJson(player["team"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(player["name"].c_str()) << "\",";
        
        if (!player["jersey_number"].is_null()) {
            json << "\"jerseyNumber\":" << player["jersey_number"] << ",";
        } else {
            json << "\"jerseyNumber\":null,";
        }
        
        if (!player["player_id"].is_null()) {
            json << "\"playerId\":\"" << escapeJson(player["player_id"].c_str()) << "\",";
        } else {
            json << "\"playerId\":null,";
        }
        
        json << "\"positionX\":" << player["position_x"] << ","
             << "\"positionY\":" << player["position_y"] << ","
             << "\"color\":\"" << escapeJson(player["color"].c_str()) << "\"";
        
        if (!player["role_id"].is_null()) {
            json << ",\"positionRole\":{"
                 << "\"id\":" << player["role_id"] << ","
                 << "\"code\":\"" << escapeJson(player["role_code"].c_str()) << "\","
                 << "\"name\":\"" << escapeJson(player["role_name"].c_str()) << "\""
                 << "}";
        }
        
        json << "}";
    }
    json << "],";
    
    // Get arrows
    auto arrowsResult = db_->query(
        "SELECT tba.id, tba.start_x, tba.start_y, tba.end_x, tba.end_y, tba.color, tba.label, "
        "tat.id as type_id, tat.code as type_code, tat.name as type_name, "
        "tls.id as style_id, tls.code as style_code, tls.name as style_name "
        "FROM tactical_board_arrows tba "
        "JOIN tactical_arrow_types tat ON tba.arrow_type_id = tat.id "
        "JOIN tactical_line_styles tls ON tba.line_style_id = tls.id "
        "WHERE tba.tactical_board_id = $1 ORDER BY tba.display_order, tba.created_at",
        {boardId}
    );
    
    json << "\"arrows\":[";
    bool firstArrow = true;
    for (const auto& arrow : arrowsResult) {
        if (!firstArrow) json << ",";
        firstArrow = false;
        
        json << "{"
             << "\"id\":\"" << escapeJson(arrow["id"].c_str()) << "\","
             << "\"startX\":" << arrow["start_x"] << ","
             << "\"startY\":" << arrow["start_y"] << ","
             << "\"endX\":" << arrow["end_x"] << ","
             << "\"endY\":" << arrow["end_y"] << ",";
        
        if (!arrow["color"].is_null()) {
            json << "\"color\":\"" << escapeJson(arrow["color"].c_str()) << "\",";
        } else {
            json << "\"color\":null,";
        }
        
        if (!arrow["label"].is_null()) {
            json << "\"label\":\"" << escapeJson(arrow["label"].c_str()) << "\",";
        } else {
            json << "\"label\":null,";
        }
        
        json << "\"arrowType\":{"
             << "\"id\":" << arrow["type_id"] << ","
             << "\"code\":\"" << escapeJson(arrow["type_code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(arrow["type_name"].c_str()) << "\""
             << "},"
             << "\"lineStyle\":{"
             << "\"id\":" << arrow["style_id"] << ","
             << "\"code\":\"" << escapeJson(arrow["style_code"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(arrow["style_name"].c_str()) << "\""
             << "}"
             << "}";
    }
    json << "]";
    
    json << "}";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleUpdateBoard(const Request& request) {
    Response r(HttpStatus::NOT_IMPLEMENTED, R"({"error":"Not implemented yet"})");
    r.setHeader("Content-Type", "application/json");
    return r;
}

Response TacticalBoardController::handleDeleteBoard(const Request& request) {
    std::string boardId = extractIdFromPath(request.getPath(), "/tactical-boards/([^/]+)");
    
    if (boardId.empty()) {
        return Response::badRequest(R"({"error":"Invalid board ID"})");
    }
    
    db_->query("DELETE FROM tactical_boards WHERE id = $1", {boardId});
    
    return Response(HttpStatus::NO_CONTENT);
}

Response TacticalBoardController::handleGetBoardsByMatch(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/tactical-boards/match/([^/]+)");
    
    auto result = db_->query(
        "SELECT DISTINCT tb.id, tb.name, tb.description, tb.created_at "
        "FROM tactical_boards tb "
        "JOIN tactical_board_entities tbe ON tb.id = tbe.tactical_board_id "
        "WHERE tbe.match_id = $1 "
        "ORDER BY tb.created_at DESC",
        {matchId}
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"createdAt\":\"" << escapeJson(row["created_at"].c_str()) << "\""
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetBoardsByPractice(const Request& request) {
    std::string practiceId = extractIdFromPath(request.getPath(), "/tactical-boards/practice/([^/]+)");
    
    auto result = db_->query(
        "SELECT DISTINCT tb.id, tb.name, tb.description, tb.created_at "
        "FROM tactical_boards tb "
        "JOIN tactical_board_entities tbe ON tb.id = tbe.tactical_board_id "
        "WHERE tbe.practice_id = $1 "
        "ORDER BY tb.created_at DESC",
        {practiceId}
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"createdAt\":\"" << escapeJson(row["created_at"].c_str()) << "\""
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetBoardsByTeam(const Request& request) {
    std::string teamId = extractIdFromPath(request.getPath(), "/tactical-boards/team/([^/]+)");
    
    // Get boards linked to team OR created by current user (if we had user context here)
    // For now, just get boards linked to team
    auto result = db_->query(
        "SELECT DISTINCT tb.id, tb.name, tb.description, tb.created_at "
        "FROM tactical_boards tb "
        "JOIN tactical_board_entities tbe ON tb.id = tbe.tactical_board_id "
        "WHERE tbe.team_id = $1 "
        "ORDER BY tb.created_at DESC",
        {teamId}
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"createdAt\":\"" << escapeJson(row["created_at"].c_str()) << "\""
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleGetBoardsByClub(const Request& request) {
    std::string clubId = extractIdFromPath(request.getPath(), "/tactical-boards/club/([^/]+)");
    
    auto result = db_->query(
        "SELECT DISTINCT tb.id, tb.name, tb.description, tb.created_at "
        "FROM tactical_boards tb "
        "JOIN tactical_board_entities tbe ON tb.id = tbe.tactical_board_id "
        "WHERE tbe.club_id = $1 "
        "ORDER BY tb.created_at DESC",
        {clubId}
    );
    
    std::ostringstream json;
    json << "[";
    bool first = true;
    for (const auto& row : result) {
        if (!first) json << ",";
        first = false;
        json << "{"
             << "\"id\":\"" << escapeJson(row["id"].c_str()) << "\","
             << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\","
             << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\","
             << "\"createdAt\":\"" << escapeJson(row["created_at"].c_str()) << "\""
             << "}";
    }
    json << "]";
    
    return Response::json(json.str());
}

Response TacticalBoardController::handleAddTag(const Request& request) {
    Response r(HttpStatus::NOT_IMPLEMENTED, R"({"error":"Not implemented yet"})");
    r.setHeader("Content-Type", "application/json");
    return r;
}

// Helper methods
std::string TacticalBoardController::extractUserIdFromToken(const Request& request) {
    // Extract Authorization header
    std::string authHeader = request.getHeader("Authorization");
    
    if (authHeader.empty() || authHeader.substr(0, 7) != "Bearer ") {
        return "";
    }
    
    // Extract token (remove "Bearer " prefix)
    std::string token = authHeader.substr(7);
    
    // JWT format: header.payload.signature
    size_t first_dot = token.find('.');
    if (first_dot == std::string::npos) {
        return "";
    }
    
    size_t second_dot = token.find('.', first_dot + 1);
    if (second_dot == std::string::npos) {
        return "";
    }
    
    // Extract payload (between first and second dot)
    std::string payload_encoded = token.substr(first_dot + 1, second_dot - first_dot - 1);
    
    // Decode payload
    std::string payload = base64UrlDecode(payload_encoded);
    
    // Extract userId from JSON payload
    // Format: {"userId":"xxx","email":"..."}
    size_t user_id_start = payload.find("\"userId\":\"");
    if (user_id_start == std::string::npos) {
        return "";
    }
    user_id_start += 10; // Length of "userId":"
    
    size_t user_id_end = payload.find('"', user_id_start);
    if (user_id_end == std::string::npos) {
        return "";
    }
    
    std::string userId = payload.substr(user_id_start, user_id_end - user_id_start);
    return userId;
}

std::string TacticalBoardController::extractIdFromPath(const std::string& path, const std::string& pattern) {
    // Simple extraction - find last path segment
    size_t lastSlash = path.find_last_of('/');
    if (lastSlash == std::string::npos) {
        return "";
    }
    
    std::string id = path.substr(lastSlash + 1);
    
    // Remove query string if present
    size_t questionMark = id.find('?');
    if (questionMark != std::string::npos) {
        id = id.substr(0, questionMark);
    }
    
    return id;
}

std::string TacticalBoardController::parseJsonString(const std::string& body, const std::string& key) {
    std::string searchKey = "\"" + key + "\"";
    size_t keyPos = body.find(searchKey);
    if (keyPos == std::string::npos) {
        return "";
    }
    
    size_t colonPos = body.find(':', keyPos);
    if (colonPos == std::string::npos) {
        return "";
    }
    
    size_t quoteStart = body.find('"', colonPos);
    if (quoteStart == std::string::npos) {
        return "";
    }
    
    size_t quoteEnd = body.find('"', quoteStart + 1);
    if (quoteEnd == std::string::npos) {
        return "";
    }
    
    return body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);
}

int TacticalBoardController::parseJsonInt(const std::string& body, const std::string& key, int defaultValue) {
    std::string searchKey = "\"" + key + "\"";
    size_t keyPos = body.find(searchKey);
    if (keyPos == std::string::npos) {
        return defaultValue;
    }
    
    size_t colonPos = body.find(':', keyPos);
    if (colonPos == std::string::npos) {
        return defaultValue;
    }
    
    // Skip whitespace after colon
    size_t numStart = colonPos + 1;
    while (numStart < body.length() && (body[numStart] == ' ' || body[numStart] == '\t')) {
        numStart++;
    }
    
    // Extract digits
    size_t numEnd = numStart;
    while (numEnd < body.length() && std::isdigit(body[numEnd])) {
        numEnd++;
    }
    
    if (numEnd == numStart) {
        return defaultValue;
    }
    
    try {
        return std::stoi(body.substr(numStart, numEnd - numStart));
    } catch (...) {
        return defaultValue;
    }
}

bool TacticalBoardController::parseJsonBool(const std::string& body, const std::string& key, bool defaultValue) {
    std::string searchKey = "\"" + key + "\"";
    size_t keyPos = body.find(searchKey);
    if (keyPos == std::string::npos) {
        return defaultValue;
    }
    
    size_t colonPos = body.find(':', keyPos);
    if (colonPos == std::string::npos) {
        return defaultValue;
    }
    
    // Check for "true" or "false" after the colon
    size_t truePos = body.find("true", colonPos);
    size_t falsePos = body.find("false", colonPos);
    
    if (truePos != std::string::npos && (falsePos == std::string::npos || truePos < falsePos)) {
        // Make sure "true" is within reasonable distance
        if (truePos - colonPos < 10) {
            return true;
        }
    }
    
    if (falsePos != std::string::npos && (truePos == std::string::npos || falsePos < truePos)) {
        // Make sure "false" is within reasonable distance
        if (falsePos - colonPos < 10) {
            return false;
        }
    }
    
    return defaultValue;
}
