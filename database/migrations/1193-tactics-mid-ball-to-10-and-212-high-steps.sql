-- 1193 (2026-11-09): 🎯 Tactics — the missing mirror steps.
--
-- Mid blocks v 4-3-3 had only the "ball to their 8" trigger (their
-- left-centre mid, on our left).  Their 10 stands in the mirror spot, so
-- "ball to their 10" mirrors it: the press and cover men swap sides, the
-- wing-backs keep their wingers (3 on their 7, 2 on their 11).
--   3-R2 / 3-L2 mid:   8 nearest-decides 10 (was 10 on their 8), 9 covers.
--   2-2-1 / 2-1-2 mid: 7 nearest-decides 10 (was 11 on their 8), 8 covers.
--
-- 3-5-2 (2-1-2) high v 4-3-3 had their 3 and 2 only.  Added, copied from
-- the goal kick with one change each:
--   ball to their 4: our 11 (on 4) goes — shadows the keeper, presses 4.
--   ball to their 5: our 7 (on 5) goes — shadows the keeper, presses 5.
--   ball to their 6: our 9 (on 6) nearest-decides.
--
-- 3-4-3 (2-2-1) high is left as James has drawn it (no one on their 5,
-- its steps carry only the four shadows) — his to finish.
--
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
DECLARE
  wbs jsonb := '[{"pos":3,"kind":"mark","targets":[7]},{"pos":2,"kind":"mark","targets":[11]}]';
BEGIN
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (3-R2)', 'mid'), 10, wbs || '[
    {"pos":8,"kind":"nearest-decides","targets":[10]},{"pos":9,"kind":"cover"}]'::jsonb);
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (3-L2)', 'mid'), 10, wbs || '[
    {"pos":8,"kind":"nearest-decides","targets":[10]},{"pos":9,"kind":"cover"}]'::jsonb);
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-4-3 (2-2-1)', 'mid'), 10, wbs || '[
    {"pos":7,"kind":"nearest-decides","targets":[10]},{"pos":8,"kind":"cover"}]'::jsonb);
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (2-1-2)', 'mid'), 10, wbs || '[
    {"pos":7,"kind":"nearest-decides","targets":[10]},{"pos":8,"kind":"cover"}]'::jsonb);

  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (2-1-2)', 'high'), 4,
    '[{"pos":11,"kind":"cover_shadow","targets":[1],"b":4}]'::jsonb);
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (2-1-2)', 'high'), 5,
    '[{"pos":7,"kind":"cover_shadow","targets":[1],"b":5}]'::jsonb);
  PERFORM pg_temp.fh_step(pg_temp.fh_root('3-5-2 (2-1-2)', 'high'), 6,
    '[{"pos":9,"kind":"nearest-decides","targets":[6]}]'::jsonb);
END $$;
