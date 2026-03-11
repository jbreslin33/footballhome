#include "GroupMeController.h"
#include <curl/curl.h>
#include <sstream>
#include <regex>
#include <iostream>
#include <chrono>

// ============================================================================
// CURL write callback
// ============================================================================
static size_t GroupMeWriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// ============================================================================
// Constructor
// ============================================================================
GroupMeController::GroupMeController() {
    db_ = Database::getInstance();
    const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
    accessToken_ = token ? std::string(token) : "";
    
    if (accessToken_.empty()) {
        std::cout << "⚠️  GROUPME_ACCESS_TOKEN not set — live sync disabled" << std::endl;
    } else {
        std::cout << "✅ GroupMe live sync enabled" << std::endl;
    }
}

// ============================================================================
// Route Registration
// ============================================================================
void GroupMeController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/groupme/sync-match/:matchId?teamId=X
    router.post(prefix + "/sync-match/:matchId", [this](const Request& request) {
        return this->handleSyncMatchRsvps(request);
    });

    // GET /api/groupme/members/:teamId?matchId=X
    router.get(prefix + "/members/:teamId", [this](const Request& request) {
        return this->handleGetGroupMembers(request);
    });

    // POST /api/groupme/link — Link a GroupMe user to a person
    router.post(prefix + "/link", [this](const Request& request) {
        return this->handleLinkMember(request);
    });

    // DELETE /api/groupme/link — Unlink a GroupMe user from a person
    router.del(prefix + "/link", [this](const Request& request) {
        return this->handleUnlinkMember(request);
    });
}

