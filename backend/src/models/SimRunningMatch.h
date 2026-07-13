#pragma once

#include <optional>
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// SimRunningMatch — row struct + helpers for `sim_running_matches`
// (migration 206). One row per running `footballhome_sim_${match_id}`
// container. Written by SimOrchestrator::launchMatch (Slice 14.3) at
// container-start, updated with the podman container_id once
// `/containers/create` returns, deleted by SimOrchestrator::stopMatch /
// the reaper thread (Slices 14.5 / 14.6).
//
// This file is header-only in Slice 14.2 — the repository .cpp lands
// alongside SimOrchestrator::launchMatch in Slice 14.3, which is the
// first place that actually writes to the table. Shipping unused CRUD
// code now would violate the "each slice ends with a green ctest gate +
// a working end-to-end demo" rule from DESIGN.md §23.3.
//
// Naming invariant: the container name is deterministic — every layer
// that needs to talk to a per-match daemon (SimRouter, reaper,
// SimOrchestrator itself) derives it via `containerNameFor(match_id)`.
// Keeping the derivation in one place (this header) means bumping the
// prefix is a single-file change.
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

} // namespace fh::orchestration
