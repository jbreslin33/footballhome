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
        // Split name into firstName and lastName for frontend compatibility
        std::string firstName = userData.name;
        std::string lastName = "";
        
        size_t spacePos = userData.name.find(' ');
        if (spacePos != std::string::npos) {
            firstName = userData.name.substr(0, spacePos);
            lastName = userData.name.substr(spacePos + 1);
        }
        
        json << ",\"user\":{";
        json << "\"id\":\"" << userData.id << "\",";
        json << "\"email\":\"" << userData.email << "\",";
        json << "\"name\":\"" << userData.name << "\",";
        json << "\"firstName\":\"" << firstName << "\",";
        json << "\"lastName\":\"" << lastName << "\",";
        json << "\"role\":\"" << userData.role << "\"";
        json << "}";
        json << ",\"token\":\"" << generateJWT(userData) << "\"";
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
        db->executeQuery(query, {user_id, ip_address, user_agent, success ? "true" : "false"});
        
        std::cout << "✅ Logged login attempt for user: " << user_id << " (success: " << success << ")" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "❌ Failed to log login attempt: " << e.what() << std::endl;
        // Don't throw - logging failure shouldn't break login
    }
}