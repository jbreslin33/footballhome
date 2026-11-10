-- 1209 (2026-11-09): 🎯 Tactics — the last three match-ups from James's
-- notes (mig 912, formation_matchups 4/7/8) as high-block plans.  Owner
-- 11/9 "Both" (libero fix 1208 + these).
--
-- Their shapes had no formations rows, so the board's opponent dropdown
-- couldn't pick them.  New rows 4-1-4-1, 5-3-2, 5-4-1 (positions_json
-- position_id = shirt number, club frame: y up from that side's goal, x 85 =
-- its right).  Opponent use only: no FIELD_SIZES entry in game-center.js,
-- so they never show in our lineup picker (nobody lines up in them).
-- Numbering like the shapes the game plays: back four 2 · 4 5 · 3 (4 right
-- centre-back), back five the bowl 3 · 5 6 4 · 2, wide mids 7 right /
-- 11 left, centre mids 8 right / 10 left, 6 the holder, 9 the striker;
-- 5-3-2's two up front 7 and 11 with 9 between 10 and 8 (owner 11/6 rule).
--
-- 4-1-4-1 → 2-4-1-3: "5 is the libero. 4 takes their striker. 3, 6, 8, 2
--   take their four mids. 10 takes their holding mid. 11, 9, 7 press their
--   back four, one is left free."  3 on 7, 6 on 8, 8 on 10, 2 on 11 (board:
--   their right = our left); front three as 1197: 11/7 shadow the
--   full-backs, 9 deters both centre-backs; steps ball to 4/5/2/3.
-- 5-3-2 → 3-3-4: "6 is the libero. 5, 4 take their two strikers. 3, 8, 2
--   take their three mids. 11, 10, 9, 7 press their back five, one is left
--   free."  5 on 7, 4 on 11; 3 on 8, 8 on 9, 2 on 10 (intercept); 11/7
--   shadow the wing-backs, 10/9 their 4/5, their middle centre-back 6 free
--   (as 1205); steps ball to 6/4/5/2/3.
-- 5-4-1 → 2-4-4: "5 is the libero. 4 takes their striker. 3, 6, 8, 2 take
--   their four mids. 11, 10, 9, 7 press their back five, one is left free."
--   4 on 9; 3 on 7, 6 on 8, 8 on 10, 2 on 11; front four as 5-3-2.
--
-- Their goal-kick shapes are [FH] ESTIMATES, on these plans'
-- tactic_state_opponents only, never tactic_buildout_shapes (measured
-- only, mig 1198).  Every job is a dropdown value for the coach to change.

SELECT setval('formations_id_seq', GREATEST((SELECT max(id) FROM formations), 1));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
('4-1-4-1', 'Classic 4-1-4-1', 10, '[
  {"slot":1,"position_id":1,"label":"GK","x":50,"y":5},
  {"slot":2,"position_id":2,"label":"RB","x":85,"y":22},
  {"slot":3,"position_id":4,"label":"CB","x":62,"y":18},
  {"slot":4,"position_id":5,"label":"CB","x":38,"y":18},
  {"slot":5,"position_id":3,"label":"LB","x":15,"y":22},
  {"slot":6,"position_id":6,"label":"CDM","x":50,"y":34},
  {"slot":7,"position_id":7,"label":"RM","x":85,"y":50},
  {"slot":8,"position_id":8,"label":"CM","x":62,"y":48},
  {"slot":9,"position_id":10,"label":"CM","x":38,"y":48},
  {"slot":10,"position_id":11,"label":"LM","x":15,"y":50},
  {"slot":11,"position_id":9,"label":"ST","x":50,"y":70}]'::jsonb, 23),
