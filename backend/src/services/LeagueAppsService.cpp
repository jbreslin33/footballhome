#include "LeagueAppsService.h"
#include "../core/HttpClient.h"
#include "../core/JwtRS256.h"
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <set>
#include <sstream>
#include <stdexcept>
#include <unordered_map>

using nlohmann::json;

namespace {

constexpr const char* kAuthUrl    = "https://auth.leagueapps.io/v2/auth/token";
constexpr const char* kApiBase    = "https://public.leagueapps.io/v2";
constexpr int         kMaxPages   = 50;
constexpr int         kFallbackTtlSec = 30 * 60;
constexpr int         kAssertionLifetimeSec = 300;

std::string envOr(const char* name, const char* fallback) {
    const char* v = std::getenv(name);
    return (v && *v) ? v : (fallback ? fallback : "");
}

std::string slurp(const std::string& path) {
    std::ifstream f(path);
    if (!f) throw std::runtime_error("LeagueAppsService: cannot read PEM at " + path);
    std::ostringstream ss;
    ss << f.rdbuf();
    return ss.str();
}

// Compute "extraction key" for dedup: (lastUpdated * 1e9 + id), largest wins.
long long extractionKey(const json& rec) {
    long long lu = 0, id = 0;
    if (rec.contains("lastUpdated") && rec["lastUpdated"].is_number()) {
        lu = rec["lastUpdated"].get<long long>();
    }
    if (rec.contains("id") && rec["id"].is_number()) {
        id = rec["id"].get<long long>();
    }
    return lu * 1000000000LL + id;
}

bool recDeleted(const json& rec) {
    return rec.contains("deleted") && rec["deleted"].is_boolean() && rec["deleted"].get<bool>();
}

// LA's registrationId can arrive as either a JSON number or a string.
std::string registrationIdAsString(const json& rec) {
    if (rec.contains("registrationId")) {
        const auto& v = rec["registrationId"];
        if (v.is_string()) return v.get<std::string>();
        if (v.is_number()) return std::to_string(v.get<long long>());
    }
    if (rec.contains("id")) {
        const auto& v = rec["id"];
        if (v.is_string()) return v.get<std::string>();
        if (v.is_number()) return std::to_string(v.get<long long>());
    }
    return {};
}

} // namespace

LeagueAppsService& LeagueAppsService::getInstance() {
    static LeagueAppsService instance;
    return instance;
}

LeagueAppsService::LeagueAppsService()
    : http_(std::make_unique<HttpClient>()) {}

void LeagueAppsService::ensureConfigured() {
    if (configured_) return;
    clientId_ = envOr("LEAGUEAPPS_API_PRIVATE_KEY", "");
    siteId_   = std::atoi(envOr("LEAGUEAPPS_SITE_ID", "0").c_str());
    if (clientId_.empty()) {
        // Defer the throw to getAccessToken(); just leave configured_ true
        // so we don't re-read env on every call.
        std::cerr << "[LeagueAppsService] WARNING: LEAGUEAPPS_API_PRIVATE_KEY not set"
                  << std::endl;
    }
    pemPath_ = "/app/config/" + clientId_ + ".pem";
    configured_ = true;
}

void LeagueAppsService::loadPem() {
    if (!pemCache_.empty()) return;
    if (clientId_.empty()) throw std::runtime_error("LEAGUEAPPS_API_PRIVATE_KEY not configured");
    pemCache_ = slurp(pemPath_);
}

std::string LeagueAppsService::mintAssertion() {
    // {"aud":kAuthUrl,"iss":clientId,"sub":clientId,"iat":N,"exp":N+300}
    const auto now = std::chrono::system_clock::now();
    const auto nowSec = std::chrono::duration_cast<std::chrono::seconds>(
        now.time_since_epoch()).count();
    json claims = {
        {"aud", kAuthUrl},
        {"iss", clientId_},
        {"sub", clientId_},
        {"iat", static_cast<long long>(nowSec)},
        {"exp", static_cast<long long>(nowSec + kAssertionLifetimeSec)},
    };
    return JwtRS256::sign(claims.dump(), pemCache_);
}

