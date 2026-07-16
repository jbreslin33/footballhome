-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 215: sim_scenarios seed for ball_on_pitch_with_defender (id=4)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M2 Slice 24.3a demo scenario: same geometry as
-- ball_on_pitch (id=1) — 105×68 m pitch, ball at centre spot at rest,
-- slot 1 five metres west facing east, slot 2 five metres east facing
-- west — but slot 2 spawns with a DefenderController that jogs toward
-- the ball every tick instead of standing idle. The point is to give
-- the Slice 25.2 sprint-with-ball feature a *reason*: outrun the AI
-- or lose ground.
--
-- No contest / touch-to-steal mechanic yet — that lands in Slice
-- 24.3b. Until then, if the defender catches the ball owner it just
-- stands on top of them.
--
-- Scenario ID contract (per §22.9, established by migration 204):
--   * IDs are hand-managed integers ≥ 0.
--   * Each new scenario adds BOTH a DB row here AND runtime branches
--     in sim/src/tools/Replay.cpp::makeScenario AND sim/src/main.cpp
--     (Scenario switch).
--   * `sim_matches.scenario_id` FKs into this table; Replay uses the
--     stored id to reconstruct the correct Scenario subclass.
--
-- ID assignments so far:
--   0 = empty_pitch                    (migration 200 + 204)
--   1 = ball_on_pitch                  (migration 207)
--   2 = half_pitch_hard                (migration 212)
--   3 = soft_drill                     (migration 213)
--   4 = ball_on_pitch_with_defender    (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe.
-- The setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't
-- collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 24.3
--   sim/src/scenario/BallOnPitchWithDefenderScenario.{hpp,cpp}
--   sim/src/controller/DefenderController.{hpp,cpp}
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=4)
--   sim/src/main.cpp        (Scenario switch case 4)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (4, 'ball_on_pitch_with_defender', 'Ball on Pitch + Defender',
     '105×68 m pitch, ball on centre spot at rest, slot 1 spawns 5 m '
     'west facing east (human-claimable, idle when unclaimed), slot 2 '
     'spawns 5 m east facing west with a DefenderController AI that '
     'jogs toward the ball every tick. No contest mechanic yet (Slice '
     '24.3b) — if the defender catches the ball owner it stands on '
     'top of them. M2 Slice 24.3a demo.',
     2, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 4)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207/212/213).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'ball_on_pitch_with_defender' AND id = 4) THEN
        RAISE EXCEPTION
            'migration 215 post-check failed: ball_on_pitch_with_defender is not at id=4';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 215.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
