#include "EligibilityController.h"
#include "../core/Crypto.h"
#include <sstream>
#include <regex>
#include <algorithm>  // std::find — squad colour validation
#include <vector>
#include <iomanip>
#include <iostream>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

// ============================================================================
// Helper: base64url decode (for JWT token parsing)
// ============================================================================

// ============================================================================
// Constructor
// ============================================================================
EligibilityController::EligibilityController() {
    db_ = Database::getInstance();
}

// ============================================================================
// Route Registration
// ============================================================================
void EligibilityController::registerRoutes(Router& router, const std::string& prefix) {
    // GET /api/eligibility/lineup/:matchId - Get saved lineup for a match
    router.get(prefix + "/lineup/:matchId", [this](const Request& request) {
        return this->handleGetMatchLineup(request);
    });
    
    // PUT /api/eligibility/lineup/:matchId - Save match lineup
    router.put(prefix + "/lineup/:matchId", [this](const Request& request) {
        return this->handleSaveMatchLineup(request);
    });
    
    // GET /api/eligibility/lineup-meta/:matchId - Get lineup metadata (formation, roster size)
    router.get(prefix + "/lineup-meta/:matchId", [this](const Request& request) {
        return this->handleGetLineupMetadata(request);
    });
    
    // PUT /api/eligibility/lineup-meta/:matchId - Save lineup metadata
    router.put(prefix + "/lineup-meta/:matchId", [this](const Request& request) {
        return this->handleSaveLineupMetadata(request);
    });

    // GET /api/eligibility/event-squads/:fhEventId - Pickup sides /
    // practice groups for one event (2026-08-28). Keyed on fh_events.id
    // because pickups and practices have no matches row at all.
    router.get(prefix + "/event-squads/:fhEventId", [this](const Request& request) {
        return this->handleGetEventSquads(request);
    });

    // PUT /api/eligibility/event-squads/:fhEventId - Assign players to sides
    router.put(prefix + "/event-squads/:fhEventId", [this](const Request& request) {
        return this->handleSaveEventSquads(request);
    });

    // GET /api/eligibility/positions - Reference list for the Starting XI
    // position picker (2026-08-22) — id/name/abbreviation/sortOrder from
    // the `positions` lookup table. sortOrder 1-11 (Goalkeeper..Right
    // Midfielder) is what the Player Lineup View sorts the Starting XI
    // by and shows as the "1 is keeper, 2 is right back" slot number.
    router.get(prefix + "/positions", [this](const Request& request) {
        return this->handleGetPositions(request);
    });

}

