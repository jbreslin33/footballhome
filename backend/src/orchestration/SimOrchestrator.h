#pragma once

#include <optional>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// SimOrchestrator — backend surface for spawning + reaping sim daemons.
//
// Design context: sim/DESIGN.md §16.7 chose Option A (N daemons behind a
// per-match router) for M1 multi-match orchestration. This class is the
// backend's only entry point into podman — every container operation that
// affects a `footballhome_sim_${match_id}` daemon goes through here.
//
// Podman surface: talks to the host's rootful podman REST API over
// /run/podman/podman.sock (Docker-compatible v1.41 endpoints, verified
// against podman 4.9.3 on the fh dev host 2026-07-13). Chosen over
// `podman run` shell-out for three reasons: (1) zero argv-injection
// surface — the backend never invokes /bin/sh, (2) libcurl is already
// linked into the backend image so no Dockerfile change is needed
// beyond mounting the socket, (3) the API is testable via mocked HTTP
// responses without a real podman handy. The DESIGN.md §22.19 draft
// originally favored shell-out for ops simplicity; this session's recon
// confirmed the socket unit is enabled + listening by default on the
// production host too, which flips the tradeoff. Full ADR §22.19 lands
// alongside Slice 14 close-out.
//
// Slice 14.1 scope (this file): scaffolding + `pingPodman()` boot smoke
// check. `launchMatch` / `stopMatch` / `listRunningMatches` land in
// slices 14.3 / 14.5 / 14.6 respectively — kept out of this landing so
// the podman-surface decision can be reviewed on the smallest possible
// diff before the real orchestration code piles on.
//
// Thread-safety: HttpClient is stateless per call, so this class is
// safe to share across threads. No internal state beyond configuration.
//
// Security: mounting /run/podman/podman.sock into the backend container
// grants root-equivalent access to the host podman daemon. The
// FH_SIM_ORCHESTRATOR_ENABLED env flag (default 0) gates all podman
// calls at construction — set to 1 in dev only. Prod deployments that
// don't need multi-match orchestration should leave it unset.
// ────────────────────────────────────────────────────────────────────────────

class HttpClient;

namespace fh::orchestration {

struct SimOrchestratorConfig {
    // UNIX socket path for the podman REST API. Default matches the
    // Debian/Ubuntu systemd unit's `Listen=` (see `sudo systemctl cat
    // podman.socket`). Override via SIM_PODMAN_SOCKET env var only
    // if the host uses a non-default socket location.
    std::string podman_socket_path = "/run/podman/podman.sock";

    // Feature flag from env. If false, all methods return immediately
    // with an "orchestrator disabled" error — no podman calls made.
    bool enabled = false;
};

struct PingResult {
    bool ok = false;
    std::string podman_version;   // e.g. "4.9.3" (empty if !ok)
    std::string api_version;      // e.g. "1.41"   (empty if !ok)
    std::string error;            // non-empty iff !ok
};

class SimOrchestrator {
public:
    // `http` is borrowed — the caller (HttpServer in main.cpp) owns the
    // HttpClient and must outlive this SimOrchestrator.
    SimOrchestrator(SimOrchestratorConfig cfg, HttpClient& http);

    // Boot smoke check. Hits `GET /_ping` followed by `GET /version` on
    // the podman socket. Non-fatal — a failure returns { ok=false, error=... }
    // and the caller decides whether to log-and-continue or bail. Used
    // by main.cpp startup to prove the socket wiring works before any
    // real match-creation request arrives.
    //
    // When `config.enabled == false`, returns { ok=false, error="orchestrator disabled" }.
    PingResult pingPodman();

    // Config accessor (used by main.cpp boot log to report the current
    // feature-flag + socket path).
    const SimOrchestratorConfig& config() const { return cfg_; }

private:
    SimOrchestratorConfig cfg_;
    HttpClient& http_;   // borrowed, never null
};

// ---------------------------------------------------------------------------
// Config loader — reads env vars once at HttpServer construction time.
//
// FH_SIM_ORCHESTRATOR_ENABLED : "1"/"true"/"yes"/"on" ⇒ enabled=true.
//                                anything else / unset ⇒ enabled=false.
// SIM_PODMAN_SOCKET           : override podman_socket_path (rarely needed).
//
// Kept as a free function so callers can construct a SimOrchestrator
// from an explicit config in tests without hitting the environment.
// ---------------------------------------------------------------------------
SimOrchestratorConfig loadConfigFromEnv();

} // namespace fh::orchestration
