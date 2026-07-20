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

    // GET /api/clubs/:id/game-model - Get DB-backed game model content
    router.get(prefix + "/:id/game-model", [this](const Request& request) {
        return this->handleGetClubGameModel(request);
    });

    router.get(prefix + "/:id/game-model/admin/:entity", [this](const Request& request) {
        std::string entity = request.getPath().substr(request.getPath().find("/game-model/admin/") + 18);
        size_t slash = entity.find('/');
        if (slash != std::string::npos) entity = entity.substr(0, slash);
        return this->handleListGameModelAdminEntities(request, entity);
    });

    router.get(prefix + "/:id/game-model/structure", [this](const Request& request) {
        return this->handleGetClubGameModelStructure(request);
    });

    router.post(prefix + "/:id/game-model/admin/:entity", [this](const Request& request) {
        std::string entity = request.getPath().substr(request.getPath().find("/game-model/admin/") + 18);
        size_t slash = entity.find('/');
        if (slash != std::string::npos) entity = entity.substr(0, slash);
        return this->handleCreateGameModelAdminEntity(request, entity);
    });

    router.del(prefix + "/:id/game-model/admin/:entity/:id", [this](const Request& request) {
        std::string entity = request.getPath().substr(request.getPath().find("/game-model/admin/") + 18);
        size_t slash = entity.find('/');
        if (slash != std::string::npos) entity = entity.substr(0, slash);
        std::string id_str = request.getPath().substr(request.getPath().rfind('/') + 1);
        int id = std::stoi(id_str);
        return this->handleDeleteGameModelAdminEntity(request, entity, id);
    });
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response ClubController::handleListGameModelAdminEntities(const Request& request, const std::string& entity) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        std::string club_id_str = path.substr(pos + prefix.length());
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) club_id_str = club_id_str.substr(0, slash_pos);
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        int club_id = std::stoi(club_id_str);

        std::string table;
        std::string select;
        if (entity == "days") {
            table = "club_game_model_days";
            select = "SELECT id, club_id, slug, label, description, sort_order, is_active FROM club_game_model_days WHERE club_id = $1::int ORDER BY sort_order, id";
        } else if (entity == "phases") {
            table = "club_game_model_phases";
            select = "SELECT id, club_id, slug, label, description, sort_order, is_active FROM club_game_model_phases WHERE club_id = $1::int ORDER BY sort_order, id";
        } else if (entity == "principles") {
            table = "club_game_model_principles";
            select = "SELECT id, phase_id, slug, level, title, description, sort_order, is_active FROM club_game_model_principles WHERE phase_id IN (SELECT id FROM club_game_model_phases WHERE club_id = $1::int) ORDER BY sort_order, id";
        } else if (entity == "practices") {
            table = "club_game_model_practices";
            select = "SELECT id, day_id, title, summary, start_time, end_time, sort_order, is_active FROM club_game_model_practices WHERE day_id IN (SELECT id FROM club_game_model_days WHERE club_id = $1::int) ORDER BY sort_order, id";
        } else if (entity == "sessions") {
            table = "club_game_model_sessions";
            select = "SELECT id, practice_id, title, summary, start_time, end_time, sort_order, is_active FROM club_game_model_sessions WHERE practice_id IN (SELECT id FROM club_game_model_practices WHERE day_id IN (SELECT id FROM club_game_model_days WHERE club_id = $1::int)) ORDER BY sort_order, id";
        } else if (entity == "exercises") {
            table = "club_game_model_exercises";
            select = "SELECT id, slug, title, summary, setup, coaching_points, simulator_slug, sort_order, is_active FROM club_game_model_exercises WHERE club_id = $1::int OR club_id IS NULL ORDER BY sort_order, id";
        } else if (entity == "patterns") {
            table = "club_game_model_number_patterns";
            select = "SELECT id, slug, name, description, min_players, max_players, sort_order, is_active FROM club_game_model_number_patterns WHERE club_id = $1::int ORDER BY sort_order, id";
        } else {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Unknown entity"));
        }

        std::vector<std::string> params = {std::to_string(club_id)};
        pqxx::result result = db_->query(select, params);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].as<long long>();
            if (entity == "days") {
                json << ",\"club_id\":" << row["club_id"].as<int>();
                json << ",\"slug\":" << "\"" << escapeJson(row["slug"].c_str()) << "\"";
                json << ",\"label\":" << "\"" << escapeJson(row["label"].c_str()) << "\"";
                json << ",\"description\":" << (row["description"].is_null() ? "null" : "\"" + escapeJson(row["description"].c_str()) + "\"") ;
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "phases") {
                json << ",\"club_id\":" << row["club_id"].as<int>();
                json << ",\"slug\":" << "\"" << escapeJson(row["slug"].c_str()) << "\"";
                json << ",\"label\":" << "\"" << escapeJson(row["label"].c_str()) << "\"";
                json << ",\"description\":" << (row["description"].is_null() ? "null" : "\"" + escapeJson(row["description"].c_str()) + "\"");
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "principles") {
                json << ",\"phase_id\":" << row["phase_id"].as<long long>();
                json << ",\"slug\":" << "\"" << escapeJson(row["slug"].c_str()) << "\"";
                json << ",\"level\":" << "\"" << escapeJson(row["level"].c_str()) << "\"";
                json << ",\"title\":" << "\"" << escapeJson(row["title"].c_str()) << "\"";
                json << ",\"description\":" << (row["description"].is_null() ? "null" : "\"" + escapeJson(row["description"].c_str()) + "\"");
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "practices") {
                json << ",\"day_id\":" << row["day_id"].as<long long>();
                json << ",\"title\":" << "\"" << escapeJson(row["title"].c_str()) << "\"";
                json << ",\"summary\":" << (row["summary"].is_null() ? "null" : "\"" + escapeJson(row["summary"].c_str()) + "\"");
                json << ",\"start_time\":" << (row["start_time"].is_null() ? "null" : "\"" + escapeJson(row["start_time"].c_str()) + "\"");
                json << ",\"end_time\":" << (row["end_time"].is_null() ? "null" : "\"" + escapeJson(row["end_time"].c_str()) + "\"");
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "sessions") {
                json << ",\"practice_id\":" << row["practice_id"].as<long long>();
                json << ",\"title\":" << "\"" << escapeJson(row["title"].c_str()) << "\"";
                json << ",\"summary\":" << (row["summary"].is_null() ? "null" : "\"" + escapeJson(row["summary"].c_str()) + "\"");
                json << ",\"start_time\":" << (row["start_time"].is_null() ? "null" : "\"" + escapeJson(row["start_time"].c_str()) + "\"");
                json << ",\"end_time\":" << (row["end_time"].is_null() ? "null" : "\"" + escapeJson(row["end_time"].c_str()) + "\"");
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "exercises") {
                json << ",\"slug\":" << "\"" << escapeJson(row["slug"].c_str()) << "\"";
                json << ",\"title\":" << "\"" << escapeJson(row["title"].c_str()) << "\"";
                json << ",\"summary\":" << (row["summary"].is_null() ? "null" : "\"" + escapeJson(row["summary"].c_str()) + "\"");
                json << ",\"setup\":" << (row["setup"].is_null() ? "null" : "\"" + escapeJson(row["setup"].c_str()) + "\"");
                json << ",\"coaching_points\":" << (row["coaching_points"].is_null() ? "null" : "\"" + escapeJson(row["coaching_points"].c_str()) + "\"");
                json << ",\"simulator_slug\":" << (row["simulator_slug"].is_null() ? "null" : "\"" + escapeJson(row["simulator_slug"].c_str()) + "\"");
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            } else if (entity == "patterns") {
                json << ",\"slug\":" << "\"" << escapeJson(row["slug"].c_str()) << "\"";
                json << ",\"name\":" << "\"" << escapeJson(row["name"].c_str()) << "\"";
                json << ",\"description\":" << (row["description"].is_null() ? "null" : "\"" + escapeJson(row["description"].c_str()) + "\"");
                json << ",\"min_players\":" << row["min_players"].as<int>();
                json << ",\"max_players\":" << row["max_players"].as<int>();
                json << ",\"sort_order\":" << row["sort_order"].as<int>();
                json << ",\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false");
            }
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "OK", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "Error listing game model admin entities: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response ClubController::handleCreateGameModelAdminEntity(const Request& request, const std::string& entity) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        std::string club_id_str = path.substr(pos + prefix.length());
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) club_id_str = club_id_str.substr(0, slash_pos);
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        int club_id = std::stoi(club_id_str);

        if (!request.isJson() || request.getBody().empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "JSON body required"));
        }

        std::string body = request.getBody();
        std::string slug = "";
        std::string title = "";
        std::string summary = "";
        std::string label = "";
        std::string description = "";
        std::string setup = "";
        std::string coaching_points = "";
        std::string simulator_slug = "";
        std::string start_time = "";
        std::string end_time = "";
        std::string name = "";
        std::string level = "";
        int id = 0;
        int day_id = 0;
        int practice_id = 0;
        int phase_id = 0;
        int sort_order = 0;
        int min_players = 0;
        int max_players = 0;

        auto parse_value = [&](const std::string& key) -> std::string {
            size_t pos = body.find("\"" + key + "\"");
            if (pos == std::string::npos) return "";
            size_t colon = body.find(':', pos);
            if (colon == std::string::npos) return "";
            size_t value_start = colon + 1;
            while (value_start < body.size() && std::isspace((unsigned char)body[value_start])) ++value_start;
            if (value_start >= body.size()) return "";
            if (body[value_start] == '"') {
                size_t value_end = body.find('"', value_start + 1);
                while (value_end != std::string::npos && body[value_end - 1] == '\\') value_end = body.find('"', value_end + 1);
                if (value_end == std::string::npos) return "";
                return body.substr(value_start + 1, value_end - value_start - 1);
            }
            size_t value_end = body.find(',', value_start);
            if (value_end == std::string::npos) value_end = body.find('}', value_start);
            if (value_end == std::string::npos) return "";
            return body.substr(value_start, value_end - value_start);
        };

        auto parse_int = [&](const std::string& key) -> int {
            std::string raw = parse_value(key);
            if (raw.empty()) return 0;
            try { return std::stoi(raw); } catch (...) { return 0; }
        };

        id = parse_int("id");
        slug = parse_value("slug");
        title = parse_value("title");
        summary = parse_value("summary");
        label = parse_value("label");
        description = parse_value("description");
        setup = parse_value("setup");
        coaching_points = parse_value("coaching_points");
        simulator_slug = parse_value("simulator_slug");
        start_time = parse_value("start_time");
        end_time = parse_value("end_time");
        name = parse_value("name");
        day_id = parse_int("day_id");
        practice_id = parse_int("practice_id");
        phase_id = parse_int("phase_id");
        level = parse_value("level");
        sort_order = parse_int("sort_order");
        min_players = parse_int("min_players");
        max_players = parse_int("max_players");

        std::ostringstream query;
        if (entity == "days") {
            if (id > 0) {
                query << "UPDATE club_game_model_days SET slug = '" << escapeJson(slug) << "', label = '" << escapeJson(label) << "', description = '" << escapeJson(description) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND club_id = " << club_id;
            } else {
                query << "INSERT INTO club_game_model_days (club_id, slug, label, description, sort_order, is_active, created_at, updated_at) VALUES (" << club_id << ", '" << escapeJson(slug) << "', '" << escapeJson(label) << "', '" << escapeJson(description) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (club_id, slug) DO UPDATE SET label = EXCLUDED.label, description = EXCLUDED.description, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "phases") {
            if (id > 0) {
                query << "UPDATE club_game_model_phases SET slug = '" << escapeJson(slug) << "', label = '" << escapeJson(label) << "', description = '" << escapeJson(description) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND club_id = " << club_id;
            } else {
                query << "INSERT INTO club_game_model_phases (club_id, slug, label, description, sort_order, is_active, created_at, updated_at) VALUES (" << club_id << ", '" << escapeJson(slug) << "', '" << escapeJson(label) << "', '" << escapeJson(description) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (club_id, slug) DO UPDATE SET label = EXCLUDED.label, description = EXCLUDED.description, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "principles") {
            if (id > 0) {
                query << "UPDATE club_game_model_principles SET phase_id = " << phase_id << ", slug = '" << escapeJson(slug) << "', level = '" << escapeJson(level) << "', title = '" << escapeJson(title) << "', description = '" << escapeJson(description) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND phase_id IN (SELECT id FROM club_game_model_phases WHERE club_id = " << club_id << ")";
            } else {
                query << "INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order, is_active, created_at, updated_at) VALUES (" << phase_id << ", '" << escapeJson(slug) << "', '" << escapeJson(level) << "', '" << escapeJson(title) << "', '" << escapeJson(description) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (phase_id, slug) DO UPDATE SET level = EXCLUDED.level, title = EXCLUDED.title, description = EXCLUDED.description, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "practices") {
            if (id > 0) {
                query << "UPDATE club_game_model_practices SET day_id = " << day_id << ", title = '" << escapeJson(title) << "', summary = '" << escapeJson(summary) << "', start_time = '" << escapeJson(start_time) << "', end_time = '" << escapeJson(end_time) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND day_id IN (SELECT id FROM club_game_model_days WHERE club_id = " << club_id << ")";
            } else {
                query << "INSERT INTO club_game_model_practices (day_id, title, summary, start_time, end_time, sort_order, is_active, created_at, updated_at) VALUES (" << day_id << ", '" << escapeJson(title) << "', '" << escapeJson(summary) << "', '" << escapeJson(start_time) << "', '" << escapeJson(end_time) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (day_id, title) DO UPDATE SET summary = EXCLUDED.summary, start_time = EXCLUDED.start_time, end_time = EXCLUDED.end_time, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "sessions") {
            if (id > 0) {
                query << "UPDATE club_game_model_sessions SET practice_id = " << practice_id << ", title = '" << escapeJson(title) << "', summary = '" << escapeJson(summary) << "', start_time = '" << escapeJson(start_time) << "', end_time = '" << escapeJson(end_time) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND practice_id IN (SELECT id FROM club_game_model_practices WHERE day_id IN (SELECT id FROM club_game_model_days WHERE club_id = " << club_id << "))";
            } else {
                query << "INSERT INTO club_game_model_sessions (practice_id, title, summary, start_time, end_time, sort_order, is_active, created_at, updated_at) VALUES (" << practice_id << ", '" << escapeJson(title) << "', '" << escapeJson(summary) << "', '" << escapeJson(start_time) << "', '" << escapeJson(end_time) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (practice_id, title) DO UPDATE SET summary = EXCLUDED.summary, start_time = EXCLUDED.start_time, end_time = EXCLUDED.end_time, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "exercises") {
            if (id > 0) {
                query << "UPDATE club_game_model_exercises SET slug = '" << escapeJson(slug) << "', title = '" << escapeJson(title) << "', summary = '" << escapeJson(summary) << "', setup = '" << escapeJson(setup) << "', coaching_points = '" << escapeJson(coaching_points) << "', simulator_slug = '" << escapeJson(simulator_slug) << "', sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND (club_id = " << club_id << " OR club_id IS NULL)";
            } else {
                query << "INSERT INTO club_game_model_exercises (club_id, slug, title, summary, setup, coaching_points, simulator_slug, sort_order, is_active, created_at, updated_at) VALUES (" << club_id << ", '" << escapeJson(slug) << "', '" << escapeJson(title) << "', '" << escapeJson(summary) << "', '" << escapeJson(setup) << "', '" << escapeJson(coaching_points) << "', '" << escapeJson(simulator_slug) << "', " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (club_id, slug) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, setup = EXCLUDED.setup, coaching_points = EXCLUDED.coaching_points, simulator_slug = EXCLUDED.simulator_slug, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else if (entity == "patterns") {
            if (id > 0) {
                query << "UPDATE club_game_model_number_patterns SET slug = '" << escapeJson(slug) << "', name = '" << escapeJson(name) << "', description = '" << escapeJson(description) << "', min_players = " << min_players << ", max_players = " << max_players << ", sort_order = " << sort_order << ", updated_at = NOW() WHERE id = " << id << " AND club_id = " << club_id;
            } else {
                query << "INSERT INTO club_game_model_number_patterns (club_id, slug, name, description, min_players, max_players, sort_order, is_active, created_at, updated_at) VALUES (" << club_id << ", '" << escapeJson(slug) << "', '" << escapeJson(name) << "', '" << escapeJson(description) << "', " << min_players << ", " << max_players << ", " << sort_order << ", true, NOW(), NOW()) ON CONFLICT (club_id, slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, min_players = EXCLUDED.min_players, max_players = EXCLUDED.max_players, sort_order = EXCLUDED.sort_order, updated_at = NOW() RETURNING id";
            }
        } else {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Unknown entity"));
        }

        pqxx::result result = db_->query(query.str());
        if (id > 0) {
            return Response(HttpStatus::OK, createJSONResponse(true, "Updated"));
        }
        return Response(HttpStatus::OK, createJSONResponse(true, "Created", "{\"id\":" + std::to_string(result[0]["id"].as<int>()) + "}"));
    } catch (const std::exception& e) {
        std::cerr << "Error creating game model admin entity: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response ClubController::handleDeleteGameModelAdminEntity(const Request& request, const std::string& entity, int id) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        std::string club_id_str = path.substr(pos + prefix.length());
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) club_id_str = club_id_str.substr(0, slash_pos);
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        int club_id = std::stoi(club_id_str);

        std::string query;
        if (entity == "days") {
            query = "UPDATE club_game_model_days SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND club_id = " + std::to_string(club_id);
        } else if (entity == "phases") {
            query = "UPDATE club_game_model_phases SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND club_id = " + std::to_string(club_id);
        } else if (entity == "principles") {
            query = "UPDATE club_game_model_principles SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND phase_id IN (SELECT id FROM club_game_model_phases WHERE club_id = " + std::to_string(club_id) + ")";
        } else if (entity == "practices") {
            query = "UPDATE club_game_model_practices SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND day_id IN (SELECT id FROM club_game_model_days WHERE club_id = " + std::to_string(club_id) + ")";
        } else if (entity == "sessions") {
            query = "UPDATE club_game_model_sessions SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND practice_id IN (SELECT id FROM club_game_model_practices WHERE day_id IN (SELECT id FROM club_game_model_days WHERE club_id = " + std::to_string(club_id) + "))";
        } else if (entity == "exercises") {
            query = "UPDATE club_game_model_exercises SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND (club_id = " + std::to_string(club_id) + " OR club_id IS NULL)";
        } else if (entity == "patterns") {
            query = "UPDATE club_game_model_number_patterns SET is_active = false, updated_at = NOW() WHERE id = " + std::to_string(id) + " AND club_id = " + std::to_string(club_id);
        } else {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Unknown entity"));
        }

        db_->query(query);
        return Response(HttpStatus::OK, createJSONResponse(true, "Deleted"));
    } catch (const std::exception& e) {
        std::cerr << "Error deleting game model admin entity: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response ClubController::handleGetClubGameModelStructure(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        std::string club_id_str = path.substr(pos + prefix.length());
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) club_id_str = club_id_str.substr(0, slash_pos);
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        int club_id = std::stoi(club_id_str);

        std::ostringstream query;
        query << "SELECT gm.id AS game_model_id, gm.title, gm.summary, gm.base_shape, p.id AS phase_id, p.slug AS phase_slug, p.label AS phase_label, p.description AS phase_description, p.sort_order AS phase_sort_order, pr.id AS principle_id, pr.slug AS principle_slug, pr.level, pr.title AS principle_title, pr.description AS principle_description, pr.sort_order AS principle_sort_order FROM club_game_model gm JOIN club_game_model_phases p ON p.club_id = gm.club_id JOIN club_game_model_phase_principles gpp ON gpp.game_model_id = gm.id AND gpp.phase_id = p.id JOIN club_game_model_principles pr ON pr.id = gpp.principle_id WHERE gm.club_id = " << club_id << " AND gm.is_active = true AND p.is_active = true AND pr.is_active = true ORDER BY p.sort_order, p.id, pr.sort_order, pr.id";

        pqxx::result result = db_->query(query.str());

        std::ostringstream json;
        json << "{";
        json << "\"game_model\":{";
        json << "\"id\":" << club_id << ",";
        json << "\"title\":\"Game Model\",";
        json << "\"summary\":\"A normalized 4-4-2 coaching framework with phases and principles.\",";
        json << "\"base_shape\":\"4-4-2\"";
        json << "},\"phases\":[";

        bool first_phase = true;
        int current_phase_id = -1;
        bool first_principle = true;
        for (const auto& row : result) {
            int phase_id = row["phase_id"].as<int>();
            if (phase_id != current_phase_id) {
                if (!first_phase) {
                    json << "]}";
                }
                first_phase = false;
                current_phase_id = phase_id;
                first_principle = true;
                json << "{";
                json << "\"id\":" << phase_id << ",";
                json << "\"slug\":\"" << escapeJson(row["phase_slug"].c_str()) << "\",";
                json << "\"label\":\"" << escapeJson(row["phase_label"].c_str()) << "\",";
                json << "\"description\":\"" << escapeJson(row["phase_description"].c_str()) << "\",";
                json << "\"sort_order\":" << row["phase_sort_order"].as<int>() << ",";
                json << "\"principles\":[";
            }

            if (!row["principle_id"].is_null()) {
                if (!first_principle) {
                    json << ",";
                }
                first_principle = false;
                json << "{";
                json << "\"id\":" << row["principle_id"].as<long long>() << ",";
                json << "\"slug\":\"" << escapeJson(row["principle_slug"].c_str()) << "\",";
                json << "\"level\":\"" << escapeJson(row["level"].c_str()) << "\",";
                json << "\"title\":\"" << escapeJson(row["principle_title"].c_str()) << "\",";
                json << "\"description\":\"" << escapeJson(row["principle_description"].c_str()) << "\",";
                json << "\"sort_order\":" << row["principle_sort_order"].as<int>();
                json << "}";
            }
        }

        if (!first_phase) {
            json << "]}";
        }
        json << "]}";
        json << "}";

        return Response(HttpStatus::OK, createJSONResponse(true, "Game model structure retrieved", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetClubGameModelStructure: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response ClubController::handleGetClubGameModel(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/clubs/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        }
        std::string club_id_str = path.substr(pos + prefix.length());
        size_t slash_pos = club_id_str.find("/");
        if (slash_pos != std::string::npos) {
            club_id_str = club_id_str.substr(0, slash_pos);
        }
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));

        int club_id = std::stoi(club_id_str);

        std::string content_query = R"(
            SELECT content_html
            FROM club_game_model_content
            WHERE club_id = )" + std::to_string(club_id) + R"(
            ORDER BY updated_at DESC, id DESC
            LIMIT 1
        )";

        pqxx::result content_result = db_->query(content_query);

        std::string content_html;
        if (!content_result.empty() && !content_result[0]["content_html"].is_null()) {
            content_html = content_result[0]["content_html"].c_str();
        }

        auto looksLikeLegacyPlanner = [](const std::string& html) {
            const std::string markers[] = {
                "Weekly preparation plan",
                "data-toggle-section=",
                "Base build",
                "Final-third finish",
                "Build from the back",
                "Final-third combinations"
            };
            for (const auto& marker : markers) {
                if (html.find(marker) != std::string::npos) {
                    return true;
                }
            }
            return false;
        };

        if (content_html.empty() || looksLikeLegacyPlanner(content_html)) {
            content_html = R"(<article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3); display: grid; gap: var(--space-3);"><h4 style="margin: 0;">Spain/UEFA-style 4-4-2 game model</h4><p style="margin: 0; opacity: 0.9;">The identity is positional, patient, and compact. The team builds through the back line, creates the free player in the middle, and attacks with rhythm and purpose.</p><div style="display: grid; gap: 0.65rem;"><div><strong>Primary principle:</strong> Play with control, shape, and clear positional structure.</div><div><strong>Sub-principle:</strong> Build from the back and create easy support angles before the attack becomes vertical.</div><div><strong>Sub-sub-principle:</strong> The first pass should create a next pass, not just a simple carry.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Offense</strong></div><div><strong>Principle:</strong> Create overloads in the middle and free a player in the attacking third.</div><div><strong>Sub-principle:</strong> The midfielders connect the build to the attack and the full-backs support the width.</div><div><strong>Sub-sub-principle:</strong> The third-man run is the main trigger to break the line.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Defense</strong></div><div><strong>Principle:</strong> Defend compact and aggressive as a unit.</div><div><strong>Sub-principle:</strong> Press together, protect the central lane, and force the ball wide.</div><div><strong>Sub-sub-principle:</strong> The nearest player presses, the second covers, and the third balances the space.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Transitions</strong></div><div><strong>Transition to offense:</strong> As soon as the ball is won, attack immediately with a quick vertical action.</div><div><strong>Sub-principle:</strong> The first pass should break the line or create a second action.</div><div><strong>Transition to defense:</strong> If the ball is lost, recover into the compact shape and protect the middle.</div><div><strong>Sub-principle:</strong> The first recovery run must make the block compact again.</div></div></article>)";
        }

        std::ostringstream plan_json;
        plan_json << "{";
        plan_json << "\"days\":";

        std::string days_query = R"(
            SELECT id, slug, label, description, sort_order
            FROM club_game_model_days
            WHERE club_id = )" + std::to_string(club_id) + R"(
              AND is_active = true
            ORDER BY sort_order, id
        )";
        pqxx::result days_result = db_->query(days_query);

        bool first_day = true;
        plan_json << "[";
        for (const auto& day_row : days_result) {
            if (!first_day) plan_json << ",";
            first_day = false;

            long long day_id = day_row["id"].as<long long>();
            plan_json << "{";
            plan_json << "\"id\":" << day_id << ",";
            plan_json << "\"slug\":" << "\"" << escapeJson(day_row["slug"].c_str()) << "\"" << ",";
            plan_json << "\"label\":" << "\"" << escapeJson(day_row["label"].c_str()) << "\"" << ",";
            plan_json << "\"description\":" << (day_row["description"].is_null() ? "null" : "\"" + escapeJson(day_row["description"].c_str()) + "\"") << ",";
            plan_json << "\"practices\":[";

            std::string practices_query = R"(
                SELECT id, title, summary, start_time, end_time, sort_order
                FROM club_game_model_practices
                WHERE day_id = )" + std::to_string(day_id) + R"(
                  AND is_active = true
                ORDER BY sort_order, id
            )";
            pqxx::result practices_result = db_->query(practices_query);

            bool first_practice = true;
            for (const auto& practice_row : practices_result) {
                if (!first_practice) plan_json << ",";
                first_practice = false;

                long long practice_id = practice_row["id"].as<long long>();
                plan_json << "{";
                plan_json << "\"id\":" << practice_id << ",";
                plan_json << "\"title\":" << "\"" << escapeJson(practice_row["title"].c_str()) << "\"" << ",";
                plan_json << "\"summary\":" << (practice_row["summary"].is_null() ? "null" : "\"" + escapeJson(practice_row["summary"].c_str()) + "\"") << ",";
                plan_json << "\"start_time\":" << (practice_row["start_time"].is_null() ? "null" : "\"" + escapeJson(practice_row["start_time"].c_str()) + "\"") << ",";
                plan_json << "\"end_time\":" << (practice_row["end_time"].is_null() ? "null" : "\"" + escapeJson(practice_row["end_time"].c_str()) + "\"") << ",";
                plan_json << "\"sessions\":[";

                std::string sessions_query = R"(
                    SELECT id, title, summary, start_time, end_time, sort_order
                    FROM club_game_model_sessions
                    WHERE practice_id = )" + std::to_string(practice_id) + R"(
                      AND is_active = true
                    ORDER BY sort_order, id
                )";
                pqxx::result sessions_result = db_->query(sessions_query);

                bool first_session = true;
                for (const auto& session_row : sessions_result) {
                    if (!first_session) plan_json << ",";
                    first_session = false;

                    long long session_id = session_row["id"].as<long long>();
                    plan_json << "{";
                    plan_json << "\"id\":" << session_id << ",";
                    plan_json << "\"title\":" << "\"" << escapeJson(session_row["title"].c_str()) << "\"" << ",";
                    plan_json << "\"summary\":" << (session_row["summary"].is_null() ? "null" : "\"" + escapeJson(session_row["summary"].c_str()) + "\"") << ",";
                    plan_json << "\"start_time\":" << (session_row["start_time"].is_null() ? "null" : "\"" + escapeJson(session_row["start_time"].c_str()) + "\"") << ",";
                    plan_json << "\"end_time\":" << (session_row["end_time"].is_null() ? "null" : "\"" + escapeJson(session_row["end_time"].c_str()) + "\"") << ",";
                    plan_json << "\"exercises\":[";

                    std::string session_exercises_query = R"(
                        SELECT se.id, se.player_count, se.duration_minutes, se.notes, se.sort_order,
                               e.id AS exercise_id, e.slug, e.title, e.summary AS exercise_summary,
                               e.setup, e.coaching_points, e.simulator_slug
                        FROM club_game_model_session_exercises se
                        JOIN club_game_model_exercises e ON e.id = se.exercise_id
                        WHERE se.session_id = )" + std::to_string(session_id) + R"(
                          AND e.is_active = true
                        ORDER BY se.sort_order, se.id
                    )";
                    pqxx::result session_exercises_result = db_->query(session_exercises_query);

                    bool first_exercise = true;
                    for (const auto& exercise_row : session_exercises_result) {
                        if (!first_exercise) plan_json << ",";
                        first_exercise = false;

                        long long exercise_id = exercise_row["exercise_id"].as<long long>();
                        plan_json << "{";
                        plan_json << "\"id\":" << exercise_id << ",";
                        plan_json << "\"slug\":" << "\"" << escapeJson(exercise_row["slug"].c_str()) << "\"" << ",";
                        plan_json << "\"title\":" << "\"" << escapeJson(exercise_row["title"].c_str()) << "\"" << ",";
                        plan_json << "\"summary\":" << (exercise_row["exercise_summary"].is_null() ? "null" : "\"" + escapeJson(exercise_row["exercise_summary"].c_str()) + "\"") << ",";
                        plan_json << "\"setup\":" << (exercise_row["setup"].is_null() ? "null" : "\"" + escapeJson(exercise_row["setup"].c_str()) + "\"") << ",";
                        plan_json << "\"coaching_points\":" << (exercise_row["coaching_points"].is_null() ? "null" : "\"" + escapeJson(exercise_row["coaching_points"].c_str()) + "\"") << ",";
                        plan_json << "\"simulator_slug\":" << (exercise_row["simulator_slug"].is_null() ? "null" : "\"" + escapeJson(exercise_row["simulator_slug"].c_str()) + "\"") << ",";
                        plan_json << "\"player_count\":" << (exercise_row["player_count"].is_null() ? "null" : std::to_string(exercise_row["player_count"].as<int>())) << ",";
                        plan_json << "\"duration_minutes\":" << (exercise_row["duration_minutes"].is_null() ? "null" : std::to_string(exercise_row["duration_minutes"].as<int>())) << ",";
                        plan_json << "\"notes\":" << (exercise_row["notes"].is_null() ? "null" : "\"" + escapeJson(exercise_row["notes"].c_str()) + "\"");
                        plan_json << "}";
                    }
                    plan_json << "]";
                    plan_json << "}";
                }
                plan_json << "]";
                plan_json << "}";
            }
            plan_json << "]";
            plan_json << "}";
        }
        plan_json << "]";

        std::string number_patterns_query = R"(
            SELECT id, slug, name, description, min_players, max_players, sort_order
            FROM club_game_model_number_patterns
            WHERE club_id = )" + std::to_string(club_id) + R"(
              AND is_active = true
            ORDER BY sort_order, id
        )";
        pqxx::result number_patterns_result = db_->query(number_patterns_query);

        plan_json << ",\"number_patterns\":[";
        bool first_pattern = true;
        for (const auto& pattern_row : number_patterns_result) {
            if (!first_pattern) plan_json << ",";
            first_pattern = false;

            plan_json << "{";
            plan_json << "\"id\":" << pattern_row["id"].as<long long>() << ",";
            plan_json << "\"slug\":" << "\"" << escapeJson(pattern_row["slug"].c_str()) << "\"" << ",";
            plan_json << "\"name\":" << "\"" << escapeJson(pattern_row["name"].c_str()) << "\"" << ",";
            plan_json << "\"description\":" << (pattern_row["description"].is_null() ? "null" : "\"" + escapeJson(pattern_row["description"].c_str()) + "\"") << ",";
            plan_json << "\"min_players\":" << pattern_row["min_players"].as<int>() << ",";
            plan_json << "\"max_players\":" << pattern_row["max_players"].as<int>();
            plan_json << "}";
        }
        plan_json << "]";
        plan_json << "}";

        if (content_html.empty()) {
            content_html = R"(<article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3); display: grid; gap: var(--space-3);"><h4 style="margin: 0;">Spain/UEFA-style 4-4-2 game model</h4><p style="margin: 0; opacity: 0.9;">The identity is positional, patient, and compact. The team builds through the back line, creates the free player in the middle, and attacks with rhythm and purpose.</p><div style="display: grid; gap: 0.65rem;"><div><strong>Primary principle:</strong> Play with control, shape, and clear positional structure.</div><div><strong>Sub-principle:</strong> Build from the back and create easy support angles before the attack becomes vertical.</div><div><strong>Sub-sub-principle:</strong> The first pass should create a next pass, not just a simple carry.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Offense</strong></div><div><strong>Principle:</strong> Create overloads in the middle and free a player in the attacking third.</div><div><strong>Sub-principle:</strong> The midfielders connect the build to the attack and the full-backs support the width.</div><div><strong>Sub-sub-principle:</strong> The third-man run is the main trigger to break the line.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Defense</strong></div><div><strong>Principle:</strong> Defend compact and aggressive as a unit.</div><div><strong>Sub-principle:</strong> Press together, protect the central lane, and force the ball wide.</div><div><strong>Sub-sub-principle:</strong> The nearest player presses, the second covers, and the third balances the space.</div></div><div style="display: grid; gap: 0.65rem;"><div><strong>Transitions</strong></div><div><strong>Transition to offense:</strong> As soon as the ball is won, attack immediately with a quick vertical action.</div><div><strong>Sub-principle:</strong> The first pass should break the line or create a second action.</div><div><strong>Transition to defense:</strong> If the ball is lost, recover into the compact shape and protect the middle.</div><div><strong>Sub-principle:</strong> The first recovery run must make the block compact again.</div></div></article>)";
        }

        std::ostringstream data;
        data << "{";
        data << "\"content_html\":" << "\"" << escapeJson(content_html) << "\"";
        data << ",\"plan\":" << plan_json.str();
        data << "}";

        return Response(HttpStatus::OK, createJSONResponse(true, "Game model content retrieved", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetClubGameModel: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
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
        if (club_id_str.empty()) return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid path"));
        
        int club_id = std::stoi(club_id_str);

        // Optional ?gender=mens|womens|youth filter.  Defaults to 'mens' so
        // the mens /lineups screen (which calls /api/clubs/:id with no
        // params) only sees its own teams.  Passing 'all' disables the
        // filter — useful for admin views that want every team.  Anything
        // else falls back to 'mens'.
        std::string gender = request.getQueryParam("gender");
        if (gender.empty()) gender = "mens";

        std::string genderFilter;
        if (gender == "all") {
            genderFilter = "";
        } else {
            // SQL-safe: gender is a tiny enum-ish string; reject anything
            // other than the known set so a stray query value can't slip
            // into the SQL.
            if (gender != "mens" && gender != "womens" && gender != "youth") {
                gender = "mens";
            }
            // gender_category IS NULL counts as 'mens' for backward compat
            // until every team has been categorized.
            if (gender == "mens") {
                genderFilter = " AND (t.gender_category = 'mens' OR t.gender_category IS NULL)";
            } else {
                genderFilter = " AND t.gender_category = '" + gender + "'";
            }
        }

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
                t.is_pool,
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
            WHERE t.club_id = )" + std::to_string(club_id) + genderFilter + R"(
            GROUP BY t.id, t.name, t.is_pool, d.name, s.name, l.name
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
            teamsJson << "\"is_pool\":" << (teamRow["is_pool"].as<bool>(false) ? "true" : "false") << ",";
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}
