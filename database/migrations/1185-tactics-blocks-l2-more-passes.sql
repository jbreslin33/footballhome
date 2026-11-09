-- 1185 (2026-11-08): 🎯 Tactics — "do all" (owner, after: describe more
-- passes / bring 3-L2 level / a mid and a low block).
--
-- 1. The block drops our whole shape, not just the keeper.
--    tactic_block_heights.back_y / front_y: our outfield formation spots,
--    deepest to highest, squeezed into back..front (fh::tactics::blockHome,
--    shared/tactics/TacticGeometry.hpp).  High = NULL = the formation as
--    drawn (what every plan so far was built on — nothing of theirs moves).
--    Mid: back line ~26 m out, front at halfway+.  Low: back ~13 m, front ~44 m.
--
-- 2. 3-5-2 (3-L2) v 4-3-3 high: its front men press the same side as 3-R2
--    (owner's 11/6 root: 7 deters 3/5, mids mark in intercept stance, 11
--    reads), and its back five stand on the same spots with the same
--    numbers as 3-R2's — so they take 3-R2's back-five jobs, and 3-L2 gets
--    the same steps 3-R2 has (ball to their 4, ball to their 5).
--
-- 3. More passes off the goal kick for 3-R2 and 3-L2: ball to their 3, to
--    their 2, to their 6.  Each is the goal kick copied (as the ⚽ Pass to:
--    row does) with only who changes:
--      to 3: our 2 springs the touchline trap on 3; our 7 locks the side
--            (shadows the back pass to 5).
--      to 2: our 3 springs the touchline trap on 2; our 11 (3-L2: 11 too)
--            shadows the back pass to 4; our 7 shadows their 6.
--      to 6: our central striker (3-R2 11, 3-L2 7) is nearest — he decides
--            and goes; the rest hold.
--
-- 4. Mid and low block plans, 3-R2 v 4-3-3.  From a goal kick a block is
--    shape, not men: zonal jobs (rule home — he stands in the block with
--    the concept as his instruction).  Mid gets the trigger step: ball to
--    their 8 = our 10 goes (nearest decides), 9 covers him, 2 and 3 pick
--    up the wingers.
--
-- Every step and job is a dropdown value for the coach to change.

ALTER TABLE tactic_block_heights ADD COLUMN IF NOT EXISTS back_y numeric(5,2);
ALTER TABLE tactic_block_heights ADD COLUMN IF NOT EXISTS front_y numeric(5,2);
UPDATE tactic_block_heights SET back_y = 25, front_y = 58 WHERE code = 'mid' AND back_y IS NULL;
UPDATE tactic_block_heights SET back_y = 12, front_y = 42 WHERE code = 'low' AND back_y IS NULL;

-- A child step of `parent` with the ball on their `ball`: their men and our
-- jobs copied, then `jobs` ({pos, kind, targets, b, stance}) replace those
-- men's jobs.  Returns the step (existing one untouched).
CREATE FUNCTION pg_temp.fh_step(parent int, ball int, jobs jsonb) RETURNS int AS $$
DECLARE sid int;
BEGIN
  IF parent IS NULL THEN RETURN NULL; END IF;
  INSERT INTO tactic_states (plan_id, parent_state_id, ball_with)
  SELECT plan_id, id, ball FROM tactic_states WHERE id = parent
  ON CONFLICT (plan_id, parent_state_id, ball_with) DO NOTHING
  RETURNING id INTO sid;
  IF sid IS NULL THEN RETURN NULL; END IF;   -- already drawn: leave it
  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT sid, number, x, y FROM tactic_state_opponents WHERE state_id = parent;
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance)
  SELECT sid, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = parent;
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
  SELECT sid, position_id, number, ord FROM tactic_job_targets WHERE state_id = parent;
  PERFORM pg_temp.fh_jobs(sid, jobs);
  RETURN sid;
END $$ LANGUAGE plpgsql;

-- Set these men's jobs on a state (replacing what they had).
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

-- The goal-kick root of a plan, by our formation code / block.
CREATE FUNCTION pg_temp.fh_root(us text, block text) RETURNS int AS $$
  SELECT s.id FROM tactic_states s
    JOIN tactic_plans p ON p.id = s.plan_id
    JOIN formations f ON f.id = p.formation_id AND f.code = us
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = '4-3-3'
   WHERE p.moment = 'out_of_possession' AND p.block_height = block AND s.parent_state_id IS NULL
$$ LANGUAGE sql;

DO $$
DECLARE r2 int := pg_temp.fh_root('3-5-2 (3-R2)', 'high');
        l2 int := pg_temp.fh_root('3-5-2 (3-L2)', 'high');
        mid int; low int; pid int; sid int;
