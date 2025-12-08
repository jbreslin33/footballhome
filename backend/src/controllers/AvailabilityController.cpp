#include "AvailabilityController.h"
#include <iostream>
#include <sstream>
#include <regex>

AvailabilityController::AvailabilityController() {
    db_ = Database::getInstance();
}

void AvailabilityController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering availability routes with prefix: " << prefix << std::endl;
    
    // Medical status routes
    router.get(prefix + "/players/:playerId/medical-status", [this](const Request& request) {
        return this->getMedicalStatus(request);
    });
    
    router.post(prefix + "/players/:playerId/medical-status", [this](const Request& request) {
        return this->createMedicalStatus(request);
    });
    
    router.post(prefix + "/medical-status/:statusId/resolve", [this](const Request& request) {
        return this->resolveMedicalStatus(request);
    });
    
    // Academic status routes
    router.get(prefix + "/players/:playerId/academic-status", [this](const Request& request) {
        return this->getAcademicStatus(request);
    });
    
    router.post(prefix + "/players/:playerId/academic-status", [this](const Request& request) {
        return this->createAcademicStatus(request);
    });
    
    router.post(prefix + "/academic-status/:statusId/resolve", [this](const Request& request) {
        return this->resolveAcademicStatus(request);
    });
    
    // Combined availability
    router.get(prefix + "/players/:playerId/availability", [this](const Request& request) {
        return this->getPlayerAvailability(request);
    });
}

