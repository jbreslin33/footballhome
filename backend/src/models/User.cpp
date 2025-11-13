#include "User.h"
#include <iostream>

User::User() : Model("users", "id") {
}

bool User::save() {
    // For now, implement a basic save (would need proper validation in production)
    try {
        std::unordered_map<std::string, std::string> data;
        data["email"] = email_;
        data["name"] = name_;
        if (!password_hash_.empty()) {
            data["password_hash"] = password_hash_;
        }
        
        std::string sql = buildInsertQuery(data);
        std::vector<std::string> params;
        for (const auto& pair : data) {
            params.push_back(pair.second);
        }
        
        pqxx::result result = executeQuery(sql, params);
        if (!result.empty()) {
            id_ = result[0][0].as<std::string>();
            return true;
        }
        return false;
    } catch (const std::exception& e) {
        std::cerr << "❌ User save error: " << e.what() << std::endl;
        return false;
    }
}

bool User::load(int id) {
    auto data = findById("users", id, "id");
    if (data.empty()) {
        return false;
    }
    
    populateFromMap(data);
    return true;
}

bool User::remove() {
    if (id_.empty()) {
        return false;
    }
    
    try {
        std::string sql = "DELETE FROM users WHERE id = $1";
        executeQuery(sql, {id_});
        return true;
    } catch (const std::exception& e) {
        std::cerr << "❌ User remove error: " << e.what() << std::endl;
        return false;
    }
}

