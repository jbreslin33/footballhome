#include "Team.h"
#include <iostream>
#include <sstream>
#include <iomanip>

Team::Team() : Model("teams", "id") {
}

bool Team::save() {
    // For now, implement basic save functionality
    try {
        std::unordered_map<std::string, std::string> data;
        data["name"] = name_;
        data["division_id"] = division_id_;
        
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
        std::cerr << "❌ Team save error: " << e.what() << std::endl;
        return false;
    }
}

bool Team::load(int id) {
    // This method expects an integer ID, but we're using UUIDs
    // For UUID support, use loadByUuid instead
    return false;
}

bool Team::loadByUuid(const std::string& uuid) {
    try {
        std::string sql = "SELECT id, name, division_id, league_division_id FROM teams WHERE id = $1";
        pqxx::result result = executeQuery(sql, {uuid});
        
        if (!result.empty()) {
            auto row = result[0];
            id_ = row["id"].as<std::string>();
            name_ = row["name"].as<std::string>();
            division_id_ = row["division_id"].as<std::string>();
            league_division_id_ = row["league_division_id"].is_null() ? "" : row["league_division_id"].as<std::string>();
            return true;
        }
        return false;
    } catch (const std::exception& e) {
        std::cerr << "❌ Team loadByUuid error: " << e.what() << std::endl;
        return false;
    }
}

bool Team::remove() {
    if (id_.empty()) {
        return false;
    }
    
    try {
        std::string sql = "DELETE FROM teams WHERE id = $1";
        executeQuery(sql, {id_});
        return true;
    } catch (const std::exception& e) {
        std::cerr << "❌ Team remove error: " << e.what() << std::endl;
        return false;
    }
}

std::string Team::getTeamRoster(const std::string& team_id) {
    std::ostringstream json;
    json << "[";
    
    try {
        // Get all players for the team
        std::string sql = 
            "SELECT "
            "  u.id as user_id, "
            "  u.first_name, "
            "  u.last_name, "
            "  u.email, "
            "  tp.jersey_number, "
            "  p.display_name as position, "
            "  tp.is_captain, "
            "  tp.is_vice_captain, "
            "  tp.is_active, "
            "  DATE(tp.joined_at) as joined_date "
            "FROM team_players tp "
            "JOIN players pl ON tp.player_id = pl.id "
            "JOIN users u ON pl.id = u.id "
            "LEFT JOIN positions p ON tp.position_id = p.id "
            "WHERE tp.team_id = $1 AND tp.is_active = true "
            "ORDER BY "
            "  tp.jersey_number NULLS LAST, "
            "  u.last_name, u.first_name";
        
        pqxx::result result = executeQuery(sql, {team_id});
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            
            std::string first_name = row["first_name"].is_null() ? "" : row["first_name"].as<std::string>();
            std::string last_name = row["last_name"].is_null() ? "" : row["last_name"].as<std::string>();
            std::string full_name = escapeJSON(first_name + " " + last_name);
            std::string email = row["email"].is_null() ? "" : escapeJSON(row["email"].as<std::string>());
            std::string position = row["position"].is_null() ? "No Position" : escapeJSON(row["position"].as<std::string>());
            std::string joined_date = row["joined_date"].is_null() ? "" : row["joined_date"].as<std::string>();
            
            json << "{";
            json << "\"id\":\"" << row["user_id"].as<std::string>() << "\",";
            json << "\"name\":\"" << full_name << "\",";
            json << "\"email\":\"" << email << "\",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].as<std::string>()) << ",";
            json << "\"position\":\"" << position << "\",";
            json << "\"isCaptain\":" << (row["is_captain"].as<bool>() ? "true" : "false") << ",";
            json << "\"isViceCaptain\":" << (row["is_vice_captain"].as<bool>() ? "true" : "false") << ",";
            json << "\"isActive\":" << (row["is_active"].as<bool>() ? "true" : "false") << ",";
            json << "\"joinedDate\":\"" << joined_date << "\",";
            json << "\"roleType\":\"PLAYER\"";
            json << "}";
            
            first = false;
        }
        
        // Also get coaches for the team
        std::string coach_sql = 
            "SELECT "
            "  u.id as user_id, "
            "  u.first_name, "
            "  u.last_name, "
            "  u.email, "
            "  tc.coach_role, "
            "  tc.is_primary "
            "FROM team_coaches tc "
            "JOIN coaches c ON tc.coach_id = c.id "
            "JOIN users u ON c.id = u.id "
            "WHERE tc.team_id = $1 AND tc.is_active = true "
            "ORDER BY tc.is_primary DESC, u.last_name, u.first_name";
        
        pqxx::result coach_result = executeQuery(coach_sql, {team_id});
        
        for (const auto& row : coach_result) {
            if (!first) json << ",";
            
            std::string first_name = row["first_name"].is_null() ? "" : row["first_name"].as<std::string>();
            std::string last_name = row["last_name"].is_null() ? "" : row["last_name"].as<std::string>();
            std::string full_name = escapeJSON(first_name + " " + last_name);
            std::string email = row["email"].is_null() ? "" : escapeJSON(row["email"].as<std::string>());
            std::string coach_role = row["coach_role"].is_null() ? "Coach" : escapeJSON(row["coach_role"].as<std::string>());
            
            json << "{";
            json << "\"id\":\"" << row["user_id"].as<std::string>() << "\",";
            json << "\"name\":\"" << full_name << "\",";
            json << "\"email\":\"" << email << "\",";
            json << "\"jerseyNumber\":null,";
            json << "\"position\":\"" << coach_role << "\",";
            json << "\"isCaptain\":false,";
            json << "\"isViceCaptain\":false,";
            json << "\"isActive\":true,";
            json << "\"joinedDate\":\"\",";
            json << "\"roleType\":\"COACH\"";
            json << "}";
            
            first = false;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ getTeamRoster error: " << e.what() << std::endl;
    }
    
    json << "]";
    return json.str();
}

void Team::populateFromMap(const std::unordered_map<std::string, std::string>& data) {
    auto it = data.find("id");
    if (it != data.end()) id_ = it->second;
    
    it = data.find("name");
    if (it != data.end()) name_ = it->second;
    
    it = data.find("division_id");
    if (it != data.end()) division_id_ = it->second;
    
    it = data.find("league_division_id");
    if (it != data.end()) league_division_id_ = it->second;
}

std::string Team::escapeJSON(const std::string& str) {
    std::ostringstream escaped;
    for (char c : str) {
        switch (c) {
            case '"':  escaped << "\\\""; break;
            case '\\': escaped << "\\\\"; break;
            case '\b': escaped << "\\b"; break;
            case '\f': escaped << "\\f"; break;
            case '\n': escaped << "\\n"; break;
            case '\r': escaped << "\\r"; break;
            case '\t': escaped << "\\t"; break;
            default:
                if (c < 0x20) {
                    // Escape other control characters
                    escaped << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(c);
                } else {
                    escaped << c;
                }
        }
    }
    return escaped.str();
}