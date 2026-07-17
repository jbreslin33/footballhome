-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 222: sim_scenarios seed for goal_drill (id=6)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M2 Slice 28.2 shots-on-goal demo scenario.
--
-- Layout (same as ball_on_pitch_2v0 with goal AABBs added):
--   105×68 m pitch, ball at centre spot at rest. Slot 1 spawns 15 m
--   west facing east; Slot 2 spawns 15 m east facing west. Both slots
--   are human-claimable; unclaimed slots idle (parity with 2v0 —
--   solo user gets a stationary target dummy on the far flank).
--
-- What's new vs. ball_on_pitch_2v0:
--   The C++ Scenario now overrides `goalRegions()` (Slice 28.2 /
--   ADR §22.25) and returns two axis-aligned bounding boxes at the
--   pitch ends (west goal index 0, east goal index 1). 7.32 m wide ×
--   2 m deep × 2.44 m tall each. Slice 28.2 lands the geometry only;
--   Match::tick's post-physics goal-detection loop lands in Slice 28.3
--   and Goal events (event_type=9, migration 221) hit the DB from
--   there.
--
-- Scenario ID contract (per §22.9, established by migration 204):
--   * IDs are hand-managed integers ≥ 0.
--   * Each new scenario adds BOTH a DB row here AND runtime branches
--     in sim/src/tools/Replay.cpp::makeScenario AND sim/src/main.cpp
--     (SIM_SCENARIO name→id map and scenario-id switch).
--   * `sim_matches.scenario_id` FKs into this table; Replay uses the
--     stored id to reconstruct the correct Scenario subclass.
--
-- ID assignments so far:
--   0 = empty_pitch                    (migration 200 + 204)
--   1 = ball_on_pitch                  (migration 207)
--   2 = half_pitch_hard                (migration 212)
--   3 = soft_drill                     (migration 213)
--   4 = ball_on_pitch_with_defender    (migration 215)
--   5 = ball_on_pitch_2v0              (migration 219)
--   6 = goal_drill                     (this migration)
--
-- Idempotent: `ON CONFLICT (code_id) DO NOTHING` makes reruns safe.
-- The setval at the end bumps the SMALLSERIAL sequence past every
-- hand-assigned id so any accidental SERIAL-driven insert won't
-- collide.
--
-- See:
--   sim/DESIGN.md §24.3 Slice 28.2, ADR §22.25
--   sim/src/scenario/GoalDrillScenario.{hpp,cpp}
--   sim/src/scenario/Scenario.hpp (GoalRegion + goalRegions())
--   sim/src/tools/Replay.cpp (makeScenario branch for scenario_id=6)
--   sim/src/main.cpp        (SIM_SCENARIO="goal_drill" → case 6)
--   database/migrations/221-sim-decode-event-goal.sql (Goal event decoder)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (6, 'goal_drill', 'Goal Drill',
     '105×68 m pitch, ball on centre spot at rest, slot 1 spawns 15 m '
     'west facing east (human-claimable, idle when unclaimed), slot 2 '
     'spawns 15 m east facing west (human-claimable, idle when '
     'unclaimed). Two axis-aligned goal AABBs at the pitch ends: '
     'west goal index 0 at x∈[-54.5,-52.5], east goal index 1 at '
     'x∈[+52.5,+54.5], both 7.32 m wide × 2.44 m tall (FIFA '
     'regulation), 2 m deep behind the goal line. First scenario '
     'exercising the Slice 28.2 Scenario::goalRegions() API '
     '(ADR §22.25). Match::tick post-physics goal-detection ships in '
     'Slice 28.3; Slice 28.2 lands geometry + DB row only.',
     2, TRUE)
ON CONFLICT (code_id) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 6)
);

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207/212/213/215/219).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_scenarios
                    WHERE code_id = 'goal_drill' AND id = 6) THEN
        RAISE EXCEPTION
            'migration 222 post-check failed: goal_drill is not at id=6';
    END IF;
END $$;

COMMIT;
