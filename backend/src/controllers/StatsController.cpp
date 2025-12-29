#include "StatsController.h"
#include <sstream>
#include <iostream>
#include <iomanip>

// Helper function to escape JSON strings
std::string escapeJsonString(const std::string& input) {
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

StatsController::StatsController() {
    db_ = Database::getInstance();
}

void StatsController::registerRoutes(Router& router, const std::string& prefix) {
    // Get team standings by league/conference
    router.get(prefix + "/standings", [this](const Request& request) {
        return this->handleGetStandings(request);
    });
    
    // Get player statistics (top scorers, assists, etc.)
    router.get(prefix + "/players", [this](const Request& request) {
        return this->handleGetPlayerStats(request);
    });
    
    // Get match results with scores
    router.get(prefix + "/matches", [this](const Request& request) {
        return this->handleGetMatches(request);
    });
}

std::string StatsController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json_response;
    json_response << "{";
    json_response << "\"success\":" << (success ? "true" : "false") << ",";
    json_response << "\"message\":\"" << message << "\"";
    if (!data.empty()) {
        json_response << ",\"data\":" << data;
    }
    json_response << "}";
    return json_response.str();
}

Response StatsController::handleGetStandings(const Request& request) {
    try {
        // Query team_stats (normalized table with source_system_id=1 for APSL)
        std::string query = R"(
            SELECT 
                ts.id::text,
                t.name as team_name,
                d.name as division_name,
                l.season,
                COALESCE(ts.wins, 0) + COALESCE(ts.losses, 0) + COALESCE(ts.ties, 0) as games_played,
                COALESCE(ts.wins, 0) as wins,
                COALESCE(ts.losses, 0) as losses,
                COALESCE(ts.ties, 0) as ties,
                COALESCE(ts.goals_for, 0) as goals_for,
                COALESCE(ts.goals_against, 0) as goals_against,
                COALESCE(ts.goals_for, 0) - COALESCE(ts.goals_against, 0) as goal_differential,
                COALESCE(ts.points, 0) as points
            FROM team_stats ts
            JOIN teams t ON ts.team_id = t.id
            JOIN divisions d ON ts.division_id = d.id
            JOIN conferences c ON d.conference_id = c.id
            JOIN leagues l ON c.league_id = l.id
            WHERE t.source_system_id = 1
            ORDER BY d.name, ts.points DESC, goal_differential DESC, t.name
        )";
        
        pqxx::result result = db_->query(query);
        
        // Manually construct JSON array
        std::ostringstream json_data;
        json_data << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json_data << ",";
            first = false;
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"team_name\":\"" << row["team_name"].c_str() << "\","
                << "\"league_name\":\"APSL\","
                << "\"division_name\":\"" << (row["division_name"].is_null() ? "Unknown" : row["division_name"].c_str()) << "\","
                << "\"season\":\"" << (row["season"].is_null() ? "2025-2026" : row["season"].c_str()) << "\","
                << "\"games_played\":" << row["games_played"].as<int>() << ","
                << "\"wins\":" << row["wins"].as<int>() << ","
                << "\"losses\":" << row["losses"].as<int>() << ","
                << "\"ties\":" << row["ties"].as<int>() << ","
                << "\"goals_for\":" << row["goals_for"].as<int>() << ","
                << "\"goals_against\":" << row["goals_against"].as<int>() << ","
                << "\"goal_differential\":" << row["goal_differential"].as<int>() << ","
                << "\"points\":" << row["points"].as<int>()
                << "}";
        }
        json_data << "]";
        
        std::string json_response = createJSONResponse(true, "Standings retrieved successfully", json_data.str());
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting standings: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve standings");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response StatsController::handleGetPlayerStats(const Request& request) {
    try {
        // Query apsl_player_stats - aggregated per-match stats
        std::string query = R"(
            SELECT 
                ap.id,
                ap.name as player_name,
                at.name as team_name,
                ad.name as division_name,
                al.season,
                COUNT(DISTINCT aps.apsl_match_id) as games_played,
                COALESCE(SUM(aps.goals), 0) as goals,
                COALESCE(SUM(aps.assists), 0) as assists,
                COALESCE(SUM(aps.yellow_cards), 0) as yellow_cards,
                COALESCE(SUM(aps.red_cards), 0) as red_cards
            FROM apsl_players ap
            JOIN apsl_teams at ON ap.apsl_team_id = at.id
            JOIN apsl_divisions ad ON at.apsl_division_id = ad.id
            JOIN apsl_conferences ac ON ad.apsl_conference_id = ac.id
            JOIN apsl_leagues al ON ac.apsl_league_id = al.id
            LEFT JOIN apsl_player_stats aps ON ap.id = aps.apsl_player_id
            GROUP BY ap.id, ap.name, at.name, ad.name, al.season
            HAVING COUNT(DISTINCT aps.apsl_match_id) > 0
            ORDER BY goals DESC, assists DESC, player_name
        )";
        
        pqxx::result result = db_->query(query);
        
        // Manually construct JSON array
        std::ostringstream json_data;
        json_data << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json_data << ",";
            first = false;
            
            std::string player_name = escapeJsonString(row["player_name"].c_str());
            std::string team_name = escapeJsonString(row["team_name"].c_str());
            std::string division_name = row["division_name"].is_null() ? "Unknown" : escapeJsonString(row["division_name"].c_str());
            std::string season = row["season"].is_null() ? "2025/2026" : row["season"].c_str();
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"player_name\":\"" << player_name << "\","
                << "\"team_name\":\"" << team_name << "\","
                << "\"league_name\":\"APSL\","
                << "\"division_name\":\"" << division_name << "\","
                << "\"season\":\"" << season << "\","
                << "\"games_played\":" << row["games_played"].as<int>() << ","
                << "\"goals\":" << row["goals"].as<int>() << ","
                << "\"assists\":" << row["assists"].as<int>() << ","
                << "\"yellow_cards\":" << row["yellow_cards"].as<int>() << ","
                << "\"red_cards\":" << row["red_cards"].as<int>()
                << "}";
        }
        json_data << "]";
        
        std::string json_response = createJSONResponse(true, "Player stats retrieved successfully", json_data.str());
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting player stats: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve player stats");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response StatsController::handleGetMatches(const Request& request) {
    try {
        // Query apsl_matches with scores, team names, venue
        std::string query = R"(
            SELECT 
                am.id,
                ht.name as home_team,
                at.name as away_team,
                am.home_score,
                am.away_score,
                am.match_date,
                am.status,
                COALESCE(v.name, 'TBD') as venue_name,
                CASE 
                    WHEN v.google_place_id IS NOT NULL THEN 'https://www.google.com/maps/place/?q=place_id:' || v.google_place_id
                    WHEN v.latitude IS NOT NULL AND v.longitude IS NOT NULL THEN 'https://www.google.com/maps/search/?api=1&query=' || v.latitude::text || ',' || v.longitude::text
                    ELSE ''
                END as google_maps_url
            FROM apsl_matches am
            LEFT JOIN apsl_teams ht ON am.home_team_id = ht.id
            LEFT JOIN apsl_teams at ON am.away_team_id = at.id
            LEFT JOIN venues v ON am.venue_id = v.id
            WHERE am.status = 'completed'
              AND am.match_date >= '2025-09-01'
            ORDER BY am.match_date DESC
        )";
        
        pqxx::result result = db_->query(query);
        
        // Manually construct JSON array
        std::ostringstream json_data;
        json_data << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json_data << ",";
            first = false;
            
            std::string match_date = row["match_date"].is_null() ? "" : row["match_date"].c_str();
            std::string venue_name = row["venue_name"].is_null() ? "" : escapeJsonString(row["venue_name"].c_str());
            std::string google_maps = row["google_maps_url"].is_null() ? "" : escapeJsonString(row["google_maps_url"].c_str());
            std::string home_team = row["home_team"].is_null() ? "" : escapeJsonString(row["home_team"].c_str());
            std::string away_team = row["away_team"].is_null() ? "" : escapeJsonString(row["away_team"].c_str());
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"home_team\":\"" << home_team << "\","
                << "\"away_team\":\"" << away_team << "\","
                << "\"home_score\":" << (row["home_score"].is_null() ? 0 : row["home_score"].as<int>()) << ","
                << "\"away_score\":" << (row["away_score"].is_null() ? 0 : row["away_score"].as<int>()) << ","
                << "\"match_date\":\"" << match_date << "\","
                << "\"status\":\"" << row["status"].c_str() << "\","
                << "\"venue_name\":\"" << venue_name << "\","
                << "\"google_maps_url\":\"" << google_maps << "\""
                << "}";
        }
        json_data << "]";
        
        std::string json_response = createJSONResponse(true, "Matches retrieved successfully", json_data.str());
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting matches: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve matches");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}
