#include "SimDebugController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <deque>
#include <exception>
#include <iostream>
#include <mutex>
#include <optional>
#include <regex>
#include <string>

using nlohmann::json;

namespace {

// ---------------------------------------------------------------------
// Small response helpers (kept local to match the style of every other
// controller in this tree — no dependency on Controller::jsonResponse
// so the {"error":"..."} shape stays consistent with SimLobbyController).
// ---------------------------------------------------------------------

Response jsonError(HttpStatus s, const std::string& msg) {
    json body = {{"error", msg}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonOk(const json& body) {
    Response r(HttpStatus::OK, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

// ---------------------------------------------------------------------
// Login JWT → persons.id — same shape as SimLobbyController's helper.
// Duplicated intentionally: making a shared helper would pull two
// controllers into a header dependency for three lines of code, and
// the sim lobby's version might diverge if the login token shape ever
// changes for the sim path.
// ---------------------------------------------------------------------

long long personIdFromLoginJwtPayload(const std::string& payloadJson) {
    const std::string needle = "\"userId\":\"";
    auto pos = payloadJson.find(needle);
    if (pos == std::string::npos) return 0;
    pos += needle.size();
    auto end = payloadJson.find('"', pos);
    if (end == std::string::npos) return 0;
    const std::string userIdStr = payloadJson.substr(pos, end - pos);
    if (userIdStr.empty()) return 0;
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT person_id FROM users WHERE id = $1::int LIMIT 1",
            {userIdStr});
        if (r.empty() || r[0]["person_id"].is_null()) return 0;
        return r[0]["person_id"].as<long long>();
    } catch (...) {
        return 0;
    }
}

long long resolveCallerPersonId(const Request& request) {
    // 1) Bearer login JWT.
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long pid = personIdFromLoginJwtPayload(payloadJson);
            if (pid > 0) return pid;
        }
    }
    // 2) fh_sess cookie.
    const std::string cookie = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    if (!sessVal.empty()) {
        auto resolved = SessionService::getInstance().requireSession(sessVal);
        if (resolved && resolved->personId > 0) return resolved->personId;
    }
    return 0;
}

// ---------------------------------------------------------------------
// Path param + query param helpers.
// ---------------------------------------------------------------------

// Pulls the numeric matchId out of a path like
// "/api/sim/debug/matches/42/inputs" or ".../events" or ".../state".
long long extractMatchIdFromPath(const std::string& path) {
    static const std::regex re(
        R"(/api/sim/debug/matches/([0-9]+)/(?:inputs|events|state)(?:/|$|\?))");
    std::smatch m;
    if (std::regex_search(path, m, re)) {
        try { return std::stoll(m[1].str()); } catch (...) { return 0; }
    }
    return 0;
}

// Parse a non-negative integer query param; returns `fallback` on
// missing / malformed / out-of-range input.
long long qparamInt(const Request& request,
                    const std::string& name,
                    long long fallback) {
    const std::string s = request.getQueryParam(name);
    if (s.empty()) return fallback;
    try {
        const long long v = std::stoll(s);
        return v < 0 ? fallback : v;
    } catch (...) {
        return fallback;
    }
}

// ---------------------------------------------------------------------
// Row limits + tick defaults.
//
// If `from_tick` is unset it defaults to 0; if `to_tick` is unset it
// defaults to 2^31 - 1 (~24 days at 20 Hz — no realistic match
// touches it). `limit` clamps to [1, 1000] with default 500.
// ---------------------------------------------------------------------

constexpr int kMaxLimit     = 1000;
constexpr int kDefaultLimit = 500;
constexpr long long kMaxTick = 2147483647LL;   // int4 upper bound (tick_num column)

int clampLimit(long long raw) {
    if (raw <= 0)         return kDefaultLimit;
    if (raw > kMaxLimit)  return kMaxLimit;
    return static_cast<int>(raw);
}

// ---------------------------------------------------------------------
// FH_ENABLE_SIM_DEBUG — read once at construction.
//
// Treated as truthy for "1", "true", "yes", "on" (case-insensitive).
// Anything else including missing → false. Prod stays clean because
// the env var is unset by default in every non-dev environment.
// ---------------------------------------------------------------------

bool readEnableFlag() {
    const char* v = std::getenv("FH_ENABLE_SIM_DEBUG");
    if (!v || !*v) return false;
    std::string s(v);
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return std::tolower(c); });
    return s == "1" || s == "true" || s == "yes" || s == "on";
}

}  // namespace

// =====================================================================
// Wiring
// =====================================================================

SimDebugController::SimDebugController()
    : db_(Database::getInstance()),
      enabled_(readEnableFlag()) {}

