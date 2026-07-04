#include "EventController.h"
#include "../core/Crypto.h"
#include "../database/SqlFileLogger.h"
#include "../database/SqlBuilder.h"
#include <sstream>
#include <regex>
#include <ctime>
#include <iomanip>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <curl/curl.h>
#include <openssl/buffer.h>

EventController::EventController() {
    db_ = Database::getInstance();
}

void EventController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/events - Create new event (practice, match, meeting)
    router.post(prefix, [this](const Request& request) {
        return this->handleCreateEvent(request);
    });
    
    // GET /api/events/team/:teamId - Get events for a team
    router.get(prefix + "/team/:teamId", [this](const Request& request) {
        return this->handleGetEvents(request);
    });
    
    // GET /api/matches/team/:teamId - Get matches for a team
    router.get("/api/matches/team/:teamId", [this](const Request& request) {
        return this->handleGetMatches(request);
    });

    // POST /api/matches/team/:teamId/sync-league - Sync match scores from league website
    router.post("/api/matches/team/:teamId/sync-league", [this](const Request& request) {
        return this->handleSyncLeague(request);
    });
    
    // POST /api/matches - Create new match
    router.post("/api/matches", [this](const Request& request) {
        return this->handleCreateMatch(request);
    });
    
    // GET /api/matches/:matchId - Get single match by ID
    router.get("/api/matches/:matchId", [this](const Request& request) {
        return this->handleGetMatch(request);
    });
    
    // PUT /api/matches/:matchId - Update match
    router.put("/api/matches/:matchId", [this](const Request& request) {
        return this->handleUpdateMatch(request);
    });
    
    // GET /api/matches/:matchId - Delete match
    router.del("/api/matches/:matchId", [this](const Request& request) {
        return this->handleDeleteMatch(request);
    });

    // GET /api/practices/team/:teamId - Get practices for a team
    router.get("/api/practices/team/:teamId", [this](const Request& request) {
        return this->handleGetPractices(request);
    });
    
    // GET /api/events/:eventId - Get single event by ID
    router.get(prefix + "/:eventId", [this](const Request& request) {
        return this->handleGetEvent(request);
    });
    
    // PUT /api/events/:eventId - Update event
    router.put(prefix + "/:eventId", [this](const Request& request) {
        return this->handleUpdateEvent(request);
    });
    
    // DELETE /api/events/:eventId - Delete event
    router.del(prefix + "/:eventId", [this](const Request& request) {
        return this->handleDeleteEvent(request);
    });
    
    // GET /api/venues - Get list of venues
    router.get("/api/venues", [this](const Request& request) {
        return this->handleGetVenues(request);
    });
    
    // POST /api/events/:eventId/rsvp - Create or update RSVP
    router.post(prefix + "/:eventId/rsvp", [this](const Request& request) {
        return this->handleCreateRSVP(request);
    });
    
    // GET /api/events/:eventId/rsvps - Get all RSVPs for an event
    router.get(prefix + "/:eventId/rsvps", [this](const Request& request) {
        return this->handleGetEventRSVPs(request);
    });
    
    // Attendance endpoints
    // GET /api/events/:eventId/attendance - Get attendance for an event
    router.get(prefix + "/:eventId/attendance", [this](const Request& request) {
        return this->handleGetEventAttendance(request);
    });
    
    // PUT /api/attendance/:attendanceId - Update a single attendance record
    router.put("/api/attendance/:attendanceId", [this](const Request& request) {
        return this->handleUpdateAttendance(request);
    });
    
    // GET /api/attendance/statuses - Get all attendance status options
    router.get("/api/attendance/statuses", [this](const Request& request) {
        return this->handleGetAttendanceStatuses(request);
    });
    
    // Game Day Roster endpoints
    // GET /api/matches/:matchId/game-roster - Get game day roster for a match
    router.get("/api/matches/:matchId/game-roster", [this](const Request& request) {
        return this->handleGetGameRoster(request);
    });
    
    // PUT /api/matches/:matchId/game-roster - Update game day roster (set who's on it)
    router.put("/api/matches/:matchId/game-roster", [this](const Request& request) {
        return this->handleUpdateGameRoster(request);
    });

    // PUT /api/matches/:matchId/visibility - Toggle public visibility flags
    //   body: { gameday_hidden?: bool, lineup_hidden?: bool }
    router.put("/api/matches/:matchId/visibility", [this](const Request& request) {
        return this->handleSetMatchVisibility(request);
    });
    
    // POST /api/matches/:matchId/lineup/:playerId - Add player to game day lineup
    router.post("/api/matches/:matchId/lineup/:playerId", [this](const Request& request) {
        return this->handleAddToLineup(request);
    });

    // DELETE /api/matches/:matchId/lineup/:playerId - Remove player from game day lineup
    router.del("/api/matches/:matchId/lineup/:playerId", [this](const Request& request) {
        return this->handleRemoveFromLineup(request);
    });

    // GET /api/matches/:matchId/eligible-players - Get players who RSVP'd attending
    router.get("/api/matches/:matchId/eligible-players", [this](const Request& request) {
        return this->handleGetEligiblePlayers(request);
    });

    // GET /api/matches/:matchId/roster-players - Enriched player data for game day roster
    router.get("/api/matches/:matchId/roster-players", [this](const Request& request) {
        return this->handleGetRosterPlayers(request);
    });

    // PUT /api/matches/:matchId/player-rsvp - Set/override player RSVP for a match
    router.put("/api/matches/:matchId/player-rsvp", [this](const Request& request) {
        return this->handleSetPlayerRSVP(request);
    });

    // GET /api/matches/:matchId/rsvp-summary - Aggregate RSVP + attendance counts
    router.get("/api/matches/:matchId/rsvp-summary", [this](const Request& request) {
        return this->handleGetMatchRsvpSummary(request);
    });
    
    // GET /api/events/club/:clubId/chat-events - Get chat events for a club
    router.get(prefix + "/club/:clubId/chat-events", [this](const Request& request) {
        return this->handleGetClubChatEvents(request);
    });

    // PUT /api/events/chat-rsvps/:rsvpId/override - Override RSVP status
    router.put(prefix + "/chat-rsvps/:rsvpId/override", [this](const Request& request) {
        return this->handleOverrideRSVP(request);
    });

    // PUT /api/events/chat-events/:chatEventId/person-rsvp - Override practice RSVP by person
    router.put(prefix + "/chat-events/:chatEventId/person-rsvp", [this](const Request& request) {
        return this->handleSetPracticeRSVP(request);
    });

}

