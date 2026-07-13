#include "SimOrchestrator.h"

#include "../core/HttpClient.h"
#include "../third_party/json.hpp"

#include <cstdlib>
#include <exception>
#include <string>

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

// ---------------------------------------------------------------------------
// Env parsing. Copies the same shape SimDebugController uses for
// FH_ENABLE_SIM_DEBUG so ops toggles feel consistent across the backend.
// ---------------------------------------------------------------------------
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

} // namespace fh::orchestration