// ============================================================================
// Main Handler: Sync RSVPs for a match from GroupMe API
// ============================================================================
Response GroupMeController::handleSyncMatchRsvps(const Request& request) {
    if (accessToken_.empty()) {
        return Response(HttpStatus::OK, createJsonResponse(true, "GroupMe token not configured", 
            "{\"synced\":false,\"reason\":\"no_token\"}"));
    }

    std::string matchId = extractIdFromPath(request.getPath(), "/api/groupme/sync-match/(\\d+)");
    if (matchId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Match ID required"));
    }

    std::string teamId = request.getQueryParam("teamId");
    if (teamId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "teamId query param required"));
    }

    std::cout << "🔄 GroupMe sync for match " << matchId << " team " << teamId << std::endl;

    try {
        // Step 1: Find the chat_event linked to this match for this team's chat
        pqxx::result ceResult = db_->query(
            "SELECT ce.id as chat_event_id, ce.external_id as event_external_id, "
            "       ci.external_id as groupme_group_id "
            "FROM chat_events ce "
            "JOIN chats c ON c.id = ce.chat_id "
            "JOIN chat_integrations ci ON ci.chat_id = c.id AND ci.provider_id = 1 "
            "WHERE ce.match_id = $1::int AND c.team_id = $2::int "
            "LIMIT 1",
            {matchId, teamId}
        );

        if (ceResult.empty()) {
            std::cout << "  ℹ️ No linked chat_event found for match " << matchId << std::endl;
            return Response(HttpStatus::OK, createJsonResponse(true, "No GroupMe event linked", 
                "{\"synced\":false,\"reason\":\"no_linked_event\"}"));
        }

        std::string chatEventId = ceResult[0]["chat_event_id"].c_str();
        std::string eventExternalId = ceResult[0]["event_external_id"].c_str();
        std::string groupmeGroupId = ceResult[0]["groupme_group_id"].c_str();

        std::cout << "  📱 GroupMe group: " << groupmeGroupId 
                  << " event: " << eventExternalId 
                  << " chat_event: " << chatEventId << std::endl;

        // Step 2: Fetch group members for nicknames
        std::string groupUrl = "https://api.groupme.com/v3/groups/" + groupmeGroupId + "?token=" + accessToken_;
        std::string groupJson = httpGet(groupUrl);
        
        std::map<std::string, std::string> nicknames;
        if (!groupJson.empty()) {
            nicknames = extractMemberNicknames(groupJson);
            std::cout << "  👥 Loaded " << nicknames.size() << " member nicknames" << std::endl;
        }

        // Step 3: Fetch calendar events from GroupMe
        std::string eventsUrl = "https://api.groupme.com/v3/conversations/" + groupmeGroupId 
                              + "/events/list?token=" + accessToken_;
        std::string eventsJson = httpGet(eventsUrl);

        if (eventsJson.empty()) {
            return Response(HttpStatus::OK, createJsonResponse(true, "GroupMe API returned empty response",
                "{\"synced\":false,\"reason\":\"api_error\"}"));
        }

        // Step 4: Find the specific event by external_id
        std::string eventNeedle = "\"event_id\":\"" + eventExternalId + "\"";
        size_t eventPos = eventsJson.find(eventNeedle);
        if (eventPos == std::string::npos) {
            std::cout << "  ⚠️ Event " << eventExternalId << " not found in GroupMe response" << std::endl;
            return Response(HttpStatus::OK, createJsonResponse(true, "Event not found in GroupMe",
                "{\"synced\":false,\"reason\":\"event_not_found\"}"));
        }

        // Find bounds: search backward for { and limit forward to next event_id or end
        size_t nextEventPos = eventsJson.find("\"event_id\":", eventPos + eventNeedle.length());
        size_t searchEnd = (nextEventPos != std::string::npos) ? nextEventPos : eventsJson.length();

        // Step 5: Extract RSVP arrays
        std::vector<std::string> going = extractStringArray(eventsJson, eventPos, searchEnd, "going");
        std::vector<std::string> notGoing = extractStringArray(eventsJson, eventPos, searchEnd, "not_going");
        std::vector<std::string> maybeGoing = extractStringArray(eventsJson, eventPos, searchEnd, "maybe_going");

        std::cout << "  📊 RSVPs: " << going.size() << " going, " 
                  << notGoing.size() << " not going, " 
                  << maybeGoing.size() << " maybe" << std::endl;

        // Step 6: Load person mappings (GroupMe user_id → person_id)
        pqxx::result identResult = db_->query(
            "SELECT external_user_id, person_id FROM external_identities WHERE provider_id = 1"
        );
        std::map<std::string, std::string> personMap;
        for (const auto& row : identResult) {
            personMap[row["external_user_id"].c_str()] = row["person_id"].c_str();
        }

        // Step 7: Upsert RSVPs
        int rsvpCount = 0;
        auto upsertRsvps = [&](const std::vector<std::string>& userIds, int statusId) {
            for (const auto& uid : userIds) {
                std::string nickname = nicknames.count(uid) ? nicknames[uid] : ("GroupMe#" + uid);
                auto personIt = personMap.find(uid);
                
                if (personIt != personMap.end()) {
                    // Person is mapped
                    db_->query(
                        "INSERT INTO chat_event_rsvps "
                        "  (chat_event_id, person_id, external_user_id, external_username, rsvp_status_id, responded_at) "
                        "VALUES ($1::int, $2::int, $3, $4, $5::int, CURRENT_TIMESTAMP) "
                        "ON CONFLICT (chat_event_id, person_id) DO UPDATE SET "
                        "  rsvp_status_id = EXCLUDED.rsvp_status_id, "
                        "  responded_at = EXCLUDED.responded_at, "
                        "  external_username = EXCLUDED.external_username",
                        {chatEventId, personIt->second, uid, nickname, std::to_string(statusId)}
                    );
                } else {
                    // Unknown person — store with external_user_id only
                    db_->query(
                        "INSERT INTO chat_event_rsvps "
                        "  (chat_event_id, external_user_id, external_username, rsvp_status_id, responded_at) "
                        "VALUES ($1::int, $2, $3, $4::int, CURRENT_TIMESTAMP) "
                        "ON CONFLICT (chat_event_id, external_user_id) DO UPDATE SET "
                        "  rsvp_status_id = EXCLUDED.rsvp_status_id, "
                        "  responded_at = EXCLUDED.responded_at, "
                        "  external_username = EXCLUDED.external_username",
                        {chatEventId, uid, nickname, std::to_string(statusId)}
                    );
                }
                rsvpCount++;
            }
        };

        upsertRsvps(going, 1);      // yes
        upsertRsvps(notGoing, 2);   // no
        upsertRsvps(maybeGoing, 3); // maybe

        std::cout << "  ✅ Synced " << rsvpCount << " RSVPs" << std::endl;

        // Build response
        std::ostringstream data;
        data << "{\"synced\":true,"
             << "\"going\":" << going.size() << ","
             << "\"notGoing\":" << notGoing.size() << ","
             << "\"maybe\":" << maybeGoing.size() << ","
             << "\"totalRsvps\":" << rsvpCount << "}";

        return Response(HttpStatus::OK, createJsonResponse(true, "RSVPs synced", data.str()));

    } catch (const std::exception& e) {
        std::cerr << "❌ GroupMe sync error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            createJsonResponse(false, std::string("Sync failed: ") + e.what()));
    }
}