Response EventController::handleCreateEvent(const Request& request) {
    try {
        std::string body = request.getBody();
        std::cout << "📝 Creating event with body: " << body << std::endl;
        
        // Parse JSON body (simple parsing for required fields)
        std::string team_id = parseJSON(body, "team_id");
        std::string event_type = parseJSON(body, "event_type");
        std::string title = parseJSON(body, "title");
        std::string date = parseJSON(body, "date");
        std::string start_time = parseJSON(body, "start_time");
        std::string end_time = parseJSON(body, "end_time");
        std::string venue_id = parseJSON(body, "venue_id");
        std::string notes = parseJSON(body, "notes");
        
        // Use title or default to "Practice Session"
        if (title.empty()) {
            title = "Practice Session";
        }
        
        // Validate required fields
        if (team_id.empty() || event_type.empty() || date.empty() || start_time.empty()) {
            std::string json = createJSONResponse(false, "Missing required fields: team_id, event_type, date, start_time");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        // Get event_type_id for 'training' (practice)
        std::string event_type_query = 
            "SELECT id FROM event_types WHERE name = 'training' LIMIT 1";
        
        pqxx::result type_result = db_->query(event_type_query);
        if (type_result.empty()) {
            std::string json = createJSONResponse(false, "Event type 'training' not found");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
        std::string event_type_id = type_result[0][0].c_str();
        
        // Get created_by from authenticated user
        std::string created_by = extractUserIdFromToken(request);
        if (created_by.empty()) {
            std::string json = createJSONResponse(false, "Authentication required");
            return Response(HttpStatus::UNAUTHORIZED, json);
        }
        
        // Calculate duration in minutes
        int duration = 90; // Default 90 minutes for practice
        if (!end_time.empty() && !start_time.empty()) {
            // Simple duration calculation (assuming HH:MM format)
            // This is simplified; in production you'd want proper time parsing
            duration = 90; // Keep default for now
        }
        
        // Create timestamp from date and start_time
        std::string event_datetime = date + " " + start_time + ":00";
        
        // Build INSERT query for events table
        // Use database uuid_generate_v4() for reliable UUID generation
        std::string event_query = 
            "INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, created_at, updated_at) "
            "VALUES (uuid_generate_v4(), $1, $2, $3, NULLIF($4, ''), $5, NULLIF($6, '')::uuid, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) "
            "RETURNING id";
        
        std::vector<std::string> event_params = {
            created_by,
            event_type_id,
            title,
            notes,
            event_datetime,
            venue_id,
            std::to_string(duration)
        };
        
        std::cout << "📊 Event query: " << event_query << std::endl;
        
        pqxx::result event_result = db_->query(event_query, event_params);
        if (event_result.empty()) {
            std::cerr << "❌ Failed to create event" << std::endl;
            std::string json = createJSONResponse(false, "Failed to create event");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
        std::string inserted_event_id = event_result[0][0].c_str();
        
        // Log event to ##u/##p file
        std::map<std::string, std::string> event_columns;
        event_columns["created_by"] = created_by;
        event_columns["event_type_id"] = event_type_id;
        event_columns["title"] = title;
        if (!notes.empty()) event_columns["description"] = notes;
        event_columns["event_date"] = event_datetime;
        if (!venue_id.empty()) event_columns["venue_id"] = venue_id;
        event_columns["duration_minutes"] = std::to_string(duration);
        std::string event_upsert = SqlBuilder::buildUpsert("events", inserted_event_id, event_columns, "id");
        SqlFileLogger::log("events", event_upsert);
        
        // Insert into practices table (extends events)
        std::string practice_query = 
            "INSERT INTO practices (id, team_id, notes) "
            "VALUES ($1, $2, NULLIF($3, ''))";
        
        std::cout << "📊 Practice query: " << practice_query << std::endl;
        
        db_->query(practice_query, {inserted_event_id, team_id, notes});
        
        // Log practice to ##u/##p file (OLD SYSTEM - SqlFileLogger)
        std::map<std::string, std::string> practice_columns;
        practice_columns["team_id"] = team_id;
        if (!notes.empty()) practice_columns["notes"] = notes;
        std::string practice_upsert = SqlBuilder::buildUpsert("practices", inserted_event_id, practice_columns, "id");
        SqlFileLogger::log("events", practice_upsert);
        
        // NEW: Persist to environment-specific SQL file for rebuilds
        std::ostringstream file_query;
        file_query << "INSERT INTO practices (id, team_id, notes) VALUES ('" 
                   << inserted_event_id << "', '" << team_id << "', ";
        if (notes.empty()) {
            file_query << "NULL";
        } else {
            file_query << "'" << notes << "'";
        }
        file_query << ");";
        // SQL file writer removed - data persists in database only
        
        std::cout << "✅ Event created successfully: " << inserted_event_id << std::endl;
        
        // Build success response with event data
        std::ostringstream data;
        data << "{";
        data << "\"id\":\"" << inserted_event_id << "\",";
        data << "\"team_id\":\"" << team_id << "\",";
        data << "\"date\":\"" << date << "\",";
        data << "\"start_time\":\"" << start_time << "\"";
        data << "}";
        
        std::string json = createJSONResponse(true, "Practice created successfully", data.str());
        std::cout << "📤 Response JSON: " << json << std::endl;
        return Response(HttpStatus::CREATED, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleCreateEvent error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to create event");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleGetEvents(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting events for team: " << team_id << std::endl;
        
        // Query events for team
        // Show: all upcoming events + events ended within last 8 hours
        // Include has_ended flag so frontend knows whether to show RSVP buttons
        std::ostringstream query;
        query << "SELECT e.id, e.title, e.event_date, e.duration_minutes, et.name as event_type, p.notes, ";
        query << "CASE WHEN (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) < NOW() ";
        query << "THEN true ELSE false END as has_ended ";
        query << "FROM events e ";
        query << "JOIN event_types et ON e.event_type_id = et.id ";
        query << "LEFT JOIN practices p ON e.id = p.id ";
        query << "WHERE p.team_id = '" << team_id << "' ";
        query << "AND (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) > (NOW() - INTERVAL '8 hours') ";
        query << "ORDER BY e.event_date ASC ";
        query << "LIMIT 50";
        
        pqxx::result result = db_->query(query.str());
        
        std::ostringstream events_json;
        events_json << "[";
        
        for (size_t i = 0; i < result.size(); i++) {
            if (i > 0) events_json << ",";
            events_json << "{";
            events_json << "\"id\":\"" << result[i][0].c_str() << "\",";
            events_json << "\"title\":\"" << result[i][1].c_str() << "\",";
            events_json << "\"event_date\":\"" << result[i][2].c_str() << "\",";
            events_json << "\"duration_minutes\":" << result[i][3].c_str() << ",";
            events_json << "\"type\":\"" << result[i][4].c_str() << "\",";
            events_json << "\"has_ended\":" << (result[i][6].as<bool>() ? "true" : "false");
            if (!result[i][5].is_null()) {
                events_json << ",\"notes\":\"" << result[i][5].c_str() << "\"";
            }
            events_json << "}";
        }
        
        events_json << "]";
        
        std::string json = createJSONResponse(true, "Events retrieved successfully", events_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetEvents error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve events");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleGetPractices(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        
        if (team_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Team ID is required"));
        }

        std::string sql = 
            "SELECT "
            "  e.id, "
            "  e.title, "
            "  e.description, "
            "  e.event_date, "
            "  e.duration_minutes, "
            "  e.cancelled, "
            "  e.venue_id, "
            "  v.name as venue_name, "
            "  p.team_id, "
            "  p.focus_areas, "
            "  p.drill_plan "
            "FROM practices p "
            "JOIN events e ON p.id = e.id "
            "LEFT JOIN venues v ON e.venue_id = v.id "
            "WHERE p.team_id = '" + team_id + "' "
            "ORDER BY e.event_date ASC";

        pqxx::result result = db_->query(sql);

        std::ostringstream json;
        json << "[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            
            std::string id = row["id"].as<std::string>();
            std::string title = row["title"].is_null() ? "" : row["title"].as<std::string>();
            std::string description = row["description"].is_null() ? "" : row["description"].as<std::string>();
            std::string event_date = row["event_date"].is_null() ? "" : row["event_date"].as<std::string>();
            int duration = row["duration_minutes"].is_null() ? 90 : row["duration_minutes"].as<int>();
            bool cancelled = row["cancelled"].is_null() ? false : row["cancelled"].as<bool>();
            std::string venue_name = row["venue_name"].is_null() ? "TBD" : row["venue_name"].as<std::string>();
            std::string drill_plan = row["drill_plan"].is_null() ? "" : row["drill_plan"].as<std::string>();
            
            // Handle focus_areas array
            std::string focus_areas = "[]";
            if (!row["focus_areas"].is_null()) {
                std::string raw_array = row["focus_areas"].as<std::string>();
                // Convert {a,b} to ["a","b"] roughly for JSON
                if (raw_array.size() >= 2) {
                    std::string content = raw_array.substr(1, raw_array.size() - 2);
                    focus_areas = "[\"" + content + "\"]"; 
                    size_t pos = 0;
                    while((pos = focus_areas.find(',', pos)) != std::string::npos) {
                        focus_areas.replace(pos, 1, "\",\"");
                        pos += 3;
                    }
                }
            }

            json << "{";
            json << "\"id\":\"" << id << "\",";
            json << "\"title\":\"" << escapeJSON(title) << "\",";
            json << "\"description\":\"" << escapeJSON(description) << "\",";
            json << "\"event_date\":\"" << event_date << "\",";
            json << "\"durationMinutes\":" << duration << ",";
            json << "\"isCancelled\":" << (cancelled ? "true" : "false") << ",";
            json << "\"venue_name\":\"" << escapeJSON(venue_name) << "\",";
            json << "\"drillPlan\":\"" << escapeJSON(drill_plan) << "\",";
            json << "\"focusAreas\":" << focus_areas << ",";
            json << "\"type\":\"practice\"";
            json << "}";
            
            first = false;
        }
        
        json << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Practices retrieved successfully", json.str()));

    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetPractices error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Internal server error"));
    }
}

Response EventController::handleGetMatches(const Request& request) {
    try {
        std::string team_id = extractTeamIdFromPath(request.getPath());
        
        if (team_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid team ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting matches for team: " << team_id << std::endl;
        
        // Matches store date/title/venue inline (no separate events table).
        // Status text is resolved via the match_statuses lookup table.
        std::ostringstream query;
        query << "SELECT m.id, COALESCE(NULLIF(m.title,''), CONCAT(COALESCE(ht.name,'TBD'),' vs ',COALESCE(awt.name,'TBD'))) AS title, ";
        query << "(m.match_date + COALESCE(m.match_time, '00:00'::time))::text AS event_date, ";
        query << "90 AS duration_minutes, 'match' AS event_type, ";
        query << "m.home_score, m.away_score, ";
        query << "COALESCE(ms.name, 'scheduled') AS match_status, ";
        query << "NULL::text AS competition_name, COALESCE(v.name, ce.location) AS venue_name, ";
        query << "CASE WHEN ms.name = 'completed' THEN true ";
        query << "WHEN (m.match_date + COALESCE(m.match_time, '00:00'::time)) < NOW() - INTERVAL '90 minutes' THEN true ";
        query << "ELSE false END AS has_ended, ";
        query << "NULLIF(ht.logo_url, '') AS home_team_logo, ";
        query << "NULLIF(awt.logo_url, '') AS away_team_logo, ";
        query << "ht.id AS home_team_id, awt.id AS away_team_id, ";
        query << "ce.image_url AS calendar_image_url, ";
        query << "COALESCE(ss.name, '') AS source_name, ";
        query << "m.source_system_id, ";
        query << "COALESCE(NULLIF(v.address,''), NULLIF(ce.location_address,'')) AS venue_address, ";
        query << "m.match_type_id, ";
        query << "COALESCE(m.end_time::text, '') AS end_time ";
        query << "FROM matches m ";
        query << "LEFT JOIN match_statuses ms ON ms.id = m.match_status_id ";
        query << "LEFT JOIN venues v ON v.id = m.venue_id ";
        query << "LEFT JOIN teams ht ON m.home_team_id = ht.id ";
        query << "LEFT JOIN teams awt ON m.away_team_id = awt.id ";
        query << "LEFT JOIN chat_events ce ON ce.match_id = m.id ";
        query << "  AND ce.chat_id = (SELECT id FROM chats WHERE team_id = $1::int LIMIT 1) ";
        query << "LEFT JOIN source_systems ss ON ss.id = m.source_system_id ";
        query << "WHERE (m.home_team_id = $1 OR m.away_team_id = $1 OR m.home_team_id = $1::int) ";
        query << "ORDER BY m.match_date DESC, m.match_time DESC NULLS LAST ";
        query << "LIMIT 100";
        
        pqxx::result result;
        result = db_->query(query.str(), {team_id});
        
        std::ostringstream matches_json;
        matches_json << "[";
        
        for (size_t i = 0; i < result.size(); i++) {
            if (i > 0) matches_json << ",";
            matches_json << "{";
            matches_json << "\"id\":\"" << result[i][0].c_str() << "\",";
            matches_json << "\"title\":\"" << escapeJSON(result[i][1].c_str()) << "\",";
            matches_json << "\"event_date\":\"" << result[i][2].c_str() << "\",";
            matches_json << "\"duration_minutes\":" << result[i][3].c_str() << ",";
            matches_json << "\"type\":\"" << result[i][4].c_str() << "\",";
            matches_json << "\"has_ended\":" << (result[i][10].as<bool>() ? "true" : "false");
            
            // Add match-specific fields
            if (!result[i][5].is_null()) {
                matches_json << ",\"home_team_score\":" << result[i][5].c_str();
            }
            if (!result[i][6].is_null()) {
                matches_json << ",\"away_team_score\":" << result[i][6].c_str();
            }
            if (!result[i][7].is_null()) {
                matches_json << ",\"match_status\":\"" << result[i][7].c_str() << "\"";
            }
            if (!result[i][8].is_null()) {
                matches_json << ",\"competition_name\":\"" << escapeJSON(result[i][8].c_str()) << "\"";
            }
            if (!result[i][9].is_null()) {
                matches_json << ",\"venue_name\":\"" << escapeJSON(result[i][9].c_str()) << "\"";
            }
            if (!result[i][11].is_null()) {
                matches_json << ",\"home_team_logo\":\"" << escapeJSON(result[i][11].c_str()) << "\"";
            }
            if (!result[i][12].is_null()) {
                matches_json << ",\"away_team_logo\":\"" << escapeJSON(result[i][12].c_str()) << "\"";
            }
            if (!result[i][13].is_null()) {
                matches_json << ",\"home_team_id\":" << result[i][13].c_str();
            }
            if (!result[i][14].is_null()) {
                matches_json << ",\"away_team_id\":" << result[i][14].c_str();
            }
            if (!result[i][15].is_null()) {
                matches_json << ",\"calendar_image_url\":\"" << escapeJSON(result[i][15].c_str()) << "\"";
            }
            if (!result[i][16].is_null() && result[i][16].c_str()[0] != '\0') {
                matches_json << ",\"source_name\":\"" << escapeJSON(result[i][16].c_str()) << "\"";
            }
            if (!result[i][17].is_null()) {
                matches_json << ",\"source_system_id\":" << result[i][17].c_str();
            }
            if (result.columns() > 18 && !result[i][18].is_null()) {
                matches_json << ",\"venue_address\":\"" << escapeJSON(result[i][18].c_str()) << "\"";
            }
            if (result.columns() > 19 && !result[i][19].is_null()) {
                matches_json << ",\"match_type_id\":" << result[i][19].c_str();
            }
            if (result.columns() > 20 && !result[i][20].is_null() && result[i][20].c_str()[0] != '\0') {
                matches_json << ",\"end_time\":\"" << result[i][20].c_str() << "\"";
            }
            
            matches_json << "}";
        }
        
        matches_json << "]";
        
        std::string json = createJSONResponse(true, "Matches retrieved successfully", matches_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetMatches error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve matches");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleCreateMatch(const Request& request) {
    try {
        std::string body = request.getBody();
        std::cout << "📝 Creating match with body: " << body << std::endl;
        
        // Parse JSON body
        std::string home_team_id = parseJSON(body, "home_team_id");
        std::string away_team_id = parseJSON(body, "away_team_id");
        std::string title = parseJSON(body, "title");
        std::string date = parseJSON(body, "date");
        std::string start_time = parseJSON(body, "start_time");
        std::string venue_id = parseJSON(body, "venue_id");
        std::string competition_name = parseJSON(body, "competition_name");
        std::string match_status = parseJSON(body, "match_status");
        std::string notes = parseJSON(body, "notes");
        
        // Validate required fields
        if (home_team_id.empty() || away_team_id.empty() || title.empty() || date.empty() || start_time.empty()) {
            std::string json = createJSONResponse(false, "Missing required fields: home_team_id, away_team_id, title, date, start_time");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        // Get event_type_id for 'match'
        std::string event_type_query = "SELECT id FROM event_types WHERE name = 'match' LIMIT 1";
        pqxx::result type_result = db_->query(event_type_query);
        if (type_result.empty()) {
            std::string json = createJSONResponse(false, "Event type 'match' not found");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        std::string event_type_id = type_result[0][0].c_str();
        
        // Get created_by user (for now, use the system admin user)
        std::string created_by = "77d77471-1250-47e0-81ab-d4626595d63c";
        
        // Create timestamp from date and start_time
        std::string event_datetime = date + " " + start_time + ":00";
        
        // Get home_away_status_id (home)
        std::string home_status_query = "SELECT id FROM home_away_statuses WHERE name = 'home' LIMIT 1";
        pqxx::result home_status_result = db_->query(home_status_query);
        std::string home_away_status_id = home_status_result.empty() ? "550e8400-e29b-41d4-a716-446655440801" : home_status_result[0][0].c_str();
        
        // Build INSERT query for events table
        std::string event_query = 
            "INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, created_at, updated_at) "
            "VALUES (uuid_generate_v4(), $1, $2, $3, NULLIF($4, ''), $5, NULLIF($6, '')::uuid, 120, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) "
            "RETURNING id";
        
        std::vector<std::string> event_params = {
            created_by,
            event_type_id,
            title,
            notes,
            event_datetime,
            venue_id
        };
        
        std::cout << "📊 Event query: " << event_query << std::endl;
        
        pqxx::result event_result = db_->query(event_query, event_params);
        if (event_result.empty()) {
            std::cerr << "❌ Failed to create event" << std::endl;
            std::string json = createJSONResponse(false, "Failed to create event");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
        std::string inserted_event_id = event_result[0][0].c_str();
        
        // Log event to ##u/##p file
        std::map<std::string, std::string> event_columns;
        event_columns["created_by"] = created_by;
        event_columns["event_type_id"] = event_type_id;
        event_columns["title"] = title;
        if (!notes.empty()) event_columns["description"] = notes;
        event_columns["event_date"] = event_datetime;
        if (!venue_id.empty()) event_columns["venue_id"] = venue_id;
        event_columns["duration_minutes"] = "120";
        std::string event_upsert = SqlBuilder::buildUpsert("events", inserted_event_id, event_columns, "id");
        SqlFileLogger::log("events", event_upsert);
        
        // Insert into matches table (extends events)
        std::string match_query = 
            "INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status) "
            "VALUES ($1, $2, $3, $4, NULLIF($5, ''), $6)";
        
        std::vector<std::string> match_params = {
            inserted_event_id,
            home_team_id,
            away_team_id,
            home_away_status_id,
            competition_name,
            match_status.empty() ? "scheduled" : match_status
        };
        
        std::cout << "📊 Match query: " << match_query << std::endl;
        
        db_->query(match_query, match_params);
        
        // Log match to ##u/##p file
        std::map<std::string, std::string> match_columns;
        match_columns["home_team_id"] = home_team_id;
        match_columns["away_team_id"] = away_team_id;
        match_columns["home_away_status_id"] = home_away_status_id;
        if (!competition_name.empty()) match_columns["competition_name"] = competition_name;
        match_columns["match_status"] = match_status.empty() ? "scheduled" : match_status;
        std::string match_upsert = SqlBuilder::buildUpsert("matches", inserted_event_id, match_columns, "id");
        SqlFileLogger::log("matches", match_upsert);
        
        std::ostringstream result_json;
        result_json << "{\"id\":\"" << inserted_event_id << "\"}";
        
        std::string json = createJSONResponse(true, "Match created successfully", result_json.str());
        return Response(HttpStatus::CREATED, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleCreateMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to create match");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleGetMatch(const Request& request) {
    try {
        std::string match_id = extractMatchIdFromPath(request.getPath());
        if (match_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid match ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting match: " << match_id << std::endl;
        
        // Query single match with all details
        // matches extends events via matches.id = events.id FK
        std::ostringstream query;
        query << "SELECT m.id, COALESCE(NULLIF(m.title,''), CONCAT(COALESCE(ht.name,'TBD'),' vs ',COALESCE(awt.name,'TBD'))) as title, ";
        query << "(m.match_date + COALESCE(m.match_time, '00:00'::time))::text as event_date, ";
        query << "90 as duration_minutes, m.venue_id, ";
        query << "m.home_team_id, m.away_team_id, UPPER(COALESCE(ss.name, '')) as competition_name, ";
        query << "COALESCE(ms.name, 'scheduled') as match_status, ";
        query << "m.home_score, m.away_score, ";
        query << "m.description as notes, ";
        query << "v.name as venue_name, ";
        query << "ht.name as home_team_name, awt.name as away_team_name, ";
        query << "ht.logo_url as home_team_logo, awt.logo_url as away_team_logo, ";
        query << "COALESCE(ss.name, '') as source_name, ";
        query << "v.address as venue_address, v.city as venue_city, v.state as venue_state, '' as venue_zip, ";
        query << "mt.name as division_name, ";
        query << "ce.image_url AS calendar_image_url ";
        query << "FROM matches m ";
        query << "LEFT JOIN match_statuses ms ON ms.id = m.match_status_id ";
        query << "LEFT JOIN match_types mt ON mt.id = m.match_type_id ";
        query << "LEFT JOIN source_systems ss ON m.source_system_id = ss.id ";
        query << "LEFT JOIN venues v ON v.id = m.venue_id ";
        query << "LEFT JOIN teams ht ON m.home_team_id = ht.id ";
        query << "LEFT JOIN teams awt ON m.away_team_id = awt.id ";
        query << "LEFT JOIN LATERAL (SELECT image_url FROM chat_events WHERE match_id = m.id LIMIT 1) ce ON true ";
        query << "WHERE m.id = '" << match_id << "'";
        
        pqxx::result result = db_->query(query.str());
        
        if (result.empty()) {
            std::string json = createJSONResponse(false, "Match not found");
            return Response(HttpStatus::NOT_FOUND, json);
        }
        
        // Build JSON for single match
        std::ostringstream match_json;
        match_json << "{";
        match_json << "\"id\":\"" << result[0][0].c_str() << "\",";
        match_json << "\"title\":\"" << escapeJSON(result[0][1].c_str()) << "\",";
        match_json << "\"event_date\":\"" << result[0][2].c_str() << "\",";
        match_json << "\"duration_minutes\":" << result[0][3].c_str() << ",";
        
        if (!result[0][4].is_null()) {
            match_json << "\"venue_id\":\"" << result[0][4].c_str() << "\",";
        }
        
        match_json << "\"home_team_id\":\"" << result[0][5].c_str() << "\",";
        match_json << "\"away_team_id\":\"" << result[0][6].c_str() << "\"";
        
        if (!result[0][7].is_null()) {
            match_json << ",\"competition_name\":\"" << escapeJSON(result[0][7].c_str()) << "\"";
        }
        if (!result[0][8].is_null()) {
            match_json << ",\"match_status\":\"" << result[0][8].c_str() << "\"";
        }
        if (!result[0][9].is_null()) {
            match_json << ",\"home_team_score\":" << result[0][9].c_str();
        }
        if (!result[0][10].is_null()) {
            match_json << ",\"away_team_score\":" << result[0][10].c_str();
        }
        if (!result[0][11].is_null()) {
            match_json << ",\"notes\":\"" << escapeJSON(result[0][11].c_str()) << "\"";
        }
        if (!result[0][12].is_null()) {
            match_json << ",\"venue_name\":\"" << escapeJSON(result[0][12].c_str()) << "\"";
        }
        if (!result[0][13].is_null()) {
            match_json << ",\"home_team_name\":\"" << escapeJSON(result[0][13].c_str()) << "\"";
        }
        if (!result[0][14].is_null()) {
            match_json << ",\"away_team_name\":\"" << escapeJSON(result[0][14].c_str()) << "\"";
        }
        if (!result[0][15].is_null()) {
            match_json << ",\"home_team_logo\":\"" << escapeJSON(result[0][15].c_str()) << "\"";
        }
        if (!result[0][16].is_null()) {
            match_json << ",\"away_team_logo\":\"" << escapeJSON(result[0][16].c_str()) << "\"";
        }
        if (!result[0][17].is_null()) {
            match_json << ",\"source_name\":\"" << escapeJSON(result[0][17].c_str()) << "\"";
        }
        if (!result[0][18].is_null()) {
            match_json << ",\"venue_address\":\"" << escapeJSON(result[0][18].c_str()) << "\"";
        }
        if (!result[0][19].is_null()) {
            match_json << ",\"venue_city\":\"" << escapeJSON(result[0][19].c_str()) << "\"";
        }
        if (!result[0][20].is_null()) {
            match_json << ",\"venue_state\":\"" << escapeJSON(result[0][20].c_str()) << "\"";
        }
        if (!result[0][21].is_null()) {
            match_json << ",\"venue_zip\":\"" << escapeJSON(result[0][21].c_str()) << "\"";
        }
        if (!result[0][22].is_null()) {
            match_json << ",\"division_name\":\"" << escapeJSON(result[0][22].c_str()) << "\"";
        }
        if (!result[0][23].is_null()) {
            match_json << ",\"calendar_image_url\":\"" << escapeJSON(result[0][23].c_str()) << "\"";
        }
        
        match_json << "}";
        
        std::string json = createJSONResponse(true, "Match retrieved successfully", match_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve match");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleUpdateMatch(const Request& request) {
    try {
        std::string match_id = extractMatchIdFromPath(request.getPath());
        if (match_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid match ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::string body = request.getBody();
        std::cout << "📝 Updating match " << match_id << " with body: " << body << std::endl;
        
        // Parse JSON body
        std::string home_team_id = parseJSON(body, "home_team_id");
        std::string away_team_id = parseJSON(body, "away_team_id");
        std::string title = parseJSON(body, "title");
        std::string date = parseJSON(body, "date");
        std::string start_time = parseJSON(body, "start_time");
        std::string venue_id = parseJSON(body, "venue_id");
        std::string competition_name = parseJSON(body, "competition_name");
        std::string match_status = parseJSON(body, "match_status");
        std::string home_team_score = parseJSON(body, "home_team_score");
        std::string away_team_score = parseJSON(body, "away_team_score");
        std::string notes = parseJSON(body, "notes");
        
        // Update events table
        std::string event_update = 
            "UPDATE events SET "
            "title = $1, "
            "event_date = $2, "
            "venue_id = NULLIF($3, '')::uuid, "
            "description = NULLIF($4, ''), "
            "updated_at = CURRENT_TIMESTAMP "
            "WHERE id = $5";
        
        std::vector<std::string> event_params = {
            title,
            date + " " + start_time + ":00",
            venue_id,
            notes,
            match_id
        };
        
        db_->query(event_update, event_params);
        
        // Log event update to ##u/##p file
        std::map<std::string, std::string> event_columns;
        event_columns["title"] = title;
        event_columns["event_date"] = date + " " + start_time + ":00";
        if (!venue_id.empty()) event_columns["venue_id"] = venue_id;
        if (!notes.empty()) event_columns["description"] = notes;
        std::string event_upsert = SqlBuilder::buildUpsert("events", match_id, event_columns, "id");
        SqlFileLogger::log("events", event_upsert);
        
        // Update matches table
        std::string match_update = 
            "UPDATE matches SET "
            "home_team_id = $1, "
            "away_team_id = $2, "
            "competition_name = NULLIF($3, ''), "
            "match_status = $4";
        
        std::vector<std::string> match_params = {
            home_team_id,
            away_team_id,
            competition_name,
            match_status.empty() ? "scheduled" : match_status
        };
        
        if (!home_team_score.empty()) {
            match_update += ", home_team_score = $" + std::to_string(match_params.size() + 1);
            match_params.push_back(home_team_score);
        }
        if (!away_team_score.empty()) {
            match_update += ", away_team_score = $" + std::to_string(match_params.size() + 1);
            match_params.push_back(away_team_score);
        }
        
        match_update += " WHERE id = $" + std::to_string(match_params.size() + 1);
        match_params.push_back(match_id);
        
        db_->query(match_update, match_params);
        
        // Log match update to ##u/##p file
        std::map<std::string, std::string> match_columns;
        match_columns["home_team_id"] = home_team_id;
        match_columns["away_team_id"] = away_team_id;
        if (!competition_name.empty()) match_columns["competition_name"] = competition_name;
        match_columns["match_status"] = match_status.empty() ? "scheduled" : match_status;
        if (!home_team_score.empty()) match_columns["home_team_score"] = home_team_score;
        if (!away_team_score.empty()) match_columns["away_team_score"] = away_team_score;
        std::string match_upsert = SqlBuilder::buildUpsert("matches", match_id, match_columns, "id");
        SqlFileLogger::log("matches", match_upsert);
        
        std::string json = createJSONResponse(true, "Match updated successfully");
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleUpdateMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to update match");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleDeleteMatch(const Request& request) {
    try {
        std::string match_id = extractMatchIdFromPath(request.getPath());
        if (match_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid match ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }

        // Validate: match_id must be a positive integer.  Guards against
        // SQL injection since we interpolate below (Db_.query does not
        // accept parameterised DELETEs in the current binding).
        for (char c : match_id) {
            if (c < '0' || c > '9') {
                std::string json = createJSONResponse(false, "Invalid match ID format");
                return Response(HttpStatus::BAD_REQUEST, json);
            }
        }

        std::cout << "🗑️ Deleting match: " << match_id << std::endl;

        // Null out chat_events.match_id first — the FK from chat_events
        // → matches is NO ACTION (chat is the source-of-truth for
        // practices/pickups; the matches row is materialised by the
        // chat_event_create_match trigger).  Setting to NULL detaches
        // the chat row from the (about-to-be-deleted) match without
        // deleting the chat message itself.
        db_->query("UPDATE chat_events SET match_id = NULL WHERE match_id = " + match_id);

        // Detach teams.live_match_id references (FK is SET NULL but be
        // explicit for clarity in logs).  Most other FK refs
        // (match_lineups, match_events, training_attendance, etc.)
        // cascade delete automatically.
        db_->query("UPDATE teams SET live_match_id = NULL WHERE live_match_id = " + match_id);

        // Delete the match row.  Everything else cascades.  NOTE: this
        // schema has NO `events` table — all match/practice/pickup data
        // lives in `matches` (the C++ port carried over a stale
        // events-table dual-write from an earlier schema).
        db_->query("DELETE FROM matches WHERE id = " + match_id);

        std::string json = createJSONResponse(true, "Match deleted successfully");
        return Response(HttpStatus::OK, json);

    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleDeleteMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, std::string("Failed to delete match: ") + e.what());
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleGetEvent(const Request& request) {
    try {
        // Extract event ID from path
        std::string event_id = extractEventIdFromPath(request.getPath());
        if (event_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid event ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🔍 Getting event: " << event_id << std::endl;
        
        // Query single event with venue info
        std::ostringstream query;
        query << "SELECT e.id, e.title, e.event_date, e.duration_minutes, e.venue_id, ";
        query << "et.name as event_type, p.notes ";
        query << "FROM events e ";
        query << "JOIN event_types et ON e.event_type_id = et.id ";
        query << "LEFT JOIN practices p ON e.id = p.id ";
        query << "WHERE e.id = '" << event_id << "'";
        
        pqxx::result result = db_->query(query.str());
        
        if (result.empty()) {
            std::string json = createJSONResponse(false, "Event not found");
            return Response(HttpStatus::NOT_FOUND, json);
        }
        
        // Parse event_date to extract date and time separately
        std::string event_date_str = result[0][2].c_str();
        std::string date_part = event_date_str.substr(0, 10); // YYYY-MM-DD
        std::string time_part = event_date_str.substr(11, 5); // HH:MM
        
        // Build JSON for single event
        std::ostringstream event_json;
        event_json << "{";
        event_json << "\"id\":\"" << result[0][0].c_str() << "\",";
        event_json << "\"title\":\"" << result[0][1].c_str() << "\",";
        event_json << "\"date\":\"" << date_part << "\",";
        event_json << "\"time\":\"" << time_part << "\",";
        event_json << "\"event_date\":\"" << event_date_str << "\",";
        event_json << "\"duration_minutes\":" << result[0][3].c_str() << ",";
        event_json << "\"venue_id\":\"" << (result[0][4].is_null() ? "" : result[0][4].c_str()) << "\",";
        event_json << "\"type\":\"" << result[0][5].c_str() << "\"";
        if (!result[0][6].is_null()) {
            event_json << ",\"notes\":\"" << result[0][6].c_str() << "\"";
        }
        event_json << "}";
        
        std::string json = createJSONResponse(true, "Event retrieved successfully", event_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetEvent error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve event");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleGetVenues(const Request& request) {
    try {
        std::cout << "🔍 Getting venues list" << std::endl;
        
        // Query active venues
        std::string query = 
            "SELECT id, name, formatted_address, city, state, venue_type, surface_type, rating "
            "FROM venues "
            "WHERE is_active = true "
            "ORDER BY name ASC "
            "LIMIT 200";
        
        pqxx::result result = db_->query(query);
        
        std::ostringstream venues_json;
        venues_json << "[";
        
        for (size_t i = 0; i < result.size(); i++) {
            if (i > 0) venues_json << ",";
            venues_json << "{";
            venues_json << "\"id\":\"" << result[i][0].c_str() << "\",";
            venues_json << "\"name\":\"" << escapeJSON(result[i][1].c_str()) << "\",";
            venues_json << "\"address\":\"" << (result[i][2].is_null() ? "" : escapeJSON(result[i][2].c_str())) << "\",";
            venues_json << "\"city\":\"" << (result[i][3].is_null() ? "" : escapeJSON(result[i][3].c_str())) << "\",";
            venues_json << "\"state\":\"" << (result[i][4].is_null() ? "" : result[i][4].c_str()) << "\",";
            venues_json << "\"type\":\"" << (result[i][5].is_null() ? "" : result[i][5].c_str()) << "\",";
            venues_json << "\"surface\":\"" << (result[i][6].is_null() ? "" : result[i][6].c_str()) << "\"";
            if (!result[i][7].is_null()) {
                venues_json << ",\"rating\":\"" << result[i][7].c_str() << "\"";
            }
            venues_json << "}";
        }
        
        venues_json << "]";
        
        std::cout << "✅ Retrieved " << result.size() << " venues" << std::endl;
        
        std::string json = createJSONResponse(true, "Venues retrieved successfully", venues_json.str());
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleGetVenues error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to retrieve venues");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleUpdateEvent(const Request& request) {
    try {
        std::string event_id = extractEventIdFromPath(request.getPath());
        
        if (event_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid event ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::string body = request.getBody();
        std::cout << "✏️ Updating event " << event_id << " with body: " << body << std::endl;
        
        // Parse request body
        std::string title = parseJSON(body, "title");
        std::string date = parseJSON(body, "date");
        std::string start_time = parseJSON(body, "start_time");
        std::string end_time = parseJSON(body, "end_time");
        std::string venue_id = parseJSON(body, "venue_id");
        std::string notes = parseJSON(body, "notes");
        
        if (date.empty() || start_time.empty()) {
            std::string json = createJSONResponse(false, "Missing required fields");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        // Combine date and time
        std::string event_datetime = date + " " + start_time;
        
        // Calculate duration in minutes (if end_time provided)
        int duration = 90; // Default to 90 minutes if no end_time
        if (!end_time.empty()) {
            int start_hour = std::stoi(start_time.substr(0, 2));
            int start_min = std::stoi(start_time.substr(3, 2));
            int end_hour = std::stoi(end_time.substr(0, 2));
            int end_min = std::stoi(end_time.substr(3, 2));
            duration = (end_hour * 60 + end_min) - (start_hour * 60 + start_min);
        }
        
        // Update events table
        std::string query = 
            "UPDATE events SET "
            "title = COALESCE(NULLIF($1, ''), title), "
            "event_date = $2, "
            "duration_minutes = $3, "
            "venue_id = NULLIF($4, '')::uuid, "
            "updated_at = CURRENT_TIMESTAMP "
            "WHERE id = $5";
        
        std::vector<std::string> params = {
            title,
            event_datetime,
            std::to_string(duration),
            venue_id,
            event_id
        };
        
        std::cout << "📊 Update query: " << query << std::endl;
        
        pqxx::result result = db_->query(query, params);
        
        // Log event update to ##u/##p file
        std::map<std::string, std::string> event_columns;
        if (!title.empty()) event_columns["title"] = title;
        event_columns["event_date"] = event_datetime;
        event_columns["duration_minutes"] = std::to_string(duration);
        if (!venue_id.empty()) event_columns["venue_id"] = venue_id;
        std::string event_upsert = SqlBuilder::buildUpsert("events", event_id, event_columns, "id");
        SqlFileLogger::log("events", event_upsert);
        
        // Update practices table notes
        std::string practice_query = 
            "UPDATE practices SET "
            "notes = NULLIF($1, '') "
            "WHERE id = $2";
        
        db_->query(practice_query, {notes, event_id});
        
        // Log practice update to ##u/##p file
        if (!notes.empty()) {
            std::map<std::string, std::string> practice_columns;
            practice_columns["notes"] = notes;
            std::string practice_upsert = SqlBuilder::buildUpsert("practices", event_id, practice_columns, "id");
            SqlFileLogger::log("events", practice_upsert);
        }
        
        std::cout << "✅ Event updated successfully: " << event_id << std::endl;
        
        std::string json = createJSONResponse(true, "Practice updated successfully");
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleUpdateEvent error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to update event");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

Response EventController::handleDeleteEvent(const Request& request) {
    try {
        std::string event_id = extractEventIdFromPath(request.getPath());
        
        if (event_id.empty()) {
            std::string json = createJSONResponse(false, "Invalid event ID in path");
            return Response(HttpStatus::BAD_REQUEST, json);
        }
        
        std::cout << "🗑️ Deleting event: " << event_id << std::endl;
        
        // Delete from practices table first (foreign key)
        std::ostringstream practice_query;
        practice_query << "DELETE FROM practices WHERE id = '" << event_id << "'";
        
        db_->query(practice_query.str());
        
        // Delete from events table
        std::ostringstream event_query;
        event_query << "DELETE FROM events WHERE id = '" << event_id << "'";
        
        db_->query(event_query.str());
        
        std::cout << "✅ Event deleted successfully: " << event_id << std::endl;
        
        std::string json = createJSONResponse(true, "Practice deleted successfully");
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleDeleteEvent error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to delete event");
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
    }
}

std::string EventController::extractTeamIdFromPath(const std::string& path) {
    // Match /api/events/team/:teamId, /api/matches/team/:teamId, and /api/practices/team/:teamId
    // Support both UUID and numeric team IDs
    std::regex id_regex(R"(/api/(events|matches|practices)/team/([a-f0-9-]{36}|\d+))");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[2].str();  // Return second capture group (team ID)
    }
    
    return "";
}

std::string EventController::extractEventIdFromPath(const std::string& path) {
    // Extract event ID from paths like /api/events/:eventId
    // Support both UUID and numeric IDs
    std::regex id_regex(R"(/api/events/([a-f0-9-]{36}|\d+))");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string EventController::extractMatchIdFromPath(const std::string& path) {
    // Extract match ID from paths like /api/matches/:matchId/...
    // Support both UUID and numeric IDs
    std::regex id_regex(R"(/api/matches/([a-f0-9-]{36}|\d+))");
    std::smatch match;
    
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    
    return "";
}

// PUT /api/matches/:matchId/visibility
// body: { "gameday_hidden": bool, "lineup_hidden": bool }  (either may be omitted)
Response EventController::handleSetMatchVisibility(const Request& request) {
    try {
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            return Response(HttpStatus::UNAUTHORIZED,
                            createJSONResponse(false, "Authentication required"));
        }

        std::string match_id = extractMatchIdFromPath(request.getPath());
        if (match_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                            createJSONResponse(false, "Invalid match id"));
        }

        const std::string& body = request.getBody();

        auto extract_bool = [&](const std::string& key, bool& out) -> bool {
            std::regex re("\"" + key + "\"\\s*:\\s*(true|false)");
            std::smatch m;
            if (std::regex_search(body, m, re)) {
                out = (m[1].str() == "true");
                return true;
            }
            return false;
        };

        bool gameday_hidden = false, lineup_hidden = false;
        bool has_gameday = extract_bool("gameday_hidden", gameday_hidden);
        bool has_lineup  = extract_bool("lineup_hidden",  lineup_hidden);

        if (!has_gameday && !has_lineup) {
            return Response(HttpStatus::BAD_REQUEST,
                            createJSONResponse(false, "No visibility fields provided"));
        }

        std::ostringstream sql;
        sql << "UPDATE matches SET ";
        std::vector<std::string> params;
        bool first = true;
        if (has_gameday) {
            sql << "gameday_hidden = $" << (params.size() + 1) << "::boolean";
            params.push_back(gameday_hidden ? "true" : "false");
            first = false;
        }
        if (has_lineup) {
            if (!first) sql << ", ";
            sql << "lineup_hidden = $" << (params.size() + 1) << "::boolean";
            params.push_back(lineup_hidden ? "true" : "false");
        }
        sql << " WHERE id = $" << (params.size() + 1) << "::int";
        params.push_back(match_id);

        db_->query(sql.str(), params);

        std::ostringstream data;
        data << "{\"match_id\":" << match_id;
        if (has_gameday) data << ",\"gameday_hidden\":" << (gameday_hidden ? "true" : "false");
        if (has_lineup)  data << ",\"lineup_hidden\":"  << (lineup_hidden  ? "true" : "false");
        data << "}";

        return Response(HttpStatus::OK,
                        createJSONResponse(true, "Visibility updated", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ handleSetMatchVisibility: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Failed to update visibility"));
    }
}


std::string EventController::parseJSON(const std::string& body, const std::string& key) {
    // Simple JSON parsing for key-value pairs
    std::string search = "\"" + key + "\"";
    size_t pos = body.find(search);
    if (pos == std::string::npos) return "";
    
    // Find the value after the key
    pos = body.find(":", pos);
    if (pos == std::string::npos) return "";
    
    // Skip whitespace and quotes
    pos++;
    while (pos < body.length() && (body[pos] == ' ' || body[pos] == '\t')) pos++;
    
    if (pos >= body.length()) return "";
    
    // Handle null value
    if (body.substr(pos, 4) == "null") return "";
    
    // Extract value between quotes or until comma/brace
    bool quoted = (body[pos] == '"');
    if (quoted) pos++;
    
    size_t end_pos = pos;
    if (quoted) {
        end_pos = body.find("\"", pos);
    } else {
        end_pos = body.find_first_of(",}", pos);
    }
    
    if (end_pos == std::string::npos) return "";
    
    return body.substr(pos, end_pos - pos);
}


std::string EventController::getCurrentTimestamp() {
    auto now = std::time(nullptr);
    auto tm = *std::localtime(&now);
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");
    return oss.str();
}

Response EventController::handleCreateRSVP(const Request& request) {
    try {
        std::string body = request.getBody();
        std::cout << "📝 Creating/Updating RSVP with body: " << body << std::endl;
        
        // Extract event_id from path
        std::string event_id = extractEventIdFromPath(request.getPath());
        
        // Parse JSON body
        std::string user_id = parseJSON(body, "user_id");
        std::string role_type = parseJSON(body, "role_type");
        std::string status = parseJSON(body, "status");
        std::string notes = parseJSON(body, "notes");
        
        if (event_id.empty() || user_id.empty() || role_type.empty() || status.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing required fields: event_id, user_id, role_type, status"));
        }
        
        // Validate role_type
        if (role_type != "player" && role_type != "coach" && role_type != "parent") {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid role_type. Must be: player, coach, or parent"));
        }
        
        // Verify the match exists (schema uses `matches`, not the legacy `events` table).
        // Coaches are allowed to record/edit RSVPs at any time (including past events).
        std::string exists_query = "SELECT 1 FROM matches WHERE id = $1::int";
        pqxx::result event_check = db_->query(exists_query, {event_id});

        if (event_check.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Event not found"));
        }
        
        // Map frontend status values to database values
        std::string db_status;
        if (status == "attending") {
            db_status = "yes";
        } else if (status == "not_attending") {
            db_status = "no";
        } else if (status == "maybe") {
            db_status = "maybe";
        } else {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid status. Must be: attending, not_attending, or maybe"));
        }
        
        // Use history table (append-only) based on role_type
        std::string table_name = role_type + "_rsvp_history";
        std::string id_column = role_type + "_id";
        
        // Get rsvp_status_id from rsvp_statuses lookup table
        std::string status_query = "SELECT id FROM rsvp_statuses WHERE name = $1";
        pqxx::result status_result = db_->query(status_query, {db_status});
        
        if (status_result.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid status value"));
        }
        
        std::string rsvp_status_id = status_result[0]["id"].c_str();
        
        // Always INSERT into history table (append-only, no updates)
        // Use database uuid_generate_v4() for reliable UUID generation.
        // `changed_by` is left NULL for coach-set RSVPs because most players
        // don't have a matching row in the `users` table (that FK targets
        // `users.id`); the FK on player_id was repointed to `players.id` at
        // the schema level so we can store the player directly.
        std::string insert_query = "INSERT INTO " + table_name + " (id, event_id, " + id_column + ", rsvp_status_id, changed_by, change_source_id, notes, changed_at) "
                                   "VALUES (uuid_generate_v4(), $1, $2, $3, NULL, (SELECT id FROM rsvp_change_sources WHERE name = 'app'), $4, CURRENT_TIMESTAMP) RETURNING id";
        pqxx::result rsvp_result = db_->query(insert_query, {event_id, user_id, rsvp_status_id, notes});
        std::string rsvp_id = rsvp_result[0][0].c_str();
        std::cout << "✅ " << role_type << " RSVP recorded in history" << std::endl;
        
        // Log RSVP to ##u/##p file
        std::map<std::string, std::string> rsvp_columns;
        rsvp_columns["event_id"] = event_id;
        rsvp_columns[id_column] = user_id;
        rsvp_columns["rsvp_status_id"] = rsvp_status_id;
        rsvp_columns["changed_by"] = user_id;
        rsvp_columns["change_source_id"] = "(SELECT id FROM rsvp_change_sources WHERE name = 'app')";
        if (!notes.empty()) rsvp_columns["notes"] = notes;
        std::string rsvp_upsert = SqlBuilder::buildUpsert(table_name, rsvp_id, rsvp_columns, "id");
        SqlFileLogger::log("event_rsvps", rsvp_upsert);
        
        std::string data = "{\"event_id\": \"" + event_id + "\", \"user_id\": \"" + user_id + "\", \"role_type\": \"" + role_type + "\", \"status\": \"" + status + "\"}";
        return Response(HttpStatus::OK, createJSONResponse(true, "RSVP saved successfully", data));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error creating/updating RSVP: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to save RSVP"));
    }
}

Response EventController::handleGetEventRSVPs(const Request& request) {
    try {
        std::string event_id = extractEventIdFromPath(request.getPath());
        
        if (event_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing event_id"));
        }
        
        // Check for role_type query parameter (optional)
        std::string role_type = request.getQueryParam("role_type");
        
        std::cout << "📋 Getting RSVPs for event: " << event_id;
        if (!role_type.empty()) {
            std::cout << " (role: " << role_type << ")";
        }
        std::cout << std::endl;
        
        std::ostringstream json_array;
        json_array << "[";
        bool first = true;
        
        // If role_type specified, query only that table, otherwise query all tables
        std::vector<std::string> roles_to_query;
        if (!role_type.empty() && (role_type == "player" || role_type == "coach" || role_type == "parent")) {
            roles_to_query.push_back(role_type);
        } else {
            roles_to_query = {"player", "coach", "parent"};
        }
        
        for (const auto& role : roles_to_query) {
            // Use the current view which shows latest RSVP status
            std::string view_name = role + "_rsvps_current";
            std::string id_column = role + "_id";

            // Player RSVPs reference `players.id` (FK repointed in the schema
            // when we discovered players don't have `users` rows).  Coach and
            // parent RSVPs still FK to `users.id`.  Use a role-appropriate
            // JOIN so the current-status view actually returns rows.
            std::string join_clause;
            if (role == "player") {
                join_clause =
                    "JOIN players pl ON r." + id_column + " = pl.id "
                    "JOIN persons p ON pl.person_id = p.id ";
            } else {
                join_clause =
                    "JOIN users u ON r." + id_column + " = u.id "
                    "JOIN persons p ON u.person_id = p.id ";
            }

            std::string query = "SELECT r.event_id, r." + id_column + " as user_id, rs.name as status, r.notes, r.changed_at as response_date, "
                               "p.first_name, p.last_name, COALESCE(p.first_name, '') as preferred_name, COALESCE(pe.email, '') as email, '' as avatar_url "
                               "FROM " + view_name + " r "
                               + join_clause +
                               "LEFT JOIN person_emails pe ON pe.person_id = p.id AND pe.is_primary = true "
                               "JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id "
                               "WHERE r.event_id = $1 "
                               "ORDER BY r.changed_at DESC";
            
            pqxx::result result = db_->query(query, {event_id});
            
            for (size_t i = 0; i < result.size(); ++i) {
                if (!first) json_array << ",";
                first = false;
                
                std::string notes_value = result[i]["notes"].is_null() ? "" : escapeJSON(result[i]["notes"].c_str());
                std::string first_name = escapeJSON(result[i]["first_name"].c_str());
                std::string last_name = escapeJSON(result[i]["last_name"].c_str());
                std::string user_name = first_name + " " + last_name;
                std::string email = escapeJSON(result[i]["email"].c_str());
                std::string avatar_url = result[i]["avatar_url"].is_null() ? "" : result[i]["avatar_url"].c_str();
                
                // Map database status values back to frontend values
                std::string db_status = result[i]["status"].c_str();
                std::string frontend_status;
                if (db_status == "yes") {
                    frontend_status = "attending";
                } else if (db_status == "no") {
                    frontend_status = "not_attending";
                } else {
                    frontend_status = db_status; // "maybe" stays as is
                }
                
                json_array << "{"
                          << "\"event_id\": \"" << result[i]["event_id"].c_str() << "\", "
                          << "\"user_id\": \"" << result[i]["user_id"].c_str() << "\", "
                          << "\"role_type\": \"" << role << "\", "
                          << "\"status\": \"" << frontend_status << "\", "
                          << "\"notes\": \"" << notes_value << "\", "
                          << "\"response_date\": \"" << result[i]["response_date"].c_str() << "\", "
                          << "\"user_name\": \"" << user_name << "\", "
                          << "\"user_email\": \"" << email << "\", "
                          << "\"photoUrl\": \"" << escapeJSON(avatar_url) << "\""
                          << "}";
            }
        }
        
        json_array << "]";
        
        std::cout << "✅ RSVPs retrieved successfully" << std::endl;
        
        return Response(HttpStatus::OK, createJSONResponse(true, "RSVPs retrieved successfully", json_array.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting RSVPs: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get RSVPs"));
    }
}

// ============================================
// ATTENDANCE ENDPOINTS
// ============================================

Response EventController::handleGetAttendanceStatuses(const Request& request) {
    std::cout << "📋 Getting attendance statuses (hardcoded)..." << std::endl;
    // No dedicated attendance_statuses table exists in this schema.
    // `training_attendance` stores {attended: bool, attendance_status: varchar}.
    // We surface a small fixed set of statuses that the coach can toggle.
    std::string json = R"([
        {"id": 1, "name": "present",  "display_name": "Present",  "sort_order": 1, "color": "#16a34a"},
        {"id": 2, "name": "absent",   "display_name": "Absent",   "sort_order": 2, "color": "#dc2626"},
        {"id": 3, "name": "late",     "display_name": "Late",     "sort_order": 3, "color": "#d97706"},
        {"id": 4, "name": "excused",  "display_name": "Excused",  "sort_order": 4, "color": "#2563eb"}
    ])";
    return Response(HttpStatus::OK, createJSONResponse(true, "Attendance statuses retrieved", json));
}

Response EventController::handleGetEventAttendance(const Request& request) {
    std::cout << "📋 Getting event attendance (training_attendance)..." << std::endl;

    std::string event_id = extractEventIdFromPath(request.getPath());
    if (event_id.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Event ID is required"));
    }

    try {
        // Look up the team associated with this match. For practice/pickup we key off
        // home_team_id; away is only set for real games. Fall back to away_team_id if
        // needed so this endpoint also works for regular games.
        std::string team_query =
            "SELECT COALESCE(home_team_id, away_team_id) AS team_id FROM matches WHERE id = $1::int";
        pqxx::result team_res = db_->query(team_query, {event_id});
        if (team_res.empty() || team_res[0]["team_id"].is_null()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Match not found"));
        }
        std::string team_id = team_res[0]["team_id"].c_str();

        // Auto-seed a training_attendance row for every active roster player so the
        // coach can start toggling immediately. ON CONFLICT DO NOTHING keeps existing
        // rows intact.
        std::string seed_query = R"(
            INSERT INTO training_attendance (player_id, match_id, attended, attendance_status, source)
            SELECT r.player_id, $1::int, false, 'pending', 'footballhome'
            FROM rosters r
            WHERE r.team_id = $2::int AND r.left_at IS NULL
            ON CONFLICT (player_id, match_id) DO NOTHING
        )";
        db_->query(seed_query, {event_id, team_id});

        // Read back and shape for the frontend.
        std::string list_query = R"(
            SELECT ta.id,
                   ta.player_id,
                   ta.attended,
                   COALESCE(ta.attendance_status, '') AS attendance_status,
                   (COALESCE(per.first_name,'') || ' ' || COALESCE(per.last_name,'')) AS player_name
            FROM training_attendance ta
            JOIN players p    ON p.id  = ta.player_id
            JOIN persons per  ON per.id = p.person_id
            WHERE ta.match_id = $1::int
            ORDER BY per.first_name, per.last_name
        )";
        pqxx::result rows = db_->query(list_query, {event_id});

        std::ostringstream out;
        out << "[";
        for (size_t i = 0; i < rows.size(); ++i) {
            if (i > 0) out << ",";
            std::string status = rows[i]["attendance_status"].c_str();
            bool attended = rows[i]["attended"].as<bool>();

            // Map the DB value back to the numeric status_id the frontend expects.
            int status_id = 0;
            std::string status_name;
            if      (status == "present") { status_id = 1; status_name = "present"; }
            else if (status == "absent")  { status_id = 2; status_name = "absent"; }
            else if (status == "late")    { status_id = 3; status_name = "late"; }
            else if (status == "excused") { status_id = 4; status_name = "excused"; }
            else if (attended)            { status_id = 1; status_name = "present"; }
            else                           { status_id = 0; status_name = ""; }

            out << "{"
                << "\"id\": " << rows[i]["id"].as<int>() << ", "
                << "\"player_id\": " << rows[i]["player_id"].as<int>() << ", "
                << "\"player_name\": \"" << escapeJSON(rows[i]["player_name"].c_str()) << "\", "
                << "\"status_id\": " << status_id << ", "
                << "\"status_name\": \"" << status_name << "\""
                << "}";
        }
        out << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Attendance retrieved", out.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting attendance: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get attendance"));
    }
}

std::string EventController::extractAttendanceIdFromPath(const std::string& path) {
    // Path format: /api/attendance/:attendanceId
    std::string prefix = "/api/attendance/";
    if (path.substr(0, prefix.length()) == prefix) {
        return path.substr(prefix.length());
    }
    return "";
}

Response EventController::handleUpdateAttendance(const Request& request) {
    std::cout << "📋 Updating attendance record..." << std::endl;
    
    std::string attendance_id = extractAttendanceIdFromPath(request.getPath());
    if (attendance_id.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Attendance ID is required"));
    }
    
    // Parse request body
    std::string body = request.getBody();
    
    // Extract fields from JSON
    std::string status_id_str = parseJSON(body, "status_id");
    std::string notes = parseJSON(body, "notes");
    std::string updated_by = parseJSON(body, "updated_by"); // user_id of the coach
    
    if (status_id_str.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "status_id is required"));
    }
    
    try {
        int status_id = std::stoi(status_id_str);

        // Map the numeric status_id (1..4) to the training_attendance columns
        // (`attended: bool` + `attendance_status: varchar`).
        bool attended = false;
        std::string status_name;
        switch (status_id) {
            case 1: attended = true;  status_name = "present"; break;
            case 2: attended = false; status_name = "absent";  break;
            case 3: attended = true;  status_name = "late";    break;
            case 4: attended = false; status_name = "excused"; break;
            default:
                return Response(HttpStatus::BAD_REQUEST,
                                createJSONResponse(false, "Invalid status_id (expected 1..4)"));
        }

        std::string query = R"(
            UPDATE training_attendance
               SET attended = $1::boolean,
                   attendance_status = $2,
                   updated_at = NOW(),
                   override_by_user_id = NULLIF($3, '')::int,
                   override_note = NULLIF($4, '')
             WHERE id = $5::int
             RETURNING id
        )";
        pqxx::result result = db_->query(query, {
            attended ? std::string("true") : std::string("false"),
            status_name,
            updated_by,
            notes,
            attendance_id
        });

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Attendance record not found"));
        }

        // Log to ##u or ##p file
        std::map<std::string, std::string> columns = {
            {"attended", attended ? "true" : "false"},
            {"attendance_status", status_name}
        };
        if (!updated_by.empty()) columns["override_by_user_id"] = updated_by;
        if (!notes.empty())      columns["override_note"] = notes;
        std::string upsert_sql = SqlBuilder::buildUpsert("training_attendance", attendance_id, columns);
        SqlFileLogger::log("training_attendance", upsert_sql);

        std::cout << "✅ Attendance updated: " << attendance_id
                  << " -> " << status_name << std::endl;

        return Response(HttpStatus::OK, createJSONResponse(true, "Attendance updated successfully"));

    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating attendance: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to update attendance"));
    }
}

// ========================================
// Game Day Roster Endpoints
// ========================================

Response EventController::handleGetGameRoster(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID is required"));
    }
    
    std::cout << "📋 Getting game roster for match: " << matchId << std::endl;
    
    try {
        std::string query = R"(
            SELECT 
                ml.id,
                ml.player_id,
                pe.first_name,
                pe.last_name,
                p.photo_url as avatar_url,
                tp.jersey_number,
                pos.abbreviation as position,
                ml.created_at
            FROM match_lineups ml
            JOIN players p ON ml.player_id = p.id
            JOIN persons pe ON pe.id = p.person_id
            LEFT JOIN team_division_players tp ON ml.player_id = tp.player_id AND tp.team_id = ml.team_id
            LEFT JOIN player_positions pp ON pp.player_id = p.id AND pp.is_primary = true
            LEFT JOIN positions pos ON pp.position_id = pos.id
            WHERE ml.match_id = $1
            ORDER BY pe.last_name, pe.first_name
        )";
        
        pqxx::result result = db_->query(query, {matchId});
        
        std::ostringstream json;
        json << "{\"success\":true,\"data\":[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"id\":\"" << row["id"].c_str() << "\",";
            json << "\"playerId\":\"" << row["player_id"].c_str() << "\",";
            json << "\"firstName\":\"" << escapeJSON(row["first_name"].c_str()) << "\",";
            json << "\"lastName\":\"" << escapeJSON(row["last_name"].c_str()) << "\",";
            json << "\"photoUrl\":" << (row["avatar_url"].is_null() ? "null" : "\"" + escapeJSON(row["avatar_url"].c_str()) + "\"") << ",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].c_str()) << ",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"");
            json << "}";
        }
        
        json << "],\"count\":" << result.size() << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting game roster: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get game roster"));
    }
}

Response EventController::handleUpdateGameRoster(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID is required"));
    }
    
    std::cout << "📋 Updating game roster for match: " << matchId << std::endl;
    
    try {
        std::string body = request.getBody();
        
        // Parse player_ids array from JSON body
        // Expected: {"player_ids": ["uuid1", "uuid2", ...], "added_by": "coach-uuid"}
        std::string addedBy = parseJSON(body, "added_by");
        
        // Extract player_ids array (simple parsing for JSON array)
        std::vector<std::string> playerIds;
        size_t arrayStart = body.find("\"player_ids\"");
        if (arrayStart != std::string::npos) {
            size_t bracketStart = body.find("[", arrayStart);
            size_t bracketEnd = body.find("]", bracketStart);
            if (bracketStart != std::string::npos && bracketEnd != std::string::npos) {
                std::string arrayContent = body.substr(bracketStart + 1, bracketEnd - bracketStart - 1);
                
                // Parse integer IDs from the array (e.g. [1346, 1347, 1348])
                std::regex idRegex("([0-9]+)");
                std::sregex_iterator iter(arrayContent.begin(), arrayContent.end(), idRegex);
                std::sregex_iterator end;
                
                while (iter != end) {
                    playerIds.push_back((*iter)[1].str());
                    ++iter;
                }
            }
        }
        
        std::cout << "📋 Player IDs to add: " << playerIds.size() << std::endl;
        
        // Start transaction: clear existing roster and add new players
        // First, delete existing lineup entries for this match
        std::string deleteQuery = "DELETE FROM match_lineups WHERE match_id = $1";
        db_->query(deleteQuery, {matchId});
        
        // Insert new roster entries
        int addedCount = 0;
        for (const auto& playerId : playerIds) {
            std::string insertQuery;
            if (addedBy.empty()) {
                insertQuery = R"(
                    INSERT INTO match_lineups (match_id, player_id, team_id, is_starter)
                    VALUES ($1, $2, (SELECT home_team_id FROM matches WHERE id = $1), true)
                    ON CONFLICT (match_id, player_id) DO NOTHING
                )";
                db_->query(insertQuery, {matchId, playerId});
            } else {
                insertQuery = R"(
                    INSERT INTO match_lineups (match_id, player_id, team_id, is_starter)
                    VALUES ($1, $2, (SELECT home_team_id FROM matches WHERE id = $1), true)
                    ON CONFLICT (match_id, player_id) DO NOTHING
                )";
                db_->query(insertQuery, {matchId, playerId});
            }
            addedCount++;
            
            // Log match roster to ##u/##p file
            std::map<std::string, std::string> roster_columns;
            roster_columns["player_id"] = playerId;
            if (!addedBy.empty()) roster_columns["added_by"] = addedBy;
            
            // Fix: Use correct key format for composite key upsert logging
            // The SqlBuilder::buildUpsert expects a single ID, but here we have a composite key.
            // For now, we'll just log the INSERT statement directly as a fallback since buildUpsert isn't designed for composite keys
            std::ostringstream sqlLog;
            sqlLog << "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter) "
                   << "VALUES ('" << matchId << "', '" << playerId << "', (SELECT home_team_id FROM matches WHERE id = '" << matchId << "'), true) "
                   << "ON CONFLICT (match_id, player_id) DO NOTHING;";
            SqlFileLogger::log("matches", sqlLog.str());
        }
        
        std::cout << "✅ Game roster updated: " << addedCount << " players" << std::endl;
        
        std::ostringstream json;
        json << "{\"success\":true,\"message\":\"Game roster updated\",\"count\":" << addedCount << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating game roster: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to update game roster"));
    }
}

// POST /api/matches/:matchId/lineup/:playerId
Response EventController::handleAddToLineup(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    // Extract playerId from end of path: /api/matches/425/lineup/1346
    std::regex pidRegex(R"(/lineup/(\d+))");
    std::smatch pidMatch;
    std::string path = request.getPath();
    std::string playerId;
    if (std::regex_search(path, pidMatch, pidRegex)) {
        playerId = pidMatch[1].str();
    }
    if (matchId.empty() || playerId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID and Player ID required"));
    }
    try {
        db_->query(
            "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter) "
            "VALUES ($1::int, $2::int, (SELECT home_team_id FROM matches WHERE id = $1::int), true) "
            "ON CONFLICT (match_id, player_id) DO NOTHING",
            {matchId, playerId});
        return Response(HttpStatus::OK, createJSONResponse(true, "Added to lineup"));
    } catch (const std::exception& e) {
        std::cerr << "❌ Add to lineup error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed"));
    }
}

// DELETE /api/matches/:matchId/lineup/:playerId
Response EventController::handleRemoveFromLineup(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    std::regex pidRegex(R"(/lineup/(\d+))");
    std::smatch pidMatch;
    std::string path = request.getPath();
    std::string playerId;
    if (std::regex_search(path, pidMatch, pidRegex)) {
        playerId = pidMatch[1].str();
    }
    if (matchId.empty() || playerId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID and Player ID required"));
    }
    try {
        db_->query(
            "DELETE FROM match_lineups WHERE match_id = $1::int AND player_id = $2::int",
            {matchId, playerId});
        return Response(HttpStatus::OK, createJSONResponse(true, "Removed from lineup"));
    } catch (const std::exception& e) {
        std::cerr << "❌ Remove from lineup error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed"));
    }
}

Response EventController::handleGetEligiblePlayers(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID is required"));
    }
    
    std::cout << "📋 Getting eligible players for match: " << matchId << std::endl;
    
    try {
        // Get players who:
        // 1. Are on the team roster (from home_team_id in matches table)
        // 2. Have RSVP'd 'yes' (attending) for this event
        // 3. Have show_in_rsvp = true on their roster status
        std::string query = R"(
            SELECT DISTINCT
                p.id as player_id,
                pe.first_name,
                pe.last_name,
                '' as email,
                p.photo_url as avatar_url,
                tp.jersey_number,
                pos.abbreviation as position,
                rs.name as rsvp_status,
                CASE WHEN ml.id IS NOT NULL THEN true ELSE false END as on_game_roster,
                CASE WHEN rs.name = 'yes' THEN 0 ELSE 1 END as rsvp_order
            FROM matches m
            JOIN team_division_players tp ON tp.team_id = m.home_team_id
            JOIN players p ON tp.player_id = p.id
            JOIN persons pe ON pe.id = p.person_id
            LEFT JOIN player_positions pp ON pp.player_id = p.id AND pp.is_primary = true
            LEFT JOIN positions pos ON pp.position_id = pos.id
            LEFT JOIN roster_statuses rost ON tp.roster_status_id = rost.id
            LEFT JOIN player_rsvps_current prc ON prc.player_id = p.id AND prc.event_id = m.id
            LEFT JOIN rsvp_statuses rs ON prc.rsvp_status_id = rs.id
            LEFT JOIN match_lineups ml ON ml.match_id = m.id AND ml.player_id = p.id
            WHERE m.id = $1
              AND tp.is_active = true
              AND (rost.show_in_rsvp = true OR rost.show_in_rsvp IS NULL)
            ORDER BY 
                rsvp_order,
                pe.last_name, 
                pe.first_name
        )";
        
        pqxx::result result = db_->query(query, {matchId});
        
        std::ostringstream json;
        json << "{\"success\":true,\"data\":[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"playerId\":\"" << row["player_id"].c_str() << "\",";
            json << "\"firstName\":\"" << escapeJSON(row["first_name"].c_str()) << "\",";
            json << "\"lastName\":\"" << escapeJSON(row["last_name"].c_str()) << "\",";
            json << "\"email\":\"" << escapeJSON(row["email"].c_str()) << "\",";
            json << "\"photoUrl\":" << (row["avatar_url"].is_null() ? "null" : "\"" + escapeJSON(row["avatar_url"].c_str()) + "\"") << ",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].c_str()) << ",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"") << ",";
            json << "\"rsvpStatus\":" << (row["rsvp_status"].is_null() ? "null" : "\"" + std::string(row["rsvp_status"].c_str()) + "\"") << ",";
            json << "\"onGameRoster\":" << (row["on_game_roster"].as<bool>() ? "true" : "false");
            json << "}";
        }
        
        json << "],\"count\":" << result.size() << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting eligible players: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get eligible players"));
    }
}

// GET /api/matches/:matchId/roster-players - Enriched player data for game day roster screen
Response EventController::handleGetRosterPlayers(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID is required"));
    }

    // Optional teamId param to specify which team's roster to show
    // Falls back to home_team_id if not provided
    std::string teamIdParam = request.getQueryParam("teamId");

    try {
        // Get match date so we can find the 5 practice/pickup events before it
        pqxx::result matchDateResult = db_->query(
            "SELECT (m.match_date + COALESCE(m.match_time, '00:00'::time))::text AS event_date FROM matches m WHERE m.id = $1", {matchId});
        std::string matchDate = "9999-12-31";
        if (!matchDateResult.empty()) {
            matchDate = matchDateResult[0]["event_date"].c_str();
        }

        // Universal training/pickup rule (applies to ALL teams and lineups):
        //  • Look at the Training Lighthouse + Philadelphia Pickup chats.
        //  • Only events whose title contains the word "training" or "pickup".
        //  • Always include the last 5 NON-canceled events.
        //  • Also include any canceled events that fall within the date window
        //    of those 5 (they render as "extra" 6th/7th columns so RSVPs to a
        //    canceled session still get credit).
        pqxx::result trainingEvents;
        std::vector<int> teIds;
        try {
            std::string trainingQuery = R"(
                WITH excluded_dates AS (
                    -- Any date that has a non-training/non-pickup event in the
                    -- Training or Pickup chat (friendlies, tournaments, etc.)
                    -- is treated as a special day and skipped entirely.
                    SELECT DISTINCT ce.event_date
                    FROM chat_events ce
                    JOIN chats c ON c.id = ce.chat_id
                    WHERE c.name IN ('Training Lighthouse', 'Philadelphia Pickup')
                      AND ce.is_active = true
                      AND ce.event_date < $1::date
                      AND NOT (ce.title ILIKE '%training%' OR ce.title ILIKE '%pickup%')
                ),
                eligible_dates AS (
                    -- Last 5 distinct dates that had actual training/pickup
                    -- (excluding friendly/tournament days entirely).
                    SELECT DISTINCT ce.event_date
                    FROM chat_events ce
                    JOIN chats c ON c.id = ce.chat_id
                    WHERE c.name IN ('Training Lighthouse', 'Philadelphia Pickup')
                      AND ce.is_active = true
                      AND (ce.title ILIKE '%training%' OR ce.title ILIKE '%pickup%')
                      AND ce.event_date < $1::date
                      AND ce.event_date NOT IN (SELECT event_date FROM excluded_dates)
                    ORDER BY ce.event_date DESC
                    LIMIT 5
                )
                SELECT ce.id, ce.title, ce.event_date::text AS event_date, ce.is_active
                FROM chat_events ce
                JOIN chats c ON c.id = ce.chat_id
                WHERE c.name IN ('Training Lighthouse', 'Philadelphia Pickup')
                  AND (ce.title ILIKE '%training%' OR ce.title ILIKE '%pickup%')
                  AND ce.event_date IN (SELECT event_date FROM eligible_dates)
                ORDER BY ce.event_date DESC, ce.event_time DESC NULLS LAST, ce.title
            )";
            trainingEvents = db_->query(trainingQuery, {matchDate});
            for (const auto& te : trainingEvents) {
                teIds.push_back(te["id"].as<int>());
            }
        } catch (...) {
            // chat_events table not available — skip training RSVP data
        }

        // Find the chat_event for this match (RSVP source)
        int matchChatEventId = 0;
        try {
            std::string matchEventQuery = R"(
                SELECT ce.id as chat_event_id
                FROM chat_events ce
                WHERE ce.match_id = $1
                LIMIT 1
            )";
            pqxx::result matchEventResult = db_->query(matchEventQuery, {matchId});
            if (!matchEventResult.empty()) {
                matchChatEventId = matchEventResult[0]["chat_event_id"].as<int>();
            }
        } catch (...) {
            // chat_events table not available — skip chat RSVP lookup
        }

        // Get all players from the home team roster with enriched data.
        // After migration 059, event_rsvps is the single source of truth for
        // player RSVPs (FH-native /api/rsvp writes + backfilled historical
        // RSVPs + mirror-trigger copies of any C++ admin "pulse"
        // writes that still target chat_event_rsvps).
        // RSVP precedence: admin override (player_rsvps_current) > event_rsvps.
        std::string query = R"(
            SELECT DISTINCT
                p.id as player_id,
                pe.id as person_id,
                pe.first_name,
                pe.last_name,
                false::boolean as is_keeper,
                NULL::text as position,
                CASE WHEN ml.id IS NOT NULL THEN true ELSE false END as on_game_roster,
                ml.zone as lineup_zone,
                ml.slot_number as lineup_slot,
                COALESCE(ml.is_starter, false) as lineup_is_starter,
                COALESCE(r.jersey_number::text, '') as jersey_number,
                r.team_id as roster_team_id,
                -- Admin override RSVP (player_rsvps_current is keyed by users.id)
                (
                    SELECT rs.name FROM player_rsvps_current prc
                    JOIN users u_admin ON u_admin.id = prc.player_id
                    JOIN rsvp_statuses rs ON rs.id = prc.rsvp_status_id
                    WHERE prc.event_id = m.id AND u_admin.person_id = pe.id
                    LIMIT 1
                ) as admin_rsvp,
                -- FH-native RSVP — unified table written by /api/rsvp, the
                -- mirror trigger from chat_event_rsvps, and historical
                -- backfill (migration 059).  source_id distinguishes
                -- ('app' | 'admin' | ...) but we don't surface it here.
                (
                    SELECT rs.name FROM event_rsvps er
                    JOIN rsvp_statuses rs ON rs.id = er.rsvp_status_id
                    WHERE er.chat_event_id = $3::int AND er.person_id = pe.id
                    LIMIT 1
                ) as fh_rsvp,
                (
                    SELECT er.updated_at::text FROM event_rsvps er
                    WHERE er.chat_event_id = $3::int AND er.person_id = pe.id
                    LIMIT 1
                ) as fh_rsvp_at,
                -- Individual chat memberships removed with the GroupMe cutover;
                -- columns retained for API shape compatibility.
                false::boolean as in_chat_apsl,
                false::boolean as in_chat_casa,
                false::boolean as in_chat_u23,
                -- Individual roster memberships (using team names for lookup)
                EXISTS(SELECT 1 FROM rosters r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC') AND r2.left_at IS NULL) as on_roster_lighthouse,
                EXISTS(SELECT 1 FROM rosters r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse Boys Club') AND r2.left_at IS NULL) as on_roster_casa,
                EXISTS(SELECT 1 FROM rosters r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers') AND r2.left_at IS NULL) as on_roster_u23
            FROM matches m
            JOIN rosters r ON r.team_id = CASE WHEN $2 <> '' THEN $2::int ELSE m.home_team_id END AND r.left_at IS NULL
            JOIN teams t ON t.id = r.team_id
            JOIN players p ON r.player_id = p.id
            JOIN persons pe ON pe.id = p.person_id
            LEFT JOIN match_lineups ml ON ml.match_id = m.id AND ml.player_id = p.id
            WHERE m.id = $1
              -- Lineup = FH-members only (June 2026 cutover).  An FH-member
              -- is either:
              --   1. A LeagueApps mens registrant (external_person_aliases
              --      JOIN mens_team_assignments).  For non-pool teams the
              --      assignment must be on THIS team; for pool teams
              --      (Practice / Pickup, teams.is_pool=true) ANY mens
              --      assignment counts since pool teams are open to every
              --      mens member.
              --   2. A FootballHome self-registrant (fh_member_at set).
              -- No saved-lineup or admin-pulse escape hatch — ghost roster
              -- regardless of any historical match_lineups or admin RSVP.
              --
              -- IMPORTANT: this endpoint returns the INTERNAL roster only
              -- (mens_team_assignments — what Lighthouse considers on the
              -- team).  The OFFICIAL roster (public league-website scrape
              -- — teams.source_system_id IN 1..3) is a separate concept
              -- and is intentionally NOT surfaced here; between seasons
              -- the official roster may be empty while the internal
              -- roster is still active.
              AND (
                EXISTS (
                  SELECT 1
                    FROM external_person_aliases epa
                    JOIN mens_team_assignments mta
                      ON mta.leagueapps_user_id::text = epa.external_user_id
                   WHERE epa.person_id = pe.id
                     AND epa.provider = 'leagueapps'
                     AND (mta.team_id = r.team_id OR t.is_pool)
                )
                OR pe.fh_member_at IS NOT NULL
              )
            ORDER BY pe.last_name, pe.first_name
        )";

        pqxx::result result = db_->query(query, {matchId, teamIdParam, std::to_string(matchChatEventId)});

        // Build practice map (person_id -> array of RSVPs for last 5 trainings)
        std::map<int, std::vector<std::string>> practiceMap;
        std::map<int, std::vector<bool>> practiceOverrideMap;
        if (!teIds.empty()) {
            // After migration 059 event_rsvps is the unified RSVP table — admin
            // pulses, FH-native /api/rsvp, mirror-trigger copies of any chat
            // sync writes, and backfilled historical RSVPs all land
            // here keyed by (chat_event_id, person_id).  is_override marks the
            // 'admin' source so the UI can render the pulse indicator.
            std::string practiceQuery = R"(
                SELECT er.person_id,
                       er.chat_event_id,
                       rs.name AS rsvp,
                       (er.source_id = 3) AS is_override
                  FROM event_rsvps er
                  JOIN rsvp_statuses rs ON rs.id = er.rsvp_status_id
                 WHERE er.chat_event_id = ANY($1)
            )";
            std::string arrayLiteral = "{";
            for (size_t i = 0; i < teIds.size(); i++) {
                if (i > 0) arrayLiteral += ",";
                arrayLiteral += std::to_string(teIds[i]);
            }
            arrayLiteral += "}";

            pqxx::result practiceResult = db_->query(practiceQuery, {arrayLiteral});

            std::map<int, int> eventIndexMap;
            for (size_t i = 0; i < teIds.size(); i++) {
                eventIndexMap[teIds[i]] = (int)i;
            }

            for (const auto& pr : practiceResult) {
                if (pr["person_id"].is_null()) continue;
                int personId = pr["person_id"].as<int>();
                int eventId = pr["chat_event_id"].as<int>();
                std::string rsvp = pr["rsvp"].c_str();
                bool isOverride = !pr["is_override"].is_null() && pr["is_override"].as<bool>();

                if (practiceMap.find(personId) == practiceMap.end()) {
                    practiceMap[personId] = std::vector<std::string>(teIds.size(), "");
                    practiceOverrideMap[personId] = std::vector<bool>(teIds.size(), false);
                }
                auto it = eventIndexMap.find(eventId);
                if (it != eventIndexMap.end()) {
                    practiceMap[personId][it->second] = rsvp;
                    practiceOverrideMap[personId][it->second] = isOverride;
                }
            }
        }

        std::ostringstream json;
        json << "{\"success\":true,\"data\":[";

        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;

            int personId = row["person_id"].as<int>();

            // RSVP precedence after migration 059:
            //   1. admin override (player_rsvps_current) always wins
            //   2. else event_rsvps (unified — covers app, mirrored admin,
            //      and backfilled historical entries)
            //   3. else null
            bool hasAdminRsvp = !row["admin_rsvp"].is_null();
            bool hasFhRsvp    = !row["fh_rsvp"].is_null();
            std::string effectiveRsvp = "";
            std::string rsvpSource = "";
            if (hasAdminRsvp) {
                effectiveRsvp = row["admin_rsvp"].c_str();
                rsvpSource = "admin";
            } else if (hasFhRsvp) {
                effectiveRsvp = row["fh_rsvp"].c_str();
                rsvpSource = "footballhome";
            }

            json << "{";
            json << "\"playerId\":\"" << row["player_id"].c_str() << "\",";
            json << "\"personId\":" << personId << ",";
            json << "\"firstName\":\"" << escapeJSON(row["first_name"].c_str()) << "\",";
            json << "\"lastName\":\"" << escapeJSON(row["last_name"].c_str()) << "\",";
            json << "\"isKeeper\":" << (row["is_keeper"].as<bool>() ? "true" : "false") << ",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"") << ",";
            json << "\"rsvpStatus\":" << (effectiveRsvp.empty() ? "null" : "\"" + effectiveRsvp + "\"") << ",";
            json << "\"rsvpSource\":" << (rsvpSource.empty() ? "null" : "\"" + rsvpSource + "\"") << ",";
            json << "\"onGameRoster\":" << (row["on_game_roster"].as<bool>() ? "true" : "false") << ",";
            // Saved lineup zone (null when player isn't on a saved lineup yet).
            bool onLineup = row["on_game_roster"].as<bool>();
            json << "\"onLineup\":" << (onLineup ? "true" : "false") << ",";
            json << "\"lineupZone\":" << (row["lineup_zone"].is_null() ? "null" : "\"" + std::string(row["lineup_zone"].c_str()) + "\"") << ",";
            json << "\"lineupSlot\":" << (row["lineup_slot"].is_null() ? "null" : std::string(row["lineup_slot"].c_str())) << ",";
            json << "\"isStarter\":" << (row["lineup_is_starter"].as<bool>() ? "true" : "false") << ",";
            json << "\"jerseyNumber\":\"" << escapeJSON(row["jersey_number"].c_str()) << "\",";
            json << "\"rosterTeamId\":\"" << row["roster_team_id"].c_str() << "\",";

            // Chat memberships
            json << "\"inChatApsl\":" << (row["in_chat_apsl"].as<bool>() ? "true" : "false") << ",";
            json << "\"inChatCasa\":" << (row["in_chat_casa"].as<bool>() ? "true" : "false") << ",";
            json << "\"inChatU23\":" << (row["in_chat_u23"].as<bool>() ? "true" : "false") << ",";

            // Roster memberships
            json << "\"onRosterLighthouse\":" << (row["on_roster_lighthouse"].as<bool>() ? "true" : "false") << ",";
            json << "\"onRosterCasa\":" << (row["on_roster_casa"].as<bool>() ? "true" : "false") << ",";
            json << "\"onRosterU23\":" << (row["on_roster_u23"].as<bool>() ? "true" : "false") << ",";

            // Practice RSVPs — {v:status, o:isOverride}
            json << "\"practice\":[";
            auto pit = practiceMap.find(personId);
            auto oit = practiceOverrideMap.find(personId);
            for (size_t i = 0; i < teIds.size(); i++) {
                if (i > 0) json << ",";
                if (pit != practiceMap.end() && i < pit->second.size() && !pit->second[i].empty()) {
                    bool isOvr = (oit != practiceOverrideMap.end() && i < oit->second.size()) ? oit->second[i] : false;
                    json << "{\"v\":\"" << pit->second[i] << "\",\"o\":" << (isOvr ? "true" : "false") << "}";
                } else {
                    json << "null";
                }
            }
            json << "]";

            json << "}";
        }

        // Include training event metadata
        json << "],\"trainingEvents\":[";
        for (size_t i = 0; i < trainingEvents.size(); i++) {
            if (i > 0) json << ",";
            bool isCanceled = !trainingEvents[(int)i]["is_active"].as<bool>();
            json << "{\"id\":" << trainingEvents[(int)i]["id"].c_str();
            json << ",\"title\":\"" << escapeJSON(trainingEvents[(int)i]["title"].c_str()) << "\"";
            json << ",\"date\":\"" << trainingEvents[(int)i]["event_date"].c_str() << "\"";
            json << ",\"isCanceled\":" << (isCanceled ? "true" : "false") << "}";
        }

        // -------------------------------------------------------------
        // Diagnostics — surfaces chat → footballhome person linking
        // and admin/chat RSVP counts for this match so the lineup screen
        // can show "why is everyone listed as no response?" up front.
        // -------------------------------------------------------------
        int totalRsvps = 0, linkedRsvps = 0, unlinkedRsvps = 0;
        int rosterWithGmRsvp = 0, rosterWithAdminRsvp = 0;
        std::string chatName = "";
        std::vector<std::pair<std::string,std::string>> unlinkedMembers; // (external_username, external_user_id)
        std::vector<std::tuple<std::string,std::string,std::string>> matchedSample; // (first,last,rsvp)

        if (matchChatEventId > 0) {
            try {
                pqxx::result cn = db_->query(
                    "SELECT c.name FROM chat_events ce JOIN chats c ON c.id = ce.chat_id WHERE ce.id = $1",
                    {std::to_string(matchChatEventId)});
                if (!cn.empty() && !cn[0][0].is_null()) chatName = cn[0][0].c_str();
            } catch (...) {}

            try {
                pqxx::result counts = db_->query(R"(
                    SELECT COUNT(*) AS total,
                           COUNT(person_id) AS linked,
                           COUNT(*) FILTER (WHERE person_id IS NULL) AS unlinked
                    FROM chat_event_rsvps
                    WHERE chat_event_id = $1
                )", {std::to_string(matchChatEventId)});
                if (!counts.empty()) {
                    totalRsvps = counts[0]["total"].as<int>();
                    linkedRsvps = counts[0]["linked"].as<int>();
                    unlinkedRsvps = counts[0]["unlinked"].as<int>();
                }
            } catch (...) {}

            try {
                pqxx::result unl = db_->query(R"(
                    SELECT COALESCE(external_username,'') AS external_username,
                           COALESCE(external_user_id,'') AS external_user_id
                    FROM chat_event_rsvps
                    WHERE chat_event_id = $1 AND person_id IS NULL
                    ORDER BY external_username
                )", {std::to_string(matchChatEventId)});
                for (const auto& row : unl) {
                    unlinkedMembers.push_back({row["external_username"].c_str(), row["external_user_id"].c_str()});
                }
            } catch (...) {}
        }

        // Count from the result we already built (avoids a second join).
        // After migration 059 "gm_rsvp" no longer exists as a separate column —
        // fh_rsvp is the unified RSVP (app + historical backfill + mirrored
        // admin writes).  We keep the historical JSON keys (rosterWithGmRsvp
        // etc.) for frontend backward-compat; they now mean "roster players
        // with any non-admin RSVP in event_rsvps".
        for (const auto& row : result) {
            if (!row["admin_rsvp"].is_null()) rosterWithAdminRsvp++;
            if (!row["fh_rsvp"].is_null()) {
                rosterWithGmRsvp++;
                if (matchedSample.size() < 50) {
                    matchedSample.emplace_back(
                        row["first_name"].c_str(),
                        row["last_name"].c_str(),
                        row["fh_rsvp"].c_str());
                }
            }
        }

        json << "],\"diagnostics\":{";
        json << "\"matchId\":\"" << matchId << "\"";
        json << ",\"chatEventId\":" << matchChatEventId;
        json << ",\"chatName\":\"" << escapeJSON(chatName) << "\"";
        json << ",\"rosterSize\":" << result.size();
        json << ",\"gmRsvpTotal\":" << totalRsvps;
        json << ",\"gmRsvpLinkedToPerson\":" << linkedRsvps;
        json << ",\"gmRsvpUnlinked\":" << unlinkedRsvps;
        json << ",\"rosterWithGmRsvp\":" << rosterWithGmRsvp;
        json << ",\"rosterWithAdminRsvp\":" << rosterWithAdminRsvp;
        json << ",\"unlinkedMembers\":[";
        for (size_t i = 0; i < unlinkedMembers.size(); i++) {
            if (i > 0) json << ",";
            json << "{\"externalUsername\":\"" << escapeJSON(unlinkedMembers[i].first) << "\""
                 << ",\"externalUserId\":\"" << escapeJSON(unlinkedMembers[i].second) << "\"}";
        }
        json << "],\"matchedSample\":[";
        for (size_t i = 0; i < matchedSample.size(); i++) {
            if (i > 0) json << ",";
            json << "{\"firstName\":\"" << escapeJSON(std::get<0>(matchedSample[i])) << "\""
                 << ",\"lastName\":\"" << escapeJSON(std::get<1>(matchedSample[i])) << "\""
                 << ",\"rsvp\":\"" << escapeJSON(std::get<2>(matchedSample[i])) << "\"}";
        }
        json << "]}";

        json << ",\"count\":" << result.size() << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting roster players: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get roster players"));
    }
}

