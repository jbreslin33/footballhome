#include "SimOrchestrator.h"

#include "../core/HttpClient.h"
#include "../models/SimRunningMatch.h"
#include "../third_party/json.hpp"

#include <condition_variable>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <mutex>
#include <string>
#include <vector>

namespace fh::orchestration {

namespace {

// ─── Global launch-concurrency limiter (Slice 14.7) ───────────────────────
// The DESIGN §16.7 goal is "20 concurrent matches per host without spawn
// errors." A naive implementation (one detached backend thread per HTTP
// request, each doing a full podman create+start round-trip) stampedes
// the podman socket + backend memory when 20 arrive together — the
// 2026-07-13 load test observed 17/20 requests time out at 15 s while
// podman was still processing containers 13..20. The socket eventually
// recovered but curl clients had already given up.
//
// Fix: cap concurrent launchMatch() calls to a small window. Excess
// callers block on a CV until a slot frees up. This turns a stampede
// into an orderly queue — total wall-clock for 20 spawns is roughly
// (20 / kMax) * per-spawn-ms, and no request is dropped.
//
// kMax defaulted to 4 based on: podman 4.9.3 rootful on this host
// handles ~3-4 parallel create+start ops before its socket queue
// starts stretching latency past the 5-second p99 mark. Tunable via
// FH_SIM_LAUNCH_MAX_CONCURRENCY for hosts with beefier storage.
// Setting it to 1 makes launches strictly serial — useful for
// debugging podman-side hangs.
//
// Why a hand-rolled semaphore instead of std::counting_semaphore?
// The backend is pinned to C++17 (see CMakeLists.txt); counting_semaphore
// arrived in C++20. A mutex + CV + counter is 15 lines and does the
// same job.
class LaunchSemaphore {
public:
    explicit LaunchSemaphore(int max_permits) : available_(max_permits) {}

    void acquire() {
        std::unique_lock<std::mutex> lk(mtx_);
        cv_.wait(lk, [&] { return available_ > 0; });
        --available_;
    }

