#include "TrailTestController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <string>

using nlohmann::json;

namespace {

// ---------------------------------------------------------------------
// Response helpers (kept local — same shape used by other controllers).
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
// Auth — identical dual-mode gate as SimLobbyController: Bearer JWT
// (from AuthController.mint / OAuth) or fh_sess cookie (from
// MagicLinkAuthController).  Returns 0 on any failure; callers must
// respond 401.
// ---------------------------------------------------------------------

long long personIdFromLoginJwtPayload(const std::string& payloadJson) {
    // AuthController mints  "userId":"<users.id>".  Trail Test wants
    // persons.id.  users.person_id is the bridge.
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
    // 1) Bearer JWT.
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
// Small bounds — belt & braces on top of DB CHECK constraints. Guard
// against runaway path payloads (a 60s Part B at 60 fps is ~3,600
// points × ~30 bytes = ~100 KB; we cap at 512 KB per part which leaves
// generous headroom even for chaotic scribblers).
// ---------------------------------------------------------------------
constexpr std::size_t kMaxPathBytes    = 512 * 1024;
constexpr int         kMaxTimeMs       = 10 * 60 * 1000;   // 10 minutes
constexpr int         kMaxErrorsPerPart = 500;
constexpr std::size_t kMaxUserAgentLen = 512;

bool isValidVariant(const std::string& v) {
    return v == "kids" || v == "standard";
}

}  // namespace

// =====================================================================
// Wiring
// =====================================================================

TrailTestController::TrailTestController() {
    db_ = Database::getInstance();
}

void TrailTestController::registerRoutes(Router& router,
                                         const std::string& prefix) {
    router.post(prefix + "/trail-test/results", [this](const Request& r) {
        return this->handlePostResult(r);
    });
    router.post(prefix + "/trail-test/attempts", [this](const Request& r) {
        return this->handlePostAttempt(r);
    });
    router.get(prefix + "/trail-test/results", [this](const Request& r) {
        return this->handleListMine(r);
    });
}

// =====================================================================
// POST /api/tactical/trail-test/results
// =====================================================================
//
// Persists ONE complete A+B session. Rejects anything malformed;
// silently coerces path payloads to strings for JSONB storage.  Also
// writes a matching 'completed' attempts row so the funnel view
// stays consistent.
Response TrailTestController::handlePostResult(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    json body;
    try {
        body = request.getBody().empty()
             ? json::object()
             : json::parse(request.getBody());
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON body");
    }
    if (!body.is_object()) {
        return jsonError(HttpStatus::BAD_REQUEST, "expected JSON object");
    }

    // ---- Extract + validate ---------------------------------------
    const std::string variant = body.value("variant", std::string{});
    if (!isValidVariant(variant)) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "variant must be 'kids' or 'standard'");
    }

    const long long layoutSeed = body.value("layout_seed", -1LL);
    if (layoutSeed < 0) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "layout_seed must be a non-negative integer");
    }

    const int partATime = body.value("part_a_time_ms", -1);
    const int partAErr  = body.value("part_a_errors",   0);
    const int partBTime = body.value("part_b_time_ms", -1);
    const int partBErr  = body.value("part_b_errors",   0);

    if (partATime <= 0 || partATime > kMaxTimeMs
     || partBTime <= 0 || partBTime > kMaxTimeMs) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "part times must be positive ms and under 10 minutes");
    }
    if (partAErr < 0 || partAErr > kMaxErrorsPerPart
     || partBErr < 0 || partBErr > kMaxErrorsPerPart) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "error counts out of bounds");
    }

    // Paths are optional but bounded when present.
    std::string pathA = "null";
    std::string pathB = "null";
    if (body.contains("path_a") && !body["path_a"].is_null()) {
        pathA = body["path_a"].dump();
        if (pathA.size() > kMaxPathBytes) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "path_a exceeds 512 KB");
        }
    }
    if (body.contains("path_b") && !body["path_b"].is_null()) {
        pathB = body["path_b"].dump();
        if (pathB.size() > kMaxPathBytes) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "path_b exceeds 512 KB");
        }
    }

    std::string userAgent = request.getHeader("User-Agent");
    if (userAgent.size() > kMaxUserAgentLen) {
        userAgent.resize(kMaxUserAgentLen);
    }

    // ---- Persist --------------------------------------------------
    try {
        auto rows = db_->query(
            "INSERT INTO trail_test_results ("
            "    person_id, variant, layout_seed, "
            "    part_a_time_ms, part_a_errors, "
            "    part_b_time_ms, part_b_errors, "
            "    path_a, path_b, client_user_agent"
            ") VALUES ("
            "    $1::int, $2, $3::bigint, "
            "    $4::int, $5::int, "
            "    $6::int, $7::int, "
            "    $8::jsonb, $9::jsonb, $10"
            ") RETURNING id, flexibility_cost_ms, played_at",
            {
                std::to_string(personId),
                variant,
                std::to_string(layoutSeed),
                std::to_string(partATime),
                std::to_string(partAErr),
                std::to_string(partBTime),
                std::to_string(partBErr),
                pathA,
                pathB,
                userAgent,
            });

        if (rows.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "insert returned no rows");
        }

        // Twin telemetry row so trail_test_attempts always reflects
        // the funnel end-state.
        try {
            db_->query(
                "INSERT INTO trail_test_attempts ("
                "    person_id, variant, layout_seed, outcome, "
                "    client_user_agent"
                ") VALUES ($1::int, $2, $3::bigint, 'completed', $4)",
                {
                    std::to_string(personId),
                    variant,
                    std::to_string(layoutSeed),
                    userAgent,
                });
        } catch (const std::exception& e) {
            // Telemetry write failure must not fail the user-facing
            // save — log and move on.
            std::cerr << "[trail-test] attempts insert (completed) failed: "
                      << e.what() << std::endl;
        }

        const auto& r = rows[0];
        return jsonOk(json{
            {"id",                  r["id"].as<long long>()},
            {"flexibility_cost_ms", r["flexibility_cost_ms"].as<int>()},
            {"played_at",           r["played_at"].as<std::string>()},
        });

    } catch (const std::exception& e) {
        std::cerr << "[trail-test] results insert failed: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                         "database error");
    }
}