// ============================================================================
// GET /api/eligibility/lineup/:matchId
// Get saved lineup for a match (with slot numbers and zones)
// ============================================================================
Response EligibilityController::handleGetMatchLineup(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/lineup/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }

    try {
        // Caller's team_id + isCoach — this endpoint stays readable by any
        // player (no 401 on a missing/absent token), but the game-lineup
        // screen needs to know whether to render edit vs. read-only.
        pqxx::result teamRow = db_->query(
            "SELECT home_team_id, away_team_id FROM matches WHERE id = $1", {matchId}
        );
        std::string teamIdForResponse = (!teamRow.empty() && !teamRow[0]["home_team_id"].is_null())
            ? teamRow[0]["home_team_id"].c_str() : "";

        // Roster-eligible teams for this match. A game tagged "Team: APSL,
        // Liga1" in gcal (see gcal-classify.js's DSL pass) is one shared
        // squad playing under two league umbrellas — fh_event_teams carries
        // ALL of them, not just matches.home_team_id, which is one column
        // and can't represent that. Everything below (isCoach, practice
        // eligibility, roster pool) is scoped to this full set so a
        // Liga1-only player still shows up for an APSL/Liga1 combined game.
        // Falls back to home/away team_id if the event isn't bridged yet.
        pqxx::result eventTeamsRow = db_->query(
            "SELECT array_agg(DISTINCT fet.team_id) AS team_ids "
            "FROM fh_events fe JOIN fh_event_teams fet ON fet.fh_event_id = fe.id "
            "WHERE fe.match_id = $1",
            {matchId}
        );
        std::string rosterTeamIdsArray; // Postgres array literal, e.g. "{35,120}"
        if (!eventTeamsRow.empty() && !eventTeamsRow[0]["team_ids"].is_null()) {
            rosterTeamIdsArray = eventTeamsRow[0]["team_ids"].c_str();
        } else {
            std::ostringstream fallback;
            fallback << "{";
            bool any = false;
            if (!teamRow.empty() && !teamRow[0]["home_team_id"].is_null()) {
                fallback << teamRow[0]["home_team_id"].c_str();
                any = true;
            }
            if (!teamRow.empty() && !teamRow[0]["away_team_id"].is_null()) {
                if (any) fallback << ",";
                fallback << teamRow[0]["away_team_id"].c_str();
            }
            fallback << "}";
            rosterTeamIdsArray = fallback.str();
        }

        // Same naive-UTC-string convention as the practice pills below (no
        // offset marker) so the frontend's Date parsing treats them
        // identically when rendering the "game" pill after the practice ones.
        pqxx::result matchStartRow = db_->query(
            "SELECT to_char(ge.starts_at, 'YYYY-MM-DD\"T\"HH24:MI:SS') AS starts_at "
            "FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            "WHERE fe.match_id = $1 LIMIT 1",
            {matchId}
        );
        std::string matchStartsAt = (!matchStartRow.empty() && !matchStartRow[0]["starts_at"].is_null())
            ? matchStartRow[0]["starts_at"].c_str() : "";

        bool isCoach = false;
        std::string userId = extractUserIdFromToken(request);
        if (!userId.empty() && !teamRow.empty()) {
            pqxx::result authRows = db_->query(
                "SELECT ("
                "  EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
                "          WHERE u.id = $1::int)"
                "  OR EXISTS (SELECT 1 FROM team_coaches tc "
                "             JOIN coaches co ON co.id = tc.coach_id "
                "             JOIN users u ON u.person_id = co.person_id "
                "             WHERE tc.team_id = ANY($2::int[]) AND tc.ended_at IS NULL "
                "             AND u.id = $1::int)"
                ") AS is_coach",
                {userId, rosterTeamIdsArray});
            isCoach = !authRows.empty() && authRows[0]["is_coach"].as<bool>();
        }

        // Roster stats (practice attendance/projection + this match's RSVP),
        // computed against the CURRENT calendar system (fh_events/
        // fh_event_attendance/fh_event_rsvps) — coach-only, internal info.
        // Keyed by player_id so the frontend can merge it onto the roster
        // fetched separately from /api/teams/:teamId/roster.
        std::ostringstream statsJson;
        statsJson << "[";
        if (isCoach && !rosterTeamIdsArray.empty() && rosterTeamIdsArray != "{}") {
            pqxx::result statsRows = db_->query(R"(
                WITH match_event AS (
                    SELECT fe.id AS fh_event_id, ge.starts_at
                    FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fe.match_id = $1::int
                    LIMIT 1
                ),
                team_practice_events AS (
                    -- ANY(team_ids), not a single team — a game tagged
                    -- "Team: APSL, Liga1" shares one practice pool across
                    -- both leagues (see fh_event_teams), so a Liga1-only
                    -- player's practices are still found here.
                    SELECT DISTINCT fe.id AS fh_event_id, fe.kind, fe.category, ge.starts_at
                    FROM fh_events fe
                    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
                    WHERE fet.team_id = ANY($2::int[])
                      AND fe.kind IN ('practice', 'pickup', 'barn night')
                      AND ge.deleted_at IS NULL
                ),
                recent_practices AS (
                    -- Bounded to the 6 days immediately before the match (Tue-Sat
                    -- for a Sunday game) rather than a pure "last 5 occurred"
                    -- lookback — an unbounded lookback reaches back into the PRIOR
                    -- week to backfill its quota whenever a practice was cancelled,
                    -- producing duplicate weekdays (e.g. two Thursdays). LIMIT 5
                    -- is just a defensive cap; the date window is what matters.
                    SELECT tpe.fh_event_id, tpe.starts_at
                    FROM team_practice_events tpe, match_event me
                    WHERE tpe.starts_at >= me.starts_at - interval '6 days'
                      AND tpe.starts_at <  LEAST(me.starts_at, now())
                    ORDER BY tpe.starts_at DESC
                    LIMIT 5
                ),
                upcoming_practices AS (
                    SELECT tpe.fh_event_id, tpe.kind, tpe.category
                    FROM team_practice_events tpe, match_event me
                    WHERE tpe.starts_at >= now() AND tpe.starts_at < me.starts_at
                ),
                -- Same Tue-Sat window as recent_practices, but NOT cut off at
                -- now() — this is what the pill row renders, so it includes
                -- practices that haven't happened yet (days 4-5 of a 5-day
                -- week when "today" falls mid-week).
                pill_window AS (
                    SELECT tpe.fh_event_id, tpe.kind, tpe.category, tpe.starts_at
                    FROM team_practice_events tpe, match_event me
                    WHERE tpe.starts_at >= me.starts_at - interval '6 days'
                      AND tpe.starts_at <  me.starts_at
                    ORDER BY tpe.starts_at DESC
                    LIMIT 5
                )
                SELECT DISTINCT ON (pl.id) pl.id AS player_id,
                       (SELECT count(*) FROM recent_practices) AS recent_total,
                       (SELECT count(*) FROM fh_event_attendance fea
                          WHERE fea.person_id = pe.id
                            AND fea.fh_event_id IN (SELECT fh_event_id FROM recent_practices)
                            AND fea.status IN ('present', 'late')) AS practices_attended,
                       (SELECT count(*) FROM upcoming_practices) AS upcoming_total,
                       (SELECT count(*) FROM upcoming_practices up
                          WHERE (SELECT r.response FROM fh_event_rsvps r
                                   WHERE r.fh_event_id = up.fh_event_id AND r.person_id = pe.id
                                ) = 'yes') AS practices_projected,
                       (SELECT r.response FROM fh_event_rsvps r, match_event me
                          WHERE r.fh_event_id = me.fh_event_id AND r.person_id = pe.id) AS game_rsvp,
                       (SELECT json_agg(json_build_object(
                                  'date', to_char(pw.starts_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
                                  'future', pw.starts_at >= now(),
                                  'attended', CASE WHEN pw.starts_at >= now() THEN
                                      -- Hasn't happened yet: green if projected to go
                                      -- (explicit RSVP yes), red otherwise.
                                      COALESCE(
                                          (SELECT r.response FROM fh_event_rsvps r
                                             WHERE r.fh_event_id = pw.fh_event_id AND r.person_id = pe.id
                                          ) = 'yes',
                                          false
                                      )
                                  ELSE
                                      EXISTS(
                                          SELECT 1 FROM fh_event_attendance fea
                                          WHERE fea.person_id = pe.id AND fea.fh_event_id = pw.fh_event_id
                                            AND fea.status IN ('present', 'late'))
                                  END
                                ) ORDER BY pw.starts_at)
                          FROM pill_window pw) AS practice_pills
                FROM team_persons tp
                JOIN persons pe ON pe.id = tp.person_id
                JOIN players pl ON pl.person_id = pe.id
                WHERE tp.team_id = ANY($2::int[]) AND tp.removed_at IS NULL
                -- A player rostered on more than one of the eligible teams
                -- (e.g. both APSL and Liga1) would otherwise get one stats
                -- row per team; collapse to one row per player.
                ORDER BY pl.id
            )", {matchId, rosterTeamIdsArray});

            bool firstStat = true;
            for (const auto& row : statsRows) {
                if (!firstStat) statsJson << ",";
                firstStat = false;
                statsJson << "{";
                statsJson << "\"playerId\":" << row["player_id"].c_str() << ",";
                statsJson << "\"practicesAttended\":" << row["practices_attended"].c_str() << ",";
                statsJson << "\"practicesRecentTotal\":" << row["recent_total"].c_str() << ",";
                statsJson << "\"practicesProjected\":" << row["practices_projected"].c_str() << ",";
                statsJson << "\"practicesUpcomingTotal\":" << row["upcoming_total"].c_str() << ",";
                statsJson << "\"gameRsvp\":" << (row["game_rsvp"].is_null() ? "null" : "\"" + std::string(row["game_rsvp"].c_str()) + "\"") << ",";
                statsJson << "\"practices\":" << (row["practice_pills"].is_null() ? "[]" : row["practice_pills"].c_str());
                statsJson << "}";
            }
        }
        statsJson << "]";

        std::string query = R"(
            SELECT ml.player_id, ml.is_starter, ml.position_id,
                   ml.slot_number, ml.zone,
                   pe.first_name, pe.last_name,
                   pos.abbreviation as position
            FROM match_lineups ml
            JOIN players pl ON pl.id = ml.player_id
            JOIN persons pe ON pe.id = pl.person_id
            LEFT JOIN positions pos ON pos.id = ml.position_id
            WHERE ml.match_id = $1
            ORDER BY ml.is_starter DESC, ml.slot_number NULLS LAST, pe.last_name, pe.first_name
        )";
        
        pqxx::result result = db_->query(query, {matchId});
        
        // Also get metadata
        pqxx::result metaResult = db_->query(
            "SELECT formation_id, roster_size, notes FROM match_lineup_metadata WHERE match_id = $1",
            {matchId}
        );
        
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{\"matchId\":" << matchId << ",";
        json << "\"matchStartsAt\":" << (matchStartsAt.empty() ? "null" : "\"" + matchStartsAt + "\"") << ",";
        json << "\"teamId\":" << (teamIdForResponse.empty() ? "null" : teamIdForResponse) << ",";
        {
            // "{35,120}" -> "[35,120]" — rosterTeamIdsArray is a Postgres
            // array literal of plain ints, safe to reuse verbatim as JSON.
            std::string rosterTeamIdsJson = rosterTeamIdsArray;
            if (!rosterTeamIdsJson.empty()) {
                rosterTeamIdsJson.front() = '[';
                rosterTeamIdsJson.back()  = ']';
            } else {
                rosterTeamIdsJson = "[]";
            }
            json << "\"rosterTeamIds\":" << rosterTeamIdsJson << ",";
        }
        json << "\"isCoach\":" << (isCoach ? "true" : "false") << ",";
        json << "\"rosterStats\":" << statsJson.str() << ",";

        // Metadata
        if (!metaResult.empty()) {
            json << "\"formationId\":" << (metaResult[0]["formation_id"].is_null() ? "null" : metaResult[0]["formation_id"].c_str()) << ",";
            json << "\"rosterSize\":" << metaResult[0]["roster_size"].c_str() << ",";
            json << "\"notes\":" << (metaResult[0]["notes"].is_null() ? "null" : "\"" + escapeJson(metaResult[0]["notes"].c_str()) + "\"") << ",";
        } else {
            json << "\"formationId\":null,\"rosterSize\":20,\"notes\":null,";
        }
        
        json << "\"lineup\":[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"playerId\":" << row["player_id"].c_str() << ",";
            json << "\"isStarter\":" << (row["is_starter"].as<bool>() ? "true" : "false") << ",";
            json << "\"positionId\":" << (row["position_id"].is_null() ? "null" : row["position_id"].c_str()) << ",";
            json << "\"slotNumber\":" << (row["slot_number"].is_null() ? "null" : row["slot_number"].c_str()) << ",";
            json << "\"zone\":\"" << (row["zone"].is_null() ? "not_selected" : row["zone"].c_str()) << "\",";
            json << "\"position\":" << (row["position"].is_null() ? "null" : "\"" + std::string(row["position"].c_str()) + "\"") << ",";
            json << "\"firstName\":\"" << escapeJson(row["first_name"].c_str()) << "\",";
            json << "\"lastName\":\"" << escapeJson(row["last_name"].c_str()) << "\"";
            json << "}";
        }
        
        json << "]}}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting lineup: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, "Failed to get lineup"));
    }
}

