-- 1939 (2026-11-26): PLAYING STYLES as a taxonomy.
-- Owner 11/26: "yes start with formations but do all" (formations → playing styles → game models).
--
-- A style is two things, so two common-ground tables:
--   game_style_dimensions   the SETTINGS a style is made of, each an axis with two ends, per moment:
--                           direct ↔ possession, narrow ↔ wide, low ↔ high block, zonal ↔ man, regroup ↔ counter-press …
--                           (the research measures style this way: Fernandez-Navarro et al. 2016, J Sports Sci 34)
--   game_styles             the NAMED styles football talks about: tiki-taka, gegenpressing, catenaccio, route one …
--   game_style_profiles     a named style's place on each axis, -2 … +2 (low end … high end) — FH's reading, owner corrects
--   game_source_styles      a style AS A SOURCE NAMES IT (its words, its context)
--   game_style_links        which named style that is: same | part_of | overlaps
--   game_style_popularity   view: sources per named style
-- A game model (next) points to its style; a sim team's style can be MEASURED from its matches later.

CREATE TABLE IF NOT EXISTS game_style_dimensions (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    moment      text NOT NULL REFERENCES game_moments(code),
    title       text NOT NULL,
    low_label   text NOT NULL,          -- the -2 end
    high_label  text NOT NULL,          -- the +2 end
    definition  text NOT NULL DEFAULT '',
    measure     text NOT NULL DEFAULT '',   -- how data measures it
    sort_order  smallint NOT NULL DEFAULT 0
);

INSERT INTO game_style_dimensions (code, moment, title, low_label, high_label, definition, measure, sort_order) VALUES
  ('possession', 'in_possession', 'Possession or direct', 'direct', 'possession', 'Does the team keep the ball and build, or go forward early?', 'possession %, passes per sequence', 1),
  ('build-up', 'in_possession', 'Build-up', 'long', 'short', 'Out from the back: played short through the lines, or long to the front.', 'share of goal kicks / back-line passes that are long', 2),
  ('tempo', 'in_possession', 'Tempo', 'patient', 'fast', 'How quickly the ball moves toward goal once a move starts.', 'metres forward per second of possession', 3),
  ('width', 'in_possession', 'Width', 'narrow', 'wide', 'Through the middle, or stretched to both touchlines.', 'average width of the team in possession', 4),
  ('crossing', 'in_possession', 'Crossing', 'few crosses', 'many crosses', 'How much the attack ends in crosses from wide.', 'crosses per possession reaching the final third', 5),
  ('rotation', 'in_possession', 'Positions', 'fixed positions', 'fluid rotation', 'Men hold their positions, or swap and rotate freely.', 'position swaps per possession', 6),
  ('block-height', 'out_of_possession', 'Block height', 'low block', 'high block', 'Where the team sets its defence: in front of its box, in midfield, or in their half.', 'average height of the defensive line without the ball', 7),
  ('pressing', 'out_of_possession', 'Pressing', 'passive', 'intense', 'How hard the team goes to the ball without it.', 'PPDA (their passes per defensive action)', 8),
  ('orientation', 'out_of_possession', 'Defending orientation', 'zonal', 'man-oriented', 'Defenders guard space, or take men.', 'distance to the nearest opponent vs to the zone', 9),
  ('after-loss', 'to_defend', 'When we lose it', 'regroup', 'counter-press', 'Drop back into shape, or win it straight back.', 'regains within 5 s of a loss', 10),
  ('after-win', 'to_attack', 'When we win it', 'secure the ball', 'counter-attack', 'Keep the ball we won, or go forward at once.', 'shots within 15 s of a regain', 11)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS game_styles (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    title       text NOT NULL,
    aka         text NOT NULL DEFAULT '',
    era         text NOT NULL DEFAULT '',
    parent_id   integer REFERENCES game_styles(id),
    definition  text NOT NULL DEFAULT '',
    owner_verdict text CHECK (owner_verdict IN ('adopt', 'reject')),
    owner_note  text NOT NULL DEFAULT '',
    sort_order  smallint NOT NULL DEFAULT 0,
    CHECK (parent_id IS NULL OR parent_id <> id)
);

