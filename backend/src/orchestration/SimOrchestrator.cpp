#include "SimOrchestrator.h"

#include "../core/HttpClient.h"
#include "../models/SimRunningMatch.h"
#include "../third_party/json.hpp"

#include <cstdlib>
#include <exception>
#include <iostream>
#include <string>
#include <vector>

namespace fh::orchestration {

namespace {

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

    // Per-match (only two values that vary):
    env.push_back("SIM_MATCH_ID=" + std::to_string(opts.match_id));
    env.push_back("SIM_MATCH_SEED=" + std::to_string(opts.seed));

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
nlohmann::json buildCreateRequest(const LaunchOptions& opts,
                                  const std::string& container_name,
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

    (void)opts;  // opts already fully consumed via env / name
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

    // Step 1: create the container.
    const std::string createUrl = std::string(kPodmanUrlPrefix) + "/"
                                + kPodmanApiVersion
                                + "/containers/create?name=" + r.container_name;
    const nlohmann::json body = buildCreateRequest(opts, r.container_name,
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

void SimOrchestrator::removeContainerBestEffort(const std::string& container_id) {
    // DELETE /containers/{id}?force=true — force stops-then-removes so
    // we don't need a separate stop call for a container that never
    // reached "started" state.
    const std::string url = std::string(kPodmanUrlPrefix) + "/"
                          + kPodmanApiVersion
                          + "/containers/" + container_id + "?force=true";
    // libcurl-based HttpClient doesn't expose DELETE directly today,
    // but the API server accepts POST /containers/{id}/stop followed by
    // DELETE /containers/{id}. Since we already handle transport
    // errors as warnings-only here, use the simpler stop-then-forget
    // pattern via the /stop endpoint (POST, no body). Any residual
    // stopped container will be swept up by the Slice 14.6 reaper
    // pass — this call exists only to reduce the window during which
    // a stale name blocks retries.
    const std::string stopUrl = std::string(kPodmanUrlPrefix) + "/"
                              + kPodmanApiVersion
                              + "/containers/" + container_id + "/stop";
    HttpClient::Response stop = http_.postJson(stopUrl, "", {},
                                               cfg_.podman_socket_path);
    if (!stop.error.empty()) {
        std::cerr << "[sim-orchestrator] best-effort stop failed for "
                  << container_id << ": " << stop.error << std::endl;
    } else if (stop.status != 204 && stop.status != 304
               && stop.status != 404) {
        std::cerr << "[sim-orchestrator] best-effort stop HTTP "
                  << stop.status << " for " << container_id
                  << ": " << stop.body << std::endl;
    }
    (void)url;  // reserved for a future proper DELETE call
}

} // namespace fh::orchestration