// ============================================================================
// Handler: Unified roster + GroupMe members for a team's club
// GET /api/groupme/members/:teamId?matchId=X
// Returns ALL GroupMe chat members + ALL roster players from club sibling teams
// ============================================================================
Response GroupMeController::handleGetGroupMembers(const Request& request) {
    if (accessToken_.empty()) {
        return Response(HttpStatus::OK, createJsonResponse(false, "GroupMe token not configured"));
    }

    std::string teamId = extractIdFromPath(request.getPath(), "/api/groupme/members/(\\d+)");
    if (teamId.empty()) {
        return Response(HttpStatus::BAD_REQUEST, createJsonResponse(false, "Team ID required"));
    }

    std::string matchId = request.getQueryParam("matchId");

    try {
        // Step 1: Find the chat + GroupMe group for this team
        pqxx::result chatResult = db_->query(
            "SELECT c.id as chat_id, ci.external_id as groupme_group_id "
            "FROM chats c "
            "JOIN chat_integrations ci ON ci.chat_id = c.id AND ci.provider_id = 1 "
            "WHERE c.team_id = $1::int "
            "LIMIT 1",
            {teamId}
        );

        if (chatResult.empty()) {
            return Response(HttpStatus::OK, createJsonResponse(false, "No GroupMe chat linked to this team"));
        }

        std::string chatId = chatResult[0]["chat_id"].c_str();
        std::string groupmeGroupId = chatResult[0]["groupme_group_id"].c_str();

        // Step 2: Find all sibling teams from the same club
        struct TeamInfo {
            std::string teamId;
            std::string teamName;
            std::string divisionName;
        };
        std::vector<TeamInfo> clubTeams;

        pqxx::result siblingResult = db_->query(
            "SELECT t2.id, t2.name as team_name, d.name as division_name "
            "FROM teams t1 "
            "JOIN teams t2 ON t2.club_id = t1.club_id "
            "LEFT JOIN divisions d ON d.id = t2.division_id "
            "WHERE t1.id = $1::int "
            "ORDER BY t2.id",
            {teamId}
        );
        for (const auto& row : siblingResult) {
            TeamInfo ti;
            ti.teamId = row["id"].c_str();
            ti.teamName = row["team_name"].c_str();
            ti.divisionName = row["division_name"].is_null() ? "" : row["division_name"].c_str();
            clubTeams.push_back(ti);
        }
        std::cout << "🏟️  Club has " << clubTeams.size() << " teams" << std::endl;

        // Step 3: Fetch all group members from GroupMe API
        std::string groupUrl = "https://api.groupme.com/v3/groups/" + groupmeGroupId + "?token=" + accessToken_;
        std::string groupJson = httpGet(groupUrl);

        if (groupJson.empty()) {
            return Response(HttpStatus::OK, createJsonResponse(false, "Failed to fetch GroupMe group"));
        }

        auto members = extractFullMemberData(groupJson);
        std::cout << "👥 GroupMe group " << groupmeGroupId << ": " << members.size() << " members" << std::endl;

        // Step 4: Load ALL person linkages from external_identities (GroupMe provider)
        struct PersonLink {
            std::string personId;
            std::string firstName;
            std::string lastName;
        };
        std::map<std::string, PersonLink> personLinks;         // gm_user_id → PersonLink
        std::map<std::string, std::string> personToGmUserId;   // person_id → gm_user_id

        pqxx::result eiResult = db_->query(
            "SELECT ei.external_user_id, ei.person_id, "
            "       p.first_name, p.last_name "
            "FROM external_identities ei "
            "JOIN persons p ON p.id = ei.person_id "
            "WHERE ei.provider_id = 1"
        );
        for (const auto& row : eiResult) {
            PersonLink pl;
            pl.personId = row["person_id"].c_str();
            pl.firstName = row["first_name"].c_str();
            pl.lastName = row["last_name"].c_str();
            std::string extId = row["external_user_id"].c_str();
            personLinks[extId] = pl;
            personToGmUserId[pl.personId] = extId;
        }

        // Step 5: Load rosters for ALL club sibling teams
        // Map: person_id → [{teamId, teamName, divisionName, playerId}]
        struct RosterEntry {
            std::string teamId;
            std::string teamName;
            std::string divisionName;
            std::string playerId;
        };
        std::map<std::string, std::vector<RosterEntry>> rosterByPerson;
        // Also build a set of person_ids we've seen on rosters
        std::set<std::string> allRosterPersonIds;

        // Build comma-separated team IDs for query
        std::string teamIdList;
        for (size_t i = 0; i < clubTeams.size(); i++) {
            if (i > 0) teamIdList += ",";
            teamIdList += clubTeams[i].teamId;
        }

        pqxx::result rosterResult = db_->query(
            "SELECT p.person_id, p.id as player_id, r.team_id, "
            "       pe.first_name, pe.last_name "
            "FROM players p "
            "JOIN rosters r ON r.player_id = p.id "
            "JOIN persons pe ON pe.id = p.person_id "
            "WHERE r.team_id IN (" + teamIdList + ") AND r.left_at IS NULL "
            "ORDER BY pe.last_name, pe.first_name"
        );
        for (const auto& row : rosterResult) {
            std::string personId = row["person_id"].c_str();
            std::string rTeamId = row["team_id"].c_str();
            allRosterPersonIds.insert(personId);

            RosterEntry re;
            re.teamId = rTeamId;
            re.playerId = row["player_id"].c_str();
            // Find team name/division from clubTeams
            for (const auto& ct : clubTeams) {
                if (ct.teamId == rTeamId) {
                    re.teamName = ct.teamName;
                    re.divisionName = ct.divisionName;
                    break;
                }
            }
            rosterByPerson[personId].push_back(re);

            // Also store person name if not already linked via external_identities
            // (We need it for roster-only players)
            if (personToGmUserId.find(personId) == personToGmUserId.end()) {
                // This person has no GM link — remember their name for later
                // (We'll use the roster query result for this)
            }
        }

        // Step 6: Load RSVP data for the match
        std::map<std::string, std::string> rsvpByExternalId;
        std::map<std::string, std::string> rsvpByPersonId;
        if (!matchId.empty()) {
            pqxx::result rsvpResult = db_->query(
                "SELECT cer.external_user_id, cer.person_id, rs.name as rsvp_status "
                "FROM chat_event_rsvps cer "
                "JOIN chat_events ce ON ce.id = cer.chat_event_id "
                "JOIN rsvp_statuses rs ON rs.id = COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) "
                "WHERE ce.match_id = $1::int AND ce.chat_id = $2::int",
                {matchId, chatId}
            );
            for (const auto& row : rsvpResult) {
                if (!row["external_user_id"].is_null()) {
                    rsvpByExternalId[row["external_user_id"].c_str()] = row["rsvp_status"].c_str();
                }
                if (!row["person_id"].is_null()) {
                    rsvpByPersonId[row["person_id"].c_str()] = row["rsvp_status"].c_str();
                }
            }
        }

        // Step 7: Load practice attendance counts
        std::map<std::string, int> practiceCounts;
        if (!matchId.empty()) {
            pqxx::result practiceResult = db_->query(
                "SELECT pl.person_id::text, COUNT(*) as cnt "
                "FROM training_attendance ta "
                "JOIN players pl ON pl.id = ta.player_id "
                "JOIN chat_events ce ON ce.id = ta.chat_event_id "
                "WHERE ce.chat_id IN (SELECT c2.id FROM chats c2 WHERE c2.team_id = $1::int OR c2.id = 4) "
                "  AND ta.attended = true "
                "GROUP BY pl.person_id",
                {teamId}
            );
            for (const auto& row : practiceResult) {
                practiceCounts[row["person_id"].c_str()] = std::stoi(row["cnt"].c_str());
            }
        }

        // ====================================================================
        // Step 8: Build unified response — merge GroupMe members + roster-only players
        // ====================================================================
        std::ostringstream json;
        json << "{\"members\":[";

        // Track which person_ids we've already emitted (prevent duplicates)
        std::set<std::string> emittedPersonIds;
        std::set<std::string> emittedGmUserIds;
        bool first = true;

        // Helper lambda to emit a member JSON object
        auto emitMember = [&](const std::string& gmUserId, const std::string& gmNickname,
                              const std::string& gmImageUrl, const std::string& personId,
                              const std::string& firstName, const std::string& lastName,
                              bool linked, const std::string& source) {
            if (!first) json << ",";
            first = false;

            json << "{";
            json << "\"externalUserId\":" << (gmUserId.empty() ? "null" : "\"" + escapeJson(gmUserId) + "\"") << ",";
            json << "\"nickname\":" << (gmNickname.empty() ? "null" : "\"" + escapeJson(gmNickname) + "\"") << ",";
            json << "\"imageUrl\":" << (gmImageUrl.empty() ? "null" : "\"" + escapeJson(gmImageUrl) + "\"") << ",";
            json << "\"personId\":" << (personId.empty() ? "null" : personId) << ",";
            json << "\"firstName\":" << (firstName.empty() ? "null" : "\"" + escapeJson(firstName) + "\"") << ",";
            json << "\"lastName\":" << (lastName.empty() ? "null" : "\"" + escapeJson(lastName) + "\"") << ",";
            json << "\"linked\":" << (linked ? "true" : "false") << ",";
            json << "\"source\":\"" << source << "\",";

            // Teams array
            json << "\"teams\":[";
            if (!personId.empty()) {
                auto rIt = rosterByPerson.find(personId);
                if (rIt != rosterByPerson.end()) {
                    bool firstTeam = true;
                    for (const auto& re : rIt->second) {
                        if (!firstTeam) json << ",";
                        firstTeam = false;
                        json << "{\"teamId\":" << re.teamId
                             << ",\"teamName\":\"" << escapeJson(re.teamName) << "\""
                             << ",\"divisionName\":\"" << escapeJson(re.divisionName) << "\""
                             << ",\"playerId\":" << re.playerId << "}";
                    }
                }
            }
            json << "],";

            // Practice count
            int practiceCount = 0;
            if (!personId.empty()) {
                auto pcIt = practiceCounts.find(personId);
                if (pcIt != practiceCounts.end()) practiceCount = pcIt->second;
            }
            json << "\"practiceCount\":" << practiceCount << ",";

            // RSVP
            std::string rsvp;
            if (!personId.empty()) {
                auto rsvpIt = rsvpByPersonId.find(personId);
                if (rsvpIt != rsvpByPersonId.end()) rsvp = rsvpIt->second;
            }
            if (rsvp.empty() && !gmUserId.empty()) {
                auto rsvpExtIt = rsvpByExternalId.find(gmUserId);
                if (rsvpExtIt != rsvpByExternalId.end()) rsvp = rsvpExtIt->second;
            }
            json << "\"matchRsvp\":" << (rsvp.empty() ? "null" : "\"" + escapeJson(rsvp) + "\"");

            json << "}";
        };

        // --- Part A: Emit all GroupMe members ---
        for (const auto& member : members) {
            emittedGmUserIds.insert(member.userId);

            auto plIt = personLinks.find(member.userId);
            if (plIt != personLinks.end()) {
                emittedPersonIds.insert(plIt->second.personId);
                bool isOnAnyRoster = rosterByPerson.count(plIt->second.personId) > 0;
                std::string src = isOnAnyRoster ? "both" : "groupme_only";
                emitMember(member.userId, member.nickname, member.imageUrl,
                           plIt->second.personId, plIt->second.firstName, plIt->second.lastName,
                           true, src);
            } else {
                emitMember(member.userId, member.nickname, member.imageUrl,
                           "", "", "", false, "groupme_only");
            }
        }

        // --- Part B: Emit roster-only players (not in GroupMe) ---
        for (const auto& row : rosterResult) {
            std::string personId = row["person_id"].c_str();
            if (emittedPersonIds.count(personId) > 0) continue; // Already emitted via GroupMe
            emittedPersonIds.insert(personId);

            std::string firstName = row["first_name"].c_str();
            std::string lastName = row["last_name"].c_str();

            // Check if this person has a GM user id (linked but not in the chat)
            std::string gmUserId;
            auto gmIt = personToGmUserId.find(personId);
            if (gmIt != personToGmUserId.end()) gmUserId = gmIt->second;

            emitMember(gmUserId, "", "", personId, firstName, lastName,
                       !gmUserId.empty(), "roster_only");
        }

        json << "],";

        // Include sibling teams metadata
        json << "\"teams\":[";
        for (size_t i = 0; i < clubTeams.size(); i++) {
            if (i > 0) json << ",";
            json << "{\"teamId\":" << clubTeams[i].teamId
                 << ",\"teamName\":\"" << escapeJson(clubTeams[i].teamName) << "\""
                 << ",\"divisionName\":\"" << escapeJson(clubTeams[i].divisionName) << "\"}";
        }
        json << "],";

        json << "\"totalMembers\":" << members.size()
             << ",\"totalRosterPlayers\":" << allRosterPersonIds.size()
             << "}";

        return Response(HttpStatus::OK, createJsonResponse(true, "Group members loaded", json.str()));

    } catch (const std::exception& e) {
        std::cerr << "❌ GroupMe members error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to load members: ") + e.what()));
    }
}

