#include "EligibilityController.h"
#include <sstream>
#include <regex>
#include <iomanip>
#include <iostream>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

// ============================================================================
// Helper: base64url decode (for JWT token parsing)
// ============================================================================
static std::string base64UrlDecode(const std::string& input) {
    std::string base64 = input;
    for (size_t i = 0; i < base64.length(); ++i) {
        if (base64[i] == '-') base64[i] = '+';
        else if (base64[i] == '_') base64[i] = '/';
    }
    while (base64.length() % 4 != 0) base64 += '=';
    
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
    // GET /api/eligibility/match/:matchId - Compute eligibility for all roster players
    router.get(prefix + "/match/:matchId", [this](const Request& request) {
        return this->handleGetMatchEligibility(request);
    });
    
    // GET /api/eligibility/policy/:teamId - Get effective policy for a team
    router.get(prefix + "/policy/:teamId", [this](const Request& request) {
        return this->handleGetTeamPolicy(request);
    });
    
    // PUT /api/eligibility/policy/:teamId - Create/update team-level policy
    router.put(prefix + "/policy/:teamId", [this](const Request& request) {
        return this->handleUpdateTeamPolicy(request);
    });
    
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
    
    // GET /api/eligibility/player/:playerId/attendance - Get player attendance for sessions
    router.get(prefix + "/player/:playerId/attendance", [this](const Request& request) {
        return this->handleGetPlayerAttendance(request);
    });
    
    // PUT /api/eligibility/player/:playerId/attendance - Toggle attendance for a session
    router.put(prefix + "/player/:playerId/attendance", [this](const Request& request) {
        return this->handleUpdatePlayerAttendance(request);
    });
}

