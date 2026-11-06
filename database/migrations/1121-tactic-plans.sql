-- 1121 (2026-11-06) — Tactic plans: jobs per ball position, shared by
-- Game Center and the game engine.
--
-- Owner: "my vision is we pick formation we play vs. we also have
-- sections. we do defense first though but others moments are in. we
-- start with working on defending in high block (build out of opp). we
-- start with ball with keeper and that triggers the drop down for each
-- player to populate with tactical choices. then when lets say keeper
-- plays to 4 (cb) it allows for more or same tactical choices. the
-- choices should be what 'number' to cover shadow and what number to
-- press from that cover shadow or to hold between them ... then you could
-- do smooth animation of those movements and let it play at a speed the
-- user picks."  Then: "use what is in game and add to game (and this)
-- together. they should be in sync" and "lh runs this game model i am
-- giving you which is still pieced together from the concepts in db".
--
--   tactic_plans            our formation vs theirs, a moment
--                           (game_moments), a block height
--   tactic_states           ball with their #N; parent = the state the
--                           pass came from (root = their GK has it)
--   tactic_state_opponents  where their eleven stand in that state
--   tactic_jobs             one job per our position per state: a job
--                           kind (= a game_concepts row) + their numbers
--
-- Numbers are the owner's scheme on BOTH sides (mig 296: 2 RB, 3 LB, 4
-- RCB, 5 LCB, 6, 8, 10 (left of 8), 7 right, 11 left, 9).  Coordinates
-- 0–100 from OUR view: x left → right as we attack, y 0 = our goal line.
-- Positions of ours are COMPUTED from the jobs (frontend/js/lib/
-- tactic-geometry.js; the engine computes the same from the same
-- tactic_job_kinds numbers) — only theirs are stored.

-- The one job missing from the concept registry (status queued until the
-- engine plays it).
INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking)
VALUES (186, 'hold-between', 'Hold between two men', 'individual', 'out_of_possession', NULL, 'queued',
        'Out of possession: stand in the gap between the two men you are given, goal-side of the line between them, ready to step to whichever one receives.',
        'Picking one and leaving the other free; standing level with them instead of goal-side.')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS tactic_block_heights (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    gk_y        numeric(5,2) NOT NULL,     -- our keeper's spot (0–100 up the pitch)
    sort_order  smallint NOT NULL DEFAULT 0
);
INSERT INTO tactic_block_heights (code, label, gk_y, sort_order) VALUES
    ('high', 'High block', 16, 1),
    ('mid',  'Mid block',  10, 2),
    ('low',  'Low block',   5, 3)
ON CONFLICT (code) DO NOTHING;

-- What a player can be told to do.  dist_m / press_m are the geometry both
-- the app and the engine use:
--   cover_shadow (A, B): B has the ball → stand press_m from the ball on
--     the ball–A line (pressing him with A in your shadow); otherwise
--     dist_m off A toward the ball (in the lane, A blocked).
--   mark (A): dist_m goal-side of A, toward the centre of our goal.
--   hold_between (A, B): midpoint of A and B, dist_m goal-side.
CREATE TABLE IF NOT EXISTS tactic_job_kinds (
    code            text PRIMARY KEY,
    concept_id      smallint NOT NULL REFERENCES game_concepts(id),
    label           text NOT NULL,
    target_a_label  text NOT NULL,
    target_b_label  text,                   -- NULL = one target
    dist_m          numeric(4,1) NOT NULL,
    press_m         numeric(4,1),
    sort_order      smallint NOT NULL DEFAULT 0
);
INSERT INTO tactic_job_kinds (code, concept_id, label, target_a_label, target_b_label, dist_m, press_m, sort_order) VALUES
    ('cover_shadow', 27,  'Cover-shadow', 'shadow',  'press',  4, 1.5, 1),
    ('mark',         18,  'Mark',         'mark',    NULL,     2, NULL, 2),
    ('hold_between', 186, 'Hold between', 'between', 'and',    3, NULL, 3)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS tactic_plans (
    id                     serial PRIMARY KEY,
    formation_id           integer NOT NULL REFERENCES formations(id),
    opponent_formation_id  integer NOT NULL REFERENCES formations(id),
    moment                 text NOT NULL REFERENCES game_moments(code),
    block_height           text NOT NULL REFERENCES tactic_block_heights(code),
    created_by_user_id     integer REFERENCES users(id),
    created_at             timestamptz NOT NULL DEFAULT now(),
    updated_at             timestamptz NOT NULL DEFAULT now(),
    UNIQUE (formation_id, opponent_formation_id, moment, block_height)
);

CREATE TABLE IF NOT EXISTS tactic_states (
    id               serial PRIMARY KEY,
    plan_id          integer NOT NULL REFERENCES tactic_plans(id) ON DELETE CASCADE,
    parent_state_id  integer REFERENCES tactic_states(id) ON DELETE CASCADE,
    ball_with        smallint NOT NULL CHECK (ball_with BETWEEN 1 AND 11),
    created_at       timestamptz NOT NULL DEFAULT now(),
    UNIQUE (plan_id, parent_state_id, ball_with)
);
CREATE UNIQUE INDEX IF NOT EXISTS tactic_states_one_root ON tactic_states (plan_id) WHERE parent_state_id IS NULL;