// PUT /api/matches/:matchId/player-rsvp - Set/override a player's RSVP for a match
// Auto-saves into player_rsvp_history (persists across rebuilds)
Response EventController::handleSetPlayerRSVP(const Request& request) {
    std::string matchId = extractMatchIdFromPath(request.getPath());
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Match ID is required"));
    }

    try {
        std::string body = request.getBody();
        std::string playerId = parseJSON(body, "player_id");
        std::string rsvpStatus = parseJSON(body, "rsvp_status");

        if (playerId.empty() || rsvpStatus.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "player_id and rsvp_status are required"));
        }

        // Look up rsvp_status_id from name
        pqxx::result statusResult = db_->query(
            "SELECT id FROM rsvp_statuses WHERE name = $1", {rsvpStatus});
        if (statusResult.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid RSVP status"));
        }
        std::string rsvpStatusId = statusResult[0][0].c_str();

        // Insert into player_rsvp_history (the view player_rsvps_current picks up the latest)
        std::string insertQuery = R"(
            INSERT INTO player_rsvp_history (event_id, player_id, rsvp_status_id, change_source_id, notes)
            VALUES ($1, $2, $3, 3, 'Set from game day roster')
        )";
        db_->query(insertQuery, {matchId, playerId, rsvpStatusId});

        std::cout << "✅ RSVP set for player " << playerId << " match " << matchId << " -> " << rsvpStatus << std::endl;

        std::ostringstream json;
        json << "{\"success\":true,\"message\":\"RSVP updated\",\"rsvpStatus\":\"" << escapeJSON(rsvpStatus) << "\"}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "❌ Error setting player RSVP: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to set RSVP"));
    }
}