// ============================================================================
// GET /api/eligibility/match/:matchId
// Compute training eligibility for all roster players for a given match
// ============================================================================
Response EligibilityController::handleGetMatchEligibility(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/match/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }

    // Optional query param: ?teamId=186 to specify which team's roster to use
    std::string requestedTeamId = request.getQueryParam("teamId");

    std::cout << "📊 Computing eligibility for match: " << matchId;
    if (!requestedTeamId.empty()) std::cout << " (team: " << requestedTeamId << ")";
    std::cout << std::endl;

    try {
        // Step 1: Get match info (teams, club, date)
        std::string matchQuery = R"(
            SELECT m.id, m.home_team_id, m.away_team_id,
                   m.match_date::date as match_date,
                   COALESCE(ht.name, '') as home_team_name,
                   COALESCE(at.name, '') as away_team_name
            FROM matches m
            LEFT JOIN teams ht ON ht.id = m.home_team_id
            LEFT JOIN teams at ON at.id = m.away_team_id
            WHERE m.id = $1
        )";
        
        pqxx::result matchResult = db_->query(matchQuery, {matchId});
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        
        std::string homeTeamId = matchResult[0]["home_team_id"].c_str();
        std::string awayTeamId = matchResult[0]["away_team_id"].is_null() ? "" : matchResult[0]["away_team_id"].c_str();
        std::string matchDate = matchResult[0]["match_date"].c_str();
        std::string homeTeamName = matchResult[0]["home_team_name"].c_str();
        std::string awayTeamName = matchResult[0]["away_team_name"].c_str();
        
        // Determine which team to show roster for:
        // If teamId query param provided and matches home or away, use it.
        // Otherwise default to home_team_id.
        std::string teamId = homeTeamId;
        if (!requestedTeamId.empty()) {
            if (requestedTeamId == homeTeamId || requestedTeamId == awayTeamId) {
                teamId = requestedTeamId;
            } else {
                std::cout << "⚠️ Requested teamId " << requestedTeamId 
                          << " not in match, defaulting to home team" << std::endl;
            }
        }
        
        // Get club_id for the selected team
        pqxx::result teamResult = db_->query("SELECT club_id, name FROM teams WHERE id = $1", {teamId});
        std::string clubId = (!teamResult.empty() && !teamResult[0]["club_id"].is_null()) 
                             ? std::string(teamResult[0]["club_id"].c_str()) : "";
        std::string teamName = !teamResult.empty() ? std::string(teamResult[0]["name"].c_str()) : "";
        
        // Step 2: Resolve effective policy
        EligibilityPolicy policy = resolvePolicy(matchId, teamId, clubId);
        
        // Step 3: Get the lookback window — the N sessions before the match date.
        // This single window is the source of truth for eligibility.
        // Sessions in the window that are in the past count via attendance/RSVP.
        // Sessions in the window that are in the future count via RSVP projection.
        std::vector<int> sessionIds = getRecentSessionIds(
            teamId, clubId, matchDate, policy.lookback_count,
            policy.game_counts_as_session, policy.pickup_counts_as_session
        );
        
        // Step 4: Get all roster players with attendance and RSVP data
        // All sessions go in one array — the SQL query handles
        // past vs future split using CURRENT_TIMESTAMP
        std::string sessionArray = "{";
        for (size_t i = 0; i < sessionIds.size(); i++) {
            if (i > 0) sessionArray += ",";
            sessionArray += std::to_string(sessionIds[i]);
        }
        sessionArray += "}";
        
        std::string playerQuery = R"(
            WITH has_chat AS (
                -- Check if this team has any GroupMe chat member data
                SELECT EXISTS(
                    SELECT 1 FROM chats c
                    JOIN chat_external_members cem ON cem.chat_id = c.id
                    WHERE c.team_id = $1::int AND cem.person_id IS NOT NULL
                ) as has_data
            ),
            chat_pool AS (
                -- Player pool from GroupMe chat members (when chat data exists)
                SELECT DISTINCT cem.person_id
                FROM chat_external_members cem
                JOIN chats c ON c.id = cem.chat_id
                LEFT JOIN chat_non_players cnp
                    ON cnp.person_id = cem.person_id
                    OR cnp.external_username = cem.external_username
                WHERE c.team_id = $1::int
                  AND cem.person_id IS NOT NULL
                  AND cnp.id IS NULL
                  AND (SELECT has_data FROM has_chat)
            ),
            roster_pool AS (
                -- Fallback: player pool from team roster (when no chat data)
                SELECT DISTINCT p.person_id
                FROM rosters r
                JOIN players p ON p.id = r.player_id
                WHERE r.team_id = $1::int
                  AND r.left_at IS NULL
                  AND NOT (SELECT has_data FROM has_chat)
            ),
            combined_pool AS (
                SELECT person_id FROM chat_pool
                UNION
                SELECT person_id FROM roster_pool
            ),
            roster_players AS (
                -- Resolve each person to their player record
                SELECT DISTINCT ON (cp.person_id)
                       p.id as player_id, r.jersey_number,
                       p.has_family_discount, p.is_keeper, p.photo_url,
                       pe.id as person_id, pe.first_name, pe.last_name,
                       -- On official roster = any sibling team in same league
                       EXISTS(
                           SELECT 1 FROM rosters r2
                           JOIN teams t2 ON t2.id = r2.team_id
                           JOIN teams req ON req.id = $1::int
                           WHERE r2.player_id = p.id
                             AND t2.club_id = req.club_id
                             AND t2.source_system_id = req.source_system_id
                             AND r2.left_at IS NULL
                       ) as on_official_roster
                FROM combined_pool cp
                JOIN persons pe ON pe.id = cp.person_id
                JOIN players p ON p.person_id = pe.id
                LEFT JOIN rosters r ON r.player_id = p.id
                    AND r.team_id = $1 AND r.left_at IS NULL
                ORDER BY cp.person_id,
                         CASE WHEN r.player_id IS NOT NULL THEN 0 ELSE 1 END,
                         p.id DESC
            ),
            -- Classify each session in the window as past or future
            window_sessions AS (
                SELECT ce.id as session_id,
                       COALESCE(ce.start_at, ce.event_date::timestamptz) < CURRENT_TIMESTAMP as is_past
                FROM chat_events ce
                WHERE ce.id = ANY($2::int[])
            ),
            -- Map external GroupMe user IDs to person IDs (for training/pickup
            -- RSVPs that have NULL person_id but valid external_user_id)
            user_person_map AS (
                SELECT DISTINCT ON (cem.external_user_id)
                       cem.external_user_id, cem.person_id
                FROM chat_external_members cem
                WHERE cem.person_id IS NOT NULL
                ORDER BY cem.external_user_id, cem.synced_at DESC NULLS LAST
            ),
            -- Resolve person_id for all RSVPs in the session window
            resolved_rsvps AS (
                SELECT cer.chat_event_id,
                       COALESCE(cer.person_id, upm.person_id) as person_id,
                       COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) as eff_rsvp_status_id
                FROM chat_event_rsvps cer
                LEFT JOIN user_person_map upm ON upm.external_user_id = cer.external_user_id
                                              AND cer.person_id IS NULL
                WHERE cer.chat_event_id = ANY($2::int[])
                  AND COALESCE(cer.person_id, upm.person_id) IS NOT NULL
            ),
            -- Unified attendance: per-session, manual overrides RSVP
            -- For each (player, session): use training_attendance if it exists,
            -- otherwise fall back to RSVP yes = attended
            unified_attendance AS (
                SELECT rp.player_id, ws.session_id,
                       CASE
                           WHEN ta.player_id IS NOT NULL THEN ta.attended
                           WHEN rr.eff_rsvp_status_id = 1 THEN true
                           ELSE false
                       END as attended
                FROM roster_players rp
                CROSS JOIN window_sessions ws
                LEFT JOIN training_attendance ta
                    ON ta.player_id = rp.player_id AND ta.chat_event_id = ws.session_id
                LEFT JOIN resolved_rsvps rr
                    ON rr.person_id = rp.person_id AND rr.chat_event_id = ws.session_id
                WHERE ws.is_past
            ),
            -- Count attended sessions per player
            actual_attendance AS (
                SELECT player_id,
                       COUNT(*) FILTER (WHERE attended) as sessions_attended
                FROM unified_attendance
                GROUP BY player_id
            ),
            -- Count RSVP 'yes' for FUTURE sessions in the same window (projection)
            future_rsvp AS (
                SELECT rp.player_id,
                       COUNT(*) FILTER (WHERE rr.eff_rsvp_status_id = 1) as future_yes_count
                FROM roster_players rp
                JOIN resolved_rsvps rr ON rr.person_id = rp.person_id
                JOIN window_sessions ws ON ws.session_id = rr.chat_event_id AND NOT ws.is_past
                GROUP BY rp.player_id
            ),
            -- Get RSVP for the match itself (via chat_events linked to matches)
            match_rsvps AS (
                SELECT rp.player_id,
                       rs.name as rsvp_status
                FROM roster_players rp
                JOIN chat_event_rsvps cer ON (
                    cer.person_id = rp.person_id
                    OR (cer.person_id IS NULL AND EXISTS(
                        SELECT 1 FROM user_person_map upm
                        WHERE upm.external_user_id = cer.external_user_id
                          AND upm.person_id = rp.person_id
                    ))
                )
                JOIN chat_events ce ON ce.id = cer.chat_event_id
                JOIN rsvp_statuses rs ON rs.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id)
                WHERE ce.match_id = $3::int
            ),
            -- Get existing lineup
            lineup AS (
                SELECT ml.player_id, ml.is_starter
                FROM match_lineups ml
                WHERE ml.match_id = $3::int
            ),
            -- Get primary position
            player_pos AS (
                SELECT pp.player_id, pos.abbreviation as position, pos.name as position_name
                FROM player_positions pp
                JOIN positions pos ON pos.id = pp.position_id
                WHERE pp.is_primary = true
            )
            SELECT rp.player_id, rp.first_name, rp.last_name, rp.jersey_number,
                   rp.has_family_discount, rp.is_keeper, rp.photo_url, rp.person_id,
                   rp.on_official_roster,
                   COALESCE(aa.sessions_attended, 0) as sessions_attended,
                   COALESCE(fr.future_yes_count, 0) as future_rsvp_yes,
                   (SELECT COUNT(*) FROM window_sessions WHERE NOT is_past) as future_session_count,
                   pp.position, pp.position_name,
                   mr.rsvp_status as match_rsvp_status,
                   lu.is_starter as lineup_is_starter,
                   lu.player_id IS NOT NULL as on_lineup
            FROM roster_players rp
            LEFT JOIN actual_attendance aa ON aa.player_id = rp.player_id
            LEFT JOIN match_rsvps mr ON mr.player_id = rp.player_id
            LEFT JOIN lineup lu ON lu.player_id = rp.player_id
            LEFT JOIN player_pos pp ON pp.player_id = rp.player_id
            LEFT JOIN future_rsvp fr ON fr.player_id = rp.player_id
            ORDER BY COALESCE(aa.sessions_attended, 0) + COALESCE(fr.future_yes_count, 0) DESC,
                     rp.last_name, rp.first_name
        )";
        
        pqxx::result playerResult = db_->query(playerQuery, {teamId, sessionArray, matchId});
        
        // Step 5: Check GroupMe sync freshness
        std::string groupmeStatus = "no_data";
        std::string groupmeLastSync = "";
        int groupmeMinutesAgo = -1;
        
        try {
            pqxx::result syncResult = db_->query(
                "SELECT MAX(cer.responded_at) as last_sync "
                "FROM chat_event_rsvps cer "
                "JOIN chat_events ce ON ce.id = cer.chat_event_id "
                "JOIN chats c ON c.id = ce.chat_id "
                "WHERE c.team_id = $1::int",
                {teamId}
            );
            if (!syncResult.empty() && !syncResult[0]["last_sync"].is_null()) {
                groupmeLastSync = syncResult[0]["last_sync"].c_str();
                // Calculate minutes ago
                pqxx::result ageResult = db_->query(
                    "SELECT EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - $1::timestamp)) / 60 as minutes_ago",
                    {groupmeLastSync}
                );
                if (!ageResult.empty()) {
                    groupmeMinutesAgo = static_cast<int>(ageResult[0]["minutes_ago"].as<double>());
                    if (groupmeMinutesAgo <= 60) {
                        groupmeStatus = "fresh";
                    } else if (groupmeMinutesAgo <= 1440) {
                        groupmeStatus = "stale";
                    } else {
                        groupmeStatus = "very_stale";
                    }
                }
            }
        } catch (const std::exception& e) {
            std::cerr << "⚠️ GroupMe freshness check failed: " << e.what() << std::endl;
        }
        
        // Step 6: Build response JSON
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{";
        
        // Match info
        json << "\"match\":{";
        json << "\"id\":" << matchId << ",";
        json << "\"date\":\"" << matchDate << "\",";
        json << "\"homeTeam\":\"" << escapeJson(homeTeamName) << "\",";
        json << "\"awayTeam\":\"" << escapeJson(awayTeamName) << "\"";
        json << "},";
        
        // GroupMe sync status
        json << "\"groupmeSync\":{";
        json << "\"status\":\"" << groupmeStatus << "\"";
        if (!groupmeLastSync.empty()) {
            json << ",\"lastSync\":\"" << groupmeLastSync << "\"";
            json << ",\"minutesAgo\":" << groupmeMinutesAgo;
        }
        json << "},";
        
        // Policy info
        json << "\"policy\":{";
        json << "\"lookbackCount\":" << policy.lookback_count << ",";
        json << "\"minSessionsToStart\":" << policy.min_sessions_to_start << ",";
        json << "\"priorityStarterSessions\":" << policy.priority_starter_sessions << ",";
        json << "\"priorityStarterSlots\":" << policy.priority_starter_slots << ",";
        json << "\"gameCountsAsSession\":" << (policy.game_counts_as_session ? "true" : "false") << ",";
        json << "\"pickupCountsAsSession\":" << (policy.pickup_counts_as_session ? "true" : "false") << ",";
        json << "\"familyDiscount\":" << policy.family_discount << ",";
        json << "\"keeperDiscount\":" << policy.keeper_discount;
        json << "},";
        
        // Sessions info
        int futureSessionCount = 0;
        if (!playerResult.empty()) {
            futureSessionCount = playerResult[0]["future_session_count"].as<int>();
        }
        json << "\"sessionsInWindow\":" << sessionIds.size() << ",";
        json << "\"futureSessionCount\":" << futureSessionCount << ",";
        
        // Players
        json << "\"players\":[";
        bool first = true;
        int priorityStarterCount = 0;
        
        // First pass: count priority starters for slot tracking
        std::vector<PlayerEligibility> players;
        for (const auto& row : playerResult) {
            PlayerEligibility pe;
            pe.player_id = row["player_id"].as<int>();
            pe.first_name = row["first_name"].c_str();
            pe.last_name = row["last_name"].c_str();
            pe.jersey_number = row["jersey_number"].is_null() ? "" : row["jersey_number"].c_str();
            pe.position = row["position"].is_null() ? "" : row["position"].c_str();
            pe.photo_url = row["photo_url"].is_null() ? "" : row["photo_url"].c_str();
            pe.has_family_discount = !row["has_family_discount"].is_null() && row["has_family_discount"].as<bool>();
            pe.is_keeper = !row["is_keeper"].is_null() && row["is_keeper"].as<bool>();
            pe.sessions_attended = row["sessions_attended"].as<int>();
            pe.sessions_in_window = sessionIds.size();
            pe.person_id = row["person_id"].as<int>();
            
            // Projected: current attendance + future RSVP yes count
            int futureRsvpYes = row["future_rsvp_yes"].as<int>();
            pe.projected_sessions = pe.sessions_attended + futureRsvpYes;
            
            // Compute effective minimum sessions (apply family/keeper discount)
            pe.effective_min_sessions = policy.min_sessions_to_start;
            if (pe.is_keeper) {
                pe.effective_min_sessions = std::max(0, pe.effective_min_sessions - policy.keeper_discount);
            } else if (pe.has_family_discount) {
                pe.effective_min_sessions = std::max(0, pe.effective_min_sessions - policy.family_discount);
            }
            
            // Classify current eligibility
            pe.status = classifyEligibility(
                pe.sessions_attended, pe.effective_min_sessions, policy.priority_starter_sessions
            );
            
            // Classify projected eligibility (if they attend future RSVP'd sessions)
            pe.projected_status = classifyEligibility(
                pe.projected_sessions, pe.effective_min_sessions, policy.priority_starter_sessions
            );
            
            pe.match_rsvp = row["match_rsvp_status"].is_null() ? "" : row["match_rsvp_status"].c_str();
            pe.on_lineup = !row["on_lineup"].is_null() && row["on_lineup"].as<bool>();
            pe.is_starter = !row["lineup_is_starter"].is_null() && row["lineup_is_starter"].as<bool>();
            pe.on_official_roster = !row["on_official_roster"].is_null() && row["on_official_roster"].as<bool>();
            
            if (pe.status == EligibilityStatus::PRIORITY_STARTER) {
                priorityStarterCount++;
            }
            
            players.push_back(pe);
        }
        
        // Second pass: output JSON
        for (const auto& pe : players) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"playerId\":" << pe.player_id << ",";
            json << "\"personId\":" << pe.person_id << ",";
            json << "\"firstName\":\"" << escapeJson(pe.first_name) << "\",";
            json << "\"lastName\":\"" << escapeJson(pe.last_name) << "\",";
            json << "\"jerseyNumber\":" << (pe.jersey_number.empty() ? "null" : "\"" + pe.jersey_number + "\"") << ",";
            json << "\"position\":" << (pe.position.empty() ? "null" : "\"" + pe.position + "\"") << ",";
            json << "\"photoUrl\":" << (pe.photo_url.empty() ? "null" : "\"" + escapeJson(pe.photo_url) + "\"") << ",";
            json << "\"hasFamilyDiscount\":" << (pe.has_family_discount ? "true" : "false") << ",";
            json << "\"isKeeper\":" << (pe.is_keeper ? "true" : "false") << ",";
            json << "\"sessionsInWindow\":" << pe.sessions_in_window << ",";
            json << "\"sessionsAttended\":" << pe.sessions_attended << ",";
            json << "\"projectedSessions\":" << pe.projected_sessions << ",";
            json << "\"effectiveMinSessions\":" << pe.effective_min_sessions << ",";
            json << "\"eligibilityStatus\":\"" << statusToString(pe.status) << "\",";
            json << "\"projectedStatus\":\"" << statusToString(pe.projected_status) << "\",";
            json << "\"matchRsvp\":" << (pe.match_rsvp.empty() ? "null" : "\"" + pe.match_rsvp + "\"") << ",";
            json << "\"onOfficialRoster\":" << (pe.on_official_roster ? "true" : "false") << ",";
            json << "\"onLineup\":" << (pe.on_lineup ? "true" : "false") << ",";
            json << "\"isStarter\":" << (pe.is_starter ? "true" : "false");
            json << "}";
        }
        
        json << "],";
        
        // Step 6b: Get unmatched GroupMe RSVP users (person_id IS NULL)
        json << "\"unmatchedRsvps\":[";
        try {
            pqxx::result unmatchedResult = db_->query(R"(
                SELECT cer.external_user_id, cer.external_username, rs.name as rsvp_status
                FROM chat_event_rsvps cer
                JOIN chat_events ce ON ce.id = cer.chat_event_id
                JOIN chats c ON c.id = ce.chat_id
                JOIN rsvp_statuses rs ON rs.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id)
                WHERE ce.match_id = $1::int AND c.team_id = $2::int
                  AND cer.person_id IS NULL
                ORDER BY cer.external_username
            )", {matchId, teamId});
            
            bool firstUnmatched = true;
            for (const auto& row : unmatchedResult) {
                if (!firstUnmatched) json << ",";
                firstUnmatched = false;
                json << "{";
                json << "\"externalUserId\":\"" << escapeJson(row["external_user_id"].c_str()) << "\",";
                json << "\"externalUsername\":\"" << escapeJson(row["external_username"].c_str()) << "\",";
                json << "\"matchRsvp\":\"" << row["rsvp_status"].c_str() << "\"";
                json << "}";
            }
        } catch (const std::exception& e) {
            std::cerr << "⚠️ Unmatched RSVPs query failed: " << e.what() << std::endl;
        }
        json << "],";
        
        json << "\"priorityStarterCount\":" << priorityStarterCount << ",";
        json << "\"priorityStarterSlots\":" << policy.priority_starter_slots << ",";
        json << "\"totalPlayers\":" << players.size();
        json << "}}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error computing eligibility: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            createJsonResponse(false, std::string("Failed to compute eligibility: ") + e.what()));
    }
}

