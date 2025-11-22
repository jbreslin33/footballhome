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
        
        // Generate event ID
        std::string event_id = generateUUID();
        
        // Build INSERT query for events table
        std::ostringstream event_query;
        event_query << "INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, created_at, updated_at) ";
        event_query << "VALUES (";
        event_query << "'" << event_id << "', ";
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
        std::ostringstream query;
        query << "SELECT e.id, e.title, e.event_date, e.duration_minutes, et.name as event_type, p.notes ";
        query << "FROM events e ";
        query << "JOIN event_types et ON e.event_type_id = et.id ";
        query << "LEFT JOIN practices p ON e.id = p.id ";
        query << "WHERE p.team_id = '" << team_id << "' ";
        query << "ORDER BY e.event_date DESC ";
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
            events_json << "\"type\":\"" << result[i][4].c_str() << "\"";
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
            venues_json << "\"name\":\"" << result[i][1].c_str() << "\",";
            venues_json << "\"address\":\"" << (result[i][2].is_null() ? "" : result[i][2].c_str()) << "\",";
            venues_json << "\"city\":\"" << (result[i][3].is_null() ? "" : result[i][3].c_str()) << "\",";
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
    std::regex uuid_regex(R"(/api/events/team/([a-f0-9-]{36}))");
    std::smatch match;
    
    if (std::regex_search(path, match, uuid_regex)) {
        return match[1].str();
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

std::string EventController::generateUUID() {
    // Simple UUID v4 generation using random
    std::ostringstream uuid;
    uuid << std::hex;
    
    for (int i = 0; i < 8; i++) uuid << (rand() % 16);
    uuid << "-";
    for (int i = 0; i < 4; i++) uuid << (rand() % 16);
    uuid << "-4"; // Version 4
    for (int i = 0; i < 3; i++) uuid << (rand() % 16);
    uuid << "-";
    uuid << (8 + rand() % 4); // Variant
    for (int i = 0; i < 3; i++) uuid << (rand() % 16);
    uuid << "-";
    for (int i = 0; i < 12; i++) uuid << (rand() % 16);
    
    return uuid.str();
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
        
        // Validate status
        if (status != "attending" && status != "not_attending" && status != "maybe") {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid status. Must be: attending, not_attending, or maybe"));
        }
        
        // Determine the correct table based on role_type
        std::string table_name = role_type + "_rsvps";
        std::string id_column = role_type + "_id";
        
        // Check if RSVP already exists
        std::string check_query = "SELECT id FROM " + table_name + " WHERE event_id = $1 AND " + id_column + " = $2";
        pqxx::result existing = db_->query(check_query, {event_id, user_id});
        
        if (existing.empty()) {
            // Insert new RSVP
            std::string rsvp_id = generateUUID();
            std::string insert_query = "INSERT INTO " + table_name + " (id, event_id, " + id_column + ", status, notes, response_date) "
                                       "VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)";
            db_->query(insert_query, {rsvp_id, event_id, user_id, status, notes});
            std::cout << "✅ " << role_type << " RSVP created successfully" << std::endl;
        } else {
            // Update existing RSVP
            std::string update_query = "UPDATE " + table_name + " SET status = $1, notes = $2, updated_at = CURRENT_TIMESTAMP "
                                       "WHERE event_id = $3 AND " + id_column + " = $4";
            db_->query(update_query, {status, notes, event_id, user_id});
            std::cout << "✅ " << role_type << " RSVP updated successfully" << std::endl;
        }
        
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
        std::string role_type = "";
        size_t query_pos = request.getPath().find("?role_type=");
        if (query_pos != std::string::npos) {
            role_type = request.getPath().substr(query_pos + 11);
            // Remove any trailing parameters
            size_t ampersand = role_type.find("&");
            if (ampersand != std::string::npos) {
                role_type = role_type.substr(0, ampersand);
            }
        }
        
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
            std::string table_name = role + "_rsvps";
            std::string id_column = role + "_id";
            
            std::string query = "SELECT r.id, r.event_id, r." + id_column + " as user_id, r.status, r.notes, r.response_date, "
                               "u.first_name, u.last_name, u.email "
                               "FROM " + table_name + " r "
                               "JOIN users u ON r." + id_column + " = u.id "
                               "WHERE r.event_id = $1 "
                               "ORDER BY r.response_date DESC";
            
            pqxx::result result = db_->query(query, {event_id});
            
            for (size_t i = 0; i < result.size(); ++i) {
                if (!first) json_array << ",";
                first = false;
                
                json_array << "{"
                          << "\"id\": \"" << result[i]["id"].c_str() << "\", "
                          << "\"event_id\": \"" << result[i]["event_id"].c_str() << "\", "
                          << "\"user_id\": \"" << result[i]["user_id"].c_str() << "\", "
                          << "\"role_type\": \"" << role << "\", "
                          << "\"status\": \"" << result[i]["status"].c_str() << "\", "
                          << "\"notes\": \"" << (result[i]["notes"].is_null() ? "" : result[i]["notes"].c_str()) << "\", "
                          << "\"response_date\": \"" << result[i]["response_date"].c_str() << "\", "
                          << "\"user_name\": \"" << result[i]["first_name"].c_str() << " " << result[i]["last_name"].c_str() << "\", "
                          << "\"user_email\": \"" << result[i]["email"].c_str() << "\""
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
