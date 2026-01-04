#include "UserService.h"
#include <sstream>
#include <stdexcept>
#include <iostream>
#include <fstream>

UserService::UserService(Database* db) : db_(db) {}

UserService::UserDetails UserService::getUserById(const std::string& user_id) {
    std::string query = R"(
        SELECT u.id, u.first_name, u.last_name, u.email, u.phone, u.date_of_birth,
               u.is_active, u.created_at, u.updated_at
        FROM users u
        WHERE u.id = $1
    )";
    
    std::vector<std::string> params = {user_id};
    auto result = db_->query(query, params);
    
    if (result.empty()) {
        throw std::runtime_error("User not found");
    }
    
    UserDetails user;
    user.id = result[0]["id"].as<std::string>();
    user.first_name = result[0]["first_name"].is_null() ? "" : result[0]["first_name"].as<std::string>();
    user.last_name = result[0]["last_name"].is_null() ? "" : result[0]["last_name"].as<std::string>();
    user.email = result[0]["email"].is_null() ? "" : result[0]["email"].as<std::string>();
    user.phone = result[0]["phone"].is_null() ? "" : result[0]["phone"].as<std::string>();
    user.date_of_birth = result[0]["date_of_birth"].is_null() ? "" : result[0]["date_of_birth"].as<std::string>();
    user.is_active = result[0]["is_active"].as<bool>();
    user.created_at = result[0]["created_at"].as<std::string>();
    user.updated_at = result[0]["updated_at"].as<std::string>();
    
    return user;
}

std::vector<UserService::UserDetails> UserService::getUsersByClub(const std::string& club_id) {
    std::string query = R"(
        SELECT DISTINCT u.id, u.first_name, u.last_name, u.email, u.phone, 
               u.date_of_birth, u.is_active, u.created_at, u.updated_at
        FROM users u
        JOIN team_division_players tp ON u.id = tp.player_id
        JOIN teams t ON tp.team_id = t.id
        JOIN clubs sd ON t.club_id = sd.id
        WHERE sd.club_id = $1
        ORDER BY u.last_name, u.first_name
    )";
    
    std::vector<std::string> params = {club_id};
    auto result = db_->query(query, params);
    
    std::vector<UserDetails> users;
    for (size_t i = 0; i < result.size(); ++i) {
        UserDetails user;
        user.id = result[i]["id"].as<std::string>();
        user.first_name = result[i]["first_name"].is_null() ? "" : result[i]["first_name"].as<std::string>();
        user.last_name = result[i]["last_name"].is_null() ? "" : result[i]["last_name"].as<std::string>();
        user.email = result[i]["email"].is_null() ? "" : result[i]["email"].as<std::string>();
        user.phone = result[i]["phone"].is_null() ? "" : result[i]["phone"].as<std::string>();
        user.date_of_birth = result[i]["date_of_birth"].is_null() ? "" : result[i]["date_of_birth"].as<std::string>();
        user.is_active = result[i]["is_active"].as<bool>();
        user.created_at = result[i]["created_at"].as<std::string>();
        user.updated_at = result[i]["updated_at"].as<std::string>();
        users.push_back(user);
    }
    
    return users;
}

bool UserService::updateUserBasicInfo(const std::string& user_id,
                                      const std::string& first_name,
                                      const std::string& last_name,
                                      const std::string& email,
                                      const std::string& phone,
                                      const std::string& date_of_birth,
                                      const std::string& admin_id) {
    try {
        // Build update query dynamically based on provided fields
        std::string query = "UPDATE users SET updated_at = CURRENT_TIMESTAMP";
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!first_name.empty()) {
            query += ", first_name = $" + std::to_string(++param_count);
            params.push_back(first_name);
        }
        if (!last_name.empty()) {
            query += ", last_name = $" + std::to_string(++param_count);
            params.push_back(last_name);
        }
        if (!email.empty()) {
            query += ", email = $" + std::to_string(++param_count);
            params.push_back(email);
        }
        if (!phone.empty()) {
            query += ", phone = $" + std::to_string(++param_count);
            params.push_back(phone);
        }
        if (!date_of_birth.empty()) {
            query += ", date_of_birth = $" + std::to_string(++param_count);
            params.push_back(date_of_birth);
        }
        
        query += " WHERE id = $" + std::to_string(++param_count);
        params.push_back(user_id);
        
        db_->query(query, params);
        
        // Build SQL statement with actual values for file logging
        std::ostringstream sql_log;
        sql_log << "UPDATE users SET updated_at = CURRENT_TIMESTAMP";
        if (!first_name.empty()) sql_log << ", first_name = '" << first_name << "'";
        if (!last_name.empty()) sql_log << ", last_name = '" << last_name << "'";
        if (!email.empty()) sql_log << ", email = '" << email << "'";
        if (!phone.empty()) sql_log << ", phone = '" << phone << "'";
        if (!date_of_birth.empty()) sql_log << ", date_of_birth = '" << date_of_birth << "'";
        sql_log << " WHERE id = '" << user_id << "'";
        
        SqlFileLogger::log("users", sql_log.str());
        
        // Log audit action
        logAuditAction(admin_id, "user_update", "users", user_id, "Updated user basic info");
        
        return true;
    } catch (const std::exception& e) {
        return false;
    }
}

