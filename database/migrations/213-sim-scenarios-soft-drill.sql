-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 213: sim_scenarios seed for soft_drill (id=3)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M1 demo scenario for Slice 17.5: 105×68 m pitch, playable
-- area restricted to a 40×30 m rectangle centred at the pitch origin
-- (x ∈ [-20, +20], y ∈ [-15, +15]) with Soft-mode pushback. Players
-- who leave the drill zone are NOT snapped back — instead they
-- receive an inward-facing velocity delta proportional to how far
-- they've strayed (via PlayableAreaConstraint::apply_soft; default
-- stiffness k = 4/s is set in Match.cpp).
--
-- One SlotSpawn (slot 1) is provided at the drill-zone centre.
-- Unclaimed slots default to WanderController, which passively
-- exercises the Soft boundary.
--
-- Scenario ID contract (per §22.9, established by migration 204):
--   * IDs are hand-managed integers ≥ 0.
--   * Each new scenario adds BOTH a DB row here AND a runtime branch
--     in sim/src/tools/Replay.cpp::makeScenario.
--   * `sim_matches.scenario_id` FKs into this table; Replay uses the
--     stored id to reconstruct the correct Scenario subclass.
--
-- ID assignments so far:
--   0 = empty_pitch       (migration 200 + 204)
--   1 = ball_on_pitch     (migration 207)
--   2 = half_pitch_hard   (migration 212)
--   3 = soft_drill        (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe.
-- setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't
-- collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 17.5
--   sim/src/scenario/SoftDrillScenario.{hpp,cpp}
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=3)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (3, 'soft_drill', 'Soft Drill Zone',
     '105×68 m pitch. Playable area = 40×30 m drill-zone rectangle '
     '(x ∈ [-20, +20], y ∈ [-15, +15]) centred at the pitch origin '
     'with Soft-mode pushback. One demo slot for Slice 17.5.',
     1, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 3)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migration 204/207/212).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'soft_drill' AND id = 3) THEN
        RAISE EXCEPTION
            'migration 213 post-check failed: soft_drill is not at id=3';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 213.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