// ============================================================================
// PUT /api/eligibility/lineup/:matchId
// Save match lineup with zones (starters with slot numbers, bench, not_selected)
// Body: { "starters": [{"playerId": 1, "slotNumber": 0}, ...], 
//         "bench": [{"playerId": 5}, ...],
//         "formationId": 1, "rosterSize": 20 }
// ============================================================================
Response EligibilityController::handleSaveMatchLineup(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/lineup/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }
    
    std::string userId = extractUserIdFromToken(request);
    if (userId.empty()) {
        return Response(HttpStatus::UNAUTHORIZED, createJsonResponse(false, "Authentication required"));
    }
    
    try {
        std::string body = request.getBody();

        // Get the team_id from the match
        pqxx::result matchResult = db_->query(
            "SELECT home_team_id, away_team_id FROM matches WHERE id = $1", {matchId}
        );
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        std::string teamId = matchResult[0]["home_team_id"].c_str();

        // Coach/admin authorization — this was previously unchecked (any
        // authenticated user, including a player, could overwrite any
        // match's lineup). Same admins-OR-coach-of-this-team EXISTS
        // pattern used for handleGetMatchLineup's isCoach flag above.
        {
            std::string homeTeamId = matchResult[0]["home_team_id"].is_null() ? "0" : matchResult[0]["home_team_id"].c_str();
            std::string awayTeamId = matchResult[0]["away_team_id"].is_null() ? "0" : matchResult[0]["away_team_id"].c_str();
            pqxx::result authRows = db_->query(
                "SELECT ("
                "  EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
                "          WHERE u.id = $1::int)"
                "  OR EXISTS (SELECT 1 FROM team_coaches tc "
                "             JOIN coaches co ON co.id = tc.coach_id "
                "             JOIN users u ON u.person_id = co.person_id "
                "             WHERE tc.team_id IN ($2::int, $3::int) AND tc.ended_at IS NULL "
                "             AND u.id = $1::int)"
                ") AS is_coach",
                {userId, homeTeamId, awayTeamId});
            bool isCoach = !authRows.empty() && authRows[0]["is_coach"].as<bool>();
            if (!isCoach) {
                return Response(HttpStatus::FORBIDDEN, createJsonResponse(false, "Not authorized to edit this match's lineup"));
            }
        }

        // Parse formation and roster size
        int formationId = parseJsonInt(body, "formationId", 0);
        int rosterSize = parseJsonInt(body, "rosterSize", 20);

        // Zone caps — starter (full XI) and bench mirror the frontend's
        // tap-to-assign guard so a direct API call can't exceed them either.
        // Alternate, and the separate starter/bench-eligible flag, are
        // unlimited.
        {
            auto countPlayerIds = [&](const std::string& key) -> int {
                size_t start = body.find("\"" + key + "\"");
                size_t arrStart = (start != std::string::npos) ? body.find("[", start) : std::string::npos;
                size_t arrEnd = (arrStart != std::string::npos) ? body.find("]", arrStart) : std::string::npos;
                if (start == std::string::npos || arrStart == std::string::npos || arrEnd == std::string::npos) return 0;
                std::string section = body.substr(arrStart, arrEnd - arrStart + 1);
                std::regex idPattern(R"("playerId"\s*:\s*(\d+))");
                return (int)std::distance(
                    std::sregex_iterator(section.begin(), section.end(), idPattern),
                    std::sregex_iterator());
            };
            int starterCount = countPlayerIds("starters");
            int benchCount = countPlayerIds("bench");
            if (starterCount > 11) {
                return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Starting XI cannot exceed 11 players"));
            }
            if (benchCount > 9) {
                return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Bench cannot exceed 9 players"));
            }
        }

        // Save metadata
        if (formationId > 0 || rosterSize > 0) {
            if (formationId > 0) {
                db_->query(R"(
                    INSERT INTO match_lineup_metadata (match_id, team_id, formation_id, roster_size, created_by_user_id, updated_at)
                    VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
                    ON CONFLICT (match_id, team_id) DO UPDATE SET
                        formation_id = EXCLUDED.formation_id,
                        roster_size = EXCLUDED.roster_size,
                        updated_at = CURRENT_TIMESTAMP
                )", {matchId, teamId, std::to_string(formationId), std::to_string(rosterSize), userId});
            } else {
                db_->query(R"(
                    INSERT INTO match_lineup_metadata (match_id, team_id, formation_id, roster_size, created_by_user_id, updated_at)
                    VALUES ($1, $2, NULL, $3, $4, CURRENT_TIMESTAMP)
                    ON CONFLICT (match_id, team_id) DO UPDATE SET
                        formation_id = NULL,
                        roster_size = EXCLUDED.roster_size,
                        updated_at = CURRENT_TIMESTAMP
                )", {matchId, teamId, std::to_string(rosterSize), userId});
            }
        }
        
        // Delete existing lineup for this match
        db_->query("DELETE FROM match_lineups WHERE match_id = $1", {matchId});
        
        int insertedCount = 0;
        
        // Parse starters: extract playerId, slotNumber, and positionId from
        // each object. positionId (2026-08-22) drives the Player Lineup
        // View's "1 is keeper, 2 is right back" Starting XI ordering — see
        // handleGetPositions and positions.sort_order.
        std::regex starterObjPattern(R"(\{[^}]*"playerId"\s*:\s*(\d+)[^}]*\})");
        std::regex slotPattern(R"("slotNumber"\s*:\s*(\d+))");
        std::regex positionPattern(R"("positionId"\s*:\s*(\d+))");

        size_t startersStart = body.find("\"starters\"");
        size_t startersArrayStart = (startersStart != std::string::npos) ? body.find("[", startersStart) : std::string::npos;
        size_t startersArrayEnd = (startersArrayStart != std::string::npos) ? body.find("]", startersArrayStart) : std::string::npos;

        if (startersStart != std::string::npos && startersArrayStart != std::string::npos) {
            std::string startersSection = body.substr(startersArrayStart, startersArrayEnd - startersArrayStart + 1);

            auto begin = std::sregex_iterator(startersSection.begin(), startersSection.end(), starterObjPattern);
            auto end = std::sregex_iterator();

            for (auto it = begin; it != end; ++it) {
                std::string objStr = (*it)[0].str();
                std::string playerId = (*it)[1].str();

                std::smatch slotMatch, posMatch;
                std::string slotStr = std::regex_search(objStr, slotMatch, slotPattern) ? slotMatch[1].str() : "";
                std::string posStr  = std::regex_search(objStr, posMatch, positionPattern) ? posMatch[1].str() : "";

                db_->query(
                    "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, slot_number, position_id, zone) "
                    "VALUES ($1, $2, $3, true, NULLIF($4,'')::int, NULLIF($5,'')::int, 'starter') "
                    "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = true, "
                    "slot_number = EXCLUDED.slot_number, position_id = EXCLUDED.position_id, zone = 'starter'",
                    {matchId, playerId, teamId, slotStr, posStr}
                );
                insertedCount++;
            }
        }
        
        // Parse bench array
        size_t benchStart = body.find("\"bench\"");
        size_t benchArrayStart = (benchStart != std::string::npos) ? body.find("[", benchStart) : std::string::npos;
        size_t benchArrayEnd = (benchArrayStart != std::string::npos) ? body.find("]", benchArrayStart) : std::string::npos;
        
        if (benchStart != std::string::npos && benchArrayStart != std::string::npos) {
            std::string benchSection = body.substr(benchArrayStart, benchArrayEnd - benchArrayStart + 1);

            // Object-scoped (not a bare playerId scan) so each bench
            // entry's own slotNumber — the bench order picker
            // (2026-08-22, owner directive) — is read from the right
            // object, not whichever slotNumber happens to appear first
            // in the array.
            std::regex benchObjPattern(R"(\{[^}]*"playerId"\s*:\s*(\d+)[^}]*\})");
            std::regex slotPattern(R"("slotNumber"\s*:\s*(\d+))");
            auto begin = std::sregex_iterator(benchSection.begin(), benchSection.end(), benchObjPattern);
            auto end = std::sregex_iterator();

            for (auto it = begin; it != end; ++it) {
                std::string objStr = (*it)[0].str();
                std::string playerId = (*it)[1].str();

                std::smatch slotMatch;
                std::string slotStr = std::regex_search(objStr, slotMatch, slotPattern) ? slotMatch[1].str() : "";

                db_->query(
                    "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, slot_number, zone) "
                    "VALUES ($1, $2, $3, false, NULLIF($4,'')::int, 'bench') "
                    "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = false, "
                    "slot_number = EXCLUDED.slot_number, zone = 'bench'",
                    {matchId, playerId, teamId, slotStr}
                );
                insertedCount++;
            }
        }
        
        // Parse alternates array
        size_t altStart = body.find("\"alternates\"");
        size_t altArrayStart = (altStart != std::string::npos) ? body.find("[", altStart) : std::string::npos;
        size_t altArrayEnd = (altArrayStart != std::string::npos) ? body.find("]", altArrayStart) : std::string::npos;
        
        if (altStart != std::string::npos && altArrayStart != std::string::npos) {
            std::string altSection = body.substr(altArrayStart, altArrayEnd - altArrayStart + 1);
            
            std::regex altPlayerIdPattern(R"("playerId"\s*:\s*(\d+))");
            auto begin = std::sregex_iterator(altSection.begin(), altSection.end(), altPlayerIdPattern);
            auto end = std::sregex_iterator();
            
            for (auto it = begin; it != end; ++it) {
                std::string playerId = (*it)[1].str();
                
                db_->query(
                    "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, zone) "
                    "VALUES ($1, $2, $3, false, 'alternate') "
                    "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = false, zone = 'alternate'",
                    {matchId, playerId, teamId}
                );
                insertedCount++;
            }
        }
        
        std::string responseData = "{\"count\":" + std::to_string(insertedCount) + "}";
        return Response(HttpStatus::OK, createJsonResponse(true, "Lineup saved", responseData));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error saving lineup: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, "Failed to save lineup"));
    }
}

