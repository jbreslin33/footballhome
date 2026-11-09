-- 1196 (2026-11-09): 🎯 Tactics — 2-3-2-3 v 4-2-3-1, high block, from
-- James's own match-up note (mig 912, formation_matchups):
--   "5 is the libero. 4 takes their striker. 3, 6, 2 take their three
--    attacking mids. 10, 8 take their two holding mids. 11, 9, 7 press
--    their back four, one is left free."
-- (4-2-3-1 is the one opponent shape picked on a game so far — game 9336.)
--
-- Sides (0-100 from our view; their right is our left):
--   3 (left) takes their 7, 6 their 10, 2 (right) their 11;
--   10 (left) takes their 6, 8 (right) their 8 — intercept stance, as in
--   James's 3-R2 midfield; 4 marks their 9 goal-side; 5 = libero.
--   Front three at their goal kick: 11 shadows their 2, 7 their 3 (each
--   ready to press the centre-back on his side), 9 splits their 4 and 5.
-- Steps (one man left free each time, the far full-back):
--   ball to their 4: 11 presses 4 cutting off 2, 9 shadows 5.
--   ball to their 5: 7 presses 5 cutting off 3, 9 shadows 4.
--   ball to their 2: 11 traps on the touchline, 9 shadows 4 (no ball back inside).
--   ball to their 3: 7 traps, 9 shadows 5.
--
-- Their 4-2-3-1 goal-kick shape is an [FH] estimate, NOT measured: the
-- back four, keeper, wingers and 9 as James placed the 4-3-3 one (migs
-- 1135-1139); the two holding mids side by side at y 74
-- (x 40 / 60), the 10 at (50, 58).  Change by migration when James or the
-- DFL cut says otherwise.
-- Every job is a dropdown value for the coach to change.

INSERT INTO tactic_buildout_shapes (formation_id, number, x, y)
SELECT f.id, v.n, v.x, v.y FROM formations f,
  (VALUES (1,50,96),(2,3,78),(3,97,75),(4,28,93),(5,72,93),
          (6,40,74),(8,60,74),(10,50,58),(7,3,52),(11,97,50),(9,50,45)) AS v(n,x,y)
 WHERE f.code = '4-2-3-1'
   AND NOT EXISTS (SELECT 1 FROM tactic_buildout_shapes b WHERE b.formation_id = f.id);

CREATE FUNCTION pg_temp.fh_jobs(sid int, jobs jsonb) RETURNS void AS $$
DECLARE j jsonb; t jsonb; k int;
BEGIN
  FOR j IN SELECT * FROM jsonb_array_elements(jobs) LOOP
    DELETE FROM tactic_jobs WHERE state_id = sid AND position_id = (j->>'pos')::int;
    INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, stance)
    VALUES (sid, (j->>'pos')::int, j->>'kind', (j->>'b')::smallint, COALESCE(j->>'stance', 'goal_side'));
    k := 0;
    FOR t IN SELECT * FROM jsonb_array_elements(COALESCE(j->'targets', '[]'::jsonb)) LOOP
      k := k + 1;
      INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES (sid, (j->>'pos')::int, t::text::smallint, k);
    END LOOP;
  END LOOP;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION pg_temp.fh_step(parent int, ball int, jobs jsonb) RETURNS int AS $$
DECLARE sid int;
BEGIN
  IF parent IS NULL THEN RETURN NULL; END IF;
  INSERT INTO tactic_states (plan_id, parent_state_id, ball_with)
  SELECT plan_id, id, ball FROM tactic_states WHERE id = parent
  ON CONFLICT (plan_id, parent_state_id, ball_with) DO NOTHING
  RETURNING id INTO sid;
  IF sid IS NULL THEN RETURN NULL; END IF;
  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT sid, number, x, y FROM tactic_state_opponents WHERE state_id = parent;
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance)
  SELECT sid, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = parent;
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
  SELECT sid, position_id, number, ord FROM tactic_job_targets WHERE state_id = parent;
  PERFORM pg_temp.fh_jobs(sid, jobs);
  RETURN sid;
END $$ LANGUAGE plpgsql;

DO $$
DECLARE pid int; root int;
BEGIN
  INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
  SELECT f.id, o.id, 'out_of_possession', 'high' FROM formations f, formations o
   WHERE f.code = '2-3-2-3' AND o.code = '4-2-3-1'
  ON CONFLICT DO NOTHING;
  SELECT p.id INTO pid FROM tactic_plans p
    JOIN formations f ON f.id = p.formation_id AND f.code = '2-3-2-3'
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = '4-2-3-1'
   WHERE p.moment = 'out_of_possession' AND p.block_height = 'high';
  IF pid IS NULL OR EXISTS (SELECT 1 FROM tactic_states WHERE plan_id = pid) THEN RETURN; END IF;

  INSERT INTO tactic_states (plan_id, ball_with, restart) VALUES (pid, 1, 'goal_kick') RETURNING id INTO root;
  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT root, b.number, b.x, b.y FROM tactic_buildout_shapes b JOIN formations o ON o.id = b.formation_id AND o.code = '4-2-3-1';

  PERFORM pg_temp.fh_jobs(root, '[
    {"pos":5,"kind":"libero"},
    {"pos":4,"kind":"mark","targets":[9]},
    {"pos":3,"kind":"mark","targets":[7]},
    {"pos":6,"kind":"mark","targets":[10]},
    {"pos":2,"kind":"mark","targets":[11]},
    {"pos":10,"kind":"mark","targets":[6],"stance":"intercept"},
    {"pos":8,"kind":"mark","targets":[8],"stance":"intercept"},
    {"pos":11,"kind":"cover_shadow","targets":[2]},
    {"pos":7,"kind":"cover_shadow","targets":[3]},
    {"pos":9,"kind":"deter","targets":[4,5]}]'::jsonb);

  PERFORM pg_temp.fh_step(root, 4, '[{"pos":11,"kind":"cover_shadow","targets":[2],"b":4},
                                     {"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 5, '[{"pos":7,"kind":"cover_shadow","targets":[3],"b":5},
                                     {"pos":9,"kind":"cover_shadow","targets":[4]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 2, '[{"pos":11,"kind":"touchline-trap","targets":[2]},
                                     {"pos":9,"kind":"cover_shadow","targets":[4]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 3, '[{"pos":7,"kind":"touchline-trap","targets":[3]},
                                     {"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb);
END $$;