INSERT INTO game_styles (code, title, aka, era, definition, sort_order) VALUES
  ('positional-play', 'Positional play', 'juego de posición; Positionsspiel', '1990s–', 'Possession built on positions held to create superiority between the lines: the free man, the third man, width and depth fixed.', 10),
  ('total-football', 'Total football', 'totaalvoetbal', '1970s', 'Any outfielder can take any other''s place: fluid rotation, high line, pressing (Michels, Cruyff).', 20),
  ('gegenpressing', 'Gegenpressing', 'counter-pressing', '2000s–', 'Win the ball back straight after losing it, before they organise; the press is the playmaker (Rangnick, Klopp).', 30),
  ('zonal-pressing', 'Zonal pressing', 'Sacchi''s pressing; la zona', '1980s–', 'A short, compact zonal block that presses together as one, high line, offside trap (Sacchi''s Milan).', 40),
  ('catenaccio', 'Catenaccio', 'the door bolt', '1950s–60s', 'Man-marking defenders with a libero behind them; defend deep, then counter (Rocco, Herrera).', 50),
  ('route-one', 'Route one', 'direct play; long ball', '1950s–', 'Get the ball forward as early as possible, long, and play from the second ball (Reep, Hughes).', 60),
  ('counter-attacking', 'Counter-attacking', 'transition football', '', 'Defend in a compact block, then go fast into the space they left when we win it.', 70),
  ('low-block', 'Low block', 'park the bus', '', 'Defend deep and narrow in front of the box, give them the ball, deny the space behind.', 80),
  ('man-oriented', 'Man-oriented pressing', 'the man-to-man press', '2000s–', 'Every defender takes a man all over the pitch and presses him (Bielsa, Gasperini).', 90),
  ('relationism', 'Relationism', 'calcio relazionale; functional play', '2020s', 'Men gather near the ball and play by their relations — short, close combinations, not fixed positions (Diniz, the FIGC paper "una nuova era").', 100),
  ('kick-and-rush', 'Kick and rush', '', '', 'Long balls forward and chase: the crudest direct style.', 110)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_styles (code, title, aka, era, parent_id, definition, sort_order)
SELECT 'tiki-taka', 'Tiki-taka', 'tiqui-taca', '2006–2012', id,
       'Short, quick passing and movement to keep the ball — the Spain / Guardiola Barcelona version of positional play.', 11
  FROM game_styles WHERE code = 'positional-play'
ON CONFLICT (code) DO NOTHING;
UPDATE game_styles c SET parent_id = p.id FROM game_styles p WHERE c.code = 'kick-and-rush' AND p.code = 'route-one' AND c.parent_id IS NULL;

CREATE TABLE IF NOT EXISTS game_style_profiles (
    style_id     integer NOT NULL REFERENCES game_styles(id) ON DELETE CASCADE,
    dimension_id integer NOT NULL REFERENCES game_style_dimensions(id),
    value        smallint NOT NULL CHECK (value BETWEEN -2 AND 2),
    PRIMARY KEY (style_id, dimension_id)
);