// Helper to extract UUID from path
std::string AvailabilityController::extractIdFromPath(const std::string& path, const std::string& paramName) {
    std::regex pattern("/" + paramName + "/([a-f0-9-]{36})");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

// Get all medical statuses for a player
Response AvailabilityController::getMedicalStatus(const Request& req) {
    try {
        std::string playerId = extractIdFromPath(req.getPath(), "players");
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid player ID\"}");
        }
        
        std::string query = R"(
            SELECT 
                m.id,
                m.player_id,
                m.status,
                m.injury_type,
                m.severity,
                m.available_for_practices,
                m.available_for_games,
                m.injury_date,
                m.expected_return_date,
                m.notes,
                m.created_at
            FROM player_medical_status m
            WHERE m.player_id = $1 AND m.resolved_at IS NULL
            ORDER BY m.created_at DESC
        )";
        
        pqxx::result result = db_->query(query, {playerId});
        
        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"id\":\"" << row["id"].c_str() << "\",";
            json << "\"player_id\":\"" << row["player_id"].c_str() << "\",";
            json << "\"status\":\"" << row["status"].c_str() << "\",";
            json << "\"injury_type\":" << (row["injury_type"].is_null() ? "null" : "\"" + std::string(row["injury_type"].c_str()) + "\"") << ",";
            json << "\"severity\":" << (row["severity"].is_null() ? "null" : "\"" + std::string(row["severity"].c_str()) + "\"") << ",";
            json << "\"available_for_practices\":" << (row["available_for_practices"].as<bool>() ? "true" : "false") << ",";
            json << "\"available_for_games\":" << (row["available_for_games"].as<bool>() ? "true" : "false") << ",";
            json << "\"injury_date\":" << (row["injury_date"].is_null() ? "null" : "\"" + std::string(row["injury_date"].c_str()) + "\"") << ",";
            json << "\"expected_return_date\":" << (row["expected_return_date"].is_null() ? "null" : "\"" + std::string(row["expected_return_date"].c_str()) + "\"") << ",";
            json << "\"notes\":" << (row["notes"].is_null() ? "null" : "\"" + std::string(row["notes"].c_str()) + "\"") << ",";
            json << "\"created_at\":\"" << row["created_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "Error in getMedicalStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Create new medical status
Response AvailabilityController::createMedicalStatus(const Request& req) {
    try {
        std::string playerId = extractIdFromPath(req.getPath(), "players");
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid player ID\"}");
        }
        
        // Parse JSON body (simplified - in production use proper JSON parser)
        // For now, create a simple example
        
        // Get user_id for created_by
        pqxx::result userResult = db_->query("SELECT id FROM users LIMIT 1", {});
        if (userResult.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"No user found\"}");
        }
        std::string userId = userResult[0]["id"].c_str();
        
        std::string query = R"(
            INSERT INTO player_medical_status (
                player_id, status, injury_type, severity,
                available_for_practices, available_for_games,
                injury_date, expected_return_date,
                affects_all_teams, notes, created_by
            ) VALUES (
                $1, 'injured', 'ankle_sprain', 'minor',
                true, false,
                CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days',
                true, 'Created via API', $2
            )
            RETURNING id
        )";
        
        pqxx::result result = db_->query(query, {playerId, userId});
        
        std::string newId = result[0]["id"].c_str();
        return Response(HttpStatus::OK, "{\"id\":\"" + newId + "\",\"message\":\"Medical status created\"}");
        
    } catch (const std::exception& e) {
        std::cerr << "Error in createMedicalStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Resolve medical status
Response AvailabilityController::resolveMedicalStatus(const Request& req) {
    try {
        std::string statusId = extractIdFromPath(req.getPath(), "medical-status");
        if (statusId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid status ID\"}");
        }
        
        pqxx::result userResult = db_->query("SELECT id FROM users LIMIT 1", {});
        std::string userId = userResult[0]["id"].c_str();
        
        std::string query = R"(
            UPDATE player_medical_status 
            SET resolved_at = CURRENT_TIMESTAMP,
                resolved_by = $2
            WHERE id = $1
        )";
        
        db_->query(query, {statusId, userId});
        
        return Response(HttpStatus::OK, "{\"message\":\"Medical status resolved\"}");
        
    } catch (const std::exception& e) {
        std::cerr << "Error in resolveMedicalStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Get academic status
Response AvailabilityController::getAcademicStatus(const Request& req) {
    try {
        std::string playerId = extractIdFromPath(req.getPath(), "players");
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid player ID\"}");
        }
        
        std::string query = R"(
            SELECT 
                a.id,
                a.player_id,
                a.status,
                a.gpa,
                a.required_gpa,
                a.available_for_practices,
                a.available_for_games,
                a.status_start_date,
                a.review_date,
                a.academic_term,
                a.notes,
                a.created_at
            FROM player_academic_status a
            WHERE a.player_id = $1 AND a.resolved_at IS NULL
            ORDER BY a.created_at DESC
        )";
        
        pqxx::result result = db_->query(query, {playerId});
        
        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"id\":\"" << row["id"].c_str() << "\",";
            json << "\"player_id\":\"" << row["player_id"].c_str() << "\",";
            json << "\"status\":\"" << row["status"].c_str() << "\",";
            json << "\"gpa\":" << (row["gpa"].is_null() ? "null" : row["gpa"].c_str()) << ",";
            json << "\"required_gpa\":" << (row["required_gpa"].is_null() ? "null" : row["required_gpa"].c_str()) << ",";
            json << "\"available_for_practices\":" << (row["available_for_practices"].as<bool>() ? "true" : "false") << ",";
            json << "\"available_for_games\":" << (row["available_for_games"].as<bool>() ? "true" : "false") << ",";
            json << "\"status_start_date\":\"" << row["status_start_date"].c_str() << "\",";
            json << "\"review_date\":" << (row["review_date"].is_null() ? "null" : "\"" + std::string(row["review_date"].c_str()) + "\"") << ",";
            json << "\"academic_term\":" << (row["academic_term"].is_null() ? "null" : "\"" + std::string(row["academic_term"].c_str()) + "\"") << ",";
            json << "\"notes\":" << (row["notes"].is_null() ? "null" : "\"" + std::string(row["notes"].c_str()) + "\"") << ",";
            json << "\"created_at\":\"" << row["created_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "Error in getAcademicStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Create academic status
Response AvailabilityController::createAcademicStatus(const Request& req) {
    try {
        std::string playerId = extractIdFromPath(req.getPath(), "players");
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid player ID\"}");
        }
        
        pqxx::result userResult = db_->query("SELECT id FROM users LIMIT 1", {});
        std::string userId = userResult[0]["id"].c_str();
        
        std::string query = R"(
            INSERT INTO player_academic_status (
                player_id, status, gpa, required_gpa,
                available_for_practices, available_for_games,
                status_start_date, academic_term,
                affects_all_teams, notes, created_by
            ) VALUES (
                $1, 'probation', 2.3, 2.5,
                true, false,
                CURRENT_DATE, 'Fall 2025',
                true, 'Created via API', $2
            )
            RETURNING id
        )";
        
        pqxx::result result = db_->query(query, {playerId, userId});
        
        std::string newId = result[0]["id"].c_str();
        return Response(HttpStatus::OK, "{\"id\":\"" + newId + "\",\"message\":\"Academic status created\"}");
        
    } catch (const std::exception& e) {
        std::cerr << "Error in createAcademicStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Resolve academic status
Response AvailabilityController::resolveAcademicStatus(const Request& req) {
    try {
        std::string statusId = extractIdFromPath(req.getPath(), "academic-status");
        if (statusId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid status ID\"}");
        }
        
        pqxx::result userResult = db_->query("SELECT id FROM users LIMIT 1", {});
        std::string userId = userResult[0]["id"].c_str();
        
        std::string query = R"(
            UPDATE player_academic_status 
            SET resolved_at = CURRENT_TIMESTAMP,
                resolved_by = $2
            WHERE id = $1
        )";
        
        db_->query(query, {statusId, userId});
        
        return Response(HttpStatus::OK, "{\"message\":\"Academic status resolved\"}");
        
    } catch (const std::exception& e) {
        std::cerr << "Error in resolveAcademicStatus: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Get combined availability
Response AvailabilityController::getPlayerAvailability(const Request& req) {
    try {
        std::string playerId = extractIdFromPath(req.getPath(), "players");
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid player ID\"}");
        }
        
        std::string query = R"(
            SELECT 
                first_name,
                last_name,
                can_practice,
                can_play_games,
                medical_issues_count,
                academic_issues_count
            FROM v_player_availability
            WHERE player_id = $1
        )";
        
        pqxx::result result = db_->query(query, {playerId});
        
        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, "{\"error\":\"Player not found\"}");
        }
        
        auto row = result[0];
        std::ostringstream json;
        json << "{";
        json << "\"player_id\":\"" << playerId << "\",";
        json << "\"first_name\":\"" << row["first_name"].c_str() << "\",";
        json << "\"last_name\":\"" << row["last_name"].c_str() << "\",";
        json << "\"can_practice\":" << (row["can_practice"].as<bool>() ? "true" : "false") << ",";
        json << "\"can_play_games\":" << (row["can_play_games"].as<bool>() ? "true" : "false") << ",";
        json << "\"medical_issues_count\":" << row["medical_issues_count"].as<int>() << ",";
        json << "\"academic_issues_count\":" << row["academic_issues_count"].as<int>();
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "Error in getPlayerAvailability: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}
