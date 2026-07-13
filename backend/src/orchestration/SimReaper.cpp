// =============================================================================
// SimReaper — impl. See SimReaper.h for the design contract.
// =============================================================================
#include "SimReaper.h"

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../models/SimRunningMatch.h"
#include "SimOrchestrator.h"

#include <cstdlib>
#include <exception>
#include <iostream>
#include <mutex>
#include <string>

namespace fh::orchestration {

namespace {

// Read FH_SIM_REAPER_INTERVAL_SEC, clamped to >=5s. Zero/negative/unset
// falls back to the default 300s. The clamp is a guard rail — a
// 0.1-second sweep loop hammering podman would be catastrophic.
std::chrono::seconds intervalFromEnv() {
    const char* raw = std::getenv("FH_SIM_REAPER_INTERVAL_SEC");
    if (raw == nullptr || raw[0] == '\0') return std::chrono::seconds(300);
    try {
        long v = std::stol(raw);
        if (v < 5) v = 5;
        return std::chrono::seconds(v);
    } catch (...) {
        return std::chrono::seconds(300);
    }
}

} // namespace

SimReaper& SimReaper::getInstance() {
    static SimReaper instance;
    return instance;
}

SimReaper::~SimReaper() {
    stop();
}

void SimReaper::start() {
    bool expected = false;
    if (!started_.compare_exchange_strong(expected, true)) {
        return;  // already started
    }

    // Refuse to run without orchestrator feature-flag on. Reaper without
    // orchestrator is a semantics bug — nothing launches containers, so
    // "reaping" them would just be destroying somebody else's containers
    // that happen to share the name prefix.
    fh::orchestration::SimOrchestratorConfig cfg = loadConfigFromEnv();
    if (!cfg.enabled) {
        std::cout << "[sim-reaper] disabled (FH_SIM_ORCHESTRATOR_ENABLED=0)"
                  << std::endl;
        started_ = false;
        return;
    }

    interval_ = intervalFromEnv();

    // Synchronous startup sweep: clean up anything left over from a
    // previous backend crash BEFORE the HTTP listener starts serving
    // /api/sim requests. Runs under the same advisory lock as the
    // periodic passes so a parallel replica starting at the same time
    // doesn't double-sweep.
    std::cout << "[sim-reaper] startup sweep begin (interval="
              << interval_.count() << "s)" << std::endl;
    SweepResult sr = runOnce();
    std::cout << "[sim-reaper] startup sweep done: reaped="
              << sr.containers_reaped
              << " abandoned=" << sr.rows_marked_abandoned
              << " errors=" << sr.errors
              << (sr.skipped_lock_contention ? " (skipped: lock contention)" : "")
              << std::endl;

    running_ = true;
    thread_ = std::thread(&SimReaper::run, this);
}

void SimReaper::stop() {
    if (!running_.exchange(false)) return;
    if (thread_.joinable()) {
        thread_.join();
    }
    started_ = false;
}

void SimReaper::run() {
    // Sleep-then-sweep loop. We sleep FIRST because start() already ran
    // the initial sweep synchronously — waking up immediately here
    // would just double-sweep with no orphans to find.
    //
    // The sleep is broken into 1-second chunks so stop() gets a
    // responsive shutdown (worst case: 1 second wait, not 5 minutes).
    while (running_.load()) {
        for (int i = 0; i < interval_.count(); ++i) {
            if (!running_.load()) return;
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
        if (!running_.load()) return;

        try {
            SweepResult sr = runOnce();
            if (sr.containers_reaped > 0
                || sr.rows_marked_abandoned > 0
                || sr.errors > 0) {
                std::cout << "[sim-reaper] sweep: reaped="
                          << sr.containers_reaped
                          << " abandoned=" << sr.rows_marked_abandoned
                          << " errors=" << sr.errors << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "[sim-reaper] uncaught in sweep: " << e.what()
                      << std::endl;
        }
    }
}

SimReaper::SweepResult SimReaper::runOnce() {
    SweepResult r;

    fh::orchestration::SimOrchestratorConfig cfg = loadConfigFromEnv();
    if (!cfg.enabled) {
        r.skipped_orchestrator_off = true;
        return r;
    }

    Database* db = Database::getInstance();
    if (db == nullptr) {
        r.errors++;
        return r;
    }

    // -----------------------------------------------------------------
    // Advisory-lock guard. pg_try_advisory_lock is non-blocking; if a
    // peer replica already holds it, `got` is false and we skip this
    // pass. Lock is released at the bottom of this function under a
    // try/catch so a mid-sweep exception can't wedge future passes.
    // -----------------------------------------------------------------
    try {
        auto lk = db->query(
            "SELECT pg_try_advisory_lock($1::bigint) AS got",
            {std::to_string(kSimReaperAdvisoryLockKey)});
        if (lk.empty() || !lk[0]["got"].as<bool>()) {
            r.skipped_lock_contention = true;
            return r;
        }
    } catch (const std::exception& e) {
        std::cerr << "[sim-reaper] advisory-lock acquire failed: "
                  << e.what() << std::endl;
        r.errors++;
        return r;
    }

    // Anything that returns from here on MUST release the lock. Use a
    // scope guard so exceptions in the body don't leak the lock.
    struct LockGuard {
        Database* db;
        int&      errors;
        ~LockGuard() {
            try {
                db->query("SELECT pg_advisory_unlock($1::bigint)",
                          {std::to_string(kSimReaperAdvisoryLockKey)});
            } catch (const std::exception& e) {
                std::cerr << "[sim-reaper] advisory-lock release failed: "
                          << e.what() << std::endl;
                ++errors;
            }
        }
    } guard{db, r.errors};

    HttpClient        http;
    SimOrchestrator   orch(cfg, http);

    // -----------------------------------------------------------------
    // Case 1 — Containers still around for ended matches.
    //
    // LIMIT 100 caps the blast radius per pass; the next tick picks up
    // any leftovers. In steady state there should be zero rows here.
    // -----------------------------------------------------------------
    try {
        auto rows = db->query(
            "SELECT srm.match_id, srm.container_id, srm.container_name "
            "  FROM sim_running_matches srm "
            "  JOIN sim_matches sm ON sm.id = srm.match_id "
            " WHERE sm.ended_at IS NOT NULL "
            " ORDER BY srm.launched_at ASC "
            " LIMIT 100");
        for (const auto& row : rows) {
            const long long match_id = row["match_id"].as<long long>();
            const std::string cname  = row["container_name"].as<std::string>();

            if (row["container_id"].is_null()) {
                // Row was insertPending()'d but setContainerId() never
                // fired — the launch crashed mid-way. Nothing to reap
                // on the podman side; just clear the row.
                if (SimRunningMatchRepo::deleteFor(match_id)) {
                    std::cout << "[sim-reaper] cleared pending row match_id="
                              << match_id << " (container never created)"
                              << std::endl;
                }
                continue;
            }

            StopOptions opts;
            opts.container_id  = row["container_id"].as<std::string>();
            opts.grace_seconds = 5;
            StopResult sr = orch.stopMatch(opts);

            if (sr.ok) {
                SimRunningMatchRepo::deleteFor(match_id);
                r.containers_reaped++;
                std::cout << "[sim-reaper] reaped " << cname
                          << " (match_id=" << match_id << " ended"
                          << (sr.already_gone ? ", container already gone" : "")
                          << ")" << std::endl;
            } else {
                std::cerr << "[sim-reaper] reap failed for " << cname
                          << " (match_id=" << match_id << "): " << sr.error
                          << std::endl;
                r.errors++;
                // Leave the row so the next sweep retries. This is
                // safe because sm.ended_at IS NOT NULL means no one
                // is actively using match_id.
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "[sim-reaper] case-1 sweep failed: " << e.what()
                  << std::endl;
        r.errors++;
    }

    // -----------------------------------------------------------------
    // Case 2 — Open matches whose container is gone.
    //
    // Probe each container via `GET /containers/{id}/json`. 404 or a
    // non-Running state means the container died; mark the match
    // abandoned. Transport errors are ignored (next sweep retries).
    // -----------------------------------------------------------------
    try {
        auto rows = db->query(
            "SELECT srm.match_id, srm.container_id, srm.container_name "
            "  FROM sim_running_matches srm "
            "  JOIN sim_matches sm ON sm.id = srm.match_id "
            " WHERE sm.ended_at IS NULL "
            "   AND srm.container_id IS NOT NULL "
            " ORDER BY srm.launched_at ASC "
            " LIMIT 100");
        for (const auto& row : rows) {
            const long long match_id = row["match_id"].as<long long>();
            const std::string cid    = row["container_id"].as<std::string>();
            const std::string cname  = row["container_name"].as<std::string>();

            const std::string url =
                std::string("http://d/v1.41/containers/") + cid + "/json";
            HttpClient::Response resp =
                http.get(url, {}, cfg.podman_socket_path);

            if (!resp.error.empty()) {
                // Transport error — podman socket blip. Skip; next
                // sweep will retry. Not an r.errors++ — this happens
                // during podman daemon restarts and shouldn't spam
                // the log.
                continue;
            }

            bool container_gone = false;
            if (resp.status == 404) {
                container_gone = true;
            } else if (resp.status == 200) {
                // Cheap substring check — we're only looking for the
                // presence of `"Running":true`. Anything else (Exited,
                // Dead, Created but not started, Paused) means the
                // daemon isn't ticking, so mark abandoned. Full JSON
                // parsing here would drag nlohmann/json into a hot
                // path for a boolean we can spot with strncmp.
                container_gone =
                    (resp.body.find("\"Running\":true") == std::string::npos);
            } else {
                // Unexpected HTTP status — log once + skip.
                std::cerr << "[sim-reaper] podman inspect " << cname
                          << " returned HTTP " << resp.status << std::endl;
                continue;
            }

            if (!container_gone) continue;

            // Container is gone or dead — mark the match abandoned.
            // AND-guard on ended_at IS NULL so the sim daemon's own
            // MatchEnd write (if it beat us here) wins. sim_matches
            // ON DELETE CASCADE handles srm cleanup, but we DELETE
            // srm explicitly so a follow-up sweep doesn't re-inspect
            // the same dead container.
            try {
                db->query(
                    "UPDATE sim_matches SET ended_at = NOW() "
                    " WHERE id = $1::bigint AND ended_at IS NULL",
                    {std::to_string(match_id)});
                SimRunningMatchRepo::deleteFor(match_id);
                r.rows_marked_abandoned++;
                std::cout << "[sim-reaper] marked match_id=" << match_id
                          << " abandoned (container " << cname
                          << " gone/dead)" << std::endl;
            } catch (const std::exception& e) {
                std::cerr << "[sim-reaper] abandon-mark failed for match_id="
                          << match_id << ": " << e.what() << std::endl;
                r.errors++;
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "[sim-reaper] case-2 sweep failed: " << e.what()
                  << std::endl;
        r.errors++;
    }

    return r;
}

} // namespace fh::orchestration
