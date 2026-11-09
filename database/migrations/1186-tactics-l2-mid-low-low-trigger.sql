-- 1186 (2026-11-08): 🎯 Tactics — 3-L2 mid + low blocks, and the low
-- block's trigger (follows 1185).
--
-- 1. 3-5-2 (3-L2) v 4-3-3, mid and low.  The same zonal jobs as 3-R2's
--    (mig 1185) except the front two swap: in 3-L2 our 7 is the high
--    central striker and 11 sits off him, so 7 takes what 3-R2's 11 does
--    and 11 takes what 3-R2's 7 does.  Mid's trigger step is 3-R2's: ball
--    to their 8 = our 10 goes (nearest decides), 9 covers, 3 picks up
--    their 7, 2 picks up their 11.
--
-- 2. The low block's trigger, 3-R2 and 3-L2.  A low block lets their
--    centre mids have it; it springs when the ball goes wide:
--      ball to their 7 (our left): our 3 springs the touchline trap, our
--            10 doubles up on him, our 5 slides across behind.
--      ball to their 11 (our right): our 2 springs the trap, our 8
--            doubles up, our 4 slides across.
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

-- A child step of `parent` with the ball on their `ball`: their men and our
-- jobs copied, then `jobs` replace those men's jobs (existing step untouched).
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
DECLARE blk text; pid int; sid int;
        l2mid int; l2low int; r2low int;
BEGIN
  -- 1. 3-L2 mid + low plans, root = their goal kick in their build-out shape.
  FOREACH blk IN ARRAY ARRAY['mid', 'low'] LOOP
    INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
    SELECT f.id, o.id, 'out_of_possession', blk
      FROM formations f, formations o WHERE f.code = '3-5-2 (3-L2)' AND o.code = '4-3-3'
    ON CONFLICT DO NOTHING;
  END LOOP;
  FOR pid IN
    SELECT p.id FROM tactic_plans p JOIN formations f ON f.id = p.formation_id AND f.code = '3-5-2 (3-L2)'
     WHERE p.block_height IN ('mid', 'low') AND p.moment = 'out_of_possession'
       AND NOT EXISTS (SELECT 1 FROM tactic_states s WHERE s.plan_id = p.id)
  LOOP
    INSERT INTO tactic_states (plan_id, ball_with, restart) VALUES (pid, 1, 'goal_kick') RETURNING id INTO sid;
    INSERT INTO tactic_state_opponents (state_id, number, x, y)
    SELECT sid, number, x, y FROM tactic_buildout_shapes b JOIN formations o ON o.id = b.formation_id AND o.code = '4-3-3';
  END LOOP;

  l2mid := pg_temp.fh_root('3-5-2 (3-L2)', 'mid');
  l2low := pg_temp.fh_root('3-5-2 (3-L2)', 'low');
  r2low := pg_temp.fh_root('3-5-2 (3-R2)', 'low');

  IF l2mid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = l2mid) THEN
    PERFORM pg_temp.fh_jobs(l2mid, '[
      {"pos":7,"kind":"engage-line"},
      {"pos":11,"kind":"close-the-centre"},
      {"pos":8,"kind":"compact-block"},
      {"pos":9,"kind":"pack-the-middle"},
      {"pos":10,"kind":"compact-block"},
      {"pos":2,"kind":"block-slide"},
      {"pos":3,"kind":"block-slide"},
      {"pos":4,"kind":"line-hold"},
      {"pos":6,"kind":"line-hold"},
      {"pos":5,"kind":"line-hold"}]');
    PERFORM pg_temp.fh_step(l2mid, 8, '[{"pos":10,"kind":"nearest-decides","targets":[8]},
                                        {"pos":9,"kind":"cover"},
                                        {"pos":3,"kind":"mark","targets":[7]},
                                        {"pos":2,"kind":"mark","targets":[11]}]');
  END IF;
  IF l2low IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = l2low) THEN
    PERFORM pg_temp.fh_jobs(l2low, '[
      {"pos":7,"kind":"close-the-centre"},
      {"pos":11,"kind":"central-trap"},
      {"pos":8,"kind":"pack-the-middle"},
      {"pos":9,"kind":"penalty-spot-guard"},
      {"pos":10,"kind":"pack-the-middle"},
      {"pos":2,"kind":"balance"},
      {"pos":3,"kind":"balance"},
      {"pos":4,"kind":"line-hold"},
      {"pos":6,"kind":"line-hold"},
      {"pos":5,"kind":"line-hold"}]');
  END IF;

  -- 2. Low block trigger: ball wide (both shapes share back five + mids).
  FOREACH sid IN ARRAY ARRAY[r2low, l2low] LOOP
    PERFORM pg_temp.fh_step(sid, 7, '[{"pos":3,"kind":"touchline-trap","targets":[7]},
                                      {"pos":10,"kind":"double-team","targets":[7]},
                                      {"pos":5,"kind":"block-slide"}]');
    PERFORM pg_temp.fh_step(sid, 11, '[{"pos":2,"kind":"touchline-trap","targets":[11]},
                                       {"pos":8,"kind":"double-team","targets":[11]},
                                       {"pos":4,"kind":"block-slide"}]');
  END LOOP;
END $$;
