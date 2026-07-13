-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 207: sim_scenarios seed for ball_on_pitch (id=1)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M1 demo scenario: 105×68 m pitch, zero player slots, one
-- ball at the centre spot. Ball rolls under passive multiplicative
-- friction (see sim/src/physics/BallPhysics.{hpp,cpp}) and eventually
-- settles at rest.
--
-- Scenario ID contract (per §22.9, established by migration 204):
--   * IDs are hand-managed integers ≥ 0.
--   * Each new scenario adds BOTH a DB row here AND a runtime branch
--     in sim/src/tools/Replay.cpp::makeScenario.
--   * `sim_matches.scenario_id` FKs into this table; Replay uses the
--     stored id to reconstruct the correct Scenario subclass.
--
-- ID assignments so far:
--   0 = empty_pitch     (migration 200 + 204)
--   1 = ball_on_pitch   (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe. The
-- setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 15.3
--   sim/src/scenario/BallOnPitchScenario.{hpp,cpp}
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=1)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (1, 'ball_on_pitch', 'Ball on Pitch',
     '105×68 m pitch, no player slots, one ball on the centre spot. '
     'Demo scenario for M1 passive ball physics.',
     1, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 1)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migration 204).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'ball_on_pitch' AND id = 1) THEN
        RAISE EXCEPTION
            'migration 207 post-check failed: ball_on_pitch is not at id=1';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 207.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
