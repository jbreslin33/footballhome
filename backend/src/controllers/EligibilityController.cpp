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
        
        // Step 3: Get recent training session IDs
        std::vector<int> sessionIds = getRecentSessionIds(
            teamId, clubId, matchDate, policy.lookback_count,
            policy.game_counts_as_session, policy.pickup_counts_as_session
        );
        
        // Step 4: Get all roster players with attendance and RSVP data
        // Build session ID array for SQL
        std::string sessionArray = "{";
        for (size_t i = 0; i < sessionIds.size(); i++) {
            if (i > 0) sessionArray += ",";
            sessionArray += std::to_string(sessionIds[i]);
        }
        sessionArray += "}";
        
        std::string playerQuery = R"(
            WITH chat_pool AS (
                -- Player pool = distinct persons from team's GroupMe chat RSVPs
                SELECT DISTINCT cer.person_id
                FROM chat_event_rsvps cer
                JOIN chat_events ce ON ce.id = cer.chat_event_id
                JOIN chats c ON c.id = ce.chat_id
                WHERE c.team_id = $1::int
                  AND cer.person_id IS NOT NULL
            ),
            roster_players AS (
                -- Resolve each chat person to their player record
                SELECT DISTINCT ON (cp.person_id)
                       p.id as player_id, r.jersey_number,
                       p.has_family_discount, p.photo_url,
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
                FROM chat_pool cp
                JOIN persons pe ON pe.id = cp.person_id
                JOIN players p ON p.person_id = pe.id
                LEFT JOIN rosters r ON r.player_id = p.id
                    AND r.team_id = $1 AND r.left_at IS NULL
                ORDER BY cp.person_id,
                         CASE WHEN r.player_id IS NOT NULL THEN 0 ELSE 1 END,
                         p.id DESC
            ),
            -- Count actual attendance from training_attendance table
            actual_attendance AS (
                SELECT ta.player_id,
                       COUNT(*) FILTER (WHERE ta.attended = true) as sessions_attended
                FROM training_attendance ta
                WHERE ta.player_id IN (SELECT player_id FROM roster_players)
                  AND ta.chat_event_id = ANY($2::int[])
                GROUP BY ta.player_id
            ),
            -- Count RSVP 'yes' from chat_event_rsvps (fallback when no training_attendance)
            rsvp_attendance AS (
                SELECT rp.player_id,
                       COUNT(*) FILTER (WHERE COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) = 1) as rsvp_yes_count
                FROM roster_players rp
                JOIN chat_event_rsvps cer ON cer.person_id = rp.person_id
                WHERE cer.chat_event_id = ANY($2::int[])
                GROUP BY rp.player_id
            ),
            -- Get RSVP for the match itself (via chat_events linked to matches)
            match_rsvps AS (
                SELECT rp.player_id,
                       rs.name as rsvp_status
                FROM roster_players rp
                JOIN chat_event_rsvps cer ON cer.person_id = rp.person_id
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
                   rp.has_family_discount, rp.photo_url, rp.person_id,
                   rp.on_official_roster,
                   COALESCE(aa.sessions_attended, ra.rsvp_yes_count, 0) as sessions_attended,
                   pp.position, pp.position_name,
                   mr.rsvp_status as match_rsvp_status,
                   lu.is_starter as lineup_is_starter,
                   lu.player_id IS NOT NULL as on_lineup
            FROM roster_players rp
            LEFT JOIN actual_attendance aa ON aa.player_id = rp.player_id
            LEFT JOIN rsvp_attendance ra ON ra.player_id = rp.player_id
            LEFT JOIN match_rsvps mr ON mr.player_id = rp.player_id
            LEFT JOIN lineup lu ON lu.player_id = rp.player_id
            LEFT JOIN player_pos pp ON pp.player_id = rp.player_id
            ORDER BY rp.last_name, rp.first_name
        )";
        
        pqxx::result playerResult = db_->query(playerQuery, {teamId, sessionArray, matchId});
        
        // Step 5: Build response JSON
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{";
        
        // Match info
        json << "\"match\":{";
        json << "\"id\":" << matchId << ",";
        json << "\"date\":\"" << matchDate << "\",";
        json << "\"homeTeam\":\"" << escapeJson(homeTeamName) << "\",";
        json << "\"awayTeam\":\"" << escapeJson(awayTeamName) << "\"";
        json << "},";
        
        // Policy info
        json << "\"policy\":{";
        json << "\"lookbackCount\":" << policy.lookback_count << ",";
        json << "\"minSessionsToStart\":" << policy.min_sessions_to_start << ",";
        json << "\"priorityStarterSessions\":" << policy.priority_starter_sessions << ",";
        json << "\"priorityStarterSlots\":" << policy.priority_starter_slots << ",";
        json << "\"gameCountsAsSession\":" << (policy.game_counts_as_session ? "true" : "false") << ",";
        json << "\"pickupCountsAsSession\":" << (policy.pickup_counts_as_session ? "true" : "false") << ",";
        json << "\"familyDiscount\":" << policy.family_discount;
        json << "},";
        
        // Sessions info
        json << "\"sessionsInWindow\":" << sessionIds.size() << ",";
        
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
            pe.sessions_attended = row["sessions_attended"].as<int>();
            pe.sessions_in_window = sessionIds.size();
            pe.person_id = row["person_id"].as<int>();
            
            // Compute effective minimum sessions (apply family discount)
            pe.effective_min_sessions = policy.min_sessions_to_start;
            if (pe.has_family_discount) {
                pe.effective_min_sessions = std::max(0, pe.effective_min_sessions - policy.family_discount);
            }
            
            // Classify eligibility
            pe.status = classifyEligibility(
                pe.sessions_attended, pe.effective_min_sessions, policy.priority_starter_sessions
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
            json << "\"sessionsInWindow\":" << pe.sessions_in_window << ",";
            json << "\"sessionsAttended\":" << pe.sessions_attended << ",";
            json << "\"effectiveMinSessions\":" << pe.effective_min_sessions << ",";
            json << "\"eligibilityStatus\":\"" << statusToString(pe.status) << "\",";
            json << "\"matchRsvp\":" << (pe.match_rsvp.empty() ? "null" : "\"" + pe.match_rsvp + "\"") << ",";
            json << "\"onOfficialRoster\":" << (pe.on_official_roster ? "true" : "false") << ",";
            json << "\"onLineup\":" << (pe.on_lineup ? "true" : "false") << ",";
            json << "\"isStarter\":" << (pe.is_starter ? "true" : "false");
            json << "}";
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
        json << "\"familyDiscount\":" << policy.family_discount;
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
        
        std::string upsertQuery = R"(
            INSERT INTO eligibility_policies 
                (team_id, lookback_count, min_sessions_to_start, 
                 priority_starter_sessions, priority_starter_slots,
                 game_counts_as_session, pickup_counts_as_session, 
                 family_discount, created_by_user_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (club_id, team_id, match_id)
            DO UPDATE SET
                lookback_count = EXCLUDED.lookback_count,
                min_sessions_to_start = EXCLUDED.min_sessions_to_start,
                priority_starter_sessions = EXCLUDED.priority_starter_sessions,
                priority_starter_slots = EXCLUDED.priority_starter_slots,
                game_counts_as_session = EXCLUDED.game_counts_as_session,
                pickup_counts_as_session = EXCLUDED.pickup_counts_as_session,
                family_discount = EXCLUDED.family_discount
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
// Get saved lineup for a match
// ============================================================================
Response EligibilityController::handleGetMatchLineup(const Request& request) {
    std::string matchId = extractIdFromPath(request.getPath(), "/api/eligibility/lineup/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID is required"));
    }
    
    try {
        std::string query = R"(
            SELECT ml.player_id, ml.is_starter, ml.position_id,
                   pe.first_name, pe.last_name,
                   pos.abbreviation as position
            FROM match_lineups ml
            JOIN players pl ON pl.id = ml.player_id
            JOIN persons pe ON pe.id = pl.person_id
            LEFT JOIN positions pos ON pos.id = ml.position_id
            WHERE ml.match_id = $1
            ORDER BY ml.is_starter DESC, pe.last_name, pe.first_name
        )";
        
        pqxx::result result = db_->query(query, {matchId});
        
        std::ostringstream json;
        json << "{\"success\":true,\"data\":{\"matchId\":" << matchId << ",\"lineup\":[";
        
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"playerId\":" << row["player_id"].c_str() << ",";
            json << "\"isStarter\":" << (row["is_starter"].as<bool>() ? "true" : "false") << ",";
            json << "\"positionId\":" << (row["position_id"].is_null() ? "null" : row["position_id"].c_str()) << ",";
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
// Save match lineup (starting XI + bench)
// Body: { "starters": [{"playerId": 1, "positionId": 3}, ...], "bench": [{"playerId": 5}, ...] }
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
        
        // Delete existing lineup for this match
        db_->query("DELETE FROM match_lineups WHERE match_id = $1", {matchId});
        
        // Parse starters array from JSON body
        // Format: {"starters":[{"playerId":1,"positionId":3},...], "bench":[{"playerId":5},...]}
        // We do a simple regex-based extraction
        int insertedCount = 0;
        
        // Extract starters section
        std::regex starterPattern(R"("playerId"\s*:\s*(\d+)(?:.*?"positionId"\s*:\s*(\d+))?)");
        
        // Find the starters array
        size_t startersStart = body.find("\"starters\"");
        size_t startersArrayStart = body.find("[", startersStart);
        size_t startersArrayEnd = body.find("]", startersArrayStart);
        
        if (startersStart != std::string::npos && startersArrayStart != std::string::npos) {
            std::string startersSection = body.substr(startersArrayStart, startersArrayEnd - startersArrayStart + 1);
            
            auto begin = std::sregex_iterator(startersSection.begin(), startersSection.end(), starterPattern);
            auto end = std::sregex_iterator();
            
            for (auto it = begin; it != end; ++it) {
                std::string playerId = (*it)[1].str();
                std::string positionId = (*it)[2].matched ? (*it)[2].str() : "";
                
                std::string insertQuery = R"(
                    INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
                    VALUES ($1, $2, $3, true, )";
                insertQuery += positionId.empty() ? "NULL" : ("$4");
                insertQuery += ") ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = true, position_id = ";
                insertQuery += positionId.empty() ? "NULL" : "EXCLUDED.position_id";
                
                if (positionId.empty()) {
                    db_->query(insertQuery, {matchId, playerId, teamId});
                } else {
                    db_->query(insertQuery, {matchId, playerId, teamId, positionId});
                }
                insertedCount++;
            }
        }
        
        // Find the bench array
        size_t benchStart = body.find("\"bench\"");
        size_t benchArrayStart = body.find("[", benchStart);
        size_t benchArrayEnd = body.find("]", benchArrayStart);
        
        if (benchStart != std::string::npos && benchArrayStart != std::string::npos) {
            std::string benchSection = body.substr(benchArrayStart, benchArrayEnd - benchArrayStart + 1);
            
            std::regex playerIdPattern(R"("playerId"\s*:\s*(\d+))");
            auto begin = std::sregex_iterator(benchSection.begin(), benchSection.end(), playerIdPattern);
            auto end = std::sregex_iterator();
            
            for (auto it = begin; it != end; ++it) {
                std::string playerId = (*it)[1].str();
                
                db_->query(
                    "INSERT INTO match_lineups (match_id, player_id, team_id, is_starter) "
                    "VALUES ($1, $2, $3, false) "
                    "ON CONFLICT (match_id, player_id) DO UPDATE SET is_starter = false",
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
// Helper: Resolve cascading eligibility policy
// Priority: match-level > team-level > club-level > system default
// ============================================================================
EligibilityPolicy EligibilityController::resolvePolicy(
    const std::string& matchId, const std::string& teamId, const std::string& clubId) {
    
    std::string query = R"(
        SELECT id, lookback_count, min_sessions_to_start,
               priority_starter_sessions, priority_starter_slots,
               game_counts_as_session, pickup_counts_as_session, family_discount
        FROM eligibility_policies
        WHERE 
            (match_id = $1::int AND $1 != '')
            OR (team_id = $2::int AND match_id IS NULL AND $2 != '')
            OR (club_id = $3::int AND team_id IS NULL AND match_id IS NULL AND $3 != '')
            OR (club_id IS NULL AND team_id IS NULL AND match_id IS NULL)
        ORDER BY 
            CASE 
                WHEN match_id IS NOT NULL THEN 1
                WHEN team_id IS NOT NULL THEN 2
                WHEN club_id IS NOT NULL THEN 3
                ELSE 4
            END
        LIMIT 1
    )";
    
    // Handle empty IDs by passing "0" which won't match any real IDs
    std::string safeMatchId = matchId.empty() ? "0" : matchId;
    std::string safeTeamId = teamId.empty() ? "0" : teamId;
    std::string safeClubId = clubId.empty() ? "0" : clubId;
    
    try {
        // Simpler approach: try each level in order
        // Match level
        if (!matchId.empty()) {
            auto result = db_->query(
                "SELECT id, lookback_count, min_sessions_to_start, "
                "priority_starter_sessions, priority_starter_slots, "
                "game_counts_as_session, pickup_counts_as_session, family_discount "
                "FROM eligibility_policies WHERE match_id = $1 LIMIT 1",
                {matchId}
            );
            if (!result.empty()) {
                return {
                    result[0]["id"].as<int>(),
                    result[0]["lookback_count"].as<int>(),
                    result[0]["min_sessions_to_start"].as<int>(),
                    result[0]["priority_starter_sessions"].as<int>(),
                    result[0]["priority_starter_slots"].as<int>(),
                    result[0]["game_counts_as_session"].as<bool>(),
                    result[0]["pickup_counts_as_session"].as<bool>(),
                    result[0]["family_discount"].as<int>()
                };
            }
        }
        
        // Team level
        if (!teamId.empty()) {
            auto result = db_->query(
                "SELECT id, lookback_count, min_sessions_to_start, "
                "priority_starter_sessions, priority_starter_slots, "
                "game_counts_as_session, pickup_counts_as_session, family_discount "
                "FROM eligibility_policies WHERE team_id = $1 AND match_id IS NULL LIMIT 1",
                {teamId}
            );
            if (!result.empty()) {
                return {
                    result[0]["id"].as<int>(),
                    result[0]["lookback_count"].as<int>(),
                    result[0]["min_sessions_to_start"].as<int>(),
                    result[0]["priority_starter_sessions"].as<int>(),
                    result[0]["priority_starter_slots"].as<int>(),
                    result[0]["game_counts_as_session"].as<bool>(),
                    result[0]["pickup_counts_as_session"].as<bool>(),
                    result[0]["family_discount"].as<int>()
                };
            }
        }
        
        // Club level
        if (!clubId.empty()) {
            auto result = db_->query(
                "SELECT id, lookback_count, min_sessions_to_start, "
                "priority_starter_sessions, priority_starter_slots, "
                "game_counts_as_session, pickup_counts_as_session, family_discount "
                "FROM eligibility_policies WHERE club_id = $1 AND team_id IS NULL AND match_id IS NULL LIMIT 1",
                {clubId}
            );
            if (!result.empty()) {
                return {
                    result[0]["id"].as<int>(),
                    result[0]["lookback_count"].as<int>(),
                    result[0]["min_sessions_to_start"].as<int>(),
                    result[0]["priority_starter_sessions"].as<int>(),
                    result[0]["priority_starter_slots"].as<int>(),
                    result[0]["game_counts_as_session"].as<bool>(),
                    result[0]["pickup_counts_as_session"].as<bool>(),
                    result[0]["family_discount"].as<int>()
                };
            }
        }
        
        // System default (all NULL scope)
        auto result = db_->query(
            "SELECT id, lookback_count, min_sessions_to_start, "
            "priority_starter_sessions, priority_starter_slots, "
            "game_counts_as_session, pickup_counts_as_session, family_discount "
            "FROM eligibility_policies WHERE club_id IS NULL AND team_id IS NULL AND match_id IS NULL LIMIT 1"
        );
        
        if (!result.empty()) {
            return {
                result[0]["id"].as<int>(),
                result[0]["lookback_count"].as<int>(),
                result[0]["min_sessions_to_start"].as<int>(),
                result[0]["priority_starter_sessions"].as<int>(),
                result[0]["priority_starter_slots"].as<int>(),
                result[0]["game_counts_as_session"].as<bool>(),
                result[0]["pickup_counts_as_session"].as<bool>(),
                result[0]["family_discount"].as<int>()
            };
        }
    } catch (const std::exception& e) {
        std::cerr << "⚠️ Policy resolution error: " << e.what() << " - using defaults" << std::endl;
    }
    
    // Hardcoded fallback if no policy exists at all
    return {0, 5, 2, 3, 3, true, true, 1};
}

// ============================================================================
// Helper: Get recent session IDs in the lookback window
// Returns chat_event IDs for training sessions before the match date
// ============================================================================
std::vector<int> EligibilityController::getRecentSessionIds(
    const std::string& teamId, const std::string& clubId,
    const std::string& matchDate, int lookbackCount,
    bool gameCountsAsSession, bool pickupCountsAsSession) {
    
    std::vector<int> sessionIds;
    
    // Get training/practice sessions from chats associated with this team's club
    // Club-wide: matches any chat linked to the club (via chat_clubs) or any
    // sibling team in the same club. This ensures Training, Pickup, and game
    // chats for all club teams are included.
    std::string query = R"(
        SELECT ce.id as session_id
        FROM chat_events ce
        JOIN chats c ON ce.chat_id = c.id
        LEFT JOIN chat_clubs cc ON cc.chat_id = c.id
        LEFT JOIN teams t ON t.id = c.team_id
        WHERE (
            cc.club_id = $1::int
            OR t.club_id = $1::int
        )
          AND COALESCE(ce.start_at, ce.event_date::timestamptz) < $2::date
          AND ce.is_active = true
        ORDER BY COALESCE(ce.start_at, ce.event_date::timestamptz) DESC
        LIMIT $3
    )";
    
    std::string safeClubId = clubId.empty() ? "0" : clubId;
    
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
    
    // If game_counts_as_session, also include recent matches before this match date
    if (gameCountsAsSession && sessionIds.size() < static_cast<size_t>(lookbackCount)) {
        try {
            int remaining = lookbackCount - sessionIds.size();
            std::string matchQuery = R"(
                SELECT ce.id as session_id
                FROM chat_events ce
                JOIN chats c ON ce.chat_id = c.id
                LEFT JOIN chat_clubs cc ON cc.chat_id = c.id
                LEFT JOIN teams t ON t.id = c.team_id
                WHERE (
                    cc.club_id = $1::int
                    OR t.club_id = $1::int
                )
                  AND ce.match_id IS NOT NULL
                  AND COALESCE(ce.start_at, ce.event_date::timestamptz) < $2::date
                  AND ce.is_active = true
                ORDER BY COALESCE(ce.start_at, ce.event_date::timestamptz) DESC
                LIMIT $3
            )";
            
            pqxx::result result = db_->query(matchQuery, {
                safeClubId, matchDate, std::to_string(remaining)
            });
            
            for (const auto& row : result) {
                int sid = row["session_id"].as<int>();
                // Avoid duplicates
                bool found = false;
                for (int existingId : sessionIds) {
                    if (existingId == sid) { found = true; break; }
                }
                if (!found) sessionIds.push_back(sid);
            }
        } catch (const std::exception& e) {
            std::cerr << "⚠️ Error getting match sessions: " << e.what() << std::endl;
        }
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
         << ",\"message\":\"" << message << "\"";
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
