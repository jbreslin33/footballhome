#include "StatsController.h"
#include <sstream>
#include <iostream>
#include <iomanip>

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
        // Calculate team standings from apsl_matches (completed games only)
        std::string query = R"(
            WITH team_stats AS (
                -- Home games
                SELECT 
                    home_team_id as team_id,
                    COUNT(*) as games_played,
                    SUM(CASE 
                        WHEN home_score > away_score THEN 1 
                        ELSE 0 
                    END) as wins,
                    SUM(CASE 
                        WHEN home_score < away_score THEN 1 
                        ELSE 0 
                    END) as losses,
                    SUM(CASE 
                        WHEN home_score = away_score THEN 1 
                        ELSE 0 
                    END) as ties,
                    SUM(home_score) as goals_for,
                    SUM(away_score) as goals_against
                FROM apsl_matches
                WHERE match_status = 'completed' AND home_team_id IS NOT NULL
                GROUP BY home_team_id
                
                UNION ALL
                
                -- Away games
                SELECT 
                    away_team_id as team_id,
                    COUNT(*) as games_played,
                    SUM(CASE 
                        WHEN away_score > home_score THEN 1 
                        ELSE 0 
                    END) as wins,
                    SUM(CASE 
                        WHEN away_score < home_score THEN 1 
                        ELSE 0 
                    END) as losses,
                    SUM(CASE 
                        WHEN away_score = home_score THEN 1 
                        ELSE 0 
                    END) as ties,
                    SUM(away_score) as goals_for,
                    SUM(home_score) as goals_against
                FROM apsl_matches
                WHERE match_status = 'completed' AND away_team_id IS NOT NULL
                GROUP BY away_team_id
            )
            SELECT 
                at.id::text,
                at.name as team_name,
                ad.name as division_name,
                SUM(ts.games_played)::int as games_played,
                SUM(ts.wins)::int as wins,
                SUM(ts.losses)::int as losses,
                SUM(ts.ties)::int as ties,
                SUM(ts.goals_for)::int as goals_for,
                SUM(ts.goals_against)::int as goals_against,
                (SUM(ts.goals_for) - SUM(ts.goals_against))::int as goal_differential,
                (SUM(ts.wins) * 3 + SUM(ts.ties))::int as points
            FROM team_stats ts
            JOIN apsl_teams at ON ts.team_id = at.id
            LEFT JOIN apsl_divisions ad ON at.apsl_division_id = ad.id
            GROUP BY at.id, at.name, ad.name
            ORDER BY ad.name, points DESC, goal_differential DESC, team_name
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
                << "\"season\":\"2025-2026\","
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
        // Query apsl_player_stats with player names from apsl tables
        std::string query = R"(
            SELECT 
                aps.id,
                ap.name as player_name,
                at.name as team_name,
                ad.name as division_name,
                aps.season,
                aps.games_played,
                aps.goals,
                aps.assists,
                aps.yellow_cards,
                aps.red_cards
            FROM apsl_player_stats aps
            JOIN apsl_players ap ON aps.apsl_player_id = ap.id
            JOIN apsl_teams at ON aps.apsl_team_id = at.id
            LEFT JOIN apsl_divisions ad ON aps.apsl_division_id = ad.id
            WHERE aps.season = '2025-2026'
            ORDER BY aps.goals DESC, aps.assists DESC
            LIMIT 100
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
                << "\"player_name\":\"" << row["player_name"].c_str() << "\","
                << "\"team_name\":\"" << row["team_name"].c_str() << "\","
                << "\"league_name\":\"" << (row["division_name"].is_null() ? "APSL" : row["division_name"].c_str()) << "\","
                << "\"season\":\"" << row["season"].c_str() << "\","
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
                am.match_status,
                am.venue_name,
                am.google_maps_url
            FROM apsl_matches am
            LEFT JOIN apsl_teams ht ON am.home_team_id = ht.id
            LEFT JOIN apsl_teams at ON am.away_team_id = at.id
            WHERE am.match_status = 'completed'
            ORDER BY am.match_date DESC
            LIMIT 100
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
            std::string venue_name = row["venue_name"].is_null() ? "" : row["venue_name"].c_str();
            std::string google_maps = row["google_maps_url"].is_null() ? "" : row["google_maps_url"].c_str();
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"home_team\":\"" << (row["home_team"].is_null() ? "" : row["home_team"].c_str()) << "\","
                << "\"away_team\":\"" << (row["away_team"].is_null() ? "" : row["away_team"].c_str()) << "\","
                << "\"home_score\":" << (row["home_score"].is_null() ? 0 : row["home_score"].as<int>()) << ","
                << "\"away_score\":" << (row["away_score"].is_null() ? 0 : row["away_score"].as<int>()) << ","
                << "\"match_date\":\"" << match_date << "\","
                << "\"match_status\":\"" << row["match_status"].c_str() << "\","
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