// ============================================================================
// GET /api/eligibility/positions
// Reference list for the Starting XI position picker (2026-08-22).
// ============================================================================
// ============================================================================
// Event squads — pickup sides and practice groups
// ============================================================================
//
// A "squad" here is just a colour a player is wearing for one event
// (owner, 2026-08-28: "they are just pickup teams like blue, green etc").
// Practice groups are the same thing under another name and share the
// column, so this pair of handlers serves both kinds.
//
// Storage is match_lineups.squad_color on a row keyed by fh_event_id
// (migration 316). match_id stays NULL for these — a pickup or practice
// has no matches row, which is the whole reason the migration existed.
//
// Deliberately not folded into handleGet/SaveMatchLineup: that path
// carries the Starting XI machinery (positions, zones, bench order, 11/9
// caps) and none of it means anything for a kickabout.

// Teams whose rosters make up the pool for this event, as a Postgres
// array literal. Same fh_event_teams source the match lineup uses, minus
// the matches hop it has to take first.
static std::string eventRosterTeamIds(Database* db, const std::string& fhEventId) {
    pqxx::result rows = db->query(
        "SELECT array_agg(DISTINCT team_id) AS team_ids "
        "FROM fh_event_teams WHERE fh_event_id = $1",
        {fhEventId});
    if (!rows.empty() && !rows[0]["team_ids"].is_null()) return rows[0]["team_ids"].c_str();
    return "{}";
}

