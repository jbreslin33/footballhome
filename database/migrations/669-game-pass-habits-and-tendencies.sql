-- 669 (2026-10-23) — game: pass lapses + Football Manager-style TENDENCIES
-- (game/DESIGN.md §8.42).
--
-- James: "that can also be done for skills and pass types. like football
-- manager game has. tries short passes at a certain percent. tries long
-- balls?" / "i like both ideas".
--
-- 1. The pass ladder lapses (mig 668's lapses-to) into two pass habits,
--    each right in its own system: short-simple (possession) and
--    direct-ball (route one).
-- 2. TENDENCY = how much a player LIKES a concept, apart from how well he
--    does it (50 = neutral). It weights which way he lapses, and above 50
--    he tries it on his own initiative (t − 50)% of the time, even when he
--    could do what the model asks.

INSERT INTO game_sources (code, kind, title) VALUES
 ('reep', 'analysis', 'Charles Reep: direct play (route one)')
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (151, 'short-simple', 'Short and simple', 'individual', 'in_possession', 'style', 'u14', 'wired',
  'On the ball: give it to the nearest open man — sideways or back is fine — and keep it.',
  'Every pass is a hopeful forward ball.', 4),
 (152, 'direct-ball', 'Hit it long', 'individual', 'in_possession', 'style', 'u14', 'wired',
  'On the ball: the furthest-forward man in range gets it in the air, over whatever is in between.',
  'Patient passing against a side that is waiting for it.', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 151, id, '[Guardiola] juego de posición (secondary)' FROM game_sources WHERE code = 'guardiola'
UNION ALL SELECT 152, id, '[Reep] route one' FROM game_sources WHERE code = 'reep'
UNION ALL SELECT 151, id, 'pass-ladder lapse / FM tendency (James 10/23)' FROM game_sources WHERE code = 'fh'
UNION ALL SELECT 152, id, 'pass-ladder lapse / FM tendency (James 10/23)' FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (29, 151, 'lapses-to'), (29, 152, 'lapses-to')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS game_demo_player_tendencies (
    team_id   INTEGER  NOT NULL,
    shirt     INTEGER  NOT NULL,
    concept   TEXT     NOT NULL REFERENCES game_concepts(name),
    tendency  SMALLINT NOT NULL CHECK (tendency BETWEEN 0 AND 100),
    source    TEXT     NOT NULL DEFAULT 'edited' CHECK (source IN ('derived', 'edited')),
    PRIMARY KEY (team_id, shirt, concept),
    FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_tendencies IS
    'How much a player LIKES a concept (0-100, 50 neutral), apart from his ability on it (mig 669): weights his lapses; above 50 he tries it on his own initiative (t-50)% of the time.';

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('skill', 'tendency', 'initiative', 1.0::numeric, 'ratio', 'Scales the own-initiative chance (t-50)% of a liked concept.'),
 ('concept', 'short-simple', 'min_m', 5, 'm', 'Not to a man closer than this.'),
 ('concept', 'short-simple', 'max_m', 15, 'm', 'Short = within this.'),
 ('concept', 'short-simple', 'back_m', 5, 'm', 'Sideways or back up to this far is fine.'),
 ('concept', 'direct-ball', 'min_gain_m', 10, 'm', 'Only a man at least this far ahead of him.'),
 ('concept', 'direct-ball', 'min_m', 15, 'm', 'Long = at least this far.'),
 ('concept', 'direct-ball', 'max_m', 30, 'm', 'The lofted kick''s carry (fixed power until the loft gets variable power).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- The first real case: Lighthouse APSL's 6, whose long passing James rated
-- 74-80, likes to hit it long.
INSERT INTO game_demo_player_tendencies (team_id, shirt, concept, tendency)
SELECT t.id, 6, 'direct-ball', 75 FROM game_demo_teams t
 WHERE t.name = 'Lighthouse APSL' AND EXISTS (SELECT 1 FROM game_demo_players p WHERE p.team_id = t.id AND p.shirt = 6)
ON CONFLICT DO NOTHING;