-- FH's reading of each named style on the axes (−2 = low end, +2 = high end); only the axes that define it.
INSERT INTO game_style_profiles (style_id, dimension_id, value)
SELECT s.id, d.id, v.val
  FROM (VALUES
    ('positional-play', 'possession', 2), ('positional-play', 'build-up', 2), ('positional-play', 'width', 1), ('positional-play', 'rotation', -1), ('positional-play', 'after-loss', 2), ('positional-play', 'block-height', 1),
    ('tiki-taka', 'possession', 2), ('tiki-taka', 'build-up', 2), ('tiki-taka', 'tempo', -1), ('tiki-taka', 'after-loss', 2),
    ('total-football', 'rotation', 2), ('total-football', 'block-height', 2), ('total-football', 'pressing', 1), ('total-football', 'possession', 1),
    ('gegenpressing', 'after-loss', 2), ('gegenpressing', 'pressing', 2), ('gegenpressing', 'tempo', 2), ('gegenpressing', 'block-height', 1), ('gegenpressing', 'after-win', 2),
    ('zonal-pressing', 'orientation', -2), ('zonal-pressing', 'pressing', 2), ('zonal-pressing', 'block-height', 2),
    ('catenaccio', 'orientation', 2), ('catenaccio', 'block-height', -2), ('catenaccio', 'after-win', 2), ('catenaccio', 'possession', -1),
    ('route-one', 'possession', -2), ('route-one', 'build-up', -2), ('route-one', 'tempo', 2), ('route-one', 'crossing', 1),
    ('kick-and-rush', 'possession', -2), ('kick-and-rush', 'build-up', -2),
    ('counter-attacking', 'after-win', 2), ('counter-attacking', 'possession', -1), ('counter-attacking', 'block-height', -1), ('counter-attacking', 'tempo', 2),
    ('low-block', 'block-height', -2), ('low-block', 'pressing', -2), ('low-block', 'width', -1), ('low-block', 'after-loss', -2),
    ('man-oriented', 'orientation', 2), ('man-oriented', 'pressing', 2), ('man-oriented', 'block-height', 1),
    ('relationism', 'rotation', 2), ('relationism', 'width', -2), ('relationism', 'possession', 1)
  ) AS v(style, dim, val)
  JOIN game_styles s ON s.code = v.style
  JOIN game_style_dimensions d ON d.code = v.dim
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS game_source_styles (
    id         serial PRIMARY KEY,
    source_id  integer NOT NULL REFERENCES game_sources(id),
    name       text NOT NULL,
    context    text NOT NULL DEFAULT '',
    locator    text NOT NULL DEFAULT '',
    verified   boolean NOT NULL DEFAULT false,
    UNIQUE (source_id, name, context)
);
CREATE TABLE IF NOT EXISTS game_style_links (
    entry_id   integer NOT NULL REFERENCES game_source_styles(id) ON DELETE CASCADE,
    style_id   integer NOT NULL REFERENCES game_styles(id),
    relation   text NOT NULL CHECK (relation IN ('same', 'part_of', 'overlaps')),
    PRIMARY KEY (entry_id, style_id)
);
-- A source can also name a DIMENSION as its style ("possession-based", "high pressing"): entry → axis + which end.
CREATE TABLE IF NOT EXISTS game_style_dimension_links (
    entry_id     integer NOT NULL REFERENCES game_source_styles(id) ON DELETE CASCADE,
    dimension_id integer NOT NULL REFERENCES game_style_dimensions(id),
    value        smallint NOT NULL CHECK (value BETWEEN -2 AND 2),
    PRIMARY KEY (entry_id, dimension_id)
);

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('fernandez-navarro-2016', 'analysis', 'Fernandez-Navarro, Fradua, Zubillaga, Ford & McRobert (2016), Attacking and defensive styles of play in soccer: Spanish and English elite teams, J Sports Sci 34, 2195–2204', 'https://irep.ntu.ac.uk/id/eprint/40699', false),
  ('wikipedia-tactics', 'analysis', 'Wikipedia, Association football tactics and skills — named styles', 'https://en.wikipedia.org/wiki/Association_football_tactics_and_skills', false),
  ('figc-relazionale', 'federation', 'FIGC Settore Tecnico, Una nuova era: il calcio relazionale', 'https://figc.it/media/233550/una-nuova-era_calcio-relazionale.pdf', false),
  ('fed-thailand-style', 'federation', 'FA Thailand, Thai Football Development Handbook 2023 — Thai style of play', NULL, false),
  ('canada-soccer-style', 'federation', 'Canada Soccer — national style "fast, aggressive and united" (TSN)', 'https://www.tsn.ca/soccer/article/fast-aggressive-and-united-inside-canada-soccers-plan-to-create-a-national-style/', false),
  ('kfa-style', 'federation', 'KFA (Korea) 2024 philosophy — 빠르고, 용맹하게, 주도하는 (fast, brave, proactive)', NULL, false)
