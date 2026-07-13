#pragma once
// =============================================================================
// SimReaper  (Slice 14.6 — periodic orchestrator reconciliation)
// =============================================================================
//
// Runs a background sweep every 5 min (default) that reconciles the DB
// view of running matches against the podman view. Fixes the two crash-
// recovery gaps that the synchronous stop/create paths can't:
//
//   Case 1 — Containers for already-ended matches. The sim daemon can
//   end a match on its own (idle-timeout watchdog, match completion,
//   `sim/main.cpp` graceful SIGTERM writing MatchEnd) — after which
//   `sim_matches.ended_at` is set but the container is still there.
//   Also covers the "handleStopMatch died after step 1" case where
//   the container was stopped but the DB update / row-delete didn't
//   finish.
//
//   Case 2 — Open matches whose container is gone. Podman gave up on
//   `restart: on-failure:3`, or someone `podman kill`-ed the container
//   manually, or the podman daemon itself was restarted with
//   `--rm`-style cleanup. `sim_matches.ended_at` is still NULL, so any
//   caller polling /api/sim/matches still sees it as "open" until we
//   mark it abandoned.
//
// Per sim/DESIGN.md §16.7 step 6 + step 9 (Backend crash recovery).
//
// Advisory-lock guard
// -------------------
// Every sweep pass grabs `pg_try_advisory_lock(kSimReaperAdvisoryLockKey)`
// before touching podman or writing DB rows. If a peer backend replica
// holds the lock we skip this pass and try again next tick. The lock is
// released at the end of the sweep so a stuck backend can't hold it
// forever — but even if it did, the sweep resumes on next restart.
//
// Also — critically — `SimLobbyController::handleStopMatch` does NOT
// take this lock. The synchronous stop path is idempotent by
// construction (podman 404 on already-gone container = success), so if
// the reaper and a caller race, the loser sees "already_gone" and
// moves on. The lock only serializes reaper-vs-reaper.
//
// Lifecycle
// ---------
//   * Singleton; `start()` is idempotent (no-op on second call).
//   * `start()` first runs a synchronous `runOnce()` so any detritus
//     from a previous backend crash is cleaned up before /api/sim
//     serves its first request.
//   * `stop()` sets running_=false, joins the thread. Called only in
//     tests / shutdown paths.
//
// Env config
// ----------
//   FH_SIM_ORCHESTRATOR_ENABLED — same feature-flag as SimOrchestrator.
//     If unset/0 the reaper doesn't start (nothing to reap when
//     orchestration is off).
//   FH_SIM_REAPER_INTERVAL_SEC — override the 300s default. Values <5
//     are clamped to 5 (prevents accidental tight loops). Used by the
//     smoke test to observe a sweep in seconds instead of minutes.
//
// =============================================================================
#include <atomic>
#include <chrono>
#include <thread>

namespace fh::orchestration {

// Advisory-lock key. Chosen as ASCII "SIM_REAP" packed into an int64 so
// `SELECT * FROM pg_locks WHERE locktype='advisory'` shows a memorable
// classid+objid pair when debugging. Stable across releases — changing
// this value would let two backends of different versions race.
inline constexpr long long kSimReaperAdvisoryLockKey = 0x53494D5F52454150LL;

class SimReaper {
public:
    struct SweepResult {
        int  containers_reaped        = 0;
        int  rows_marked_abandoned    = 0;
        int  errors                   = 0;
        bool skipped_lock_contention  = false;
        bool skipped_orchestrator_off = false;
    };

    static SimReaper& getInstance();

    // Spawn the sweep thread. Idempotent.
    void start();

    // Signal + join the sweep thread. Idempotent.
    void stop();

    // Perform one reconciliation pass. Public for testability +
    // for main.cpp to run once at startup before entering the
    // periodic loop.
    SweepResult runOnce();

private:
    SimReaper() = default;
    ~SimReaper();
    SimReaper(const SimReaper&) = delete;
    SimReaper& operator=(const SimReaper&) = delete;

    void run();  // thread body

    std::thread          thread_;
    std::atomic<bool>    running_{false};
    std::atomic<bool>    started_{false};
    std::chrono::seconds interval_{300};
};

} // namespace fh::orchestration