// Helper function to decode base64url

std::string EventController::extractUserIdFromToken(const Request& request) {
    // Extract Authorization header
    std::string auth_header = request.getHeader("Authorization");
    
    if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") {
        return "";
    }
    
    // Extract token (remove "Bearer " prefix)
    std::string token = auth_header.substr(7);
    
    // Check for JWT format (header.payload.signature)
    if (token.find('.') != std::string::npos) {
        size_t first_dot = token.find('.');
        size_t second_dot = token.find('.', first_dot + 1);
        
        if (first_dot != std::string::npos && second_dot != std::string::npos) {
            // Extract payload
            std::string payload_encoded = token.substr(first_dot + 1, second_dot - first_dot - 1);
            
            // Decode payload
            std::string payload = fh::crypto::base64UrlDecode(payload_encoded);
            
            // Extract userId from JSON payload
            // Format: {"userId":"xxx",...}
            std::string pattern = "\"userId\"\\s*:\\s*\"([^\"]+)\"";
            std::regex user_id_regex(pattern);
            std::smatch match;
            
            if (std::regex_search(payload, match, user_id_regex)) {
                return match[1].str();
            }
        }
    }
    
    if (!token.empty() && token.substr(0, 4) == "jwt_") {
        // Extract user ID from our JWT format: jwt_{user_id}_{hash}
        // Find the last underscore (since UUID contains hyphens, not underscores)
        size_t last_underscore = token.rfind('_');
        if (last_underscore != std::string::npos && last_underscore > 4) {
            std::string user_id = token.substr(4, last_underscore - 4);
            return user_id;
        }
    }
    
    return "";
}