// ============================================================================
// GET /api/eligibility/policy/:teamId
// Get effective policy for a team (resolves cascade)
// ============================================================================
Response EligibilityController::handleGetTeamPolicy(const Request& request) {
    std::string teamId = extractIdFromPath(request.getPath(), "/api/eligibility/policy/(\\d+)");
    if (teamId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Team ID is required"));
    }
    
    try {
        // Get club_id for the team
        pqxx::result teamResult = db_->query(
            "SELECT club_id FROM teams WHERE id = $1", {teamId}
        );
        if (teamResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Team not found"));
        }
        std::string clubId = teamResult[0]["club_id"].is_null() ? "" : teamResult[0]["club_id"].c_str();
        
        EligibilityPolicy policy = resolvePolicy("", teamId, clubId);
        
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{";
        json << "\"policyId\":" << policy.id << ",";
        json << "\"lookbackCount\":" << policy.lookback_count << ",";
        json << "\"minSessionsToStart\":" << policy.min_sessions_to_start << ",";
        json << "\"priorityStarterSessions\":" << policy.priority_starter_sessions << ",";
        json << "\"priorityStarterSlots\":" << policy.priority_starter_slots << ",";
        json << "\"gameCountsAsSession\":" << (policy.game_counts_as_session ? "true" : "false") << ",";
        json << "\"pickupCountsAsSession\":" << (policy.pickup_counts_as_session ? "true" : "false") << ",";
        json << "\"familyDiscount\":" << policy.family_discount << ",";
        json << "\"keeperDiscount\":" << policy.keeper_discount;
        json << "}}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting policy: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to get policy: ") + e.what()));
    }
}