('5-3-2', 'Classic 5-3-2', 10, '[
  {"slot":1,"position_id":1,"label":"GK","x":50,"y":5},
  {"slot":2,"position_id":2,"label":"RWB","x":92,"y":30},
  {"slot":3,"position_id":4,"label":"CB","x":70,"y":18},
  {"slot":4,"position_id":6,"label":"CB","x":50,"y":15},
  {"slot":5,"position_id":5,"label":"CB","x":30,"y":18},
  {"slot":6,"position_id":3,"label":"LWB","x":8,"y":30},
  {"slot":7,"position_id":8,"label":"CM","x":68,"y":45},
  {"slot":8,"position_id":9,"label":"CDM","x":50,"y":42},
  {"slot":9,"position_id":10,"label":"CM","x":32,"y":45},
  {"slot":10,"position_id":7,"label":"ST","x":62,"y":68},
  {"slot":11,"position_id":11,"label":"ST","x":38,"y":68}]'::jsonb, 24),
('5-4-1', 'Classic 5-4-1', 10, '[
  {"slot":1,"position_id":1,"label":"GK","x":50,"y":5},
  {"slot":2,"position_id":2,"label":"RWB","x":92,"y":30},
  {"slot":3,"position_id":4,"label":"CB","x":70,"y":18},
  {"slot":4,"position_id":6,"label":"CB","x":50,"y":15},
  {"slot":5,"position_id":5,"label":"CB","x":30,"y":18},
  {"slot":6,"position_id":3,"label":"LWB","x":8,"y":30},
  {"slot":7,"position_id":7,"label":"RM","x":85,"y":48},
  {"slot":8,"position_id":8,"label":"CM","x":62,"y":45},
  {"slot":9,"position_id":10,"label":"CM","x":38,"y":45},
  {"slot":10,"position_id":11,"label":"LM","x":15,"y":48},
  {"slot":11,"position_id":9,"label":"ST","x":50,"y":68}]'::jsonb, 25)
ON CONFLICT (code) DO NOTHING;

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

-- us v them (high block) from their goal-kick shape `opps` [[n,x,y]…],
-- root jobs `jobs`, then each step [ball, jobs].  Skips a plan with states.
CREATE FUNCTION pg_temp.fh_plan(us text, them text, opps jsonb, jobs jsonb, steps jsonb) RETURNS void AS $$
DECLARE pid int; root int; st jsonb;
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
  PERFORM pg_temp.fh_jobs(root, jobs);
  FOR st IN SELECT * FROM jsonb_array_elements(steps) LOOP
    PERFORM pg_temp.fh_step(root, (st->>0)::int, st->1);
  END LOOP;
END $$ LANGUAGE plpgsql;

-- 4-1-4-1: back four split wide, the 6 in front, mids spread, 9 on top.
SELECT pg_temp.fh_plan('2-4-1-3', '4-1-4-1',
  '[[1,50,96],[2,3,78],[4,28,93],[5,72,93],[3,97,78],[6,50,74],
    [7,5,52],[8,38,62],[10,62,62],[11,95,52],[9,50,46]]'::jsonb,
  '[{"pos":5,"kind":"libero"},
    {"pos":4,"kind":"mark","targets":[9]},
    {"pos":3,"kind":"mark","targets":[7]},
    {"pos":6,"kind":"mark","targets":[8],"stance":"intercept"},
    {"pos":8,"kind":"mark","targets":[10],"stance":"intercept"},
    {"pos":2,"kind":"mark","targets":[11]},
    {"pos":10,"kind":"mark","targets":[6],"stance":"intercept"},
    {"pos":11,"kind":"cover_shadow","targets":[2]},
    {"pos":7,"kind":"cover_shadow","targets":[3]},
    {"pos":9,"kind":"deter","targets":[4,5]}]'::jsonb,
  '[[4,[{"pos":11,"kind":"cover_shadow","targets":[2],"b":4},{"pos":9,"kind":"cover_shadow","targets":[5]}]],
    [5,[{"pos":7,"kind":"cover_shadow","targets":[3],"b":5},{"pos":9,"kind":"cover_shadow","targets":[4]}]],
    [2,[{"pos":11,"kind":"touchline-trap","targets":[2]},{"pos":9,"kind":"cover_shadow","targets":[4]}]],
    [3,[{"pos":7,"kind":"touchline-trap","targets":[3]},{"pos":9,"kind":"cover_shadow","targets":[5]}]]]'::jsonb);

