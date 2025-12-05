#include "EventController.h"
#include <sstream>
#include <regex>
#include <ctime>
#include <iomanip>

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
    
    // GET /api/matches/:matchId/eligible-players - Get players who RSVP'd attending
    router.get("/api/matches/:matchId/eligible-players", [this](const Request& request) {
        return this->handleGetEligiblePlayers(request);
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
        
        // Get created_by user (for now, use the system admin user)
        std::string created_by = "77d77471-1250-47e0-81ab-d4626595d63c";
        
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
        std::ostringstream event_query;
        event_query << "INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, created_at, updated_at) ";
        event_query << "VALUES (";
        event_query << "uuid_generate_v4(), ";
        event_query << "'" << created_by << "', ";
        event_query << "'" << event_type_id << "', ";
        event_query << "'" << title << "', ";
        event_query << (notes.empty() ? "NULL" : "'" + notes + "'") << ", ";
        event_query << "'" << event_datetime << "', ";
        event_query << (venue_id.empty() ? "NULL" : "'" + venue_id + "'") << ", ";
        event_query << duration << ", ";
        event_query << "CURRENT_TIMESTAMP, ";
        event_query << "CURRENT_TIMESTAMP";
        event_query << ") RETURNING id";
        
        std::cout << "📊 Event query: " << event_query.str() << std::endl;
        
        pqxx::result event_result = db_->query(event_query.str());
        if (event_result.empty()) {
            std::cerr << "❌ Failed to create event" << std::endl;
            std::string json = createJSONResponse(false, "Failed to create event");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
        std::string inserted_event_id = event_result[0][0].c_str();
        
        // Insert into practices table (extends events)
        std::ostringstream practice_query;
        practice_query << "INSERT INTO practices (id, team_id, notes) ";
        practice_query << "VALUES (";
        practice_query << "'" << inserted_event_id << "', ";
        practice_query << "'" << team_id << "', ";
        practice_query << (notes.empty() ? "NULL" : "'" + notes + "'");
        practice_query << ")";
        
        std::cout << "📊 Practice query: " << practice_query.str() << std::endl;
        
        db_->query(practice_query.str());
        
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
        std::string json = createJSONResponse(false, "Failed to create event: " + std::string(e.what()));
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
            json << "\"start\":\"" << event_date << "\",";
            json << "\"durationMinutes\":" << duration << ",";
            json << "\"isCancelled\":" << (cancelled ? "true" : "false") << ",";
            json << "\"location\":\"" << escapeJSON(venue_name) << "\",";
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
        // Show: all upcoming matches + matches ended within last 8 hours
        // Include has_ended flag so frontend knows whether to show RSVP buttons
        std::ostringstream query;
        query << "SELECT e.id, e.title, e.event_date, e.duration_minutes, et.name as event_type, ";
        query << "m.home_team_score, m.away_team_score, m.match_status, m.competition_name, v.name as venue_name, ";
        query << "CASE WHEN (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) < NOW() ";
        query << "THEN true ELSE false END as has_ended, ";
        query << "ht.logo_url as home_team_logo, at.logo_url as away_team_logo ";
        query << "FROM events e ";
        query << "JOIN event_types et ON e.event_type_id = et.id ";
        query << "JOIN matches m ON e.id = m.id ";
        query << "LEFT JOIN venues v ON e.venue_id = v.id ";
        query << "LEFT JOIN teams ht ON m.home_team_id = ht.id ";
        query << "LEFT JOIN teams at ON m.away_team_id = at.id ";
        query << "WHERE (m.home_team_id = '" << team_id << "' OR m.away_team_id = '" << team_id << "') ";
        query << "AND (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) > (NOW() - INTERVAL '8 hours') ";
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
        std::ostringstream event_query;
        event_query << "INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, created_at, updated_at) ";
        event_query << "VALUES (";
        event_query << "uuid_generate_v4(), ";
        event_query << "'" << created_by << "', ";
        event_query << "'" << event_type_id << "', ";
        event_query << "'" << title << "', ";
        event_query << (notes.empty() ? "NULL" : "'" + notes + "'") << ", ";
        event_query << "'" << event_datetime << "', ";
        event_query << (venue_id.empty() ? "NULL" : "'" + venue_id + "'") << ", ";
        event_query << "120, "; // 2 hour duration for matches
        event_query << "CURRENT_TIMESTAMP, ";
        event_query << "CURRENT_TIMESTAMP";
        event_query << ") RETURNING id";
        
        std::cout << "📊 Event query: " << event_query.str() << std::endl;
        
        pqxx::result event_result = db_->query(event_query.str());
        if (event_result.empty()) {
            std::cerr << "❌ Failed to create event" << std::endl;
            std::string json = createJSONResponse(false, "Failed to create event");
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, json);
        }
        
        std::string inserted_event_id = event_result[0][0].c_str();
        
        // Insert into matches table (extends events)
        std::ostringstream match_query;
        match_query << "INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status) ";
        match_query << "VALUES (";
        match_query << "'" << inserted_event_id << "', ";
        match_query << "'" << home_team_id << "', ";
        match_query << "'" << away_team_id << "', ";
        match_query << "'" << home_away_status_id << "', ";
        match_query << (competition_name.empty() ? "NULL" : "'" + competition_name + "'") << ", ";
        match_query << "'" << (match_status.empty() ? "scheduled" : match_status) << "'";
        match_query << ")";
        
        std::cout << "📊 Match query: " << match_query.str() << std::endl;
        
        db_->query(match_query.str());
        
        std::ostringstream result_json;
        result_json << "{\"id\":\"" << inserted_event_id << "\"}";
        
        std::string json = createJSONResponse(true, "Match created successfully", result_json.str());
        return Response(HttpStatus::CREATED, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleCreateMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, std::string("Failed to create match: ") + e.what());
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
        std::ostringstream query;
        query << "SELECT e.id, e.title, e.event_date, e.duration_minutes, e.venue_id, ";
        query << "m.home_team_id, m.away_team_id, m.competition_name, m.match_status, ";
        query << "m.home_team_score, m.away_team_score, e.description as notes, ";
        query << "v.name as venue_name ";
        query << "FROM events e ";
        query << "JOIN matches m ON e.id = m.id ";
        query << "LEFT JOIN venues v ON e.venue_id = v.id ";
        query << "WHERE e.id = '" << match_id << "'";
        
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
        std::ostringstream event_update;
        event_update << "UPDATE events SET ";
        event_update << "title = '" << title << "', ";
        event_update << "event_date = '" << date << " " << start_time << ":00', ";
        event_update << "venue_id = " << (venue_id.empty() ? "NULL" : "'" + venue_id + "'") << ", ";
        event_update << "description = " << (notes.empty() ? "NULL" : "'" + notes + "'") << ", ";
        event_update << "updated_at = CURRENT_TIMESTAMP ";
        event_update << "WHERE id = '" << match_id << "'";
        
        db_->query(event_update.str());
        
        // Update matches table
        std::ostringstream match_update;
        match_update << "UPDATE matches SET ";
        match_update << "home_team_id = '" << home_team_id << "', ";
        match_update << "away_team_id = '" << away_team_id << "', ";
        match_update << "competition_name = " << (competition_name.empty() ? "NULL" : "'" + competition_name + "'") << ", ";
        match_update << "match_status = '" << (match_status.empty() ? "scheduled" : match_status) << "'";
        
        if (!home_team_score.empty()) {
            match_update << ", home_team_score = " << home_team_score;
        }
        if (!away_team_score.empty()) {
            match_update << ", away_team_score = " << away_team_score;
        }
        
        match_update << " WHERE id = '" << match_id << "'";
        
        db_->query(match_update.str());
        
        std::string json = createJSONResponse(true, "Match updated successfully");
        return Response(HttpStatus::OK, json);
        
    } catch (const std::exception& e) {
        std::cerr << "❌ EventController::handleUpdateMatch error: " << e.what() << std::endl;
        std::string json = createJSONResponse(false, std::string("Failed to update match: ") + e.what());
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
        std::ostringstream query;
        query << "UPDATE events SET ";
        if (!title.empty()) {
            query << "title = '" << title << "', ";
        }
        query << "event_date = '" << event_datetime << "', ";
        query << "duration_minutes = " << duration << ", ";
        if (!venue_id.empty()) {
            query << "venue_id = '" << venue_id << "', ";
        }
        query << "updated_at = CURRENT_TIMESTAMP ";
        query << "WHERE id = '" << event_id << "'";
        
        std::cout << "📊 Update query: " << query.str() << std::endl;
        
        pqxx::result result = db_->query(query.str());
        
        // Update practices table notes
        std::ostringstream practice_query;
        practice_query << "UPDATE practices SET ";
        practice_query << "notes = " << (notes.empty() ? "NULL" : "'" + notes + "'") << " ";
        practice_query << "WHERE id = '" << event_id << "'";
        
        db_->query(practice_query.str());
        
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
    // Match both /api/events/team/:teamId and /api/matches/team/:teamId
    std::regex uuid_regex(R"(/api/(events|matches)/team/([a-f0-9-]{36}))");
    std::smatch match;
    
    if (std::regex_search(path, match, uuid_regex)) {
        return match[2].str();  // Return second capture group (team ID)
    }
    
    return "";
}

std::string EventController::extractEventIdFromPath(const std::string& path) {
    // Extract event ID from paths like /api/events/:eventId
    std::regex uuid_regex(R"(/api/events/([a-f0-9-]{36}))");
    std::smatch match;
    
    if (std::regex_search(path, match, uuid_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string EventController::extractMatchIdFromPath(const std::string& path) {
    // Extract match ID from paths like /api/matches/:matchId/...
    std::regex uuid_regex(R"(/api/matches/([a-f0-9-]{36}))");
    std::smatch match;
    
    if (std::regex_search(path, match, uuid_regex)) {
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
                                   "VALUES (uuid_generate_v4(), $1, $2, $3, $4, (SELECT id FROM rsvp_change_sources WHERE name = 'app'), $5, CURRENT_TIMESTAMP)";
        db_->query(insert_query, {event_id, user_id, rsvp_status_id, user_id, notes});
        std::cout << "✅ " << role_type << " RSVP recorded in history" << std::endl;
        
        std::string data = "{\"event_id\": \"" + event_id + "\", \"user_id\": \"" + user_id + "\", \"role_type\": \"" + role_type + "\", \"status\": \"" + status + "\"}";
        return Response(HttpStatus::OK, createJSONResponse(true, "RSVP saved successfully", data));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error creating/updating RSVP: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to save RSVP: ") + e.what()));
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
                               "u.first_name, u.last_name, COALESCE(u.preferred_name, '') as preferred_name, u.email, u.avatar_url "
                               "FROM " + view_name + " r "
                               "JOIN users u ON r." + id_column + " = u.id "
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to get RSVPs: ") + e.what()));
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to get attendance statuses: ") + e.what()));
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
                u.first_name,
                u.last_name,
                COALESCE(u.preferred_name, '') as preferred_name,
                u.email,
                u.avatar_url,
                ats.id as status_id,
                ats.name as status_name,
                ats.display_name as status_display_name,
                ats.color as status_color,
                rs.name as rsvp_snapshot,
                ea.notes,
                ea.created_at,
                ea.updated_at,
                upd.first_name as updated_by_first_name,
                upd.last_name as updated_by_last_name
            FROM event_attendance ea
            JOIN users u ON ea.player_id = u.id
            JOIN attendance_statuses ats ON ea.status_id = ats.id
            LEFT JOIN rsvp_statuses rs ON ea.rsvp_snapshot_id = rs.id
            LEFT JOIN users upd ON ea.updated_by = upd.id
            WHERE ea.event_id = $1
            ORDER BY u.last_name, u.first_name
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to get attendance: ") + e.what()));
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
        
        std::cout << "✅ Attendance updated: " << attendance_id << std::endl;
        
        return Response(HttpStatus::OK, createJSONResponse(true, "Attendance updated successfully"));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating attendance: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to update attendance: ") + e.what()));
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
                mr.id,
                mr.player_id,
                u.first_name,
                u.last_name,
                u.email,
                u.avatar_url,
                tp.jersey_number,
                pos.abbreviation as position,
                mr.created_at
            FROM match_rosters mr
            JOIN team_players tp ON mr.player_id = tp.player_id AND tp.team_id = (SELECT home_team_id FROM matches WHERE id = $1)
            JOIN players p ON mr.player_id = p.id
            JOIN users u ON p.id = u.id
            LEFT JOIN positions pos ON p.preferred_position_id = pos.id
            WHERE mr.match_id = $1
            ORDER BY u.last_name, u.first_name
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
            json << "\"email\":\"" << escapeJSON(row["email"].c_str()) << "\",";
            json << "\"photoUrl\":" << (row["avatar_url"].is_null() ? "null" : "\"" + escapeJSON(row["avatar_url"].c_str()) + "\"") << ",";
            json << "\"jerseyNumber\":" << (row["jersey_number"].is_null() ? "null" : row["jersey_number"].c_str()) << ",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"");
            json << "}";
        }
        
        json << "],\"count\":" << result.size() << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting game roster: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to get game roster: ") + e.what()));
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
                
                // Parse UUIDs from the array
                std::regex uuidRegex("\"([0-9a-fA-F-]{36})\"");
                std::sregex_iterator iter(arrayContent.begin(), arrayContent.end(), uuidRegex);
                std::sregex_iterator end;
                
                while (iter != end) {
                    playerIds.push_back((*iter)[1].str());
                    ++iter;
                }
            }
        }
        
        std::cout << "📋 Player IDs to add: " << playerIds.size() << std::endl;
        
        // Start transaction: clear existing roster and add new players
        // First, delete existing roster entries for this match
        std::string deleteQuery = "DELETE FROM match_rosters WHERE match_id = $1";
        db_->query(deleteQuery, {matchId});
        
        // Insert new roster entries
        int addedCount = 0;
        for (const auto& playerId : playerIds) {
            std::string insertQuery;
            if (addedBy.empty()) {
                insertQuery = R"(
                    INSERT INTO match_rosters (match_id, player_id)
                    VALUES ($1, $2)
                    ON CONFLICT (match_id, player_id) DO NOTHING
                )";
                db_->query(insertQuery, {matchId, playerId});
            } else {
                insertQuery = R"(
                    INSERT INTO match_rosters (match_id, player_id, added_by)
                    VALUES ($1, $2, $3)
                    ON CONFLICT (match_id, player_id) DO NOTHING
                )";
                db_->query(insertQuery, {matchId, playerId, addedBy});
            }
            addedCount++;
        }
        
        std::cout << "✅ Game roster updated: " << addedCount << " players" << std::endl;
        
        std::ostringstream json;
        json << "{\"success\":true,\"message\":\"Game roster updated\",\"count\":" << addedCount << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating game roster: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to update game roster: ") + e.what()));
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
                u.first_name,
                u.last_name,
                u.email,
                u.avatar_url,
                tp.jersey_number,
                pos.abbreviation as position,
                rs.name as rsvp_status,
                CASE WHEN mr.id IS NOT NULL THEN true ELSE false END as on_game_roster,
                CASE WHEN rs.name = 'yes' THEN 0 ELSE 1 END as rsvp_order
            FROM matches m
            JOIN team_players tp ON tp.team_id = m.home_team_id
            JOIN players p ON tp.player_id = p.id
            JOIN users u ON p.id = u.id
            LEFT JOIN positions pos ON p.preferred_position_id = pos.id
            LEFT JOIN roster_statuses rost ON tp.roster_status_id = rost.id
            LEFT JOIN player_rsvps_current prc ON prc.player_id = p.id AND prc.event_id = m.id
            LEFT JOIN rsvp_statuses rs ON prc.rsvp_status_id = rs.id
            LEFT JOIN match_rosters mr ON mr.match_id = m.id AND mr.player_id = p.id
            WHERE m.id = $1
              AND tp.is_active = true
              AND (rost.show_in_rsvp = true OR rost.show_in_rsvp IS NULL)
            ORDER BY 
                rsvp_order,
                u.last_name, 
                u.first_name
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, std::string("Failed to get eligible players: ") + e.what()));
    }
}
