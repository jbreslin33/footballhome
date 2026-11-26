-- 1940 (2026-11-26): GAME MODELS as a taxonomy — ours included equally with everyone else's.
-- Owner 11/26: "we already have a us game model page. i think that needs modernizing to new fh format and just be
-- included equally with everyone else game models right?" · "do all … normalized db … fk relations".
--
-- A game model = the whole plan: per moment, which principles come first, in which formation and playing style, with
-- which concepts and how much (game_model_concepts / game_model_role_concepts already hold "how much", 0–100).
--   game_models                 one model; now WHOSE (source_id → game_sources), its style (style_id → game_styles),
--                               its formation family (formation_family_id → game_formation_families)
--   game_model_moments          the model in its own words, one line per moment (moment → game_moments)
--   game_model_principles       which principles of play it puts first, per moment (→ game_play_principles)
--   game_model_style_settings   its own settings on the style axes (→ game_style_dimensions), where it says them
--   game_model_popularity       views: across all models, which principles / styles / formations are chosen most
--
-- OUR model (#game-model, club_game_model 176 "U17+ Game Model", US Soccer-aligned) joins by FK, not by copy:
--   club_game_model.game_model_id → game_models;  club_game_model_phases.moment → game_moments;
--   club_game_model_principles.play_principle_id → game_play_principles.  Its 20 principles then count as a source in
--   the principles popularity (source 'lighthouse-game-model', which draws on US Soccer's).

-- ── 1. game_models: whose, which style, which shape ──────────────────────────────────────────────────────────────
ALTER TABLE game_models ADD COLUMN IF NOT EXISTS source_id integer REFERENCES game_sources(id);
ALTER TABLE game_models ADD COLUMN IF NOT EXISTS style_id integer REFERENCES game_styles(id);
ALTER TABLE game_models ADD COLUMN IF NOT EXISTS formation_family_id integer REFERENCES game_formation_families(id);
ALTER TABLE game_models ADD COLUMN IF NOT EXISTS era text NOT NULL DEFAULT '';
ALTER TABLE game_models ADD COLUMN IF NOT EXISTS verified boolean NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS game_model_moments (
    model_id  integer NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    moment    text NOT NULL REFERENCES game_moments(code),
    plan      text NOT NULL,
    citation  text NOT NULL DEFAULT '',
    PRIMARY KEY (model_id, moment)
);
CREATE TABLE IF NOT EXISTS game_model_principles (
    model_id     integer NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    principle_id integer NOT NULL REFERENCES game_play_principles(id),
    moment       text NOT NULL REFERENCES game_moments(code),
    emphasis     smallint NOT NULL DEFAULT 2 CHECK (emphasis BETWEEN 1 AND 3),   -- 3 = a headline of the model
    own_words    text NOT NULL DEFAULT '',
    PRIMARY KEY (model_id, principle_id, moment)
);
CREATE TABLE IF NOT EXISTS game_model_style_settings (
    model_id     integer NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    dimension_id integer NOT NULL REFERENCES game_style_dimensions(id),
    value        smallint NOT NULL CHECK (value BETWEEN -2 AND 2),
    PRIMARY KEY (model_id, dimension_id)
);

-- ── 2. our model, connected ──────────────────────────────────────────────────────────────────────────────────────
INSERT INTO game_sources (code, kind, title, url, verified)
VALUES ('lighthouse-game-model', 'club', 'Lighthouse 1893 SC — U17+ Game Model (#game-model), US Soccer-aligned four moments', NULL, true)
ON CONFLICT (code) DO NOTHING;
INSERT INTO game_source_lineage (source_id, draws_on_id, note, verified)
SELECT a.id, b.id, 'built on US Soccer''s U17+ four-moments framework', true
  FROM game_sources a, game_sources b WHERE a.code = 'lighthouse-game-model' AND b.code = 'us-soccer-u17'
ON CONFLICT DO NOTHING;

ALTER TABLE club_game_model ADD COLUMN IF NOT EXISTS game_model_id integer REFERENCES game_models(id);
ALTER TABLE club_game_model_phases ADD COLUMN IF NOT EXISTS moment text REFERENCES game_moments(code);
ALTER TABLE club_game_model_principles ADD COLUMN IF NOT EXISTS play_principle_id integer REFERENCES game_play_principles(id);

UPDATE club_game_model_phases SET moment = m.moment
  FROM (VALUES ('attacking', 'in_possession'), ('defending', 'out_of_possession'),
               ('attacking-to-defending-transition', 'to_defend'), ('defending-to-attacking-transition', 'to_attack')) AS m(slug, moment)
 WHERE club_game_model_phases.slug = m.slug AND club_game_model_phases.moment IS NULL;

UPDATE club_game_model_principles c SET play_principle_id = p.id
  FROM game_play_principles p,
       (VALUES ('create-attacking-shape', 'width'), ('provide-options-to-play-forward', 'support'),
               ('break-lines-to-advance-attack', 'penetration'), ('take-countermeasures-anticipate-opponent-counter', 'x-rest-defence'),
               ('finish-the-attack', 'finish'), ('create-defending-shape', 'compactness'), ('build-pressure-on-the-ball', 'pressure'),
               ('recover-when-pressure-is-broken', 'x-recovery-run-recover-shape'),
               ('take-countermeasures-anticipate-to-counter-def', 'x-anticipate-transition'), ('deny-the-finish', 'protect-goal'),
               ('apply-immediate-pressure-on-the-ball', 'immediate-regain'), ('delay-the-counterattack-atd', 'pressure'),
               ('recover-with-speed-atd', 'x-recovery-run-recover-shape'), ('take-countermeasures-anticipate-the-counter-atd', 'x-anticipate-transition'),
               ('deny-finish-from-counterattack', 'protect-goal'), ('play-forward-quickly', 'x-counter-attack'), ('secure-the-ball', 'keep-ball'),
               ('join-the-attack-with-speed', 'support'), ('take-countermeasures-anticipate-the-counter-dta', 'x-rest-defence'),
               ('finish-the-counterattack-as-fast-as-possible', 'finish')) AS m(slug, pp)
 WHERE c.slug = m.slug AND p.code = m.pp AND c.play_principle_id IS NULL;

-- ── 3. the models: federations, clubs/coaches, ours ──────────────────────────────────────────────────────────────
INSERT INTO game_models (name, kind, note, sort_order, era, source_id, style_id, formation_family_id, verified)
SELECT v.name, v.kind, v.note, v.o, v.era, s.id, st.id, f.id, v.ver
  FROM (VALUES
    ('Lighthouse 1893 SC — U17+', 'club', 'Our model (#game-model): US Soccer''s four moments, 20 principles with sub-principles and player actions.', 1, '2026', 'lighthouse-game-model', NULL, NULL, true),
    ('US Soccer — U17+ four moments', 'federation', 'Attacking, defending and the two transitions, each with its principles (Player Development Framework).', 2, '2020s', 'us-soccer-u17', NULL, NULL, false),
    ('England DNA', 'federation', 'In possession / out of possession / transition, three headlines each (FA, 2014).', 3, '2014–', 'fa-england', 'positional-play', NULL, false),
    ('KNVB — Dutch school', 'federation', 'Team tasks per main moment, 1-4-3-3, total football heritage.', 4, '', 'knvb', 'total-football', '4-3-3', false),
    ('Football Australia — National Curriculum', 'federation', 'Four main moments with team tasks, 1-4-3-3.', 5, '2009–', 'football-australia', NULL, '4-3-3', false),
    ('RFEF — youth national teams', 'federation', 'Positional play in a 4-3-3; every player knows his role in every zone.', 6, '', 'rfef', 'positional-play', '4-3-3', false),
    ('PZPN — Narodowy Model Gry', 'federation', 'Poland''s national game model, 1-3-5-2.', 7, '2020s', 'pzpn', NULL, '3-5-2', false),
    ('Guardiola — Manchester City', 'club', 'Positional play, counter-press, 4-3-3 that becomes a 3-2-5 with the ball.', 20, '2016–', 'guardiola', 'positional-play', '4-3-3', false),
    ('Klopp — Liverpool', 'club', 'Gegenpressing from a 4-3-3.', 21, '2015–2024', 'klopp', 'gegenpressing', '4-3-3', false),
    ('Klopp — Dortmund', 'club', 'Gegenpressing from a 4-2-3-1.', 22, '2008–2015', 'klopp', 'gegenpressing', '4-2-3-1', false),
    ('Rangnick — Red Bull school', 'club', 'Gegenpressing, vertical, 4-2-2-2.', 23, '2010s', 'rangnick', 'gegenpressing', '4-2-2-2', false),
    ('Sacchi — Milan', 'club', 'Zonal pressing in a short, high 4-4-2.', 24, '1987–1991', 'sacchi', 'zonal-pressing', '4-4-2', false),
    ('Cruyff — Barcelona Dream Team', 'club', 'Total football / positional play in a 3-4-3 diamond.', 25, '1988–1996', 'cruyff', 'total-football', '3-4-3', false),
    ('Simeone — Atlético Madrid', 'club', 'Compact 4-4-2 mid block, counter-attack.', 26, '2011–', 'simeone', 'counter-attacking', '4-4-2', false),
    ('Mourinho — Real Madrid 2011-12', 'club', 'Compact 4-2-3-1, fast counter-attacks (Terzis, Defending).', 27, '2011–12', 'book-terzis-mourinho-real-madrid-defending', 'counter-attacking', '4-2-3-1', true),
    ('Bielsa — Leeds', 'club', 'Man-oriented pressing, 3-3-1-3 / 4-1-4-1.', 28, '2018–2022', 'bielsa', 'man-oriented', '3-3-1-3', false),
    ('Gasperini — Atalanta', 'club', 'Man-to-man all over the pitch from a 3-4-2-1.', 29, '2016–', 'gasperini', 'man-oriented', '3-4-2-1', false),
    ('Herrera — Grande Inter', 'club', 'Catenaccio: man-marking with a libero, counter.', 30, '1960s', 'catenaccio', 'catenaccio', NULL, false)
  ) AS v(name, kind, note, o, era, src, style, fam, ver)
  JOIN game_sources s ON s.code = v.src
  LEFT JOIN game_styles st ON st.code = v.style
  LEFT JOIN game_formation_families f ON f.code = v.fam
ON CONFLICT (name) DO NOTHING;

UPDATE game_models SET source_id = (SELECT id FROM game_sources WHERE code = 'statsbomb-pl1516'),
       formation_family_id = (SELECT id FROM game_formation_families WHERE code = '4-2-3-1')
 WHERE name = 'Premier League 2015/16' AND source_id IS NULL;
UPDATE club_game_model SET game_model_id = (SELECT id FROM game_models WHERE name = 'Lighthouse 1893 SC — U17+') WHERE id = 176 AND game_model_id IS NULL;

-- ── 4. per moment, in the model's own words, and the principles it puts first ───────────────────────────────────
-- Ours and US Soccer's: straight from the club model's phases and principles (one source of truth: club_game_model_*).
INSERT INTO game_model_moments (model_id, moment, plan, citation)
SELECT gm.id, ph.moment, string_agg(p.title, ' · ' ORDER BY p.sort_order), '#game-model'
  FROM club_game_model c JOIN game_models gm ON gm.id = c.game_model_id
  JOIN club_game_model_phases ph ON ph.club_game_model_id = c.id
  JOIN club_game_model_principles p ON p.phase_id = ph.id
 WHERE ph.moment IS NOT NULL
 GROUP BY gm.id, ph.moment
ON CONFLICT DO NOTHING;
INSERT INTO game_model_principles (model_id, principle_id, moment, emphasis, own_words)
SELECT DISTINCT ON (gm.id, p.play_principle_id, ph.moment) gm.id, p.play_principle_id, ph.moment, 3, p.title
  FROM club_game_model c JOIN game_models gm ON gm.id = c.game_model_id
  JOIN club_game_model_phases ph ON ph.club_game_model_id = c.id
  JOIN club_game_model_principles p ON p.phase_id = ph.id
 WHERE ph.moment IS NOT NULL AND p.play_principle_id IS NOT NULL
ON CONFLICT DO NOTHING;
INSERT INTO game_model_principles (model_id, principle_id, moment, emphasis, own_words)
SELECT us.id, gmp.principle_id, gmp.moment, gmp.emphasis, gmp.own_words
  FROM game_models us, game_models ours JOIN game_model_principles gmp ON gmp.model_id = ours.id
 WHERE us.name = 'US Soccer — U17+ four moments' AND ours.name = 'Lighthouse 1893 SC — U17+'
ON CONFLICT DO NOTHING;

-- England DNA, from its own headlines (secondary sources, 11/26)
INSERT INTO game_model_moments (model_id, moment, plan, citation)
SELECT gm.id, v.m, v.plan, 'thefa.com England DNA — How we play'
  FROM game_models gm, (VALUES
    ('in_possession', 'Intelligently dominate possession, selecting the right moments to progress the play and penetrate the opposition.'),
    ('out_of_possession', 'Regain possession intelligently, winning the ball as early and as efficiently as possible; pressing: deny, delay, dictate.'),
    ('to_attack', 'Regain and attack quickly: quick forward passing and running with early support.')) AS v(m, plan)
 WHERE gm.name = 'England DNA'
ON CONFLICT DO NOTHING;
INSERT INTO game_model_principles (model_id, principle_id, moment, emphasis, own_words)
SELECT gm.id, p.id, v.m, 3, v.w
  FROM game_models gm, (VALUES ('keep-ball', 'in_possession', 'Intelligently dominate possession'), ('penetration', 'in_possession', 'progress the play and penetrate'),
                                ('immediate-regain', 'out_of_possession', 'win the ball as early as possible'), ('pressure', 'out_of_possession', 'deny, delay, dictate'),
                                ('x-counter-attack', 'to_attack', 'regain and attack quickly')) AS v(p, m, w)
  JOIN game_play_principles p ON p.code = v.p
 WHERE gm.name = 'England DNA'
ON CONFLICT DO NOTHING;
INSERT INTO game_model_style_settings (model_id, dimension_id, value)
SELECT gm.id, d.id, v.val FROM game_models gm, (VALUES ('possession', 2), ('after-loss', 2), ('after-win', 1)) AS v(dim, val)
  JOIN game_style_dimensions d ON d.code = v.dim WHERE gm.name = 'England DNA'
ON CONFLICT DO NOTHING;

-- KNVB / Football Australia team tasks
INSERT INTO game_model_moments (model_id, moment, plan, citation)
SELECT gm.id, v.m, v.plan, v.c
  FROM game_models gm JOIN (VALUES
    ('KNVB — Dutch school', 'in_possession', 'Building up and scoring.', 'KNVB Academy team tasks'),
    ('KNVB — Dutch school', 'out_of_possession', 'Disrupting their build-up and preventing goals.', 'KNVB Academy team tasks'),
    ('Football Australia — National Curriculum', 'in_possession', 'Building up, attacking and scoring.', 'FFA National Curriculum'),
    ('Football Australia — National Curriculum', 'out_of_possession', 'Disturbing and defending; make the field small.', 'FFA National Curriculum')) AS v(model, m, plan, c)
    ON gm.name = v.model
ON CONFLICT DO NOTHING;

-- ── 5. ours counts as a source of principles too (popularity view, by FK — no copied text) ───────────────────────
DROP VIEW IF EXISTS game_principle_popularity;
CREATE VIEW game_principle_popularity AS
WITH hits AS (
    SELECT l.principle_id, t.source_id, l.relation FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
    UNION ALL   -- club game models (ours): each principle by its FK, the model's source
    SELECT cp.play_principle_id, gm.source_id, 'same'
      FROM club_game_model_principles cp JOIN club_game_model_phases ph ON ph.id = cp.phase_id
      JOIN club_game_model c ON c.id = ph.club_game_model_id JOIN game_models gm ON gm.id = c.game_model_id
     WHERE cp.play_principle_id IS NOT NULL AND gm.source_id IS NOT NULL
),
up AS (
    SELECT * FROM hits
    UNION ALL
    SELECT p.parent_id, h.source_id, h.relation FROM hits h JOIN game_play_principles p ON p.id = h.principle_id WHERE p.parent_id IS NOT NULL
)
SELECT p.id, p.code, p.title, p.level, p.side,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation IN ('same', 'part_of')) AS sources,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation = 'overlaps') AS overlap_sources,
       count(DISTINCT sc.school_id) FILTER (WHERE h.relation IN ('same', 'part_of')) AS schools,
       string_agg(DISTINCT sc.school, ', ') FILTER (WHERE h.relation IN ('same', 'part_of')) AS school_codes,
       string_agg(DISTINCT s.code, ', ') AS source_codes,
       p.owner_verdict, p.owner_note,
       CASE WHEN p.owner_verdict IS NOT NULL THEN p.owner_verdict || ' (owner)' ELSE 'popularity' END AS decided_by
  FROM game_play_principles p
  LEFT JOIN up h ON h.principle_id = p.id
  LEFT JOIN game_sources s ON s.id = h.source_id
  LEFT JOIN game_source_schools sc ON sc.source_id = h.source_id
 GROUP BY p.id;

-- ── 6. what game models choose, across all of them ───────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW game_model_choices AS
SELECT 'style' AS category, st.code, st.title, count(*) AS models, string_agg(gm.name, ' · ' ORDER BY gm.sort_order) AS which
  FROM game_models gm JOIN game_styles st ON st.id = gm.style_id GROUP BY st.code, st.title
UNION ALL
SELECT 'formation', f.code, f.title, count(*), string_agg(gm.name, ' · ' ORDER BY gm.sort_order)
  FROM game_models gm JOIN game_formation_families f ON f.id = gm.formation_family_id GROUP BY f.code, f.title
UNION ALL
SELECT 'principle', p.code, p.title, count(DISTINCT gmp.model_id), string_agg(DISTINCT gm.name, ' · ')
  FROM game_model_principles gmp JOIN game_play_principles p ON p.id = gmp.principle_id JOIN game_models gm ON gm.id = gmp.model_id
 GROUP BY p.code, p.title;