bool UserService::updateUserStatus(const std::string& user_id,
                                   bool is_active,
                                   const std::string& admin_id) {
    try {
        std::string query = "UPDATE users SET is_active = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2";
        std::vector<std::string> params = {is_active ? "true" : "false", user_id};
        db_->query(query, params);
        
        logAuditAction(admin_id, "user_status_update", "users", user_id,
                      is_active ? "Activated user" : "Deactivated user");
        
        return true;
    } catch (const std::exception& e) {
        return false;
    }
}

std::vector<UserService::TeamMembership> UserService::getUserTeams(const std::string& user_id) {
    std::string query = R"(
        SELECT t.id as team_id, t.name as team_name,
               sd.display_name as sport_division_name,
               tp.jersey_number,
               p.id as position_id, p.display_name as position_name
        FROM team_division_players tp
        JOIN teams t ON tp.team_id = t.id
        JOIN clubs sd ON t.club_id = sd.id
        LEFT JOIN players pl ON pl.id = tp.player_id
        LEFT JOIN positions p ON p.id = pl.preferred_position_id
        WHERE tp.player_id = $1
        ORDER BY sd.display_name, t.name
    )";
    
    std::vector<std::string> params = {user_id};
    auto result = db_->query(query, params);
    
    std::vector<TeamMembership> teams;
    for (size_t i = 0; i < result.size(); ++i) {
        TeamMembership tm;
        tm.team_id = result[i]["team_id"].as<std::string>();
        tm.team_name = result[i]["team_name"].as<std::string>();
        tm.sport_division_name = result[i]["sport_division_name"].as<std::string>();
        tm.jersey_number = result[i]["jersey_number"].is_null() ? "" : result[i]["jersey_number"].as<std::string>();
        tm.position_id = result[i]["position_id"].is_null() ? "" : result[i]["position_id"].as<std::string>();
        tm.position_name = result[i]["position_name"].is_null() ? "" : result[i]["position_name"].as<std::string>();
        teams.push_back(tm);
    }
    
    return teams;
}

bool UserService::addUserToTeam(const std::string& user_id,
                                const std::string& team_id,
                                const std::string& jersey_number,
                                const std::string& admin_id) {
    try {
        std::string query = "INSERT INTO team_division_players (team_id, player_id, jersey_number) VALUES ($1, $2, $3) "
                          "ON CONFLICT (team_id, player_id) DO UPDATE SET jersey_number = EXCLUDED.jersey_number";
        std::vector<std::string> params = {team_id, user_id, jersey_number};
        db_->query(query, params);
        
        logAuditAction(admin_id, "team_player_add", "team_division_players", user_id,
                      "Added user to team " + team_id);
        
        return true;
    } catch (const std::exception& e) {
        return false;
    }
}

bool UserService::removeUserFromTeam(const std::string& user_id,
                                     const std::string& team_id,
                                     const std::string& admin_id) {
    try {
        std::string query = "DELETE FROM team_division_players WHERE team_id = $1 AND player_id = $2";
        std::vector<std::string> params = {team_id, user_id};
        db_->query(query, params);
        
        logAuditAction(admin_id, "team_player_remove", "team_division_players", user_id,
                      "Removed user from team " + team_id);
        
        return true;
    } catch (const std::exception& e) {
        return false;
    }
}

bool UserService::canUserManageUser(const std::string& admin_id,
                                    const std::string& target_user_id,
                                    const std::string& permission_level) {
    // System admins can manage anyone
    if (permission_level == "system_admin") {
        return true;
    }
    
    // Club admins can manage users in their club
    if (permission_level == "club_admin") {
        std::string query = R"(
            SELECT COUNT(*) as count
            FROM team_division_players tp
            JOIN teams t ON tp.team_id = t.id
            JOIN clubs sd ON t.club_id = sd.id
            JOIN organization_admins ca ON ca.club_id = sd.club_id
            WHERE ca.admin_id = (SELECT id FROM admins WHERE admin_id = $1)
              AND tp.player_id = $2
        )";
        std::vector<std::string> params = {admin_id, target_user_id};
        auto result = db_->query(query, params);
        return result[0]["count"].as<int>() > 0;
    }
    
    // Coaches cannot manage user profiles
    return false;
}

void UserService::logAuditAction(const std::string& admin_id,
                                 const std::string& action_type,
                                 const std::string& entity_type,
                                 const std::string& entity_id,
                                 const std::string& description,
                                 const std::string& old_values,
                                 const std::string& new_values) {
    try {
        std::string query = R"(
            INSERT INTO system_audit_log 
            (admin_user_id, action_type, entity_type, entity_id, action_description, old_values, new_values)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
        )";
        
        std::vector<std::string> params = {
            admin_id, action_type, entity_type, entity_id, description,
            old_values.empty() ? "NULL" : old_values,
            new_values.empty() ? "NULL" : new_values
        };
        
        db_->query(query, params);
    } catch (const std::exception& e) {
        // Audit logging should not break the main operation
        // Log error but continue
    }
}
