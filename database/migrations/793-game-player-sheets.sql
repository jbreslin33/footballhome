-- 793 (2026-10-28) — game: every player has a character sheet, rolled by
-- PlayerGenerator (game/src/core/PlayerSheet.*, tool fh-game-roll;
-- game/DESIGN.md §8.81, G4.83).
--
-- James 10/28: "use dungeons and dragons type rolls to assign experience to
-- current players and playing history and ability scores" — "why not 1d100
-- lol? then mod it based on experienmce level adn level they are at now" —
-- "apply to all and diff between starters, bench and deep bench should be
-- significant at this level" — "we beasically have a generate player
-- function right but with paramenters?" / "do we have a 'player class' in
-- c++ to handle all this?" — "yes build it that way".
--
-- REAL DATA WINS: a real birth date, his lineups (tier, positions) and every
-- 'edited' attribute stand; the dice fill the rest. Every roll is kept
-- (game_demo_player_rolls) so a sheet says why he has each number.
--
--   attribute = floor + (2 × spread) × d100/100      his rank at his level
--             + tier (starter / bench / deep bench)  from his real lineups
--             + experience (learned skills only)     his rolled history,
--               per_year × (his weighted years − his team's mean), capped
--             + position profile                     his real lineup spots
--             − pace past 30                         his age
--   floor = team quality − spread.
--   concept ability = 100 − (100 − quality) × ½^(years on it / halving_years)
--             years on it = playing years since the age it's taught
--
-- Every number here is an FH estimate for James to set (the tier gap he
-- asked to be "significant"; the history odds are a US amateur path).

BEGIN;

ALTER TABLE game_model_params DROP CONSTRAINT game_model_params_owner_check;
ALTER TABLE game_model_params ADD CONSTRAINT game_model_params_owner_check
  CHECK (owner = ANY (ARRAY['skill', 'concept', 'technique', 'physics', 'sheet']));

ALTER TABLE game_demo_players
  ADD COLUMN IF NOT EXISTS age smallint CHECK (age BETWEEN 5 AND 70),
  ADD COLUMN IF NOT EXISTS age_source text CHECK (age_source IN ('real', 'rolled')),
  ADD COLUMN IF NOT EXISTS start_age smallint CHECK (start_age BETWEEN 2 AND 40),
  ADD COLUMN IF NOT EXISTS years_off smallint CHECK (years_off >= 0),
  ADD COLUMN IF NOT EXISTS lineup_tier text CHECK (lineup_tier IN ('starter', 'bench', 'deep'));
COMMENT ON COLUMN game_demo_players.age IS 'His age (mig 793): persons.birth_date when known (age_source real), else rolled on game_sheet_tables stage age.';
COMMENT ON COLUMN game_demo_players.lineup_tier IS 'Starter / bench / deep bench from his real lineups (mig 793); the tier mod on every attribute.';

CREATE TABLE IF NOT EXISTS game_sheet_tables (
  stage     text NOT NULL,
  roll_lo   smallint NOT NULL CHECK (roll_lo BETWEEN 1 AND 100),
  roll_hi   smallint NOT NULL CHECK (roll_hi BETWEEN 1 AND 100),
  outcome   text NOT NULL,
  weight    numeric NOT NULL DEFAULT 1,   -- how much a year of it counts as experience
  years     smallint NOT NULL DEFAULT 0,  -- stage years_off: years lost; stage age: lowest age of the band
  years_hi  smallint NOT NULL DEFAULT 0,  -- stage age: highest age of the band
  PRIMARY KEY (stage, roll_lo),
  CHECK (roll_hi >= roll_lo)
);
COMMENT ON TABLE game_sheet_tables IS
  'The d100 tables a player sheet is rolled on (mig 793): youth (start age to 14), high_school (14-18), college (18-22), adult (22 on), years_off (years lost to injury/work), age (when no birth date). weight = a year of it as experience.';

INSERT INTO game_sheet_tables (stage, roll_lo, roll_hi, outcome, weight, years, years_hi) VALUES
  ('youth', 1, 25, 'rec league', 0.6, 0, 0),
  ('youth', 26, 70, 'travel club', 1.0, 0, 0),
  ('youth', 71, 93, 'premier club / academy', 1.25, 0, 0),
  ('youth', 94, 100, 'pro academy', 1.5, 0, 0),
  ('high_school', 1, 15, 'didn''t play for the school', 0.6, 0, 0),
  ('high_school', 16, 65, 'varsity', 1.0, 0, 0),
  ('high_school', 66, 100, 'varsity + club', 1.2, 0, 0),
  ('college', 1, 45, 'no college soccer: adult amateur', 0.8, 0, 0),
  ('college', 46, 65, 'college club team', 0.8, 0, 0),
  ('college', 66, 82, 'D3 / JUCO', 1.0, 0, 0),
  ('college', 83, 94, 'D2', 1.15, 0, 0),
  ('college', 95, 100, 'D1', 1.3, 0, 0),
  ('adult', 1, 60, 'adult amateur / semi-pro', 1.0, 0, 0),
  ('adult', 61, 90, 'semi-pro (APSL / UPSL / NPSL)', 1.1, 0, 0),
  ('adult', 91, 100, 'played professionally', 1.3, 0, 0),
  ('years_off', 1, 75, 'no time out', 0, 0, 0),
  ('years_off', 76, 92, 'a year out (injury / work)', 0, 1, 0),
  ('years_off', 93, 98, 'two years out', 0, 2, 0),
  ('years_off', 99, 100, 'four years out', 0, 4, 0),
  ('age', 1, 10, '18-19', 0, 18, 19),
  ('age', 11, 35, '20-23', 0, 20, 23),
  ('age', 36, 70, '24-27', 0, 24, 27),
  ('age', 71, 90, '28-31', 0, 28, 31),
  ('age', 91, 100, '32-35', 0, 32, 35)
ON CONFLICT (stage, roll_lo) DO UPDATE SET roll_hi = EXCLUDED.roll_hi, outcome = EXCLUDED.outcome,
  weight = EXCLUDED.weight, years = EXCLUDED.years, years_hi = EXCLUDED.years_hi;

CREATE TABLE IF NOT EXISTS game_sheet_position_profile (
  position_group text NOT NULL CHECK (position_group IN ('GK', 'CB', 'FB', 'DM', 'CM', 'AM', 'W', 'ST')),
  attribute      text NOT NULL REFERENCES game_attributes(code),
  offset_pts     smallint NOT NULL,
  PRIMARY KEY (position_group, attribute)
);
COMMENT ON TABLE game_sheet_position_profile IS
  'Rating points a position adds to an attribute (mig 793; was load_squads.py PROFILE + draw_bodies.py POSITION), weighted by where he has lined up.';

INSERT INTO game_sheet_position_profile (position_group, attribute, offset_pts) VALUES
  ('GK', 'goalkeeping', 10), ('GK', 'pace', -6), ('GK', 'shooting', -15), ('GK', 'tackling', -10), ('GK', 'first_touch', -4), ('GK', 'passing', -2),
  ('GK', 'acceleration', -4), ('GK', 'agility', -2), ('GK', 'dribbling', -8),
  ('CB', 'tackling', 6), ('CB', 'anticipation', 4), ('CB', 'pace', -2), ('CB', 'shooting', -6), ('CB', 'first_touch', -2), ('CB', 'passing', -1),
  ('CB', 'acceleration', -4), ('CB', 'agility', -5), ('CB', 'deceleration', 2), ('CB', 'dribbling', -5),
  ('FB', 'pace', 5), ('FB', 'tackling', 2), ('FB', 'shooting', -4), ('FB', 'passing', 1), ('FB', 'acceleration', 4), ('FB', 'agility', 3),
  ('DM', 'passing', 4), ('DM', 'decisions', 4), ('DM', 'tackling', 3), ('DM', 'anticipation', 2), ('DM', 'shooting', -3), ('DM', 'dribbling', -2),
  ('CM', 'passing', 3), ('CM', 'first_touch', 2), ('CM', 'decisions', 2),
  ('AM', 'first_touch', 4), ('AM', 'passing', 3), ('AM', 'decisions', 2), ('AM', 'shooting', 2), ('AM', 'tackling', -4), ('AM', 'agility', 3), ('AM', 'dribbling', 5),
  ('W', 'pace', 6), ('W', 'first_touch', 3), ('W', 'shooting', 1), ('W', 'tackling', -4), ('W', 'acceleration', 5), ('W', 'agility', 5), ('W', 'dribbling', 5),
  ('ST', 'shooting', 6), ('ST', 'first_touch', 3), ('ST', 'pace', 3), ('ST', 'tackling', -6), ('ST', 'passing', -1), ('ST', 'acceleration', 3), ('ST', 'agility', 2), ('ST', 'dribbling', 2)
ON CONFLICT (position_group, attribute) DO UPDATE SET offset_pts = EXCLUDED.offset_pts;

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('sheet', 'range', 'spread_pts', 20, 'pts', 'A d100 places him team quality ± this: 1 = the floor, 100 = the ceiling.'),
  ('sheet', 'tier', 'starter_pts', 10, 'pts', 'Starter (starts half his APSL games or more), on every attribute and his quality. James: significant.'),
  ('sheet', 'tier', 'bench_pts', 0, 'pts', 'Bench (in APSL matchday squads, mostly as a sub).'),
  ('sheet', 'tier', 'deep_pts', -10, 'pts', 'Deep bench (Liga 1 / Reserves lineups only, or none).'),
  ('sheet', 'experience', 'per_year_pts', 0.3, 'pts', 'Learned skills: a weighted year of football above his team''s mean adds this.'),
  ('sheet', 'experience', 'cap_pts', 6, 'pts', 'The experience mod never moves a skill more than this either way.'),
  ('sheet', 'mastery', 'halving_years', 5, 'years', 'Each this-many years playing a concept halves how often he lapses on it.'),
  ('sheet', 'start_age', 'base', 3, 'years', 'Started playing at base + 1d(die).'),
  ('sheet', 'start_age', 'die', 6, 'sides', 'Started playing at base + 1d(die).'),
  ('sheet', 'taught_age', 'u10', 8, 'years', 'Age a u10 concept is learned.'),
  ('sheet', 'taught_age', 'u14', 12, 'years', 'Age a u14 concept is learned.'),
  ('sheet', 'taught_age', 'amateur', 18, 'years', 'Age an amateur concept is learned.'),
  ('sheet', 'taught_age', 'semipro', 20, 'years', 'Age a semi-pro concept is learned.'),
  ('sheet', 'age', 'pace_from', 30, 'years', 'Pace and acceleration drop from this age.'),
  ('sheet', 'age', 'pace_per_year_pts', 1.5, 'pts', 'Pace and acceleration lost a year past pace_from.'),
  ('sheet', 'lean', 'acceleration', 0.6, '', 'His acceleration roll leans this much on his pace roll (bodies hang together).'),
  ('sheet', 'lean', 'deceleration', 0.5, '', 'Deceleration roll leans on his acceleration roll.'),
  ('sheet', 'lean', 'agility', 0.4, '', 'Agility roll leans on his acceleration roll.'),
  ('sheet', 'lean', 'dribbling', 0.5, '', 'Dribbling roll leans on his first-touch roll.'),
  ('sheet', 'goalkeeping', 'non_keeper', 25, 'pts', 'An outfielder''s goalkeeping.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;

CREATE TABLE IF NOT EXISTS game_demo_player_history (
  team_id   integer NOT NULL,
  shirt     integer NOT NULL,
  ord       smallint NOT NULL,
  stage     text NOT NULL,
  outcome   text NOT NULL,
  from_age  smallint NOT NULL,
  to_age    smallint NOT NULL,
  weight    numeric NOT NULL,
  roll      smallint NOT NULL CHECK (roll BETWEEN 1 AND 100),
  PRIMARY KEY (team_id, shirt, ord),
  FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_history IS 'His rolled football life (mig 793), stage by stage, capped by his age.';

CREATE TABLE IF NOT EXISTS game_demo_player_rolls (
  team_id  integer NOT NULL,
  shirt    integer NOT NULL,
  what     text NOT NULL,
  roll     smallint NOT NULL CHECK (roll BETWEEN 1 AND 100),
  PRIMARY KEY (team_id, shirt, what),
  FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_rolls IS 'Every d100 on his sheet (mig 793): one per attribute, start age, each history stage, age.';

COMMIT;
