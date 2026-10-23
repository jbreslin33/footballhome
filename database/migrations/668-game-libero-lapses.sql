-- 668 (2026-10-23) — game: LAPSES (game/DESIGN.md §8.41).
--
-- James: "a bad libero will lag behind line too much and also get caught too
-- high up" / "or is dropping back a concept and they just do it more often
-- if they are bad at our libero concept so that they drift into another
-- concept not in game model? like also stepping up into midfield a lot?" /
-- "which is a concept that is good in other systems?" / "yes i love lapses".
--
-- No "bad" concepts. When a player fails his ability roll on a concept his
-- game model demands, he LAPSES into a neighbour concept — one that is right
-- in another system — picked in proportion to his own ability on each
-- (his habit). The libero lapses two ways: too deep (the catenaccio sweeper)
-- or too high (the front-foot step-out). The roll is per 3 s window, so a
-- lapse lasts long enough to cost something.

ALTER TABLE game_concept_links DROP CONSTRAINT IF EXISTS game_concept_links_kind_check;
ALTER TABLE game_concept_links ADD CONSTRAINT game_concept_links_kind_check
    CHECK (kind IN ('requires', 'refines', 'counters', 'lapses-to'));
COMMENT ON COLUMN game_concept_links.kind IS
    'requires / refines / counters; lapses-to = what a player drifts into when he fails his roll on concept_id (mig 668): a neighbour concept right in another system, weighted by his ability on it.';

INSERT INTO game_sources (code, kind, title) VALUES
 ('catenaccio', 'coach', 'Nereo Rocco / Helenio Herrera: catenaccio (libero behind the line)')
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (149, 'deep-sweeper', 'Sweeper behind the line', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Deep block: the free man sits a few metres behind the line at all times, ball covered or not, and sweeps up what comes through.',
  'Balls in behind a deep line go uncontested.', 9),
 (150, 'step-out', 'Step out to the man between the lines', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'Front-foot defending: leave the line and engage the opponent receiving between the lines in your channel, goal-side.',
  'Their 10 turns between the lines unchallenged.', 9)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 149, id, '[Catenaccio] libero staccato' FROM game_sources WHERE code = 'catenaccio'
UNION ALL SELECT 150, id, '[Gasperini] man-orientation, defenders step out' FROM game_sources WHERE code = 'gasperini'
UNION ALL SELECT 149, id, 'lapse of the libero (James 10/23)' FROM game_sources WHERE code = 'fh'
UNION ALL SELECT 150, id, 'lapse of the libero (James 10/23)' FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (26, 149, 'lapses-to'), (26, 150, 'lapses-to')
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'libero', 'lapse_window_s', 3::numeric, 's', 'One ability roll per window: a failed roll is a lapse that lasts the window.'),
 ('concept', 'deep-sweeper', 'depth_m', 4, 'm', 'How far behind the deepest teammate he sits, always.'),
 ('concept', 'deep-sweeper', 'lateral_follow', 1.0, 'ratio', 'Into the ball''s channel.'),
 ('concept', 'deep-sweeper', 'lateral_max_m', 19, 'm', 'Channels 2-4.'),
 ('concept', 'deep-sweeper', 'long_ball_lead_s', 0.8, 's', 'A long ball in the air: met where it lands, this far ahead.'),
 ('concept', 'deep-sweeper', 'long_ball_height_m', 1, 'm', 'Ball above this = a long ball.'),
 ('concept', 'step-out', 'reach_m', 20, 'm', 'How far ahead of the line he looks for the man between the lines.'),
 ('concept', 'step-out', 'channel_m', 13.6, 'm', 'Only a man within one channel across.'),
 ('concept', 'step-out', 'goal_side_m', 1.5, 'm', 'Goal-side of the man he engages.'),
 ('concept', 'step-out', 'step_m', 6, 'm', 'Nobody there: he still steps this far ahead of the line.'),
 ('concept', 'step-out', 'lateral_follow', 1.0, 'ratio', 'Into the ball''s channel.'),
 ('concept', 'step-out', 'lateral_max_m', 19, 'm', 'Channels 2-4.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
