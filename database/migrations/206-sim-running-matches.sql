-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 206: footballhome_sim — sim_running_matches table
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 14.2 of M1 (see sim/DESIGN.md §23.3). Introduces a persistent
-- registry of every running per-match sim daemon container. One row per
-- live `footballhome_sim_${match_id}` container. Written by
-- SimOrchestrator::launchMatch (Slice 14.3) at container-start time and
-- deleted by SimOrchestrator::stopMatch / the reaper thread (Slice
-- 14.5 / 14.6) at container-stop time.
--
-- Why persist this (vs. a pure in-memory map)? Two reasons:
--   1. The backend can crash + restart while sim daemons keep running
--      (their containers survive backend death because they're managed
--      by rootful podman on the host). On startup the reaper thread
--      RECONCILES this table against `podman ps` — orphan rows get
--      cleaned up, alive-but-untracked containers can be re-adopted.
--      Per DESIGN.md §16.7 step 9 "backend crash" failure-mode.
--   2. `SimRouter` (Slice 14.4) needs a stable lookup from `match_id`
--      to `container_name` for cross-container HTTP-RPC dispatch —
--      persistent so admin endpoints work after backend restart even
--      when the sim container is still healthy.
--
-- Column notes:
--   * match_id — 1:1 with the sim daemon container. Chosen as PK
--     (not a synthetic id) because there is at most one live daemon per
--     match at a time; UPSERT-on-relaunch semantics fall out naturally.
--     FK to sim_matches(id) with ON DELETE CASCADE so cleaning up a
--     historical match auto-cleans its running-registry row.
--   * container_id — the podman container ID (~64-char hex). Nullable
--     because SimOrchestrator inserts the row BEFORE calling podman's
--     /containers/create (so a mid-launch crash still leaves a
--     reconcilable audit trail), then UPDATEs with the returned ID.
--     Reaper handles NULL rows via `container_name` lookup instead.
--   * container_name — the deterministic name `footballhome_sim_${match_id}`
--     as passed to podman `--name`. Fallback identifier for cases where
--     container_id is not yet set OR the container was recreated with a
--     different id.
--   * launched_at — audit timestamp; also used by the reaper's
--     age-based orphan detection (rows older than N hours where the
--     matching container no longer exists are logged + deleted).
--
-- Columns intentionally NOT added yet (deferred to later sub-slices):
--   * ws_port / admin_port — Slice 14.4 (SimRouter needs them for
--     dynamic upstream selection). For M1 they're 9100/9101 hardcoded.
--   * state / stopped_at / error_message — Slice 14.5 (stop workflow).
--   * last_seen_at — Slice 14.6 (health-check reaper).
-- Adding all of these upfront would violate the "each slice ends with a
-- green ctest gate + a working end-to-end demo" rule from §23.3 by
-- shipping columns nothing reads or writes yet.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE TABLE IF NOT EXISTS sim_running_matches (
    match_id       BIGINT PRIMARY KEY
                       REFERENCES sim_matches(id) ON DELETE CASCADE,
    container_id   TEXT,
    container_name TEXT NOT NULL,
    launched_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Cheap secondary lookup for the reaper's `podman ps` reconciliation
-- pass (iterates by container_name, not match_id). BTREE is fine — the
-- table's expected cardinality is O(hundreds) at most.
CREATE INDEX IF NOT EXISTS sim_running_matches_container_name_idx
    ON sim_running_matches (container_name);

COMMIT;
