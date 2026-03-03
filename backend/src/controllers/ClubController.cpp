#include "ClubController.h"
#include <sstream>
#include <iostream>
#include <iomanip>

ClubController::ClubController() {
    db_ = Database::getInstance();
}

void ClubController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering club routes with prefix: " << prefix << std::endl;
    
    // GET /api/clubs - List all clubs with team count
    router.get(prefix, [this](const Request& request) {
        return this->handleGetAllClubs(request);
    });
    
    // GET /api/clubs/:id - Get club detail with teams, rosters, schedules
    router.get(prefix + "/:id", [this](const Request& request) {
        return this->handleGetClubDetail(request);
    });
}

std::string ClubController::escapeJson(const std::string& input) {
    std::ostringstream output;
    for (char c : input) {
        switch (c) {
            case '"': output << "\\\""; break;
            case '\\': output << "\\\\"; break;
            case '\b': output << "\\b"; break;
            case '\f': output << "\\f"; break;
            case '\n': output << "\\n"; break;
            case '\r': output << "\\r"; break;
            case '\t': output << "\\t"; break;
            default:
                if (c < 0x20) {
                    output << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(c);
                } else {
                    output << c;
                }
        }
    }
    return output.str();
}

std::string ClubController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
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

Response ClubController::handleGetAllClubs(const Request& request) {
    try {
        std::string query = R"(
            SELECT 
                c.id,
                c.name,
                c.logo_url,
                o.name as organization_name,
                COUNT(DISTINCT t.id) as team_count,
                COUNT(DISTINCT r.player_id) FILTER (WHERE r.left_at IS NULL) as player_count
            FROM clubs c
            JOIN organizations o ON c.organization_id = o.id
            LEFT JOIN teams t ON t.club_id = c.id
            LEFT JOIN rosters r ON r.team_id = t.id
            WHERE c.is_active = true
            GROUP BY c.id, c.name, c.logo_url, o.name
            ORDER BY c.name
        )";
        
        pqxx::result result = db_->query(query);
        
        std::ostringstream json;
        json << "[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
            json << "\"logo_url\":" << (row["logo_url"].is_null() ? "null" : "\"" + escapeJson(row["logo_url"].c_str()) + "\"") << ",";
            json << "\"organization_name\":\"" << escapeJson(row["organization_name"].c_str()) << "\",";
            json << "\"team_count\":" << row["team_count"].as<int>() << ",";
            json << "\"player_count\":" << row["player_count"].as<int>();
            json << "}";
        }
        
        json << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Clubs retrieved", json.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetAllClubs: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
}

