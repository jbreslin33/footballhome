#include "InternalRosterController.h"
#include <sstream>
#include <iomanip>
#include <iostream>
#include <regex>

// ============================================================================
// Lighthouse internal team IDs (created in migration 038)
// ============================================================================
static const int INTERNAL_TEAM_IDS[]  = {901, 902, 903, 904, 905, 906, 907, 908, 909};
static const int INTERNAL_TEAM_COUNT  = 9;
// Squad dimension (901-906): only one allowed at a time per player
static const int SQUAD_TEAM_IDS[]     = {901, 902, 903, 904, 905, 906};
static const int SQUAD_TEAM_COUNT     = 6;
// League dimension (907-909): only one allowed at a time per player
static const int LEAGUE_TEAM_IDS[]    = {907, 908, 909};
static const int LEAGUE_TEAM_COUNT    = 3;

InternalRosterController::InternalRosterController() {
    db_ = Database::getInstance();
}

// ============================================================================
// Route Registration
// ============================================================================
void InternalRosterController::registerRoutes(Router& router, const std::string& prefix) {
    // GET /api/internal/teams
    router.get(prefix + "/teams", [this](const Request& request) {
        return this->handleGetTeams(request);
    });

    // GET /api/internal/roster
    // Registered through laGet(dynamic) — the query reads person_la_memberships
    // across every category (active + pickup) to compute the Lighthouse pool
    // (§ Membership Data Flow: any endpoint that reads person_la_memberships
    // MUST sync every program it depends on first).  allLaProgramIds() returns
    // the full registry, and Controller::syncPrograms fans them out in
    // parallel before the handler runs.
    laGet(router, prefix + "/roster",
        [](const Request&) { return Controller::allLaProgramIds(); },
        [this](const Request& req, const LaSyncMap& sync) {
            return this->handleGetRoster(req, sync);
        });

    // PUT /api/internal/roster/:playerId/team
    router.put(prefix + "/roster/:playerId/team", [this](const Request& request) {
        return this->handleAssignPlayer(request);
    });

    // POST /api/internal/players
    router.post(prefix + "/players", [this](const Request& request) {
        return this->handleCreatePlayer(request);
    });

    // DELETE /api/internal/roster/:playerId
    router.del(prefix + "/roster/:playerId", [this](const Request& request) {
        return this->handleDeletePlayer(request);
    });

    // PUT /api/internal/roster/:playerId/attrs
    router.put(prefix + "/roster/:playerId/attrs", [this](const Request& request) {
        return this->handleUpdatePlayerAttrs(request);
    });
}

