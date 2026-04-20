#include "EventController.h"
#include "../core/TwilioSMSService.h"
#include "../database/SqlFileLogger.h"
#include "../database/SqlBuilder.h"
#include <sstream>
#include <regex>
#include <ctime>
#include <iomanip>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>
#include <curl/curl.h>

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
    
    // POST /api/events/:eventId/send-reminder - Send SMS reminder to a player
    router.post(prefix + "/:eventId/send-reminder", [this](const Request& request) {
        return this->handleSendReminder(request);
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

    // POST /api/matches/apsl/refresh - Trigger APSL score scrape (coach/admin only)
    router.post("/api/matches/apsl/refresh", [this](const Request& request) {
        return this->handleRefreshAPSLScores(request);
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
        
        // Query matches where team is home or away
        // matches extends events (matches.id = events.id FK)
        // Show: all upcoming matches + completed matches
        // Include has_ended flag so frontend knows whether to show RSVP buttons
        std::ostringstream query;
        query << "SELECT m.id, COALESCE(e.title, CONCAT(ht.name, ' vs ', awt.name)) as title, ";
        query << "e.event_date::text as event_date, ";
        query << "COALESCE(e.duration_minutes, 90) as duration_minutes, et.name as event_type, ";
        query << "m.home_team_score, m.away_team_score, ";
        query << "m.match_status, m.competition_name, v.name as venue_name, ";
        query << "CASE WHEN m.match_status = 'completed' THEN true ";
        query << "WHEN e.event_date < NOW() - INTERVAL '90 minutes' THEN true ";
        query << "ELSE false END as has_ended, ";
        query << "ht.logo_url as home_team_logo, awt.logo_url as away_team_logo ";
        query << "FROM matches m ";
        query << "JOIN events e ON m.id = e.id ";
        query << "LEFT JOIN event_types et ON e.event_type_id = et.id ";
        query << "LEFT JOIN venues v ON e.venue_id = v.id ";
        query << "LEFT JOIN teams ht ON m.home_team_id = ht.id ";
        query << "LEFT JOIN teams awt ON m.away_team_id = awt.id ";
        query << "WHERE (m.home_team_id = '" << team_id << "' OR m.away_team_id = '" << team_id << "') ";
        query << "ORDER BY e.event_date ASC ";
        query << "LIMIT 100";
        
        pqxx::result result = db_->query(query.str());
        
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
        query << "SELECT m.id, COALESCE(e.title, CONCAT(ht.name, ' vs ', awt.name)) as title, ";
        query << "e.event_date::text as event_date, ";
        query << "COALESCE(e.duration_minutes, 90) as duration_minutes, e.venue_id, ";
        query << "m.home_team_id, m.away_team_id, m.competition_name, ";
        query << "m.match_status, ";
        query << "m.home_team_score, m.away_team_score, ";
        query << "e.description as notes, ";
        query << "v.name as venue_name, ";
        query << "ht.name as home_team_name, awt.name as away_team_name, ";
        query << "ht.logo_url as home_team_logo, awt.logo_url as away_team_logo, ";
        query << "'' as source_name, ";
        query << "v.address as venue_address, v.city as venue_city, v.state as venue_state, '' as venue_zip, ";
        query << "et.name as division_name ";
        query << "FROM matches m ";
        query << "JOIN events e ON m.id = e.id ";
        query << "LEFT JOIN event_types et ON e.event_type_id = et.id ";
        query << "LEFT JOIN venues v ON e.venue_id = v.id ";
        query << "LEFT JOIN teams ht ON m.home_team_id = ht.id ";
        query << "LEFT JOIN teams awt ON m.away_team_id = awt.id ";
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
        
        std::cout << "🗑️ Deleting match: " << match_id << std::endl;
        
        // Delete from matches table first (FK constraint)
        db_->query("DELETE FROM matches WHERE id = '" + match_id + "'");
        
        // Delete from events table (cascades to RSVPs, etc.)
        db_->query("DELETE FROM events WHERE id = '" + match_id + "'");
        
        std::string json = createJSONResponse(true, "Match deleted successfully");
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleDeleteMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, "Failed to delete match");
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

std::string EventController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
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

std::string EventController::escapeJSON(const std::string& str) {
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
        
        // Check if event has ended (event_date + duration has passed)
        std::string event_ended_query = R"(
            SELECT CASE 
                WHEN (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) < NOW()
                THEN true ELSE false 
            END as has_ended
            FROM events e
            JOIN event_types et ON e.event_type_id = et.id
            WHERE e.id = $1
        )";
        pqxx::result event_check = db_->query(event_ended_query, {event_id});
        
        if (event_check.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Event not found"));
        }
        
        bool has_ended = event_check[0]["has_ended"].as<bool>();
        if (has_ended) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "This event has ended. RSVPs are no longer accepted."));
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
        // Use database uuid_generate_v4() for reliable UUID generation
        std::string insert_query = "INSERT INTO " + table_name + " (id, event_id, " + id_column + ", rsvp_status_id, changed_by, change_source_id, notes, changed_at) "
                                   "VALUES (uuid_generate_v4(), $1, $2, $3, $4, (SELECT id FROM rsvp_change_sources WHERE name = 'app'), $5, CURRENT_TIMESTAMP) RETURNING id";
        pqxx::result rsvp_result = db_->query(insert_query, {event_id, user_id, rsvp_status_id, user_id, notes});
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
            
            std::string query = "SELECT r.event_id, r." + id_column + " as user_id, rs.name as status, r.notes, r.changed_at as response_date, "
                               "p.first_name, p.last_name, COALESCE(p.first_name, '') as preferred_name, COALESCE(pe.email, '') as email, '' as avatar_url "
                               "FROM " + view_name + " r "
                               "JOIN users u ON r." + id_column + " = u.id "
                               "JOIN persons p ON u.person_id = p.id "
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
    std::cout << "📋 Getting attendance statuses..." << std::endl;
    
    try {
        std::string query = "SELECT id, name, display_name, sort_order, color FROM attendance_statuses ORDER BY sort_order";
        pqxx::result result = db_->query(query, {});
        
        std::ostringstream json_array;
        json_array << "[";
        
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json_array << ",";
            
            std::string color = result[i]["color"].is_null() ? "" : result[i]["color"].c_str();
            
            json_array << "{"
                      << "\"id\": " << result[i]["id"].as<int>() << ", "
                      << "\"name\": \"" << escapeJSON(result[i]["name"].c_str()) << "\", "
                      << "\"display_name\": \"" << escapeJSON(result[i]["display_name"].c_str()) << "\", "
                      << "\"sort_order\": " << result[i]["sort_order"].as<int>() << ", "
                      << "\"color\": \"" << escapeJSON(color) << "\""
                      << "}";
        }
        
        json_array << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Attendance statuses retrieved", json_array.str()));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting attendance statuses: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to get attendance statuses"));
    }
}