// ============================================================================
// Club Chat Events & RSVP Override
// ============================================================================

Response EventController::handleGetClubChatEvents(const Request& request) {
    try {
        // Extract clubId from path: /api/events/club/:clubId/chat-events
        std::string path = request.getPath();
        std::regex clubIdRegex("/api/events/club/(\\d+)/chat-events");
        std::smatch match;
        std::string clubId;
        if (std::regex_search(path, match, clubIdRegex)) {
            clubId = match[1].str();
        }
        if (clubId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing clubId"));
        }

        // Get all chat events for chats linked to teams belonging to this club,
        // plus cross-team chats (training/pickup where team_id is NULL)
        std::string sql = R"(
            SELECT ce.id, ce.title, ce.description, ce.location, ce.location_address,
                   ce.event_date, ce.event_time, ce.start_at, ce.end_at,
                   ce.external_id, ce.match_id, ce.is_active,
                   c.name as chat_name, c.id as chat_id, c.chat_type_id,
                   (SELECT COUNT(*) FROM event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND r.rsvp_status_id = 1) as going_count,
                   (SELECT COUNT(*) FROM event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND r.rsvp_status_id = 2) as not_going_count,
                   (SELECT COUNT(*) FROM event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND r.rsvp_status_id = 3) as maybe_count,
                   m.match_date, mt.name as match_type_name,
                   ht.name as home_team, at2.name as away_team,
                   m.home_score, m.away_score
            FROM chat_events ce
            JOIN chats c ON c.id = ce.chat_id
            LEFT JOIN matches m ON m.id = ce.match_id
            LEFT JOIN match_types mt ON mt.id = m.match_type_id
            LEFT JOIN teams ht ON ht.id = m.home_team_id
            LEFT JOIN teams at2 ON at2.id = m.away_team_id
            WHERE c.team_id IN (SELECT t.id FROM teams t WHERE t.club_id = )" + clubId + R"()
               OR c.id IN (SELECT cc.chat_id FROM chat_clubs cc WHERE cc.club_id = )" + clubId + R"()
            ORDER BY ce.start_at DESC NULLS LAST, ce.event_date DESC NULLS LAST
        )";

        pqxx::result events = db_->query(sql);

        std::ostringstream json;
        json << "{\"success\":true,\"data\":{\"events\":[";

        for (size_t i = 0; i < events.size(); ++i) {
            if (i > 0) json << ",";
            json << "{"
                 << "\"id\":" << events[i]["id"].c_str() << ","
                 << "\"title\":\"" << escapeJSON(events[i]["title"].is_null() ? "" : events[i]["title"].c_str()) << "\","
                 << "\"description\":\"" << escapeJSON(events[i]["description"].is_null() ? "" : events[i]["description"].c_str()) << "\","
                 << "\"location\":\"" << escapeJSON(events[i]["location"].is_null() ? "" : events[i]["location"].c_str()) << "\","
                 << "\"location_address\":\"" << escapeJSON(events[i]["location_address"].is_null() ? "" : events[i]["location_address"].c_str()) << "\","
                 << "\"start_at\":" << (events[i]["start_at"].is_null() ? "null" : ("\"" + std::string(events[i]["start_at"].c_str()) + "\"")) << ","
                 << "\"end_at\":" << (events[i]["end_at"].is_null() ? "null" : ("\"" + std::string(events[i]["end_at"].c_str()) + "\"")) << ","
                 << "\"event_date\":" << (events[i]["event_date"].is_null() ? "null" : ("\"" + std::string(events[i]["event_date"].c_str()) + "\"")) << ","
                 << "\"external_id\":\"" << escapeJSON(events[i]["external_id"].is_null() ? "" : events[i]["external_id"].c_str()) << "\","
                 << "\"chat_name\":\"" << escapeJSON(events[i]["chat_name"].is_null() ? "" : events[i]["chat_name"].c_str()) << "\","
                 << "\"chat_id\":" << events[i]["chat_id"].c_str() << ","
                 << "\"match_id\":" << (events[i]["match_id"].is_null() ? "null" : events[i]["match_id"].c_str()) << ","
                 << "\"match_type\":\"" << escapeJSON(events[i]["match_type_name"].is_null() ? "" : events[i]["match_type_name"].c_str()) << "\","
                 << "\"home_team\":\"" << escapeJSON(events[i]["home_team"].is_null() ? "" : events[i]["home_team"].c_str()) << "\","
                 << "\"away_team\":\"" << escapeJSON(events[i]["away_team"].is_null() ? "" : events[i]["away_team"].c_str()) << "\","
                 << "\"home_score\":" << (events[i]["home_score"].is_null() ? "null" : events[i]["home_score"].c_str()) << ","
                 << "\"away_score\":" << (events[i]["away_score"].is_null() ? "null" : events[i]["away_score"].c_str()) << ","
                 << "\"going\":" << events[i]["going_count"].c_str() << ","
                 << "\"not_going\":" << events[i]["not_going_count"].c_str() << ","
                 << "\"maybe\":" << events[i]["maybe_count"].c_str()
                 << "}";
        }
        json << "],";

        // Get RSVPs with effective status (override wins over synced)
        std::string rsvpSql = R"(
            SELECT r.id as rsvp_id, r.chat_event_id, 
                   r.rsvp_status_id as synced_status_id,
                   r.override_rsvp_status_id,
                   COALESCE(r.override_rsvp_status_id, r.rsvp_status_id) as effective_status_id,
                   r.external_username,
                   r.override_note,
                   r.overridden_at,
                   p.first_name, p.last_name, r.person_id, r.external_user_id,
                   rs.name as synced_status,
                   ors.name as override_status,
                   COALESCE(ors.name, rs.name) as effective_status
            FROM chat_event_rsvps r
            LEFT JOIN persons p ON p.id = r.person_id
            JOIN rsvp_statuses rs ON rs.id = r.rsvp_status_id
            LEFT JOIN rsvp_statuses ors ON ors.id = r.override_rsvp_status_id
            WHERE r.chat_event_id IN (
                SELECT ce.id FROM chat_events ce
                JOIN chats c ON c.id = ce.chat_id
                WHERE c.team_id IN (SELECT t.id FROM teams t WHERE t.club_id = )" + clubId + R"()
                   OR c.id IN (SELECT cc.chat_id FROM chat_clubs cc WHERE cc.club_id = )" + clubId + R"()
            )
            ORDER BY r.chat_event_id, COALESCE(r.override_rsvp_status_id, r.rsvp_status_id), 
                     p.last_name NULLS LAST, r.external_username
        )";

        pqxx::result rsvps = db_->query(rsvpSql);

        json << "\"rsvps\":[";
        for (size_t i = 0; i < rsvps.size(); ++i) {
            if (i > 0) json << ",";
            std::string displayName;
            if (!rsvps[i]["first_name"].is_null()) {
                displayName = std::string(rsvps[i]["first_name"].c_str()) + " " + std::string(rsvps[i]["last_name"].c_str());
            } else if (!rsvps[i]["external_username"].is_null()) {
                displayName = rsvps[i]["external_username"].c_str();
            } else {
                displayName = "Unknown";
            }
            json << "{"
                 << "\"rsvp_id\":" << rsvps[i]["rsvp_id"].c_str() << ","
                 << "\"event_id\":" << rsvps[i]["chat_event_id"].c_str() << ","
                 << "\"effective_status\":\"" << escapeJSON(rsvps[i]["effective_status"].c_str()) << "\","
                 << "\"effective_status_id\":" << rsvps[i]["effective_status_id"].c_str() << ","
                 << "\"synced_status\":\"" << escapeJSON(rsvps[i]["synced_status"].c_str()) << "\","
                 << "\"synced_status_id\":" << rsvps[i]["synced_status_id"].c_str() << ","
                 << "\"is_overridden\":" << (rsvps[i]["override_rsvp_status_id"].is_null() ? "false" : "true") << ","
                 << "\"override_note\":\"" << escapeJSON(rsvps[i]["override_note"].is_null() ? "" : rsvps[i]["override_note"].c_str()) << "\","
                 << "\"name\":\"" << escapeJSON(displayName) << "\","
                 << "\"linked\":" << (rsvps[i]["person_id"].is_null() ? "false" : "true") << ","
                 << "\"person_id\":" << (rsvps[i]["person_id"].is_null() ? "null" : rsvps[i]["person_id"].c_str())
                 << "}";
        }
        json << "]}}";

        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to get RSVP status"));
    }
}