// ============================================================================
// GET /api/internal/teams
// Returns the 6 Lighthouse summer teams with player counts
// ============================================================================
Response InternalRosterController::handleGetTeams(const Request& request) {
    try {
        std::string query = R"(
            SELECT
                t.id,
                t.name,
                COUNT(wr.id) FILTER (WHERE wr.removed_at IS NULL) AS player_count
            FROM teams t
            JOIN divisions d ON d.id = t.division_id
            JOIN conferences c ON c.id = d.conference_id
            LEFT JOIN working_rosters wr ON wr.team_id = t.id
            WHERE c.name = 'Lighthouse Squads'
            GROUP BY t.id, t.name
            ORDER BY t.id
        )";

        pqxx::result result = db_->query(query);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{"
                 << "\"id\":" << row["id"].as<int>() << ","
                 << "\"name\":\"" << escapeJson(row["name"].as<std::string>()) << "\","
                 << "\"playerCount\":" << row["player_count"].as<int>()
                 << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJsonResponse(true, "Teams retrieved", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ InternalRosterController::handleGetTeams: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to retrieve teams"));
    }
}

// ============================================================================
// GET /api/internal/roster
// All Lighthouse-pool players with their current working-roster assignment
// ============================================================================
Response InternalRosterController::handleGetRoster(const Request& request, const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laGet(); handler reads DB only.
    try {
        // Build comma-separated list of internal team IDs for IN clause
        std::string teamIdList;
        for (int i = 0; i < INTERNAL_TEAM_COUNT; ++i) {
            if (i > 0) teamIdList += ",";
            teamIdList += std::to_string(INTERNAL_TEAM_IDS[i]);
        }

        std::string query = R"(
            WITH
            -- Universal exclusion: anyone with ANY active 'pickup' LA
            -- membership is a pickup-only player and MUST NOT appear on
            -- any roster page (mens, boys, girls, womens).  Applied here
            -- for the mens roster; the same rule is enforced on the youth
            -- roster pages via the same JOIN pattern.
            pickup_people AS (
                SELECT DISTINCT plm.person_id
                FROM person_la_memberships plm
                JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
                WHERE plm.ended_at IS NULL
                  AND lp.variant = 'pickup'
            ),
            -- People with at least one active NON-pickup LA membership in
            -- ANY category (mens/boys/girls/womens active).  Required for
            -- the "manually moved over" branch: a boys/girls/womens
            -- member manually assigned to a mens working roster still
            -- counts, but only while they hold an active membership
            -- somewhere.  A person with zero active memberships (or
            -- pickup-only) never shows.
            active_members AS (
                SELECT DISTINCT plm.person_id
                FROM person_la_memberships plm
                JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
                WHERE plm.ended_at IS NULL
                  AND lp.variant = 'active'
            ),
            lighthouse_pool AS (
                -- (A) Active Lighthouse Men's Club LA members
                --     (program_id 5039300 = Lighthouse Men's Club 1893
                --     Soccer Membership, category='men', variant='active').
                --     Pickup members are excluded via the NOT EXISTS below.
                SELECT DISTINCT pl.id AS player_id
                FROM players pl
                JOIN person_la_memberships plm
                  ON plm.person_id = pl.person_id
                 AND plm.la_program_id = 5039300
                 AND plm.ended_at IS NULL
                WHERE pl.person_id NOT IN (SELECT person_id FROM pickup_people)
                UNION
                -- (B) Manually moved into a mens working roster (teams
                --     901-909).  Must currently hold an active NON-pickup
                --     LA membership in some category (boys/girls/womens/
                --     mens) — i.e. an actual member of the club, not a
                --     stale roster row or a pickup-only person.
                SELECT DISTINCT wr.player_id
                FROM working_rosters wr
                JOIN players pl ON pl.id = wr.player_id
                WHERE wr.team_id IN ()" + teamIdList + R"()
                  AND wr.removed_at IS NULL
                  AND pl.person_id IN (SELECT person_id FROM active_members)
                  AND pl.person_id NOT IN (SELECT person_id FROM pickup_people)
            )
            SELECT
                p.id                                                    AS player_id,
                per.id                                                  AS person_id,
                per.first_name,
                per.last_name,
                EXTRACT(YEAR FROM per.birth_date)::text                 AS birth_year,
                COALESCE(pt.team_ids, '')                              AS working_team_ids,
                STRING_AGG(DISTINCT ot.name, ', ' ORDER BY ot.name)    AS official_teams,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 1
                         AND pe.category = 'starter' AND pe.subdivision = '')
                                                                        AS elig_apsl_starter,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 1
                         AND pe.category = 'bench' AND pe.subdivision = '')
                                                                        AS elig_apsl_bench,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 2
                         AND pe.category = 'starter' AND pe.subdivision = '')
                                                                        AS elig_liga1_starter,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 2
                         AND pe.category = 'bench' AND pe.subdivision = '')
                                                                        AS elig_liga1_bench,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 2
                         AND pe.category = 'starter' AND pe.subdivision = 'liga2')
                                                                        AS elig_liga2_starter,
                EXISTS(SELECT 1 FROM player_eligibilities pe
                       WHERE pe.player_id = p.id AND pe.source_system_id = 2
                         AND pe.category = 'bench' AND pe.subdivision = 'liga2')
                                                                        AS elig_liga2_bench,
                EXISTS(SELECT 1 FROM player_availability pa
                       WHERE pa.player_id = p.id AND pa.status = 'injured'
                         AND (pa.until_date IS NULL OR pa.until_date >= CURRENT_DATE))
                                                                        AS is_injured,
                EXISTS(SELECT 1 FROM player_availability pa
                       WHERE pa.player_id = p.id AND pa.status = 'suspended_league'
                         AND (pa.until_date IS NULL OR pa.until_date >= CURRENT_DATE))
                                                                        AS is_suspended_league,
                EXISTS(SELECT 1 FROM player_availability pa
                       WHERE pa.player_id = p.id AND pa.status = 'suspended_inhouse'
                         AND (pa.until_date IS NULL OR pa.until_date >= CURRENT_DATE))
                                                                        AS is_suspended_inhouse,
                (SELECT r.jersey_number FROM rosters r
                 WHERE r.player_id = p.id AND r.left_at IS NULL
                 ORDER BY r.id DESC LIMIT 1)                            AS jersey_number,
                TO_CHAR(per.birth_date, 'YYYY-MM-DD')                  AS date_of_birth,
                p.is_keeper,
                p.is_designated,
                p.is_child,
                COALESCE(p.num_clubs, 1)                               AS num_clubs,
                ppn.position
            FROM lighthouse_pool lp
            JOIN players  p   ON p.id  = lp.player_id
            JOIN persons  per ON per.id = p.person_id
            LEFT JOIN (
                SELECT player_id,
                       STRING_AGG(CAST(team_id AS VARCHAR), ',' ORDER BY team_id) AS team_ids
                FROM working_rosters
                WHERE team_id IN ()" + teamIdList + R"()
                  AND removed_at IS NULL
                GROUP BY player_id
            ) pt ON pt.player_id = p.id
            LEFT JOIN rosters r2
                   ON r2.player_id = p.id AND r2.left_at IS NULL
            LEFT JOIN teams ot
                   ON ot.id = r2.team_id
                  AND ot.id NOT IN ()" + teamIdList + R"()
            LEFT JOIN player_planner_notes ppn ON ppn.player_id = p.id
            GROUP BY p.id, per.id, per.first_name, per.last_name, per.birth_date,
                     pt.team_ids, ppn.position,
                     p.is_keeper, p.is_designated, p.is_child, p.num_clubs
            ORDER BY per.last_name, per.first_name
        )";

        pqxx::result result = db_->query(query);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;

            auto nullOrStr = [&](const char* col) -> std::string {
                return row[col].is_null() ? "null" : "\"" + escapeJson(row[col].as<std::string>()) + "\"";
            };
            auto boolVal = [&](const char* col) -> std::string {
                return row[col].as<bool>() ? "true" : "false";
            };
            auto csvToJsonArray = [](const std::string& csv) -> std::string {
                return csv.empty() ? "[]" : "[" + csv + "]";
            };

            json << "{"
                 << "\"playerId\":"         << row["player_id"].as<int>() << ","
                 << "\"personId\":"         << row["person_id"].as<int>() << ","
                 << "\"firstName\":"        << nullOrStr("first_name") << ","
                 << "\"lastName\":"         << nullOrStr("last_name") << ","
                 << "\"birthYear\":"        << nullOrStr("birth_year") << ","
                 << "\"workingTeamIds\":"   << csvToJsonArray(row["working_team_ids"].as<std::string>()) << ","
                 << "\"officialTeams\":"    << nullOrStr("official_teams") << ","
                 << "\"eligApslStarter\":"  << boolVal("elig_apsl_starter") << ","
                 << "\"eligApslBench\":"    << boolVal("elig_apsl_bench") << ","
                 << "\"eligLiga1Starter\":" << boolVal("elig_liga1_starter") << ","
                 << "\"eligLiga1Bench\":"   << boolVal("elig_liga1_bench") << ","
                 << "\"eligLiga2Starter\":" << boolVal("elig_liga2_starter") << ","
                 << "\"eligLiga2Bench\":"   << boolVal("elig_liga2_bench") << ","
                 << "\"isInjured\":"           << boolVal("is_injured") << ","
                 << "\"isSuspendedLeague\":"   << boolVal("is_suspended_league") << ","
                 << "\"isSuspendedInhouse\":"  << boolVal("is_suspended_inhouse") << ","
                 << "\"jerseyNumber\":"        << nullOrStr("jersey_number") << ","
                 << "\"dateOfBirth\":"         << nullOrStr("date_of_birth") << ","
                 << "\"isKeeper\":"            << boolVal("is_keeper") << ","
                 << "\"isDesignated\":"        << boolVal("is_designated") << ","
                 << "\"isChild\":"             << boolVal("is_child") << ","
                 << "\"numClubs\":"            << row["num_clubs"].as<int>() << ","
                 << "\"position\":"            << nullOrStr("position")
                 << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJsonResponse(true, "Roster retrieved", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ InternalRosterController::handleGetRoster: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to retrieve roster"));
    }
}

