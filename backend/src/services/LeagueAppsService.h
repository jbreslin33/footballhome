#pragma once
#include <chrono>
#include <memory>
#include <mutex>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class HttpClient;

// ────────────────────────────────────────────────────────────────────────────
// LeagueAppsService — singleton wrapper around the LeagueApps public OAuth2
// + REST API.  Mints a JWT-bearer assertion (RS256) from a PEM private key
// on disk and exchanges it for an access token; caches the token until ~60s
// before LA-reported expiry.
//
// Required environment:
//   LEAGUEAPPS_API_PRIVATE_KEY   client_id (also used as the PEM filename
//                                under /app/config/<id>.pem in the container)
//   LEAGUEAPPS_SITE_ID           numeric site id for the export endpoint
//
// API surface mirrors the Node service one-to-one (see
// meta-leads-webhook/index.js `getLaAccessToken`, `fetchLaProgramRegistrations`)
// so the C++ reconciliation route can be a drop-in replacement.
// ────────────────────────────────────────────────────────────────────────────
class LeagueAppsService {
public:
    static LeagueAppsService& getInstance();

    // Returns a valid (non-expired) access token, refreshing if needed.
    // Throws std::runtime_error on missing config, PEM read failure,
    // signing failure, or non-2xx response from the LA token endpoint.
    std::string getAccessToken();

    // Drop the cached token so the next getAccessToken() forces a fresh
    // exchange.  Used after the API returns 401 on a request that used a
    // cached-but-server-side-revoked token.
    void invalidateToken();

    // Fetch every registration record for `programId`.  Handles pagination,
    // dedup (latest by registrationId + id), filters out deleted records,
    // and transparently retries once on a 401 (refreshing the token first).
    // Returns the records as JSON for downstream consumption.
    std::vector<nlohmann::json> fetchProgramRegistrations(int programId);

private:
    LeagueAppsService();
    ~LeagueAppsService() = default;
    LeagueAppsService(const LeagueAppsService&) = delete;
    LeagueAppsService& operator=(const LeagueAppsService&) = delete;

    void ensureConfigured();      // read env once
    void loadPem();               // lazy; called with mutex held
    std::string mintAssertion();  // build + sign the JWT assertion

    std::unique_ptr<HttpClient> http_;
    bool configured_ = false;
    std::string clientId_;        // env LEAGUEAPPS_API_PRIVATE_KEY
    int siteId_ = 0;              // env LEAGUEAPPS_SITE_ID
    std::string pemPath_;         // /app/config/<clientId>.pem
    std::string pemCache_;        // empty until loadPem() succeeds

    std::mutex tokenMutex_;
    std::string tokenCache_;      // empty when no valid token
    std::chrono::system_clock::time_point tokenExpiresAt_;
};
