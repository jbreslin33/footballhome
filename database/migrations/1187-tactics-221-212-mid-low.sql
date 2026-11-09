-- 1187 (2026-11-08): 🎯 Tactics — mid + low blocks for 3-4-3 (2-2-1) and
-- 3-5-2 (2-1-2) v 4-3-3 (follows 1185/1186, which did 3-R2 and 3-L2).
--
-- Both shapes share 3-R2's back three (4, 6, 5), wing-backs (2 right,
-- 3 left) and wide-centre mids (8 right, 10 left), so they take the same
-- back-line and midfield jobs.  The front men differ:
--   2-2-1: 9 alone up top, 7 and 11 a pair behind him.
--   2-1-2: 7 and 11 the strike pair, 9 the attacking mid.
--
-- Mid (zonal from the goal kick): the top man engages at the middle
-- third, the next protect the middle, mids compact, wing-backs shift and
-- tilt, back three hold the line.  Trigger, ball to their 8: our 11 is
-- nearest in both shapes once the block squeezes them (blockHome) — he
-- decides and goes, 10 covers, 3 picks up their 7, 2 their 11.
--
-- Low: the top man protects the middle, the rest funnel inside / pack
-- the middle, wing-backs balance, back three hold.  Trigger = 1186's:
-- ball to their 7 → 3 traps on the touchline, 10 doubles, 5 slides;
-- ball to their 11 → 2 traps, 8 doubles, 4 slides.
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

-- Plan + goal-kick root (their build-out shape) if missing; returns the root.
CREATE FUNCTION pg_temp.fh_plan(us text, blk text) RETURNS int AS $$
DECLARE pid int; sid int;
BEGIN
  INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
  SELECT f.id, o.id, 'out_of_possession', blk FROM formations f, formations o
   WHERE f.code = us AND o.code = '4-3-3'
  ON CONFLICT DO NOTHING;
  SELECT p.id INTO pid FROM tactic_plans p JOIN formations f ON f.id = p.formation_id AND f.code = us
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = '4-3-3'
   WHERE p.moment = 'out_of_possession' AND p.block_height = blk;
  IF pid IS NULL THEN RETURN NULL; END IF;
  IF NOT EXISTS (SELECT 1 FROM tactic_states WHERE plan_id = pid) THEN
    INSERT INTO tactic_states (plan_id, ball_with, restart) VALUES (pid, 1, 'goal_kick') RETURNING id INTO sid;
    INSERT INTO tactic_state_opponents (state_id, number, x, y)
    SELECT sid, number, x, y FROM tactic_buildout_shapes b JOIN formations o ON o.id = b.formation_id AND o.code = '4-3-3';
  END IF;
  RETURN pg_temp.fh_root(us, blk);
END $$ LANGUAGE plpgsql;

-- Fill an empty root with `jobs` plus its trigger steps.
CREATE FUNCTION pg_temp.fh_fill(root int, jobs jsonb, steps jsonb) RETURNS void AS $$
DECLARE st jsonb;
BEGIN
  IF root IS NULL OR EXISTS (SELECT 1 FROM tactic_jobs WHERE state_id = root) THEN RETURN; END IF;
  PERFORM pg_temp.fh_jobs(root, jobs);
  FOR st IN SELECT * FROM jsonb_array_elements(steps) LOOP
    PERFORM pg_temp.fh_step(root, (st->>'ball')::int, st->'jobs');
  END LOOP;
END $$ LANGUAGE plpgsql;

DO $$
DECLARE
  back jsonb := '[{"pos":4,"kind":"line-hold"},{"pos":6,"kind":"line-hold"},{"pos":5,"kind":"line-hold"}]';
  mid_step jsonb := '[{"ball":8,"jobs":[{"pos":11,"kind":"nearest-decides","targets":[8]},
                                        {"pos":10,"kind":"cover"},
                                        {"pos":3,"kind":"mark","targets":[7]},
                                        {"pos":2,"kind":"mark","targets":[11]}]}]';
  low_steps jsonb := '[{"ball":7,"jobs":[{"pos":3,"kind":"touchline-trap","targets":[7]},
                                         {"pos":10,"kind":"double-team","targets":[7]},
                                         {"pos":5,"kind":"block-slide"}]},
                       {"ball":11,"jobs":[{"pos":2,"kind":"touchline-trap","targets":[11]},
                                          {"pos":8,"kind":"double-team","targets":[11]},
                                          {"pos":4,"kind":"block-slide"}]}]';
BEGIN
  -- 3-4-3 (2-2-1)
  PERFORM pg_temp.fh_fill(pg_temp.fh_plan('3-4-3 (2-2-1)', 'mid'), back || '[
    {"pos":9,"kind":"engage-line"},
    {"pos":7,"kind":"close-the-centre"},
    {"pos":11,"kind":"close-the-centre"},
    {"pos":8,"kind":"compact-block"},
    {"pos":10,"kind":"compact-block"},
    {"pos":2,"kind":"block-slide"},
    {"pos":3,"kind":"block-slide"}]'::jsonb, mid_step);
  PERFORM pg_temp.fh_fill(pg_temp.fh_plan('3-4-3 (2-2-1)', 'low'), back || '[
    {"pos":9,"kind":"close-the-centre"},
    {"pos":7,"kind":"central-trap"},
    {"pos":11,"kind":"central-trap"},
    {"pos":8,"kind":"pack-the-middle"},
    {"pos":10,"kind":"pack-the-middle"},
    {"pos":2,"kind":"balance"},
    {"pos":3,"kind":"balance"}]'::jsonb, low_steps);

  -- 3-5-2 (2-1-2)
  PERFORM pg_temp.fh_fill(pg_temp.fh_plan('3-5-2 (2-1-2)', 'mid'), back || '[
    {"pos":7,"kind":"engage-line"},
    {"pos":11,"kind":"close-the-centre"},
    {"pos":9,"kind":"pack-the-middle"},
    {"pos":8,"kind":"compact-block"},
    {"pos":10,"kind":"compact-block"},
    {"pos":2,"kind":"block-slide"},
    {"pos":3,"kind":"block-slide"}]'::jsonb, mid_step);
  PERFORM pg_temp.fh_fill(pg_temp.fh_plan('3-5-2 (2-1-2)', 'low'), back || '[
    {"pos":7,"kind":"close-the-centre"},
    {"pos":11,"kind":"central-trap"},
    {"pos":9,"kind":"pack-the-middle"},
    {"pos":8,"kind":"pack-the-middle"},
    {"pos":10,"kind":"pack-the-middle"},
    {"pos":2,"kind":"balance"},
    {"pos":3,"kind":"balance"}]'::jsonb, low_steps);
END $$;