// ============================================================================
// Handler: Link a GroupMe user to an existing person
// POST /api/groupme/link  body: {"externalUserId":"123", "personId":456, "nickname":"...", "imageUrl":"..."}
// ============================================================================
Response GroupMeController::handleLinkMember(const Request& request) {
    try {
        std::string body = request.getBody();

        // Simple JSON parsing for the fields we need
        auto extractJsonString = [&](const std::string& key) -> std::string {
            std::string search = "\"" + key + "\":\"";
            size_t pos = body.find(search);
            if (pos == std::string::npos) return "";
            pos += search.size();
            size_t end = body.find("\"", pos);
            if (end == std::string::npos) return "";
            return body.substr(pos, end - pos);
        };

        auto extractJsonInt = [&](const std::string& key) -> std::string {
            std::string search = "\"" + key + "\":";
            size_t pos = body.find(search);
            if (pos == std::string::npos) return "";
            pos += search.size();
            // Skip whitespace
            while (pos < body.size() && (body[pos] == ' ' || body[pos] == '\t')) pos++;
            size_t end = pos;
            while (end < body.size() && (body[end] >= '0' && body[end] <= '9')) end++;
            return body.substr(pos, end - pos);
        };

        std::string externalUserId = extractJsonString("externalUserId");
        std::string personIdStr = extractJsonInt("personId");
        std::string nickname = extractJsonString("nickname");
        std::string imageUrl = extractJsonString("imageUrl");

        if (externalUserId.empty() || personIdStr.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJsonResponse(false, "externalUserId and personId required"));
        }

        // Check if link already exists
        pqxx::result existing = db_->query(
            "SELECT id FROM external_identities "
            "WHERE provider_id = 1 AND external_user_id = $1",
            {externalUserId}
        );

        if (!existing.empty()) {
            // Update existing link
            db_->query(
                "UPDATE external_identities SET "
                "  person_id = $1::int, "
                "  external_display_name = $2, "
                "  external_avatar_url = $3, "
                "  last_synced_at = NOW() "
                "WHERE provider_id = 1 AND external_user_id = $4",
                {personIdStr, nickname, imageUrl, externalUserId}
            );
        } else {
            // Insert new link
            db_->query(
                "INSERT INTO external_identities "
                "(person_id, provider_id, external_user_id, external_username, external_display_name, external_avatar_url, last_synced_at) "
                "VALUES ($1::int, 1, $2, $3, $4, $5, NOW())",
                {personIdStr, externalUserId, nickname, nickname, imageUrl}
            );
        }

        // Also update person_id on any existing chat_event_rsvps for this external user
        db_->query(
            "UPDATE chat_event_rsvps SET person_id = $1::int "
            "WHERE external_user_id = $2 AND person_id IS NULL",
            {personIdStr, externalUserId}
        );

        std::cout << "🔗 Linked GroupMe user " << externalUserId << " → person " << personIdStr << std::endl;

        return Response(HttpStatus::OK,
            createJsonResponse(true, "Member linked successfully"));

    } catch (const std::exception& e) {
        std::cerr << "❌ Link error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to link: ") + e.what()));
    }
}

