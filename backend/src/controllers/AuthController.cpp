#include "AuthController.h"
#include <sstream>
#include <regex>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

AuthController::AuthController() {
    user_model_ = std::make_unique<User>();
    db_ = Database::getInstance();
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
    
    router.get(prefix + "/coach/teams", [this](const Request& request) {
        return this->handleCoachTeams(request);
    });
    
    router.get(prefix + "/player/teams", [this](const Request& request) {
        return this->handlePlayerTeams(request);
    });
    
    router.get(prefix + "/admin/contexts", [this](const Request& request) {
        return this->handleAdminContexts(request);
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

// Helper function to decode base64url
std::string base64UrlDecode(const std::string& input) {
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

// Helper function to extract userId from JWT token
std::string extractUserIdFromJWT(const std::string& token) {
    // JWT format: header.payload.signature
    size_t first_dot = token.find('.');
    if (first_dot == std::string::npos) {
        std::cout << "❌ JWT: No first dot found" << std::endl;
        return "";
    }
    
    size_t second_dot = token.find('.', first_dot + 1);
    if (second_dot == std::string::npos) {
        std::cout << "❌ JWT: No second dot found" << std::endl;
        return "";
    }
    
    // Extract payload (between first and second dot)
    std::string payload_encoded = token.substr(first_dot + 1, second_dot - first_dot - 1);
    std::cout << "🔍 JWT payload_encoded: " << payload_encoded << std::endl;
    
    // Decode payload
    std::string payload = base64UrlDecode(payload_encoded);
    std::cout << "🔍 JWT payload decoded: " << payload << std::endl;
    
    // Extract userId from JSON payload
    // Format: {"userId":"xxx","email":"..."}
    size_t user_id_start = payload.find("\"userId\":\"");
    if (user_id_start == std::string::npos) {
        std::cout << "❌ JWT: userId field not found in payload" << std::endl;
        return "";
    }
    user_id_start += 10; // Length of "userId":\"
    
    size_t user_id_end = payload.find('"', user_id_start);
    if (user_id_end == std::string::npos) {
        std::cout << "❌ JWT: userId closing quote not found" << std::endl;
        return "";
    }
    
    std::string user_id = payload.substr(user_id_start, user_id_end - user_id_start);
    std::cout << "✅ JWT: Extracted userId=" << user_id << std::endl;
    return user_id;
}

Response AuthController::handleCurrentUser(const Request& request) {
    try {
        // Extract Authorization header directly
        std::string auth_header = request.getHeader("Authorization");
        
        std::cout << "🔐 handleCurrentUser: auth_header=" << (auth_header.empty() ? "EMPTY" : auth_header.substr(0, std::min((size_t)50, auth_header.length()))) << "..." << std::endl;
        
        if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
            std::string json = createJSONResponse(false, "Invalid or missing authentication token");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Extract token (remove "Bearer " prefix)
        std::string token = auth_header.substr(7);
        std::cout << "🔐 Token length: " << token.length() << ", first 50 chars: " << token.substr(0, std::min((size_t)50, token.length())) << "..." << std::endl;
        
        // Extract user ID from JWT token
        std::string user_id = extractUserIdFromJWT(token);
        std::cout << "🔐 Extracted user_id: " << (user_id.empty() ? "EMPTY" : user_id) << std::endl;
        
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
        std::string user_id = extractUserIdFromJWT(token);
        
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
        if (!userData.club_id.empty()) {
            json << ",\"club_id\":\"" << userData.club_id << "\",";
            json << "\"club_name\":\"" << userData.club_name << "\"";
        }
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

Response AuthController::handleCoachTeams(const Request& request) {
    try {
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Invalid or missing authentication token"));
        }
        
        std::string sql = "SELECT DISTINCT t.id, t.name, COUNT(tp.player_id) as player_count "
                         "FROM coaches co "
                         "JOIN team_coaches tc ON co.id = tc.coach_id "
                         "JOIN teams t ON tc.team_id = t.id "
                         "LEFT JOIN team_players tp ON t.id = tp.team_id "
                         "WHERE co.id = $1 "
                         "GROUP BY t.id, t.name "
                         "ORDER BY t.name";
        
        pqxx::result result = db_->query(sql, {user_id});
        
        std::ostringstream teams_json;
        teams_json << "[";
        bool first = true;
        for (auto row : result) {
            if (!first) teams_json << ",";
            first = false;
            teams_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                      << "\"display_name\":\"" << row["name"].as<std::string>() << "\","
                      << "\"name\":\"" << row["name"].as<std::string>() << "\","
                      << "\"player_count\":" << row["player_count"].as<int>() << "}";
        }
        teams_json << "]";
        
        std::string json = createJSONResponse(true, "Coach teams retrieved successfully", teams_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ AuthController::handleCoachTeams error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve coach teams");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response AuthController::handlePlayerTeams(const Request& request) {
    try {
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Invalid or missing authentication token"));
        }
        
        std::string sql = "SELECT DISTINCT t.id, t.name, sd.display_name as division_name "
                         "FROM team_players tp "
                         "JOIN teams t ON tp.team_id = t.id "
                         "JOIN sport_divisions sd ON t.sport_division_id = sd.id "
                         "JOIN players p ON tp.player_id = p.id "
                         "WHERE p.id = $1 "
                         "ORDER BY t.name";
        
        pqxx::result result = db_->query(sql, {user_id});
        
        std::ostringstream teams_json;
        teams_json << "[";
        bool first = true;
        for (auto row : result) {
            if (!first) teams_json << ",";
            first = false;
            teams_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                      << "\"display_name\":\"" << row["name"].as<std::string>() << "\","
                      << "\"name\":\"" << row["name"].as<std::string>() << "\","
                      << "\"division_name\":\"" << row["division_name"].as<std::string>() << "\"}";
        }
        teams_json << "]";
        
        std::string json = createJSONResponse(true, "Player teams retrieved successfully", teams_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ AuthController::handlePlayerTeams error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve player teams");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response AuthController::handleAdminContexts(const Request& request) {
    try {
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Invalid or missing authentication token"));
        }
        
        std::ostringstream contexts_json;
        contexts_json << "[";
        bool first = true;
        
        // Check if user is a system admin (sees everything)
        std::string system_admin_sql = "SELECT user_id FROM system_admins WHERE user_id = $1 AND is_active = true";
        pqxx::result system_result = db_->query(system_admin_sql, {user_id});
        bool is_system_admin = !system_result.empty();
        
        if (is_system_admin) {
            // Add system admin context
            contexts_json << "{\"id\":\"system\","
                         << "\"display_name\":\"System Administration\","
                         << "\"type\":\"system\"}";
            first = false;
        }
        
        // Get clubs the user administers
        std::string club_sql = "SELECT DISTINCT c.id, c.display_name, 'club' as type, COUNT(DISTINCT t.id) as team_count "
                              "FROM clubs c "
                              "JOIN club_admins ca ON c.id = ca.club_id "
                              "LEFT JOIN sport_divisions sd ON c.id = sd.club_id "
                              "LEFT JOIN teams t ON sd.id = t.sport_division_id "
                              "WHERE ca.user_id = $1 AND ca.is_active = true "
                              "GROUP BY c.id, c.display_name";
        
        pqxx::result club_result = db_->query(club_sql, {user_id});
        for (auto row : club_result) {
            if (!first) contexts_json << ",";
            first = false;
            contexts_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                         << "\"display_name\":\"" << row["display_name"].as<std::string>() << "\","
                         << "\"type\":\"club\","
                         << "\"team_count\":" << row["team_count"].as<int>() << "}";
        }
        
        // Get sport divisions the user administers
        std::string sport_div_sql = "SELECT DISTINCT sd.id, sd.display_name, 'sport_division' as type, c.display_name as club_name "
                                    "FROM sport_divisions sd "
                                    "JOIN clubs c ON sd.club_id = c.id "
                                    "JOIN sport_division_admins sda ON sd.id = sda.sport_division_id "
                                    "WHERE sda.user_id = $1 AND sda.is_active = true "
                                    "ORDER BY sd.display_name";
        
        pqxx::result sport_div_result = db_->query(sport_div_sql, {user_id});
        for (auto row : sport_div_result) {
            if (!first) contexts_json << ",";
            first = false;
            contexts_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                         << "\"display_name\":\"" << row["display_name"].as<std::string>() << " (" << row["club_name"].as<std::string>() << ")\","
                         << "\"type\":\"sport_division\"}";
        }
        
        // Get teams the user administers (team-level admins or coaches with management roles)
        std::string team_sql = "SELECT DISTINCT t.id, t.name, 'team' as type "
                              "FROM teams t "
                              "LEFT JOIN team_admins ta ON t.id = ta.team_id AND ta.user_id = $1 AND ta.is_active = true "
                              "LEFT JOIN team_coaches tc ON t.id = tc.team_id "
                              "LEFT JOIN coaches co ON tc.coach_id = co.id AND co.id = $1 "
                              "WHERE (ta.user_id IS NOT NULL OR (co.id IS NOT NULL AND tc.coach_role IN ('head_coach', 'team_manager'))) "
                              "ORDER BY t.name";
        
        pqxx::result team_result = db_->query(team_sql, {user_id});
        for (auto row : team_result) {
            if (!first) contexts_json << ",";
            first = false;
            contexts_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                         << "\"display_name\":\"" << row["name"].as<std::string>() << "\","
                         << "\"type\":\"team\"}";
        }
        
        contexts_json << "]";
        
        std::string json = createJSONResponse(true, "Admin contexts retrieved successfully", contexts_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ AuthController::handleAdminContexts error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve admin contexts");
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