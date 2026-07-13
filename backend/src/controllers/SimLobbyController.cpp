#include "SimLobbyController.h"

#include "../core/Crypto.h"
#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../models/SimRunningMatch.h"
#include "../orchestration/SimOrchestrator.h"
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

// Extract the numeric matchId from a path like
// "/api/sim/matches/42/join" or ".../42/stop". Suffix is matched
// against a fixed set so a typo (e.g. "/joinn") returns 0 rather
// than silently succeeding with the wrong matchId.
long long extractMatchIdFromPath(const std::string& path) {
    static const std::regex re(
        R"(/api/sim/matches/([0-9]+)/(?:join|stop)(?:/|$))");
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

    // POST /api/sim/matches/:matchId/stop  (Slice 14.5)
    router.post(prefix + "/matches/:matchId/stop",
                [this](const Request& request) {
        return this->handleStopMatch(request);
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
// Slice 14.3 of M1 (sim/DESIGN.md §23.3): spawn a fresh per-match sim
// daemon container.
//
// Steps:
//   1. Auth caller (Bearer JWT or fh_sess cookie).
//   2. Parse body — {scenario_id?, seed?, tick_hz?}. All optional;
//      defaults match the M0 empty_pitch match seeded by migration 202
//      so the SPA can POST an empty body and still get a usable match.
//   3. INSERT sim_matches → new match_id.
//   4. INSERT sim_running_matches (match_id, container_name, container_id=NULL)
//      BEFORE calling podman so a mid-launch backend crash still
//      leaves a reconcilable audit trail (DESIGN §16.7 step 9).
//   5. Call SimOrchestrator::launchMatch — POST /containers/create +
//      /containers/${id}/start against the mounted podman socket.
//   6. On success: UPDATE sim_running_matches SET container_id.
//   7. On any failure past step 3: DELETE both rows and return 5xx.
//      No half-committed state left in either table.
//
// When FH_SIM_ORCHESTRATOR_ENABLED is unset/0 we fall back to the M0
// no-op stub — returns the pre-seeded match_id=1 idempotently so
// existing frontends keep working on hosts that haven't opted into the
// per-match orchestration yet. This makes 14.3 safe to deploy without
// a lockstep frontend rollout.
//
// Returns:
//   200 {id, scenario_id, seed, tick_hz, ws_url, container_name}
//   401 sign in required
//   400 invalid body
//   500 database error
//   502 orchestrator/podman error
//   503 orchestrator disabled AND no fallback match seeded (should
//       never happen in a healthy deploy — migration 202 seeds one)

namespace {

// The wire URL a browser hands to `new WebSocket(...)`. Slice 14.5
// pairs this with an nginx regex block that routes `/sim/${id}` to
// `footballhome_sim_${id}:9100/sim`. Until 14.5 lands, the URL is
// still returned (so the API shape is stable) — clients that follow
// it before 14.5 ships will just fail to route, which is the same
// user-visible outcome as before 14.3.
std::string buildWsUrl(long long match_id) {
    return "/sim/" + std::to_string(match_id);
}

// Backend-side placeholder for sim_matches.server_version. The sim
// binary knows its own git-describe (baked in via FH_SIM_GIT_DESCRIBE
// at image build time — see sim/DESIGN.md §16.6 task 7) but the
// backend doesn't have that string in-process today. Writing a
// placeholder is safe because server_version is metadata-only per
// §10 rule 7 — it doesn't participate in any determinism gate. If
// replay-compatibility guarantees later require the exact sha, the
// sim's own admin endpoint can UPDATE this column after startup.
constexpr const char* kServerVersionPlaceholder = "backend-launched";

} // namespace

Response SimLobbyController::handleCreateMatch(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    // -----------------------------------------------------------------
    // 1) Parse body. Empty body OK — every field has a sensible default
    //    matching migration 202's seed row (scenario_id=0 empty_pitch,
    //    seed=42, tick_hz=20).
    // -----------------------------------------------------------------
    int         scenario_id = 0;       // empty_pitch (sim_scenarios.id)
    long long   seed        = 42;
    int         tick_hz     = 20;
    if (!request.getBody().empty()) {
        try {
            auto j = json::parse(request.getBody());
            if (j.contains("scenario_id") && j["scenario_id"].is_number_integer()) {
                scenario_id = j["scenario_id"].get<int>();
            }
            if (j.contains("seed") && j["seed"].is_number_integer()) {
                seed = j["seed"].get<long long>();
            }
            if (j.contains("tick_hz") && j["tick_hz"].is_number_integer()) {
                tick_hz = j["tick_hz"].get<int>();
            }
        } catch (const std::exception& e) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             std::string("invalid JSON body: ") + e.what());
        }
    }
    if (scenario_id < 0 || tick_hz <= 0 || tick_hz > 240) {
        return jsonError(HttpStatus::BAD_REQUEST,
                         "scenario_id/tick_hz out of range");
    }

    // -----------------------------------------------------------------
    // 2) Orchestrator feature-flag gate. When disabled we fall back to
    //    the M0 idempotent no-op so hosts that haven't opted into
    //    multi-match orchestration keep serving the seeded match.
    // -----------------------------------------------------------------
    fh::orchestration::SimOrchestratorConfig cfg =
        fh::orchestration::loadConfigFromEnv();
    if (!cfg.enabled) {
        try {
            auto rows = db_->query(
                "SELECT id, scenario_id, seed, tick_hz "
                "  FROM sim_matches "
                " WHERE ended_at IS NULL "
                " ORDER BY id ASC LIMIT 1");
            if (rows.empty()) {
                return jsonError(HttpStatus::SERVICE_UNAVAILABLE,
                                 "orchestrator disabled and no seeded match");
            }
            const auto& r = rows[0];
            const long long existingMatchId = r["id"].as<long long>();
            // Legacy ws path — the M0 seed match is served by the
            // docker-compose `footballhome_sim` container (no _{id}
            // suffix), reachable only via nginx's exact-match
            // `location = /sim` block. NOT /sim/${id}, which routes
            // through the regex block to footballhome_sim_${id} —
            // that hostname doesn't exist for the M0 seed.
            return jsonOk(json{
                {"id",           existingMatchId},
                {"scenario_id",  r["scenario_id"].as<int>()},
                {"seed",         r["seed"].as<long long>()},
                {"tick_hz",      r["tick_hz"].as<int>()},
                {"ws_url",       std::string("/sim")},
                {"note",         "orchestrator disabled — returned seeded match"},
            });
        } catch (const std::exception& e) {
            std::cerr << "[sim-lobby] create_match (fallback) failed: "
                      << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
        }
    }

    // -----------------------------------------------------------------
    // 3) INSERT sim_matches. RETURNING gives us the new match_id.
    // -----------------------------------------------------------------
    long long match_id = 0;
    try {
        auto rows = db_->query(
            "INSERT INTO sim_matches "
            "  (scenario_id, seed, tick_hz, server_version, created_by, "
            "   visibility) "
            "VALUES ($1::smallint, $2::bigint, $3::smallint, $4, "
            "        $5::integer, 0) "
            "RETURNING id",
            {std::to_string(scenario_id),
             std::to_string(seed),
             std::to_string(tick_hz),
             kServerVersionPlaceholder,
             std::to_string(personId)});
        if (rows.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                             "sim_matches insert returned no id");
        }
        match_id = rows[0]["id"].as<long long>();
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] create_match INSERT sim_matches failed: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                         "sim_matches insert failed");
    }

    const std::string container_name =
        fh::orchestration::containerNameFor(match_id);

    // -----------------------------------------------------------------
    // 4) INSERT sim_running_matches (pending row, no container_id yet).
    //    If this fails we roll back the sim_matches row.
    // -----------------------------------------------------------------
    if (!fh::orchestration::SimRunningMatchRepo::insertPending(
            match_id, container_name)) {
        // Rollback sim_matches — best-effort. Failure here logs and
        // moves on; a leftover sim_matches row with no companion
        // sim_running_matches row is inert (nothing reads it).
        try {
            db_->query("DELETE FROM sim_matches WHERE id = $1::bigint",
                       {std::to_string(match_id)});
        } catch (...) {}
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                         "sim_running_matches insert failed");
    }

    // -----------------------------------------------------------------
    // 5) Actually launch the container. HttpClient is stateless-per-
    //    call so a fresh instance here matches how every other
    //    outbound-HTTP path in this codebase looks.
    // -----------------------------------------------------------------
    HttpClient http;
    fh::orchestration::SimOrchestrator orchestrator(cfg, http);
    fh::orchestration::LaunchOptions opts;
    opts.match_id = match_id;
    opts.seed     = seed;
    fh::orchestration::LaunchResult launch = orchestrator.launchMatch(opts);

    if (!launch.ok) {
        std::cerr << "[sim-lobby] launchMatch(match_id=" << match_id
                  << ") failed: " << launch.error << std::endl;
        // Roll back BOTH rows so a retry with a new match_id has a
        // clean slate.
        fh::orchestration::SimRunningMatchRepo::deleteFor(match_id);
        try {
            db_->query("DELETE FROM sim_matches WHERE id = $1::bigint",
                       {std::to_string(match_id)});
        } catch (...) {}
        return jsonError(HttpStatus::BAD_GATEWAY,
                         "podman launch failed: " + launch.error);
    }

    // -----------------------------------------------------------------
    // 6) Fill in container_id. If this UPDATE fails somehow (row was
    //    reaped mid-launch), we DO NOT roll back the container — it's
    //    already running and serving traffic. Log and move on; the
    //    Slice 14.6 reaper will handle the row-vs-container mismatch.
    // -----------------------------------------------------------------
    (void)fh::orchestration::SimRunningMatchRepo::setContainerId(
        match_id, launch.container_id);

    std::cout << "[sim-lobby] launched match_id=" << match_id
              << " container=" << launch.container_name
              << " id=" << launch.container_id.substr(0, 12) << std::endl;

    return jsonOk(json{
        {"id",             match_id},
        {"scenario_id",    scenario_id},
        {"seed",           seed},
        {"tick_hz",        tick_hz},
        {"ws_url",         buildWsUrl(match_id)},
        {"container_name", launch.container_name},
    });
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

    // ws_path discrimination (Slice 14.4):
    //   * Orchestrator-launched matches have a `sim_running_matches`
    //     row → ws_path = "/sim/${match_id}" (nginx regex block routes
    //     to footballhome_sim_${match_id}:9100).
    //   * The pre-seeded M0 match (docker-compose service
    //     `footballhome_sim`, migration 202 seed) has NO row → ws_path
    //     = "/sim" (nginx exact-match block routes to
    //     footballhome_sim:9100).
    // Presence of a row is the ONLY discriminator — do NOT special-
    // case on match_id == 1, because a future rebuild could reseed at
    // a different id.
    std::string ws_path = "/sim";
    try {
        auto rows = db_->query(
            "SELECT 1 FROM sim_running_matches WHERE match_id = $1::bigint LIMIT 1",
            {std::to_string(matchId)});
        if (!rows.empty()) {
            ws_path = "/sim/" + std::to_string(matchId);
        }
    } catch (const std::exception& e) {
        // Non-fatal: fall back to legacy path. Log so ops sees it.
        std::cerr << "[sim-lobby] join ws_path lookup failed: "
                  << e.what() << " (falling back to /sim)" << std::endl;
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

    // ws_path is a *relative* path so the browser can attach whatever
    // scheme+host it's currently loaded from (http→ws, https→wss).
    // The token travels via the WebSocket subprotocol header, not as
    // a URL parameter, so we DON'T bake it in here.
    return jsonOk(json{
        {"match_id",      matchId},
        {"person_id",     personId},
        {"token",         token},
        {"ws_path",       ws_path},
        {"subprotocol",   std::string("fh-sim.v1.bearer.") + token},
        {"expires_in_s",  static_cast<long long>(kSimJwtTtl.count())},
    });
}