// ============================================================================
// Handler: Unlink a GroupMe user from a person
// DELETE /api/groupme/link  body: {"externalUserId":"123"}
// ============================================================================
Response GroupMeController::handleUnlinkMember(const Request& request) {
    try {
        std::string body = request.getBody();

        // Parse externalUserId
        std::string search = "\"externalUserId\":\"";
        size_t pos = body.find(search);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJsonResponse(false, "externalUserId required"));
        }
        pos += search.size();
        size_t end = body.find("\"", pos);
        std::string externalUserId = body.substr(pos, end - pos);

        // Remove the link
        db_->query(
            "DELETE FROM external_identities WHERE provider_id = 1 AND external_user_id = $1",
            {externalUserId}
        );

        // Clear person_id from RSVPs
        db_->query(
            "UPDATE chat_event_rsvps SET person_id = NULL "
            "WHERE external_user_id = $1",
            {externalUserId}
        );

        std::cout << "🔓 Unlinked GroupMe user " << externalUserId << std::endl;

        return Response(HttpStatus::OK,
            createJsonResponse(true, "Member unlinked successfully"));

    } catch (const std::exception& e) {
        std::cerr << "❌ Unlink error: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJsonResponse(false, std::string("Failed to unlink: ") + e.what()));
    }
}

// ============================================================================
// HTTP GET helper using libcurl
// ============================================================================
std::string GroupMeController::httpGet(const std::string& url) {
    CURL* curl = curl_easy_init();
    if (!curl) {
        std::cerr << "  ❌ Failed to initialize CURL" << std::endl;
        return "";
    }

    std::string responseBuffer;
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, GroupMeWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);  // 10 second timeout

    CURLcode res = curl_easy_perform(curl);
    
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        std::cerr << "  ❌ CURL error: " << curl_easy_strerror(res) << std::endl;
        return "";
    }

    if (httpCode != 200) {
        std::cerr << "  ❌ GroupMe API HTTP " << httpCode << std::endl;
        return "";
    }

    return responseBuffer;
}