// ============================================================================
// PUT /api/internal/roster/:playerId/team
// Body: {"teamId": 901}  — or {"teamId": null} to remove from all teams
// ============================================================================
Response InternalRosterController::handleAssignPlayer(const Request& request) {
    std::string playerIdStr = extractPlayerId(request.getPath());
    if (playerIdStr.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Player ID required"));
    }

    const std::string& body = request.getBody();
    std::string teamIdStr   = parseJsonString(body, "teamId");
    bool remove             = (teamIdStr.empty() || teamIdStr == "null");
    int  teamId             = remove ? 0 : parseJsonInt(body, "teamId");
    bool onlyRemove         = (parseJsonString(body, "onlyRemove") == "true");
    bool onlyAdd            = (parseJsonString(body, "onlyAdd")    == "true");

    // Validate teamId is one of the internal teams
    if (!remove) {
        bool valid = false;
        for (int i = 0; i < INTERNAL_TEAM_COUNT; ++i) {
            if (INTERNAL_TEAM_IDS[i] == teamId) { valid = true; break; }
        }
        if (!valid) {
            return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Invalid team ID"));
        }
    }

    try {
        if (onlyRemove && !remove) {
            // Remove from this one specific team only — no reassignment
            db_->query(
                "UPDATE working_rosters SET removed_at = CURRENT_TIMESTAMP "
                "WHERE player_id = $1::int AND team_id = $2::int AND removed_at IS NULL",
                {playerIdStr, std::to_string(teamId)});
        } else if (onlyAdd && !remove) {
            // Add to this team only — do not remove from any other team
            db_->query(
                "INSERT INTO working_rosters (team_id, player_id) VALUES ($1::int, $2::int)",
                {std::to_string(teamId), playerIdStr});
        } else {
        // Build comma-separated list for IN clause
        std::string teamIdList;
        for (int i = 0; i < INTERNAL_TEAM_COUNT; ++i) {
            if (i > 0) teamIdList += ",";
            teamIdList += std::to_string(INTERNAL_TEAM_IDS[i]);
        }

        // Determine which dimension to remove from (squad 901-906 or league 907-909)
        std::string removalList;
        if (remove) {
            removalList = teamIdList;
        } else {
            bool inSquad = false, inLeague = false;
            for (int i = 0; i < SQUAD_TEAM_COUNT;  ++i) if (SQUAD_TEAM_IDS[i]  == teamId) { inSquad  = true; break; }
            if (!inSquad)
            for (int i = 0; i < LEAGUE_TEAM_COUNT; ++i) if (LEAGUE_TEAM_IDS[i] == teamId) { inLeague = true; break; }

            if (inSquad) {
                for (int i = 0; i < SQUAD_TEAM_COUNT; ++i) {
                    if (i > 0) removalList += ",";
                    removalList += std::to_string(SQUAD_TEAM_IDS[i]);
                }
            } else if (inLeague) {
                for (int i = 0; i < LEAGUE_TEAM_COUNT; ++i) {
                    if (i > 0) removalList += ",";
                    removalList += std::to_string(LEAGUE_TEAM_IDS[i]);
                }
            } else {
                removalList = teamIdList;
            }
        }

        // Remove from the appropriate dimension only
        db_->query(
            "UPDATE working_rosters SET removed_at = CURRENT_TIMESTAMP "
            "WHERE player_id = $1::int AND team_id IN (" + removalList + ") AND removed_at IS NULL",
            {playerIdStr});

        // Insert into new team unless removing
        if (!remove) {
            db_->query(
                "INSERT INTO working_rosters (team_id, player_id) VALUES ($1::int, $2::int)",
                {std::to_string(teamId), playerIdStr});
        }
        } // end else

        std::ostringstream data;
        data << "{\"playerId\":" << playerIdStr
             << ",\"teamId\":"   << (remove ? "null" : std::to_string(teamId))
             << "}";

        return Response(HttpStatus::OK, createJsonResponse(true, "Assignment updated", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ InternalRosterController::handleAssignPlayer: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to update assignment"));
    }
}

// ============================================================================
// POST /api/internal/players
// Body: {"firstName":"...", "lastName":"...", "birthYear":2003}
// Creates person + player record.
// ============================================================================
Response InternalRosterController::handleCreatePlayer(const Request& request) {
    const std::string& body = request.getBody();
    std::string firstName   = parseJsonString(body, "firstName");
    std::string lastName    = parseJsonString(body, "lastName");
    int  birthYear          = parseJsonInt(body, "birthYear");

    if (firstName.empty() || lastName.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "firstName and lastName required"));
    }

    try {
        // Insert person, or reuse existing if name already exists
        std::string birthDate = (birthYear > 0)
            ? std::to_string(birthYear) + "-01-01"
            : "";

        pqxx::result personResult;
        if (!birthDate.empty()) {
            personResult = db_->query(
                "INSERT INTO persons (first_name, last_name, birth_date) "
                "VALUES ($1, $2, $3::date) "
                "ON CONFLICT (first_name, last_name) DO UPDATE SET updated_at = CURRENT_TIMESTAMP "
                "RETURNING id",
                {firstName, lastName, birthDate});
        } else {
            personResult = db_->query(
                "INSERT INTO persons (first_name, last_name) VALUES ($1, $2) "
                "ON CONFLICT (first_name, last_name) DO UPDATE SET updated_at = CURRENT_TIMESTAMP "
                "RETURNING id",
                {firstName, lastName});
        }

        if (personResult.empty()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to create person"));
        }
        int personId = personResult[0]["id"].as<int>();

        // Insert player (linked to internal source system 5)
        // If this person is already a player, return a friendly error
        pqxx::result playerResult = db_->query(
            "INSERT INTO players (person_id, source_system_id) VALUES ($1::int, 5) "
            "ON CONFLICT (person_id) DO NOTHING RETURNING id",
            {std::to_string(personId)});

        if (playerResult.empty()) {
            return Response(HttpStatus::CONFLICT, createJsonResponse(false, "A player with this name already exists in the system"));
        }
        int playerId = playerResult[0]["id"].as<int>();

        std::ostringstream data;
        data << "{\"playerId\":" << playerId
             << ",\"personId\":" << personId
             << ",\"firstName\":\"" << escapeJson(firstName) << "\""
             << ",\"lastName\":\""  << escapeJson(lastName) << "\""
             << ",\"birthYear\":"   << (birthYear > 0 ? std::to_string(birthYear) : "null")
             << "}";

        return Response(HttpStatus::CREATED, createJsonResponse(true, "Player created", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ InternalRosterController::handleCreatePlayer: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to create player"));
    }
}

// ============================================================================
// DELETE /api/internal/roster/:playerId
// Permanently removes a player (and their person record if orphaned).
// Non-cascading match_events.assisted_by_player_id is nulled first.
// ============================================================================
Response InternalRosterController::handleDeletePlayer(const Request& request) {
    std::string playerIdStr = extractPlayerId(request.getPath());
    if (playerIdStr.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Player ID required"));
    }

    try {
        // Get person_id before deleting
        pqxx::result playerRow = db_->query(
            "SELECT person_id FROM players WHERE id = $1::int",
            {playerIdStr});

        if (playerRow.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Player not found"));
        }
        std::string personIdStr = std::to_string(playerRow[0]["person_id"].as<int>());

        // Null out non-cascading assists reference
        db_->query(
            "UPDATE match_events SET assisted_by_player_id = NULL "
            "WHERE assisted_by_player_id = $1::int",
            {playerIdStr});

        // Delete player — all other FKs cascade
        db_->query("DELETE FROM players WHERE id = $1::int", {playerIdStr});

        // Delete person only if no other player or user still references it
        db_->query(
            "DELETE FROM persons WHERE id = $1::int "
            "AND NOT EXISTS (SELECT 1 FROM players WHERE person_id = $1::int) "
            "AND NOT EXISTS (SELECT 1 FROM users   WHERE person_id = $1::int)",
            {personIdStr});

        return Response(HttpStatus::OK, createJsonResponse(true, "Player deleted"));
    } catch (const std::exception& e) {
        std::cerr << "❌ InternalRosterController::handleDeletePlayer: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to delete player"));
    }
}

