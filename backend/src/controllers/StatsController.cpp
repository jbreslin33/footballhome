#include "StatsController.h"
#include <sstream>
#include <iostream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

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
        auto conn = db_->getConnection();
        pqxx::work txn(*conn);
        
        // Query team_season_stats with team names, ordered by points desc
        std::string query = R"(
            SELECT 
                tss.id,
                t.display_name as team_name,
                l.display_name as league_name,
                ld.display_name as division_name,
                tss.season,
                tss.games_played,
                tss.wins,
                tss.losses,
                tss.ties,
                tss.goals_for,
                tss.goals_against,
                tss.goal_difference,
                tss.points
            FROM team_season_stats tss
            JOIN teams t ON tss.team_id = t.id
            LEFT JOIN leagues l ON tss.league_id = l.id
            LEFT JOIN league_divisions ld ON tss.league_division_id = ld.id
            WHERE tss.season = '2025-2026'
            ORDER BY l.display_name, ld.display_name, tss.points DESC, tss.goal_difference DESC
        )";
        
        pqxx::result result = txn.exec(query);
        txn.commit();
        
        json standings_array = json::array();
        for (const auto& row : result) {
            json standing;
            standing["id"] = row["id"].c_str();
            standing["team_name"] = row["team_name"].c_str();
            standing["league_name"] = row["league_name"].is_null() ? "" : row["league_name"].c_str();
            standing["division_name"] = row["division_name"].is_null() ? "" : row["division_name"].c_str();
            standing["season"] = row["season"].c_str();
            standing["games_played"] = row["games_played"].as<int>();
            standing["wins"] = row["wins"].as<int>();
            standing["losses"] = row["losses"].as<int>();
            standing["ties"] = row["ties"].as<int>();
            standing["goals_for"] = row["goals_for"].as<int>();
            standing["goals_against"] = row["goals_against"].as<int>();
            standing["goal_difference"] = row["goal_difference"].as<int>();
            standing["points"] = row["points"].as<int>();
            standings_array.push_back(standing);
        }
        
        std::string data = standings_array.dump();
        std::string json_response = createJSONResponse(true, "Standings retrieved successfully", data);
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting standings: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve standings");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response StatsController::handleGetPlayerStats(const Request& request) {
    try {
        auto conn = db_->getConnection();
        pqxx::work txn(*conn);
        
        // Query player_season_stats with player names, ordered by goals desc
        std::string query = R"(
            SELECT 
                pss.id,
                p.display_name as player_name,
                t.display_name as team_name,
                l.display_name as league_name,
                pss.season,
                pss.games_played,
                pss.goals,
                pss.assists,
                pss.yellow_cards,
                pss.red_cards
            FROM player_season_stats pss
            JOIN players p ON pss.player_id = p.id
            JOIN teams t ON pss.team_id = t.id
            LEFT JOIN leagues l ON pss.league_id = l.id
            WHERE pss.season = '2025-2026'
            ORDER BY pss.goals DESC, pss.assists DESC
            LIMIT 100
        )";
        
        pqxx::result result = txn.exec(query);
        txn.commit();
        
        json stats_array = json::array();
        for (const auto& row : result) {
            json stat;
            stat["id"] = row["id"].c_str();
            stat["player_name"] = row["player_name"].c_str();
            stat["team_name"] = row["team_name"].c_str();
            stat["league_name"] = row["league_name"].is_null() ? "" : row["league_name"].c_str();
            stat["season"] = row["season"].c_str();
            stat["games_played"] = row["games_played"].as<int>();
            stat["goals"] = row["goals"].as<int>();
            stat["assists"] = row["assists"].as<int>();
            stat["yellow_cards"] = row["yellow_cards"].as<int>();
            stat["red_cards"] = row["red_cards"].as<int>();
            stats_array.push_back(stat);
        }
        
        std::string data = stats_array.dump();
        std::string json_response = createJSONResponse(true, "Player stats retrieved successfully", data);
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting player stats: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve player stats");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response StatsController::handleGetMatches(const Request& request) {
    try {
        auto conn = db_->getConnection();
        pqxx::work txn(*conn);
        
        // Query matches with scores, team names, venue
        std::string query = R"(
            SELECT 
                m.id,
                ht.display_name as home_team,
                at.display_name as away_team,
                m.home_team_score,
                m.away_team_score,
                m.match_date,
                m.match_status,
                v.name as venue_name,
                v.google_maps_url
            FROM matches m
            JOIN teams ht ON m.home_team_id = ht.id
            JOIN teams at ON m.away_team_id = at.id
            LEFT JOIN venues v ON m.venue_id = v.id
            WHERE m.match_status = 'completed'
            ORDER BY m.match_date DESC
            LIMIT 100
        )";
        
        pqxx::result result = txn.exec(query);
        txn.commit();
        
        json matches_array = json::array();
        for (const auto& row : result) {
            json match;
            match["id"] = row["id"].c_str();
            match["home_team"] = row["home_team"].c_str();
            match["away_team"] = row["away_team"].c_str();
            match["home_score"] = row["home_team_score"].is_null() ? 0 : row["home_team_score"].as<int>();
            match["away_score"] = row["away_team_score"].is_null() ? 0 : row["away_team_score"].as<int>();
            match["match_date"] = row["match_date"].is_null() ? "" : row["match_date"].c_str();
            match["match_status"] = row["match_status"].c_str();
            match["venue_name"] = row["venue_name"].is_null() ? "" : row["venue_name"].c_str();
            match["google_maps_url"] = row["google_maps_url"].is_null() ? "" : row["google_maps_url"].c_str();
            matches_array.push_back(match);
        }
        
        std::string data = matches_array.dump();
        std::string json_response = createJSONResponse(true, "Matches retrieved successfully", data);
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting matches: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve matches");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}