// ============================================================================
// PUT /api/eligibility/policy/:teamId
// Create or update team-level eligibility policy
// ============================================================================
Response EligibilityController::handleUpdateTeamPolicy(const Request& request) {
    std::string teamId = extractIdFromPath(request.getPath(), "/api/eligibility/policy/(\\d+)");
    if (teamId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Team ID is required"));
    }
    
    std::string userId = extractUserIdFromToken(request);
    if (userId.empty()) {
        return Response(HttpStatus::UNAUTHORIZED, createJsonResponse(false, "Authentication required"));
    }
    
    try {
        std::string body = request.getBody();
        
        int lookbackCount = parseJsonInt(body, "lookback_count", 5);
        int minSessions = parseJsonInt(body, "min_sessions_to_start", 2);
        int prioritySessions = parseJsonInt(body, "priority_starter_sessions", 3);
        int prioritySlots = parseJsonInt(body, "priority_starter_slots", 3);
        bool gameCounts = parseJsonBool(body, "game_counts_as_session", true);
        bool pickupCounts = parseJsonBool(body, "pickup_counts_as_session", true);
        int familyDiscount = parseJsonInt(body, "family_discount", 1);
        int keeperDiscount = parseJsonInt(body, "keeper_discount", 2);
        
        std::string upsertQuery = R"(
            INSERT INTO eligibility_policies 
                (team_id, lookback_count, min_sessions_to_start, 
                 priority_starter_sessions, priority_starter_slots,
                 game_counts_as_session, pickup_counts_as_session, 
                 family_discount, keeper_discount, created_by_user_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            ON CONFLICT (club_id, team_id, match_id)
            DO UPDATE SET
                lookback_count = EXCLUDED.lookback_count,
                min_sessions_to_start = EXCLUDED.min_sessions_to_start,
                priority_starter_sessions = EXCLUDED.priority_starter_sessions,
                priority_starter_slots = EXCLUDED.priority_starter_slots,
                game_counts_as_session = EXCLUDED.game_counts_as_session,
                pickup_counts_as_session = EXCLUDED.pickup_counts_as_session,
                family_discount = EXCLUDED.family_discount,
                keeper_discount = EXCLUDED.keeper_discount
            RETURNING id
        )";
        
        pqxx::result result = db_->query(upsertQuery, {
            teamId,
            std::to_string(lookbackCount),
            std::to_string(minSessions),
            std::to_string(prioritySessions),
            std::to_string(prioritySlots),
            gameCounts ? "true" : "false",
            pickupCounts ? "true" : "false",
            std::to_string(familyDiscount),
            std::to_string(keeperDiscount),
            userId
        });
        
        std::string policyId = result.empty() ? "0" : result[0]["id"].c_str();
        return Response(HttpStatus::OK, 
            createJsonResponse(true, "Policy updated", "{\"policyId\":" + policyId + "}"));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating policy: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to update policy: ") + e.what()));
    }
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
            createJsonResponse(false, std::string("Failed to get lineup: ") + e.what()));
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
            "SELECT home_team_id FROM matches WHERE id = $1", {matchId}
        );
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        std::string teamId = matchResult[0]["home_team_id"].c_str();
        
        // Parse formation and roster size
        int formationId = parseJsonInt(body, "formationId", 0);
        int rosterSize = parseJsonInt(body, "rosterSize", 20);
        
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
        
        // Parse starters: extract playerId and slotNumber from each object
        std::regex starterObjPattern(R"(\{[^}]*"playerId"\s*:\s*(\d+)[^}]*\})");
        std::regex slotPattern(R"("slotNumber"\s*:\s*(\d+))");
        
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
                
                // Extract slot number from the object
                std::smatch slotMatch;
                std::string slotStr = "NULL";
                if (std::regex_search(objStr, slotMatch, slotPattern)) {
                    slotStr = slotMatch[1].str();
                }
                
                std::string insertQuery;
                if (slotStr != "NULL") {
                    insertQuery = 
                        "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, slot_number, zone) "
                        "VALUES ($1, $2, $3, true, $4, 'starter') "
                        "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = true, "
                        "slot_number = EXCLUDED.slot_number, zone = 'starter'";
                    db_->query(insertQuery, {matchId, playerId, teamId, slotStr});
                } else {
                    insertQuery = 
                        "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, slot_number, zone) "
                        "VALUES ($1, $2, $3, true, NULL, 'starter') "
                        "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = true, "
                        "slot_number = NULL, zone = 'starter'";
                    db_->query(insertQuery, {matchId, playerId, teamId});
                }
                insertedCount++;
            }
        }
        
        // Parse bench array
        size_t benchStart = body.find("\"bench\"");
        size_t benchArrayStart = (benchStart != std::string::npos) ? body.find("[", benchStart) : std::string::npos;
        size_t benchArrayEnd = (benchArrayStart != std::string::npos) ? body.find("]", benchArrayStart) : std::string::npos;
        
        if (benchStart != std::string::npos && benchArrayStart != std::string::npos) {
            std::string benchSection = body.substr(benchArrayStart, benchArrayEnd - benchArrayStart + 1);
            
            std::regex playerIdPattern(R"("playerId"\s*:\s*(\d+))");
            auto begin = std::sregex_iterator(benchSection.begin(), benchSection.end(), playerIdPattern);
            auto end = std::sregex_iterator();
            
            for (auto it = begin; it != end; ++it) {
                std::string playerId = (*it)[1].str();
                
                db_->query(
                    "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, zone) "
                    "VALUES ($1, $2, $3, false, 'bench') "
                    "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = false, zone = 'bench'",
                    {matchId, playerId, teamId}
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
            createJsonResponse(false, std::string("Failed to save lineup: ") + e.what()));
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
            SELECT mlm.formation_id, mlm.roster_size, mlm.notes,
                   f.code as formation_code, f.name as formation_name,
                   f.positions_json as formation_positions
            FROM match_lineup_metadata mlm
            LEFT JOIN formations f ON f.id = mlm.formation_id
            WHERE mlm.match_id = $1
        )", {matchId});
        
        if (result.empty()) {
            return Response(HttpStatus::OK, 
                createJsonResponse(true, "No metadata", "{\"formationId\":null,\"rosterSize\":20,\"notes\":null}"));
        }
        
        const auto& row = result[0];
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{";
        json << "\"formationId\":" << (row["formation_id"].is_null() ? "null" : row["formation_id"].c_str()) << ",";
        json << "\"rosterSize\":" << row["roster_size"].c_str() << ",";
        json << "\"notes\":" << (row["notes"].is_null() ? "null" : "\"" + escapeJson(row["notes"].c_str()) + "\"") << ",";
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
            createJsonResponse(false, std::string("Failed to get lineup metadata: ") + e.what()));
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
        
        // Get team_id from match
        pqxx::result matchResult = db_->query(
            "SELECT home_team_id FROM matches WHERE id = $1", {matchId}
        );
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        std::string teamId = matchResult[0]["home_team_id"].c_str();
        
        if (formationId > 0) {
            db_->query(R"(
                INSERT INTO match_lineup_metadata (match_id, team_id, formation_id, roster_size, notes, created_by_user_id, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
                ON CONFLICT (match_id, team_id) DO UPDATE SET
                    formation_id = $3,
                    roster_size = EXCLUDED.roster_size,
                    notes = EXCLUDED.notes,
                    updated_at = CURRENT_TIMESTAMP
            )", {matchId, teamId, std::to_string(formationId), std::to_string(rosterSize), notes, userId});
        } else {
            db_->query(R"(
                INSERT INTO match_lineup_metadata (match_id, team_id, formation_id, roster_size, notes, created_by_user_id, updated_at)
                VALUES ($1, $2, NULL, $3, $4, $5, CURRENT_TIMESTAMP)
                ON CONFLICT (match_id, team_id) DO UPDATE SET
                    formation_id = NULL,
                    roster_size = EXCLUDED.roster_size,
                    notes = EXCLUDED.notes,
                    updated_at = CURRENT_TIMESTAMP
            )", {matchId, teamId, std::to_string(rosterSize), notes, userId});
        }
        
        return Response(HttpStatus::OK, createJsonResponse(true, "Metadata saved"));
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error saving lineup metadata: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to save lineup metadata: ") + e.what()));
    }
}