ON CONFLICT (code) DO NOTHING;

CREATE TEMP TABLE t_s (src text, name text, ctx text, style text, rel text, dim text, val smallint) ON COMMIT DROP;
INSERT INTO t_s VALUES
  -- named styles: the clubs and coaches that are their source
  ('guardiola', 'Juego de posición', 'Barcelona / Bayern / City', 'positional-play', 'same', NULL, NULL),
  ('guardiola', 'Tiki-taka', 'Barcelona 2008–12 (a name he rejects)', 'tiki-taka', 'overlaps', NULL, NULL),
  ('rfef', 'Juego de posición', 'youth national teams', 'positional-play', 'same', NULL, NULL),
  ('rfef', 'Tiki-taka', 'Spain 2008–12', 'tiki-taka', 'same', NULL, NULL),
  ('barca-masia', 'Possession, position, pressing', 'La Masia', 'positional-play', 'same', NULL, NULL),
  ('cruyff', 'Total football', 'Ajax / Netherlands / Barcelona', 'total-football', 'same', NULL, NULL),
  ('cruyff', 'Positional play', 'Barcelona Dream Team', 'positional-play', 'same', NULL, NULL),
  ('knvb', 'Totaalvoetbal', 'the Dutch school', 'total-football', 'same', NULL, NULL),
  ('klopp', 'Gegenpressing', 'Dortmund / Liverpool', 'gegenpressing', 'same', NULL, NULL),
  ('rangnick', 'Gegenpressing', 'Red Bull school', 'gegenpressing', 'same', NULL, NULL),
  ('sacchi', 'Zonal pressing', 'Milan', 'zonal-pressing', 'same', NULL, NULL),
  ('catenaccio', 'Catenaccio', 'Inter / Milan 1960s', 'catenaccio', 'same', NULL, NULL),
  ('reep', 'Direct play (route one)', 'Wolves / England', 'route-one', 'same', NULL, NULL),
  ('bielsa', 'Man-oriented pressing', 'Chile / Bilbao / Leeds', 'man-oriented', 'same', NULL, NULL),
  ('gasperini', 'Man-to-man all over the pitch', 'Atalanta', 'man-oriented', 'same', NULL, NULL),
  ('simeone', 'Compact mid block and counter', 'Atlético Madrid', 'counter-attacking', 'same', NULL, NULL),
  ('figc-relazionale', 'Calcio relazionale', 'FIGC paper', 'relationism', 'same', NULL, NULL),
  ('book-terzis-mourinho-real-madrid-defending', 'Compact defending and fast counter-attacks', 'Mourinho''s Real Madrid 2011-12', 'counter-attacking', 'same', NULL, NULL),
  -- the encyclopaedia list of named styles
  ('wikipedia-tactics', 'Total Football', 'named style', 'total-football', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Tiki-taka', 'named style', 'tiki-taka', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Gegenpressing', 'named style', 'gegenpressing', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Catenaccio', 'named style', 'catenaccio', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Long ball', 'named style', 'route-one', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Counter-attack', 'named style', 'counter-attacking', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Parking the bus', 'named style', 'low-block', 'same', NULL, NULL),
  ('wikipedia-tactics', 'Kick and rush', 'named style', 'kick-and-rush', 'same', NULL, NULL),
  -- the research's styles are the axes
  ('fernandez-navarro-2016', 'Direct vs possession', 'factor 1', NULL, NULL, 'possession', 0),
  ('fernandez-navarro-2016', 'Wide vs narrow possession', 'factor', NULL, NULL, 'width', 0),
  ('fernandez-navarro-2016', 'Crossing vs no crossing', 'factor', NULL, NULL, 'crossing', 0),
  ('fernandez-navarro-2016', 'Fast vs slow progression', 'factor', NULL, NULL, 'tempo', 0),
  ('fernandez-navarro-2016', 'High vs low pressure', 'factor', NULL, NULL, 'pressing', 0),
  -- federations' national styles, said as ends of axes
  ('fa-england', 'Intelligently dominate possession', 'England DNA', NULL, NULL, 'possession', 2),
  ('fa-england', 'Win the ball back as early as possible', 'England DNA', NULL, NULL, 'after-loss', 2),
  ('fed-thailand-style', 'Associative play', 'Thai style of play', NULL, NULL, 'possession', 1),
  ('fed-thailand-style', 'High pressing', 'Thai style of play', NULL, NULL, 'pressing', 2),
  ('fed-thailand-style', 'Zonal defending', 'Thai style of play', NULL, NULL, 'orientation', -2),
  ('canada-soccer-style', 'Fast', 'national style', NULL, NULL, 'tempo', 2),
  ('canada-soccer-style', 'Aggressive', 'national style', NULL, NULL, 'pressing', 2),
  ('kfa-style', '빠르고 (fast)', '2024 philosophy', NULL, NULL, 'tempo', 2),
  ('kfa-style', '주도하는 (proactive, take the initiative)', '2024 philosophy', NULL, NULL, 'possession', 1);

