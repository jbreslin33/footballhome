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

// Inputs to launchMatch — one per-match daemon. Only the values that
// vary across matches live here; everything else (POSTGRES_*, JWT_SECRET,
// FH_SIM_ADMIN_TOKEN, SIM_PORT, SIM_ADMIN_PORT, image name, network name)
// is either read from the backend's own process env at launch time
// or hardcoded to match docker-compose.yml's `footballhome_sim` service.
struct LaunchOptions {
    long long match_id = 0;   // required, > 0
    long long seed     = 0;   // required (sim also accepts 0 → treats as fallback)
};

struct LaunchResult {
    bool        ok = false;
    std::string container_id;    // ~64-char hex; empty on failure
    std::string container_name;  // "footballhome_sim_${match_id}"; always set for logs
    std::string error;           // non-empty iff !ok
};

// Inputs to stopMatch. container_id is the primary identifier —
// stopping by name requires an extra podman round-trip to resolve, and
// the caller already has the id in `sim_running_matches.container_id`.
// grace_seconds is the SIGTERM→SIGKILL window; 5s matches podman-compose
// default and gives the sim's shutdown chain enough time to flush
// AsyncPgLog buffers on a healthy daemon.
struct StopOptions {
    std::string container_id;      // required, non-empty
    int         grace_seconds = 5; // podman /stop?t= parameter
};

struct StopResult {
    bool        ok = false;
    bool        already_gone = false; // container had already been removed
    std::string error;                // non-empty iff !ok
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

    // Slice 14.3 — create + start a per-match sim daemon container.
    //
    // Two-step podman API call:
    //   1. POST /v1.41/containers/create?name=footballhome_sim_${match_id}
    //      with a spec matching docker-compose.yml's `footballhome_sim`
    //      service (same image, same network, same env manifest — only
    //      SIM_MATCH_ID and SIM_MATCH_SEED vary).
    //   2. POST /v1.41/containers/${id}/start
    //
    // On step-2 failure the created-but-not-started container is
    // best-effort removed so `podman ps -a` doesn't accumulate zombies
    // across retries. Best-effort means we swallow errors from the
    // cleanup call — the caller has already got the launch failure.
    //
    // When `config.enabled == false`, returns { ok=false, error="orchestrator disabled" }.
    LaunchResult launchMatch(const LaunchOptions& opts);

    // Slice 14.5 — stop + remove a running per-match sim daemon container.
    //
    // Three-step podman API call:
    //   1. POST /v1.41/containers/${id}/stop?t=${grace_seconds}
    //      SIGTERMs the container; podman waits up to grace_seconds for
    //      graceful exit, then SIGKILLs. Grace period gives the sim
    //      daemon's signal-handler chain time to flush AsyncPgLog
    //      buffers and write the final MatchEnd event (see
    //      sim/src/main.cpp:409 shutdown sequence).
    //   2. DELETE /v1.41/containers/${id}
    //      Removes the (now-stopped) container so its name is freed for
    //      future launches. `force=true` is NOT set — /stop above already
    //      guaranteed the container is stopped, so a force here would
    //      only mask bugs.
    //   3. Repository row cleanup is the caller's job — this method
    //      operates purely on the podman surface.
    //
    // Idempotent: an already-stopped container returns 304 from /stop
    // and 204 from DELETE — both counted as success. A completely-
    // missing container (404 from either call) is also success, so a
    // caller retrying after a partial success (stop OK, delete failed)
    // gets a clean retry.
    //
    // When `config.enabled == false`, returns { ok=false, error="orchestrator disabled" }.
    StopResult stopMatch(const StopOptions& opts);

    // Config accessor (used by main.cpp boot log to report the current
    // feature-flag + socket path).
    const SimOrchestratorConfig& config() const { return cfg_; }

private:
    // Best-effort container cleanup. Called after a partial-launch
    // failure. Errors are logged and swallowed — the caller already
    // has the primary error to return.
    void removeContainerBestEffort(const std::string& container_id);

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