// ============================================================================
// GET /api/eligibility/player/:playerId/attendance?teamId=X&matchId=Y
// Returns all sessions in lookback window with attendance status for a player
// ============================================================================
Response EligibilityController::handleGetPlayerAttendance(const Request& request) {
    std::string playerId = extractIdFromPath(request.getPath(), "/api/eligibility/player/(\\d+)/attendance");
    if (playerId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Player ID required"));
    }

    std::string teamId = request.getQueryParam("teamId");
    std::string matchId = request.getQueryParam("matchId");
    if (teamId.empty() || matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "teamId and matchId query params required"));
    }

    try {
        // Get match date
        pqxx::result matchResult = db_->query(
            "SELECT match_date::date as match_date FROM matches WHERE id = $1", {matchId});
        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Match not found"));
        }
        std::string matchDate = matchResult[0]["match_date"].c_str();

        // Get club_id for session lookup
        pqxx::result teamResult = db_->query("SELECT club_id FROM teams WHERE id = $1", {teamId});
        std::string clubId = (!teamResult.empty() && !teamResult[0]["club_id"].is_null())
                             ? std::string(teamResult[0]["club_id"].c_str()) : "0";

        // Resolve policy to get lookback count
        EligibilityPolicy policy = resolvePolicy(matchId, teamId, clubId);

        // Get session IDs (same logic as eligibility)
        std::vector<int> sessionIds = getRecentSessionIds(
            teamId, clubId, matchDate, policy.lookback_count,
            policy.game_counts_as_session, policy.pickup_counts_as_session);

        if (sessionIds.empty()) {
            return Response(HttpStatus::OK,
                createJsonResponse(true, "OK", "{\"sessions\":[]}"));
        }

        // Build session ID array
        std::string sessionArray = "{";
        for (size_t i = 0; i < sessionIds.size(); i++) {
            if (i > 0) sessionArray += ",";
            sessionArray += std::to_string(sessionIds[i]);
        }
        sessionArray += "}";

        // Get person_id for this player
        pqxx::result personResult = db_->query(
            "SELECT person_id FROM players WHERE id = $1", {playerId});
        if (personResult.empty()) {
            return Response(HttpStatus::NOT_FOUND, createJsonResponse(false, "Player not found"));
        }
        std::string personId = personResult[0]["person_id"].c_str();

        // Query sessions with attendance + RSVP status for this player
        std::string query = R"(
            SELECT ce.id as session_id,
                   ce.title,
                   COALESCE(ce.event_date::text, to_char(ce.start_at, 'YYYY-MM-DD')) as session_date,
                   CASE WHEN ta.id IS NOT NULL THEN ta.attended
                        ELSE (COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) = 1)
                   END as attended,
                   CASE WHEN ta.id IS NOT NULL THEN 'manual'
                        WHEN cer.id IS NOT NULL THEN 'rsvp'
                        ELSE 'none'
                   END as source,
                   rs.name as rsvp_status
            FROM unnest($1::int[]) WITH ORDINALITY AS s(id, ord)
            JOIN chat_events ce ON ce.id = s.id
            LEFT JOIN training_attendance ta ON ta.chat_event_id = ce.id AND ta.player_id = $2::int
            LEFT JOIN chat_event_rsvps cer ON cer.chat_event_id = ce.id AND cer.person_id = $3::int
            LEFT JOIN rsvp_statuses rs ON rs.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id)
            ORDER BY COALESCE(ce.start_at, ce.event_date::timestamptz) DESC
        )";

        pqxx::result result = db_->query(query, {sessionArray, playerId, personId});

        std::ostringstream json;
        json << "{\"sessions\":[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"sessionId\":" << row["session_id"].as<int>() << ",";
            json << "\"title\":\"" << escapeJson(row["title"].c_str()) << "\",";
            json << "\"date\":\"" << escapeJson(row["session_date"].c_str()) << "\",";
            json << "\"attended\":" << (row["attended"].as<bool>(false) ? "true" : "false") << ",";
            json << "\"source\":\"" << escapeJson(row["source"].c_str()) << "\",";
            json << "\"rsvp\":\"" << (row["rsvp_status"].is_null() ? "" : escapeJson(row["rsvp_status"].c_str())) << "\"";
            json << "}";
        }
        json << "]}";

        return Response(HttpStatus::OK, createJsonResponse(true, "OK", json.str()));

    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting player attendance: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed: ") + e.what()));
    }
}