UserData User::authenticate(const std::string& email, const std::string& password) {
    UserData userData;
    userData.valid = false;
    
    std::cout << "🔍 authenticateUser called for: " << email << std::endl;
    
    try {
        // Query database for user by email with admin info
        std::string sql = "SELECT u.id, u.email, u.name, u.password_hash, a.admin_level "
                         "FROM users u "
                         "LEFT JOIN admins a ON u.id = a.id "
                         "WHERE u.email = $1 "
                         "LIMIT 1";
        
        pqxx::result result = executeQuery(sql, {email});
        std::cout << "🔍 Query returned " << result.size() << " rows" << std::endl;
        
        if (!result.empty()) {
            auto row = result[0];
            std::string stored_hash = row["password_hash"].as<std::string>();
            
            std::cout << "🔍 User found in DB: " << email << std::endl;
            
            if (verifyPassword(password, stored_hash)) {
                userData.valid = true;
                userData.id = row["id"].as<std::string>();
                userData.email = row["email"].as<std::string>();
                userData.name = row["name"].as<std::string>();
                // Check if user is an admin, otherwise default to "user"
                userData.role = row["admin_level"].is_null() ? "user" : row["admin_level"].as<std::string>();
                
                std::cout << "✅ Authentication successful for: " << email << std::endl;
            } else {
                std::cout << "❌ Password verification failed for: " << email << std::endl;
            }
        } else {
            std::cout << "🔍 No user found in DB for: " << email << std::endl;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Auth query failed: " << e.what() << std::endl;
    }
    
    return userData;
}

bool User::verifyPassword(const std::string& password, const std::string& stored_hash) {
    try {
        // Use PostgreSQL's crypt function to verify bcrypt hash
        std::string sql = "SELECT crypt($1, $2) = $2 AS password_match";
        pqxx::result result = executeQuery(sql, {password, stored_hash});
        
        bool password_match = !result.empty() && result[0]["password_match"].as<bool>();
        std::cout << "🔍 Password match result: " << (password_match ? "true" : "false") << std::endl;
        
        return password_match;
    } catch (const std::exception& e) {
        std::cerr << "❌ Password verification error: " << e.what() << std::endl;
        return false;
    }
}

UserData User::toUserData() const {
    UserData userData;
    userData.id = id_;
    userData.email = email_;
    userData.name = name_;
    userData.role = role_;
    userData.valid = !id_.empty();
    return userData;
}

bool User::loadByEmail(const std::string& email) {
    auto data = findBy("users", "email", email);
    if (data.empty()) {
        return false;
    }
    
    populateFromMap(data[0]);
    return true;
}

std::string User::getUserRoles(const std::string& user_id) {
    std::ostringstream json;
    json << "{\"roles\":[";
    
    bool hasRoles = false;
    
    try {
        // Check if user is a player on any teams
        std::string player_sql = 
            "SELECT DISTINCT "
            "  'player' as role_type, "
            "  t.id as team_id, "
            "  t.name as team_name, "
            "  tp.jersey_number, "
            "  c.name as club_name "
            "FROM team_players tp "
            "JOIN teams t ON tp.team_id = t.id "
            "JOIN sport_divisions sd ON t.division_id = sd.id "
            "JOIN clubs c ON sd.club_id = c.id "
            "WHERE tp.player_id = $1 AND tp.is_active = true";
        
        pqxx::result player_result = executeQuery(player_sql, {user_id});
        
        for (const auto& row : player_result) {
            if (hasRoles) json << ",";
            json << "{";
            json << "\"type\":\"player\",";
            json << "\"teamId\":\"" << row["team_id"].as<std::string>() << "\",";
            json << "\"teamName\":\"" << row["team_name"].as<std::string>() << "\",";
            json << "\"clubName\":\"" << row["club_name"].as<std::string>() << "\",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].as<std::string>());
            json << "}";
            hasRoles = true;
        }
        
        // Check if user is a coach on any teams
        std::string coach_sql = 
            "SELECT DISTINCT "
            "  'coach' as role_type, "
            "  t.id as team_id, "
            "  t.name as team_name, "
            "  tc.coach_role, "
            "  tc.is_primary, "
            "  c.name as club_name "
            "FROM team_coaches tc "
            "JOIN teams t ON tc.team_id = t.id "
            "JOIN sport_divisions sd ON t.division_id = sd.id "
            "JOIN clubs c ON sd.club_id = c.id "
            "WHERE tc.coach_id = $1 AND tc.is_active = true";
        
        pqxx::result coach_result = executeQuery(coach_sql, {user_id});
        
        for (const auto& row : coach_result) {
            if (hasRoles) json << ",";
            json << "{";
            json << "\"type\":\"coach\",";
            json << "\"teamId\":\"" << row["team_id"].as<std::string>() << "\",";
            json << "\"teamName\":\"" << row["team_name"].as<std::string>() << "\",";
            json << "\"clubName\":\"" << row["club_name"].as<std::string>() << "\",";
            json << "\"coachRole\":\"" << row["coach_role"].as<std::string>() << "\",";
            json << "\"isPrimary\":" << (row["is_primary"].as<bool>() ? "true" : "false");
            json << "}";
            hasRoles = true;
        }
        
        // Check if user is an admin (system, league, club, etc.)
        std::string admin_sql = 
            "SELECT a.admin_level "
            "FROM admins a "
            "WHERE a.id = $1";
        
        pqxx::result admin_result = executeQuery(admin_sql, {user_id});
        
        for (const auto& row : admin_result) {
            if (hasRoles) json << ",";
            json << "{";
            json << "\"type\":\"admin\",";
            json << "\"adminLevel\":\"" << row["admin_level"].as<std::string>() << "\",";
            json << "\"teamId\":null,";
            json << "\"teamName\":\"System Administration\",";
            json << "\"clubName\":\"Football Home\"";
            json << "}";
            hasRoles = true;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ getUserRoles error: " << e.what() << std::endl;
    }
    
    json << "]}";
    return json.str();
}

void User::populateFromMap(const std::unordered_map<std::string, std::string>& data) {
    auto it = data.find("id");
    if (it != data.end()) id_ = it->second;
    
    it = data.find("email");
    if (it != data.end()) email_ = it->second;
    
    it = data.find("name");
    if (it != data.end()) name_ = it->second;
    
    it = data.find("password_hash");
    if (it != data.end()) password_hash_ = it->second;
    
    it = data.find("admin_level");
    if (it != data.end()) {
        role_ = it->second.empty() ? "user" : it->second;
    } else {
        role_ = "user";
    }
}