std::string LeagueAppsService::getAccessToken() {
    ensureConfigured();
    std::lock_guard<std::mutex> lk(tokenMutex_);

    const auto now = std::chrono::system_clock::now();
    if (!tokenCache_.empty() && tokenExpiresAt_ > now + std::chrono::seconds(60)) {
        return tokenCache_;
    }

    loadPem();
    const std::string assertion = mintAssertion();

    // application/x-www-form-urlencoded body.
    const std::string body =
        "grant_type=" + HttpClient::urlEncode("urn:ietf:params:oauth:grant-type:jwt-bearer") +
        "&assertion=" + HttpClient::urlEncode(assertion);

    const auto r = http_->postForm(kAuthUrl, body);
    if (!r.ok()) {
        throw std::runtime_error("LeagueApps token exchange failed (status="
                                 + std::to_string(r.status)
                                 + (r.error.empty() ? "" : ", " + r.error)
                                 + "): " + r.body.substr(0, 200));
    }

    json data;
    try {
        data = json::parse(r.body);
    } catch (const std::exception& e) {
        throw std::runtime_error(std::string("LeagueApps token JSON parse failed: ") + e.what());
    }
    if (!data.contains("access_token") || !data["access_token"].is_string()) {
        throw std::runtime_error("LeagueApps token response missing access_token");
    }
    tokenCache_ = data["access_token"].get<std::string>();

    int ttlSec = kFallbackTtlSec;
    if (data.contains("expires_in") && data["expires_in"].is_number()) {
        const int reported = data["expires_in"].get<int>();
        if (reported > 120) ttlSec = reported - 60;  // mirror Node's 60s buffer
    }
    tokenExpiresAt_ = std::chrono::system_clock::now() + std::chrono::seconds(ttlSec);
    return tokenCache_;
}

void LeagueAppsService::invalidateToken() {
    std::lock_guard<std::mutex> lk(tokenMutex_);
    tokenCache_.clear();
    tokenExpiresAt_ = {};
}

std::vector<nlohmann::json>
LeagueAppsService::fetchProgramRegistrations(int programId) {
    ensureConfigured();
    if (siteId_ <= 0) throw std::runtime_error("LEAGUEAPPS_SITE_ID not configured");

    std::vector<json> all;

    std::string token = getAccessToken();
    bool retriedAuth = false;

    long long lastUpdated = 0;
    long long lastId      = 0;

    for (int page = 0; page < kMaxPages; ++page) {
        std::ostringstream url;
        url << kApiBase << "/sites/" << siteId_
            << "/export/registrations-2"
            << "?last-updated=" << lastUpdated
            << "&last-id="      << lastId
            << "&program-id="   << programId;

        HttpClient::Headers headers = {{"Authorization", "Bearer " + token}};
        auto r = http_->get(url.str(), headers);

        if (r.status == 401 && !retriedAuth) {
            // Cached token rejected — refresh once and retry the same page.
            retriedAuth = true;
            invalidateToken();
            token = getAccessToken();
            --page;
            continue;
        }
        if (!r.ok()) {
            throw std::runtime_error("LeagueApps export failed (status="
                                     + std::to_string(r.status)
                                     + (r.error.empty() ? "" : ", " + r.error)
                                     + "): " + r.body.substr(0, 200));
        }

        json batch;
        try {
            batch = json::parse(r.body);
        } catch (const std::exception& e) {
            throw std::runtime_error(std::string("LeagueApps export JSON parse failed: ") + e.what());
        }
        if (!batch.is_array() || batch.empty()) break;

        for (auto& rec : batch) all.push_back(rec);

        const auto& tail = batch.back();
        lastUpdated = tail.contains("lastUpdated") && tail["lastUpdated"].is_number()
                    ? tail["lastUpdated"].get<long long>() : 0;
        lastId      = tail.contains("id") && tail["id"].is_number()
                    ? tail["id"].get<long long>() : 0;
    }

    // Dedupe by registrationId, keeping the highest (lastUpdated, id) tuple.
    std::unordered_map<std::string, std::pair<long long, json>> latest;
    for (auto& rec : all) {
        const std::string rid = registrationIdAsString(rec);
        if (rid.empty()) continue;
        const long long key = extractionKey(rec);
        auto it = latest.find(rid);
        if (it == latest.end() || key >= it->second.first) {
            latest[rid] = {key, std::move(rec)};
        }
    }

    std::vector<json> out;
    out.reserve(latest.size());
    for (auto& [rid, kv] : latest) {
        if (!recDeleted(kv.second)) out.push_back(std::move(kv.second));
    }
    return out;
}

