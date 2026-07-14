-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 212: sim_scenarios seed for half_pitch_hard (id=2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M1 demo scenario for Slice 17.4: 105×68 m pitch, playable
-- area restricted to the east half rectangle (x ∈ [0, 52.5],
-- y ∈ [-34, +34]) with Hard-mode boundary clamp (positions snap
-- back at the wall, outward-facing velocity is zeroed).
--
-- Two SlotSpawns are provided (slots 1 & 2) so a claiming client can
-- walk toward the west or east wall and observe the Hard clamp in
-- action. Unclaimed slots default to WanderController, which also
-- exercises the boundary passively.
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
--   2 = half_pitch_hard   (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe.
-- setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't
-- collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 17.4
--   sim/src/scenario/HalfPitchScenario.{hpp,cpp}
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (2, 'half_pitch_hard', 'Half Pitch (Hard)',
     '105×68 m pitch. Playable area = east half rectangle '
     '(x ∈ [0, 52.5], y ∈ [-34, +34]) with Hard-mode boundary clamp. '
     'Two demo slots for Slice 17.4.',
     1, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 2)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migration 204/207).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'half_pitch_hard' AND id = 2) THEN
        RAISE EXCEPTION
            'migration 212 post-check failed: half_pitch_hard is not at id=2';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 212.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