Response ClubController::handleGetClubDetail(const Request& request) {
    try {
        // Extract club ID from path: /api/clubs/:id
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        }
        std::string club_id_str = path.substr(pos + prefix.length());
        // Remove any trailing path segments
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) {
            club_id_str = club_id_str.substr(0, slash_pos);
        }
        
        int club_id = std::stoi(club_id_str);
        
        // 1. Get club info
        std::string clubQuery = R"(
            SELECT c.id, c.name, c.logo_url, o.name as organization_name
            FROM clubs c
            JOIN organizations o ON c.organization_id = o.id
            WHERE c.id = )" + std::to_string(club_id);
        
        pqxx::result clubResult = db_->query(clubQuery);
        if (clubResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Club not found"));
        }
        
        auto clubRow = clubResult[0];
        
        // 2. Get teams with division info
        std::string teamsQuery = R"(
            SELECT 
                t.id,
                t.name,
                d.name as division_name,
                s.name as season_name,
                l.name as league_name,
                COUNT(DISTINCT r.player_id) FILTER (WHERE r.left_at IS NULL) as player_count,
                COUNT(DISTINCT m.id) as match_count
            FROM teams t
            JOIN divisions d ON t.division_id = d.id
            JOIN conferences conf ON d.conference_id = conf.id
            JOIN seasons s ON conf.season_id = s.id
            JOIN leagues l ON s.league_id = l.id
            LEFT JOIN rosters r ON r.team_id = t.id
            LEFT JOIN matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
            WHERE t.club_id = )" + std::to_string(club_id) + R"(
            GROUP BY t.id, t.name, d.name, s.name, l.name
            ORDER BY l.name, d.name, t.name
        )";
        
        pqxx::result teamsResult = db_->query(teamsQuery);
        
        // 3. For each team, get roster
        std::ostringstream teamsJson;
        teamsJson << "[";
        
        bool firstTeam = true;
        for (const auto& teamRow : teamsResult) {
            if (!firstTeam) teamsJson << ",";
            firstTeam = false;
            
            int teamId = teamRow["id"].as<int>();
            
            // Get roster for this team
            std::string rosterQuery = R"(
                SELECT 
                    per.first_name,
                    per.last_name,
                    r.jersey_number
                FROM rosters r
                JOIN players pl ON r.player_id = pl.id
                JOIN persons per ON pl.person_id = per.id
                WHERE r.team_id = )" + std::to_string(teamId) + R"(
                  AND r.left_at IS NULL
                ORDER BY per.last_name, per.first_name
            )";
            
            pqxx::result rosterResult = db_->query(rosterQuery);
            
            std::ostringstream rosterJson;
            rosterJson << "[";
            bool firstPlayer = true;
            for (const auto& playerRow : rosterResult) {
                if (!firstPlayer) rosterJson << ",";
                firstPlayer = false;
                
                rosterJson << "{";
                rosterJson << "\"first_name\":\"" << escapeJson(playerRow["first_name"].c_str()) << "\",";
                rosterJson << "\"last_name\":\"" << escapeJson(playerRow["last_name"].c_str()) << "\",";
                rosterJson << "\"jersey_number\":" << (playerRow["jersey_number"].is_null() ? "null" : "\"" + escapeJson(playerRow["jersey_number"].c_str()) + "\"");
                rosterJson << "}";
            }
            rosterJson << "]";
            
            // Get upcoming matches for this team
            std::string matchesQuery = R"(
                SELECT 
                    m.id,
                    m.match_date,
                    m.match_time,
                    m.home_score,
                    m.away_score,
                    ht.name as home_team_name,
                    at.name as away_team_name,
                    ms.name as match_status
                FROM matches m
                JOIN teams ht ON m.home_team_id = ht.id
                JOIN teams at ON m.away_team_id = at.id
                JOIN match_statuses ms ON m.match_status_id = ms.id
                WHERE (m.home_team_id = )" + std::to_string(teamId) + R"(
                   OR m.away_team_id = )" + std::to_string(teamId) + R"()
                ORDER BY m.match_date DESC
                LIMIT 20
            )";
            
            pqxx::result matchesResult = db_->query(matchesQuery);
            
            std::ostringstream matchesJson;
            matchesJson << "[";
            bool firstMatch = true;
            for (const auto& matchRow : matchesResult) {
                if (!firstMatch) matchesJson << ",";
                firstMatch = false;
                
                matchesJson << "{";
                matchesJson << "\"id\":" << matchRow["id"].as<int>() << ",";
                matchesJson << "\"match_date\":\"" << matchRow["match_date"].c_str() << "\",";
                matchesJson << "\"match_time\":" << (matchRow["match_time"].is_null() ? "null" : "\"" + std::string(matchRow["match_time"].c_str()) + "\"") << ",";
                matchesJson << "\"home_score\":" << (matchRow["home_score"].is_null() ? "null" : std::string(matchRow["home_score"].c_str())) << ",";
                matchesJson << "\"away_score\":" << (matchRow["away_score"].is_null() ? "null" : std::string(matchRow["away_score"].c_str())) << ",";
                matchesJson << "\"home_team_name\":\"" << escapeJson(matchRow["home_team_name"].c_str()) << "\",";
                matchesJson << "\"away_team_name\":\"" << escapeJson(matchRow["away_team_name"].c_str()) << "\",";
                matchesJson << "\"match_status\":\"" << matchRow["match_status"].c_str() << "\"";
                matchesJson << "}";
            }
            matchesJson << "]";
            
            teamsJson << "{";
            teamsJson << "\"id\":" << teamId << ",";
            teamsJson << "\"name\":\"" << escapeJson(teamRow["name"].c_str()) << "\",";
            teamsJson << "\"division_name\":\"" << escapeJson(teamRow["division_name"].c_str()) << "\",";
            teamsJson << "\"season_name\":\"" << escapeJson(teamRow["season_name"].c_str()) << "\",";
            teamsJson << "\"league_name\":\"" << escapeJson(teamRow["league_name"].c_str()) << "\",";
            teamsJson << "\"player_count\":" << teamRow["player_count"].as<int>() << ",";
            teamsJson << "\"match_count\":" << teamRow["match_count"].as<int>() << ",";
            teamsJson << "\"roster\":" << rosterJson.str() << ",";
            teamsJson << "\"matches\":" << matchesJson.str();
            teamsJson << "}";
        }
        
        teamsJson << "]";
        
        // Build final response
        std::ostringstream clubJson;
        clubJson << "{";
        clubJson << "\"id\":" << clubRow["id"].as<int>() << ",";
        clubJson << "\"name\":\"" << escapeJson(clubRow["name"].c_str()) << "\",";
        clubJson << "\"logo_url\":" << (clubRow["logo_url"].is_null() ? "null" : "\"" + escapeJson(clubRow["logo_url"].c_str()) + "\"") << ",";
        clubJson << "\"organization_name\":\"" << escapeJson(clubRow["organization_name"].c_str()) << "\",";
        clubJson << "\"teams\":" << teamsJson.str();
        clubJson << "}";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Club detail retrieved", clubJson.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetClubDetail: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Database error: ") + e.what()));
    }
}