Response EventController::handleOverrideRSVP(const Request& request) {
    try {
        // Extract rsvpId from path: /api/events/chat-rsvps/:rsvpId/override
        std::string path = request.getPath();
        std::regex rsvpIdRegex("/api/events/chat-rsvps/(\\d+)/override");
        std::smatch match;
        std::string rsvpId;
        if (std::regex_search(path, match, rsvpIdRegex)) {
            rsvpId = match[1].str();
        }
        if (rsvpId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing rsvpId"));
        }

        // Get authenticated user
        std::string userId = extractUserIdFromToken(request);
        if (userId.empty()) {
            return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Authentication required"));
        }

        // Parse body
        std::string body = request.getBody();
        std::string statusIdStr = parseJSON(body, "status_id");
        std::string note = parseJSON(body, "note");
        std::string clearStr = parseJSON(body, "clear");

        if (clearStr == "true") {
            // Clear override — revert to underlying RSVP value
            std::string clearSql = 
                "UPDATE chat_event_rsvps SET "
                "override_rsvp_status_id = NULL, "
                "overridden_by_user_id = NULL, "
                "overridden_at = NULL, "
                "override_note = NULL "
                "WHERE id = " + rsvpId;
            db_->query(clearSql);

            return Response(HttpStatus::OK, createJSONResponse(true, "Override cleared"));
        }

        if (statusIdStr.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing status_id"));
        }

        // Validate status_id exists
        std::string validateSql = "SELECT id FROM rsvp_statuses WHERE id = " + statusIdStr;
        pqxx::result validateResult = db_->query(validateSql);
        if (validateResult.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid status_id"));
        }

        // Apply override — note: escape single quotes for SQL safety
        std::string escapedNote;
        for (char c : note) {
            if (c == '\'') escapedNote += "''";
            else escapedNote += c;
        }
        
        std::string updateSql = 
            "UPDATE chat_event_rsvps SET "
            "override_rsvp_status_id = " + statusIdStr + ", "
            "overridden_by_user_id = " + userId + ", "
            "overridden_at = NOW(), "
            "override_note = " + (note.empty() ? "NULL" : "'" + escapedNote + "'") + " "
            "WHERE id = " + rsvpId + " "
            "RETURNING id, COALESCE(override_rsvp_status_id, rsvp_status_id) as effective_status_id";
        pqxx::result result = db_->query(updateSql);

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "RSVP not found"));
        }

        std::string responseData = "{\"rsvp_id\":" + rsvpId + 
            ",\"effective_status_id\":" + std::string(result[0]["effective_status_id"].c_str()) + "}";
        return Response(HttpStatus::OK, createJSONResponse(true, "Override applied", responseData));

    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to override RSVP"));
    }
}

