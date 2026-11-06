-- 1139 (2026-11-06) — Jobs on several men, Deter and Read, the intercept
-- (Numbered 1139: another session claimed 1138 first.)
-- stance; James's high-block plan for 3-5-2 (3-R2) vs 4-3-3.
--
-- Owner: "7 should deter pass from 1 to 5 and 1 to 3 by sitting near where
-- that would deter so put him on 'deter' then allow multi selects ... so we
-- can put 5,3.  (also move 4 and 5 back to just above 6 yard line depth so
-- 8 yard line.)  then when ball is played to 4 the 7 cover shadows from 5&1
-- to 4.  11 is in a 'read' situation to intercept ball from 4 into
-- midfield.  10 marks 8, 8 marks 10, 9 marks 6.  all 3 mids are in
-- interception mode."  And: "set the values of drop downs to the plan i
-- give you above and in future."
--
--  * A job's men are a SET: tactic_job_targets replaces tactic_jobs.target_a
--    (target_b stays the single "then press" / "and" man; partner stays).
--    tactic_job_kinds.multi_a says which jobs take more than one.
--  * deter (new concept 188) and read (concept 20 'intercept', "Read the
--    pass"): stand on the lanes from the ball carrier to the men, lane_t of
--    the way along (averaged over the lanes) — deter sits nearer the passer
--    to put him off, read nearer the receivers to step in.
--  * stance on a job (tactic_job_stances): goal_side (default) or intercept
--    (concept 168 "Defend your man: intercept, no turn, contain") — a mark
--    in intercept stance stands ball-side of his man.
--  Geometry contract: game/DESIGN.md §8.137 (the game session updates it).

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking)
VALUES (188, 'deter', 'Deter the pass', 'individual', 'out_of_possession', NULL, 'queued',
        'Out of possession: stand where the passes you are given all look closed — between those lanes, a few steps off the passer — so he holds it or plays where we want.',
        'Standing on one lane and leaving the other wide open; going so close to the passer that he plays round you.')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE tactic_job_kinds ADD COLUMN IF NOT EXISTS multi_a boolean NOT NULL DEFAULT false;
ALTER TABLE tactic_job_kinds ADD COLUMN IF NOT EXISTS lane_t numeric(4,2);
UPDATE tactic_job_kinds SET multi_a = true WHERE code = 'cover_shadow';
INSERT INTO tactic_job_kinds (code, concept_id, label, target_a_label, target_b_label, partner_label, dist_m, press_m, multi_a, lane_t, sort_order) VALUES
    ('deter', 188, 'Deter', 'deter', NULL, NULL, 0, NULL, true, 0.45, 5),
    ('read',  20,  'Read',  'read',  NULL, NULL, 0, NULL, true, 0.65, 6)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS tactic_job_stances (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    concept_id  smallint REFERENCES game_concepts(id),
    sort_order  smallint NOT NULL DEFAULT 0
);
INSERT INTO tactic_job_stances (code, label, concept_id, sort_order) VALUES
    ('goal_side', 'Goal-side', NULL, 1),
    ('intercept', 'Intercept', 168, 2)
ON CONFLICT (code) DO NOTHING;
ALTER TABLE tactic_jobs ADD COLUMN IF NOT EXISTS stance text NOT NULL DEFAULT 'goal_side' REFERENCES tactic_job_stances(code);

CREATE TABLE IF NOT EXISTS tactic_job_targets (
    state_id     integer  NOT NULL,
    position_id  integer  NOT NULL,
    number       smallint NOT NULL CHECK (number BETWEEN 1 AND 11),
    ord          smallint NOT NULL DEFAULT 1,
    PRIMARY KEY (state_id, position_id, number),
    FOREIGN KEY (state_id, position_id) REFERENCES tactic_jobs(state_id, position_id) ON DELETE CASCADE
);
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tactic_jobs' AND column_name = 'target_a') THEN
    INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
    SELECT state_id, position_id, target_a, 1 FROM tactic_jobs ON CONFLICT DO NOTHING;
    ALTER TABLE tactic_jobs DROP COLUMN target_a;
  END IF;
END $$;

-- Their 4 and 5 back to the 8-yard line (7.3 m out → y 93), x unchanged.
UPDATE tactic_buildout_shapes b SET y = 93
  FROM formations f WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number IN (4, 5);
UPDATE tactic_state_opponents o SET y = 93
  FROM tactic_states s, tactic_plans p, formations f
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession' AND p.opponent_formation_id = f.id AND f.code = '4-3-3'
   AND o.number IN (4, 5);

-- James's plan, 3-5-2 (3-R2) vs 4-3-3, out of possession, high block.
DO $$
DECLARE v_plan int; v_root int; v_four int;
BEGIN
  SELECT p.id INTO v_plan FROM tactic_plans p
    JOIN formations us ON us.id = p.formation_id AND us.code = '3-5-2 (3-R2)'
    JOIN formations them ON them.id = p.opponent_formation_id AND them.code = '4-3-3'
   WHERE p.moment = 'out_of_possession' AND p.block_height = 'high';
  IF v_plan IS NULL THEN RETURN; END IF;
  SELECT id INTO v_root FROM tactic_states WHERE plan_id = v_plan AND parent_state_id IS NULL;

  -- Their GK has it: 7 deters 1→5 and 1→3; 11 holds his shadow on their 6
  -- (the press on their 4 is the 7's now); the three mids mark in the
  -- intercept stance.
  DELETE FROM tactic_jobs WHERE state_id = v_root AND position_id IN (7, 11);
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, stance) VALUES
    (v_root, 7, 'deter', NULL, 'goal_side'), (v_root, 11, 'cover_shadow', NULL, 'goal_side');
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES
    (v_root, 7, 5, 1), (v_root, 7, 3, 2), (v_root, 11, 6, 1);
  UPDATE tactic_jobs SET stance = 'intercept' WHERE state_id = v_root AND position_id IN (10, 9, 8);

  -- Ball played to their 4.
  INSERT INTO tactic_states (plan_id, parent_state_id, ball_with) VALUES (v_plan, v_root, 4)
  ON CONFLICT (plan_id, parent_state_id, ball_with) DO NOTHING RETURNING id INTO v_four;
  IF v_four IS NULL THEN RETURN; END IF;
  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT v_four, number, x, y FROM tactic_state_opponents WHERE state_id = v_root;
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance)
  SELECT v_four, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = v_root;
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
  SELECT v_four, position_id, number, ord FROM tactic_job_targets WHERE state_id = v_root;
  -- 7 presses their 4 with 5 and 1 in his shadow; 11 reads 4 → their 8 / 6.
  DELETE FROM tactic_jobs WHERE state_id = v_four AND position_id IN (7, 11);
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, stance) VALUES
    (v_four, 7, 'cover_shadow', 4, 'goal_side'), (v_four, 11, 'read', NULL, 'goal_side');
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES
    (v_four, 7, 5, 1), (v_four, 7, 1, 2), (v_four, 11, 8, 1), (v_four, 11, 6, 2);
END $$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('stance', 'Game Center — Tactics: marking stance label', 'stance', 1235),
    ('multi_hint', 'Game Center — Tactics: tap their numbers for a multi-man job', 'tap every one that applies', 1236)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
