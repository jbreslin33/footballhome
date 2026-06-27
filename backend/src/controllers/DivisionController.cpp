#include "DivisionController.h"
#include <iostream>
#include <sstream>
#include <regex>

// Helper function to escape JSON strings

DivisionController::DivisionController() {
    db_ = Database::getInstance();
}

void DivisionController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering division routes with prefix: " << prefix << std::endl;
    
    // Get all divisions
    router.get(prefix + "/divisions", [this](const Request& request) {
        return this->handleGetDivisions(request);
    });
    
    // Get divisions for a specific club
    router.get(prefix + "/clubs/:clubId/divisions", [this](const Request& request) {
        return this->handleGetClubDivisions(request);
    });
    
    // Get division players
    router.get(prefix + "/divisions/:divisionId/players", [this](const Request& request) {
        return this->handleGetDivisionPlayers(request);
    });

    // Update division player
    router.put(prefix + "/divisions/:divisionId/players/:playerId", [this](const Request& request) {
        return this->handleUpdateDivisionPlayer(request);
    });
}

Response DivisionController::handleGetDivisions(const Request& request) {
    std::cout << "=== handleGetDivisions ===" << std::endl;

    try {
        // Divisions live inside conferences -> seasons -> leagues.
        // There is no direct club_id on divisions; clubs relate via teams.
        std::string query =
            "SELECT d.id, d.name, "
            "       c.name AS conference_name, "
            "       s.name AS season_name, "
            "       l.name AS league_name "
            "FROM divisions d "
            "JOIN conferences c ON c.id = d.conference_id "
            "JOIN seasons s ON s.id = d.season_id "
            "JOIN leagues l ON l.id = s.league_id "
            "ORDER BY l.name, s.name, c.name, d.sort_order, d.name";

        pqxx::result result = db_->query(query);

        std::cout << "Found " << result.size() << " divisions" << std::endl;

        // Build JSON array of divisions
        std::ostringstream divisionsJson;
        divisionsJson << "[";

        bool first = true;
        for (const auto& row : result) {
            if (!first) divisionsJson << ",";
            first = false;

            divisionsJson << "{";
            divisionsJson << "\"id\":" << row["id"].c_str() << ",";
            divisionsJson << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
            divisionsJson << "\"conference_name\":\"" << escapeJson(row["conference_name"].c_str()) << "\",";
            divisionsJson << "\"season_name\":\"" << escapeJson(row["season_name"].c_str()) << "\",";
            divisionsJson << "\"league_name\":\"" << escapeJson(row["league_name"].c_str()) << "\"";
            divisionsJson << "}";
        }

        divisionsJson << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Divisions retrieved successfully", divisionsJson.str()));

    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetDivisions: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response DivisionController::handleGetClubDivisions(const Request& request) {
    std::cout << "=== handleGetClubDivisions ===" << std::endl;
    std::cout << "Path: " << request.getPath() << std::endl;

    try {
        // Extract club_id from path: /clubs/{integer}/divisions.
        std::string path = request.getPath();
        std::regex pattern(R"(/clubs/(\d+)/divisions)");
        std::smatch matches;
        std::string clubId;
        if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
            clubId = matches[1].str();
        }
        if (clubId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid club ID"));
        }

        std::cout << "Club ID: " << clubId << std::endl;

        // Divisions associated with a club via its teams.  A club has many
        // teams; each team belongs to exactly one division.  DISTINCT
        // collapses duplicates when multiple teams from the same club land
        // in the same division.
        std::string query =
            "SELECT DISTINCT d.id, d.name, "
            "       c.name AS conference_name, "
            "       s.name AS season_name, "
            "       l.name AS league_name, "
            "       d.sort_order "
            "FROM divisions d "
            "JOIN teams t ON t.division_id = d.id "
            "JOIN conferences c ON c.id = d.conference_id "
            "JOIN seasons s ON s.id = d.season_id "
            "JOIN leagues l ON l.id = s.league_id "
            "WHERE t.club_id = $1::int "
            "ORDER BY l.name, s.name, c.name, d.sort_order, d.name";

        pqxx::result result = db_->query(query, {clubId});

        std::cout << "Found " << result.size() << " divisions for club" << std::endl;

        std::ostringstream divisionsJson;
        divisionsJson << "[";

        bool first = true;
        for (const auto& row : result) {
            if (!first) divisionsJson << ",";
            first = false;

            divisionsJson << "{";
            divisionsJson << "\"id\":" << row["id"].c_str() << ",";
            divisionsJson << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
            divisionsJson << "\"conference_name\":\"" << escapeJson(row["conference_name"].c_str()) << "\",";
            divisionsJson << "\"season_name\":\"" << escapeJson(row["season_name"].c_str()) << "\",";
            divisionsJson << "\"league_name\":\"" << escapeJson(row["league_name"].c_str()) << "\"";
            divisionsJson << "}";
        }

        divisionsJson << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Divisions retrieved successfully", divisionsJson.str()));

    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetClubDivisions: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response DivisionController::handleGetDivisionPlayers(const Request& request) {
    std::cout << "=== handleGetDivisionPlayers ===" << std::endl;
    std::cout << "Path: " << request.getPath() << std::endl;

    try {
        // Extract division_id from path
        std::string divisionId = extractDivisionIdFromPath(request.getPath());
        if (divisionId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, createJSONResponse(false, "Invalid division ID"));
        }

        std::cout << "Division ID: " << divisionId << std::endl;

        // Status filter.  The data model only tracks "active" (rosters with
        // left_at IS NULL) vs historical.  We expose:
        //   active (default) → players currently on at least one team in
        //                      this division
        //   all              → distinct players who have EVER been on a
        //                      team in this division
        // Any other value is treated as "active".
        std::string status = request.getQueryParam("status");
        if (status.empty()) status = "active";
        const bool includeHistorical = (status == "all");
        std::cout << "Status filter: " << status
                  << " (includeHistorical=" << (includeHistorical ? "yes" : "no") << ")"
                  << std::endl;

        std::string query =
            "SELECT DISTINCT ON (p.id) "
            "       p.id AS player_id, "
            "       per.first_name, per.last_name, "
            "       per.birth_date AS date_of_birth, "
            "       (r.left_at IS NULL) AS is_active, "
            "       (SELECT email        FROM person_emails WHERE person_id = per.id ORDER BY is_primary DESC, id LIMIT 1) AS email, "
            "       (SELECT phone_number FROM person_phones WHERE person_id = per.id ORDER BY is_primary DESC, id LIMIT 1) AS phone "
            "FROM teams t "
            "JOIN rosters r ON r.team_id = t.id "
            "JOIN players p ON p.id = r.player_id "
            "JOIN persons per ON per.id = p.person_id "
            "WHERE t.division_id = $1::int ";
        if (!includeHistorical) {
            query += "  AND r.left_at IS NULL ";
        }
        // ORDER BY needs to lead with the DISTINCT ON expression (p.id),
        // then anything else.  Sort the resulting one-row-per-player set
        // again at the SQL level — last_name/first_name — so the API is
        // deterministic regardless of natural roster order.
        query =
            "WITH players_for_div AS (" + query + " ORDER BY p.id, r.left_at IS NULL DESC, r.joined_at DESC) "
            "SELECT * FROM players_for_div ORDER BY last_name, first_name";

        pqxx::result result = db_->query(query, {divisionId});

        std::cout << "Found " << result.size() << " players" << std::endl;

        std::ostringstream playersJson;
        playersJson << "[";

        bool first = true;
        for (const auto& row : result) {
            if (!first) playersJson << ",";
            first = false;

            const bool isActive = !row["is_active"].is_null() && row["is_active"].as<bool>();

            playersJson << "{";
            playersJson << "\"player_id\":" << row["player_id"].c_str() << ",";
            playersJson << "\"division_id\":" << divisionId << ",";
            playersJson << "\"status\":\"" << (isActive ? "active" : "inactive") << "\",";
            playersJson << "\"registration_number\":null,";

            playersJson << "\"first_name\":\"" << escapeJson(row["first_name"].c_str()) << "\",";
            playersJson << "\"last_name\":\"" << escapeJson(row["last_name"].c_str()) << "\",";

            if (!row["date_of_birth"].is_null()) {
                playersJson << "\"date_of_birth\":\"" << escapeJson(row["date_of_birth"].c_str()) << "\",";
            } else {
                playersJson << "\"date_of_birth\":null,";
            }

            if (!row["email"].is_null()) {
                playersJson << "\"email\":\"" << escapeJson(row["email"].c_str()) << "\",";
            } else {
                playersJson << "\"email\":null,";
            }

            if (!row["phone"].is_null()) {
                playersJson << "\"phone\":\"" << escapeJson(row["phone"].c_str()) << "\"";
            } else {
                playersJson << "\"phone\":null";
            }

            playersJson << "}";
        }

        playersJson << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Players retrieved successfully", playersJson.str()));

    } catch (const std::exception& e) {
        std::cerr << "Error in handleGetDivisionPlayers: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

std::string DivisionController::extractDivisionIdFromPath(const std::string& path) {
    // Match integer ID: /divisions/{id}
    std::regex pattern(R"(/divisions/(\d+))");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

std::string DivisionController::extractPlayerIdFromPath(const std::string& path) {
    // Match integer ID: /players/{id}
    std::regex pattern(R"(/players/(\d+))");
    std::smatch matches;
    if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
        return matches[1].str();
    }
    return "";
}

Response DivisionController::handleUpdateDivisionPlayer(const Request& request) {
    try {
        std::string divisionId = extractDivisionIdFromPath(request.getPath());
        std::string playerId = extractPlayerIdFromPath(request.getPath());

        if (divisionId.empty() || playerId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid division ID or player ID"));
        }

        std::string body = request.getBody();

        // Parse fields the frontend sends.  Status and registrationNumber
        // are accepted but not persisted — the data model has no per-
        // division-player status column, and registration_number isn't
        // tracked at all.  Only first/last name update the underlying
        // person record.
        std::string firstName, lastName;

        std::regex fn_regex(R"rx("firstName"\s*:\s*"([^"]*)")rx");
        std::smatch fn_match;
        if (std::regex_search(body, fn_match, fn_regex)) firstName = fn_match[1].str();

        std::regex ln_regex(R"rx("lastName"\s*:\s*"([^"]*)")rx");
        std::smatch ln_match;
        if (std::regex_search(body, ln_match, ln_regex)) lastName = ln_match[1].str();

        if (firstName.empty() && lastName.empty()) {
            return Response(HttpStatus::OK,
                createJSONResponse(true, "Nothing to update"));
        }

        // Resolve player → person.  Reject if the player doesn't exist or
        // isn't on a team in the supplied division (prevents cross-
        // division edits via URL tampering).
        pqxx::result chk = db_->query(
            "SELECT DISTINCT p.person_id "
            "FROM players p "
            "JOIN rosters r ON r.player_id = p.id "
            "JOIN teams   t ON t.id        = r.team_id "
            "WHERE p.id = $1::int AND t.division_id = $2::int",
            {playerId, divisionId});
        if (chk.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Player not found in this division"));
        }
        const std::string personId = chk[0]["person_id"].c_str();

        if (!firstName.empty() && !lastName.empty()) {
            db_->query(
                "UPDATE persons SET first_name = $1, last_name = $2, "
                "                   updated_at = NOW() "
                "WHERE id = $3::int",
                {firstName, lastName, personId});
        } else if (!firstName.empty()) {
            db_->query(
                "UPDATE persons SET first_name = $1, updated_at = NOW() "
                "WHERE id = $2::int",
                {firstName, personId});
        } else {
            db_->query(
                "UPDATE persons SET last_name = $1, updated_at = NOW() "
                "WHERE id = $2::int",
                {lastName, personId});
        }

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Player updated successfully"));

    } catch (const std::exception& e) {
        std::cerr << "Error in handleUpdateDivisionPlayer: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Database error"));
    }
}

