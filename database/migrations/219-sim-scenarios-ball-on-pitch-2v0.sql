-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 219: sim_scenarios seed for ball_on_pitch_2v0 (id=5)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M2 Slice 26.3 short-pass primitive demo scenario:
-- 105×68 m pitch, ball at centre spot at rest, slot 1 spawns 15 m
-- west facing east, slot 2 spawns 15 m east facing west. Both slots
-- are human-claimable; unclaimed slots idle (no wandering AI) so a
-- solo user gets a stationary receiver dummy on the far flank.
--
-- First scenario whose intended play loop requires the wants_kick
-- wire trailer (Slice 26.2) + BallControl release-on-kick +
-- BallPhysics::applyImpulse (Slice 26.3, ADR §22.23). Dribbling the
-- 15 m from spawn to centre spot takes ~4.7 s at the M0
-- max_dribble_speed × dribble_efficiency = 3.2 m/s; a 15 m/s pass
-- (physical.pass_power default from Slice 26.1) covers the same
-- distance in 1 s — the geometry alone teaches the primitive.
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
--   4 = ball_on_pitch_with_defender    (migration 215)
--   5 = ball_on_pitch_2v0              (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe.
-- The setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't
-- collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 26.3, §22.23
--   sim/src/scenario/BallOnPitch2v0Scenario.{hpp,cpp}
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=5)
--   sim/src/main.cpp        (Scenario switch case 5)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (5, 'ball_on_pitch_2v0', 'Ball on Pitch 2v0',
     '105×68 m pitch, ball on centre spot at rest, slot 1 spawns 15 m '
     'west facing east (human-claimable, idle when unclaimed), slot 2 '
     'spawns 15 m east facing west (human-claimable, idle when '
     'unclaimed). Two-versus-zero pass-drill layout: 30 m between the '
     'slots — far enough that passing (physical.pass_power default '
     '15 m/s, ~1 s per 15 m leg) is meaningfully faster than dribbling '
     '(~4.7 s per leg at max_dribble_speed × dribble_efficiency = '
     '3.2 m/s). First scenario whose intended play loop requires the '
     'Slice 26.2 wants_kick wire trailer + Slice 26.3 BallControl '
     'release-on-kick + BallPhysics::applyImpulse.',
     2, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 5)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207/212/213/215).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'ball_on_pitch_2v0' AND id = 5) THEN
        RAISE EXCEPTION
            'migration 219 post-check failed: ball_on_pitch_2v0 is not at id=5';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 219.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
