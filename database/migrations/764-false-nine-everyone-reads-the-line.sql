-- 764 (2026-10-27) — game: everyone reads the high line; the false 9 drops
-- in and sends it long (181); a centre-back organises when the keeper is
-- out of voice range (game/DESIGN.md §8.75, G4.78).
--
-- James 10/27: "1) all players should communicate so yes. 3) yes everyone
-- including false 9 dropping in and taking care of it to send long ball
-- like harry kane. (that should be in lh game model as that is how our 9
-- should play when Luke Breslin is in)"
--
-- false-nine-drop is a role skill (taught_from NULL: nobody knows it by
-- default, like the libero) — Luke's own ability row is what makes it
-- happen; the Lighthouse models ask for it. Every other top-level model
-- states 0 (mig 762: a new concept names every root's demand).

BEGIN;

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (181, 'false-nine-drop', 'False 9: drop in, send it long', 'individual', 'in_possession', NULL, 'wired',
  'Our ball well short of their back line: come off it into the space in front of them, take it, turn and hit the runner in behind — the centre-back who followed you left the space.',
  'Stays on their last line with his back to goal while the ball can''t reach him; nobody pulls a centre-back out.',
  (SELECT id FROM game_principles WHERE code = 'ip-progress'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 181, id, 'James 10/27: "false 9 dropping in and taking care of it to send long ball like harry kane … that is how our 9 should play when Luke Breslin is in"'
  FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'false-nine-drop', 'drop_m', 14::numeric, 'm', 'He drops to this far in front of their back line, central.'),
 ('concept', 'false-nine-drop', 'space_m', 20, 'm', 'On the ball he goes over their line when there is this much grass behind it (the line need not be high).'),
 ('concept', 'false-nine-drop', 'from_line_m', 25, 'm', 'He drops while our ball is this far or more short of their back line.'),
 ('concept', 'beat-the-high-line', 'pass_min_m', 20, 'm', 'An outfield passer goes over the line only if the ball travels this far or more.'),
 ('concept', 'beat-the-high-line', 'runner_from_line_m', 12, 'm', 'The runner he picks is onside and no more than this far short of their line.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- Every top-level model says what it asks: the Lighthouse model wants it,
-- nobody else does.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 181,
       CASE WHEN m.name = 'Lighthouse' THEN 90 ELSE 0 END,
       CASE WHEN m.name = 'Lighthouse' THEN 'James 10/27: how our 9 plays when Luke Breslin is in.'
            ELSE 'Not asked.' END
  FROM game_models m WHERE m.parent_id IS NULL
ON CONFLICT (model_id, concept_id) DO NOTHING;

-- Lighthouse APSL is Bielsa's child: it asks for it itself.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT id, 181, 90, 'James 10/27: how our 9 plays when Luke Breslin is in.'
  FROM game_models WHERE name = 'Lighthouse APSL'
ON CONFLICT (model_id, concept_id) DO NOTHING;

-- Luke knows it (his own row; a semi-pro 9 at the club's level).
INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT p.team_id, p.shirt, 'false-nine-drop', 70
  FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id
 WHERE p.name = 'Luke Breslin' AND t.name IN ('Lighthouse APSL', 'Lighthouse XI')
ON CONFLICT DO NOTHING;

COMMIT;

-- The race (G4.78, added after the first harness run: the keeper's G4.75
-- balls over the line were 91% theirs without it).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'beat-the-high-line', 'runner_speed_mps', 3, 'm/s', 'The runner is already going forward this fast (his run is on).'),
 ('concept', 'beat-the-high-line', 'race_m', 3, 'm', 'He is this much nearer the drop than any of theirs, keeper included.')
ON CONFLICT DO NOTHING;
