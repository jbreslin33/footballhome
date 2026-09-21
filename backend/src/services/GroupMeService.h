#pragma once
#include <chrono>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

class HttpClient;

// ────────────────────────────────────────────────────────────────────────────
// GroupMeService — read-only singleton wrapper around the public GroupMe v3
// REST API.  Feeds the GroupMe block on #my (chat_integrations rows with
// sync_messages = true, migration 392).
//
// Auth: GroupMe uses a single static access token passed as `?token=...`
// in the URL.  Read once from env (GROUPME_ACCESS_TOKEN) on first use.
//
// Every viewer of #my polls, so results are cached per group for
// kCacheSeconds — GroupMe sees at most one request a minute per group no
// matter how many players have the page open.  On a fetch failure a stale
// cached copy is served rather than an error.
// ────────────────────────────────────────────────────────────────────────────
class GroupMeService {
public:
    struct Message {
        std::string id;
        std::string name;         // sender's GroupMe nickname
        std::string text;         // may be empty (image-only post)
        std::string imageUrl;     // first image attachment, if any
        long long   createdAt = 0;  // unix seconds
        bool        isSystem = false;
    };

    static GroupMeService& getInstance();

    // Newest-first, up to `limit` (GroupMe caps at 100).
    // Throws std::runtime_error when the token is missing or the fetch
    // fails with nothing cached to fall back on.
    std::vector<Message> recentMessages(const std::string& externalGroupId, int limit = 20);

private:
    GroupMeService();
    ~GroupMeService();
    GroupMeService(const GroupMeService&) = delete;
    GroupMeService& operator=(const GroupMeService&) = delete;

    static constexpr int kCacheSeconds = 60;

    struct CacheEntry {
        std::chrono::steady_clock::time_point fetchedAt;
        std::vector<Message> messages;
    };

    std::unique_ptr<HttpClient> http_;
    std::string accessToken_;   // lazy; read from env on first call
    bool configured_ = false;
    std::mutex mutex_;
    std::map<std::string, CacheEntry> cache_;

    void ensureConfigured();
    std::vector<Message> fetchMessages(const std::string& externalGroupId, int limit);
};