// =====================================================================
// POST /api/sim/matches/:matchId/stop
// =====================================================================
//
// Slice 14.5 — stop + reap an orchestrator-launched per-match sim
// daemon container.
//
// Steps:
//   1. Auth: caller must be the match creator (sim_matches.created_by
//      == personId). No admin bypass in this slice — that lands with
//      the operator/admin surface in a later slice. If the row's
//      created_by is NULL (M0 legacy seed from migration 202), no one
//      is authorized: return 403.
//   2. Validate the match has a running-container row. No row =
//      nothing to stop; return 404 rather than a confusing 200 —
//      caller almost certainly has a stale UI.
//   3. SimOrchestrator::stopMatch — SIGTERM (5s grace) → DELETE via
//      podman REST API. Idempotent: already-gone containers count as
//      success (see SimOrchestrator::stopMatch header for details).
//   4. On stop success: UPDATE sim_matches SET ended_at = NOW() and
//      DELETE from sim_running_matches. Both under the same "everything
//      after step 3 is bookkeeping" umbrella — failure to update
//      ended_at is logged but doesn't fail the response because the
//      container is already gone from the container-runtime's PoV.
//
// Feature-flag gate: when FH_SIM_ORCHESTRATOR_ENABLED is unset/0 the
// handler returns 503 rather than silently succeeding — an operator
// stopping a match wants confirmation the daemon is actually gone.
//
// Idempotency contract: calling stop twice on the same match returns
// 200 both times (the second time is effectively a no-op because
// sim_running_matches has no row). This matches the "stop is safe to
// retry" expectation from UIs.

