-- 🎯 Tactics: Cover over the top + the two press steps off the goal kick in
-- the 3-5-2 (2-1-2) v 4-3-3 high plan (owner 2026-11-07: "our 3 to press
-- from a cover shadow of their 11 to the 2 … our 4 … does not have to
-- initially be in tight coverage of their 11 but instead be back and in and
-- cover the ball over the top of the 11 … also help with support coverage
-- of the 9 … mirrored on the other side when their 2 or 3 has ball";
-- agreed reading: their 11 is on their 3's side, their 7 on their 2's).
--
-- The rule (shared/tactics/TacticGeometry.hpp CoverOverTopRule): lane_t of
-- the way from A toward B, then dist_m toward our goal.  A third of the way
-- in and 8 m deep to start; tune here, not in code.  Concept = cover
-- ("Cover the presser") — he covers the man pressing the full back.

INSERT INTO tactic_job_rules (code, label, sort_order)
VALUES ('cover_over_top', 'Behind one man, part of the way toward another, deep enough for the ball over the top', 8)
ON CONFLICT (code) DO NOTHING;

INSERT INTO tactic_job_kinds (code, concept_id, label, target_a_label, target_b_label, dist_m, press_m, sort_order, multi_a, lane_t, rule)
VALUES ('cover_over_top', (SELECT id FROM game_concepts WHERE name = 'cover'), 'Cover over the top',
        'behind', 'help on', 8.0, NULL, 5, false, 0.33, 'cover_over_top')
ON CONFLICT (code) DO NOTHING;

-- Two steps under the plan's goal kick, each a copy of the goal kick's
-- opponents and jobs, then:
--   ball to their 3: our 2 cover-shadows 11 then presses 3; our 4 covers over the top of 11, helps on 9.
--   ball to their 2: our 3 cover-shadows 7 then presses 2;  our 5 covers over the top of 7, helps on 9;
--                    our 4 (the far centre back, the mirror of our 5 in the other step) holds his spot.
DO $$
DECLARE
  gk int;
  st int;
  step record;
BEGIN
  SELECT s.id INTO gk
    FROM tactic_states s
    JOIN tactic_plans p ON p.id = s.plan_id
    JOIN formations f ON f.id = p.formation_id
    JOIN formations o ON o.id = p.opponent_formation_id
   WHERE f.code = '3-5-2 (2-1-2)' AND o.code = '4-3-3' AND p.moment = 'out_of_possession'
     AND p.block_height = 'high' AND s.parent_state_id IS NULL AND s.restart = 'goal_kick';
  IF gk IS NULL THEN RAISE NOTICE 'no 3-5-2 (2-1-2) v 4-3-3 goal kick state'; RETURN; END IF;

  FOR step IN SELECT * FROM (VALUES
      (3, 2, 11, 4, 11, NULL::int),
      (2, 3,  7, 5,  7, 4)
    ) v(ball, presser, shadow, coverer, behind, clear_pos)
  LOOP
    IF EXISTS (SELECT 1 FROM tactic_states WHERE parent_state_id = gk AND ball_with = step.ball) THEN CONTINUE; END IF;

    INSERT INTO tactic_states (plan_id, parent_state_id, ball_with)
    SELECT plan_id, gk, step.ball FROM tactic_states WHERE id = gk RETURNING id INTO st;

    INSERT INTO tactic_state_opponents (state_id, number, x, y)
    SELECT st, number, x, y FROM tactic_state_opponents WHERE state_id = gk;

    INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance)
    SELECT st, position_id, kind, target_b, partner_position_id, stance
      FROM tactic_jobs WHERE state_id = gk AND position_id NOT IN (step.presser, step.coverer, COALESCE(step.clear_pos, 0));
    INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
    SELECT st, position_id, number, ord
      FROM tactic_job_targets WHERE state_id = gk AND position_id NOT IN (step.presser, step.coverer, COALESCE(step.clear_pos, 0));

    INSERT INTO tactic_jobs (state_id, position_id, kind, target_b) VALUES
      (st, step.presser, 'cover_shadow', step.ball),
      (st, step.coverer, 'cover_over_top', 9);
    INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES
      (st, step.presser, step.shadow, 1),
      (st, step.coverer, step.behind, 1);
  END LOOP;
END $$;
