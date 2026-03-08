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