Response SimLobbyController::handleStopMatch(const Request& request) {
    const long long personId = resolveCallerPersonId(request);
    if (personId <= 0) {
        return jsonError(HttpStatus::UNAUTHORIZED, "sign in required");
    }

    const long long matchId = extractMatchIdFromPath(request.getPath());
    if (matchId <= 0) {
        return jsonError(HttpStatus::BAD_REQUEST, "invalid matchId");
    }

    // -----------------------------------------------------------------
    // 1) Ownership check. `created_by` NULL → no one owns it (M0 seed).
    // -----------------------------------------------------------------
    std::optional<long long> createdBy;
    bool alreadyEnded = false;
    try {
        auto rows = db_->query(
            "SELECT created_by, ended_at FROM sim_matches WHERE id = $1::bigint",
            {std::to_string(matchId)});
        if (rows.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "match not found");
        }
        if (!rows[0]["created_by"].is_null()) {
            createdBy = rows[0]["created_by"].as<long long>();
        }
        alreadyEnded = !rows[0]["ended_at"].is_null();
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] stop lookup failed: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }
    if (!createdBy.has_value() || *createdBy != personId) {
        return jsonError(HttpStatus::FORBIDDEN,
                         "only the match creator can stop this match");
    }

    // -----------------------------------------------------------------
    // 2) Feature-flag gate + running-row lookup.
    // -----------------------------------------------------------------
    fh::orchestration::SimOrchestratorConfig cfg =
        fh::orchestration::loadConfigFromEnv();
    if (!cfg.enabled) {
        return jsonError(HttpStatus::SERVICE_UNAVAILABLE,
                         "orchestrator disabled");
    }

    std::string containerId;
    std::string containerName;
    try {
        auto rows = db_->query(
            "SELECT container_id, container_name FROM sim_running_matches "
            " WHERE match_id = $1::bigint",
            {std::to_string(matchId)});
        if (rows.empty()) {
            // No running-row → nothing to reap. If the match was
            // already ended this is the idempotent second-call case;
            // otherwise the container is missing for some other reason
            // (crashed + reaper swept it, orchestrator disabled at
            // launch time, ...). Either way, respond 200 with a note.
            return jsonOk(json{
                {"match_id",      matchId},
                {"stopped",       false},
                {"already_gone",  true},
                {"note",          alreadyEnded
                                    ? "match already ended"
                                    : "no running container row (nothing to reap)"},
            });
        }
        if (!rows[0]["container_id"].is_null()) {
            containerId = rows[0]["container_id"].as<std::string>();
        }
        containerName = rows[0]["container_name"].as<std::string>();
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] stop running-row lookup failed: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "database error");
    }

    // -----------------------------------------------------------------
    // 3) Stop + delete via podman.
    // -----------------------------------------------------------------
    fh::orchestration::StopResult stopResult;
    if (containerId.empty()) {
        // Row exists but container_id was never filled in — the launch
        // must have crashed between insertPending and setContainerId.
        // We have no id to stop; just clear the DB row. This matches
        // the reaper's fallback behavior planned for Slice 14.6.
        stopResult.ok = true;
        stopResult.already_gone = true;
    } else {
        HttpClient http;
        fh::orchestration::SimOrchestrator orchestrator(cfg, http);
        fh::orchestration::StopOptions opts;
        opts.container_id  = containerId;
        opts.grace_seconds = 5;
        stopResult = orchestrator.stopMatch(opts);
    }

    if (!stopResult.ok) {
        std::cerr << "[sim-lobby] stopMatch(match_id=" << matchId
                  << ", container=" << containerName
                  << ") failed: " << stopResult.error << std::endl;
        return jsonError(HttpStatus::BAD_GATEWAY,
                         "podman stop failed: " + stopResult.error);
    }

    // -----------------------------------------------------------------
    // 4) Bookkeeping. Both updates are best-effort — the container is
    //    already gone, so a DB blip shouldn't make the caller retry.
    // -----------------------------------------------------------------
    try {
        db_->query(
            "UPDATE sim_matches SET ended_at = NOW() "
            " WHERE id = $1::bigint AND ended_at IS NULL",
            {std::to_string(matchId)});
    } catch (const std::exception& e) {
        std::cerr << "[sim-lobby] stop UPDATE sim_matches.ended_at failed: "
                  << e.what() << std::endl;
    }
    (void)fh::orchestration::SimRunningMatchRepo::deleteFor(matchId);

    std::cout << "[sim-lobby] stopped match_id=" << matchId
              << " container=" << containerName
              << (stopResult.already_gone ? " (already gone)" : "")
              << std::endl;

    return jsonOk(json{
        {"match_id",      matchId},
        {"stopped",       true},
        {"already_gone",  stopResult.already_gone},
        {"container_name", containerName},
    });
}