// ============================================================================
// Helpers
// ============================================================================
std::string InternalRosterController::parseJsonString(const std::string& body, const std::string& key) {
    std::string search = "\"" + key + "\"";
    size_t pos = body.find(search);
    if (pos == std::string::npos) return "";
    pos = body.find(":", pos);
    if (pos == std::string::npos) return "";
    ++pos;
    while (pos < body.size() && (body[pos] == ' ' || body[pos] == '\t')) ++pos;
    if (pos >= body.size()) return "";
    if (body.substr(pos, 4) == "null") return "null";
    bool quoted = (body[pos] == '"');
    if (quoted) ++pos;
    size_t end = quoted ? body.find('"', pos) : body.find_first_of(",}", pos);
    if (end == std::string::npos) return "";
    return body.substr(pos, end - pos);
}

int InternalRosterController::parseJsonInt(const std::string& body, const std::string& key, int defaultValue) {
    std::string val = parseJsonString(body, key);
    if (val.empty() || val == "null") return defaultValue;
    try { return std::stoi(val); } catch (...) { return defaultValue; }
}


std::string InternalRosterController::createJsonResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{\"success\":" << (success ? "true" : "false")
         << ",\"message\":\"" << escapeJson(message) << "\"";
    if (!data.empty()) json << ",\"data\":" << data;
    json << "}";
    return json.str();
}

