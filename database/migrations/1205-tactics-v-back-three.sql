-- 1205 (2026-11-09): 🎯 Tactics — the two back-three match-ups from James's
-- notes (mig 912, formation_matchups) as high-block plans, built like 1197.
-- Owner 11/9 lifted the pause on our plans for these ("yes 1 and 2").
--
-- 3-5-2 (3-2) v 3-5-2: "6 is the libero. 5, 4 take their two strikers.
--   3, 10, 9, 8, 2 take their five mids, 3 and 2 on the wing backs. 11, 7
--   press their back three, one is left free."
--   Sides (board: their right = our left): 5 on their 7, 4 on their 11;
--   3 on their 2, 2 on their 3 (wing-backs); 10 on their 8, 9 on their 9,
--   8 on their 10 (intercept stance).
--
-- 4-4-2 v 3-4-3 (2-3): "5 is the libero. 4 takes their striker, 3 and 2
--   their wingers. 11, 8, 6, 7 take their four mids. 10, 9 press their
--   back three, one is left free."
--   Sides: 4 on their 9; 3 on their 7, 2 on their 11; 11 on their 2,
--   7 on their 3 (wide mids, goal side); 8 on their 8, 6 on their 10
--   (intercept).
--
-- Front two in both: at the goal kick our left striker shadows their 4
-- (their right centre-back), our right striker their 5; their middle
-- centre-back (6) is the free man.  Steps: ball to their 6 → left striker
-- presses 6 cutting off 4, right keeps 5's shadow; ball to their 4 → left
-- presses 4 cutting off 6, right slides in to shadow 6 (their 5, far side,
-- free); ball to their 5 mirrored.
--
-- Their goal-kick shapes are [FH] ESTIMATES, not measured: three centre-
-- backs split across the box (x 22/50/78), wing-backs high and wide,
-- mids in front.  They live only in these plans' tactic_state_opponents,
-- never in tactic_buildout_shapes (measured only, mig 1198).  Every job is
-- a dropdown value for the coach to change.

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
  ON CONFLICT (plan_id, parent_state_id, ball_with) WHERE copied_from IS NULL DO NOTHING
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

-- us v them (high block) from their goal-kick shape `opps` [[n,x,y]…]:
-- root jobs, the front two (lft = our left striker, rgt = our right) on
-- their back three, then the three steps.  Skips a plan that has states.
CREATE FUNCTION pg_temp.fh_back3(us text, them text, opps jsonb, lft int, rgt int, jobs jsonb) RETURNS void AS $$
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
  SELECT root, (o->>0)::smallint, (o->>1)::numeric, (o->>2)::numeric FROM jsonb_array_elements(opps) o;
  PERFORM pg_temp.fh_jobs(root, jobs || jsonb_build_array(
    jsonb_build_object('pos', lft, 'kind', 'cover_shadow', 'targets', jsonb_build_array(4)),
    jsonb_build_object('pos', rgt, 'kind', 'cover_shadow', 'targets', jsonb_build_array(5))));
  PERFORM pg_temp.fh_step(root, 6, jsonb_build_array(
    jsonb_build_object('pos', lft, 'kind', 'cover_shadow', 'targets', jsonb_build_array(4), 'b', 6)));
  PERFORM pg_temp.fh_step(root, 4, jsonb_build_array(
    jsonb_build_object('pos', lft, 'kind', 'cover_shadow', 'targets', jsonb_build_array(6), 'b', 4),
    jsonb_build_object('pos', rgt, 'kind', 'cover_shadow', 'targets', jsonb_build_array(6))));
  PERFORM pg_temp.fh_step(root, 5, jsonb_build_array(
    jsonb_build_object('pos', rgt, 'kind', 'cover_shadow', 'targets', jsonb_build_array(6), 'b', 5),
    jsonb_build_object('pos', lft, 'kind', 'cover_shadow', 'targets', jsonb_build_array(6))));
END $$ LANGUAGE plpgsql;

SELECT pg_temp.fh_back3('3-5-2 (3-2)', '3-5-2 (3-2)',
  '[[1,50,96],[4,22,90],[6,50,86],[5,78,90],[2,4,66],[3,96,66],
    [8,35,70],[9,50,76],[10,65,70],[7,38,48],[11,62,48]]'::jsonb,
  11, 7, '[
  {"pos":6,"kind":"libero"},
  {"pos":5,"kind":"mark","targets":[7]},
  {"pos":4,"kind":"mark","targets":[11]},
  {"pos":3,"kind":"mark","targets":[2]},
  {"pos":2,"kind":"mark","targets":[3]},
  {"pos":10,"kind":"mark","targets":[8],"stance":"intercept"},
  {"pos":9,"kind":"mark","targets":[9],"stance":"intercept"},
  {"pos":8,"kind":"mark","targets":[10],"stance":"intercept"}]'::jsonb);

SELECT pg_temp.fh_back3('4-4-2', '3-4-3 (2-3)',
  '[[1,50,96],[4,22,90],[6,50,86],[5,78,90],[2,4,66],[3,96,66],
    [8,40,74],[10,60,74],[7,18,50],[9,50,46],[11,82,50]]'::jsonb,
  10, 9, '[
  {"pos":5,"kind":"libero"},
  {"pos":4,"kind":"mark","targets":[9]},
  {"pos":3,"kind":"mark","targets":[7]},
  {"pos":2,"kind":"mark","targets":[11]},
  {"pos":11,"kind":"mark","targets":[2]},
  {"pos":7,"kind":"mark","targets":[3]},
  {"pos":8,"kind":"mark","targets":[8],"stance":"intercept"},
  {"pos":6,"kind":"mark","targets":[10],"stance":"intercept"}]'::jsonb);
