#include "AuthController.h"
#include <sstream>
#include <regex>

AuthController::AuthController() {
    user_model_ = std::make_unique<User>();
}

void AuthController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix + "/login", [this](const Request& request) {
        return this->handleLogin(request);
    });
    
    router.post(prefix + "/register", [this](const Request& request) {
        return this->handleRegister(request);
    });
    
    router.post(prefix + "/logout", [this](const Request& request) {
        return this->handleLogout(request);
    });
    
    router.get(prefix + "/me", [this](const Request& request) {
        return this->handleCurrentUser(request);
    });
    
    router.get(prefix + "/me/roles", [this](const Request& request) {
        return this->handleUserRoles(request);
    });
    
    router.get(prefix + "/user/teams", [this](const Request& request) {
        return this->handleUserTeams(request);
    });
}

Response AuthController::handleLogin(const Request& request) {
    // Validate request
    Response error_response;
    if (!validateJsonRequest(request, error_response)) {
        return error_response;
    }
    
    // Extract credentials
    std::string email = extractField(request.getBody(), "email");
    std::string password = extractField(request.getBody(), "password");
    
    if (email.empty() || password.empty()) {
        std::string json = createJSONResponse(false, "Email and password are required");
        return Response(HttpStatus::BAD_REQUEST, json);
    }
    
    // Authenticate user
    UserData userData = user_model_->authenticate(email, password);
    
    if (userData.valid) {
        // Log successful login
        logLoginAttempt(userData.id, true, request);
        
        std::string json = createJSONResponse(true, "Login successful", userData);
        return Response(HttpStatus::OK, json);
    } else {
        // For failed logins, we don't have a user_id, so skip logging or log with empty id
        // In production, you might want to log failed attempts with the email instead
        
        std::string json = createJSONResponse(false, "Invalid email or password");
        return Response(HttpStatus::UNAUTHORIZED, json);
    }
}

Response AuthController::handleRegister(const Request& request) {
    // For now, return not implemented
    std::string json = createJSONResponse(false, "Registration not yet implemented");
    return Response(HttpStatus::NOT_FOUND, json);
}

Response AuthController::handleLogout(const Request& request) {
    // For JWT-based auth, logout is typically handled client-side
    std::string json = createJSONResponse(true, "Logged out successfully");
    return Response(HttpStatus::OK, json);
}