std::string InternalRosterController::extractPlayerId(const std::string& path) {
    std::regex re("/api/internal/roster/(\\d+)(?:/(?:team|attrs))?(?:/|$)");
    std::smatch m;
    if (std::regex_search(path, m, re)) return m[1].str();
    return "";
}

// ============================================================================
// PUT /api/internal/roster/:playerId/attrs
// Body: {"position":"CM", "injured":true}
// Updates player position in player_planner_notes and injury in player_availability.
// ============================================================================
Response InternalRosterController::handleUpdatePlayerAttrs(const Request& request) {
    std::string playerIdStr = extractPlayerId(request.getPath());
    if (playerIdStr.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Player ID required"));
    }

    const std::string& body = request.getBody();

    bool hasPosition = (body.find("\"position\"") != std::string::npos);
    std::string positionStr = parseJsonString(body, "position");
    bool positionIsNull = positionStr.empty() || positionStr == "null";

    bool hasInjured = (body.find("\"injured\"") != std::string::npos);
    std::string injuredStr = parseJsonString(body, "injured");
    bool injured = (injuredStr == "true");

    try {
        if (hasPosition) {
            if (positionIsNull) {
                db_->query(
                    "DELETE FROM player_planner_notes WHERE player_id = $1::int",
                    {playerIdStr});
            } else {
                db_->query(
                    "INSERT INTO player_planner_notes (player_id, position, updated_at) "
                    "VALUES ($1::int, $2, CURRENT_TIMESTAMP) "
                    "ON CONFLICT (player_id) DO UPDATE SET position = EXCLUDED.position, updated_at = CURRENT_TIMESTAMP",
                    {playerIdStr, positionStr});
            }
        }

        if (hasInjured) {
            if (injured) {
                pqxx::result existing = db_->query(
                    "SELECT id FROM player_availability WHERE player_id = $1::int "
                    "AND status = 'injured' AND (until_date IS NULL OR until_date >= CURRENT_DATE)",
                    {playerIdStr});
                if (existing.empty()) {
                    db_->query(
                        "INSERT INTO player_availability (player_id, status) VALUES ($1::int, 'injured')",
                        {playerIdStr});
                }
            } else {
                db_->query(
                    "UPDATE player_availability SET until_date = CURRENT_DATE - INTERVAL '1 day' "
                    "WHERE player_id = $1::int AND status = 'injured' "
                    "AND (until_date IS NULL OR until_date >= CURRENT_DATE)",
                    {playerIdStr});
            }
        }

        return Response(HttpStatus::OK, createJsonResponse(true, "Player attributes updated"));
    } catch (const std::exception& e) {
        std::cerr << "\u274c InternalRosterController::handleUpdatePlayerAttrs: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to update player attributes"));
    }
}