void SimDebugController::registerRoutes(Router& router,
                                        const std::string& prefix) {
    if (!enabled_) {
        std::cout << "[sim-debug] endpoints DISABLED "
                     "(set FH_ENABLE_SIM_DEBUG=1 to enable)"
                  << std::endl;
        return;
    }

    std::cout << "[sim-debug] endpoints ENABLED under " << prefix
              << " (admin-only, rate-limited " << kRateCap << " req/"
              << kRateWindow.count() << "s per admin)"
              << std::endl;

    router.get(prefix + "/matches/:matchId/inputs",
               [this](const Request& r) { return this->handleInputs(r); });
    router.get(prefix + "/matches/:matchId/events",
               [this](const Request& r) { return this->handleEvents(r); });
    router.get(prefix + "/matches/:matchId/state",
               [this](const Request& r) { return this->handleState(r); });
}

// =====================================================================
// Rate limiter (sliding-window, in-memory, per person_id).
// =====================================================================

bool SimDebugController::allowRequest(long long personId) {
    if (personId <= 0) return true;   // caller not yet admin-checked; let
                                       // the admin check reject them.
    const auto now = std::chrono::steady_clock::now();
    const auto cutoff = now - kRateWindow;

    std::lock_guard<std::mutex> lock(rate_mu_);
    auto& bucket = rate_buckets_[personId];
    while (!bucket.empty() && bucket.front() < cutoff) {
        bucket.pop_front();
    }
    if (static_cast<int>(bucket.size()) >= kRateCap) {
        return false;
    }
    bucket.push_back(now);
    return true;
}

// =====================================================================
// Admin gate.
//
// Returns:
//    0  → not signed in (respond 401)
//   -1  → signed in but not an admin (respond 403)
//   >0  → admin, returns the caller's person_id
//
// Matches MyController's admin check: JOINs `admins` × `users` on
// user_id, filters by person_id. No caching — the volume is 10/min per
// admin and the query is a single indexed row lookup.
// =====================================================================

long long SimDebugController::resolveAdminPersonId(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) return 0;

    try {
        auto r = db_->query(
            "SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (r.empty()) return -1;
    } catch (const std::exception& e) {
        std::cerr << "[sim-debug] admin lookup failed: " << e.what() << std::endl;
        return -1;   // treat as forbidden on DB error; safer than 500ing.
    }
    return personId;
}

// =====================================================================
// GET /api/sim/debug/matches/:id/inputs?from_tick=N&to_tick=M&limit=L
// =====================================================================