Response EventController::handleGetEventAttendance(const Request& request) {
    std::cout << "📋 Getting event attendance..." << std::endl;
    
    std::string event_id = extractEventIdFromPath(request.getPath());
    if (event_id.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Event ID is required"));
    }
    
    try {
        std::string query = R"(
            SELECT 
                ea.id,
                ea.event_id,
                ea.player_id,
                p.first_name,
                p.last_name,
                '' as preferred_name,
                COALESCE(pe.email, '') as email,
                COALESCE(pl.photo_url, '') as avatar_url,
                ats.id as status_id,
                ats.name as status_name,
                ats.display_name as status_display_name,
                ats.color as status_color,
                rs.name as rsvp_snapshot,
                ea.notes,
                ea.created_at,
                ea.updated_at,
                upd_p.first_name as updated_by_first_name,
                upd_p.last_name as updated_by_last_name
            FROM event_attendance ea
            JOIN users u ON ea.player_id = u.id
            JOIN persons p ON u.person_id = p.id
            LEFT JOIN person_emails pe ON pe.person_id = p.id AND pe.is_primary = true
            LEFT JOIN players pl ON pl.person_id = p.id
            JOIN attendance_statuses ats ON ea.status_id = ats.id
            LEFT JOIN rsvp_statuses rs ON ea.rsvp_snapshot_id = rs.id
            LEFT JOIN users upd ON ea.updated_by = upd.id
            LEFT JOIN persons upd_p ON upd.person_id = upd_p.id
            WHERE ea.event_id = $1
            ORDER BY p.last_name, p.first_name
        )";
        
        pqxx::result result = db_->query(query, {event_id});
        
        std::ostringstream json_array;
        json_array << "[";
        
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json_array << ",";
            
            std::string notes = result[i]["notes"].is_null() ? "" : result[i]["notes"].c_str();
            std::string rsvp_snapshot = result[i]["rsvp_snapshot"].is_null() ? "" : result[i]["rsvp_snapshot"].c_str();
            std::string status_color = result[i]["status_color"].is_null() ? "" : result[i]["status_color"].c_str();
            std::string avatar_url = result[i]["avatar_url"].is_null() ? "" : result[i]["avatar_url"].c_str();
            std::string updated_by_name = "";
            if (!result[i]["updated_by_first_name"].is_null()) {
                updated_by_name = std::string(result[i]["updated_by_first_name"].c_str()) + " " + result[i]["updated_by_last_name"].c_str();
            }
            
            json_array << "{"
                      << "\"id\": \"" << result[i]["id"].c_str() << "\", "
                      << "\"event_id\": \"" << result[i]["event_id"].c_str() << "\", "
                      << "\"player_id\": \"" << result[i]["player_id"].c_str() << "\", "
                      << "\"player_name\": \"" << escapeJSON(result[i]["first_name"].c_str()) << " " << escapeJSON(result[i]["last_name"].c_str()) << "\", "
                      << "\"player_email\": \"" << escapeJSON(result[i]["email"].c_str()) << "\", "
                      << "\"photoUrl\": \"" << escapeJSON(avatar_url) << "\", "
                      << "\"status_id\": " << result[i]["status_id"].as<int>() << ", "
                      << "\"status_name\": \"" << escapeJSON(result[i]["status_name"].c_str()) << "\", "
                      << "\"status_display_name\": \"" << escapeJSON(result[i]["status_display_name"].c_str()) << "\", "
                      << "\"status_color\": \"" << escapeJSON(status_color) << "\", "
                      << "\"rsvp_snapshot\": \"" << escapeJSON(rsvp_snapshot) << "\", "
                      << "\"notes\": \"" << escapeJSON(notes) << "\", "
                      << "\"updated_by\": \"" << escapeJSON(updated_by_name) << "\", "
                      << "\"created_at\": \"" << result[i]["created_at"].c_str() << "\", "
                      << "\"updated_at\": \"" << result[i]["updated_at"].c_str() << "\""
                      << "}";
        }
        
        json_array << "]";
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Attendance retrieved", json_array.str()));
        
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
        
        // TODO: Verify user is a coach for this event's team
        
        std::string query;
        pqxx::result result;
        
        if (updated_by.empty()) {
            // No updated_by provided
            query = R"(
                UPDATE event_attendance 
                SET status_id = $1, 
                    notes = $2, 
                    updated_at = NOW()
                WHERE id = $3
                RETURNING id
            )";
            result = db_->query(query, {std::to_string(status_id), notes, attendance_id});
        } else {
            query = R"(
                UPDATE event_attendance 
                SET status_id = $1, 
                    notes = $2, 
                    updated_at = NOW(), 
                    updated_by = $3
                WHERE id = $4
                RETURNING id
            )";
            result = db_->query(query, {std::to_string(status_id), notes, updated_by, attendance_id});
        }
        
        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Attendance record not found"));
        }
        
        // Log to ##u or ##p file
        std::map<std::string, std::string> columns = {
            {"status_id", std::to_string(status_id)},
            {"notes", notes}
        };
        if (!updated_by.empty()) {
            columns["updated_by"] = updated_by;
        }
        std::string upsert_sql = SqlBuilder::buildUpsert("event_attendance", attendance_id, columns);
        SqlFileLogger::log("event_attendance", upsert_sql);
        
        std::cout << "✅ Attendance updated: " << attendance_id << std::endl;
        
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
            "SELECT e.event_date FROM matches m JOIN events e ON m.id = e.id WHERE m.id = $1", {matchId});
        std::string matchDate = "9999-12-31";
        if (!matchDateResult.empty()) {
            matchDate = matchDateResult[0]["event_date"].c_str();
        }

        // Last 5 training + pickup events before the match date (requires chat_events table)
        pqxx::result trainingEvents;
        std::vector<int> teIds;
        try {
            std::string trainingQuery = R"(
                SELECT id, title, event_date
                FROM chat_events
                WHERE chat_id IN (4, 5) AND is_active = true
                  AND event_date < $1
                ORDER BY event_date DESC, event_time DESC
                LIMIT 5
            )";
            trainingEvents = db_->query(trainingQuery, {matchDate});
            for (const auto& te : trainingEvents) {
                teIds.push_back(te["id"].as<int>());
            }
        } catch (...) {
            // chat_events table not available — skip training RSVP data
        }

        // Find the chat_event for this match (GroupMe RSVP source)
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
            // chat_events table not available — skip GroupMe RSVP lookup
        }

        // Get all players from the home team roster with enriched data
        // RSVP priority: admin override (player_rsvps_current) > GroupMe RSVP (chat_event_rsvps)
        std::string query = R"(
            SELECT DISTINCT
                p.id as player_id,
                pe.id as person_id,
                pe.first_name,
                pe.last_name,
                false::boolean as is_keeper,
                false::boolean as has_family_discount,
                NULL::text as position,
                CASE WHEN ml.id IS NOT NULL THEN true ELSE false END as on_game_roster,
                COALESCE(r.jersey_number::text, '') as jersey_number,
                r.team_id as roster_team_id,
                -- Admin override RSVP (player_rsvps_current not available — use NULL)
                NULL::int as admin_rsvp_id,
                NULL::text as admin_rsvp,
                -- GroupMe RSVP (chat tables not available — use NULL)
                NULL::text as gm_rsvp,
                -- Individual chat memberships (chat_external_members not available)
                false::boolean as in_chat_apsl,
                false::boolean as in_chat_casa,
                false::boolean as in_chat_u23,
                -- Individual roster memberships (using team names for UUID lookup)
                EXISTS(SELECT 1 FROM team_players r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC') AND r2.left_at IS NULL AND r2.is_active = true) as on_roster_lighthouse,
                EXISTS(SELECT 1 FROM team_players r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse Boys Club') AND r2.left_at IS NULL AND r2.is_active = true) as on_roster_casa,
                EXISTS(SELECT 1 FROM team_players r2 WHERE r2.player_id = p.id AND r2.team_id = (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers') AND r2.left_at IS NULL AND r2.is_active = true) as on_roster_u23
            FROM matches m
            JOIN team_players r ON r.team_id = CASE WHEN $2 <> '' THEN $2::uuid ELSE m.home_team_id END AND r.left_at IS NULL AND r.is_active = true
            JOIN players p ON r.player_id = p.id
            JOIN persons pe ON pe.id = p.person_id
            LEFT JOIN match_lineups ml ON ml.match_id = m.id AND ml.player_id = p.id
            WHERE m.id = $1
            ORDER BY pe.last_name, pe.first_name
        )";

        pqxx::result result = db_->query(query, {matchId, teamIdParam});

        // Build practice map (person_id -> array of RSVPs for last 5 trainings)
        std::map<int, std::vector<std::string>> practiceMap;
        std::map<int, std::vector<bool>> practiceOverrideMap;
        if (!teIds.empty()) {
            std::string practiceQuery = R"(
                SELECT DISTINCT ON (person_id, chat_event_id)
                       person_id,
                       chat_event_id,
                       rsvp,
                       is_override
                FROM (
                    -- Rows matched via external_user_id -> chat_external_members
                    SELECT cem2.person_id,
                           cer.chat_event_id,
                           COALESCE(
                               (SELECT rs2.name FROM rsvp_statuses rs2 WHERE rs2.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id)),
                               ''
                           ) as rsvp,
                           (cer.override_rsvp_status_id IS NOT NULL) as is_override
                    FROM chat_event_rsvps cer
                    JOIN chat_external_members cem2 ON cem2.external_user_id = cer.external_user_id
                        AND cem2.person_id IS NOT NULL
                    WHERE cer.chat_event_id = ANY($1)
                    UNION
                    -- Rows inserted directly with person_id (admin overrides)
                    SELECT cer.person_id,
                           cer.chat_event_id,
                           COALESCE(
                               (SELECT rs2.name FROM rsvp_statuses rs2 WHERE rs2.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id)),
                               ''
                           ) as rsvp,
                           true as is_override
                    FROM chat_event_rsvps cer
                    WHERE cer.chat_event_id = ANY($1)
                      AND cer.person_id IS NOT NULL
                      AND cer.external_user_id IS NULL
                ) combined
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

            // RSVP: admin override wins, else GM rsvp, else null
            bool hasAdminRsvp = !row["admin_rsvp"].is_null();
            bool hasGmRsvp = !row["gm_rsvp"].is_null();
            std::string effectiveRsvp = "";
            std::string rsvpSource = "";
            if (hasAdminRsvp) {
                effectiveRsvp = row["admin_rsvp"].c_str();
                rsvpSource = "admin";
            } else if (hasGmRsvp) {
                effectiveRsvp = row["gm_rsvp"].c_str();
                rsvpSource = "groupme";
            }

            json << "{";
            json << "\"playerId\":\"" << row["player_id"].c_str() << "\",";
            json << "\"personId\":" << personId << ",";
            json << "\"firstName\":\"" << escapeJSON(row["first_name"].c_str()) << "\",";
            json << "\"lastName\":\"" << escapeJSON(row["last_name"].c_str()) << "\",";
            json << "\"isKeeper\":" << (row["is_keeper"].as<bool>() ? "true" : "false") << ",";
            json << "\"hasFamilyDiscount\":" << (row["has_family_discount"].as<bool>() ? "true" : "false") << ",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"") << ",";
            json << "\"rsvpStatus\":" << (effectiveRsvp.empty() ? "null" : "\"" + effectiveRsvp + "\"") << ",";
            json << "\"rsvpSource\":" << (rsvpSource.empty() ? "null" : "\"" + rsvpSource + "\"") << ",";
            json << "\"onGameRoster\":" << (row["on_game_roster"].as<bool>() ? "true" : "false") << ",";
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
            json << "{\"id\":" << trainingEvents[(int)i]["id"].c_str();
            json << ",\"title\":\"" << escapeJSON(trainingEvents[(int)i]["title"].c_str()) << "\"";
            json << ",\"date\":\"" << trainingEvents[(int)i]["event_date"].c_str() << "\"}";
        }
        json << "],\"count\":" << result.size() << "}";
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

Response EventController::handleSendReminder(const Request& request) {
    std::string eventId = extractEventIdFromPath(request.getPath());
    if (eventId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Event ID is required"));
    }
    
    try {
        std::string body = request.getBody();
        std::string playerId = parseJSON(body, "player_id");
        
        if (playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "player_id is required"));
        }
        
        std::cout << "📲 Sending SMS reminder for event " << eventId << " to player " << playerId << std::endl;
        
        // Get event details and player phone
        std::string query = R"(
            SELECT 
                e.title,
                e.event_date,
                e.duration_minutes,
                v.name as venue_name,
                v.address as venue_address,
                p.first_name,
                pp.phone_number as phone
            FROM events e
            LEFT JOIN venues v ON e.venue_id = v.id
            JOIN users u ON u.id = $1
            JOIN persons p ON u.person_id = p.id
            LEFT JOIN person_phones pp ON pp.person_id = p.id AND pp.is_primary = true
            WHERE e.id = $2
        )";
        
        pqxx::result result = db_->query(query, {playerId, eventId});
        
        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Event or player not found"));
        }
        
        auto row = result[0];
        
        if (row["phone"].is_null()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Player has no phone number on file"));
        }
        
        std::string phone = row["phone"].as<std::string>();
        std::string firstName = row["first_name"].as<std::string>();
        std::string title = row["title"].as<std::string>();
        std::string eventDate = row["event_date"].as<std::string>();
        std::string venueName = row["venue_name"].is_null() ? "TBD" : row["venue_name"].as<std::string>();
        
        // Parse event date/time (format: YYYY-MM-DD HH:MM:SS)
        std::string dateStr = eventDate.substr(0, 10);  // YYYY-MM-DD
        std::string timeStr = eventDate.substr(11, 5);  // HH:MM
        
        // Format message
        std::ostringstream message;
        message << "Hi " << firstName << "! Reminder: " << title 
                << " on " << dateStr << " at " << timeStr;
        if (venueName != "TBD") {
            message << " at " << venueName;
        }
        message << ". See you there! ⚽";
        
        // Send SMS
        bool success = TwilioSMSService::getInstance().sendSMS(phone, message.str());
        
        if (success) {
            std::cout << "✅ SMS sent successfully to " << phone << std::endl;
            return Response(HttpStatus::OK, createJSONResponse(true, "SMS reminder sent successfully"));
        } else {
            std::cerr << "❌ Failed to send SMS to " << phone << std::endl;
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to send SMS"));
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error sending reminder: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Failed to send reminder"));
    }
}