-- Back five at their goal kick: three centre-backs across the box, wing-
-- backs wide and up.  Front four: 11/7 shadow the wing-backs, 10/9 their
-- 4/5; their 6 free.  Ball to 6 → 10 presses him cutting off 4; to 4 → 10
-- presses cutting off 6, 9 slides onto 6; to 5 mirrored; to a wing-back →
-- the winger traps him on the line, the striker behind shadows the near
-- centre-back.
SELECT pg_temp.fh_plan('3-3-4', '5-3-2',
  '[[1,50,96],[4,22,90],[6,50,88],[5,78,90],[2,4,72],[3,96,72],
    [8,32,68],[9,50,72],[10,68,68],[7,38,48],[11,62,48]]'::jsonb,
  '[{"pos":6,"kind":"libero"},
    {"pos":5,"kind":"mark","targets":[7]},
    {"pos":4,"kind":"mark","targets":[11]},
    {"pos":3,"kind":"mark","targets":[8],"stance":"intercept"},
    {"pos":8,"kind":"mark","targets":[9],"stance":"intercept"},
    {"pos":2,"kind":"mark","targets":[10],"stance":"intercept"},
    {"pos":11,"kind":"cover_shadow","targets":[2]},
    {"pos":7,"kind":"cover_shadow","targets":[3]},
    {"pos":10,"kind":"cover_shadow","targets":[4]},
    {"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb,
  '[[6,[{"pos":10,"kind":"cover_shadow","targets":[4],"b":6}]],
    [4,[{"pos":10,"kind":"cover_shadow","targets":[6],"b":4},{"pos":9,"kind":"cover_shadow","targets":[6]}]],
    [5,[{"pos":9,"kind":"cover_shadow","targets":[6],"b":5},{"pos":10,"kind":"cover_shadow","targets":[6]}]],
    [2,[{"pos":11,"kind":"touchline-trap","targets":[2]},{"pos":10,"kind":"cover_shadow","targets":[4]}]],
    [3,[{"pos":7,"kind":"touchline-trap","targets":[3]},{"pos":9,"kind":"cover_shadow","targets":[5]}]]]'::jsonb);

SELECT pg_temp.fh_plan('2-4-4', '5-4-1',
  '[[1,50,96],[4,22,90],[6,50,88],[5,78,90],[2,4,72],[3,96,72],
    [7,5,56],[8,38,68],[10,62,68],[11,95,56],[9,50,46]]'::jsonb,
  '[{"pos":5,"kind":"libero"},
    {"pos":4,"kind":"mark","targets":[9]},
    {"pos":3,"kind":"mark","targets":[7]},
    {"pos":6,"kind":"mark","targets":[8],"stance":"intercept"},
    {"pos":8,"kind":"mark","targets":[10],"stance":"intercept"},
    {"pos":2,"kind":"mark","targets":[11]},
    {"pos":11,"kind":"cover_shadow","targets":[2]},
    {"pos":7,"kind":"cover_shadow","targets":[3]},
    {"pos":10,"kind":"cover_shadow","targets":[4]},
    {"pos":9,"kind":"cover_shadow","targets":[5]}]'::jsonb,
  '[[6,[{"pos":10,"kind":"cover_shadow","targets":[4],"b":6}]],
    [4,[{"pos":10,"kind":"cover_shadow","targets":[6],"b":4},{"pos":9,"kind":"cover_shadow","targets":[6]}]],
    [5,[{"pos":9,"kind":"cover_shadow","targets":[6],"b":5},{"pos":10,"kind":"cover_shadow","targets":[6]}]],
    [2,[{"pos":11,"kind":"touchline-trap","targets":[2]},{"pos":10,"kind":"cover_shadow","targets":[4]}]],
    [3,[{"pos":7,"kind":"touchline-trap","targets":[3]},{"pos":9,"kind":"cover_shadow","targets":[5]}]]]'::jsonb);