    void release() {
        {
            std::lock_guard<std::mutex> lk(mtx_);
            ++available_;
        }
        cv_.notify_one();
    }

private:
    std::mutex mtx_;
    std::condition_variable cv_;
    int available_;
};

int launchMaxFromEnv() {
    const char* v = std::getenv("FH_SIM_LAUNCH_MAX_CONCURRENCY");
    if (!v || !*v) return 4;
    try {
        int n = std::stoi(v);
        if (n < 1)  return 1;
        if (n > 32) return 32;
        return n;
    } catch (...) {
        return 4;
    }
}

LaunchSemaphore& launchSemaphore() {
    // Meyers-singleton — first access initializes with the env-derived
    // cap. Later env changes DO NOT retune the live limiter; this is
    // intentional — the backend restarts for env changes anyway.
    static LaunchSemaphore instance(launchMaxFromEnv());
    return instance;
}

// RAII wrapper. Acquires on construction, releases on destruction —
// guarantees the semaphore is released even when launchMatch throws
// or returns early via one of its many error paths.
struct LaunchPermit {
    LaunchPermit()  { launchSemaphore().acquire(); }
    ~LaunchPermit() { launchSemaphore().release(); }
    LaunchPermit(const LaunchPermit&)            = delete;
    LaunchPermit& operator=(const LaunchPermit&) = delete;
};


// libcurl requires a scheme+host in the URL even when routing over a
// UNIX socket via CURLOPT_UNIX_SOCKET_PATH. Convention (borrowed from
// Docker's own docs) is to use "http://d/…" — the host component is
// ignored on the wire, only the path is sent.
constexpr const char* kPodmanUrlPrefix = "http://d";

// Docker-compatible API version. Podman 4.9.3 advertises 1.41 in its
// /version response — pin explicitly so the URL doesn't silently drift.
// (Podman also exposes a native /libpod/ surface but we don't need
// anything specific to it for Slice 14; sticking with the Docker
// compat API keeps this class portable to Docker hosts too if that
// ever matters.)
constexpr const char* kPodmanApiVersion = "v1.41";

// Sim container image tag — must match the tag `podman-compose build`
// produces for the `footballhome_sim` service (project prefix +
// service name). Rebuilding the sim without also updating this string
// would silently launch stale binaries.
constexpr const char* kSimImageTag = "localhost/footballhome_footballhome_sim:latest";

// Sim container network — must match docker-compose.yml's `networks`
// entry (project prefix + declared name). Backend + sim daemons share
// this bridge network so nginx can reach `footballhome_sim_${match_id}`
// by hostname alias in Slice 14.4.
constexpr const char* kSimNetwork = "footballhome_footballhome_network";

// -------------------------------------------------------------------------
// Env parsing. Copies the same shape SimDebugController uses for
// FH_ENABLE_SIM_DEBUG so ops toggles feel consistent across the backend.
// -------------------------------------------------------------------------
bool envFlagIsTrue(const char* name) {
    const char* v = std::getenv(name);
    if (!v || !*v) return false;
    std::string s(v);
    for (char& c : s) { c = static_cast<char>(std::tolower(static_cast<unsigned char>(c))); }
    return s == "1" || s == "true" || s == "yes" || s == "on";
}

std::string envOrDefault(const char* name, const std::string& fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    return std::string(v);
}

// -------------------------------------------------------------------------
// Build the per-match env manifest. Mirrors `footballhome_sim`'s
// environment: block in docker-compose.yml with the two per-match
// values (SIM_MATCH_ID + SIM_MATCH_SEED) substituted in.
//
// Everything else (POSTGRES_*, JWT_SECRET, FH_SIM_ADMIN_TOKEN) is
// forwarded from the BACKEND's own process env — the backend's
// env_file: ./env in docker-compose.yml already populated those. This
// keeps the secret manifest in one place (./env) instead of
// duplicating it in code.
//
// If a required secret is missing from the backend's env, the sim
// binary will refuse to start (JWT_SECRET / POSTGRES_PASSWORD both
// exit non-zero in sim/src/main.cpp) — that failure surfaces as a
// launchMatch() error at API-response time. We do NOT preflight the
// env here because a caller may deliberately be launching a container
// that's expected to fail (e.g. a rotation smoke test).
// -------------------------------------------------------------------------
std::vector<std::string> buildSimEnv(const LaunchOptions& opts) {
    std::vector<std::string> env;

    // Per-match (values that vary):
    env.push_back("SIM_MATCH_ID=" + std::to_string(opts.match_id));
    env.push_back("SIM_MATCH_SEED=" + std::to_string(opts.seed));
    // Slice 18.x bugfix: without this, every per-match container fell back
    // to sim/src/main.cpp's default of empty_pitch — the "Ball on Pitch"
    // (and future) launcher tiles would spawn a match with no ball. The
    // sim daemon accepts an unset SIM_SCENARIO (treats as empty_pitch)
    // so we only emit it when the caller actually specified a scenario.
    if (!opts.scenario_code.empty()) {
        env.push_back("SIM_SCENARIO=" + opts.scenario_code);
    }

    // Static (matches docker-compose.yml `footballhome_sim` service):
    env.push_back("SIM_BIND_ADDRESS=0.0.0.0");
    env.push_back("SIM_PORT=9100");
    env.push_back("SIM_ADMIN_BIND_ADDRESS=0.0.0.0");
    env.push_back("SIM_ADMIN_PORT=9101");

    // Postgres — sim connects to the same DB the backend uses. Reuse
    // whatever the backend has in its own env. The sim binary has
    // fallbacks for POSTGRES_HOST/PORT/DB/USER but requires
    // POSTGRES_PASSWORD non-empty.
    env.push_back("POSTGRES_HOST="     + envOrDefault("POSTGRES_HOST",     "db"));
    env.push_back("POSTGRES_PORT="     + envOrDefault("POSTGRES_PORT",     "5432"));
    env.push_back("POSTGRES_DB="       + envOrDefault("POSTGRES_DB",       "footballhome"));
    env.push_back("POSTGRES_USER="     + envOrDefault("POSTGRES_USER",     "footballhome_user"));
    env.push_back("POSTGRES_PASSWORD=" + envOrDefault("POSTGRES_PASSWORD", ""));

    // JWT + admin tokens — sim verifies the same signature backend mints.
    env.push_back("JWT_SECRET="         + envOrDefault("JWT_SECRET", ""));
    env.push_back("FH_SIM_ADMIN_TOKEN=" + envOrDefault("FH_SIM_ADMIN_TOKEN", ""));

    return env;
}

// -------------------------------------------------------------------------
// Build the env manifest for a WARM sim daemon (§21.7 item 1 step 5A).
//
// Identical to buildSimEnv() EXCEPT the three per-match variables
// (SIM_MATCH_ID / SIM_MATCH_SEED / SIM_SCENARIO) are omitted. The sim
// daemon's main.cpp branches on `getenv("SIM_MATCH_ID") != nullptr` at
// boot (step 4A landing): env-set ⇒ existing hot-boot path;
// env-unset ⇒ AssignmentGate wait, admin port serves
// POST /admin/assign_match to receive the real match_id later.
//
// Every other env variable (secrets, ports, bind addresses) is the same
// so the daemon's admin server binds identically and the eventual
// assign_match handler has all the DB credentials it needs to run
// upsertMatch + MatchStart in the hot phase.
// -------------------------------------------------------------------------
std::vector<std::string> buildWarmSimEnv() {
    std::vector<std::string> env;

    // NO SIM_MATCH_ID, NO SIM_MATCH_SEED, NO SIM_SCENARIO — the whole
    // point of this env shape is to keep the daemon in the AssignmentGate
    // wait state so a POST /admin/assign_match can decide the values.
    //
    // BUT: [sim/Dockerfile](../../../sim/Dockerfile) sets
    // `ENV SIM_MATCH_ID=1 SIM_MATCH_SEED=42` as image-level defaults for
    // local-dev `podman run` convenience. The Docker/Podman container-
    // create API's `Env` field can only override / add — it can't UNSET
    // an image-level ENV. So we override with EMPTY strings, which the
    // sim's boot check treats as "unset":
    //   const bool env_set = (getenv("SIM_MATCH_ID") != nullptr &&
    //                         getenv("SIM_MATCH_ID")[0] != '\0');
    // Empty string ⇒ pointer non-null, first char is '\0' ⇒ env_set=false
    // ⇒ AssignmentGate wait branch engages (step 4A).
    env.push_back("SIM_MATCH_ID=");
    env.push_back("SIM_MATCH_SEED=");
    env.push_back("SIM_SCENARIO=");

    // Static (identical to buildSimEnv):
    env.push_back("SIM_BIND_ADDRESS=0.0.0.0");
    env.push_back("SIM_PORT=9100");
    env.push_back("SIM_ADMIN_BIND_ADDRESS=0.0.0.0");
    env.push_back("SIM_ADMIN_PORT=9101");

    // Postgres + secrets — same rationale as buildSimEnv: the daemon
    // needs these ready for when the hot phase engages after assignment.
    env.push_back("POSTGRES_HOST="     + envOrDefault("POSTGRES_HOST",     "db"));
    env.push_back("POSTGRES_PORT="     + envOrDefault("POSTGRES_PORT",     "5432"));
    env.push_back("POSTGRES_DB="       + envOrDefault("POSTGRES_DB",       "footballhome"));
    env.push_back("POSTGRES_USER="     + envOrDefault("POSTGRES_USER",     "footballhome_user"));
    env.push_back("POSTGRES_PASSWORD=" + envOrDefault("POSTGRES_PASSWORD", ""));

    env.push_back("JWT_SECRET="         + envOrDefault("JWT_SECRET", ""));
    env.push_back("FH_SIM_ADMIN_TOKEN=" + envOrDefault("FH_SIM_ADMIN_TOKEN", ""));

    return env;
}

// Deterministic warm-container name (§21.7 item 1 step 5A). Namespaced
// with `_warm_` to guarantee zero overlap with the assigned-container
// name space owned by containerNameFor() in SimRunningMatch.h. A
// follow-up slice (5B) renames the container to the canonical
// `footballhome_sim_${match_id}` at assign time so nginx's per-match
// regex route (Slice 14.4) can reach it.
std::string warmContainerNameFor(long long warm_id) {
    return "footballhome_sim_warm_" + std::to_string(warm_id);
}

// -------------------------------------------------------------------------
// Build the JSON body for POST /containers/create.
//
// Podman's Docker-compat container-create endpoint accepts the same
// schema as Docker Engine 1.41 (documented at
// https://docs.docker.com/reference/api/engine/version/v1.41/#tag/Container/operation/ContainerCreate).
// The fields we set here are exactly the ones podman-compose derives
// from `docker-compose.yml`'s `footballhome_sim` service:
//
//   Image          — the built sim image (kSimImageTag)
//   Env            — per-match SIM_MATCH_ID/SEED + shared secrets
//   HostConfig
//     NetworkMode  — the project-prefixed bridge network
//     RestartPolicy: on-failure with 3 retries
//   NetworkingConfig
//     EndpointsConfig: alias the container_name onto the network so
//                       nginx can reach it by that hostname in 14.4
//
// Ports are deliberately NOT published to the host — the sim is
// reachable only via the internal bridge (identical to the M0
// docker-compose service).
// -------------------------------------------------------------------------
nlohmann::json buildCreateRequest(const std::string& container_name,
                                  const std::vector<std::string>& env) {
    nlohmann::json body;
    body["Image"] = kSimImageTag;
    body["Env"]   = env;

    // Podman/Docker healthcheck: same shell command docker-compose.yml
    // uses — proves the sim's TCP listen socket is up. Not strictly
    // required for `podman start` to return success, but populating
    // it means `podman inspect` shows the same health field as the
    // compose-managed daemon.
    body["Healthcheck"] = {
        {"Test", nlohmann::json::array({
            "CMD-SHELL",
            "ss -Hln --tcp sport = :9100 | grep -q LISTEN"})},
        {"Interval",     15LL * 1'000'000'000LL},  // nanoseconds
        {"Timeout",       5LL * 1'000'000'000LL},
        {"Retries",       4},
        {"StartPeriod",  30LL * 1'000'000'000LL},
    };

    body["HostConfig"] = {
        {"NetworkMode", kSimNetwork},
        {"RestartPolicy", {
            {"Name",              "on-failure"},
            {"MaximumRetryCount", 3}
        }},
    };

    body["NetworkingConfig"] = {
        {"EndpointsConfig", {
            {kSimNetwork, {
                {"Aliases", nlohmann::json::array({container_name})}
            }}
        }}
    };

    return body;
}

} // namespace

// ---------------------------------------------------------------------------
// loadConfigFromEnv
// ---------------------------------------------------------------------------

SimOrchestratorConfig loadConfigFromEnv() {
    SimOrchestratorConfig cfg;
    cfg.podman_socket_path = envOrDefault("SIM_PODMAN_SOCKET",
                                          "/run/podman/podman.sock");
    cfg.enabled            = envFlagIsTrue("FH_SIM_ORCHESTRATOR_ENABLED");
    return cfg;
}

// ---------------------------------------------------------------------------
// SimOrchestrator
// ---------------------------------------------------------------------------

SimOrchestrator::SimOrchestrator(SimOrchestratorConfig cfg, HttpClient& http)
    : cfg_(std::move(cfg)), http_(http) {}

PingResult SimOrchestrator::pingPodman() {
    PingResult r;

    if (!cfg_.enabled) {
        r.error = "orchestrator disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)";
        return r;
    }

    // Step 1: /_ping — cheap liveness probe. Podman returns literal "OK".
    const std::string pingUrl = std::string(kPodmanUrlPrefix) + "/_ping";
    HttpClient::Response ping = http_.get(pingUrl, {}, cfg_.podman_socket_path);
    if (!ping.error.empty()) {
        r.error = "podman socket transport error: " + ping.error;
        return r;
    }
    if (ping.status != 200) {
        r.error = "podman /_ping returned HTTP " + std::to_string(ping.status);
        return r;
    }
    if (ping.body != "OK") {
        r.error = "podman /_ping returned unexpected body: " + ping.body;
        return r;
    }

    // Step 2: /version — parse Version + ApiVersion so the boot log
    // shows exactly which podman we're targeting.
    const std::string verUrl = std::string(kPodmanUrlPrefix) + "/"
                             + kPodmanApiVersion + "/version";
    HttpClient::Response ver = http_.get(verUrl, {}, cfg_.podman_socket_path);
    if (!ver.error.empty()) {
        r.error = "podman /version transport error: " + ver.error;
        return r;
    }
    if (ver.status != 200) {
        r.error = "podman /version returned HTTP " + std::to_string(ver.status);
        return r;
    }

    try {
        auto j = nlohmann::json::parse(ver.body);
        // Docker-compat shape (verified against podman 4.9.3):
        //   { "Version": "4.9.3", "ApiVersion": "1.41", ... }
        if (j.contains("Version") && j["Version"].is_string()) {
            r.podman_version = j["Version"].get<std::string>();
        }
        if (j.contains("ApiVersion") && j["ApiVersion"].is_string()) {
            r.api_version = j["ApiVersion"].get<std::string>();
        }
    } catch (const std::exception& e) {
        r.error = std::string("podman /version body was not valid JSON: ") + e.what();
        return r;
    }

    if (r.podman_version.empty()) {
        r.error = "podman /version JSON missing Version field";
        return r;
    }

    r.ok = true;
    return r;
}

LaunchResult SimOrchestrator::launchMatch(const LaunchOptions& opts) {
    LaunchResult r;
    r.container_name = containerNameFor(opts.match_id);

    if (!cfg_.enabled) {
        r.error = "orchestrator disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)";
        return r;
    }
    if (opts.match_id <= 0) {
        r.error = "invalid match_id (must be > 0)";
        return r;
    }

    // Backpressure: cap concurrent create+start podman round-trips to
    // FH_SIM_LAUNCH_MAX_CONCURRENCY (default 4). Excess callers block
    // here until a slot frees up. RAII guarantees the slot is released
    // even on error-path returns and thrown exceptions below.
    LaunchPermit permit;

    // Step 1: create the container.
    const std::string createUrl = std::string(kPodmanUrlPrefix) + "/"
                                + kPodmanApiVersion
                                + "/containers/create?name=" + r.container_name;
    const nlohmann::json body = buildCreateRequest(r.container_name,
                                                   buildSimEnv(opts));
    HttpClient::Response create = http_.postJson(createUrl, body.dump(), {},
                                                 cfg_.podman_socket_path);
    if (!create.error.empty()) {
        r.error = "podman create transport error: " + create.error;
        return r;
    }
    if (create.status != 201) {
        r.error = "podman create returned HTTP " + std::to_string(create.status)
                + ": " + create.body;
        return r;
    }

    try {
        auto j = nlohmann::json::parse(create.body);
        // Docker-compat shape: { "Id": "<64-char hex>", "Warnings": [...] }
        if (j.contains("Id") && j["Id"].is_string()) {
            r.container_id = j["Id"].get<std::string>();
        }
    } catch (const std::exception& e) {
        r.error = std::string("podman create body was not valid JSON: ")
                + e.what();
        return r;
    }

    if (r.container_id.empty()) {
        r.error = "podman create response missing Id field";
        return r;
    }

    // Step 2: start it. On any failure we best-effort remove the
    // created-but-not-started container so retries have a clean name to
    // reuse.
    const std::string startUrl = std::string(kPodmanUrlPrefix) + "/"
                               + kPodmanApiVersion
                               + "/containers/" + r.container_id + "/start";
    HttpClient::Response start = http_.postJson(startUrl, "", {},
                                                cfg_.podman_socket_path);
    if (!start.error.empty()) {
        r.error = "podman start transport error: " + start.error;
        removeContainerBestEffort(r.container_id);
        r.container_id.clear();
        return r;
    }
    // Docker/Podman container-start returns 204 on success, 304 if it
    // was already running (which shouldn't happen for a freshly-created
    // container but tolerate anyway).
    if (start.status != 204 && start.status != 304) {
        r.error = "podman start returned HTTP " + std::to_string(start.status)
                + ": " + start.body;
        removeContainerBestEffort(r.container_id);
        r.container_id.clear();
        return r;
    }

    r.ok = true;
    return r;
}

// ---------------------------------------------------------------------------
// spawnWarm (§21.7 item 1 step 5A, 2026-07-15)
//
// Structurally identical to launchMatch: same permit, same two-step
// podman create+start, same rollback discipline. The differences are
// entirely in the inputs handed to buildCreateRequest:
//   - name  = warmContainerNameFor(warm_id) instead of containerNameFor()
//   - env   = buildWarmSimEnv() (omits SIM_MATCH_ID/SEED/SCENARIO)
//
// Deliberately duplicates the create+start call graph rather than
// refactoring launchMatch onto a shared helper — the slice ships as pure
// addition so a regression in launchMatch is architecturally impossible.
// A follow-up cleanup slice can factor commonalities once both paths
// have real integration coverage.
// ---------------------------------------------------------------------------
LaunchResult SimOrchestrator::spawnWarm(long long warm_id) {
    LaunchResult r;
    r.container_name = warmContainerNameFor(warm_id);

    if (!cfg_.enabled) {
        r.error = "orchestrator disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)";
        return r;
    }
    if (warm_id <= 0) {
        r.error = "invalid warm_id (must be > 0)";
        return r;
    }

    // Same backpressure semaphore as launchMatch — warm spawns and
    // per-match launches share podman's rate-limit envelope.
    LaunchPermit permit;

    // Step 1: create.
    const std::string createUrl = std::string(kPodmanUrlPrefix) + "/"
                                + kPodmanApiVersion
                                + "/containers/create?name=" + r.container_name;
    const nlohmann::json body = buildCreateRequest(r.container_name,
                                                   buildWarmSimEnv());
    HttpClient::Response create = http_.postJson(createUrl, body.dump(), {},
                                                 cfg_.podman_socket_path);
    if (!create.error.empty()) {
        r.error = "podman create transport error: " + create.error;
        return r;
    }
    if (create.status != 201) {
        r.error = "podman create returned HTTP " + std::to_string(create.status)
                + ": " + create.body;
        return r;
    }

    try {
        auto j = nlohmann::json::parse(create.body);
        if (j.contains("Id") && j["Id"].is_string()) {
            r.container_id = j["Id"].get<std::string>();
        }
    } catch (const std::exception& e) {
        r.error = std::string("podman create body was not valid JSON: ")
                + e.what();
        return r;
    }

    if (r.container_id.empty()) {
        r.error = "podman create response missing Id field";
        return r;
    }

    // Step 2: start.
    const std::string startUrl = std::string(kPodmanUrlPrefix) + "/"
                               + kPodmanApiVersion
                               + "/containers/" + r.container_id + "/start";
    HttpClient::Response start = http_.postJson(startUrl, "", {},
                                                cfg_.podman_socket_path);
    if (!start.error.empty()) {
        r.error = "podman start transport error: " + start.error;
        removeContainerBestEffort(r.container_id);
        r.container_id.clear();
        return r;
    }
    if (start.status != 204 && start.status != 304) {
        r.error = "podman start returned HTTP " + std::to_string(start.status)
                + ": " + start.body;
        removeContainerBestEffort(r.container_id);
        r.container_id.clear();
        return r;
    }

    r.ok = true;
    return r;
}

// ---------------------------------------------------------------------------
// postAssignMatch (§21.7 item 1 step 5B, 2026-07-15)
//
// Single POST to the target sim daemon's admin server. Uses HttpClient's
// standard TCP+DNS path (empty socketPath) — the backend and every sim
// daemon share the compose bridge network `footballhome_footballhome_network`
// (verified by spawnWarm's NetworkingConfig EndpointsConfig aliases +
// launchMatch's identical setup), and podman's aardvark-dns serves the
// container_name → bridge-IP mapping.
//
// Bearer token sourced from FH_SIM_ADMIN_TOKEN in the backend's own
// env — the same value the sim reads at boot (see buildSimEnv +
// buildWarmSimEnv above). If it's unset in the backend env, the sim's
// admin server would 401 the call anyway; we short-circuit with a
// descriptive error rather than round-trip a definite failure.
//
// Body shape mirrors AdminHttpServer::parseAssignMatchJson (step 3 of
// this fix chain) exactly — a three-field object with match_id, seed,
// scenario_id. Wider match_id / seed types on the wire (u64 in the sim
// parser) accept the entire long long range we might send from here.
//
// Response handling: three canonical outcomes distinguished for the
// pool's benefit (per AssignResult docblock). All other cases collapse
// into a generic error with the HTTP status + body for diagnosability.
// ---------------------------------------------------------------------------
AssignResult SimOrchestrator::postAssignMatch(const AssignOptions& opts) {
    AssignResult r;

    if (!cfg_.enabled) {
        r.error = "orchestrator disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)";
        return r;
    }
    if (opts.container_name.empty()) {
        r.error = "container_name required";
        return r;
    }
    if (opts.match_id <= 0) {
        r.error = "invalid match_id (must be > 0)";
        return r;
    }
    if (opts.scenario_id < 0 || opts.scenario_id > 32767) {
        r.error = "invalid scenario_id (must be 0..32767)";
        return r;
    }

    const std::string bearer = envOrDefault("FH_SIM_ADMIN_TOKEN", "");
    if (bearer.empty()) {
        // Cheaper than round-tripping a guaranteed 401. Signals a config
        // error in the backend's own env, not a sim-side problem.
        r.error = "FH_SIM_ADMIN_TOKEN unset in backend env";
        return r;
    }

    // Build the assign_match URL. Port 9101 matches buildWarmSimEnv()'s
    // SIM_ADMIN_PORT — both sides of the wire must agree on this.
    const std::string url = "http://" + opts.container_name
                          + ":9101/admin/assign_match";

    // Body per parseAssignMatchJson contract.
    nlohmann::json body;
    body["match_id"]    = opts.match_id;
    body["seed"]        = opts.seed;
    body["scenario_id"] = opts.scenario_id;

    const HttpClient::Headers headers = {
        { "Authorization", "Bearer " + bearer },
    };

    // Empty socketPath ⇒ HttpClient uses TCP+DNS via libcurl's default
    // resolver, which points at aardvark-dns on the compose bridge.
    HttpClient::Response resp = http_.postJson(url, body.dump(), headers,
                                               /*unixSocketPath=*/ "");

    if (!resp.error.empty()) {
        r.error = "sim admin transport error: " + resp.error;
        return r;
    }

    if (resp.status == 200) {
        // Sanity-check the sim confirmed the assignment. The wire contract
        // says the body carries `{"assigned":true,"match_id":...,...}` on
        // success; a 200 with anything else means the sim's contract has
        // drifted from ours and the pool should surface it rather than
        // silently trust the status code.
        try {
            auto j = nlohmann::json::parse(resp.body);
            if (j.contains("assigned") && j["assigned"].is_boolean()
                && j["assigned"].get<bool>()) {
                r.ok = true;
                return r;
            }
            r.error = "sim admin 200 with unexpected body: " + resp.body;
            return r;
        } catch (const std::exception& e) {
            r.error = std::string("sim admin 200 body not valid JSON: ")
                    + e.what() + " (body=" + resp.body + ")";
            return r;
        }
    }

    if (resp.status == 409) {
        // Race: the AssignmentGate was already consumed. Signal the pool
        // so it can retire this daemon and refill rather than treat it
        // as a hard failure.
        r.already_assigned = true;
        r.error = "sim admin returned 409: " + resp.body;
        return r;
    }

    r.error = "sim admin returned HTTP " + std::to_string(resp.status)
            + ": " + resp.body;
    return r;
}

void SimOrchestrator::removeContainerBestEffort(const std::string& container_id) {
    // Rollback path from launchMatch. Reuses the full stopMatch flow
    // (stop-with-grace → delete) so a partial-launch failure leaves
    // exactly the same clean state as an explicit stopMatch call.
    // Grace period is deliberately short (2s) because a container that
    // failed to start has no in-flight work worth flushing — either the
    // process never wrote anything, or it wrote and then crashed, and
    // we're just trying to free the name.
    StopOptions opts;
    opts.container_id   = container_id;
    opts.grace_seconds  = 2;
    StopResult r = stopMatch(opts);
    if (!r.ok && !r.already_gone) {
        std::cerr << "[sim-orchestrator] best-effort cleanup failed for "
                  << container_id << ": " << r.error
                  << " (leaked container name will be resolved by reaper)"
                  << std::endl;
    }
}

StopResult SimOrchestrator::stopMatch(const StopOptions& opts) {
    StopResult r;

    if (!cfg_.enabled) {
        r.error = "orchestrator disabled (FH_SIM_ORCHESTRATOR_ENABLED unset)";
        return r;
    }
    if (opts.container_id.empty()) {
        r.error = "container_id required";
        return r;
    }
    if (opts.grace_seconds < 0) {
        r.error = "grace_seconds must be >= 0";
        return r;
    }

    // Backpressure: stopMatch does a synchronous /stop?t=5 followed
    // by DELETE, both against the same rootful podman socket that
    // launchMatch uses. Under 20-concurrent tear-down the socket
    // starves the same way it did on launch — the 2026-07-13 load
    // test observed 10/20 stops timing out at 30 s while podman
    // was still processing tail-end containers. Cap concurrent
    // stops behind the same semaphore as launches so a spawn burst
    // followed by a stop burst can't queue-jump each other.
    LaunchPermit permit;

    // Step 1: SIGTERM + wait up to grace_seconds. Docker/podman API
    // returns 204 (stopped), 304 (already stopped), or 404 (missing).
    // /stop is synchronous up to `t` seconds — if the daemon exits
    // cleanly before that, the call returns as soon as the process
    // reaps. If not, podman escalates to SIGKILL and returns 204 anyway.
    const std::string stopUrl = std::string(kPodmanUrlPrefix) + "/"
                              + kPodmanApiVersion
                              + "/containers/" + opts.container_id
                              + "/stop?t=" + std::to_string(opts.grace_seconds);
    HttpClient::Response stop = http_.postJson(stopUrl, "", {},
                                               cfg_.podman_socket_path);
    if (!stop.error.empty()) {
        r.error = "podman stop transport error: " + stop.error;
        return r;
    }
    if (stop.status == 404) {
        // Container already gone — /delete will 404 too. Treat as
        // idempotent success so the caller's retry after a partial
        // success (stop OK, delete failed, retry) collapses cleanly.
        r.ok = true;
        r.already_gone = true;
        return r;
    }
    if (stop.status != 204 && stop.status != 304) {
        r.error = "podman stop returned HTTP " + std::to_string(stop.status)
                + ": " + stop.body;
        return r;
    }

    // Step 2: DELETE. No `force=true` — /stop above already guaranteed
    // the container is stopped, so `force` would only mask bugs.
    const std::string delUrl = std::string(kPodmanUrlPrefix) + "/"
                             + kPodmanApiVersion
                             + "/containers/" + opts.container_id;
    HttpClient::Response del = http_.del(delUrl, {}, cfg_.podman_socket_path);
    if (!del.error.empty()) {
        r.error = "podman delete transport error: " + del.error;
        return r;
    }
    if (del.status == 404) {
        // Raced with the reaper or another delete — the container is
        // gone. Same idempotent-success semantics as the /stop 404 case.
        r.ok = true;
        r.already_gone = true;
        return r;
    }
    if (del.status != 204 && del.status != 200) {
        r.error = "podman delete returned HTTP " + std::to_string(del.status)
                + ": " + del.body;
        return r;
    }

    r.ok = true;
    return r;
}

} // namespace fh::orchestration
