-- 2191 (2026-11-27): 🏋️ Exercise catalog — every exercise from every source.
--
-- Owner: "we need a way to catalog all the exercises from the books and any
-- new books etc coming in add to it … getting all exercises into db and
-- their source fk … a cat lookup table? unopposed? unopposed passing
-- circuit? possession, small sided games (so with target)" · "then making
-- it so we can tie it to a practice event and even a game as the warmup".
--
-- Same shape as the rest of the taxonomy: game_sources → the entry.  A book
-- exercise also points at coaching_books + its app pages (the diagram is the
-- book page, viewed in #books).  Wording is OUR paraphrase, never the book's
-- sentences.  The old club_game_model_exercises list retires once practices
-- and game warm-ups link to this catalog (next step).
BEGIN;

-- What kind of exercise it is (one primary per exercise).
CREATE TABLE IF NOT EXISTS exercise_categories (
    id          smallserial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    label       text NOT NULL,
    icon        text,
    description text NOT NULL,
    sort_order  integer NOT NULL DEFAULT 0
);

-- How much resistance the players face.
CREATE TABLE IF NOT EXISTS exercise_oppositions (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    description text NOT NULL,
    sort_order  integer NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS exercises (
    id              serial PRIMARY KEY,
    title           text NOT NULL,                    -- our short name
    category_id     smallint NOT NULL REFERENCES exercise_categories(id),
    opposition      text REFERENCES exercise_oppositions(code),
    moment          text CHECK (moment IN ('in_possession', 'out_of_possession', 'to_defend', 'to_attack', 'set_piece')),
    -- where it came from
    source_id       integer NOT NULL REFERENCES game_sources(id),
    book_id         integer REFERENCES coaching_books(id) ON DELETE CASCADE,
    page_from       integer,
    page_to         integer,
    source_ref      text,                             -- the book's own number, e.g. 'Practice 23'
    coach           text,                             -- whose session it is credited to, e.g. 'Guardiola (Man City)'
    -- what we know about it
    objective       text NOT NULL,                    -- what it trains, 1 sentence
    setup           text,                             -- area, cones, goals, where players start
    procedure       text,                             -- how it runs, our words
    rules           text,                             -- touch limits, scoring, restrictions
    progressions    text,                             -- variations / harder / easier
    coaching_points text,
    players_text    text,                             -- as written, e.g. '6v4+2', '3 groups of 4'
    min_players     integer,
    max_players     integer,
    area_text       text,                             -- as written, e.g. '30x20 yards', 'half pitch'
    area_length_m   real,
    area_width_m    real,
    duration_min    real,                             -- total minutes when the source gives it
    has_goals       boolean,                          -- small-sided game / finishing to goals
    has_keepers     boolean,
    directional     boolean,                          -- play towards targets / end zones / goals
    age_text        text,                             -- e.g. 'U9-U12', 'senior'
    sort_order      integer NOT NULL DEFAULT 0,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CHECK (page_to IS NULL OR page_from IS NULL OR page_to >= page_from),
    CHECK (book_id IS NULL OR page_from IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS exercises_book_idx     ON exercises (book_id, sort_order);
CREATE INDEX IF NOT EXISTS exercises_category_idx ON exercises (category_id);
CREATE INDEX IF NOT EXISTS exercises_source_idx   ON exercises (source_id);

INSERT INTO exercise_categories (code, label, icon, description, sort_order) VALUES
  ('warm_up',            'Warm-up',                  '🔥', 'Activation, mobility, injury prevention (FIFA 11+), ball-mastery warm-ups.', 10),
  ('passing_unopposed',  'Unopposed passing',        '🔁', 'Passing circuit or pattern with no defenders: set routes, players follow their pass.', 20),
  ('passing_opposed',    'Opposed passing',          '🎯', 'A passing pattern or circuit with passive or live defenders added.', 30),
  ('rondo',              'Rondo',                    '⭕', 'Keep-ball with players around the outside and defenders in the middle.', 40),
  ('possession',         'Possession game',          '🔄', 'Keep-ball in an area with no direction: count passes, keep it from the other team.', 50),
  ('positional_game',    'Positional game',          '🧭', 'Directional possession: play through zones or lines to targets, end zones, gates or a neutral, no goals.', 60),
  ('small_sided_game',   'Small-sided game',         '🥅', 'Two teams playing to goals (with or without keepers), conditioned or free.', 70),
  ('phase_of_play',      'Phase of play',            '🧩', 'Unit against unit on part of the pitch towards one goal: build-up, attacking, defending block.', 80),
  ('combination',        'Combination to finish',    '⚡', 'A rehearsed attacking pattern that ends in a shot, unopposed or with few defenders.', 90),
  ('finishing',          'Finishing',                '💥', 'Shooting and finishing, including crossing and finishing.', 100),
  ('one_v_one',          '1v1 / small numbers',      '🤺', '1v1, 2v1, 2v2, 3v2 duels to goal or line.', 110),
  ('technical',          'Technical',                '🦶', 'First touch, receiving, dribbling, ball mastery, heading: technique without a team problem.', 120),
  ('transition',         'Transition game',          '↔️', 'Built around winning or losing the ball: counter-press, counter-attack, recovery runs.', 130),
  ('defending',          'Defending / pressing',     '🛡️', 'Defending unit or pressing practice: shape, shifting, cover, pressing triggers.', 140),
  ('conditioned_game',   'Conditioned game',         '🏟️', 'Large-sided game (8v8 to 11v11) with conditions to bring out the theme.', 150),
  ('set_piece',          'Set piece',                '🚩', 'Corners, free kicks, throw-ins, kick-offs.', 160),
  ('goalkeeping',        'Goalkeeping',              '🧤', 'Goalkeeper-specific training.', 170),
  ('conditioning',       'Speed / conditioning',     '🏃', 'Speed, agility, repeated sprints, fitness with or without the ball.', 180)
ON CONFLICT (code) DO NOTHING;

INSERT INTO exercise_oppositions (code, label, description, sort_order) VALUES
  ('unopposed', 'Unopposed', 'No defenders.', 1),
  ('passive',   'Passive',   'Defenders or mannequins block lines but do not try to win the ball.', 2),
  ('opposed',   'Opposed',   'Live defenders trying to win the ball.', 3),
  ('overload',  'Overload',  'Live, with the attackers given extra players (e.g. 4v2, 6v4+2).', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO schema_migrations (filename) VALUES ('2191-exercise-catalog.sql') ON CONFLICT DO NOTHING;
COMMIT;
