-- 652 (2026-10-23) — game: the taxonomy of football, game models,
-- formation roles (game/DESIGN.md §8.34).
--
-- James: "what we want is a taxonomy of football. then the game models
-- filter right? then the formation filters further then the player filters
-- further." The chain, as tables:
--   taxonomy   game_moments → game_principles (a tree) → game_concepts,
--              with game_sources / game_concept_sources (many sources per
--              idea: Bielsa, Klopp and Pochettino teach the same press run)
--              and game_concept_links (requires / refines / counters);
--   game model game_models (school / club / federation / formation / team,
--              with a PARENT: a team model is its school plus changes) →
--              game_model_concepts (DEMAND 0-100) + game_model_concept_params
--              (a model's own numbers, e.g. a counter-press window);
--   formation  game_roles, formation_slot_roles (slot → role),
--              game_role_concepts (what a role carries — the coaching list
--              per position), game_model_role_concepts (role demand inside
--              one model);
--   player     game_demo_player_concepts stays: the player's ABILITY.
-- fh-game plays min(demand, ability); demand − ability is what to coach.
--
-- Style concepts become learnable (taught_from set): any amateur+ can
-- follow a man if coached to; whether he is asked is the model's DEMAND
-- (style default demand 0, core 100). libero / cover-shadow stay role
-- skills (no default ability; the rostered role rows give it).
-- The presets (mig 630/631/644) move into game_models; the old preset
-- tables and the free-text sources / requires go.

CREATE TABLE IF NOT EXISTS game_moments (
    code TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    sort_order SMALLINT NOT NULL
);
INSERT INTO game_moments (code, title, sort_order) VALUES
 ('in_possession', 'In possession', 1),
 ('out_of_possession', 'Out of possession', 2),
 ('to_defend', 'Transition: we lose it', 3),
 ('to_attack', 'Transition: we win it', 4),
 ('set_piece', 'Set pieces', 5)
ON CONFLICT (code) DO UPDATE SET title = EXCLUDED.title, sort_order = EXCLUDED.sort_order;

DO $$
DECLARE c TEXT;
BEGIN
  FOR c IN SELECT conname FROM pg_constraint
            WHERE conrelid = 'game_concepts'::regclass AND contype = 'c'
              AND (pg_get_constraintdef(oid) LIKE '%moment%' OR pg_get_constraintdef(oid) LIKE '%taught_from IS NULL%')
  LOOP EXECUTE format('ALTER TABLE game_concepts DROP CONSTRAINT %I', c); END LOOP;
END $$;
ALTER TABLE game_concepts ADD CONSTRAINT game_concepts_moment_fk FOREIGN KEY (moment) REFERENCES game_moments(code);

CREATE TABLE IF NOT EXISTS game_principles (
    id          SERIAL PRIMARY KEY,
    code        TEXT NOT NULL UNIQUE,
    moment      TEXT NOT NULL REFERENCES game_moments(code),
    parent_id   INTEGER REFERENCES game_principles(id),
    title       TEXT NOT NULL,
    description TEXT NOT NULL,
    sort_order  SMALLINT NOT NULL
);
COMMENT ON TABLE game_principles IS 'Taxonomy tree (mig 652): moment → main principle → sub-principle; concepts hang off the leaves.';
INSERT INTO game_principles (code, moment, title, description, sort_order) VALUES
 ('ip-build-up', 'in_possession', 'Build up from the back', 'Get the ball out of our third into midfield in control.', 1),
 ('ip-shape', 'in_possession', 'Attacking shape', 'Height, width and depth: stretch them and give the ball options.', 2),
 ('ip-secure', 'in_possession', 'Keep the ball', 'Receive, protect and circulate without giving it away; stay ready for the loss.', 3),
 ('ip-progress', 'in_possession', 'Break the lines', 'Play and run forward through or behind their lines.', 4),
 ('ip-create', 'in_possession', 'Create chances', 'Turn arrival in the final third into a clear chance.', 5),
 ('ip-finish', 'in_possession', 'Finish', 'Shoot well: pick the moment and place it.', 6),
 ('op-pressure', 'out_of_possession', 'Pressure on the ball', 'The first defender: close, delay, show, win it.', 7),
 ('op-press-team', 'out_of_possession', 'Press as a team', 'Triggers, traps and who presses whom.', 8),
 ('op-compact', 'out_of_possession', 'Compact shape and line', 'Keep the block tight and the line right: protect the space behind and between.', 9),
 ('op-mark', 'out_of_possession', 'Mark and track', 'Take the right man and stay with him.', 10),
 ('op-protect-goal', 'out_of_possession', 'Protect the goal', 'Box defending: block, clear, defend crosses.', 11),
 ('op-keeper', 'out_of_possession', 'The keeper defends', 'Sweep, narrow the angle, command the box.', 12),
 ('td-regain', 'to_defend', 'Win it straight back', 'The first seconds after losing it: pressure to regain.', 13),
 ('td-recover', 'to_defend', 'Delay and recover', 'Slow the counter, get back goal-side, rebuild the shape.', 14),
 ('ta-forward', 'to_attack', 'First action forward', 'Go at goal before they reorganise.', 15),
 ('ta-secure', 'to_attack', 'Secure the regain', 'Keep the ball we just won.', 16),
 ('ta-spread', 'to_attack', 'Make the pitch big', 'Spread out at once to give the ball room.', 17),
 ('sp-attack', 'set_piece', 'Attacking set pieces', 'Corners, free kicks, throw-ins in our favour.', 18),
 ('sp-defend', 'set_piece', 'Defending set pieces', 'Their corners, free kicks and throw-ins.', 19)
ON CONFLICT (code) DO UPDATE SET moment = EXCLUDED.moment, title = EXCLUDED.title, description = EXCLUDED.description, sort_order = EXCLUDED.sort_order;

ALTER TABLE game_concepts ADD COLUMN IF NOT EXISTS principle_id INTEGER REFERENCES game_principles(id);
UPDATE game_concepts c SET principle_id = p.id FROM game_principles p, (VALUES
 ('delay', 'td-recover'),
 ('marking', 'op-mark'),
 ('cover', 'op-pressure'),
 ('support', 'ip-secure'),
 ('outlet', 'ip-secure'),
 ('runs', 'ip-progress'),
 ('over-top', 'ip-progress'),
 ('sweep', 'op-keeper'),
 ('placement', 'ip-finish'),
 ('line-hold', 'op-compact'),
 ('jockey-angle', 'op-pressure'),
 ('recover', 'td-recover'),
 ('double-team', 'op-press-team'),
 ('width', 'ip-shape'),
 ('give-and-go', 'ip-progress'),
 ('push-up', 'op-compact'),
 ('counter-press', 'td-regain'),
 ('balance', 'op-compact'),
 ('man-mark', 'op-mark'),
 ('verticality', 'ip-progress'),
 ('intercept', 'op-pressure'),
 ('restraint', 'op-pressure'),
 ('tackle-timing', 'op-pressure'),
 ('counter-attack', 'ta-forward'),
 ('safe-pass', 'ip-secure'),
 ('shot-selection', 'ip-finish'),
 ('libero', 'op-compact'),
 ('cover-shadow', 'op-press-team'),
 ('line-step', 'op-compact'),
 ('pass-ladder', 'ip-progress'),
 ('blind-side-run', 'ip-progress'),
 ('first-touch-direction', 'ip-secure'),
 ('shield-ball', 'ip-secure'),
 ('scan-before-receive', 'ip-secure'),
 ('half-turn-receive', 'ip-progress'),
 ('beat-man-1v1', 'ip-create'),
 ('match-up', 'op-mark'),
 ('pivot-drop', 'ip-build-up'),
 ('pivot-step', 'op-press-team'),
 ('inside-forward', 'ip-create'),
 ('ten-arrives', 'ip-create'),
 ('overlap', 'ip-create'),
 ('underlap', 'ip-create'),
 ('rotation', 'ip-progress'),
 ('press-minus-one', 'op-press-team'),
 ('touchline-trap', 'op-press-team'),
 ('back-to-goal-trap', 'op-press-team'),
 ('loose-pass-trap', 'op-press-team'),
 ('press-through', 'op-pressure'),
 ('chain-recover', 'td-recover'),
 ('find-your-man', 'td-recover'),
 ('screen-transition', 'td-recover'),
 ('regain-spread', 'ta-spread'),
 ('second-ball', 'ta-secure'),
 ('eights-high', 'ip-shape'),
 ('inverted-fullback', 'ip-shape'),
 ('hold-width-weak-side', 'ip-shape'),
 ('switch-play', 'ip-progress'),
 ('box-occupancy', 'ip-create'),
 ('drive-into-space', 'ip-progress'),
 ('release-timing', 'ip-create'),
 ('body-feint-pass', 'ip-create'),
 ('change-of-pace', 'ip-create'),
 ('block-shot-line', 'op-protect-goal'),
 ('win-duel', 'op-pressure'),
 ('wall-pass', 'ip-progress'),
 ('third-man', 'ip-progress'),
 ('compact-block', 'op-compact'),
 ('press-as-unit', 'op-press-team'),
 ('play-out-back', 'ip-build-up'),
 ('rest-defense', 'ip-secure'),
 ('offside-trap', 'op-compact'),
 ('tempo-control', 'ip-secure'),
 ('narrow-angle', 'op-keeper'),
 ('distribute-quickly', 'ta-forward'),
 ('command-box', 'op-keeper')
) AS v(concept, principle) WHERE c.name = v.concept AND p.code = v.principle;

-- Style concepts: learnable from amateur up (ability); asked for only by a
-- model (demand). libero / cover-shadow stay role skills.
UPDATE game_concepts SET taught_from = 'amateur'
 WHERE name IN ('man-mark', 'verticality', 'counter-attack', 'line-step', 'pass-ladder', 'blind-side-run');
COMMENT ON COLUMN game_concepts.taught_from IS 'Lowest level band whose players KNOW it by default (ability = band quality). NULL = nobody by default (a role skill, or not yet placed).';
COMMENT ON COLUMN game_concepts.kind IS 'core = any good team does it (default demand 100); style = a chosen identity (default demand 0 — only a game model asks for it).';

CREATE TABLE IF NOT EXISTS game_sources (
    id       SERIAL PRIMARY KEY,
    code     TEXT NOT NULL UNIQUE,
    kind     TEXT NOT NULL CHECK (kind IN ('book', 'coach', 'club', 'federation', 'analysis', 'fh')),
    title    TEXT NOT NULL,
    url      TEXT,
    verified BOOLEAN NOT NULL DEFAULT true
);
CREATE TABLE IF NOT EXISTS game_concept_sources (
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    source_id  INTEGER NOT NULL REFERENCES game_sources(id),
    citation   TEXT NOT NULL,          -- chapter / figure / page / url
    local_name TEXT,                   -- what that source calls it
    verified   BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (concept_id, source_id)
);
COMMENT ON TABLE game_concept_sources IS 'Who teaches each concept (mig 652): one idea, many sources and local names.';
INSERT INTO game_sources (code, kind, title, url, verified) VALUES
 ('bielsa-leeds', 'book', 'Marcelo Bielsa: Leeds United 2019/20 tactical analysis (Kindle B08TDTYFPG)', NULL, true),
 ('bielsa', 'coach', 'Marcelo Bielsa (school)', NULL, true),
 ('klopp', 'coach', 'Jürgen Klopp: gegenpressing', NULL, true),
 ('sacchi', 'coach', 'Arrigo Sacchi: zonal pressing block', NULL, true),
 ('gasperini', 'coach', 'Gian Piero Gasperini: man-orientation', NULL, true),
 ('zeman', 'coach', 'Zdeněk Zeman: vertical attack', NULL, true),
 ('buckland', 'book', 'Mat Buckland, Programming Game AI by Example (Simple Soccer)', NULL, true),
 ('knvb', 'federation', 'KNVB (Netherlands): four moments, team tasks', NULL, true),
 ('dfb', 'federation', 'DFB (Germany): Spielvision', 'https://www.dfb-akademie.de/spielvision/-/id-11008585', true),
 ('fa-england', 'federation', 'The FA (England): principles of play / England DNA', 'https://www.thefa.com/bootroom/resources/england-dna', true),
 ('us-soccer-u17', 'federation', 'U.S. Soccer Player Development Framework: U17+ game model (club copy, docs/game-model)', NULL, true),
 ('premier-league-4231', 'analysis', 'Premier League: the 4-2-3-1 explained', 'https://www.premierleague.com/en/news/4243785', true),
 ('sportmonks', 'analysis', 'sportmonks: 4-2-3-1 explained', NULL, false),
 ('coaching-standard', 'analysis', 'Standard coaching frameworks (four moments; play-practice-play)', NULL, true),
 ('fh', 'fh', 'Football Home original (James / measured in the engine)', NULL, true),
 ('fh-v1', 'fh', 'Football Home v1 2D sim (archived behaviours)', NULL, true)
ON CONFLICT (code) DO UPDATE SET kind = EXCLUDED.kind, title = EXCLUDED.title, url = EXCLUDED.url, verified = EXCLUDED.verified;
INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c.id, s.id, v.citation FROM (VALUES
 ('delay', 'fh', '[FH/James]'),
 ('marking', 'coaching-standard', 'Standard coaching frameworks'),
 ('cover', 'coaching-standard', 'Standard coaching frameworks'),
 ('support', 'buckland', '[Buckland]'),
 ('outlet', 'coaching-standard', 'Standard coaching frameworks'),
 ('runs', 'coaching-standard', 'Standard coaching frameworks'),
 ('over-top', 'fh', 'DESIGN.md §5.2'),
 ('sweep', 'coaching-standard', 'Standard coaching frameworks'),
 ('placement', 'coaching-standard', 'Standard coaching frameworks'),
 ('line-hold', 'fh', '[FH]'),
 ('jockey-angle', 'coaching-standard', 'Standard coaching frameworks'),
 ('recover', 'coaching-standard', 'Standard coaching frameworks'),
 ('double-team', 'coaching-standard', 'Standard coaching frameworks'),
 ('width', 'fh', '[FH/James]'),
 ('give-and-go', 'coaching-standard', 'Standard coaching frameworks'),
 ('push-up', 'dfb', 'DFB/RB school'),
 ('push-up', 'fh', '[FH/James]'),
 ('counter-press', 'knvb', 'KNVB four moments'),
 ('counter-press', 'klopp', 'gegenpress'),
 ('balance', 'fa-england', 'English FA principles of play'),
 ('man-mark', 'bielsa', '[Bielsa]'),
 ('man-mark', 'gasperini', 'Gasperini'),
 ('man-mark', 'bielsa-leeds', '[Bielsa-Leeds ch2]'),
 ('verticality', 'bielsa', '[Bielsa]'),
 ('verticality', 'zeman', 'Zeman'),
 ('verticality', 'bielsa-leeds', '[Bielsa-Leeds ch4]'),
 ('intercept', 'fh', '[FH] G4.14'),
 ('restraint', 'fh', '[FH] G4.16'),
 ('tackle-timing', 'fh', '[FH] G4.17'),
 ('counter-attack', 'knvb', 'KNVB moment 4'),
 ('counter-attack', 'bielsa-leeds', '[Bielsa-Leeds f13/37]'),
 ('safe-pass', 'buckland', '[Buckland]'),
 ('shot-selection', 'fh', '[FH] after the xG literature'),
 ('libero', 'bielsa', '[Bielsa]'),
 ('libero', 'bielsa-leeds', '[Bielsa-Leeds ch1/ch8]'),
 ('cover-shadow', 'bielsa', '[Bielsa]'),
 ('cover-shadow', 'klopp', 'Klopp'),
 ('cover-shadow', 'bielsa-leeds', '[Bielsa-Leeds ch3]'),
 ('line-step', 'sacchi', 'Sacchi'),
 ('line-step', 'fa-england', 'FA / KNVB / DFB back-four models'),
 ('line-step', 'knvb', 'FA / KNVB / DFB back-four models'),
 ('line-step', 'dfb', 'FA / KNVB / DFB back-four models'),
 ('pass-ladder', 'bielsa-leeds', '[Bielsa-Leeds ch4]'),
 ('blind-side-run', 'bielsa-leeds', '[Bielsa-Leeds f7/21/35/46/48/51/65/78/81/82]'),
 ('first-touch-direction', 'coaching-standard', 'Standard coaching frameworks'),
 ('shield-ball', 'coaching-standard', 'Standard coaching frameworks'),
 ('shield-ball', 'bielsa-leeds', '[Bielsa-Leeds f62/74]'),
 ('scan-before-receive', 'coaching-standard', 'Standard coaching frameworks'),
 ('half-turn-receive', 'coaching-standard', 'Standard coaching frameworks'),
 ('beat-man-1v1', 'fh-v1', '[v1] feint behavior'),
 ('match-up', 'bielsa-leeds', '[Bielsa-Leeds ch1]'),
 ('match-up', 'fh', 'James 10/22'),
 ('pivot-drop', 'bielsa-leeds', '[Bielsa-Leeds ch1, f57, ch10]'),
 ('pivot-drop', 'sportmonks', 'sportmonks 4-2-3-1'),
 ('pivot-step', 'premier-league-4231', 'Premier League 4-2-3-1 explainer'),
 ('inside-forward', 'premier-league-4231', 'Premier League 4-2-3-1 explainer'),
 ('inside-forward', 'bielsa-leeds', '[Bielsa-Leeds ch6]'),
 ('ten-arrives', 'premier-league-4231', 'Premier League 4-2-3-1 explainer'),
 ('overlap', 'bielsa-leeds', '[Bielsa-Leeds f52, goal 5]'),
 ('underlap', 'bielsa-leeds', '[Bielsa-Leeds ch5]'),
 ('rotation', 'bielsa-leeds', '[Bielsa-Leeds ch5, f5/27-31/62/80]'),
 ('press-minus-one', 'bielsa-leeds', '[Bielsa-Leeds f14-16/36]'),
 ('touchline-trap', 'bielsa-leeds', '[Bielsa-Leeds f16]'),
 ('back-to-goal-trap', 'bielsa-leeds', '[Bielsa-Leeds f17]'),
 ('loose-pass-trap', 'bielsa-leeds', '[Bielsa-Leeds f41/55]'),
 ('press-through', 'bielsa-leeds', '[Bielsa-Leeds f60/64]'),
 ('chain-recover', 'bielsa-leeds', '[Bielsa-Leeds f11/18-19]'),
 ('find-your-man', 'bielsa-leeds', '[Bielsa-Leeds ch2, f12]'),
 ('screen-transition', 'bielsa-leeds', '[Bielsa-Leeds ch1, f59]'),
 ('regain-spread', 'bielsa-leeds', '[Bielsa-Leeds f13/37/83-84]'),
 ('second-ball', 'bielsa-leeds', '[Bielsa-Leeds f66/79]'),
 ('eights-high', 'bielsa-leeds', '[Bielsa-Leeds ch1/5/7]'),
 ('inverted-fullback', 'bielsa-leeds', '[Bielsa-Leeds ch9, f52]'),
 ('hold-width-weak-side', 'bielsa-leeds', '[Bielsa-Leeds ch6, f34]'),
 ('switch-play', 'fh', 'DESIGN.md §5.2'),
 ('switch-play', 'bielsa-leeds', '[Bielsa-Leeds f34/45]'),
 ('box-occupancy', 'bielsa-leeds', '[Bielsa-Leeds f75/84, goals 1-3]'),
 ('drive-into-space', 'bielsa-leeds', '[Bielsa-Leeds f31/44/48/50/53/58]'),
 ('release-timing', 'bielsa-leeds', '[Bielsa-Leeds f54/67/71/72]'),
 ('body-feint-pass', 'bielsa-leeds', '[Bielsa-Leeds f46/61/63/69/70/73]'),
 ('change-of-pace', 'bielsa-leeds', '[Bielsa-Leeds f76-77]'),
 ('block-shot-line', 'fh', '[FH] G4.22'),
 ('win-duel', 'fh', '[FH] G4.22'),
 ('wall-pass', 'coaching-standard', 'Standard coaching frameworks'),
 ('third-man', 'fh-v1', '[v1]'),
 ('third-man', 'bielsa-leeds', '[Bielsa-Leeds f6/23]'),
 ('compact-block', 'coaching-standard', 'Standard coaching frameworks'),
 ('press-as-unit', 'sacchi', 'Sacchi'),
 ('press-as-unit', 'coaching-standard', 'standard coaching frameworks'),
 ('play-out-back', 'coaching-standard', 'Standard coaching frameworks'),
 ('rest-defense', 'coaching-standard', 'Standard coaching frameworks'),
 ('offside-trap', 'coaching-standard', 'Standard coaching frameworks'),
 ('tempo-control', 'coaching-standard', 'Standard coaching frameworks'),
 ('tempo-control', 'bielsa-leeds', '[Bielsa-Leeds ch12]'),
 ('narrow-angle', 'coaching-standard', 'Standard coaching frameworks'),
 ('distribute-quickly', 'coaching-standard', 'Standard coaching frameworks'),
 ('distribute-quickly', 'bielsa-leeds', '[Bielsa-Leeds f68]'),
 ('command-box', 'coaching-standard', 'Standard coaching frameworks')
) AS v(concept, source, citation)
  JOIN game_concepts c ON c.name = v.concept
  JOIN game_sources s ON s.code = v.source
ON CONFLICT DO NOTHING;
ALTER TABLE game_concepts DROP COLUMN IF EXISTS sources;

CREATE TABLE IF NOT EXISTS game_concept_links (
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    other_id   SMALLINT NOT NULL REFERENCES game_concepts(id),
    kind       TEXT NOT NULL CHECK (kind IN ('requires', 'refines', 'counters')),
    PRIMARY KEY (concept_id, other_id, kind),
    CHECK (concept_id <> other_id)
);
COMMENT ON TABLE game_concept_links IS 'requires = teach the other first; refines = a more specific version of the other; counters = beats the other (mig 652).';
INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT concept_id, requires_id, 'requires' FROM game_concept_requires ON CONFLICT DO NOTHING;
DROP TABLE IF EXISTS game_concept_requires;

-- Game models: the presets, now with a kind and a parent.
CREATE TABLE IF NOT EXISTS game_models (
    id             SERIAL PRIMARY KEY,
    name           TEXT NOT NULL UNIQUE,
    kind           TEXT NOT NULL CHECK (kind IN ('school', 'club', 'federation', 'formation', 'team')),
    parent_id      INTEGER REFERENCES game_models(id),
    formation_code TEXT,
    note           TEXT NOT NULL DEFAULT '',
    sort_order     INTEGER NOT NULL DEFAULT 0,
    CHECK (parent_id IS NULL OR parent_id <> id)
);
COMMENT ON TABLE game_models IS 'A game model selects and weights concepts (mig 652). A model inherits every demand of its parent it does not set itself.';
CREATE TABLE IF NOT EXISTS game_model_concepts (
    model_id   INTEGER NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    demand     SMALLINT NOT NULL CHECK (demand BETWEEN 0 AND 100),
    citation   TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (model_id, concept_id)
);
COMMENT ON COLUMN game_model_concepts.demand IS 'How much the model asks for it, 0-100; an explicit 0 is meaningful (Sacchi zeroes man-marking).';
CREATE TABLE IF NOT EXISTS game_model_concept_params (
    model_id   INTEGER NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    param      TEXT NOT NULL,
    value      NUMERIC NOT NULL,
    unit       TEXT NOT NULL,
    citation   TEXT NOT NULL,
    PRIMARY KEY (model_id, concept_id, param)
);
COMMENT ON TABLE game_model_concept_params IS 'A model''s own numbers for a concept (e.g. counter-press window 8 s for Rangnick), over game_model_params defaults.';

INSERT INTO game_models (name, kind, note, sort_order)
SELECT p.name,
       CASE p.name WHEN 'Lighthouse' THEN 'team' WHEN 'Classic 4-2-3-1' THEN 'formation' ELSE 'school' END,
       COALESCE(p.note, ''), p.sort_order
  FROM game_style_presets p
ON CONFLICT (name) DO NOTHING;
UPDATE game_models SET formation_code = '4-2-3-1' WHERE name = 'Classic 4-2-3-1';
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, LEAST(GREATEST(r.rating, 0), 100), COALESCE(r.source, '')
  FROM game_style_preset_ratings r
  JOIN game_style_presets p ON p.id = r.preset_id
  JOIN game_models m ON m.name = p.name
  JOIN game_concepts c ON c.name = r.concept
ON CONFLICT (model_id, concept_id) DO NOTHING;

-- Bielsa's role concepts are school demands (who has the role is the
-- player's ability row, written on lineup save by GameRoster).
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, v.demand, v.citation FROM (VALUES
 ('libero', 95, 'The free +1 behind man-oriented marking [Bielsa-Leeds ch1/ch2] (was a per-player row, mig 639).'),
 ('cover-shadow', 90, 'The 9 presses their building CB on the pass to the 6 [Bielsa-Leeds ch3] (was a per-player row, mig 642).')
) AS v(concept, demand, citation)
  JOIN game_models m ON m.name = 'Bielsa'
  JOIN game_concepts c ON c.name = v.concept
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

-- The two live teams get TEAM models built on their school (inheritance):
-- the semi-pro line step both were coached into (mig 642) is theirs.
INSERT INTO game_models (name, kind, parent_id, formation_code, note, sort_order)
SELECT v.name, 'team', p.id, v.formation, v.note, 100 + v.ord FROM (VALUES
 ('Lighthouse APSL', 'Bielsa', '4-3-3', 'Lighthouse APSL: Bielsa, plus our semi-pro line step.', 1),
 ('Ukrainian Nationals', 'Classic 4-2-3-1', '4-2-3-1', 'Ukrainian Nationals: a classic 4-2-3-1, plus their line step.', 2)
) AS v(name, parent, formation, note, ord)
  JOIN game_models p ON p.name = v.parent
ON CONFLICT (name) DO NOTHING;
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, 68, 'Both teams step their line at a semi-pro 68 (mig 642).'
  FROM game_models m, game_concepts c
 WHERE m.name IN ('Lighthouse APSL', 'Ukrainian Nationals') AND c.name = 'line-step'
ON CONFLICT (model_id, concept_id) DO NOTHING;

ALTER TABLE game_demo_teams DROP CONSTRAINT IF EXISTS game_demo_teams_style_preset_fkey;
ALTER TABLE game_demo_teams RENAME COLUMN style_preset TO game_model;
UPDATE game_demo_teams SET game_model = name WHERE name IN ('Lighthouse APSL', 'Ukrainian Nationals');
ALTER TABLE game_demo_teams ADD CONSTRAINT game_demo_teams_game_model_fk
  FOREIGN KEY (game_model) REFERENCES game_models(name) ON UPDATE CASCADE;

DROP TABLE IF EXISTS game_style_preset_ratings;
DROP TABLE IF EXISTS game_style_presets;

-- Formation roles.
CREATE TABLE IF NOT EXISTS game_roles (
    code  TEXT PRIMARY KEY,
    title TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS formation_slot_roles (
    formation_code TEXT NOT NULL,
    slot           SMALLINT NOT NULL,
    role           TEXT NOT NULL REFERENCES game_roles(code),
    PRIMARY KEY (formation_code, slot)
);
CREATE TABLE IF NOT EXISTS game_role_concepts (
    role       TEXT NOT NULL REFERENCES game_roles(code),
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    PRIMARY KEY (role, concept_id)
);
COMMENT ON TABLE game_role_concepts IS 'What a role carries — the coaching list per position (mig 652).';
CREATE TABLE IF NOT EXISTS game_model_role_concepts (
    model_id   INTEGER NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    role       TEXT NOT NULL REFERENCES game_roles(code),
    concept_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    demand     SMALLINT NOT NULL CHECK (demand BETWEEN 0 AND 100),
    citation   TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (model_id, role, concept_id)
);
COMMENT ON TABLE game_model_role_concepts IS 'Role demand inside one model, over the model''s team-wide demand (mig 652).';
INSERT INTO game_roles (code, title) VALUES
 ('keeper', 'Goalkeeper'),
 ('full-back', 'Full-back / wing-back'),
 ('centre-back', 'Centre-back'),
 ('single-pivot', 'The 6 (single pivot)'),
 ('double-pivot', 'Double pivot (6/8 pair)'),
 ('eight', 'The 8'),
 ('ten', 'The 10'),
 ('wide-forward', 'Winger / wide forward'),
 ('nine', 'The 9')
ON CONFLICT (code) DO UPDATE SET title = EXCLUDED.title;
INSERT INTO formation_slot_roles (formation_code, slot, role) VALUES
 ('4-3-3', 1, 'keeper'),
 ('4-3-3', 2, 'full-back'),
 ('4-3-3', 3, 'centre-back'),
 ('4-3-3', 4, 'centre-back'),
 ('4-3-3', 5, 'full-back'),
 ('4-3-3', 6, 'eight'),
 ('4-3-3', 7, 'single-pivot'),
 ('4-3-3', 8, 'eight'),
 ('4-3-3', 9, 'wide-forward'),
 ('4-3-3', 10, 'nine'),
 ('4-3-3', 11, 'wide-forward'),
 ('4-2-3-1', 1, 'keeper'),
 ('4-2-3-1', 2, 'full-back'),
 ('4-2-3-1', 3, 'centre-back'),
 ('4-2-3-1', 4, 'centre-back'),
 ('4-2-3-1', 5, 'full-back'),
 ('4-2-3-1', 6, 'double-pivot'),
 ('4-2-3-1', 7, 'double-pivot'),
 ('4-2-3-1', 8, 'wide-forward'),
 ('4-2-3-1', 9, 'ten'),
 ('4-2-3-1', 10, 'wide-forward'),
 ('4-2-3-1', 11, 'nine'),
 ('3-3-1-3', 1, 'keeper'),
 ('3-3-1-3', 2, 'centre-back'),
 ('3-3-1-3', 3, 'centre-back'),
 ('3-3-1-3', 4, 'centre-back'),
 ('3-3-1-3', 5, 'full-back'),
 ('3-3-1-3', 6, 'single-pivot'),
 ('3-3-1-3', 7, 'full-back'),
 ('3-3-1-3', 8, 'ten'),
 ('3-3-1-3', 9, 'wide-forward'),
 ('3-3-1-3', 10, 'nine'),
 ('3-3-1-3', 11, 'wide-forward')
ON CONFLICT (formation_code, slot) DO UPDATE SET role = EXCLUDED.role;
INSERT INTO game_role_concepts (role, concept_id)
SELECT v.role, c.id FROM (VALUES
 ('keeper', 'sweep'),
 ('keeper', 'narrow-angle'),
 ('keeper', 'command-box'),
 ('keeper', 'distribute-quickly'),
 ('keeper', 'play-out-back'),
 ('centre-back', 'marking'),
 ('centre-back', 'cover'),
 ('centre-back', 'line-hold'),
 ('centre-back', 'line-step'),
 ('centre-back', 'push-up'),
 ('centre-back', 'offside-trap'),
 ('centre-back', 'libero'),
 ('centre-back', 'block-shot-line'),
 ('centre-back', 'play-out-back'),
 ('centre-back', 'drive-into-space'),
 ('centre-back', 'recover'),
 ('centre-back', 'win-duel'),
 ('centre-back', 'intercept'),
 ('full-back', 'overlap'),
 ('full-back', 'underlap'),
 ('full-back', 'inverted-fullback'),
 ('full-back', 'jockey-angle'),
 ('full-back', 'balance'),
 ('full-back', 'double-team'),
 ('full-back', 'recover'),
 ('full-back', 'width'),
 ('single-pivot', 'pivot-drop'),
 ('single-pivot', 'screen-transition'),
 ('single-pivot', 'safe-pass'),
 ('single-pivot', 'switch-play'),
 ('single-pivot', 'pass-ladder'),
 ('single-pivot', 'tempo-control'),
 ('single-pivot', 'rest-defense'),
 ('single-pivot', 'intercept'),
 ('single-pivot', 'cover'),
 ('double-pivot', 'pivot-step'),
 ('double-pivot', 'pivot-drop'),
 ('double-pivot', 'screen-transition'),
 ('double-pivot', 'rest-defense'),
 ('double-pivot', 'safe-pass'),
 ('double-pivot', 'intercept'),
 ('double-pivot', 'cover'),
 ('double-pivot', 'tempo-control'),
 ('eight', 'eights-high'),
 ('eight', 'rotation'),
 ('eight', 'third-man'),
 ('eight', 'give-and-go'),
 ('eight', 'press-through'),
 ('eight', 'counter-press'),
 ('eight', 'release-timing'),
 ('eight', 'drive-into-space'),
 ('eight', 'box-occupancy'),
 ('ten', 'ten-arrives'),
 ('ten', 'half-turn-receive'),
 ('ten', 'scan-before-receive'),
 ('ten', 'release-timing'),
 ('ten', 'body-feint-pass'),
 ('ten', 'third-man'),
 ('ten', 'cover-shadow'),
 ('ten', 'box-occupancy'),
 ('wide-forward', 'width'),
 ('wide-forward', 'hold-width-weak-side'),
 ('wide-forward', 'inside-forward'),
 ('wide-forward', 'beat-man-1v1'),
 ('wide-forward', 'change-of-pace'),
 ('wide-forward', 'blind-side-run'),
 ('wide-forward', 'regain-spread'),
 ('wide-forward', 'double-team'),
 ('wide-forward', 'recover'),
 ('nine', 'runs'),
 ('nine', 'blind-side-run'),
 ('nine', 'cover-shadow'),
 ('nine', 'shield-ball'),
 ('nine', 'box-occupancy'),
 ('nine', 'shot-selection'),
 ('nine', 'placement'),
 ('nine', 'press-minus-one'),
 ('nine', 'second-ball')
) AS v(role, concept) JOIN game_concepts c ON c.name = v.concept
ON CONFLICT DO NOTHING;
