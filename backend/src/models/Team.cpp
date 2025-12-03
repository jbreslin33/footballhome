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

std::string Team::getAllTeams() {
    std::ostringstream json;
    json << "[";
    
    try {
        std::string sql = 
            "SELECT t.id, t.name, t.age_group, t.skill_level, d.name as division_name "
            "FROM teams t "
            "LEFT JOIN sport_divisions d ON t.division_id = d.id "
            "ORDER BY t.name";
        
        pqxx::result result = executeQuery(sql, {});
        
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json << ",";
            
            json << "{";
            json << "\"id\":\"" << result[i]["id"].c_str() << "\",";
            json << "\"name\":\"" << escapeJSON(result[i]["name"].c_str()) << "\"";
            
            if (!result[i]["age_group"].is_null()) {
                json << ",\"age_group\":\"" << escapeJSON(result[i]["age_group"].c_str()) << "\"";
            }
            if (!result[i]["skill_level"].is_null()) {
                json << ",\"skill_level\":\"" << escapeJSON(result[i]["skill_level"].c_str()) << "\"";
            }
            if (!result[i]["division_name"].is_null()) {
                json << ",\"division_name\":\"" << escapeJSON(result[i]["division_name"].c_str()) << "\"";
            }
            
            json << "}";
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Team getAllTeams error: " << e.what() << std::endl;
        json.str("");
        json << "[";
    }
    
    json << "]";
    return json.str();
}