BEGIN
  -- 2. 3-L2: back five as 3-R2's (only men with no job yet).
  IF l2 IS NOT NULL THEN
    PERFORM pg_temp.fh_jobs(l2, (
      SELECT COALESCE(jsonb_agg(x), '[]') FROM jsonb_array_elements('[
        {"pos":2,"kind":"mark","targets":[3]},
        {"pos":3,"kind":"mark","targets":[2]},
        {"pos":4,"kind":"mark","targets":[11]},
        {"pos":5,"kind":"mark","targets":[7]},
        {"pos":6,"kind":"mark","targets":[9]}]'::jsonb) x
       WHERE NOT EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = l2 AND position_id = (x->>'pos')::int)));
    -- 3-R2's steps: ball to their 4 (7 shadows 5 + keeper, then presses 4;
    -- 11 reads 8/6), ball to their 5 (hold the goal-kick jobs).
    PERFORM pg_temp.fh_step(l2, 4, '[{"pos":7,"kind":"cover_shadow","targets":[5,1],"b":4},
                                     {"pos":11,"kind":"read","targets":[8,6]}]');
    PERFORM pg_temp.fh_step(l2, 5, '[]');
  END IF;

  -- 3. Ball to their 3 / 2 / 6 — 3-R2 then 3-L2.
  PERFORM pg_temp.fh_step(r2, 3, '[{"pos":2,"kind":"touchline-trap","targets":[3]},
                                   {"pos":7,"kind":"lock-the-side","targets":[5]}]');
  PERFORM pg_temp.fh_step(r2, 2, '[{"pos":3,"kind":"touchline-trap","targets":[2]},
                                   {"pos":11,"kind":"lock-the-side","targets":[4]},
                                   {"pos":7,"kind":"cover_shadow","targets":[6]}]');
  PERFORM pg_temp.fh_step(r2, 6, '[{"pos":11,"kind":"nearest-decides","targets":[6]}]');
  PERFORM pg_temp.fh_step(l2, 3, '[{"pos":2,"kind":"touchline-trap","targets":[3]},
                                   {"pos":7,"kind":"lock-the-side","targets":[5]}]');
  PERFORM pg_temp.fh_step(l2, 2, '[{"pos":3,"kind":"touchline-trap","targets":[2]},
                                   {"pos":11,"kind":"lock-the-side","targets":[4]},
                                   {"pos":7,"kind":"cover_shadow","targets":[6]}]');
  PERFORM pg_temp.fh_step(l2, 6, '[{"pos":7,"kind":"nearest-decides","targets":[6]}]');

  -- 4. Mid and low block plans for 3-R2 (root = their goal kick, their
  --    build-out shape, as TacticPlans::create makes one).
  FOREACH pid IN ARRAY ARRAY[1, 2] LOOP
    INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
    SELECT f.id, o.id, 'out_of_possession', CASE pid WHEN 1 THEN 'mid' ELSE 'low' END
      FROM formations f, formations o WHERE f.code = '3-5-2 (3-R2)' AND o.code = '4-3-3'
    ON CONFLICT DO NOTHING;
  END LOOP;
  FOR sid IN
    SELECT p.id FROM tactic_plans p JOIN formations f ON f.id = p.formation_id AND f.code = '3-5-2 (3-R2)'
     WHERE p.block_height IN ('mid', 'low') AND p.moment = 'out_of_possession'
       AND NOT EXISTS (SELECT 1 FROM tactic_states s WHERE s.plan_id = p.id)
  LOOP
    INSERT INTO tactic_states (plan_id, ball_with, restart) VALUES (sid, 1, 'goal_kick') RETURNING id INTO pid;
    INSERT INTO tactic_state_opponents (state_id, number, x, y)
    SELECT pid, number, x, y FROM tactic_buildout_shapes b JOIN formations o ON o.id = b.formation_id AND o.code = '4-3-3';
  END LOOP;

  mid := pg_temp.fh_root('3-5-2 (3-R2)', 'mid');
  low := pg_temp.fh_root('3-5-2 (3-R2)', 'low');
  IF mid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = mid) THEN
    PERFORM pg_temp.fh_jobs(mid, '[
      {"pos":11,"kind":"engage-line"},
      {"pos":7,"kind":"close-the-centre"},
      {"pos":8,"kind":"compact-block"},
      {"pos":9,"kind":"pack-the-middle"},
      {"pos":10,"kind":"compact-block"},
      {"pos":2,"kind":"block-slide"},
      {"pos":3,"kind":"block-slide"},
      {"pos":4,"kind":"line-hold"},
      {"pos":6,"kind":"line-hold"},
      {"pos":5,"kind":"line-hold"}]');
    PERFORM pg_temp.fh_step(mid, 8, '[{"pos":10,"kind":"nearest-decides","targets":[8]},
                                      {"pos":9,"kind":"cover"},
                                      {"pos":3,"kind":"mark","targets":[7]},
                                      {"pos":2,"kind":"mark","targets":[11]}]');
  END IF;
  IF low IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = low) THEN
    PERFORM pg_temp.fh_jobs(low, '[
      {"pos":11,"kind":"close-the-centre"},
      {"pos":7,"kind":"central-trap"},
      {"pos":8,"kind":"pack-the-middle"},
      {"pos":9,"kind":"penalty-spot-guard"},
      {"pos":10,"kind":"pack-the-middle"},
      {"pos":2,"kind":"balance"},
      {"pos":3,"kind":"balance"},
      {"pos":4,"kind":"line-hold"},
      {"pos":6,"kind":"line-hold"},
      {"pos":5,"kind":"line-hold"}]');
  END IF;
END $$;