CREATE TABLE IF NOT EXISTS tactic_state_opponents (
    state_id  integer NOT NULL REFERENCES tactic_states(id) ON DELETE CASCADE,
    number    smallint NOT NULL CHECK (number BETWEEN 1 AND 11),
    x         numeric(5,2) NOT NULL CHECK (x BETWEEN 0 AND 100),
    y         numeric(5,2) NOT NULL CHECK (y BETWEEN 0 AND 100),
    PRIMARY KEY (state_id, number)
);

CREATE TABLE IF NOT EXISTS tactic_jobs (
    state_id     integer NOT NULL REFERENCES tactic_states(id) ON DELETE CASCADE,
    position_id  integer NOT NULL REFERENCES positions(id) CHECK (position_id BETWEEN 2 AND 11),
    kind         text NOT NULL REFERENCES tactic_job_kinds(code),
    target_a     smallint NOT NULL CHECK (target_a BETWEEN 1 AND 11),
    target_b     smallint CHECK (target_b BETWEEN 1 AND 11),
    PRIMARY KEY (state_id, position_id)
);

-- Seed: 3-5-2 (3-R2) vs 4-3-3, out of possession, high block, their GK on
-- the ball, their build-out shape (CBs split, 6 between, FBs high).  Their
-- right side is on OUR left.  Jobs as agreed 11/6: 11 shadows their 6 and
-- presses their 4; 7 shadows their 10 and presses their 5; 10/9/8 mark
-- their 8/6/10; wing backs on their full backs; back three on their front
-- three.  First draft — coaches change it in Game Center.
DO $$
DECLARE v_plan int; v_state int;
BEGIN
  INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height)
  SELECT us.id, them.id, 'out_of_possession', 'high'
    FROM formations us, formations them
   WHERE us.code = '3-5-2 (3-R2)' AND them.code = '4-3-3'
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_plan;
  IF v_plan IS NULL THEN RETURN; END IF;

  INSERT INTO tactic_states (plan_id, ball_with) VALUES (v_plan, 1) RETURNING id INTO v_state;
  INSERT INTO tactic_state_opponents (state_id, number, x, y) VALUES
    (v_state, 1, 50, 96), (v_state, 4, 32, 88), (v_state, 5, 68, 88), (v_state, 2, 10, 74),
    (v_state, 3, 90, 74), (v_state, 6, 50, 79), (v_state, 8, 36, 64), (v_state, 10, 64, 64),
    (v_state, 7, 12, 56), (v_state, 11, 88, 56), (v_state, 9, 50, 54);
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_a, target_b) VALUES
    (v_state, 11, 'cover_shadow', 6, 4),
    (v_state, 7,  'cover_shadow', 10, 5),
    (v_state, 10, 'mark', 8, NULL),
    (v_state, 9,  'mark', 6, NULL),
    (v_state, 8,  'mark', 10, NULL),
    (v_state, 3,  'mark', 2, NULL),
    (v_state, 2,  'mark', 3, NULL),
    (v_state, 5,  'mark', 7, NULL),
    (v_state, 6,  'mark', 9, NULL),
    (v_state, 4,  'mark', 11, NULL);
END $$;

-- Copy (client-side, MessageCopy.block('tactics', tier)).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('mode_plan',   'Game Center — Tactics: jobs plan view',                 '🧠 Game model', 1210),
    ('mode_drawn',  'Game Center — Tactics: drawn situations view',          '✏️ Drawn', 1211),
    ('vs',          'Game Center — Tactics: opponent formation label',       'vs', 1212),
    ('ball_with',   'Game Center — Tactics: state pill',                     'their {n}', 1213),
    ('ball_gk',     'Game Center — Tactics: root state pill',                'their GK', 1214),
    ('pass_hint',   'Game Center — Tactics: coach, how to add the next pass', 'Tap one of theirs on the pitch to play the ball to him.', 1215),
    ('next',        'Game Center — Tactics: passes already drawn from here', 'Next:', 1216),
    ('no_plan',     'Game Center — Tactics: no plan for this matchup',       'No plan yet for {us} vs {them} · {moment} · {block}.', 1217),
    ('create',      'Game Center — Tactics: coach creates the plan',         '➕ Start this plan', 1218),
    ('free',        'Game Center — Tactics: their men nobody is on',         'Free: {list}', 1219),
    ('double',      'Game Center — Tactics: their men two of ours are on',   'Two on: {list}', 1220),
    ('all_on',      'Game Center — Tactics: every one of theirs taken',      'Every one of theirs has someone.', 1221),
    ('play',        'Game Center — Tactics: animate the passes',             '▶ Play', 1222),
    ('stop',        'Game Center — Tactics: stop the animation',             '■ Stop', 1223),
    ('speed',       'Game Center — Tactics: speed label',                    'Speed', 1224),
    ('delete',      'Game Center — Tactics: remove this pass',               '🗑 Remove this pass', 1225),
    ('no_job',      'Game Center — Tactics: no job picked',                  '— no job —', 1226),
    ('their',       'Game Center — Tactics: their number in a dropdown',     'their {n}', 1227)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