// Admin, or a coach of any team this event is tagged to. Mirrors the
// match lineup's authorization, scoped to fh_event_teams rather than the
// match's home/away pair.
static bool isEventCoach(Database* db, const std::string& userId, const std::string& fhEventId) {
    if (userId.empty()) return false;
    pqxx::result rows = db->query(
        "SELECT ("
        "  EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id WHERE u.id = $1::int)"
        "  OR EXISTS (SELECT 1 FROM team_coaches tc "
        "             JOIN coaches co ON co.id = tc.coach_id "
        "             JOIN users u ON u.person_id = co.person_id "
        "             JOIN fh_event_teams fet ON fet.team_id = tc.team_id "
        "             WHERE fet.fh_event_id = $2::bigint AND tc.ended_at IS NULL "
        "             AND u.id = $1::int)"
        ") AS is_coach",
        {userId, fhEventId});
    return !rows.empty() && rows[0]["is_coach"].as<bool>();
}

Response EligibilityController::handleGetEventSquads(const Request& request) {
    std::string fhEventId = extractIdFromPath(request.getPath(), "/api/eligibility/event-squads/(\\d+)");
    if (fhEventId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Event ID is required"));
    }

    try {
        pqxx::result evRow = db_->query("SELECT kind FROM fh_events WHERE id = $1", {fhEventId});
        if (evRow.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Event not found"));
        }
        std::string kind = evRow[0]["kind"].c_str();

        // Readable by any player (no 401 on a missing token) — same as the
        // match lineup, so a player can see which side they are on. The
        // flag only drives whether the UI offers edit controls.
        std::string userId = extractUserIdFromToken(request);
        bool isCoach = isEventCoach(db_, userId, fhEventId);

        std::string rosterTeamIds = eventRosterTeamIds(db_, fhEventId);

        // The pool is every player on the tagged teams, LEFT JOINed to
        // whatever side they have been given for this event. A player with
        // no row yet is simply unassigned.
        // Same team_persons -> persons -> players chain the match lineup's
        // roster pool uses. DISTINCT ON collapses a player rostered on
        // more than one of the event's teams (e.g. both APSL and Liga1)
        // to a single row, exactly as that query's ORDER BY pl.id does.
        pqxx::result rows = db_->query(
            "SELECT DISTINCT ON (pl.id) "
            "       pl.id AS player_id, "
            "       pe.first_name, pe.last_name, "
            "       tp.team_id, tp.jersey_number, "
            "       ml.squad_color "
            "FROM team_persons tp "
            "JOIN persons pe ON pe.id = tp.person_id "
            "JOIN players pl ON pl.person_id = pe.id "
            "LEFT JOIN match_lineups ml "
            "       ON ml.player_id = pl.id AND ml.fh_event_id = $1::bigint "
            "WHERE tp.team_id = ANY($2::int[]) AND tp.removed_at IS NULL "
            "ORDER BY pl.id, tp.team_id",
            {fhEventId, rosterTeamIds});

        std::ostringstream json;
        json << "{\"fhEventId\":" << fhEventId
             << ",\"kind\":\"" << escapeJson(kind) << "\""
             << ",\"isCoach\":" << (isCoach ? "true" : "false")
             << ",\"rosterTeamIds\":" << (rosterTeamIds == "{}" ? "[]" :
                    ("[" + rosterTeamIds.substr(1, rosterTeamIds.size() - 2) + "]"))
             << ",\"colors\":[\"white\",\"blue\",\"green\",\"orange\",\"red\",\"black\",\"yellow\",\"pink\"]"
             << ",\"players\":[";
        bool first = true;
        for (const auto& row : rows) {
            if (!first) json << ",";
            first = false;
            json << "{\"playerId\":" << row["player_id"].c_str()
                 << ",\"firstName\":\"" << escapeJson(row["first_name"].is_null() ? "" : row["first_name"].c_str()) << "\""
                 << ",\"lastName\":\"" << escapeJson(row["last_name"].is_null() ? "" : row["last_name"].c_str()) << "\""
                 << ",\"teamId\":" << (row["team_id"].is_null() ? "null" : row["team_id"].c_str())
                 << ",\"jerseyNumber\":\"" << escapeJson(row["jersey_number"].is_null() ? "" : row["jersey_number"].c_str()) << "\""
                 << ",\"squadColor\":" << (row["squad_color"].is_null() ? "null"
                        : ("\"" + escapeJson(row["squad_color"].c_str()) + "\""))
                 << "}";
        }
        json << "]}";

        return Response(HttpStatus::OK, createJsonResponse(true, "Event squads", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Error: ") + e.what()));
    }
}

Response EligibilityController::handleSaveEventSquads(const Request& request) {
    std::string fhEventId = extractIdFromPath(request.getPath(), "/api/eligibility/event-squads/(\\d+)");
    if (fhEventId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Event ID is required"));
    }
    std::string userId = extractUserIdFromToken(request);
    if (userId.empty()) {
        return Response(HttpStatus::UNAUTHORIZED, createJsonResponse(false, "Authentication required"));
    }
    if (!isEventCoach(db_, userId, fhEventId)) {
        return Response(HttpStatus::FORBIDDEN, createJsonResponse(false, "Not authorized to edit this event's squads"));
    }

    try {
        pqxx::result evRow = db_->query("SELECT id FROM fh_events WHERE id = $1", {fhEventId});
        if (evRow.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Event not found"));
        }

        // Body: {"assignments":[{"playerId":1,"squadColor":"green"},
        //                       {"playerId":2,"squadColor":null}, ...]}
        // A null colour means "take them off a side", which deletes the
        // row rather than storing a null — an unassigned player and a
        // player with no row are the same state, and keeping only one
        // representation means the GET above never has to distinguish.
        const std::string body = request.getBody();
        // Custom RX delimiters, not the bare R"(...)": the colour pattern
        // contains ([a-z]+)" and a bare raw string would end at that )"
        // sequence, silently truncating the regex mid-expression.
        std::regex entry(R"RX(\{[^{}]*?"playerId"\s*:\s*(\d+)[^{}]*?\})RX");
        std::regex colorPat(R"RX("squadColor"\s*:\s*(?:"([a-z]+)"|null))RX");

        // Colours are re-checked here, not just by the CHECK constraint, so
        // a bad value is a 400 naming the colour instead of a 500 from a
        // constraint violation halfway through a batch.
        static const std::vector<std::string> kColors =
            {"white","blue","green","orange","red","black","yellow","pink"};

        int applied = 0, cleared = 0;
        for (std::sregex_iterator it(body.begin(), body.end(), entry), end; it != end; ++it) {
            const std::string chunk = (*it)[0].str();
            const std::string playerId = (*it)[1].str();

            std::smatch cm;
            std::string color;
            if (std::regex_search(chunk, cm, colorPat)) color = cm[1].matched ? cm[1].str() : "";

            if (color.empty()) {
                db_->query("DELETE FROM match_lineups WHERE fh_event_id = $1::bigint AND player_id = $2::int",
                           {fhEventId, playerId});
                cleared++;
                continue;
            }
            if (std::find(kColors.begin(), kColors.end(), color) == kColors.end()) {
                return Response(HttpStatus::BAD_REQUEST,
                    createJsonResponse(false, "Unknown squad colour: " + color));
            }

            // team_id is NOT NULL on match_lineups, so carry the player's
            // own roster team for this event rather than inventing one.
            db_->query(
                "INSERT INTO match_lineups (fh_event_id, player_id, team_id, is_starter, zone, squad_color) "
                "SELECT $1::bigint, pl.id, tp.team_id, false, 'not_selected', $3 "
                "  FROM players pl "
                "  JOIN team_persons tp ON tp.person_id = pl.person_id AND tp.removed_at IS NULL "
                "  JOIN fh_event_teams fet ON fet.team_id = tp.team_id AND fet.fh_event_id = $1::bigint "
                " WHERE pl.id = $2::int "
                " LIMIT 1 "
                "ON CONFLICT (fh_event_id, player_id) WHERE fh_event_id IS NOT NULL "
                "DO UPDATE SET squad_color = EXCLUDED.squad_color",
                {fhEventId, playerId, color});
            applied++;
        }

        std::ostringstream out;
        out << "{\"assigned\":" << applied << ",\"cleared\":" << cleared << "}";
        return Response(HttpStatus::OK, createJsonResponse(true, "Squads saved", out.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Error: ") + e.what()));
    }
}

Response EligibilityController::handleGetPositions(const Request& request) {
    try {
        pqxx::result result = db_->query(
            "SELECT id, name, abbreviation, sort_order FROM positions ORDER BY sort_order", {});

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].c_str() << ",";
            json << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
            json << "\"abbreviation\":\"" << escapeJson(row["abbreviation"].c_str()) << "\",";
            json << "\"sortOrder\":" << row["sort_order"].c_str();
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJsonResponse(true, "Positions retrieved", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting positions: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJsonResponse(false, "Failed to get positions"));
    }
}

// ============================================================================
// GET /api/eligibility/lineup-meta/:matchId
// Get lineup metadata (formation, roster size) for a match
// ============================================================================
Response EligibilityController::handleGetLineupMetadata(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/lineup-meta/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }
    
    try {
        pqxx::result result = db_->query(R"(
            SELECT mlm.formation_id, mlm.roster_size, mlm.notes, mlm.custom_positions, mlm.formation_locked,
                   f.code as formation_code, f.name as formation_name,
                   f.positions_json as formation_positions
            FROM match_lineup_metadata mlm
            LEFT JOIN formations f ON f.id = mlm.formation_id
            WHERE mlm.match_id = $1
        )", {matchId});
        
        if (result.empty()) {
            return Response(HttpStatus::OK, 
                createJsonResponse(true, "No metadata", "{\"formationId\":null,\"rosterSize\":20,\"notes\":null,\"customPositions\":null}"));
        }
        
        const auto& row = result[0];
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{";
        json << "\"formationId\":" << (row["formation_id"].is_null() ? "null" : row["formation_id"].c_str()) << ",";
        json << "\"rosterSize\":" << row["roster_size"].c_str() << ",";
        json << "\"notes\":" << (row["notes"].is_null() ? "null" : "\"" + escapeJson(row["notes"].c_str()) + "\"") << ",";
        json << "\"customPositions\":" << (row["custom_positions"].is_null() ? "null" : row["custom_positions"].c_str()) << ",";
        json << "\"formationLocked\":" << (row["formation_locked"].as<bool>(true) ? "true" : "false") << ",";
        if (!row["formation_code"].is_null()) {
            json << "\"formationCode\":\"" << escapeJson(row["formation_code"].c_str()) << "\",";
            json << "\"formationName\":\"" << escapeJson(row["formation_name"].c_str()) << "\",";
            json << "\"formationPositions\":" << row["formation_positions"].c_str();
        } else {
            json << "\"formationCode\":null,\"formationName\":null,\"formationPositions\":null";
        }
        json << "}}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting lineup metadata: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, "Failed to get lineup metadata"));
    }
}

// ============================================================================
// PUT /api/eligibility/lineup-meta/:matchId
// Save lineup metadata
// Body: { "formationId": 1, "rosterSize": 20, "notes": "..." }
// ============================================================================
Response EligibilityController::handleSaveLineupMetadata(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/lineup-meta/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }
    
    std::string userId = extractUserIdFromToken(request);
    if (userId.empty()) {
        return Response(HttpStatus::UNAUTHORIZED, createJsonResponse(false, "Authentication required"));
    }
    
    try {
        std::string body = request.getBody();
        int formationId = parseJsonInt(body, "formationId", 0);
        int rosterSize = parseJsonInt(body, "rosterSize", 20);
        std::string notes = parseJsonString(body, "notes");
        bool formationLocked = parseJsonBool(body, "formationLocked", true);
        std::string customPositions = parseJsonString(body, "__customPositionsRaw__"); // unused — read raw below

        // Extract raw customPositions JSON value (may be array or null)
        std::string customPosRaw = "NULL";
        {
            auto pos = body.find("\"customPositions\"");
            if (pos != std::string::npos) {
                pos = body.find(':', pos) + 1;
                // skip whitespace
                while (pos < body.size() && (body[pos] == ' ' || body[pos] == '\t')) pos++;
                if (pos < body.size()) {
                    if (body[pos] == '[' || body[pos] == '{') {
                        // find matching bracket
                        char open = body[pos], close = (open == '[') ? ']' : '}';
                        int depth = 0; size_t end = pos;
                        for (; end < body.size(); end++) {
                            if (body[end] == open) depth++;
                            else if (body[end] == close) { depth--; if (depth == 0) { end++; break; } }
                        }
                        customPosRaw = body.substr(pos, end - pos);
                    } else if (body.substr(pos, 4) == "null") {
                        customPosRaw = "NULL";
                    }
                }
            }
        }
        
        // Get team_id from match
        pqxx::result matchResult = db_->query(
            "SELECT home_team_id FROM matches WHERE id = $1", {matchId}
        );
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        std::string teamId = matchResult[0]["home_team_id"].c_str();

        std::string formIdStr = formationId > 0 ? std::to_string(formationId) : "";
        std::string customPosParam = (customPosRaw == "NULL") ? "" : customPosRaw;

        db_->query(R"(
            INSERT INTO match_lineup_metadata
                (match_id, team_id, formation_id, roster_size, notes, custom_positions, formation_locked, created_by_user_id, updated_at)
            VALUES (
                $1, $2,
                NULLIF($3, '')::int,
                $4,
                NULLIF($5, ''),
                NULLIF($6, '')::jsonb,
                $7::bool,
                $8,
                CURRENT_TIMESTAMP
            )
            ON CONFLICT (match_id, team_id) DO UPDATE SET
                formation_id      = NULLIF($3, '')::int,
                roster_size       = EXCLUDED.roster_size,
                notes             = EXCLUDED.notes,
                custom_positions  = NULLIF($6, '')::jsonb,
                formation_locked  = EXCLUDED.formation_locked,
                updated_at        = CURRENT_TIMESTAMP
        )", {matchId, teamId, formIdStr, std::to_string(rosterSize), notes, customPosParam, formationLocked ? "true" : "false", userId});

        return Response(HttpStatus::OK, createJsonResponse(true, "Metadata saved"));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error saving lineup metadata: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, "Failed to save lineup metadata"));
    }
}

