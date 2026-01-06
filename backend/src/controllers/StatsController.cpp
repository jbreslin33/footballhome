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
    
    // Get per-match player statistics
    router.get(prefix + "/matches/:id/player-stats", [this](const Request& request) {
        return this->handleGetMatchPlayerStats(request);
    });
    
    // Get raw match events (simple list)
    router.get(prefix + "/matches/:id/events", [this](const Request& request) {
        return this->handleGetMatchEvents(request);
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
        // Query team_season_standings VIEW (calculated from matches)
        std::string query = R"(
            SELECT 
                tss.team_id::text as id,
                tss.team_name,
                tss.division_name,
                '2025-2026' as season,
                tss.games_played,
                tss.wins,
                tss.losses,
                tss.ties,
                tss.goals_for,
                tss.goals_against,
                tss.goal_differential,
                tss.points
            FROM team_season_standings tss
            JOIN teams t ON tss.team_id = t.id
            WHERE t.source_system_id = 1
            ORDER BY tss.division_name, tss.points DESC, tss.goal_differential DESC, tss.team_name
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
        // Query normalized player_stats for APSL (source_system_id=1)
        std::string query = R"(
            SELECT 
                p.id,
                (p.first_name || ' ' || p.last_name) as player_name,
                t.name as team_name,
                d.name as division_name,
                l.season,
                COUNT(DISTINCT ps.match_id) as games_played,
                COALESCE(SUM(ps.goals), 0) as goals,
                COALESCE(SUM(ps.assists), 0) as assists,
                COALESCE(SUM(ps.yellow_cards), 0) as yellow_cards,
                COALESCE(SUM(ps.red_cards), 0) as red_cards
            FROM players p
            JOIN player_stats ps ON p.id = ps.player_id
            JOIN teams t ON ps.team_id = t.id
            JOIN divisions d ON t.division_id = d.id OR ps.match_id IS NOT NULL
            JOIN conferences c ON d.conference_id = c.id
            JOIN leagues l ON c.league_id = l.id
            WHERE t.source_system_id = 1
            GROUP BY p.id, player_name, t.name, d.name, l.season
            HAVING COUNT(DISTINCT ps.match_id) > 0
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
        // Query matches with scores, team names, venue
        std::string query = R"(
            SELECT 
                m.id,
                ht.name as home_team,
                at.name as away_team,
                m.home_score,
                m.away_score,
                m.match_date,
                ms.name as status,
                COALESCE(v.name, 'TBD') as venue_name,
                CASE 
                    WHEN v.google_place_id IS NOT NULL THEN 'https://www.google.com/maps/place/?q=place_id:' || v.google_place_id
                    WHEN v.latitude IS NOT NULL AND v.longitude IS NOT NULL THEN 'https://www.google.com/maps/search/?api=1&query=' || v.latitude::text || ',' || v.longitude::text
                    ELSE ''
                END as google_maps_url,
                (SELECT COUNT(*) FROM match_events me WHERE me.match_id = m.id) as event_count
            FROM matches m
            LEFT JOIN teams ht ON m.home_team_id = ht.id
            LEFT JOIN teams at ON m.away_team_id = at.id
            LEFT JOIN venues v ON m.venue_id = v.id
            LEFT JOIN match_statuses ms ON m.match_status_id = ms.id
            WHERE m.match_status_id = (SELECT id FROM match_statuses WHERE name = 'completed')
              AND m.match_date >= '2025-09-01'
            ORDER BY m.match_date DESC
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
                << "\"status\":\"" << (row["status"].is_null() ? "completed" : row["status"].c_str()) << "\","
                << "\"venue_name\":\"" << venue_name << "\","
                << "\"google_maps_url\":\"" << google_maps << "\","
                << "\"event_count\":" << (row["event_count"].is_null() ? 0 : row["event_count"].as<int>())
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

Response StatsController::handleGetMatchPlayerStats(const Request& request) {
    try {
        // Extract match_id from path: /api/stats/matches/:id/player-stats
        std::string path = request.getPath();
        std::string prefix = "/api/stats/matches/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string match_id = after_prefix.substr(0, slash_pos);
        
        // Query match_events and aggregate per player
        std::string query = R"(
            SELECT 
                p.id,
                (p.first_name || ' ' || p.last_name) as player_name,
                t.name as team_name,
                -- Aggregate events by type
                COUNT(CASE WHEN me.event_type_id = 1 THEN 1 END) as goals,
                COUNT(CASE WHEN me.event_type_id = 2 THEN 1 END) as assists,
                COUNT(CASE WHEN me.event_type_id = 3 THEN 1 END) as yellow_cards,
                COUNT(CASE WHEN me.event_type_id = 4 THEN 1 END) as red_cards,
                -- Get sub minutes
                MIN(CASE WHEN me.event_type_id = 5 THEN me.minute END) as sub_in_minute,
                MIN(CASE WHEN me.event_type_id = 6 THEN me.minute END) as sub_out_minute,
                -- Check if player started (has no sub_in event)
                CASE WHEN COUNT(CASE WHEN me.event_type_id = 5 THEN 1 END) = 0 THEN true ELSE false END as is_starter
            FROM match_events me
            JOIN players p ON me.player_id = p.id
            JOIN teams t ON me.team_id = t.id
            WHERE me.match_id = )" + match_id + R"(
            GROUP BY p.id, player_name, t.name, t.id
            ORDER BY t.name, is_starter DESC, player_name
        )";
        
        pqxx::result result = db_->query(query);
        
        // Manually construct JSON array grouped by team
        std::ostringstream json_data;
        json_data << "{\"teams\":[";
        
        std::string current_team;
        bool first_team = true;
        bool first_player = true;
        
        for (const auto& row : result) {
            std::string team_name = row["team_name"].is_null() ? "Unknown" : escapeJsonString(row["team_name"].c_str());
            std::string player_name = escapeJsonString(row["player_name"].c_str());
            bool is_starter = row["is_starter"].as<bool>();
            
            // Start new team section if team changed
            if (team_name != current_team) {
                if (!first_team) {
                    json_data << "]}"; // Close previous team's players array
                }
                if (!first_team) json_data << ",";
                first_team = false;
                current_team = team_name;
                first_player = true;
                
                json_data << "{\"team_name\":\"" << team_name << "\",\"players\":[";
            }
            
            if (!first_player) json_data << ",";
            first_player = false;
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"player_name\":\"" << player_name << "\","
                << "\"is_starter\":" << (is_starter ? "true" : "false") << ","
                << "\"goals\":" << row["goals"].as<int>() << ","
                << "\"assists\":" << row["assists"].as<int>() << ","
                << "\"yellow_cards\":" << row["yellow_cards"].as<int>() << ","
                << "\"red_cards\":" << row["red_cards"].as<int>() << ","
                << "\"sub_in_minute\":" << (row["sub_in_minute"].is_null() ? "null" : std::to_string(row["sub_in_minute"].as<int>())) << ","
                << "\"sub_out_minute\":" << (row["sub_out_minute"].is_null() ? "null" : std::to_string(row["sub_out_minute"].as<int>()))
                << "}";
        }
        
        if (!first_team) {
            json_data << "]}"; // Close last team's players array
        }
        json_data << "]}"; // Close teams array and root object
        
        std::string json_response = createJSONResponse(true, "Match player stats retrieved successfully", json_data.str());
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting match player stats: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve match player stats");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response StatsController::handleGetMatchEvents(const Request& request) {
    try {
        // Extract match_id from path: /api/stats/matches/:id/events
        std::string path = request.getPath();
        std::string prefix = "/api/stats/matches/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string match_id = after_prefix.substr(0, slash_pos);
        
        // Query raw match_events with player and team names
        std::string query = R"(
            SELECT 
                me.id,
                me.match_id,
                (per.first_name || ' ' || per.last_name) as player_name,
                t.name as team_name,
                met.name as event_type,
                me.minute,
                CASE 
                    WHEN me.assisted_by_player_id IS NOT NULL THEN (aper.first_name || ' ' || aper.last_name)
                    ELSE NULL
                END as assisted_by_player_name
            FROM match_events me
            JOIN players p ON me.player_id = p.id
            JOIN persons per ON p.person_id = per.id
            JOIN teams t ON me.team_id = t.id
            JOIN match_event_types met ON me.event_type_id = met.id
            LEFT JOIN players ap ON me.assisted_by_player_id = ap.id
            LEFT JOIN persons aper ON ap.person_id = aper.id
            WHERE me.match_id = )" + match_id + R"(
            ORDER BY me.minute ASC, me.id
        )";
        
        pqxx::result result = db_->query(query);
        
        // Construct JSON array of raw events
        std::ostringstream json_data;
        json_data << "[";
        bool first = true;
        
        for (const auto& row : result) {
            if (!first) json_data << ",";
            first = false;
            
            std::string player_name = escapeJsonString(row["player_name"].c_str());
            std::string team_name = escapeJsonString(row["team_name"].c_str());
            std::string event_type = escapeJsonString(row["event_type"].c_str());
            std::string assisted_by = row["assisted_by_player_name"].is_null() ? "" : escapeJsonString(row["assisted_by_player_name"].c_str());
            
            json_data << "{"
                << "\"id\":\"" << row["id"].c_str() << "\","
                << "\"match_id\":\"" << row["match_id"].c_str() << "\","
                << "\"player_name\":\"" << player_name << "\","
                << "\"team_name\":\"" << team_name << "\","
                << "\"event_type\":\"" << event_type << "\","
                << "\"minute\":" << row["minute"].as<int>();
            
            if (!assisted_by.empty()) {
                json_data << ",\"assisted_by\":\"" << assisted_by << "\"";
            }
            
            json_data << "}";
        }
        
        json_data << "]";
        
        std::string json_response = createJSONResponse(true, "Match events retrieved successfully", json_data.str());
        return Response(HttpStatus::OK, json_response);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting match events: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve match events");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}
