#pragma once
#include <memory>
#include <string>
#include <vector>

class HttpClient;

// ────────────────────────────────────────────────────────────────────────────
// GroupMeService — minimal singleton wrapper around the public GroupMe v3
// REST API.  Used during team-reconciliation refreshes to read live
// membership for a single group.
//
// SOURCE-OF-TRUTH RULE: callers that join against `chat_external_members`
// MUST call `fetchGroup` for the corresponding GroupMe id BEFORE running
// the join, otherwise leavers will haunt the lineup as phantom "gmOnly"
// players.  (Same invariant the Node implementation has.)
//
// Auth: GroupMe uses a single static access token passed as `?token=...`
// in the URL.  Read once from env (GROUPME_ACCESS_TOKEN) on first use.
// ────────────────────────────────────────────────────────────────────────────
class GroupMeService {
public:
    struct Member {
        std::string userId;       // GroupMe user_id (string)
        std::string nickname;     // empty if GroupMe omitted it
        std::string imageUrl;     // empty if no avatar
    };

    struct Group {
        std::string name;                 // group display name
        std::vector<Member> members;      // never null; may be empty
    };

    static GroupMeService& getInstance();

    // Fetch one group's metadata + member list.
    // Throws std::runtime_error when:
    //   - GROUPME_ACCESS_TOKEN is not configured
    //   - transport / TLS failure
    //   - non-2xx HTTP response (the message includes status + truncated body)
    //   - the response body lacks the expected `response` envelope
    Group fetchGroup(const std::string& externalGroupId);

private:
    GroupMeService();
    ~GroupMeService() = default;
    GroupMeService(const GroupMeService&) = delete;
    GroupMeService& operator=(const GroupMeService&) = delete;

    std::unique_ptr<HttpClient> http_;
    std::string accessToken_;   // lazy; read from env on first call
    bool configured_ = false;

    void ensureConfigured();
};
