#include "SimLobbyController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <chrono>
#include <cstdint>
#include <exception>
#include <iostream>
#include <optional>
#include <regex>
#include <string>

using nlohmann::json;

namespace {

// Sim JWTs are cheap to reissue (page reload = new one) so pick a
// generous but bounded lifetime. 8h covers a training session; if a
// match runs longer than that the client just needs to hit /join again.
constexpr std::chrono::seconds kSimJwtTtl = std::chrono::seconds(8 * 60 * 60);

// ---------------------------------------------------------------------
// Response helpers
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
// Session gate — accepts the same two shapes as MyController: Bearer
// JWT from the OAuth/password flow, or fh_sess cookie from the magic
// link flow. Bearer wins when both are present (same rationale as
// MyController: prevents cookie-bleed across users on shared devices).
// Returns 0 on any failure; caller returns 401.
// ---------------------------------------------------------------------

long long personIdFromLoginJwtPayload(const std::string& payloadJson) {
    // AuthController mints `"userId":"<users.id as string>"`. Map that
    // to persons.id — the sim daemon only ever wants person_id.
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
    // 1) Bearer JWT
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long pid = personIdFromLoginJwtPayload(payloadJson);
            if (pid > 0) return pid;
        }
    }

    // 2) fh_sess cookie
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
// Path param + JWT minting helpers
// ---------------------------------------------------------------------

// Extract the numeric matchId from a path like "/api/sim/matches/42/join".
long long extractMatchIdFromPath(const std::string& path) {
    static const std::regex re(R"(/api/sim/matches/([0-9]+)/join(?:/|$))");
    std::smatch m;
    if (std::regex_search(path, m, re)) {
        try { return std::stoll(m[1].str()); } catch (...) { return 0; }
    }
    return 0;
}

// Build the sim-side JWT payload. Claims match sim/src/auth/JwtVerifier
// expectations exactly: person_id (integer > 0), exp (integer seconds
// since epoch), iat (optional).
std::string buildSimJwtPayload(long long personId,
                               long long matchId,
                               std::chrono::seconds ttl) {
    const auto now = std::chrono::duration_cast<std::chrono::seconds>(
        std::chrono::system_clock::now().time_since_epoch()).count();
    const auto exp = now + ttl.count();
    // Include match_id as a non-verified claim for audit/replay stitching.
    // JwtVerifier ignores unknown claims so this is forward-compatible.
    json payload = {
        {"person_id", personId},
        {"match_id",  matchId},
        {"iat",       now},
        {"exp",       exp},
    };
    return payload.dump();
}

}  // namespace

// =====================================================================
// Wiring
// =====================================================================

SimLobbyController::SimLobbyController() {
    db_ = Database::getInstance();
}

void SimLobbyController::registerRoutes(Router& router,
                                        const std::string& prefix) {
    // GET  /api/sim/matches
    router.get(prefix + "/matches", [this](const Request& request) {
        return this->handleListMatches(request);
    });

    // POST /api/sim/matches
    router.post(prefix + "/matches", [this](const Request& request) {
        return this->handleCreateMatch(request);
    });

    // POST /api/sim/matches/:matchId/join
    router.post(prefix + "/matches/:matchId/join",
                [this](const Request& request) {
        return this->handleJoinMatch(request);
    });
}

// =====================================================================
// GET /api/sim/matches
// =====================================================================
//
// Lists open matches (ended_at IS NULL). No auth required — the lobby
// is intentionally readable-by-anyone so the SPA can show a "join"
// button before the user is prompted to sign in. Actual join still
// gates on a valid session.