// =====================================================================
// POST /api/tactical/trail-test/attempts
// =====================================================================
//
// Fire-and-forget: records incomplete sessions so we can measure
// completion rate + where players drop out. Silently accepts anything
// well-formed; failures don't propagate to the UI.
Response TrailTestController::handlePostAttempt(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    json body;
    try {
        body = request.getBody().empty()
             ? json::object()
             : json::parse(request.getBody());
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON body");
    }
    if (!body.is_object()) {
        return jsonError(HttpStatus::BAD_REQUEST, "expected JSON object");
    }

    const std::string variant = body.value("variant", std::string{});
    if (!isValidVariant(variant)) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "variant must be 'kids' or 'standard'");
    }
    const long long layoutSeed = body.value("layout_seed", -1LL);
    if (layoutSeed < 0) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "layout_seed must be a non-negative integer");
    }
    const std::string outcome = body.value("outcome", std::string{});
    // Whitelist matches the DB CHECK constraint on trail_test_attempts.
    // (We never accept 'completed' from this endpoint — the results
    // endpoint owns that transition.)
    if (outcome != "abandoned_before_a"
     && outcome != "abandoned_in_a"
     && outcome != "abandoned_in_b"
     && outcome != "client_error") {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid outcome");
    }

    // Optional partial payload.
    std::string partialMsStr     = "";
    std::string partialErrorsStr = "";
    std::string partialPart      = "";
    if (body.contains("partial_ms") && body["partial_ms"].is_number_integer()) {
        int v = body["partial_ms"].get<int>();
        if (v > 0 && v <= kMaxTimeMs) partialMsStr = std::to_string(v);
    }
    if (body.contains("partial_errors") && body["partial_errors"].is_number_integer()) {
        int v = body["partial_errors"].get<int>();
        if (v >= 0 && v <= kMaxErrorsPerPart) partialErrorsStr = std::to_string(v);
    }
    if (body.contains("partial_part") && body["partial_part"].is_string()) {
        const std::string p = body["partial_part"].get<std::string>();
        if (p == "a" || p == "b") partialPart = p;
    }

    std::string userAgent = request.getHeader("User-Agent");
    if (userAgent.size() > kMaxUserAgentLen) userAgent.resize(kMaxUserAgentLen);

    try {
        db_->query(
            "INSERT INTO trail_test_attempts ("
            "    person_id, variant, layout_seed, outcome, "
            "    partial_ms, partial_errors, partial_part, client_user_agent"
            ") VALUES ("
            "    $1::int, $2, $3::bigint, $4, "
            "    NULLIF($5,'')::int, NULLIF($6,'')::int, NULLIF($7,''), $8"
            ")",
            {
                std::to_string(personId),
                variant,
                std::to_string(layoutSeed),
                outcome,
                partialMsStr,
                partialErrorsStr,
                partialPart,
                userAgent,
            });
    } catch (const std::exception& e) {
        std::cerr << "[trail-test] attempts insert failed: "
                  << e.what() << std::endl;
        // Still return 200 — this endpoint is best-effort telemetry.
    }

    return jsonOk(json{{"recorded", true}});
}

// =====================================================================
// GET /api/tactical/trail-test/results
// =====================================================================
//
// Caller's own history, newest first. Excludes path geometry to keep
// the payload small — a dedicated single-row endpoint can serve that
// later when we add the "review my run" screen.
Response TrailTestController::handleListMine(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    // Bounded limit — no accidental "give me every row you've ever seen".
    int limit = 20;
    if (request.hasQueryParam("limit")) {
        try {
            int v = std::stoi(request.getQueryParam("limit"));
            if (v > 0 && v <= 100) limit = v;
        } catch (...) { /* keep default */ }
    }

    try {
        auto rows = db_->query(
            "SELECT id, variant, layout_seed, "
            "       part_a_time_ms, part_a_errors, "
            "       part_b_time_ms, part_b_errors, "
            "       flexibility_cost_ms, "
            "       to_char(played_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS played_at "
            "  FROM trail_test_results "
            " WHERE person_id = $1::int "
            " ORDER BY played_at DESC "
            " LIMIT $2::int",
            {std::to_string(personId), std::to_string(limit)});

        json arr = json::array();
        for (const auto& r : rows) {
            arr.push_back({
                {"id",                  r["id"].as<long long>()},
                {"variant",             r["variant"].as<std::string>()},
                {"layout_seed",         r["layout_seed"].as<long long>()},
                {"part_a_time_ms",      r["part_a_time_ms"].as<int>()},
                {"part_a_errors",       r["part_a_errors"].as<int>()},
                {"part_b_time_ms",      r["part_b_time_ms"].as<int>()},
                {"part_b_errors",       r["part_b_errors"].as<int>()},
                {"flexibility_cost_ms", r["flexibility_cost_ms"].as<int>()},
                {"played_at",           r["played_at"].as<std::string>()},
            });
        }
        return jsonOk(json{{"results", arr}});

    } catch (const std::exception& e) {
        std::cerr << "[trail-test] list failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                         "database error");
    }
}
