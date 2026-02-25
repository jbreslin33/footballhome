#include "Team.h"
#include "../database/SqlFileLogger.h"
#include "../database/SqlBuilder.h"
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
        std::string sql = "SELECT id, name, division_id, club_id, source_system_id, external_id FROM teams WHERE id = $1";
        pqxx::result result = executeQuery(sql, {uuid});
        
        if (!result.empty()) {
            auto row = result[0];
            id_ = row["id"].as<std::string>();
            name_ = row["name"].as<std::string>();
            division_id_ = row["division_id"].as<std::string>();
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
            "LEFT JOIN clubs d ON t.club_id = d.id "
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
        // Get all active players for the team
        // rosters → players → persons for names
        // LEFT JOIN roster_positions → positions for position
        // LEFT JOIN users (via person_id) for email/avatar
        std::string sql = 
            "SELECT "
            "  pl.id as player_id, "
            "  pe.first_name, "
            "  pe.last_name, "
            "  pem.email, "
            "  pl.photo_url as avatar_url, "
            "  r.jersey_number, "
            "  pos.name as position, "
            "  (r.left_at IS NULL) as is_active, "
            "  DATE(r.joined_at) as joined_date "
            "FROM rosters r "
            "JOIN players pl ON r.player_id = pl.id "
            "JOIN persons pe ON pl.person_id = pe.id "
            "LEFT JOIN roster_positions rp ON rp.roster_id = r.id AND rp.is_primary = true "
            "LEFT JOIN positions pos ON rp.position_id = pos.id "
            "LEFT JOIN person_emails pem ON pem.person_id = pe.id AND pem.is_primary = true "
            "WHERE r.team_id = $1 AND r.left_at IS NULL "
            "ORDER BY "
            "  r.jersey_number NULLS LAST, "
            "  pe.last_name, pe.first_name";
        
        pqxx::result result = executeQuery(sql, {team_id});
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            
            std::string first_name = row["first_name"].is_null() ? "" : row["first_name"].as<std::string>();
            std::string last_name = row["last_name"].is_null() ? "" : row["last_name"].as<std::string>();
            std::string full_name = escapeJSON(first_name + " " + last_name);
            std::string email = row["email"].is_null() ? "" : escapeJSON(row["email"].as<std::string>());
            std::string avatar_url = row["avatar_url"].is_null() ? "" : escapeJSON(row["avatar_url"].as<std::string>());
            std::string position = row["position"].is_null() ? "" : escapeJSON(row["position"].as<std::string>());
            std::string joined_date = row["joined_date"].is_null() ? "" : row["joined_date"].as<std::string>();
            
            json << "{";
            json << "\"id\":\"" << row["player_id"].as<std::string>() << "\",";
            json << "\"name\":\"" << full_name << "\",";
            json << "\"email\":\"" << email << "\",";
            json << "\"photoUrl\":\"" << avatar_url << "\",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : "\"" + row["jersey_number"].as<std::string>() + "\"") << ",";
            json << "\"position\":\"" << position << "\",";
            json << "\"isCaptain\":false,";
            json << "\"isViceCaptain\":false,";
            json << "\"isActive\":" << (row["is_active"].as<bool>() ? "true" : "false") << ",";
            json << "\"rosterStatusId\":null,";
            json << "\"rosterStatusCode\":null,";
            json << "\"rosterStatus\":null,";
            json << "\"showInRsvp\":true,";
            json << "\"showInOfficialRoster\":true,";
            json << "\"joinedDate\":\"" << joined_date << "\",";
            json << "\"roleType\":\"PLAYER\"";
            json << "}";
            
            first = false;
        }
        
        // Also get coaches for the team
        std::string coach_sql = 
            "SELECT "
            "  c.id as coach_id, "
            "  pe.first_name, "
            "  pe.last_name, "
            "  pem.email, "
            "  cr.name as coach_role, "
            "  tc.coach_role_id "
            "FROM team_coaches tc "
            "JOIN coaches c ON tc.coach_id = c.id "
            "JOIN persons pe ON c.person_id = pe.id "
            "LEFT JOIN coach_roles cr ON tc.coach_role_id = cr.id "
            "LEFT JOIN person_emails pem ON pem.person_id = pe.id AND pem.is_primary = true "
            "WHERE tc.team_id = $1 AND tc.ended_at IS NULL "
            "ORDER BY pe.last_name, pe.first_name";
        
        pqxx::result coach_result = executeQuery(coach_sql, {team_id});
        
        for (const auto& row : coach_result) {
            if (!first) json << ",";
            
            std::string first_name = row["first_name"].is_null() ? "" : row["first_name"].as<std::string>();
            std::string last_name = row["last_name"].is_null() ? "" : row["last_name"].as<std::string>();
            std::string full_name = escapeJSON(first_name + " " + last_name);
            std::string email = row["email"].is_null() ? "" : escapeJSON(row["email"].as<std::string>());
            std::string coach_role = row["coach_role"].is_null() ? "Coach" : escapeJSON(row["coach_role"].as<std::string>());
            
            json << "{";
            json << "\"id\":\"" << row["coach_id"].as<std::string>() << "\",";
            json << "\"name\":\"" << full_name << "\",";
            json << "\"email\":\"" << email << "\",";
            json << "\"photoUrl\":\"\",";
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

std::string Team::getDivisionStandings(const std::string& team_id) {
    std::ostringstream json;
    json << "{";
    
    try {
        // First get the division info for this team
        std::string div_sql = 
            "SELECT t.division_id, d.name as division_name, "
            "       c.name as conference_name, l.name as league_name "
            "FROM teams t "
            "JOIN divisions d ON t.division_id = d.id "
            "JOIN conferences c ON d.conference_id = c.id "
            "JOIN seasons s ON c.season_id = s.id "
            "JOIN leagues l ON s.league_id = l.id "
            "WHERE t.id = $1";
        
        pqxx::result div_result = executeQuery(div_sql, {team_id});
        
        if (div_result.empty()) {
            json << "\"division_name\":\"Unknown\",\"standings\":[]";
            json << "}";
            return json.str();
        }
        
        std::string division_id = div_result[0]["division_id"].as<std::string>();
        std::string division_name = div_result[0]["division_name"].is_null() ? "Unknown" : div_result[0]["division_name"].as<std::string>();
        std::string conference_name = div_result[0]["conference_name"].is_null() ? "" : div_result[0]["conference_name"].as<std::string>();
        std::string league_name = div_result[0]["league_name"].is_null() ? "" : div_result[0]["league_name"].as<std::string>();
        
        json << "\"division_name\":\"" << escapeJSON(division_name) << "\",";
        json << "\"conference_name\":\"" << escapeJSON(conference_name) << "\",";
        json << "\"league_name\":\"" << escapeJSON(league_name) << "\",";
        json << "\"team_id\":\"" << team_id << "\",";
        json << "\"standings\":[";
        
        // Get standings for all teams in the same division
        std::string standings_sql = 
            "SELECT s.position, t.id as team_id, t.name as team_name, t.logo_url, "
            "       s.played, s.wins, s.draws, s.losses, "
            "       s.goals_for, s.goals_against, s.goal_diff, s.points "
            "FROM standings s "
            "JOIN teams t ON s.team_id = t.id "
            "WHERE t.division_id = $1 "
            "ORDER BY s.points DESC, s.goal_diff DESC, s.goals_for DESC, t.name";
        
        pqxx::result standings_result = executeQuery(standings_sql, {division_id});
        
        bool first = true;
        for (const auto& row : standings_result) {
            if (!first) json << ",";
            
            std::string logo_url = row["logo_url"].is_null() ? "" : escapeJSON(row["logo_url"].as<std::string>());
            
            json << "{";
            json << "\"position\":" << (row["position"].is_null() ? 0 : row["position"].as<int>()) << ",";
            json << "\"team_id\":\"" << row["team_id"].as<std::string>() << "\",";
            json << "\"team_name\":\"" << escapeJSON(row["team_name"].as<std::string>()) << "\",";
            json << "\"logo_url\":\"" << logo_url << "\",";
            json << "\"played\":" << (row["played"].is_null() ? 0 : row["played"].as<int>()) << ",";
            json << "\"wins\":" << (row["wins"].is_null() ? 0 : row["wins"].as<int>()) << ",";
            json << "\"draws\":" << (row["draws"].is_null() ? 0 : row["draws"].as<int>()) << ",";
            json << "\"losses\":" << (row["losses"].is_null() ? 0 : row["losses"].as<int>()) << ",";
            json << "\"goals_for\":" << (row["goals_for"].is_null() ? 0 : row["goals_for"].as<int>()) << ",";
            json << "\"goals_against\":" << (row["goals_against"].is_null() ? 0 : row["goals_against"].as<int>()) << ",";
            json << "\"goal_diff\":" << (row["goal_diff"].is_null() ? 0 : row["goal_diff"].as<int>()) << ",";
            json << "\"points\":" << (row["points"].is_null() ? 0 : row["points"].as<int>());
            json << "}";
            
            first = false;
        }
        
        json << "]";
        
    } catch (const std::exception& e) {
        std::cerr << "❌ getDivisionStandings error: " << e.what() << std::endl;
        json << "\"division_name\":\"Error\",\"standings\":[]";
    }
    
    json << "}";
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
                              const std::string& roster_status_id,
                              const std::string& first_name, const std::string& last_name) {
    try {
        // If setting this player as captain, first unset any existing captain
        if (is_captain) {
            std::string unset_sql = "UPDATE team_division_players SET is_captain = false WHERE team_id = $1 AND is_captain = true";
            executeQuery(unset_sql, {team_id});
        }
        
        // If setting this player as vice captain, first unset any existing vice captain
        if (is_vice_captain) {
            std::string unset_sql = "UPDATE team_division_players SET is_vice_captain = false WHERE team_id = $1 AND is_vice_captain = true";
            executeQuery(unset_sql, {team_id});
        }
        
        // Build the update query with hard-coded booleans (pqxx string params don't work for bool)
        std::ostringstream sql;
        sql << "UPDATE team_division_players SET ";
        
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
        
        // Log to ##u/##p file
        std::map<std::string, std::string> tp_columns;
        if (!jersey_number.empty()) tp_columns["jersey_number"] = jersey_number;
        if (!roster_status_id.empty()) tp_columns["roster_status_id"] = roster_status_id;
        tp_columns["is_captain"] = is_captain ? "true" : "false";
        tp_columns["is_vice_captain"] = is_vice_captain ? "true" : "false";
        std::string tp_upsert = SqlBuilder::buildUpsert("team_division_players", 
            team_id + "',player_id='" + player_id, tp_columns, "team_id, player_id");
        SqlFileLogger::log("team_division_players", tp_upsert);

        // Update user name if provided
        if (!first_name.empty() && !last_name.empty()) {
            std::string user_sql = "UPDATE users SET first_name = $1, last_name = $2 WHERE id = $3";
            executeQuery(user_sql, {first_name, last_name, player_id});
            std::cout << "✅ Updated user name: " << first_name << " " << last_name << std::endl;
            
            // Log to ##u/##p file
            std::map<std::string, std::string> user_columns;
            user_columns["first_name"] = first_name;
            user_columns["last_name"] = last_name;
            std::string user_upsert = SqlBuilder::buildUpsert("users", player_id, user_columns, "id");
            SqlFileLogger::log("users", user_upsert);
        }
        
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
        std::string sql = "UPDATE team_division_players SET is_active = false WHERE team_id = $1 AND player_id = $2";
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