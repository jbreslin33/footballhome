-- 1195 (2026-11-09): 🎯 Tactics — the low block's central trigger.
--
-- The low blocks v 4-3-3 (3-R2, 3-L2, 2-2-1, 2-1-2) triggered only on the
-- ball out wide (their 7 / 11, migs 1185-1187).  The ball into their 8 or
-- 10 in front of the block is the other moment: the near centre mid steps
-- out to contain him (no dive, no turn), everyone else stays packed.
-- All four shapes share the wide-centre mids (8 right, 10 left):
--   ball to their 8 (on our left):  10 engage-or-contain 8.
--   ball to their 10 (on our right): 8 engage-or-contain 10.
-- Copied from the goal kick (zonal shape), only that man changes.
-- Every step and job is a dropdown value for the coach to change.

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

CREATE FUNCTION pg_temp.fh_root(us text, block text) RETURNS int AS $$
  SELECT s.id FROM tactic_states s
    JOIN tactic_plans p ON p.id = s.plan_id
    JOIN formations f ON f.id = p.formation_id AND f.code = us
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = '4-3-3'
   WHERE p.moment = 'out_of_possession' AND p.block_height = block AND s.parent_state_id IS NULL
$$ LANGUAGE sql;

DO $$
DECLARE us text;
BEGIN
  FOREACH us IN ARRAY ARRAY['3-5-2 (3-R2)', '3-5-2 (3-L2)', '3-4-3 (2-2-1)', '3-5-2 (2-1-2)'] LOOP
    PERFORM pg_temp.fh_step(pg_temp.fh_root(us, 'low'), 8,
      '[{"pos":10,"kind":"engage-or-contain","targets":[8]}]'::jsonb);
    PERFORM pg_temp.fh_step(pg_temp.fh_root(us, 'low'), 10,
      '[{"pos":8,"kind":"engage-or-contain","targets":[10]}]'::jsonb);
  END LOOP;
END $$;