int LeagueAppsService::getSiteId() {
    ensureConfigured();
    return siteId_;
}

LeagueAppsService::RawResponse
LeagueAppsService::rawGet(const std::string& path) {
    ensureConfigured();

    // Build URL: prepend base if the caller gave a relative path.
    std::string url;
    if (path.rfind("http://", 0) == 0 || path.rfind("https://", 0) == 0) {
        url = path;
    } else if (!path.empty() && path.front() == '/') {
        url = std::string(kApiBase) + path;
    } else {
        url = std::string(kApiBase) + "/" + path;
    }

    std::string token = getAccessToken();
    bool retriedAuth = false;

    for (int attempt = 0; attempt < 2; ++attempt) {
        HttpClient::Headers headers = {{"Authorization", "Bearer " + token}};
        auto r = http_->get(url, headers);

        if (r.status == 401 && !retriedAuth) {
            retriedAuth = true;
            invalidateToken();
            token = getAccessToken();
            continue;
        }
        RawResponse out;
        out.status = r.status;
        out.body   = r.body;
        out.error  = r.error;
        return out;
    }
    return {};
}

LeagueAppsService::TransactionFetchResult
LeagueAppsService::fetchTransactionsSince(long long cursorLastUpdatedMs,
                                          long long cursorLastId) {
    ensureConfigured();
    if (siteId_ <= 0) throw std::runtime_error("LEAGUEAPPS_SITE_ID not configured");

    TransactionFetchResult out;
    out.newLastUpdatedMs = cursorLastUpdatedMs;
    out.newLastId        = cursorLastId;

    std::string token = getAccessToken();
    bool retriedAuth = false;

    long long lastUpdated = cursorLastUpdatedMs;
    long long lastId      = cursorLastId;

    for (int page = 0; page < kMaxPages; ++page) {
        std::ostringstream url;
        url << kApiBase << "/sites/" << siteId_
            << "/export/transactions-2"
            << "?last-updated=" << lastUpdated
            << "&last-id="      << lastId;

        HttpClient::Headers headers = {{"Authorization", "Bearer " + token}};
        auto r = http_->get(url.str(), headers);

        if (r.status == 401 && !retriedAuth) {
            retriedAuth = true;
            invalidateToken();
            token = getAccessToken();
            --page;
            continue;
        }
        if (!r.ok()) {
            throw std::runtime_error("LeagueApps transactions-2 failed (status="
                                     + std::to_string(r.status)
                                     + (r.error.empty() ? "" : ", " + r.error)
                                     + "): " + r.body.substr(0, 200));
        }

        json batch;
        try {
            batch = json::parse(r.body);
        } catch (const std::exception& e) {
            throw std::runtime_error(std::string("LeagueApps transactions-2 JSON parse failed: ") + e.what());
        }
        if (!batch.is_array() || batch.empty()) break;

        for (auto& rec : batch) out.records.push_back(rec);

        const auto& tail = batch.back();
        long long newLu = tail.contains("lastUpdated") && tail["lastUpdated"].is_number()
                        ? tail["lastUpdated"].get<long long>() : 0;
        long long newId = tail.contains("id") && tail["id"].is_number()
                        ? tail["id"].get<long long>() : 0;

        // Stop if the tail didn't advance — protects against runaway loops
        // if LA ever returns a fixed page.
        if (newLu == lastUpdated && newId == lastId) break;

        lastUpdated = newLu;
        lastId      = newId;
    }

    out.newLastUpdatedMs = lastUpdated;
    out.newLastId        = lastId;
    return out;
}