// Helper function to decode base64url
static std::string base64UrlDecode(const std::string& input) {
    std::string base64 = input;
    
    // Convert base64url to base64
    for (size_t i = 0; i < base64.length(); ++i) {
        if (base64[i] == '-') base64[i] = '+';
        else if (base64[i] == '_') base64[i] = '/';
    }
    
    // Add padding if necessary
    while (base64.length() % 4 != 0) {
        base64 += '=';
    }
    
    // Decode base64
    BIO *bio, *b64;
    char *buffer = new char[base64.length()];
    
    bio = BIO_new_mem_buf(base64.c_str(), base64.length());
    b64 = BIO_new(BIO_f_base64());
    bio = BIO_push(b64, bio);
    
    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
    int decoded_length = BIO_read(bio, buffer, base64.length());
    BIO_free_all(bio);
    
    std::string result(buffer, decoded_length);
    delete[] buffer;
    
    return result;
}

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
            std::string payload = base64UrlDecode(payload_encoded);
            
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
                   (SELECT COUNT(*) FROM chat_event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND COALESCE(r.override_rsvp_status_id, r.rsvp_status_id) = 1) as going_count,
                   (SELECT COUNT(*) FROM chat_event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND COALESCE(r.override_rsvp_status_id, r.rsvp_status_id) = 2) as not_going_count,
                   (SELECT COUNT(*) FROM chat_event_rsvps r WHERE r.chat_event_id = ce.id 
                    AND COALESCE(r.override_rsvp_status_id, r.rsvp_status_id) = 3) as maybe_count,
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
            // Clear override — revert to GroupMe synced value
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
            // Delete admin-only rows (no GroupMe data behind them)
            db_->query(
                "DELETE FROM chat_event_rsvps "
                "WHERE chat_event_id = $1 AND person_id = $2 AND external_user_id IS NULL",
                {chatEventId, personId});

            // Clear override on GroupMe-synced rows so the original value shows through
            db_->query(
                "UPDATE chat_event_rsvps SET "
                "override_rsvp_status_id = NULL, overridden_by_user_id = NULL, "
                "overridden_at = NULL, override_note = NULL "
                "WHERE chat_event_id = $1 AND person_id = $2",
                {chatEventId, personId});

            // Return the underlying GroupMe value (if any)
            pqxx::result underlying = db_->query(
                "SELECT rs.name FROM chat_event_rsvps cer "
                "JOIN rsvp_statuses rs ON rs.id = cer.rsvp_status_id "
                "WHERE cer.chat_event_id = $1 AND cer.person_id = $2 "
                "LIMIT 1",
                {chatEventId, personId});

            std::ostringstream json;
            json << "{\"success\":true,\"message\":\"Released to GroupMe\"";
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

