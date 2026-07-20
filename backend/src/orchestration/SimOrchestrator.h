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
    std::optional<long long> defender_profile_person_id;
    // Slice 18.x bugfix: which scenario the per-match sim daemon should
    // load. Maps to SIM_SCENARIO env var; sim/src/main.cpp resolves it to
    // a scenario_id and constructs the matching Scenario. Empty string
    // ⇒ let the daemon fall back to its own default ("empty_pitch").
    // Values must match sim_scenarios.code_id (empty_pitch, ball_on_pitch,
    // half_pitch_hard, soft_drill).
    std::string scenario_code;
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

// §21.7 item 1 step 5B (2026-07-15) — inputs to postAssignMatch.
//
// container_name is the sim daemon's compose-network hostname (the same
// string returned in LaunchResult::container_name from spawnWarm — e.g.
// "footballhome_sim_warm_7"). Backend uses TCP+DNS (aardvark-dns on the
// compose bridge) to reach the daemon's admin port 9101, NOT the podman
// unix socket. This is the ONE orchestrator verb that talks to a sim
// daemon directly rather than to podman.
//
// match_id / seed / scenario_id are the payload for the sim's
// AssignmentGate (see sim/src/main.cpp step 4A landing). match_id must
// be > 0 (sim rejects 0); seed accepts 0 (sim treats as fallback);
// scenario_id must fit i16 non-negative range (0..32767) per the sim's
// parseAssignMatchJson bounds check.
struct AssignOptions {
    std::string container_name; // required, non-empty (sim admin hostname)
    long long   match_id = 0;   // required, > 0
    long long   seed     = 0;   // required (0 legal)
    int         scenario_id = 0; // 0..32767
    std::optional<long long> defender_profile_person_id;
};

// §21.7 item 1 step 5B (2026-07-15) — outputs from postAssignMatch.
//
// ok=true                    ⇒ sim returned HTTP 200 with {"assigned":true,...},
//                              hot phase is engaging (registries load →
//                              upsertMatch → WS bind → SimServer::run).
// ok=false, already_assigned ⇒ sim returned HTTP 409 (gate was already
//                              consumed by a prior assign). Pool must NOT
//                              reuse this daemon — retire it and refill.
// ok=false, other            ⇒ transport error, HTTP 4xx/5xx, malformed
//                              response, or missing FH_SIM_ADMIN_TOKEN.
//                              error contains the diagnostic detail.
struct AssignResult {
    bool        ok = false;
    bool        already_assigned = false;
    std::string error;   // non-empty iff !ok
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

    // §21.7 item 1 step 5A (2026-07-15) — spawn a "warm" sim daemon that
    // boots into the AssignmentGate wait state (main.cpp warm-boot gate
    // from step 4A), listening on the admin port for a future
    // POST /admin/assign_match without knowing its match_id yet.
    //
    // Same two-step podman create+start as launchMatch, differing only in:
    //   - Container name: `footballhome_sim_warm_${warm_id}` — namespaced
    //     to avoid colliding with launchMatch's `footballhome_sim_${match_id}`
    //     names. The warm container's compose-network alias equals its
    //     container name (aardvark-dns publishes it); the alias does NOT
    //     re-flow on `podman container rename` (verified empirically
    //     2026-07-15), so any routing layer that wants to reach the
    //     warm-and-then-assigned daemon must either address it by its
    //     warm_id-tagged name for its lifetime, or use a network
    //     disconnect/reconnect flow to add a second alias. Both approaches
    //     will be considered when the pool refactor (5C onwards) lands.
    //   - Env: SIM_MATCH_ID, SIM_MATCH_SEED, SIM_SCENARIO deliberately
    //     ABSENT. The sim daemon detects env-unset at boot (sim/src/main.cpp
    //     branch landed in step 4A) and blocks on AssignmentGate::waitForAssign
    //     until POST /admin/assign_match arrives.
    //   - Every other field (image, network, healthcheck, secrets, restart
    //     policy) is IDENTICAL to launchMatch — the warm daemon is byte-for-
    //     byte the same binary; only its runtime env shape differs.
    //
    // `warm_id` is a monotonic counter owned by the caller (SimPool in
    // slice 5C). Must be > 0. Reusing a warm_id whose container is still
    // alive returns a create-failure ("name already in use") — the pool
    // must not reuse ids without confirming the previous container is
    // gone.
    //
    // Concurrency: same LaunchSemaphore backpressure as launchMatch
    // (excess concurrent spawns queue rather than stampede podman).
    //
    // When `config.enabled == false`, returns { ok=false, error="orchestrator disabled" }.
    LaunchResult spawnWarm(long long warm_id);

    // §21.7 item 1 step 5B (2026-07-15) — post an assignment to a warm
    // sim daemon's admin server, transitioning it from the AssignmentGate
    // wait state (step 4A) into the hot phase (registries load → upsertMatch
    // → WS bind → SimServer::run).
    //
    // Transport: HTTPS-flavored TCP+DNS over the compose bridge network
    // (backend and sim share `footballhome_footballhome_network`), NOT
    // the podman unix socket. HttpClient::postJson with an empty
    // socketPath uses libcurl's default TCP resolver — aardvark-dns
    // resolves the sim's container name to its bridge IP within the
    // configured TTL. Bearer auth: FH_SIM_ADMIN_TOKEN sourced from the
    // backend's own process env (same value the sim reads at boot).
    //
    // Response mapping:
    //   HTTP 200 "assigned":true         ⇒ { ok=true }
    //   HTTP 409 already-assigned        ⇒ { ok=false, already_assigned=true }
    //   HTTP 401/400/500/transport error ⇒ { ok=false, error=<detail> }
    //
    // The already_assigned signal exists so the pool can distinguish
    // "daemon consumed by a raced concurrent assign" (retire + refill)
    // from "the daemon is broken" (retire + investigate).
    //
    // Precondition: FH_SIM_ADMIN_TOKEN must be set in the backend's
    // process env. If empty, the call returns
    // { ok=false, error="FH_SIM_ADMIN_TOKEN unset" } WITHOUT hitting
    // the wire — an unauthenticated POST would only earn a 401 anyway.
    //
    // Concurrency: NO LaunchSemaphore permit is taken — this verb is a
    // single lightweight HTTP request whose bottleneck is the sim's
    // AssignmentGate (single-shot, so races produce 409, not overload).
    //
    // When `config.enabled == false`, returns { ok=false, error="orchestrator disabled" }.
    AssignResult postAssignMatch(const AssignOptions& opts);

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