Response SimLobbyController::handleListMatches(const Request& /*request*/) {
    try {
        auto rows = db_->query(
            "SELECT m.id, m.scenario_id, s.code_id AS scenario_code, "
            "       s.display AS scenario_display, m.seed, m.tick_hz, "
            "       m.server_version, m.visibility, "
            "       EXTRACT(EPOCH FROM m.started_at)::bigint AS started_at_s, "
            "       m.created_by "
            "  FROM sim_matches m "
            "  JOIN sim_scenarios s ON s.id = m.scenario_id "
            " WHERE m.ended_at IS NULL "
            " ORDER BY m.id ASC");

        json arr = json::array();
        for (const auto& r : rows) {
            arr.push_back({
                {"id",               r["id"].as<long long>()},
                {"scenario_id",      r["scenario_id"].as<int>()},
                {"scenario_code",    r["scenario_code"].as<std::string>()},
                {"scenario_display", r["scenario_display"].as<std::string>()},
                {"seed",             r["seed"].as<long long>()},
                {"tick_hz",          r["tick_hz"].as<int>()},
                {"server_version",   r["server_version"].as<std::string>()},
                {"visibility",       r["visibility"].as<int>()},
                {"started_at",       r["started_at_s"].as<long long>()},
                {"created_by",       r["created_by"].is_null()
                                      ? json(nullptr)
                                      : json(r["created_by"].as<long long>())},
            });
        }
        return jsonOk(json{{"matches", arr}});
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] list_matches failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }
}

// =====================================================================
// POST /api/sim/matches
// =====================================================================
//
// M0 constraint: the `footballhome_sim` container binds a single
// SIM_MATCH_ID from its env. Creating a new DB row wouldn't spawn a
// new daemon, so this endpoint is deliberately a no-op that
// idempotently returns whatever open match already exists (row
// seeded by migration 202). Once the sim gains multi-tenant support
// this handler is where we'll actually INSERT + notify a match
// scheduler.

Response SimLobbyController::handleCreateMatch(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }
    try {
        auto rows = db_->query(
            "SELECT id, scenario_id, seed, tick_hz "
            "  FROM sim_matches "
            " WHERE ended_at IS NULL "
            " ORDER BY id ASC LIMIT 1");
        if (rows.empty()) {
            return jsonError(HttpStatus::SERVICE_UNAVAILABLE,
                             "no open sim match available");
        }
        const auto& r = rows[0];
        return jsonOk(json{
            {"id",           r["id"].as<long long>()},
            {"scenario_id",  r["scenario_id"].as<int>()},
            {"seed",         r["seed"].as<long long>()},
            {"tick_hz",      r["tick_hz"].as<int>()},
            {"note",         "M0: single-daemon; POST is idempotent "
                             "(returns the running match)."},
        });
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] create_match failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }
}

// =====================================================================
// POST /api/sim/matches/:matchId/join
// =====================================================================
//
// The JWT bridge. Verifies the caller's login session, resolves their
// person_id, mints an HS256 sim JWT with the claim shape sim's
// JwtVerifier expects, and returns it alongside a WS URL the browser
// can hand straight to `new WebSocket(...)`.
//
// Returns 401 if the caller isn't signed in; 404 if the requested
// match isn't open; 400 if the matchId is missing/non-numeric.

Response SimLobbyController::handleJoinMatch(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid matchId");
    }

    try {
        auto rows = db_->query(
            "SELECT 1 FROM sim_matches "
            " WHERE id = $1::bigint AND ended_at IS NULL LIMIT 1",
            {std::to_string(matchId)});
        if (rows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "match not open");
        }
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] join lookup failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }

    // Mint the sim JWT. We use the same JWT_SECRET the sim daemon
    // reads from ./env; both processes share it via docker-compose.
    const std::string payload = buildSimJwtPayload(personId, matchId, kSimJwtTtl);
    std::string token;
    try {
        token = fh::crypto::signJwtHS256(payload);
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] sign failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "token minting failed");
    }

    // ws_url is a *relative* path so the browser can attach whatever
    // scheme+host it's currently loaded from (http→ws, https→wss).
    // The token travels via the WebSocket subprotocol header, not as
    // a URL parameter, so we DON'T bake it in here.
    return jsonOk(json{
        {"match_id",      matchId},
        {"person_id",     personId},
        {"token",         token},
        {"ws_path",       "/sim"},
        {"subprotocol",   std::string("fh-sim.v1.bearer.") + token},
        {"expires_in_s",  static_cast<long long>(kSimJwtTtl.count())},
    });
}