// PUT /api/events/chat-events/:chatEventId/person-rsvp - Override practice RSVP by person_id
Response EventController::handleSetPracticeRSVP(const Request& request) {
    try {
        // Extract chatEventId from path
        std::string path = request.getPath();
        std::regex ceIdRegex("/api/events/chat-events/(\\d+)/person-rsvp");
        std::smatch match;
        std::string chatEventId;
        if (std::regex_search(path, match, ceIdRegex)) {
            chatEventId = match[1].str();
        }
        if (chatEventId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Missing chatEventId"));
        }

        std::string body = request.getBody();
        std::string personId = parseJSON(body, "person_id");
        std::string rsvpStatus = parseJSON(body, "rsvp_status");
        std::string clearStr = parseJSON(body, "clear");

        if (personId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "person_id is required"));
        }

        if (clearStr == "true") {
            // Delete admin-only rows (no external sync data behind them)
            db_->query(
                "DELETE FROM chat_event_rsvps "
                "WHERE chat_event_id = $1 AND person_id = $2 AND external_user_id IS NULL",
                {chatEventId, personId});

            // Clear override on externally-synced rows so the original value shows through
            db_->query(
                "UPDATE chat_event_rsvps SET "
                "override_rsvp_status_id = NULL, overridden_by_user_id = NULL, "
                "overridden_at = NULL, override_note = NULL "
                "WHERE chat_event_id = $1 AND person_id = $2",
                {chatEventId, personId});

            // Return the underlying synced value (if any)
            pqxx::result underlying = db_->query(
                "SELECT rs.name FROM chat_event_rsvps cer "
                "JOIN rsvp_statuses rs ON rs.id = cer.rsvp_status_id "
                "WHERE cer.chat_event_id = $1 AND cer.person_id = $2 "
                "LIMIT 1",
                {chatEventId, personId});

            std::ostringstream json;
            json << "{\"success\":true,\"message\":\"Override cleared\"";
            if (!underlying.empty()) {
                json << ",\"rsvpStatus\":\"" << escapeJSON(underlying[0][0].c_str()) << "\"";
            }
            json << "}";
            return Response(HttpStatus::OK, json.str());
        }

        if (rsvpStatus.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "rsvp_status is required"));
        }

        // Look up rsvp_status_id
        pqxx::result statusResult = db_->query(
            "SELECT id FROM rsvp_statuses WHERE name = $1", {rsvpStatus});
        if (statusResult.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid RSVP status"));
        }
        std::string statusId = statusResult[0][0].c_str();

        // Try to update existing row first (set override)
        pqxx::result updateResult = db_->query(
            "UPDATE chat_event_rsvps SET "
            "override_rsvp_status_id = $1, overridden_at = NOW() "
            "WHERE chat_event_id = $2 AND person_id = $3 "
            "RETURNING id",
            {statusId, chatEventId, personId});

        if (updateResult.empty()) {
            // No existing row — insert with override so sync doesn't overwrite
            db_->query(
                "INSERT INTO chat_event_rsvps (chat_event_id, person_id, rsvp_status_id, "
                "override_rsvp_status_id, overridden_at, responded_at) "
                "VALUES ($1, $2, $3, $3, NOW(), NOW())",
                {chatEventId, personId, statusId});
        }

        std::cout << "\u2705 Practice RSVP set for person " << personId << " event " << chatEventId << " -> " << rsvpStatus << std::endl;

        std::ostringstream json;
        json << "{\"success\":true,\"rsvpStatus\":\"" << escapeJSON(rsvpStatus) << "\"}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "\u274c Error setting practice RSVP: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to set practice RSVP"));
    }
}

