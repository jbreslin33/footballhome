-- 1197 (2026-11-09): 🎯 Tactics — two more of James's match-up notes
-- (mig 912, formation_matchups) as high-block plans, built like 1196.
--
-- 4-2-3-1 v 4-3-3: "5 is the libero. 4 takes their striker, 3 and 2 their
--   wingers. 8, 6 take their two central mids, 10 their holding mid. 11, 9,
--   7 press their back four, one is left free."
--   Sides: 3 (left) on their 7, 2 on their 11; 8 (left) on their 8, 6 on
--   their 10, 10 on their 6 (mids in intercept stance).  Their goal-kick
--   shape = the 4-3-3 one already in tactic_buildout_shapes (James + DFL).
--
-- 3-4-3 (2-3) v 4-4-2: "6 is the libero. 5, 4 take their two strikers.
--   3, 10, 8, 2 take their four mids. 11, 9, 7 press their back four, one
--   is left free."
--   Sides: 5 (left) on their 9, 4 on their 10; 3 on their 7, 10 on their 6,
--   8 on their 8, 2 on their 11.  Their 4-4-2 goal-kick shape is an [FH]
--   ESTIMATE, not measured: back four, keeper and wide men as the 4-3-3
--   one; centre mids side by side at y 68 (x 40 / 60), strikers at y 45
--   (x 40 / 60).
--
-- Front three in both (as 1196): at the goal kick 11 shadows their 2, 7
-- their 3, 9 splits their 4 and 5.  Steps: ball to their 4 → 11 presses 4
-- cutting off 2, 9 shadows 5; to 5 mirrored; to 2 → 11 touchline trap,
-- 9 shadows 4; to 3 mirrored.  Their far full-back is the free man.
-- Every job is a dropdown value for the coach to change.

INSERT INTO tactic_buildout_shapes (formation_id, number, x, y)
SELECT f.id, v.n, v.x, v.y FROM formations f,
  (VALUES (1,50,96),(2,3,78),(3,97,75),(4,28,93),(5,72,93),
          (6,40,68),(8,60,68),(7,3,52),(11,97,50),(9,40,45),(10,60,45)) AS v(n,x,y)
 WHERE f.code = '4-4-2'
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

-- A high-block plan us v them from their goal-kick shape: root jobs, then
-- the front three's four steps.  Skips a plan that already has states.
CREATE FUNCTION pg_temp.fh_matchup(us text, them text, jobs jsonb) RETURNS void AS $$
DECLARE pid int; root int;
BEGIN
  INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
  SELECT f.id, o.id, 'out_of_possession', 'high' FROM formations f, formations o
   WHERE f.code = us AND o.code = them
  ON CONFLICT DO NOTHING;
  SELECT p.id INTO pid FROM tactic_plans p
    JOIN formations f ON f.id = p.formation_id AND f.code = us
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = them
   WHERE p.moment = 'out_of_possession' AND p.block_height = 'high';
  IF pid IS NULL OR EXISTS (SELECT 1 FROM tactic_states WHERE plan_id = pid) THEN RETURN; END IF;
  INSERT INTO tactic_states (plan_id, ball_with, restart) VALUES (pid, 1, 'goal_kick') RETURNING id INTO root;
  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT root, b.number, b.x, b.y FROM tactic_buildout_shapes b JOIN formations o ON o.id = b.formation_id AND o.code = them;
  PERFORM pg_temp.fh_jobs(root, jobs || '[
    {"pos":11,"kind":"cover_shadow","targets":[2]},
    {"pos":7,"kind":"cover_shadow","targets":[3]},
    {"pos":9,"kind":"deter","targets":[4,5]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 4, '[{"pos":11,"kind":"cover_shadow","targets":[2],"b":4},{"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 5, '[{"pos":7,"kind":"cover_shadow","targets":[3],"b":5},{"pos":9,"kind":"cover_shadow","targets":[4]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 2, '[{"pos":11,"kind":"touchline-trap","targets":[2]},{"pos":9,"kind":"cover_shadow","targets":[4]}]'::jsonb);
  PERFORM pg_temp.fh_step(root, 3, '[{"pos":7,"kind":"touchline-trap","targets":[3]},{"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb);
END $$ LANGUAGE plpgsql;

SELECT pg_temp.fh_matchup('4-2-3-1', '4-3-3', '[
  {"pos":5,"kind":"libero"},
  {"pos":4,"kind":"mark","targets":[9]},
  {"pos":3,"kind":"mark","targets":[7]},
  {"pos":2,"kind":"mark","targets":[11]},
  {"pos":8,"kind":"mark","targets":[8],"stance":"intercept"},
  {"pos":6,"kind":"mark","targets":[10],"stance":"intercept"},
  {"pos":10,"kind":"mark","targets":[6],"stance":"intercept"}]'::jsonb);

SELECT pg_temp.fh_matchup('3-4-3 (2-3)', '4-4-2', '[
  {"pos":6,"kind":"libero"},
  {"pos":5,"kind":"mark","targets":[9]},
  {"pos":4,"kind":"mark","targets":[10]},
  {"pos":3,"kind":"mark","targets":[7]},
  {"pos":10,"kind":"mark","targets":[6],"stance":"intercept"},
  {"pos":8,"kind":"mark","targets":[8],"stance":"intercept"},
  {"pos":2,"kind":"mark","targets":[11]}]'::jsonb);