// ============================================================================
// Path/JSON Helpers
// ============================================================================
std::string EligibilityController::extractIdFromPath(const std::string& path, const std::string& pattern) {
    std::regex id_regex(pattern);
    std::smatch match;
    if (std::regex_search(path, match, id_regex)) {
        return match[1].str();
    }
    return "";
}

std::string EligibilityController::extractUserIdFromToken(const Request& request) {
    std::string auth_header = request.getHeader("Authorization");
    if (auth_header.empty() || auth_header.substr(0, 7) != "Bearer ") return "";
    
    std::string token = auth_header.substr(7);
    
    // JWT format: header.payload.signature
    if (token.find('.') != std::string::npos) {
        size_t first_dot = token.find('.');
        size_t second_dot = token.find('.', first_dot + 1);
        if (first_dot != std::string::npos && second_dot != std::string::npos) {
            std::string payload = fh::crypto::base64UrlDecode(token.substr(first_dot + 1, second_dot - first_dot - 1));
            std::regex user_id_regex(R"re("userId"\s*:\s*"([^"]+)")re");            std::smatch match;
            if (std::regex_search(payload, match, user_id_regex)) {
                return match[1].str();
            }
        }
    }
    
    // Fallback: jwt_{user_id}_{hash} format
    if (token.length() > 4 && token.substr(0, 4) == "jwt_") {
        size_t last_underscore = token.rfind('_');
        if (last_underscore != std::string::npos && last_underscore > 4) {
            return token.substr(4, last_underscore - 4);
        }
    }
    
    return "";
}

std::string EligibilityController::parseJsonString(const std::string& body, const std::string& key) {
    std::string search = "\"" + key + "\"";
    size_t pos = body.find(search);
    if (pos == std::string::npos) return "";
    
    pos = body.find(":", pos);
    if (pos == std::string::npos) return "";
    pos++;
    while (pos < body.length() && (body[pos] == ' ' || body[pos] == '\t')) pos++;
    if (pos >= body.length()) return "";
    if (body.substr(pos, 4) == "null") return "";
    
    bool quoted = (body[pos] == '"');
    if (quoted) pos++;
    size_t end_pos = quoted ? body.find("\"", pos) : body.find_first_of(",}", pos);
    if (end_pos == std::string::npos) return "";
    return body.substr(pos, end_pos - pos);
}

int EligibilityController::parseJsonInt(const std::string& body, const std::string& key, int defaultValue) {
    std::string val = parseJsonString(body, key);
    if (val.empty()) return defaultValue;
    try { return std::stoi(val); } catch (...) { return defaultValue; }
}

bool EligibilityController::parseJsonBool(const std::string& body, const std::string& key, bool defaultValue) {
    std::string val = parseJsonString(body, key);
    if (val.empty()) return defaultValue;
    return val == "true" || val == "1";
}

std::string EligibilityController::createJsonResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{\"success\":" << (success ? "true" : "false") 
         << ",\"message\":\"" << escapeJson(message) << "\"";
    if (!data.empty()) json << ",\"data\":" << data;
    json << "}";
    return json.str();
}