// ============================================================================
// JSON Parser: Extract array of strings from JSON
// Example: "going":["123","456"] → {"123", "456"}
// ============================================================================
std::vector<std::string> GroupMeController::extractStringArray(
    const std::string& json, size_t searchFrom, size_t searchTo, const std::string& key) 
{
    std::vector<std::string> result;
    
    std::string needle = "\"" + key + "\":[";
    size_t pos = json.find(needle, searchFrom);
    if (pos == std::string::npos || pos >= searchTo) return result;
    
    pos += needle.length();
    size_t end = json.find("]", pos);
    if (end == std::string::npos || end > searchTo) return result;
    
    // Parse string values between [ and ]
    std::string arrayContent = json.substr(pos, end - pos);
    size_t i = 0;
    while (i < arrayContent.length()) {
        size_t qStart = arrayContent.find("\"", i);
        if (qStart == std::string::npos) break;
        size_t qEnd = arrayContent.find("\"", qStart + 1);
        if (qEnd == std::string::npos) break;
        result.push_back(arrayContent.substr(qStart + 1, qEnd - qStart - 1));
        i = qEnd + 1;
    }
    
    return result;
}

// ============================================================================
// JSON Parser: Extract member user_id → nickname from /groups response
// Response has "members":[{"user_id":"123","nickname":"John"}, ...]
// ============================================================================
std::map<std::string, std::string> GroupMeController::extractMemberNicknames(const std::string& json) {
    std::map<std::string, std::string> result;
    
    size_t pos = json.find("\"members\":[");
    if (pos == std::string::npos) return result;
    
    // Scan through member objects
    size_t membersEnd = json.find("]", pos);
    // Find end of members array (handle nested arrays by counting brackets)
    int bracketDepth = 0;
    size_t searchPos = json.find("[", pos);
    if (searchPos == std::string::npos) return result;
    
    for (size_t i = searchPos; i < json.length(); i++) {
        if (json[i] == '[') bracketDepth++;
        else if (json[i] == ']') {
            bracketDepth--;
            if (bracketDepth == 0) {
                membersEnd = i;
                break;
            }
        }
    }
    
    // Extract user_id and nickname pairs
    std::string membersStr = json.substr(pos, membersEnd - pos + 1);
    size_t cursor = 0;
    
    while (cursor < membersStr.length()) {
        // Find next user_id
        std::string uidNeedle = "\"user_id\":\"";
        size_t uidPos = membersStr.find(uidNeedle, cursor);
        if (uidPos == std::string::npos) break;
        
        uidPos += uidNeedle.length();
        size_t uidEnd = membersStr.find("\"", uidPos);
        if (uidEnd == std::string::npos) break;
        
        std::string userId = membersStr.substr(uidPos, uidEnd - uidPos);
        
        // Find nickname near this user_id
        std::string nickNeedle = "\"nickname\":\"";
        size_t nickPos = membersStr.find(nickNeedle, uidEnd);
        if (nickPos != std::string::npos && nickPos < uidEnd + 500) {
            nickPos += nickNeedle.length();
            size_t nickEnd = membersStr.find("\"", nickPos);
            if (nickEnd != std::string::npos) {
                std::string nickname = membersStr.substr(nickPos, nickEnd - nickPos);
                result[userId] = nickname;
            }
        }
        
        cursor = uidEnd + 1;
    }
    
    return result;
}