std::string Team::getTeamRoster(const std::string& team_id) {
    std::ostringstream json;
    json << "[";
    
    try {
        // Get all players for the team (including roster status info)
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
            "  tp.roster_status_id, "
            "  rs.code as roster_status_code, "
            "  rs.display_name as roster_status, "
            "  rs.show_in_rsvp, "
            "  rs.show_in_official_roster, "
            "  DATE(tp.joined_at) as joined_date "
            "FROM team_players tp "
            "JOIN players pl ON tp.player_id = pl.id "
            "JOIN users u ON pl.id = u.id "
            "LEFT JOIN positions p ON tp.position_id = p.id "
            "LEFT JOIN roster_statuses rs ON tp.roster_status_id = rs.id "
            "WHERE tp.team_id = $1 "
            "ORDER BY "
            "  rs.sort_order, "
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
            std::string roster_status = row["roster_status"].is_null() ? "Active Player" : escapeJSON(row["roster_status"].as<std::string>());
            std::string roster_status_code = row["roster_status_code"].is_null() ? "active" : row["roster_status_code"].as<std::string>();
            int roster_status_id = row["roster_status_id"].is_null() ? 1 : row["roster_status_id"].as<int>();
            bool show_in_rsvp = row["show_in_rsvp"].is_null() ? true : row["show_in_rsvp"].as<bool>();
            bool show_in_official = row["show_in_official_roster"].is_null() ? true : row["show_in_official_roster"].as<bool>();
            
            json << "{";
            json << "\"id\":\"" << row["user_id"].as<std::string>() << "\",";
            json << "\"name\":\"" << full_name << "\",";
            json << "\"email\":\"" << email << "\",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].as<std::string>()) << ",";
            json << "\"position\":\"" << position << "\",";
            json << "\"isCaptain\":" << (row["is_captain"].as<bool>() ? "true" : "false") << ",";
            json << "\"isViceCaptain\":" << (row["is_vice_captain"].as<bool>() ? "true" : "false") << ",";
            json << "\"isActive\":" << (row["is_active"].as<bool>() ? "true" : "false") << ",";
            json << "\"rosterStatusId\":" << roster_status_id << ",";
            json << "\"rosterStatusCode\":\"" << roster_status_code << "\",";
            json << "\"rosterStatus\":\"" << roster_status << "\",";
            json << "\"showInRsvp\":" << (show_in_rsvp ? "true" : "false") << ",";
            json << "\"showInOfficialRoster\":" << (show_in_official ? "true" : "false") << ",";
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
            json << "\"rosterStatusId\":null,";
            json << "\"rosterStatusCode\":null,";
            json << "\"rosterStatus\":null,";
            json << "\"showInRsvp\":true,";
            json << "\"showInOfficialRoster\":true,";
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

std::string Team::getRosterStatuses() {
    std::ostringstream json;
    json << "[";
    
    try {
        std::string sql = 
            "SELECT id, code, display_name, description, "
            "       show_in_rsvp, show_in_official_roster, sort_order, is_active "
            "FROM roster_statuses "
            "WHERE is_active = true "
            "ORDER BY sort_order";
        
        pqxx::result result = executeQuery(sql, {});
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            
            std::string description = row["description"].is_null() ? "" : escapeJSON(row["description"].as<std::string>());
            
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"code\":\"" << row["code"].as<std::string>() << "\",";
            json << "\"displayName\":\"" << escapeJSON(row["display_name"].as<std::string>()) << "\",";
            json << "\"description\":\"" << description << "\",";
            json << "\"showInRsvp\":" << (row["show_in_rsvp"].as<bool>() ? "true" : "false") << ",";
            json << "\"showInOfficialRoster\":" << (row["show_in_official_roster"].as<bool>() ? "true" : "false") << ",";
            json << "\"sortOrder\":" << row["sort_order"].as<int>();
            json << "}";
            
            first = false;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ getRosterStatuses error: " << e.what() << std::endl;
    }
    
    json << "]";
    return json.str();
}

bool Team::updateRosterMember(const std::string& team_id, const std::string& player_id,
                              const std::string& jersey_number, bool is_captain, bool is_vice_captain,
                              const std::string& roster_status_id) {
    try {
        // If setting this player as captain, first unset any existing captain
        if (is_captain) {
            std::string unset_sql = "UPDATE team_players SET is_captain = false WHERE team_id = $1 AND is_captain = true";
            executeQuery(unset_sql, {team_id});
        }
        
        // If setting this player as vice captain, first unset any existing vice captain
        if (is_vice_captain) {
            std::string unset_sql = "UPDATE team_players SET is_vice_captain = false WHERE team_id = $1 AND is_vice_captain = true";
            executeQuery(unset_sql, {team_id});
        }
        
        // Build the update query with hard-coded booleans (pqxx string params don't work for bool)
        std::ostringstream sql;
        sql << "UPDATE team_players SET ";
        
        std::vector<std::string> params;
        int param_num = 1;
        
        if (!jersey_number.empty()) {
            sql << "jersey_number = $" << param_num++ << ", ";
            params.push_back(jersey_number);
        }
        
        if (!roster_status_id.empty()) {
            sql << "roster_status_id = $" << param_num++ << ", ";
            params.push_back(roster_status_id);
        }
        
        // Use literal true/false for boolean columns
        sql << "is_captain = " << (is_captain ? "true" : "false") << ", ";
        sql << "is_vice_captain = " << (is_vice_captain ? "true" : "false") << " ";
        
        sql << "WHERE team_id = $" << param_num++ << " AND player_id = $" << param_num;
        params.push_back(team_id);
        params.push_back(player_id);
        
        std::string sql_str = sql.str();
        std::cout << "🔍 SQL: " << sql_str << std::endl;
        std::cout << "🔍 Params: ";
        for (const auto& p : params) std::cout << p << " ";
        std::cout << std::endl;
        
        executeQuery(sql_str, params);
        
        std::cout << "✅ Updated roster member: " << player_id << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "❌ updateRosterMember error: " << e.what() << std::endl;
        return false;
    }
}

bool Team::removeRosterMember(const std::string& team_id, const std::string& player_id) {
    try {
        // Soft delete - set is_active to false
        std::string sql = "UPDATE team_players SET is_active = false WHERE team_id = $1 AND player_id = $2";
        executeQuery(sql, {team_id, player_id});
        
        std::cout << "✅ Removed roster member: " << player_id << " from team: " << team_id << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "❌ removeRosterMember error: " << e.what() << std::endl;
        return false;
    }
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