INSERT INTO game_source_styles (source_id, name, context, locator, verified)
SELECT DISTINCT s.id, t.name, t.ctx, coalesce(s.url, ''), t.src = 'book-terzis-mourinho-real-madrid-defending'
  FROM t_s t JOIN game_sources s ON s.code = t.src
ON CONFLICT (source_id, name, context) DO NOTHING;

INSERT INTO game_style_links (entry_id, style_id, relation)
SELECT e.id, g.id, t.rel
  FROM t_s t JOIN game_sources s ON s.code = t.src
  JOIN game_source_styles e ON e.source_id = s.id AND e.name = t.name AND e.context = t.ctx
  JOIN game_styles g ON g.code = t.style
 WHERE t.style IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO game_style_dimension_links (entry_id, dimension_id, value)
SELECT e.id, d.id, t.val
  FROM t_s t JOIN game_sources s ON s.code = t.src
  JOIN game_source_styles e ON e.source_id = s.id AND e.name = t.name AND e.context = t.ctx
  JOIN game_style_dimensions d ON d.code = t.dim
 WHERE t.dim IS NOT NULL
ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW game_style_popularity AS
SELECT g.id, g.code, g.title, g.era, par.code AS parent,
       count(DISTINCT e.source_id) FILTER (WHERE l.relation IN ('same', 'part_of')) AS sources,
       count(DISTINCT e.source_id) FILTER (WHERE l.relation = 'overlaps') AS overlap_sources,
       (SELECT string_agg(d.title || ' ' || CASE WHEN p.value > 0 THEN d.high_label ELSE d.low_label END, ' · ' ORDER BY d.sort_order)
          FROM game_style_profiles p JOIN game_style_dimensions d ON d.id = p.dimension_id WHERE p.style_id = g.id AND p.value <> 0) AS profile,
       g.owner_verdict,
       CASE WHEN g.owner_verdict IS NOT NULL THEN g.owner_verdict || ' (owner)' ELSE 'popularity' END AS decided_by
  FROM game_styles g
  LEFT JOIN game_styles par ON par.id = g.parent_id
  LEFT JOIN game_style_links l ON l.style_id = g.id
  LEFT JOIN game_source_styles e ON e.id = l.entry_id
 GROUP BY g.id, par.code;

CREATE OR REPLACE VIEW game_style_dimension_popularity AS
SELECT d.id, d.code, d.title, d.moment, d.low_label, d.high_label,
       count(DISTINCT e.source_id) AS sources,
       count(DISTINCT e.source_id) FILTER (WHERE dl.value > 0) AS toward_high,
       count(DISTINCT e.source_id) FILTER (WHERE dl.value < 0) AS toward_low,
       (SELECT count(*) FROM game_style_profiles p WHERE p.dimension_id = d.id) AS in_named_styles
  FROM game_style_dimensions d
  LEFT JOIN game_style_dimension_links dl ON dl.dimension_id = d.id
  LEFT JOIN game_source_styles e ON e.id = dl.entry_id
 GROUP BY d.id;
