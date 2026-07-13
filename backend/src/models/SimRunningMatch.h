#pragma once

#include <optional>
#include <string>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// SimRunningMatch — row struct + helpers for `sim_running_matches`
// (migration 206). One row per running `footballhome_sim_${match_id}`
// container. Written by SimOrchestrator::launchMatch (Slice 14.3) at
// container-start, updated with the podman container_id once
// `/containers/create` returns, deleted by SimOrchestrator::stopMatch /
// the reaper thread (Slices 14.5 / 14.6).
//
// Naming invariant: the container name is deterministic — every layer
// that needs to talk to a per-match daemon (SimRouter, reaper,
// SimOrchestrator itself) derives it via `containerNameFor(match_id)`.
// Keeping the derivation in one place (this header) means bumping the
// prefix is a single-file change.
//
// Repository shape (Slice 14.3): three free functions in
// `SimRunningMatchRepo::` — insertPending, setContainerId, deleteFor —
// each opens/uses the Database singleton and returns a bool for the
// caller to translate into HTTP 500 vs propagate. Deliberately NOT a
// class-with-methods pattern (like PersonMerge / MensRoster) because
// there's no shared connection state to hold across calls; the
// operations are independent one-shot statements. A full class-with-
// state repository would land only if we later need read APIs that
// batch multiple queries under one transaction.
// ────────────────────────────────────────────────────────────────────────────

namespace fh::orchestration {

struct SimRunningMatch {
    // Foreign key to `sim_matches(id)`. Primary key of this table —
    // there is at most one live sim daemon per match at any moment.
    long long match_id = 0;

    // The podman container ID (~64-char hex string). Empty/nullopt when
    // SimOrchestrator has inserted the row but not yet received the
    // container-create response — see migration 206 header for why the
    // column is nullable.
    std::optional<std::string> container_id;

    // Deterministic name — matches the podman `--name` arg. Filled at
    // INSERT time; the reaper uses this as the fallback identifier
    // when container_id is NULL.
    std::string container_name;

    // ISO-8601 UTC; server-side default is NOW() at INSERT.
    std::string launched_at;
};

// Deterministic container-name derivation. Every layer that needs the
// name of a per-match daemon uses this — SimOrchestrator (podman
// `--name` arg), SimRouter (upstream lookup), reaper (reconciliation
// against `podman ps`). Do not hand-format this string anywhere else.
inline std::string containerNameFor(long long match_id) {
    return "footballhome_sim_" + std::to_string(match_id);
}

namespace SimRunningMatchRepo {

// Insert the pending row BEFORE calling podman /containers/create so
// that a mid-launch backend crash leaves a reconcilable audit trail
// (per DESIGN.md §16.7 step 9). container_id is written as NULL and
// filled in later by `setContainerId`.
//
// Returns false on DB error (already logged to stderr); caller
// translates to HTTP 500. Returns true on success OR on ON CONFLICT
// DO NOTHING (a stale row for the same match_id was already there —
// caller should treat this as "someone else got here first" and
// probably NOT proceed with launch).
bool insertPending(long long match_id,
                   const std::string& container_name);

// Fill in container_id once /containers/create returns success. If
// the row was deleted between insertPending and this call (e.g.
// reaper swept it) we log and return false — caller decides whether
// to abort the launch or continue.
bool setContainerId(long long match_id,
                    const std::string& container_id);

// Rollback path — used when podman /containers/create or /start
// fails after a successful insertPending. Also used by the Slice
// 14.5 stopMatch and the Slice 14.6 reaper. Returns true whether or
// not a row was actually present (deletion is idempotent).
bool deleteFor(long long match_id);

} // namespace SimRunningMatchRepo

} // namespace fh::orchestration
