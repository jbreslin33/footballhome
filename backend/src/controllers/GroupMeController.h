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

    // Handler: return all GroupMe group members with linkage info
    Response handleGetGroupMembers(const Request& request);

    // Handler: link a GroupMe user to a person
    Response handleLinkMember(const Request& request);

    // Handler: unlink a GroupMe user from a person
    Response handleUnlinkMember(const Request& request);

    // HTTP helpers
    std::string httpGet(const std::string& url);

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