// ─── APSL score refresh ───────────────────────────────────────────────────────
static size_t eventCurlWriteCallback(void* contents, size_t size, size_t nmemb, std::string* out) {
    size_t total = size * nmemb;
    out->append(static_cast<char*>(contents), total);
    return total;
}

Response EventController::handleRefreshAPSLScores(const Request& request) {
    // Require authentication — coaches and admins only
    std::string userId = extractUserIdFromToken(request);
    if (userId.empty()) {
        return Response(HttpStatus::UNAUTHORIZED,
            createJSONResponse(false, "Authentication required"));
    }

    CURL* curl = curl_easy_init();
    if (!curl) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to initialize HTTP client"));
    }

    std::string responseBody;
    // Scraper runs with network_mode:host, reachable via host gateway
    curl_easy_setopt(curl, CURLOPT_URL, "http://host.docker.internal:3010/refresh");
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, "");
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, 0L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, eventCurlWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBody);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 120L);  // scraping + DB write can take ~60s
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 5L);

    CURLcode res = curl_easy_perform(curl);
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        std::cerr << "❌ APSL refresh: scraper unreachable — " << curl_easy_strerror(res) << std::endl;
        return Response(HttpStatus::SERVICE_UNAVAILABLE,
            createJSONResponse(false, std::string("Scraper service unavailable: ") + curl_easy_strerror(res)));
    }

    std::cout << "🔄 APSL refresh: scraper returned HTTP " << httpCode << std::endl;

    if (httpCode == 200) {
        Response r(HttpStatus::OK, responseBody);
        r.setHeader("Content-Type", "application/json");
        return r;
    } else if (httpCode == 409) {
        Response r(HttpStatus::CONFLICT, responseBody);
        r.setHeader("Content-Type", "application/json");
        return r;
    } else {
        Response r(HttpStatus::INTERNAL_SERVER_ERROR, responseBody);
        r.setHeader("Content-Type", "application/json");
        return r;
    }
}