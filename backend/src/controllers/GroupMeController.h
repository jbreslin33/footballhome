#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <string>
#include <vector>
#include <map>
#include <set>

struct GroupMeMember {
    std::string userId;
    std::string nickname;
    std::string imageUrl;
};

class GroupMeController : public Controller {
private:
    Database* db_;
    std::string accessToken_;

public:
    GroupMeController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Main handler: sync RSVPs for a specific match from GroupMe API
    Response handleSyncMatchRsvps(const Request& request);

    // Handler: sync ALL GroupMe data needed for the roster page (match + training RSVPs)
    Response handleSyncForMatch(const Request& request);

    // Handler: return all GroupMe group members with linkage info
    Response handleGetGroupMembers(const Request& request);

    // Handler: link a GroupMe user to a person
    Response handleLinkMember(const Request& request);

    // Handler: unlink a GroupMe user from a person
    Response handleUnlinkMember(const Request& request);

    // Handler: training week attendance grid (per-day columns with editable attendance)
    Response handleGetTrainingWeek(const Request& request);

    // Handler: toggle attendance for a player on a training event
    Response handleToggleAttendance(const Request& request);
    Response handleFinalizeAttendance(const Request& request);
    Response handleFinalizeBatchAttendance(const Request& request);

    // Handler: get last successful sync timestamp for a team
    Response handleGetSyncStatus(const Request& request);

    // Handler: sync GroupMe calendar events → matches + chat_events for a team
    Response handleSyncCalendar(const Request& request);

    // Handler: combined GroupMe + scrape timestamps per league for a team
    Response handleGetLeaguesSyncStatus(const Request& request);

    // Handler: get RSVP list for a specific chat event (with overrides + attendance)
    Response handleGetEventRsvps(const Request& request);

    // Handler: set or clear an RSVP override for a person on a training/chat event
    Response handleSetEventRsvpOverride(const Request& request);

    // Handler: push a new event from footballhome to a GroupMe group calendar
    Response handlePushEvent(const Request& request);

    // HTTP helpers
    std::string httpGet(const std::string& url);
    std::string httpPost(const std::string& url, const std::string& body);

    // JSON parsing helpers (targeted for GroupMe API responses)
    std::vector<std::string> extractStringArray(const std::string& json, 
                                                 size_t searchFrom, 
                                                 size_t searchTo,
                                                 const std::string& key);
    std::map<std::string, std::string> extractMemberNicknames(const std::string& json);
    std::vector<GroupMeMember> extractFullMemberData(const std::string& json);

    // Path/response helpers
    std::string extractIdFromPath(const std::string& path, const std::string& pattern);
    std::string createJsonResponse(bool success, const std::string& message, const std::string& data = "");
    std::string escapeJson(const std::string& str);
};