// ============================================================================
// PUT /api/eligibility/player/:playerId/attendance
// Toggle attendance for a player at a specific session
// Body: { "sessionId": 5, "attended": true }
// ============================================================================
Response EligibilityController::handleUpdatePlayerAttendance(const Request& request) {
    std::string playerId = extractIdFromPath(request.getPath(), "/api/eligibility/player/(\\d+)/attendance");
    if (playerId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Player ID required"));
    }

    int sessionId = parseJsonInt(request.getBody(), "sessionId");
    bool attended = parseJsonBool(request.getBody(), "attended");

    if (sessionId <= 0) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "sessionId required"));
    }

    try {
        // UPSERT into training_attendance
        std::string query = R"(
            INSERT INTO training_attendance (player_id, chat_event_id, attended, source, updated_at)
            VALUES ($1::int, $2::int, $3::bool, 'manual', CURRENT_TIMESTAMP)
            ON CONFLICT (player_id, chat_event_id)
            DO UPDATE SET attended = $3::bool, source = 'manual', updated_at = CURRENT_TIMESTAMP
            RETURNING id
        )";

        pqxx::result result = db_->query(query, {
            playerId, std::to_string(sessionId), attended ? "true" : "false"
        });

        std::string dataJson = "{\"id\":" + std::to_string(result[0]["id"].as<int>()) + "}";
        return Response(HttpStatus::OK, createJsonResponse(true, "Attendance updated", dataJson));

    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating attendance: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed: ") + e.what()));
    }
}

