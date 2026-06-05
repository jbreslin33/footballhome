#include "TeamController.h"
#include <sstream>
#include <regex>
#include <iostream>

TeamController::TeamController() {
    team_model_ = std::make_unique<Team>();
    db_ = Database::getInstance();
}

void TeamController::registerRoutes(Router& router, const std::string& prefix) {
    // Get all teams
    router.get(prefix, [this](const Request& request) {
        return this->handleGetAllTeams(request);
    });
    
    // Get roster statuses (lookup table)
    router.get(prefix + "/roster-statuses", [this](const Request& request) {
        return this->handleGetRosterStatuses(request);
    });
    
    // Get team roster
    router.get(prefix + "/:teamId/roster", [this](const Request& request) {
        return this->handleGetRoster(request);
    });
    
    // Get division standings for a team
    router.get(prefix + "/:teamId/standings", [this](const Request& request) {
        return this->handleGetDivisionStandings(request);
    });
    
    // Update roster member (jersey number, position, captain status, roster status)
    router.put(prefix + "/:teamId/roster/:playerId", [this](const Request& request) {
        return this->handleUpdateRosterMember(request);
    });
    
    // Remove player from roster
    router.del(prefix + "/:teamId/roster/:playerId", [this](const Request& request) {
        return this->handleRemoveRosterMember(request);
    });
    
    // Get team accolades
    router.get(prefix + "/:teamId/accolades", [this](const Request& request) {
        return this->handleGetTeamAccolades(request);
    });

    // Set / clear the team's "live" match pointer (coach pin)
    //   body: { "match_id": <int|null>, "pinned": <bool> }
    //   pinned=true   -> sticky on match_id until unpinned
    //   pinned=false  -> auto-resolve (server picks earliest non-completed match)
    router.put(prefix + "/:teamId/live-match", [this](const Request& request) {
        return this->handleSetLiveMatch(request);
    });

    // GET /api/teams/:teamId/share-info
    //   optional query: ?matchId=<int> to also get visibility flags for that match
    //   returns { slug, live_match_id, live_match_pinned, match: { gameday_hidden, lineup_hidden } }
    router.get(prefix + "/:teamId/share-info", [this](const Request& request) {
        return this->handleGetShareInfo(request);
    });
}