// ============================================================================
// POST /api/matches/team/:teamId/sync-league
// Sync match scores from the league website (SportsEngine API for CASA teams)
// ============================================================================

static size_t LeagueSyncWriteCallback(void* contents, size_t size, size_t nmemb, std::string* out) {
    size_t total = size * nmemb;
    out->append(static_cast<char*>(contents), total);
    return total;
}

static std::string leagueHttpGet(const std::string& url) {
    CURL* curl = curl_easy_init();
    if (!curl) return "";
    std::string buf;
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, LeagueSyncWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buf);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    struct curl_slist* headers = nullptr;
    headers = curl_slist_append(headers, "Accept: application/json");
    headers = curl_slist_append(headers, "User-Agent: Mozilla/5.0 (compatible; FootballHome/1.0)");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    CURLcode res = curl_easy_perform(curl);
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    if (res != CURLE_OK || httpCode != 200) return "";
    return buf;
}

// Minimal JSON helpers — find a scalar value by key in a flat JSON string
static std::string jsonStr(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\":\"";
    auto pos = json.find(search);
    if (pos == std::string::npos) return "";
    pos += search.size();
    auto end = json.find('"', pos);
    if (end == std::string::npos) return "";
    return json.substr(pos, end - pos);
}

static std::string jsonVal(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\":";
    auto pos = json.find(search);
    if (pos == std::string::npos) return "";
    pos += search.size();
    while (pos < json.size() && json[pos] == ' ') pos++;
    auto end = pos;
    while (end < json.size() && json[end] != ',' && json[end] != '}' && json[end] != ']') end++;
    std::string v = json.substr(pos, end - pos);
    if (!v.empty() && v.front() == '"') { v = v.substr(1); if (!v.empty() && v.back() == '"') v.pop_back(); }
    return v;
}

Response EventController::handleSyncLeague(const Request& request) {
    try {
        std::string user_id = extractUserIdFromToken(request);
        if (user_id.empty()) {
            return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Unauthorized"));
        }

        std::string path = request.getPath();
        std::regex re("/api/matches/team/(\\d+)/sync-league");
        std::smatch m;
        if (!std::regex_search(path, m, re)) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid team ID"));
        }
        std::string teamId = m[1].str();

        // Determine source system for this team
        auto ssResult = db_->query(
            "SELECT DISTINCT ss.name as ss_name "
            "FROM matches mt "
            "JOIN source_systems ss ON ss.id = mt.source_system_id "
            "WHERE (mt.home_team_id = $1::int OR mt.away_team_id = $1::int) "
            "AND ss.name IN ('casa','apsl') "
            "LIMIT 1",
            {teamId});

        if (ssResult.empty()) {
            return Response(HttpStatus::OK,
                "{\"success\":false,\"message\":\"No league data found for this team\"}");
        }
        std::string sourceSystem = ssResult[0]["ss_name"].c_str();

        if (sourceSystem == "apsl") {
            // Delegate to host task server (runs Chrome/Puppeteer scraper)
            // Use long timeout — scraper can take 2-3 minutes
            std::string taskUrl = "http://10.89.0.1:3002/run-task?task=apsl-team";
            CURL* taskCurl = curl_easy_init();
            std::string taskResp;
            if (taskCurl) {
                curl_easy_setopt(taskCurl, CURLOPT_URL, taskUrl.c_str());
                curl_easy_setopt(taskCurl, CURLOPT_WRITEFUNCTION, LeagueSyncWriteCallback);
                curl_easy_setopt(taskCurl, CURLOPT_WRITEDATA, &taskResp);
                curl_easy_setopt(taskCurl, CURLOPT_TIMEOUT, 200L);
                curl_easy_setopt(taskCurl, CURLOPT_FOLLOWLOCATION, 1L);
                curl_easy_perform(taskCurl);
                curl_easy_cleanup(taskCurl);
            }
            if (taskResp.find("\"success\":true") != std::string::npos) {
                return Response(HttpStatus::OK,
                    "{\"success\":true,\"message\":\"APSL sync complete — scores updated from league website\"}");
            }
            // Task server not reachable or failed
            std::string errMsg = "APSL sync failed";
            auto msgPos = taskResp.find("\"message\":\"");
            if (msgPos != std::string::npos) {
                msgPos += 11;
                auto msgEnd = taskResp.find('"', msgPos);
                if (msgEnd != std::string::npos) errMsg = taskResp.substr(msgPos, msgEnd - msgPos);
            }
            return Response(HttpStatus::OK,
                "{\"success\":false,\"message\":\"" + errMsg + "\"}");
        }

        // CASA: determine which programId(s) to call
        // Philadelphia Liga 1 (team 120) → 6827a0840b95c8019f7e2b38
        // Philadelphia Liga 2 (team 121) → 682f9676528c0e00bfc9d2f2
        // We look up the team against known division IDs in the DB
        auto divResult = db_->query(
            "SELECT d.external_id "
            "FROM matches mt "
            "JOIN source_systems ss ON ss.id = mt.source_system_id "
            "JOIN divisions d ON (mt.title ILIKE '%' || d.name || '%' OR "
            "  EXISTS (SELECT 1 FROM matches m2 "
            "          JOIN division_matches dm ON dm.match_id = m2.id "
            "          WHERE m2.id = mt.id AND dm.division_id = d.id)) "
            "WHERE (mt.home_team_id = $1::int OR mt.away_team_id = $1::int) "
            "AND ss.name = 'casa' "
            "AND d.external_id IS NOT NULL "
            "LIMIT 1",
            {teamId});

        // Fallback: map by team ID directly
        std::string programId;
        std::string divisionName;
        int teamIdInt = std::stoi(teamId);
        if (teamIdInt == 120) {
            programId = "6827a0840b95c8019f7e2b38";
            divisionName = "Philadelphia Liga 1";
        } else if (teamIdInt == 121) {
            programId = "682f9676528c0e00bfc9d2f2";
            divisionName = "Philadelphia Liga 2";
        } else {
            return Response(HttpStatus::OK,
                "{\"success\":false,\"message\":\"Unknown CASA team — cannot determine program ID\"}");
        }

        // Call SportsEngine API (paginated)
        int updated = 0, notFound = 0, totalEvents = 0;
        for (int page = 1; page <= 5; page++) {
            std::string url = "https://se-api.sportsengine.com/v3/microsites/events"
                "?page=" + std::to_string(page) +
                "&per_page=100&program_id=" + programId +
                "&order_by=starts_at&direction=asc";
            std::string body = leagueHttpGet(url);
            if (body.empty()) break;

            // Count events and check pagination
            auto metaPos = body.find("\"totalPages\":");
            int totalPages = 1;
            if (metaPos != std::string::npos) {
                std::string tp = jsonVal(body.substr(metaPos - 1), "totalPages");
                if (!tp.empty()) try { totalPages = std::stoi(tp); } catch (...) {}
            }

            // Find each game event block
            size_t pos = 0;
            while (true) {
                auto evStart = body.find("\"event_type\":\"game\"", pos);
                if (evStart == std::string::npos) break;

                // Walk back to find the enclosing object start
                auto objStart = body.rfind('{', evStart);
                if (objStart == std::string::npos) { pos = evStart + 1; continue; }

                // Extract event ID
                std::string evId = jsonStr(body.substr(objStart, evStart - objStart + 200), "id");
                if (evId.empty()) { pos = evStart + 1; continue; }

                // Scores are in source.extended_attributes
                // Search within 5000 chars after event_type for extended_attributes
                size_t searchEnd = std::min(body.size(), evStart + 5000);
                auto extPos = body.find("\"extended_attributes\":", evStart);
                if (extPos == std::string::npos || extPos > searchEnd) { pos = evStart + 1; continue; }
                auto extStart = body.find('{', extPos);
                if (extStart == std::string::npos) { pos = evStart + 1; continue; }
                // Find closing brace for extended_attributes (scan up to 1000 chars)
                size_t extEnd = std::min(body.size(), extStart + 1000);
                std::string extBlock = body.substr(extStart, extEnd - extStart);

                std::string homeScoreStr = jsonStr(extBlock, "home_team_score");
                std::string awayScoreStr = jsonStr(extBlock, "away_team_score");

                pos = evStart + 1;
                totalEvents++;

                // Only update if both scores present
                if (homeScoreStr.empty() || homeScoreStr == "null" ||
                    awayScoreStr.empty() || awayScoreStr == "null") continue;

                int homeScore = 0, awayScore = 0;
                try { homeScore = std::stoi(homeScoreStr); } catch (...) { continue; }
                try { awayScore = std::stoi(awayScoreStr); } catch (...) { continue; }

                // Update match by external_id
                auto upd = db_->query(
                    "UPDATE matches SET home_score = $1, away_score = $2 "
                    "WHERE external_id = $3 "
                    "AND (home_score IS DISTINCT FROM $1 OR away_score IS DISTINCT FROM $2) "
                    "RETURNING id",
                    {std::to_string(homeScore), std::to_string(awayScore), evId});
                if (!upd.empty()) updated++;
                else notFound++;
            }

            if (page >= totalPages) break;
        }

        std::ostringstream result;
        result << "{\"success\":true,\"updated\":" << updated
               << ",\"skipped\":" << notFound
               << ",\"totalEvents\":" << totalEvents
               << ",\"division\":\"" << divisionName << "\"}";
        return Response(HttpStatus::OK, result.str());

    } catch (const std::exception& e) {
        std::cerr << "\u274c handleSyncLeague error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Sync failed"));
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/matches/:matchId/rsvp-summary
//
// Returns compact aggregate counts for the Practice/Pickup Dashboard row
// badges (no per-player data — that's what /api/events/:eventId/rsvps is
// for).  Shape:
//   {
//     "success": true,
//     "match_id": 9218,
//     "rsvp":       {"yes": 12, "maybe": 3, "no": 1},
//     "attendance": {"present": 8, "absent": 1}
//   }
//
// Notes:
//  • RSVP counts come from the `player_rsvps_current` view (latest status
//    per player per event).
//  • Attendance counts read `training_attendance` — only rows where
//    `attended = true` count as present, `attended = false` as absent.
//    Rows missing entirely are the "not yet marked" set (not returned;
//    frontend derives it from total_expected − present − absent if it
//    knows the denominator).
// ────────────────────────────────────────────────────────────────────────────
Response EventController::handleGetMatchRsvpSummary(const Request& request) {
    try {
        const std::string matchIdStr = extractMatchIdFromPath(request.getPath());
        if (matchIdStr.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid matchId in path"));
        }

        // Single query — aggregates both RSVP and attendance in one pass.
        // FILTER (...) is postgres-native and cheaper than 6 subselects.
        const std::string q =
            "WITH r AS ("
            "  SELECT rsvp_status_id FROM player_rsvps_current WHERE event_id = $1::int"
            "), a AS ("
            "  SELECT attended FROM training_attendance WHERE match_id = $1::int"
            ") "
            "SELECT "
            "  (SELECT COUNT(*) FROM r WHERE rsvp_status_id = 1) AS yes,"
            "  (SELECT COUNT(*) FROM r WHERE rsvp_status_id = 2) AS no,"
            "  (SELECT COUNT(*) FROM r WHERE rsvp_status_id = 3) AS maybe,"
            "  (SELECT COUNT(*) FROM a WHERE attended = true)    AS present,"
            "  (SELECT COUNT(*) FROM a WHERE attended = false)   AS absent";
        auto rows = db_->query(q, {matchIdStr});
        if (rows.empty()) {
            // Should never happen (aggregates always return 1 row) but
            // return zeros anyway so the frontend contract is stable.
            std::ostringstream out;
            out << "{\"success\":true,\"match_id\":" << matchIdStr
                << ",\"rsvp\":{\"yes\":0,\"maybe\":0,\"no\":0}"
                << ",\"attendance\":{\"present\":0,\"absent\":0}}";
            return Response(HttpStatus::OK, out.str());
        }
        const auto& r = rows[0];
        std::ostringstream out;
        out << "{\"success\":true,\"match_id\":" << matchIdStr
            << ",\"rsvp\":{"
            << "\"yes\":"   << r["yes"].c_str()   << ","
            << "\"maybe\":" << r["maybe"].c_str() << ","
            << "\"no\":"    << r["no"].c_str()
            << "},\"attendance\":{"
            << "\"present\":" << r["present"].c_str() << ","
            << "\"absent\":"  << r["absent"].c_str()
            << "}}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetMatchRsvpSummary error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Failed to get summary: ") + e.what()));
    }
}
