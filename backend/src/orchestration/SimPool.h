#pragma once

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstddef>
#include <deque>
#include <mutex>
#include <optional>
#include <string>
#include <thread>

// ────────────────────────────────────────────────────────────────────────────
// SimPool — fixed-K ring of pre-spawned warm sim daemons.
//
// §21.7 item 1 step 5C (2026-07-15). The item-1 M1-blocker chain has
// established that the podman REST create+start round-trip costs
// ~800 ms median (§21.7 item 1 attribution B1+B2), and that a warm
// daemon blocking on AssignmentGate can be assigned to a match with a
// single ~10 ms HTTP round-trip (postAssignMatch, step 5B). SimPool is
// the piece that turns that latency win into a user-visible one — it
// keeps K warm daemons standing by so the hot path (SimLobbyController
// handleCreateMatch, step 5D) only ever needs a postAssignMatch, never
// a launchMatch.
//
// Scope of THIS slice (5C): the pool class itself, standalone,
// compile-clean, uncalled by any current code path. Wiring into
// SimLobbyController lands in 5D; wiring into HttpServer's boot +
// shutdown sequence lands in 5E. Splitting the class landing from the
// wiring keeps this diff pure additive against a green tree — the
// same pattern used by 5A (`spawnWarm`) and 5B (`postAssignMatch`).
//
// Design summary:
//   - `take()` non-blocking, pops the head warm daemon or returns
//     nullopt so callers can fall back to `launchMatch` cleanly.
//   - Background refill thread wakes on take() consumption + on a
//     periodic timer fallback; spawns via SimOrchestrator::spawnWarm
//     until `slots_.size() >= target_size`.
//   - `stop()` joins the refill thread but does NOT touch remaining
//     containers — the reaper (SimReaper) handles orphans if the
//     backend crashes without draining. HttpServer's clean-shutdown
//     path (5E) will explicitly drain via take() + orch.stopMatch()
//     before calling stop().
//   - warm_id is a per-instance monotonic counter starting at 1.
//     Refill bumps it on every attempt (success OR failure) so a
//     transient half-created container can't cause a name-collision
//     retry storm. Fresh-restart with orphaned warm_1..K containers
//     is a known collision edge case; 5E's boot sequence will scan
//     `podman ps` and seed next_warm_id_ past the max existing id
//     to eliminate it. For this slice, if `spawnWarm` returns a
//     name-collision error we simply log-and-back-off — the reaper
//     eventually reclaims and the next attempt succeeds.
//
// Concurrency invariants:
//   - All slot access serialized through mtx_.
//   - Refill spawns are dispatched OUTSIDE mtx_ (podman round-trip
//     is ~500 ms — holding the lock during that would block take()).
//   - `take()` is O(1) under mtx_ and never blocks on I/O.
//
// Thread-safety: `take()` + `metrics()` are safe to call from any
// thread. `start()` + `stop()` are NOT — they should be called from
// the owning thread (HttpServer boot / shutdown, 5E).
//
// The pool is oblivious to the container's post-take fate. If the
// caller's `postAssignMatch` fails (409 already-assigned or
// transport error), the caller is responsible for calling
// `orch.stopMatch()` to reap the failed container. The pool's size
// already reflects the take, so the refill thread will replace it
// automatically.
// ────────────────────────────────────────────────────────────────────────────

namespace fh::orchestration {

class SimOrchestrator;

struct SimPoolConfig {
    // How many warm daemons to keep standing by. When `slots_.size()`
    // drops below this, the refill thread spawns until it's restored.
    // Sourced from FH_SIM_POOL_SIZE env in 5E; 0 disables the pool
    // (which lets 5D transparently fall back to launchMatch on every
    // request — the same behaviour as before this chain landed).
    int target_size = 4;

    // Backoff between refill attempts after a spawnWarm failure.
    // 2s is generous — spawnWarm failures usually mean podman is
    // wedged, and we don't want to hammer it with retries.
    std::chrono::milliseconds refill_backoff_on_error{std::chrono::seconds(2)};

    // Fallback wake period even when no take() has fired. Covers the
    // case where a spawn failed and the caller isn't consuming — we
    // still want to eventually retry. Chosen 30s: rare enough to be
    // idle, quick enough to self-heal after a transient podman blip.
    std::chrono::milliseconds refill_wake_interval{std::chrono::seconds(30)};
};

// A single warm daemon slot. Handed out by `take()` and consumed by
// the caller for postAssignMatch + subsequent routing. The container
// keeps its `container_name` for its entire lifetime — that's the
// stable routing key (per 5B's rename-deferral finding: podman
// container rename does NOT reflow aardvark-dns network aliases).
struct SimPoolSlot {
    long long warm_id = 0;            // pool-owned monotonic id
    std::string container_id;         // podman ~64-char hex
    std::string container_name;       // "footballhome_sim_warm_${warm_id}"
};

// Snapshot of pool state for admin / metrics endpoints. All fields
// are cheap counters — this struct is safe to compute inside the
// mutex without meaningful lock contention.
struct SimPoolMetrics {
    std::size_t available = 0;              // slots_.size() right now
    long long total_spawned = 0;            // lifetime cumulative
    long long total_taken = 0;              // lifetime cumulative
    long long total_spawn_failures = 0;     // lifetime cumulative
    long long next_warm_id = 1;             // what the next spawn will use
};

class SimPool {
public:
    // `orch` is borrowed — the caller (HttpServer in 5E) owns the
    // SimOrchestrator and must outlive this SimPool.
    SimPool(SimPoolConfig cfg, SimOrchestrator& orch);

    // Joins the refill thread if still running. Does NOT stop any
    // remaining warm containers — the caller must drain first if
    // it wants clean shutdown (5E).
    ~SimPool();

    SimPool(const SimPool&) = delete;
    SimPool& operator=(const SimPool&) = delete;
    SimPool(SimPool&&) = delete;
    SimPool& operator=(SimPool&&) = delete;

    // Launch the refill thread. Idempotent — a second call is a no-op.
    // Safe to call with `cfg.target_size == 0`, in which case the
    // thread starts but never spawns anything (pool always empty,
    // `take()` always returns nullopt).
    void start();

    // Signal the refill thread to stop and join it. Idempotent.
    // Does not touch existing slots — call `take()` in a loop before
    // this if you want to reap remaining warm daemons.
    void stop();

    // Non-blocking pop. Returns the head slot if one is available,
    // nullopt otherwise. On success wakes the refill thread so it
    // can start replacing the taken slot immediately.
    std::optional<SimPoolSlot> take();

    // Snapshot of pool state. Safe to call from any thread.
    SimPoolMetrics metrics() const;

    const SimPoolConfig& config() const { return cfg_; }

private:
    void refillLoop();

    SimPoolConfig cfg_;
    SimOrchestrator& orch_;

    mutable std::mutex mtx_;
    std::condition_variable cv_;
    std::deque<SimPoolSlot> slots_;
    long long next_warm_id_ = 1;
    long long total_spawned_ = 0;
    long long total_taken_ = 0;
    long long total_spawn_failures_ = 0;

    std::atomic<bool> running_{false};
    std::atomic<bool> shutdown_requested_{false};
    std::thread refill_thread_;
};

} // namespace fh::orchestration
