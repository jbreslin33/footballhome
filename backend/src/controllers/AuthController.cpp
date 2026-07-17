#include "AuthController.h"
#include "../core/Crypto.h"
#include "../core/Mail.h"
#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <deque>
#include <iostream>
#include <mutex>
#include <sstream>
#include <regex>
#include <cstdio>
#include <ctime>
#include <unordered_map>
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

    // Password reset flow — both public.  Rate-limiting/enumeration
    // protection is inside the handlers.
    router.post(prefix + "/forgot-password", [this](const Request& request) {
        return this->handleForgotPassword(request);
    });
    router.post(prefix + "/reset-password", [this](const Request& request) {
        return this->handleResetPassword(request);
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

// Helper function to encode base64url (static to avoid multiple definition)

// Helper function to decode base64url (static to avoid multiple definition)

// Helper function to extract userId from JWT token (static to avoid multiple definition)
static std::string extractUserIdFromJWT(const std::string& token) {
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
    std::string payload = fh::crypto::base64UrlDecode(payload_encoded);
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
    // HS256-signed JWT.  Payload shape MUST stay byte-compatible with
    // OAuthController::generateJWT: {"userId","email","role","iat","exp"}
    // in that exact order.  If you change one, change the other, or
    // Controller::requireBearer will start rejecting tokens minted by
    // whichever generator drifted.
    const std::time_t now = std::time(nullptr);
    const std::time_t exp = now + (90LL * 24 * 60 * 60);  // 90 days

    std::ostringstream payload;
    payload << "{";
    payload << "\"userId\":\"" << userData.id << "\",";
    payload << "\"email\":\""  << userData.email << "\",";
    payload << "\"role\":\""   << userData.role  << "\",";
    payload << "\"iat\":" << now << ",";
    payload << "\"exp\":" << exp;
    payload << "}";

    return fh::crypto::signJwtHS256(payload.str());
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
    
    if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
        return "";
    }
    
    // Extract token (remove "Bearer " prefix)
    std::string token = auth_header.substr(7);
    
    // Use the JWT decoder to extract user ID
    return extractUserIdFromJWT(token);
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
        // Look up person_id from users table, then find teams via coaches/players
        std::ostringstream query;
        query << "SELECT DISTINCT t.id, t.name, "
              << "CASE WHEN tp.player_id IS NOT NULL THEN 'player' "
              << "     WHEN tc.coach_id IS NOT NULL THEN 'coach' "
              << "     ELSE 'unknown' END as role "
              << "FROM teams t "
              << "LEFT JOIN team_division_players tp ON t.id = tp.team_id "
              << "LEFT JOIN players p ON tp.player_id = p.id "
              << "LEFT JOIN team_coaches tc ON t.id = tc.team_id AND tc.ended_at IS NULL "
              << "LEFT JOIN coaches c ON tc.coach_id = c.id "
              << "WHERE p.person_id = (SELECT person_id FROM users WHERE id = " << user_id << ") "
              << "   OR c.person_id = (SELECT person_id FROM users WHERE id = " << user_id << ")";
        
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

        // Pull the team's chat (if any) alongside the team so the UI can
        // label teams by their chat name when one exists.
        std::string sql = "SELECT DISTINCT t.id, t.name, t.club_id, "
                          "       ch.id AS chat_id, ch.name AS chat_name, "
                          "       COUNT(tp.player_id) AS player_count "
                          "FROM coaches co "
                          "JOIN team_coaches tc ON co.id = tc.coach_id "
                          "JOIN teams t ON tc.team_id = t.id "
                          "LEFT JOIN chats ch ON ch.team_id = t.id "
                          "LEFT JOIN team_division_players tp ON t.id = tp.team_id AND tp.is_active = true "
                          "WHERE co.person_id = (SELECT person_id FROM users WHERE id = $1) "
                          "GROUP BY t.id, t.name, t.club_id, ch.id, ch.name "
                          "ORDER BY ch.name NULLS LAST, t.name";

        pqxx::result result;
        try {
            result = db_->query(sql, {user_id});
        } catch (const std::exception& e) {
            std::string error = e.what();
            if (error.find("team_division_players") == std::string::npos) {
                throw;
            }

            std::cerr << "⚠️ team_division_players missing, falling back to team_players in handleCoachTeams" << std::endl;
            const std::string fallback_sql = "SELECT DISTINCT t.id, t.name, NULL::integer AS club_id, "
                                             "       ch.id AS chat_id, ch.name AS chat_name, "
                                             "       COUNT(tp.player_id) AS player_count "
                                             "FROM coaches co "
                                             "JOIN team_coaches tc ON co.id = tc.coach_id "
                                             "JOIN teams t ON tc.team_id = t.id "
                                             "LEFT JOIN chats ch ON ch.team_id = t.id "
                                             "LEFT JOIN team_players tp ON t.id = tp.team_id AND tp.is_active = true "
                                             "WHERE co.person_id = (SELECT person_id FROM users WHERE id = $1) "
                                             "GROUP BY t.id, t.name, ch.id, ch.name "
                                             "ORDER BY ch.name NULLS LAST, t.name";
            result = db_->query(fallback_sql, {user_id});
        }

        // Helper: escape a string for embedding in a JSON string literal.
        auto jsonEscape = [](const std::string& s) {
            std::string out;
            out.reserve(s.size() + 2);
            for (char c : s) {
                switch (c) {
                    case '"':  out += "\\\""; break;
                    case '\\': out += "\\\\"; break;
                    case '\b': out += "\\b";  break;
                    case '\f': out += "\\f";  break;
                    case '\n': out += "\\n";  break;
                    case '\r': out += "\\r";  break;
                    case '\t': out += "\\t";  break;
                    default:
                        if (static_cast<unsigned char>(c) < 0x20) {
                            char buf[8];
                            std::snprintf(buf, sizeof(buf), "\\u%04x", c);
                            out += buf;
                        } else {
                            out += c;
                        }
                }
            }
            return out;
        };

        std::ostringstream teams_json;
        teams_json << "[";
        bool first = true;
        for (auto row : result) {
            if (!first) teams_json << ",";
            first = false;
            const std::string teamName = row["name"].as<std::string>();
            const std::string rawChatName = row["chat_name"].is_null() ? "" : row["chat_name"].as<std::string>();
            const std::string displayName = rawChatName.empty() ? teamName : rawChatName;
            teams_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                      << "\"display_name\":\"" << jsonEscape(displayName) << "\","
                      << "\"name\":\"" << jsonEscape(teamName) << "\","
                      << "\"chat_id\":" << (row["chat_id"].is_null() ? "null" : std::to_string(row["chat_id"].as<int>())) << ","
                      << "\"chat_name\":" << (rawChatName.empty() ? "null" : ("\"" + jsonEscape(rawChatName) + "\"")) << ","
                      << "\"club_id\":" << (row["club_id"].is_null() ? "null" : std::to_string(row["club_id"].as<int>())) << ","
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

        // Two roster tables are read here:
        //   (a) `team_division_players` — the canonical youth/adult
        //       squad view (id, team_id, player_id, is_active, …).
        //       Legacy queries used `team_players`; that table was
        //       removed in migration 08x — the view is its shape-
        //       preserving replacement.
        //   (b) `mens_team_assignments` — the mens-side roster for
        //       APSL / pool teams (Practice=908, Pickup=909).  It is
        //       keyed on `leagueapps_user_id`; we bridge to a
        //       persons row via `external_person_aliases` (same
        //       pattern used across the roster/RSVP surfaces).
        //
        // Both branches emit `{id, name, club_id, division_name?}`
        // rows and are UNION-ed so a single caller with entries in
        // either side gets every team they can RSVP for.  Wrapping
        // `SELECT DISTINCT ON (id)` collapses cases where the caller
        // is in both roster tables (typical for pool teams that also
        // have a team_division_players view row).
        const std::string sql =
            "WITH caller AS ( "
            "  SELECT person_id FROM users WHERE id = $1::int "
            "), roster AS ( "
            "  SELECT t.id::text AS id, t.name, "
            "         t.club_id::text AS club_id, "
            "         d.name AS division_name, "
            "         1 AS priority "
            "    FROM caller "
            "    JOIN players p ON p.person_id = caller.person_id "
            "    JOIN team_division_players tdp ON tdp.player_id = p.id "
            "                                  AND tdp.is_active = true "
            "    JOIN teams t ON t.id = tdp.team_id "
            "    LEFT JOIN divisions d ON d.id = t.division_id "
            "  UNION ALL "
            "  SELECT t.id::text AS id, t.name, "
            "         t.club_id::text AS club_id, "
            "         NULL::varchar AS division_name, "
            "         2 AS priority "
            "    FROM caller "
            "    JOIN external_person_aliases epa "
            "      ON epa.person_id = caller.person_id "
            "     AND epa.provider = 'leagueapps' "
            "    JOIN roster_assignments mta "
            "      ON mta.leagueapps_user_id::text = epa.external_user_id "
            "     AND mta.domain = 'mens' "
            "     AND mta.removed_at IS NULL "
            "    JOIN teams t ON t.id = mta.team_id "
            ") "
            "SELECT DISTINCT ON (id) id, name, club_id, division_name "
            "  FROM roster "
            " ORDER BY id, priority, division_name NULLS LAST";

        pqxx::result result = db_->query(sql, {user_id});

        std::ostringstream teams_json;
        teams_json << "[";
        bool first = true;
        for (auto row : result) {
            if (!first) teams_json << ",";
            first = false;
            const std::string clubIdStr =
                row["club_id"].is_null() ? "null"
                                         : "\"" + row["club_id"].as<std::string>() + "\"";
            const std::string divName =
                row["division_name"].is_null() ? "null"
                                               : "\"" + escapeJson(row["division_name"].as<std::string>()) + "\"";
            teams_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                       << "\"display_name\":\"" << escapeJson(row["name"].as<std::string>()) << "\","
                       << "\"name\":\"" << escapeJson(row["name"].as<std::string>()) << "\","
                       << "\"club_id\":" << clubIdStr << ","
                       << "\"division_name\":" << divName << "}";
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
        
        // Check if user is a super admin (sees everything) - join with admin_levels lookup table
        std::string super_admin_sql = "SELECT a.user_id, al.name as admin_level "
                                      "FROM admins a "
                                      "JOIN admin_levels al ON a.admin_level_id = al.id "
                                      "WHERE a.user_id = $1 AND al.name = 'super'";
        pqxx::result super_result = db_->query(super_admin_sql, {user_id});
        bool is_super_admin = !super_result.empty();
        
        if (is_super_admin) {
            // Add super admin context
            contexts_json << "{\"id\":\"super\","
                         << "\"display_name\":\"Super Admin\","
                         << "\"type\":\"super\"}";
            first = false;
        }
        
        // Get organizations the user administers (via admins -> organization_admins)
        std::string org_sql = "SELECT DISTINCT o.id, o.name as display_name, 'organization' as type "
                              "FROM organizations o "
                              "JOIN organization_admins oa ON o.id = oa.organization_id "
                              "JOIN admins a ON oa.admin_id = a.id "
                              "WHERE a.user_id = $1 AND oa.ended_at IS NULL "
                              "GROUP BY o.id, o.name";
        
        pqxx::result org_result = db_->query(org_sql, {user_id});
        for (auto row : org_result) {
            if (!first) contexts_json << ",";
            first = false;
            contexts_json << "{\"id\":\"" << row["id"].as<std::string>() << "\","
                         << "\"display_name\":\"" << row["display_name"].as<std::string>() << "\","
                         << "\"type\":\"club\"}";
        }
        
        // TODO: Sport divisions and teams - these tables need to be populated first
        // For now, super admins can access the system-level admin screen
        
        contexts_json << "]";
        
        std::string json = createJSONResponse(true, "Admin contexts retrieved successfully", contexts_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ AuthController::handleAdminContexts error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve admin contexts");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

// ═════════════════════════════════════════════════════════════════════
// Password reset flow
// ─────────────────────────────────────────────────────────────────────
// POST /api/auth/forgot-password   { "email": "..." }
//   Always returns 200 { ok: true } to prevent account enumeration.
//   If the email matches an active user we insert a row in
//   password_reset_tokens with a hashed token and email a link.
//
// POST /api/auth/reset-password    { "token": "...", "password": "..." }
//   Verifies the token (hash lookup, unused, unexpired), then updates
//   users.password_hash via pgcrypto's crypt(gen_salt('bf')) — matches
//   the bcrypt format that authenticate() already verifies.
// ═════════════════════════════════════════════════════════════════════

namespace {

// In-process per-IP rate-limit for /api/auth/forgot-password.
//
// Cap: at most FORGOT_IP_LIMIT requests per FORGOT_IP_WINDOW_SECS from
// a single source IP.  Keeps a bounded FIFO of request timestamps per
// IP; old entries fall off as new ones arrive.
//
// Deliberately in-process (no Redis) because:
//   - We only run one backend replica.  Restart-on-deploy clears the
//     table, which is fine — abuse detection is best-effort here.
//   - Real safety comes from the DB-side per-user cap below plus the
//     no-enumeration uniform response.
constexpr std::size_t FORGOT_IP_LIMIT        = 10;
constexpr int         FORGOT_IP_WINDOW_SECS  = 60 * 60;   // 1 hour
constexpr int         FORGOT_USER_LIMIT      =  3;
constexpr int         FORGOT_USER_WINDOW_MIN = 60;

std::mutex                                              g_forgotIpMx;
std::unordered_map<std::string, std::deque<long long>>  g_forgotIpHits;

// Records a hit for `ip` and returns true if the caller should be
// throttled (i.e. limit exceeded within the rolling window).  An empty
// IP short-circuits to false so we don't lump everyone together.
bool forgotIpThrottled(const std::string& ip) {
    if (ip.empty()) return false;

    const long long now = static_cast<long long>(
        std::chrono::duration_cast<std::chrono::seconds>(
            std::chrono::steady_clock::now().time_since_epoch()).count());
    const long long cutoff = now - FORGOT_IP_WINDOW_SECS;

    std::lock_guard<std::mutex> lk(g_forgotIpMx);
    auto& q = g_forgotIpHits[ip];
    while (!q.empty() && q.front() < cutoff) q.pop_front();
    if (q.size() >= FORGOT_IP_LIMIT) return true;
    q.push_back(now);

    // Occasional janitorial sweep so g_forgotIpHits doesn't grow
    // forever from one-off IPs.  Cheap: iterate at most once per ~256
    // requests thanks to size gate.
    if (g_forgotIpHits.size() > 4096) {
        for (auto it = g_forgotIpHits.begin(); it != g_forgotIpHits.end(); ) {
            while (!it->second.empty() && it->second.front() < cutoff) it->second.pop_front();
            if (it->second.empty()) it = g_forgotIpHits.erase(it);
            else ++it;
        }
    }
    return false;
}

} // namespace

Response AuthController::handleForgotPassword(const Request& request) {
    // Extract client IP first — we need it for both rate-limit and the
    // audit row later.
    std::string ip = request.getHeader("X-Forwarded-For");
    if (ip.empty()) ip = request.getHeader("X-Real-IP");
    // X-Forwarded-For can be "client, proxy1, proxy2"; take the first.
    {
        auto comma = ip.find(',');
        if (comma != std::string::npos) ip = ip.substr(0, comma);
        while (!ip.empty() && std::isspace(static_cast<unsigned char>(ip.front()))) ip.erase(ip.begin());
        while (!ip.empty() && std::isspace(static_cast<unsigned char>(ip.back())))  ip.pop_back();
    }

    // Standard uniform response regardless of whether email exists.
    // Also used for any rate-limit early-return so throttling doesn't
    // leak information about specific emails.
    auto uniformOk = [] {
        std::ostringstream b;
        b << "{\"ok\":true,\"message\":\"If that address is registered, "
             "we've emailed a reset link. Check your inbox (and spam).\"}";
        Response r(HttpStatus::OK, b.str());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    };

    // Per-IP rate-limit (short-circuits before any DB work).
    if (forgotIpThrottled(ip)) {
        std::cerr << "[password-reset] IP rate-limit hit ip=" << ip << "\n";
        return uniformOk();
    }

    // Body: { "email": "..." }.  Bad JSON => still respond 200 with
    // ok:true so nobody can probe our request handling; log the noise.
    std::string email = extractField(request.getBody(), "email");

    // Cheap sanity — must look like an email.
    auto isEmailish = [](const std::string& s) {
        if (s.empty() || s.size() > 254) return false;
        auto at = s.find('@');
        return at != std::string::npos && at > 0 && at < s.size() - 3
            && s.find(' ') == std::string::npos;
    };

    if (!isEmailish(email)) {
        // Same 200 body — no enumeration.  Do log so we can spot abuse.
        std::cerr << "[password-reset] rejected malformed email in request\n";
        return uniformOk();
    }

    // Normalise for lookup: lower-case.  person_emails stores as-typed
    // so we compare with ILIKE / LOWER().
    std::string lookupEmail = email;
    std::transform(lookupEmail.begin(), lookupEmail.end(), lookupEmail.begin(),
                   [](unsigned char c){ return std::tolower(c); });

    try {
        // Resolve email -> user row.  Prefer primary email; accept any
        // person_emails match (a person can have multiple).
        auto res = db_->query(
            "SELECT u.id AS user_id, p.first_name, p.last_name, pe.email "
            "  FROM person_emails pe "
            "  JOIN persons p ON p.id = pe.person_id "
            "  JOIN users u ON u.person_id = p.id AND COALESCE(u.is_active, true) "
            " WHERE LOWER(pe.email) = $1 "
            " ORDER BY pe.is_primary DESC, u.id ASC "
            " LIMIT 1",
            {lookupEmail});

        if (res.empty()) {
            std::cerr << "[password-reset] no active user for " << lookupEmail << "\n";
            return uniformOk();
        }

        const std::string userId    = res[0]["user_id"].as<std::string>();
        const std::string firstName = res[0]["first_name"].is_null()
                                       ? std::string{}
                                       : res[0]["first_name"].as<std::string>();
        const std::string realEmail = res[0]["email"].as<std::string>();

        // Per-user rate-limit.  Bots that guess a valid email
        // shouldn't be able to generate unlimited token rows (and
        // reset-emails, once SMTP is on).  Counts recent inserts
        // regardless of used_at so an attacker can't grind through
        // fresh tokens by consuming their own.
        {
            auto rl = db_->query(
                "SELECT COUNT(*) AS c FROM password_reset_tokens "
                " WHERE user_id = $1::int "
                "   AND created_at > NOW() - ($2::text || ' minutes')::interval",
                {userId, std::to_string(FORGOT_USER_WINDOW_MIN)});
            const long recent = rl[0]["c"].as<long>();
            if (recent >= FORGOT_USER_LIMIT) {
                std::cerr << "[password-reset] per-user rate-limit hit "
                          << "user_id=" << userId
                          << " recent=" << recent
                          << " window_min=" << FORGOT_USER_WINDOW_MIN << "\n";
                return uniformOk();
            }
        }

        // Fresh single-use token, 60-minute TTL.
        const std::string raw  = fh::crypto::randomTokenB64Url(32);
        const std::string hash = fh::crypto::sha256Hex(raw);

        std::string ua = request.getHeader("User-Agent");

        try {
            db_->query(
                "INSERT INTO password_reset_tokens "
                "  (user_id, token_hash, expires_at, requested_ip, requested_ua) "
                "VALUES ($1::int, $2, NOW() + INTERVAL '60 minutes', "
                "        NULLIF($3, ''), NULLIF($4, ''))",
                {userId, hash, ip, ua});
        } catch (const std::exception& e) {
            std::cerr << "[password-reset] INSERT failed: " << e.what() << "\n";
            return uniformOk();  // never leak
        }

        // Build reset link.  PUBLIC_BASE_URL is the canonical origin (no
        // trailing slash).  Keep in sync with EventReminderController.
        std::string baseUrl;
        {
            const char* env = std::getenv("PUBLIC_BASE_URL");
            baseUrl = (env && *env) ? std::string(env) : std::string("https://footballhome.org");
            while (!baseUrl.empty() && baseUrl.back() == '/') baseUrl.pop_back();
        }
        const std::string resetUrl =
            baseUrl + "/reset-password?token=" + fh::crypto::urlEncode(raw);

        // Compose message.  Plaintext only — HTML MIME would need more
        // scaffolding and offers no functional win for a link this
        // short.
        std::ostringstream body;
        body << "Hi";
        if (!firstName.empty()) body << " " << firstName;
        body << ",\n\n"
             << "Someone (hopefully you) requested a password reset for your "
                "Football Home account.  Tap the link below to set a new "
                "password.  This link expires in 60 minutes and can only be "
                "used once.\n\n"
             << resetUrl << "\n\n"
             << "If you didn't request this, you can safely ignore the email "
                "— your existing password stays as-is.\n\n"
             << "— Football Home\n";

        const std::string subject = "Football Home — reset your password";

        // Fire-and-forget.  fh::mail::send() logs errors internally.
        // We still respond 200 either way; a delivery failure will show
        // up in the container logs.
        bool sent = fh::mail::send(realEmail, subject, body.str());

        // Extra observability line for the log — includes the raw URL
        // so operator can hand-deliver during outages / pre-SMTP builds.
        std::cerr << "[password-reset] user_id=" << userId
                  << " email=" << realEmail
                  << " sent=" << (sent ? "true" : "false")
                  << " url=" << resetUrl << "\n";

    } catch (const std::exception& e) {
        std::cerr << "[password-reset] unexpected error: " << e.what() << "\n";
        // Still respond 200 to preserve uniform semantics.
    }

    return uniformOk();
}

Response AuthController::handleResetPassword(const Request& request) {
    std::string token    = extractField(request.getBody(), "token");
    std::string password = extractField(request.getBody(), "password");

    auto errJson = [](HttpStatus s, const std::string& msg) {
        std::ostringstream b;
        b << "{\"error\":\"" << msg << "\"}";
        Response r(s, b.str());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    };

    if (token.empty()) {
        return errJson(HttpStatus::BAD_REQUEST, "token is required");
    }
    if (password.size() < 8) {
        return errJson(HttpStatus::BAD_REQUEST, "password must be at least 8 characters");
    }
    if (password.size() > 200) {
        return errJson(HttpStatus::BAD_REQUEST, "password too long");
    }

    const std::string hash = fh::crypto::sha256Hex(token);

    try {
        // Look up unused, unexpired token.  Row lives forever after the
        // reset; we mark used_at so it can't replay.
        auto res = db_->query(
            "SELECT prt.id, prt.user_id "
            "  FROM password_reset_tokens prt "
            "  JOIN users u ON u.id = prt.user_id AND COALESCE(u.is_active, true) "
            " WHERE prt.token_hash = $1 "
            "   AND prt.used_at IS NULL "
            "   AND prt.expires_at > NOW() "
            " LIMIT 1",
            {hash});

        if (res.empty()) {
            return errJson(HttpStatus::BAD_REQUEST,
                           "Reset link is invalid or expired. Request a new one.");
        }

        const std::string tokenId = res[0]["id"].as<std::string>();
        const std::string userId  = res[0]["user_id"].as<std::string>();

        // Update password + mark token used in the same round-trip so a
        // half-way failure can't leave the token consumed with the
        // password unchanged.  pgcrypto's crypt(gen_salt('bf')) produces
        // a bcrypt hash matching the format authenticate() verifies.
        db_->query(
            "WITH upd_user AS ( "
            "  UPDATE users SET password_hash = crypt($1, gen_salt('bf')) "
            "   WHERE id = $2::int "
            "  RETURNING id "
            "), upd_token AS ( "
            "  UPDATE password_reset_tokens SET used_at = NOW() "
            "   WHERE id = $3::int "
            "  RETURNING id "
            ") "
            "SELECT (SELECT id FROM upd_user) AS uid, "
            "       (SELECT id FROM upd_token) AS tid",
            {password, userId, tokenId});

        std::cerr << "[password-reset] user_id=" << userId
                  << " password reset succeeded (token_id=" << tokenId << ")\n";

        std::ostringstream ok;
        ok << "{\"ok\":true,\"message\":\"Password updated. You can now log in.\"}";
        Response r(HttpStatus::OK, ok.str());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;

    } catch (const std::exception& e) {
        std::cerr << "[password-reset] reset failed: " << e.what() << "\n";
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR,
                       "Something went wrong. Please try again.");
    }
}