Response TeamController::handleGetRoster(const Request& request) {
    try {
        // Extract team ID from path like "/api/teams/d37eb44b-8e47-0005-9060-f0cbe96fe089/roster"
        std::string team_id = extractTeamIdFromPath(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting roster for team: " << team_id << std::endl;
        
        // Get team roster from database (now includes roster status)
        std::string roster_json = team_model_->getTeamRoster(team_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Team roster retrieved successfully\",";
        json << "\"data\":" << roster_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetRoster error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve team roster");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleGetRosterStatuses(const Request& request) {
    try {
        std::cout << "🔍 Getting roster statuses" << std::endl;
        
        std::string statuses_json = team_model_->getRosterStatuses();
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Roster statuses retrieved successfully\",";
        json << "\"data\":" << statuses_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetRosterStatuses error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve roster statuses");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string TeamController::extractTeamIdFromPath(const std::string& path) {
    // Extract team ID (integer or UUID) from path like "/api/teams/35/roster"
    // or "/api/teams/d37eb44b-8e47-0005-9060-f0cbe96fe089/roster"
    std::regex id_regex(R"(/api/teams/([^/]+)/roster)");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string TeamController::extractPlayerIdFromPath(const std::string& path) {
    // Extract player ID from path like "/api/teams/team-id/roster/player-id"
    std::regex id_regex(R"(/api/teams/[^/]+/roster/([^/]+))");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

Response TeamController::handleUpdateRosterMember(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        std::string player_id = extractPlayerIdFromPath(request.getPath());
        
        if (team_id.empty() || player_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID or player ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔧 Updating roster member: " << player_id << " for team: " << team_id << std::endl;
        
        // Parse request body for updates
        std::string body = request.getBody();
        
        // Simple JSON parsing for jersey_number, position_id, is_captain, is_vice_captain, roster_status_id
        std::string jersey_number = "";
        std::string roster_status_id = "";
        bool is_captain = false;
        bool is_vice_captain = false;
        
        // Parse jersey_number
        std::regex jersey_regex(R"("jerseyNumber"\s*:\s*(\d+|null))");
        std::smatch jersey_match;
        if (std::regex_search(body, jersey_match, jersey_regex)) {
            std::string val = jersey_match[1].str();
            if (val != "null") {
                jersey_number = val;
            }
        }
        
        // Parse roster_status_id
        std::regex status_regex(R"("rosterStatusId"\s*:\s*(\d+))");
        std::smatch status_match;
        if (std::regex_search(body, status_match, status_regex)) {
            roster_status_id = status_match[1].str();
        }
        
        // Parse is_captain
        std::regex captain_regex(R"("isCaptain"\s*:\s*(true|false))");
        std::smatch captain_match;
        if (std::regex_search(body, captain_match, captain_regex)) {
            is_captain = (captain_match[1].str() == "true");
        }
        
        // Parse is_vice_captain  
        std::regex vc_regex(R"("isViceCaptain"\s*:\s*(true|false))");
        std::smatch vc_match;
        if (std::regex_search(body, vc_match, vc_regex)) {
            is_vice_captain = (vc_match[1].str() == "true");
        }

        // Parse firstName
        std::string first_name = "";
        std::regex first_name_regex(R"rx("firstName"\s*:\s*"([^"]+)")rx");
        std::smatch first_name_match;
        if (std::regex_search(body, first_name_match, first_name_regex)) {
            first_name = first_name_match[1].str();
        }

        // Parse lastName
        std::string last_name = "";
        std::regex last_name_regex(R"rx("lastName"\s*:\s*"([^"]+)")rx");
        std::smatch last_name_match;
        if (std::regex_search(body, last_name_match, last_name_regex)) {
            last_name = last_name_match[1].str();
        }
        
        // Update the roster entry
        bool success = team_model_->updateRosterMember(team_id, player_id, jersey_number, 
                                                        is_captain, is_vice_captain, roster_status_id,
                                                        first_name, last_name);
        
        if (success) {
            std::string json = createJSONResponse(true, "Roster member updated successfully");
            return Response(HttpStatus::OK, json);
        } else {
            std::string json = createJSONResponse(false, "Failed to update roster member");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleUpdateRosterMember error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to update roster member");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleRemoveRosterMember(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        std::string player_id = extractPlayerIdFromPath(request.getPath());
        
        if (team_id.empty() || player_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID or player ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🗑️ Removing roster member: " << player_id << " from team: " << team_id << std::endl;
        
        // Deactivate the player (soft delete)
        bool success = team_model_->removeRosterMember(team_id, player_id);
        
        if (success) {
            std::string json = createJSONResponse(true, "Player removed from roster");
            return Response(HttpStatus::OK, json);
        } else {
            std::string json = createJSONResponse(false, "Failed to remove player from roster");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleRemoveRosterMember error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to remove player from roster");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleGetAllTeams(const Request& request) {
    try {
        std::cout << "🔍 Getting all teams" << std::endl;
        
        // Get all teams from database
        std::string teams_json = team_model_->getAllTeams();
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Teams retrieved successfully\",";
        json << "\"data\":" << teams_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetAllTeams error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve teams");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response TeamController::handleGetDivisionStandings(const Request& request) {
    try {
        std::string team_id = extractTeamIdGeneric(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting division standings for team: " << team_id << std::endl;
        
        std::string standings_json = team_model_->getDivisionStandings(team_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Division standings retrieved successfully\",";
        json << "\"data\":" << standings_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetDivisionStandings error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve division standings");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string TeamController::extractTeamIdGeneric(const std::string& path) {
    // Extract team ID from path like "/api/teams/123/standings" or "/api/teams/uuid/standings"
    // Matches any non-slash characters between /teams/ and /standings
    std::regex id_regex(R"(/api/teams/([^/]+)/standings)");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string TeamController::createJSONResponse(bool success, const std::string& message) {
    std::ostringstream json;
    json << "{";
    json << "\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << message << "\"";
    json << "}";
    return json.str();
}

bool TeamController::hasBearerToken(const Request& request) {
    std::string h = request.getHeader("Authorization");
    return !h.empty() && h.substr(0, 7) == "Bearer ";
}

std::string TeamController::extractTeamIdForLiveMatch(const std::string& path) {
    std::regex re(R"(/api/teams/([^/]+)/live-match)");
    std::smatch m;
    if (std::regex_search(path, m, re)) return m[1].str();
    return "";
}

// PUT /api/teams/:teamId/live-match
// body: { match_id: <int|null>, pinned: <bool> }
//   pinned=true  with match_id -> sticky override
//   pinned=false                -> clear override, server auto-resolves
Response TeamController::handleSetLiveMatch(const Request& request) {
    try {
        if (!hasBearerToken(request)) {
            return Response(HttpStatus::UNAUTHORIZED,
                            createJSONResponse(false, "Authentication required"));
        }

        std::string team_id = extractTeamIdForLiveMatch(request.getPath());
        if (team_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                            createJSONResponse(false, "Invalid team id"));
        }

        std::string body = request.getBody();

        // pinned: true | false   (default false)
        bool pinned = false;
        {
            std::regex re(R"("pinned"\s*:\s*(true|false))");
            std::smatch m;
            if (std::regex_search(body, m, re)) pinned = (m[1].str() == "true");
        }

        // match_id: integer or null   (only meaningful when pinned=true)
        std::string match_id_sql_value = "NULL";
        {
            std::regex re(R"("match_id"\s*:\s*(\d+|null))");
            std::smatch m;
            if (std::regex_search(body, m, re) && m[1].str() != "null") {
                match_id_sql_value = m[1].str();
            }
        }

        // If unpinning, always clear the stored match_id so it doesn't linger
        // and accidentally re-stick when someone toggles pinned back on later.
        std::string update_sql;
        if (pinned && match_id_sql_value != "NULL") {
            update_sql =
                "UPDATE teams SET live_match_id = $1::int, live_match_pinned = true "
                "WHERE id = $2::int";
            db_->query(update_sql, {match_id_sql_value, team_id});
        } else {
            update_sql =
                "UPDATE teams SET live_match_id = NULL, live_match_pinned = false "
                "WHERE id = $1::int";
            db_->query(update_sql, {team_id});
        }

        std::ostringstream data;
        data << "{\"team_id\":" << team_id
             << ",\"pinned\":" << (pinned && match_id_sql_value != "NULL" ? "true" : "false")
             << ",\"match_id\":" << (pinned && match_id_sql_value != "NULL" ? match_id_sql_value : "null")
             << "}";
        std::ostringstream out;
        out << "{\"success\":true,\"message\":\"Live match updated\",\"data\":" << data.str() << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "❌ handleSetLiveMatch: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Failed to update live match"));
    }
}

Response TeamController::handleGetTeamAccolades(const Request& request) {
    try {
        // Extract team ID from path like "/api/teams/35/accolades"
        std::regex id_regex(R"(/api/teams/([^/]+)/accolades)");
        std::smatch match;
        std::string path = request.getPath();
        
        if (!std::regex_search(path, match, id_regex) || match[1].str().empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::string team_id = match[1].str();
        std::string accolades_json = team_model_->getTeamAccolades(team_id);
        
        std::ostringstream json;
        json << "{";
        json << "\"success\":true,";
        json << "\"message\":\"Team accolades retrieved successfully\",";
        json << "\"data\":" << accolades_json;
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ TeamController::handleGetTeamAccolades error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve team accolades");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

// GET /api/teams/:teamId/share-info  [?matchId=<int>]
// Returns:
//   { team_id, slug, live_match_id|null, live_match_pinned,
//     match: { id, gameday_hidden, lineup_hidden } | null }
Response TeamController::handleGetShareInfo(const Request& request) {
    try {
        std::string team_id;
        {
            std::regex re(R"(/api/teams/([^/]+)/share-info)");
            std::smatch m;
            std::string path = request.getPath();
            if (std::regex_search(path, m, re)) team_id = m[1].str();
        }
        if (team_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                            createJSONResponse(false, "Invalid team id"));
        }

        std::string match_id = request.getQueryParam("matchId");

        pqxx::result tr = db_->query(
            "SELECT COALESCE(slug,'') AS slug, "
            "       COALESCE(live_match_id, 0) AS live_match_id, "
            "       live_match_pinned "
            "FROM teams WHERE id = $1::int", {team_id});
        if (tr.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                            createJSONResponse(false, "Team not found"));
        }
        std::string slug = tr[0]["slug"].as<std::string>();
        int live_match_id = tr[0]["live_match_id"].as<int>();
        bool pinned       = tr[0]["live_match_pinned"].as<bool>();

        std::string match_json = "null";
        if (!match_id.empty()) {
            pqxx::result mr = db_->query(
                "SELECT id, COALESCE(gameday_hidden,false) AS gh, "
                "       COALESCE(lineup_hidden,true) AS lh "
                "FROM matches WHERE id = $1::int", {match_id});
            if (!mr.empty()) {
                std::ostringstream m;
                m << "{\"id\":" << mr[0]["id"].as<int>()
                  << ",\"gameday_hidden\":" << (mr[0]["gh"].as<bool>() ? "true" : "false")
                  << ",\"lineup_hidden\":"  << (mr[0]["lh"].as<bool>() ? "true" : "false")
                  << "}";
                match_json = m.str();
            }
        }

        std::ostringstream data;
        data << "{\"team_id\":" << team_id
             << ",\"slug\":\"" << slug << "\""
             << ",\"live_match_id\":" << (live_match_id > 0 ? std::to_string(live_match_id) : "null")
             << ",\"live_match_pinned\":" << (pinned ? "true" : "false")
             << ",\"match\":" << match_json
             << "}";

        std::ostringstream out;
        out << "{\"success\":true,\"data\":" << data.str() << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetShareInfo: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Failed to load share info"));
    }
}