Response SimDebugController::handleInputs(const Request& request) {
    const long long adminPid = resolveAdminPersonId(request);
    if (adminPid == 0)  return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    if (adminPid == -1) return jsonError(HttpStatus::FORBIDDEN, "admin only");

    if (!allowRequest(adminPid)) {
        return jsonError(HttpStatus::TOO_MANY_REQUESTS,
                          "rate limit exceeded (10/min per admin)");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid matchId");
    }

    const long long fromTick = qparamInt(request, "from_tick", 0);
    const long long toTick   = qparamInt(request, "to_tick",   kMaxTick);
    const int       limit    = clampLimit(qparamInt(request, "limit", kDefaultLimit));

    if (toTick < fromTick) {
        return jsonError(HttpStatus::BAD_REQUEST,
                          "to_tick must be >= from_tick");
    }

    try {
        auto rows = db_->query(
            "SELECT tick_num, "
            "       slot_id, "
            "       encode(payload, 'hex') AS payload_hex, "
            "       sim_decode_input(payload)::text AS decoded "
            "  FROM sim_match_inputs "
            " WHERE match_id  = $1::bigint "
            "   AND tick_num >= $2::int "
            "   AND tick_num <= $3::int "
            " ORDER BY tick_num ASC, slot_id ASC "
            " LIMIT $4::int",
            {std::to_string(matchId),
             std::to_string(fromTick),
             std::to_string(toTick),
             std::to_string(limit)});

        json arr = json::array();
        for (const auto& r : rows) {
            json entry = {
                {"tick_num",    r["tick_num"].as<long long>()},
                {"slot_id",     r["slot_id"].as<int>()},
                {"payload_hex", r["payload_hex"].as<std::string>()},
            };
            // The DB round-trips jsonb through ::text so we get a JSON
            // string here that we re-parse into an inline object.
            try {
                entry["decoded"] = json::parse(r["decoded"].as<std::string>());
            } catch (...) {
                entry["decoded"] = nullptr;
            }
            arr.push_back(std::move(entry));
        }

        return jsonOk(json{
            {"match_id",  matchId},
            {"from_tick", fromTick},
            {"to_tick",   toTick == kMaxTick ? json(nullptr) : json(toTick)},
            {"limit",     limit},
            {"count",     arr.size()},
            {"rows",      std::move(arr)},
        });
    } catch (const std::exception& e) {
        std::cerr << "[sim-debug] inputs query failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }
}

// =====================================================================
// GET /api/sim/debug/matches/:id/events?from_tick=N&to_tick=M&limit=L
// =====================================================================

Response SimDebugController::handleEvents(const Request& request) {
    const long long adminPid = resolveAdminPersonId(request);
    if (adminPid == 0)  return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    if (adminPid == -1) return jsonError(HttpStatus::FORBIDDEN, "admin only");

    if (!allowRequest(adminPid)) {
        return jsonError(HttpStatus::TOO_MANY_REQUESTS,
                          "rate limit exceeded (10/min per admin)");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid matchId");
    }

    const long long fromTick = qparamInt(request, "from_tick", 0);
    const long long toTick   = qparamInt(request, "to_tick",   kMaxTick);
    const int       limit    = clampLimit(qparamInt(request, "limit", kDefaultLimit));

    if (toTick < fromTick) {
        return jsonError(HttpStatus::BAD_REQUEST,
                          "to_tick must be >= from_tick");
    }

    try {
        auto rows = db_->query(
            "SELECT id, "
            "       tick_num, "
            "       event_type, "
            "       sim_event_type_name(event_type) AS event_type_name, "
            "       CASE WHEN payload IS NULL THEN NULL "
            "            ELSE encode(payload, 'hex') END AS payload_hex, "
            "       sim_decode_event(event_type, payload)::text AS decoded "
            "  FROM sim_match_events "
            " WHERE match_id  = $1::bigint "
            "   AND tick_num >= $2::int "
            "   AND tick_num <= $3::int "
            " ORDER BY id ASC "
            " LIMIT $4::int",
            {std::to_string(matchId),
             std::to_string(fromTick),
             std::to_string(toTick),
             std::to_string(limit)});

        json arr = json::array();
        for (const auto& r : rows) {
            json entry = {
                {"id",             r["id"].as<long long>()},
                {"tick_num",       r["tick_num"].as<long long>()},
                {"event_type",     r["event_type"].as<int>()},
                {"event_type_name", r["event_type_name"].is_null()
                                     ? json(nullptr)
                                     : json(r["event_type_name"].as<std::string>())},
                {"payload_hex",    r["payload_hex"].is_null()
                                     ? json(nullptr)
                                     : json(r["payload_hex"].as<std::string>())},
            };
            try {
                entry["decoded"] = json::parse(r["decoded"].as<std::string>());
            } catch (...) {
                entry["decoded"] = nullptr;
            }
            arr.push_back(std::move(entry));
        }

        return jsonOk(json{
            {"match_id",  matchId},
            {"from_tick", fromTick},
            {"to_tick",   toTick == kMaxTick ? json(nullptr) : json(toTick)},
            {"limit",     limit},
            {"count",     arr.size()},
            {"rows",      std::move(arr)},
        });
    } catch (const std::exception& e) {
        std::cerr << "[sim-debug] events query failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }
}

// =====================================================================
// GET /api/sim/debug/matches/:id/state?tick=T
//
// Not implemented in this sub-slice. The DESIGN spec calls for
// spawning `fh-sim-replay --match-id N --up-to-tick T --emit-hex
// --emit-json-snapshot` in a sandboxed subprocess, but the binary is
// only present in the `footballhome_sim` container image (see
// sim/Dockerfile) — the backend container has no way to invoke it
// today. Two follow-ups will unblock this (sub-slice 8.1):
//
//   (a) bundle fh-sim-replay into the backend image alongside its
//       runtime deps (libpqxx, libc++), OR
//   (b) expose a debug replay endpoint on the sim daemon itself
//       (localhost socket, HS256-signed request from the backend),
//       and have the backend proxy through to it.
//
// Path (b) is preferred because it keeps binaries owned by whichever
// container ships them, but it's non-trivial. Returning 501 here so
// the endpoint is visible in the router surface without silently
// returning garbage.
// =====================================================================

Response SimDebugController::handleState(const Request& request) {
    const long long adminPid = resolveAdminPersonId(request);
    if (adminPid == 0)  return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    if (adminPid == -1) return jsonError(HttpStatus::FORBIDDEN, "admin only");

    if (!allowRequest(adminPid)) {
        return jsonError(HttpStatus::TOO_MANY_REQUESTS,
                          "rate limit exceeded (10/min per admin)");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid matchId");
    }
    // Read the tick so we surface it in the diagnostic body even though
    // we can't act on it yet.
    const long long tick = qparamInt(request, "tick", -1);

    json body = {
        {"error",          "not implemented"},
        {"match_id",       matchId},
        {"tick",           tick < 0 ? json(nullptr) : json(tick)},
        {"reason",         "fh-sim-replay lives in footballhome_sim, not "
                           "footballhome_backend — cross-container spawn "
                           "deferred to sub-slice 8.1"},
        {"workaround",     "run manually inside the sim container: "
                           "`sudo podman exec footballhome_sim "
                           "fh-sim-replay --match-id N --up-to-tick T --emit-hex`"},
    };
    Response r(HttpStatus::NOT_IMPLEMENTED, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