// ============================================================================
// Helper: Resolve cascading eligibility policy
// Priority: match-level > team-level > club-level > system default
// ============================================================================
EligibilityPolicy EligibilityController::resolvePolicy(
    const std::string& matchId, const std::string& teamId, const std::string& clubId) {
    
    try {
        auto loadPolicy = [](const pqxx::result& result) -> EligibilityPolicy {
            return {
                result[0]["id"].as<int>(),
                result[0]["lookback_count"].as<int>(),
                result[0]["min_sessions_to_start"].as<int>(),
                result[0]["priority_starter_sessions"].as<int>(),
                result[0]["priority_starter_slots"].as<int>(),
                result[0]["game_counts_as_session"].as<bool>(),
                result[0]["pickup_counts_as_session"].as<bool>(),
                result[0]["family_discount"].as<int>(),
                result[0]["keeper_discount"].as<int>()
            };
        };

        const char* cols = "SELECT id, lookback_count, min_sessions_to_start, "
            "priority_starter_sessions, priority_starter_slots, "
            "game_counts_as_session, pickup_counts_as_session, family_discount, keeper_discount ";

        // Match level
        if (!matchId.empty()) {
            auto result = db_->query(
                std::string(cols) + "FROM eligibility_policies WHERE match_id = $1 LIMIT 1",
                {matchId}
            );
            if (!result.empty()) return loadPolicy(result);
        }
        
        // Team level
        if (!teamId.empty()) {
            auto result = db_->query(
                std::string(cols) + "FROM eligibility_policies WHERE team_id = $1 AND match_id IS NULL LIMIT 1",
                {teamId}
            );
            if (!result.empty()) return loadPolicy(result);
        }
        
        // Club level
        if (!clubId.empty()) {
            auto result = db_->query(
                std::string(cols) + "FROM eligibility_policies WHERE club_id = $1 AND team_id IS NULL AND match_id IS NULL LIMIT 1",
                {clubId}
            );
            if (!result.empty()) return loadPolicy(result);
        }
        
        // System default (all NULL scope)
        auto result = db_->query(
            std::string(cols) + "FROM eligibility_policies WHERE club_id IS NULL AND team_id IS NULL AND match_id IS NULL LIMIT 1"
        );
        if (!result.empty()) return loadPolicy(result);
    } catch (const std::exception& e) {
        std::cerr << "⚠️ Policy resolution error: " << e.what() << " - using defaults" << std::endl;
    }
    
    // Hardcoded fallback if no policy exists at all
    return {0, 5, 2, 3, 3, true, true, 1, 2};
}