Response AuthController::handleCurrentUser(const Request& request) {
    try {
        // Extract Authorization header directly
        std::string auth_header = request.getHeader("Authorization");
        
        if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
            std::string json = createJSONResponse(false, "Invalid or missing authentication token");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Extract token (remove "Bearer " prefix)
        std::string token = auth_header.substr(7);
        
        // Extract user ID from JWT format: jwt_{user_id}_{hash}
        std::string user_id;
        if (!token.empty() && token.substr(0, 4) == "jwt_") {
            size_t last_underscore = token.rfind('_');
            if (last_underscore != std::string::npos && last_underscore > 4) {
                user_id = token.substr(4, last_underscore - 4);
            }
        }
        
        if (user_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid authentication token format");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Get user data from database
        UserData userData = user_model_->getUserById(user_id);
        
        if (!userData.valid) {
            std::string json = createJSONResponse(false, "User not found");
            return Response(HttpStatus::NOT_FOUND, json);
        }
        
        std::string json = createJSONResponse(true, "Current user retrieved successfully", userData);
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::string json = createJSONResponse(false, "Error retrieving current user");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response AuthController::handleUserRoles(const Request& request) {
    try {
        // Extract Authorization header directly
        std::string auth_header = request.getHeader("Authorization");
        
        if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
            std::string json = createJSONResponse(false, "Invalid or missing authentication token");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Extract token and user ID
        std::string token = auth_header.substr(7);
        std::string user_id;
        if (!token.empty() && token.substr(0, 4) == "jwt_") {
            size_t last_underscore = token.rfind('_');
            if (last_underscore != std::string::npos && last_underscore > 4) {
                user_id = token.substr(4, last_underscore - 4);
            }
        }
        
        if (user_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid authentication token format");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Get user roles and teams from database
        std::string roles_json = user_model_->getUserRoles(user_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"User roles retrieved successfully\",";
        json << "\"data\":" << roles_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
    } catch (const std::exception& e) {
        std::string json = createJSONResponse(false, "Failed to retrieve user roles");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string AuthController::createJSONResponse(bool success, const std::string& message, const UserData& userData) {
    std::ostringstream json;
    json << "{";
    json << "\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << message << "\"";
    
    if (success && userData.valid) {
        // Standardize: always use "data" wrapper for consistency
        json << ",\"data\":{";
        json << "\"user\":{";
        json << "\"id\":\"" << userData.id << "\",";
        json << "\"email\":\"" << userData.email << "\",";
        json << "\"first_name\":\"" << userData.first_name << "\",";
        json << "\"last_name\":\"" << userData.last_name << "\",";
        json << "\"name\":\"" << userData.name << "\","; // Computed full name
        if (!userData.preferred_name.empty()) {
            json << "\"preferred_name\":\"" << userData.preferred_name << "\",";
        }
        json << "\"role\":\"" << userData.role << "\"";
        json << "},";
        json << "\"token\":\"" << generateJWT(userData) << "\"";
        json << "}";
    }
    
    json << "}";
    return json.str();
}

std::string AuthController::generateJWT(const UserData& userData) {
    // Simple JWT-like token for now (in production, use proper JWT library)
    std::hash<std::string> hasher;
    return "jwt_" + userData.id + "_" + std::to_string(hasher(userData.email));
}

std::string AuthController::extractField(const std::string& json, const std::string& field) {
    // Simple JSON field extraction using regex
    std::string pattern = "\"" + field + "\"\\s*:\\s*\"([^\"]+)\"";
    std::regex field_regex(pattern);
    std::smatch match;
    
    if (std::regex_search(json, match, field_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string AuthController::extractUserIdFromToken(const Request& request) {
    // Extract Authorization header
    std::string auth_header = request.getHeader("Authorization");
    std::cout << "🔍 Auth header: '" << auth_header << "'" << std::endl;
    
    if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
        std::cout << "❌ No Bearer token found" << std::endl;
        return "";
    }
    
    // Extract token (remove "Bearer " prefix)
    std::string token = auth_header.substr(7);
    std::cout << "🔍 Token: '" << token << "'" << std::endl;
    
    if (!token.empty() && token.substr(0, 4) == "jwt_") {
        // Extract user ID from our JWT format: jwt_{user_id}_{hash}
        // Find the last underscore (since UUID contains hyphens, not underscores)
        size_t last_underscore = token.rfind('_');
        std::cout << "🔍 Last underscore at position: " << last_underscore << std::endl;
        if (last_underscore != std::string::npos && last_underscore > 4) {
            std::string user_id = token.substr(4, last_underscore - 4);
            std::cout << "🔍 Extracted user ID: '" << user_id << "'" << std::endl;
            return user_id;
        }
    }
    
    std::cout << "❌ Token parsing failed" << std::endl;
    return "";
}

void AuthController::logLoginAttempt(const std::string& user_id, bool success, const Request& request) {
    try {
        // Extract IP address and user agent from request headers
        std::string ip_address = request.getHeader("X-Forwarded-For");
        if (ip_address.empty()) {
            ip_address = request.getHeader("X-Real-IP");
        }
        if (ip_address.empty()) {
            ip_address = "unknown";
        }
        
        std::string user_agent = request.getHeader("User-Agent");
        if (user_agent.empty()) {
            user_agent = "unknown";
        }
        
        // Insert into login_history table
        std::string query = "INSERT INTO login_history (user_id, ip_address, user_agent, success) "
                          "VALUES ($1, $2, $3, $4)";
        
        auto db = Database::getInstance();
        db->query(query, {user_id, ip_address, user_agent, success ? "true" : "false"});
        
        std::cout << "✅ Logged login attempt for user: " << user_id << " (success: " << success << ")" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "❌ Failed to log login attempt: " << e.what() << std::endl;
        // Don't throw - logging failure shouldn't break login
    }
}

Response AuthController::handleUserTeams(const Request& request) {
    try {
        std::cout << "🔍 Getting teams for user" << std::endl;
        
        // Extract user ID from token
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid or missing authentication token");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        std::cout << "🔍 User ID from token: " << user_id << std::endl;
        
        auto db = Database::getInstance();
        
        // Query to get all teams for this user (both as player and coach)
        // Note: players.id and coaches.id ARE the user_id (FK to users table)
        std::ostringstream query;
        query << "SELECT DISTINCT t.id, t.name, "
              << "CASE WHEN tp.player_id IS NOT NULL THEN 'player' "
              << "     WHEN tc.coach_id IS NOT NULL THEN 'coach' "
              << "     ELSE 'unknown' END as role "
              << "FROM teams t "
              << "LEFT JOIN team_players tp ON t.id = tp.team_id AND tp.is_active = true "
              << "LEFT JOIN players p ON tp.player_id = p.id "
              << "LEFT JOIN team_coaches tc ON t.id = tc.team_id AND tc.is_active = true "
              << "LEFT JOIN coaches c ON tc.coach_id = c.id "
              << "WHERE (p.id = '" << user_id << "' OR c.id = '" << user_id << "')";
        
        std::cout << "🔍 Query: " << query.str() << std::endl;
        
        pqxx::result result = db->query(query.str());
        
        std::cout << "🔍 Found " << result.size() << " teams" << std::endl;
        
        // Build JSON array of teams
        std::ostringstream teams_json;
        teams_json << "[";
        
        for (size_t i = 0; i < result.size(); i++) {
            if (i > 0) teams_json << ",";
            teams_json << "{";
            teams_json << "\"id\":\"" << result[i][0].c_str() << "\",";
            teams_json << "\"name\":\"" << result[i][1].c_str() << "\",";
            teams_json << "\"role\":\"" << result[i][2].c_str() << "\"";
            teams_json << "}";
        }
        
        teams_json << "]";
        
        std::string json = createJSONResponse(true, "Teams retrieved successfully", teams_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ AuthController::handleUserTeams error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve teams");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string AuthController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{";
    json << "\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << message << "\"";
    if (!data.empty()) {
        json << ",\"data\":" << data;
    }
    json << "}";
    return json.str();
}