// ============================================================================
// JSON Parser: Extract full member data from /groups response
// Returns: vector of {userId, nickname, imageUrl}
// ============================================================================
std::vector<GroupMeMember> GroupMeController::extractFullMemberData(const std::string& json) {
    std::vector<GroupMeMember> result;
    
    size_t pos = json.find("\"members\":[");
    if (pos == std::string::npos) return result;
    
    // Find end of members array (handle nested brackets)
    int bracketDepth = 0;
    size_t membersStart = json.find("[", pos);
    size_t membersEnd = membersStart;
    if (membersStart == std::string::npos) return result;
    
    for (size_t i = membersStart; i < json.length(); i++) {
        if (json[i] == '[') bracketDepth++;
        else if (json[i] == ']') {
            bracketDepth--;
            if (bracketDepth == 0) {
                membersEnd = i;
                break;
            }
        }
    }
    
    std::string membersStr = json.substr(membersStart, membersEnd - membersStart + 1);
    
    // Find each member object by scanning for user_id
    size_t cursor = 0;
    while (cursor < membersStr.length()) {
        GroupMeMember m;
        
        // Find user_id
        std::string uidNeedle = "\"user_id\":\"";
        size_t uidPos = membersStr.find(uidNeedle, cursor);
        if (uidPos == std::string::npos) break;
        uidPos += uidNeedle.length();
        size_t uidEnd = membersStr.find("\"", uidPos);
        if (uidEnd == std::string::npos) break;
        m.userId = membersStr.substr(uidPos, uidEnd - uidPos);
        
        // Search window for other fields (within ~1000 chars)
        size_t searchLimit = std::min(uidEnd + 1000, membersStr.length());
        
        // Find nickname
        std::string nickNeedle = "\"nickname\":\"";
        size_t nickPos = membersStr.find(nickNeedle, uidEnd);
        if (nickPos != std::string::npos && nickPos < searchLimit) {
            nickPos += nickNeedle.length();
            size_t nickEnd = membersStr.find("\"", nickPos);
            if (nickEnd != std::string::npos) {
                m.nickname = membersStr.substr(nickPos, nickEnd - nickPos);
            }
        }
        
        // Find image_url
        std::string imgNeedle = "\"image_url\":\"";
        size_t imgPos = membersStr.find(imgNeedle, uidEnd);
        if (imgPos != std::string::npos && imgPos < searchLimit) {
            imgPos += imgNeedle.length();
            size_t imgEnd = membersStr.find("\"", imgPos);
            if (imgEnd != std::string::npos) {
                m.imageUrl = membersStr.substr(imgPos, imgEnd - imgPos);
            }
        }

        // Also check for null image_url
        if (m.imageUrl.empty()) {
            std::string imgNullNeedle = "\"image_url\":null";
            size_t imgNullPos = membersStr.find(imgNullNeedle, uidEnd);
            if (imgNullPos != std::string::npos && imgNullPos < searchLimit) {
                m.imageUrl = "";
            }
        }
        
        result.push_back(m);
        cursor = uidEnd + 1;
    }
    
    return result;
}

// ============================================================================
// Helpers
// ============================================================================
std::string GroupMeController::extractIdFromPath(const std::string& path, const std::string& pattern) {
    std::regex re(pattern);
    std::smatch match;
    if (std::regex_search(path, match, re) && match.size() > 1) {
        return match[1].str();
    }
    return "";
}

std::string GroupMeController::createJsonResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << escapeJson(message) << "\"";
    if (!data.empty()) {
        json << ",\"data\":" << data;
    }
    json << "}";
    return json.str();
}

std::string GroupMeController::escapeJson(const std::string& str) {
    std::string result;
    result.reserve(str.length() + 10);
    for (char c : str) {
        switch (c) {
            case '"': result += "\\\""; break;
            case '\\': result += "\\\\"; break;
            case '\n': result += "\\n"; break;
            case '\r': result += "\\r"; break;
            case '\t': result += "\\t"; break;
            default: result += c;
        }
    }
    return result;
}