// ============================================================================
// Helper: Get recent session IDs in the lookback window
// Counts back lookbackCount training sessions (from training chat, type=5)
// before the match date. Optionally also counts games and pickups.
// ============================================================================
std::vector<int> EligibilityController::getRecentSessionIds(
    const std::string& teamId, const std::string& clubId,
    const std::string& matchDate, int lookbackCount,
    bool gameCountsAsSession, bool pickupCountsAsSession) {
    
    std::vector<int> sessionIds;
    std::string safeClubId = clubId.empty() ? "0" : clubId;

    // Build chat_type filter: always include training (5)
    // Optionally include team games (1) and pickup (3)
    std::string chatTypeFilter = "c.chat_type_id = 5";
    if (gameCountsAsSession && pickupCountsAsSession) {
        chatTypeFilter = "c.chat_type_id IN (1, 3, 5)";
    } else if (gameCountsAsSession) {
        chatTypeFilter = "c.chat_type_id IN (1, 5)";
    } else if (pickupCountsAsSession) {
        chatTypeFilter = "c.chat_type_id IN (3, 5)";
    }

    // Get the N most recent sessions before the match date
    // from club-associated chats filtered by type.
    // Dedup by local date (America/New_York) so two events on the same
    // evening only count as one practice day.
    std::string query = R"(
        SELECT session_id FROM (
            SELECT DISTINCT ON (
                (COALESCE(ce.start_at, ce.event_date::timestamptz)
                   AT TIME ZONE 'America/New_York')::date
            )
            ce.id as session_id,
            COALESCE(ce.start_at, ce.event_date::timestamptz) as effective_ts
            FROM chat_events ce
            JOIN chats c ON ce.chat_id = c.id
            LEFT JOIN chat_clubs cc ON cc.chat_id = c.id
            LEFT JOIN teams t ON t.id = c.team_id
            WHERE (
                cc.club_id = $1::int
                OR t.club_id = $1::int
            )
              AND )" + chatTypeFilter + R"(
              AND COALESCE(ce.start_at, ce.event_date::timestamptz) < $2::date
              AND ce.is_active = true
            ORDER BY (COALESCE(ce.start_at, ce.event_date::timestamptz)
                        AT TIME ZONE 'America/New_York')::date DESC,
                     ce.id DESC
        ) deduped
        LIMIT $3
    )";

    try {
        pqxx::result result = db_->query(query, {
            safeClubId, matchDate, std::to_string(lookbackCount)
        });
        
        for (const auto& row : result) {
            sessionIds.push_back(row["session_id"].as<int>());
        }
    } catch (const std::exception& e) {
        std::cerr << "⚠️ Error getting sessions: " << e.what() << std::endl;
    }
    
    return sessionIds;
}

// ============================================================================
// Helper: Classify eligibility status
// ============================================================================
EligibilityStatus EligibilityController::classifyEligibility(
    int sessionsAttended, int effectiveMinSessions, int priorityStarterSessions) {
    
    if (sessionsAttended >= priorityStarterSessions) {
        return EligibilityStatus::PRIORITY_STARTER;
    }
    if (sessionsAttended >= effectiveMinSessions) {
        return EligibilityStatus::ELIGIBLE_STARTER;
    }
    if (sessionsAttended > 0) {
        return EligibilityStatus::BENCH_ONLY;
    }
    return EligibilityStatus::INELIGIBLE;
}

// ============================================================================
// Helper: Status enum to string
// ============================================================================
std::string EligibilityController::statusToString(EligibilityStatus status) {
    switch (status) {
        case EligibilityStatus::PRIORITY_STARTER: return "priority_starter";
        case EligibilityStatus::ELIGIBLE_STARTER: return "eligible_starter";
        case EligibilityStatus::BENCH_ONLY: return "bench_only";
        case EligibilityStatus::INELIGIBLE: return "ineligible";
    }
    return "unknown";
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
            std::string payload = base64UrlDecode(token.substr(first_dot + 1, second_dot - first_dot - 1));
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

std::string EligibilityController::escapeJson(const std::string& str) {
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
                    escaped << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(c);
                } else {
                    escaped << c;
                }
        }
    }
    return escaped.str();
}
