-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 204: sim_scenarios.empty_pitch → id 0 (align DB with runtime enum)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Fixes the DB-vs-runtime scenario-id split that surfaced during
-- sub-slice 8.1 verification (2026-07-13):
--
--   * `sim/src/main.cpp` on startup writes `upsertMatch(scenario_id=0)`
--     — a wire-contract enum value where 0 = EmptyPitchScenario.
--   * `sim/src/tools/Replay.cpp::makeScenario` maps `scenario_id == 0`
--     → EmptyPitchScenario; any other value throws
--     "unknown scenario_id=N (M0 supports only scenario_id=0)".
--   * Migration 200 seeded `sim_scenarios.empty_pitch` at id=1 (the
--     first row of a SMALLSERIAL PRIMARY KEY, which was hand-managed
--     as of migration 203 per §22.9 but had already been assigned 1).
--   * Migration 202 seeded `sim_matches.id=1` with
--     `scenario_id = (SELECT id FROM sim_scenarios WHERE code_id='empty_pitch')`
--     — resolving to 1 at seed time.
--   * `upsertMatch`'s `ON CONFLICT (id) DO UPDATE SET server_version =
--     EXCLUDED.server_version` (per DESIGN §16.6 sub-slice 4:
--     "preserves history but refreshes server_version") deliberately
--     leaves scenario_id untouched on restart. Result: the seeded 1
--     stayed sticky, and every call to `/admin/replay` for match 1
--     returned 500 "unknown scenario_id=1".
--
-- Root cause: the DB used auto-assigned surrogate keys where the code
-- used hand-managed enum values. Correct fix is to make scenario IDs
-- hand-managed enum values in the DB too — the same pattern §22.9
-- already applied to attribute/concept/pattern registries. `empty_pitch`
-- becomes id=0 to match the runtime enum, and the seeded sim_matches
-- row is updated in the same transaction so the FK stays consistent.
--
-- Going-forward contract (documented in DESIGN.md §16.5 additions
-- 2026-07-13): sim_scenarios IDs are hand-managed integers ≥ 0. New
-- scenarios pick the next unused id and add both a DB row here + a
-- runtime branch in Replay.cpp::makeScenario. Never rely on
-- SMALLSERIAL to pick.
--
-- Safe pre-conditions:
--   * sim_matches has one row (id=1) with scenario_id=1 pointing at
--     empty_pitch (verified 2026-07-13).
--   * No sim_match_inputs exist for that row (verified via
--     `SELECT count(*) FROM sim_match_inputs`).
--   * No prod deployment (M0 dev only).
--
-- See sim/DESIGN.md §16.5, §22.9, §22.14.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- -----------------------------------------------------------------------
-- 1) Temporarily drop the child FK so we can renumber the parent PK.
--    (PostgreSQL requires FK-referenced values to exist at every step of
--    a transaction unless the constraint is DEFERRABLE INITIALLY DEFERRED.
--    Migration 200 declared this FK non-deferrable, so drop + rebuild is
--    the cleanest atomic move.)
-- -----------------------------------------------------------------------
ALTER TABLE sim_matches DROP CONSTRAINT sim_matches_scenario_id_fkey;

-- -----------------------------------------------------------------------
-- 2) Renumber the empty_pitch scenario from whatever id it currently has
--    to id=0. Idempotent: no-op if it's already 0. Guarded by code_id so
--    a hypothetical future scenario at id=0 doesn't get clobbered.
-- -----------------------------------------------------------------------
UPDATE sim_scenarios
   SET id = 0
 WHERE code_id = 'empty_pitch'
   AND id <> 0;

-- -----------------------------------------------------------------------
-- 3) Reroute every existing sim_matches row that pointed at the old
--    empty_pitch id to the new one. We can't join on "old empty_pitch
--    row" because it's been mutated above, so we key off the fact that
--    every current sim_matches row IS empty_pitch (M0 has one scenario
--    and the runtime code enforces it). If future migrations introduce
--    more scenarios, this UPDATE will already have run and future
--    inserts will pick their id explicitly.
-- -----------------------------------------------------------------------
UPDATE sim_matches
   SET scenario_id = 0
 WHERE scenario_id NOT IN (SELECT id FROM sim_scenarios);

-- -----------------------------------------------------------------------
-- 4) Re-add the FK with the exact same shape it had in migration 200.
--    Verify the parent row set is coherent before commit (self-check).
-- -----------------------------------------------------------------------
ALTER TABLE sim_matches
    ADD CONSTRAINT sim_matches_scenario_id_fkey
    FOREIGN KEY (scenario_id) REFERENCES sim_scenarios(id);

-- -----------------------------------------------------------------------
-- 5) Self-audit — belt AND suspenders. Fails the transaction if the
--    post-migration invariants don't hold. Any assertion failure means
--    the migration is unsafe to apply on this dataset and someone needs
--    to look at the pre-condition assumptions above.
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'empty_pitch' AND id = 0) THEN
        RAISE EXCEPTION
            'migration 204 post-check failed: empty_pitch is not at id=0';
    END IF;
    IF EXISTS (SELECT 1 FROM sim_matches
                WHERE scenario_id NOT IN (SELECT id FROM sim_scenarios)) THEN
        RAISE EXCEPTION
            'migration 204 post-check failed: sim_matches has scenario_id '
            'with no matching sim_scenarios row';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 204.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
