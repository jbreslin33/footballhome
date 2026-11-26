-- 1938 (2026-11-26): FORMATIONS as a taxonomy — every source's name for a shape, linked to one common shape.
-- Owner 11/26: "yes start with formations but do all … normalized db. look to see where we connect things in db with fk
-- relations right?"
--
-- Two different things, two tables (they were one, which is why the catalogue could not grow):
--   game_formation_families  the named SYSTEM football talks about ("4-3-3", "3-5-2", "the diamond", "WM") — common ground
--   formations               a concrete BOARD LAYOUT the app and engine play (x/y per slot): "3-5-2 (1-2-R2)", "Wide 4-2-3-1"
--                            → each now points to its family (formations.family_id)
--   game_source_formations   a shape AS A SOURCE NAMES IT (its words, how often it used it, where)
--   game_formation_family_links  which family that is: same | part_of | overlaps
--   game_formation_popularity    view: sources per family, and how many real starts (StatsBomb counts)
--
-- FK audit (owner: "where we connect things in db with fk relations"): six tables named a formation by text with no
-- FK. Mig 1110's rename 3-3-1-3 → 3-4-3 (1-1-3) left 11 formation_slot_roles rows orphaned on the old code — fixed
-- here, and every one of those columns now REFERENCES formations(code) ON UPDATE CASCADE, so a rename carries.

-- ── 1. the orphans, then the FKs ─────────────────────────────────────────────────────────────────────────────────
UPDATE formation_slot_roles SET formation_code = '3-4-3 (1-1-3)'
 WHERE formation_code = '3-3-1-3'
   AND NOT EXISTS (SELECT 1 FROM formation_slot_roles r WHERE r.formation_code = '3-4-3 (1-1-3)');

ALTER TABLE formation_slot_roles   DROP CONSTRAINT IF EXISTS formation_slot_roles_formation_fk;
ALTER TABLE formation_slot_roles   ADD CONSTRAINT formation_slot_roles_formation_fk
    FOREIGN KEY (formation_code) REFERENCES formations(code) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE formation_slot_numbers DROP CONSTRAINT IF EXISTS formation_slot_numbers_formation_fk;
ALTER TABLE formation_slot_numbers ADD CONSTRAINT formation_slot_numbers_formation_fk
    FOREIGN KEY (formation_code) REFERENCES formations(code) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE game_models            DROP CONSTRAINT IF EXISTS game_models_formation_fk;
ALTER TABLE game_models            ADD CONSTRAINT game_models_formation_fk
    FOREIGN KEY (formation_code) REFERENCES formations(code) ON UPDATE CASCADE;
ALTER TABLE game_demo_teams        DROP CONSTRAINT IF EXISTS game_demo_teams_formation_fk;
ALTER TABLE game_demo_teams        ADD CONSTRAINT game_demo_teams_formation_fk
    FOREIGN KEY (formation_code) REFERENCES formations(code) ON UPDATE CASCADE;
ALTER TABLE game_phase_positions   DROP CONSTRAINT IF EXISTS game_phase_positions_formation_fk;
ALTER TABLE game_phase_positions   ADD CONSTRAINT game_phase_positions_formation_fk
    FOREIGN KEY (formation_code) REFERENCES formations(code) ON UPDATE CASCADE;

-- ── 2. the families (common ground) ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_formation_families (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,                 -- the lines, back to front: '4-2-3-1'
    title       text NOT NULL,
    aka         text NOT NULL DEFAULT '',
    back        smallint NOT NULL CHECK (back BETWEEN 2 AND 5),   -- men in the last line
    phase       text NOT NULL DEFAULT 'base' CHECK (phase IN ('base', 'in_possession', 'historic')),
    parent_id   integer REFERENCES game_formation_families(id),   -- a variant of a broader system
    definition  text NOT NULL DEFAULT '',
    owner_verdict text CHECK (owner_verdict IN ('adopt', 'reject')),
    owner_note  text NOT NULL DEFAULT '',
    sort_order  smallint NOT NULL DEFAULT 0,
    CHECK (parent_id IS NULL OR parent_id <> id)
);

INSERT INTO game_formation_families (code, title, aka, back, phase, definition, sort_order) VALUES
  ('4-4-2',   '4-4-2', 'flat 4-4-2', 4, 'base', 'Back four, a flat midfield four, two strikers.', 10),
  ('4-3-3',   '4-3-3', '', 4, 'base', 'Back four, a midfield three, a front three with two wide forwards.', 20),
  ('4-2-3-1', '4-2-3-1', '', 4, 'base', 'Back four, two holding midfielders, three behind a lone striker (a 10 and two wide).', 30),
  ('4-5-1',   '4-5-1', '', 4, 'base', 'Back four, a midfield five, one striker.', 40),
  ('3-5-2',   '3-5-2', '', 3, 'base', 'Three centre-backs, wing-backs and a central three, two strikers.', 50),
  ('3-4-3',   '3-4-3', '', 3, 'base', 'Three centre-backs, a midfield four with wing-backs, a front three.', 60),
  ('5-3-2',   '5-3-2', '', 5, 'base', 'A back five (wing-backs deep), a midfield three, two strikers.', 70),
  ('5-4-1',   '5-4-1', '', 5, 'base', 'A back five, a midfield four, one striker: the low block of the back-three systems.', 80),
  ('4-2-4',   '4-2-4', '', 4, 'historic', 'Back four, two in midfield, four forwards (Brazil 1958).', 200),
  ('3-2-2-3', 'WM', '3-2-2-3', 3, 'historic', 'Chapman''s WM: three backs, two halves, two inside forwards, three forwards.', 210),
  ('2-3-5',   'The Pyramid', '2-3-5', 2, 'historic', 'Two full-backs, three halves, five forwards: the 19th-century default.', 220),
  ('3-2-5',   '3-2-5 (in possession)', 'the box + five', 3, 'in_possession', 'The modern in-possession shape: three behind, two pivots, five across the front.', 300),
  ('2-3-5-ip', '2-3-5 (in possession)', '', 2, 'in_possession', 'Two centre-backs, three in the next line, five across the front.', 310)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_formation_families (code, title, aka, back, phase, parent_id, definition, sort_order)
SELECT v.code, v.title, v.aka, v.back, v.phase, p.id, v.def, v.o
  FROM (VALUES
    ('4-4-1-1', '4-4-1-1', '', 4, 'base', '4-4-2', 'A 4-4-2 with one striker dropped behind the other.', 11),
    ('4-1-2-1-2', 'The diamond', '4-1-2-1-2; 4-4-2 diamond', 4, 'base', '4-4-2', 'A 4-4-2 with the midfield as a diamond: a holder, two shuttlers, a 10.', 12),
    ('4-2-2-2', '4-2-2-2', 'the magic rectangle', 4, 'base', '4-4-2', 'Two holders, two narrow attacking midfielders, two strikers.', 13),
    ('4-3-1-2', '4-3-1-2', '', 4, 'base', '4-4-2', 'A midfield three, a 10, two strikers.', 14),
    ('4-1-4-1', '4-1-4-1', '', 4, 'base', '4-3-3', 'One holder, a midfield four, one striker — often the 4-3-3 without the ball.', 21),
    ('4-3-2-1', 'The Christmas tree', '4-3-2-1', 4, 'base', '4-3-3', 'A midfield three, two behind a lone striker.', 22),
    ('4-6-0', '4-6-0', 'false nine', 4, 'base', '4-3-3', 'No striker: a front line of midfielders.', 23),
    ('3-4-1-2', '3-4-1-2', '', 3, 'base', '3-5-2', 'A 3-5-2 with a 10 behind two strikers.', 51),
    ('3-5-1-1', '3-5-1-1', '', 3, 'base', '3-5-2', 'A 3-5-2 with one striker dropped.', 52),
    ('3-4-2-1', '3-4-2-1', '', 3, 'base', '3-4-3', 'A 3-4-3 with two 10s behind a lone striker.', 61),
    ('3-3-1-3', '3-3-1-3', 'Bielsa''s 3-3-1-3', 3, 'base', '3-4-3', 'Three backs, a midfield three, a 10, a front three — the owner files it as 3-4-3 (1-1-3) (mig 1110).', 62),
    ('2-3-2-3', '2-3-2-3 (in possession)', 'the box midfield', 2, 'in_possession', '3-2-5', 'Two centre-backs, three, a box of two, three up front: the box in possession.', 311),
    ('2-4-1-3', '2-4-1-3 (in possession)', '', 2, 'in_possession', '2-3-5-ip', 'Two centre-backs, four, one 10, three up front.', 312),
    ('3-3-4', '3-3-4 (in possession)', '', 3, 'in_possession', '3-2-5', 'Three behind, three in midfield, four across the front.', 313),
    ('2-4-4', '2-4-4 (in possession)', '', 2, 'in_possession', '2-3-5-ip', 'Two behind, four in midfield, four across the front.', 314)
  ) AS v(code, title, aka, back, phase, parent, def, o)
  JOIN game_formation_families p ON p.code = v.parent
ON CONFLICT (code) DO NOTHING;

-- ── 3. every board layout to its family ──────────────────────────────────────────────────────────────────────────
ALTER TABLE formations ADD COLUMN IF NOT EXISTS family_id integer REFERENCES game_formation_families(id);
UPDATE formations f SET family_id = g.id
  FROM game_formation_families g,
       (VALUES ('4-3-3', '4-3-3'), ('4-4-2', '4-4-2'), ('4-2-3-1', '4-2-3-1'), ('4-2-3-1 wide', '4-2-3-1'), ('4-2-3-1 narrow', '4-2-3-1'),
               ('4-1-4-1', '4-1-4-1'), ('5-3-2', '5-3-2'), ('5-4-1', '5-4-1'),
               ('3-5-2 (3-2)', '3-5-2'), ('3-5-2 (2-1-2)', '3-5-2'), ('3-5-2 (1-2-2)', '3-5-2'), ('3-5-2 (3-R2)', '3-5-2'),
               ('3-5-2 (3-L2)', '3-5-2'), ('3-5-2 (1-2-R2)', '3-5-2'), ('3-5-2 (1-2-L2)', '3-5-2'), ('3-5-2 (2-1-R2)', '3-5-2'),
               ('3-5-2 (2-1-L2)', '3-5-2'),
               ('3-4-3 (2-3)', '3-4-3'), ('3-4-3 (2-2-1)', '3-4-2-1'), ('3-4-3 (4-1)', '3-4-3'), ('3-4-3 (1-1-3)', '3-3-1-3'),
               ('2-3-2-3', '2-3-2-3'), ('2-4-1-3', '2-4-1-3'), ('3-3-4', '3-3-4'), ('2-4-4', '2-4-4')) AS m(board, fam)
 WHERE f.code = m.board AND g.code = m.fam AND f.family_id IS NULL;

-- ── 4. every source's name for a shape ───────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_source_formations (
    id         serial PRIMARY KEY,
    source_id  integer NOT NULL REFERENCES game_sources(id),
    name       text NOT NULL,                     -- as the source writes it: '4231', '1-4-3-3', 'the diamond'
    context    text NOT NULL DEFAULT '',          -- e.g. 'starting XI', 'national model', 'his Barcelona'
    uses_n     integer,                           -- how often the source used it (counts), NULL when it names it
    locator    text NOT NULL DEFAULT '',
    verified   boolean NOT NULL DEFAULT false,
    UNIQUE (source_id, name, context)
);
CREATE TABLE IF NOT EXISTS game_formation_family_links (
    entry_id   integer NOT NULL REFERENCES game_source_formations(id) ON DELETE CASCADE,
    family_id  integer NOT NULL REFERENCES game_formation_families(id),
    relation   text NOT NULL CHECK (relation IN ('same', 'part_of', 'overlaps')),
    PRIMARY KEY (entry_id, family_id)
);

-- the research session's book patterns name the formation they face: a family, enforced
ALTER TABLE coaching_book_patterns DROP CONSTRAINT IF EXISTS coaching_book_patterns_vs_formation_fk;
ALTER TABLE coaching_book_patterns ADD CONSTRAINT coaching_book_patterns_vs_formation_fk
    FOREIGN KEY (vs_formation) REFERENCES game_formation_families(code) ON UPDATE CASCADE;

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('statsbomb-pl1516', 'analysis', 'StatsBomb open data, Premier League 2015/16 — starting XI formations (380 matches, local copy)', 'https://github.com/statsbomb/open-data', true),
  ('wikipedia-formations', 'analysis', 'Wikipedia, Formation (association football) — the named systems and their history', 'https://en.wikipedia.org/wiki/Formation_(association_football)', false),
  ('pzpn', 'federation', 'PZPN (Poland) — Narodowy Model Gry, 1-3-5-2', NULL, false)
ON CONFLICT (code) DO NOTHING;

CREATE TEMP TABLE t_f (src text, name text, ctx text, n integer, fam text, rel text) ON COMMIT DROP;
INSERT INTO t_f VALUES
  -- StatsBomb PL 15/16: starting XIs (count = team-matches), read from ~/football-data/statsbomb/pl1516 11/26
  ('statsbomb-pl1516', '4231', 'starting XI', 384, '4-2-3-1', 'same'),
  ('statsbomb-pl1516', '442', 'starting XI', 120, '4-4-2', 'same'),
  ('statsbomb-pl1516', '433', 'starting XI', 65, '4-3-3', 'same'),
  ('statsbomb-pl1516', '4411', 'starting XI', 61, '4-4-1-1', 'same'),
  ('statsbomb-pl1516', '4141', 'starting XI', 60, '4-1-4-1', 'same'),
  ('statsbomb-pl1516', '41212', 'starting XI', 15, '4-1-2-1-2', 'same'),
  ('statsbomb-pl1516', '451', 'starting XI', 13, '4-5-1', 'same'),
  ('statsbomb-pl1516', '352', 'starting XI', 11, '3-5-2', 'same'),
  ('statsbomb-pl1516', '343', 'starting XI', 9, '3-4-3', 'same'),
  ('statsbomb-pl1516', '3412', 'starting XI', 8, '3-4-1-2', 'same'),
  ('statsbomb-pl1516', '4321', 'starting XI', 7, '4-3-2-1', 'same'),
  ('statsbomb-pl1516', '3421', 'starting XI', 6, '3-4-2-1', 'same'),
  ('statsbomb-pl1516', '4222', 'starting XI', 1, '4-2-2-2', 'same'),
  ('statsbomb-pl1516', '3511', 'tactical shift', 3, '3-5-1-1', 'same'),
  -- the named systems (Wikipedia list)
  ('wikipedia-formations', '2–3–5 (the Pyramid)', 'named system', NULL, '2-3-5', 'same'),
  ('wikipedia-formations', 'WM (3–2–2–3)', 'named system', NULL, '3-2-2-3', 'same'),
  ('wikipedia-formations', '4–2–4', 'named system', NULL, '4-2-4', 'same'),
  ('wikipedia-formations', '4–4–2', 'named system', NULL, '4-4-2', 'same'),
  ('wikipedia-formations', '4–4–2 diamond (4–1–2–1–2)', 'named system', NULL, '4-1-2-1-2', 'same'),
  ('wikipedia-formations', '4–4–1–1', 'named system', NULL, '4-4-1-1', 'same'),
  ('wikipedia-formations', '4–3–3', 'named system', NULL, '4-3-3', 'same'),
  ('wikipedia-formations', '4–3–2–1 (Christmas tree)', 'named system', NULL, '4-3-2-1', 'same'),
  ('wikipedia-formations', '4–2–3–1', 'named system', NULL, '4-2-3-1', 'same'),
  ('wikipedia-formations', '4–1–4–1', 'named system', NULL, '4-1-4-1', 'same'),
  ('wikipedia-formations', '4–5–1', 'named system', NULL, '4-5-1', 'same'),
  ('wikipedia-formations', '4–2–2–2 (magic rectangle)', 'named system', NULL, '4-2-2-2', 'same'),
  ('wikipedia-formations', '4–6–0', 'named system', NULL, '4-6-0', 'same'),
  ('wikipedia-formations', '3–5–2', 'named system', NULL, '3-5-2', 'same'),
  ('wikipedia-formations', '3–4–3', 'named system', NULL, '3-4-3', 'same'),
  ('wikipedia-formations', '3–4–1–2', 'named system', NULL, '3-4-1-2', 'same'),
  ('wikipedia-formations', '3–3–1–3', 'named system', NULL, '3-3-1-3', 'same'),
  ('wikipedia-formations', '5–3–2', 'named system', NULL, '5-3-2', 'same'),
  ('wikipedia-formations', '5–4–1', 'named system', NULL, '5-4-1', 'same'),
  -- federations' national models (federation sweep 11/26)
  ('football-australia', '1-4-3-3', 'national curriculum formation', NULL, '4-3-3', 'same'),
  ('knvb', '1-4-3-3', 'Dutch school base system', NULL, '4-3-3', 'same'),
  ('rfef', '4-3-3', 'youth national teams'' customary shape', NULL, '4-3-3', 'same'),
  ('pzpn', '1-3-5-2', 'Narodowy Model Gry', NULL, '3-5-2', 'same'),
  -- coaches (game_sources rows already there); their signature systems
  ('guardiola', '4-3-3', 'Barcelona / Manchester City', NULL, '4-3-3', 'same'),
  ('guardiola', '3-2-5', 'in possession', NULL, '3-2-5', 'same'),
  ('cruyff', '3-4-3 (diamond)', 'Barcelona Dream Team', NULL, '3-4-3', 'part_of'),
  ('sacchi', '4-4-2', 'Milan', NULL, '4-4-2', 'same'),
  ('bielsa', '3-3-1-3', 'Chile / Bilbao / Leeds', NULL, '3-3-1-3', 'same'),
  ('bielsa', '4-1-4-1', 'Leeds', NULL, '4-1-4-1', 'same'),
  ('klopp', '4-2-3-1', 'Dortmund', NULL, '4-2-3-1', 'same'),
  ('klopp', '4-3-3', 'Liverpool', NULL, '4-3-3', 'same'),
  ('simeone', '4-4-2', 'Atlético Madrid', NULL, '4-4-2', 'same'),
  ('gasperini', '3-4-1-2', 'Atalanta', NULL, '3-4-1-2', 'same'),
  ('gasperini', '3-4-2-1', 'Atalanta', NULL, '3-4-2-1', 'same'),
  ('zeman', '4-3-3', 'Foggia / Pescara', NULL, '4-3-3', 'same'),
  ('rangnick', '4-2-2-2', 'Leipzig / Hoffenheim', NULL, '4-2-2-2', 'same'),
  ('hasenhuttl', '4-2-2-2', 'Leipzig / Southampton', NULL, '4-2-2-2', 'same'),
  ('pochettino', '4-2-3-1', 'Tottenham', NULL, '4-2-3-1', 'same'),
  ('de-zerbi', '4-2-3-1', 'Brighton (3-2-5 / 2-3-5 in possession)', NULL, '4-2-3-1', 'same'),
  -- the research session's first book
  ('book-terzis-mourinho-real-madrid-defending', '4-2-3-1', 'Mourinho''s Real Madrid 2011-12, defending', NULL, '4-2-3-1', 'same');

INSERT INTO game_source_formations (source_id, name, context, uses_n, locator, verified)
SELECT s.id, t.name, t.ctx, t.n, coalesce(s.url, ''), t.src IN ('statsbomb-pl1516', 'book-terzis-mourinho-real-madrid-defending')
  FROM t_f t JOIN game_sources s ON s.code = t.src
ON CONFLICT (source_id, name, context) DO NOTHING;

INSERT INTO game_formation_family_links (entry_id, family_id, relation)
SELECT e.id, g.id, t.rel
  FROM t_f t JOIN game_sources s ON s.code = t.src
  JOIN game_source_formations e ON e.source_id = s.id AND e.name = t.name AND e.context = t.ctx
  JOIN game_formation_families g ON g.code = t.fam
ON CONFLICT DO NOTHING;

-- ── 5. popularity: sources that name it, real starts (counts), boards we can play it on ─────────────────────────
CREATE OR REPLACE VIEW game_formation_popularity AS
SELECT g.id, g.code, g.title, g.phase, g.back, par.code AS parent,
       count(DISTINCT e.source_id) FILTER (WHERE l.relation IN ('same', 'part_of')) AS sources,
       coalesce(sum(e.uses_n) FILTER (WHERE l.relation = 'same'), 0) AS uses,
       (SELECT count(*) FROM formations f WHERE f.family_id = g.id) AS boards,
       (SELECT count(*) FROM game_demo_teams t JOIN formations f ON f.code = t.formation_code WHERE f.family_id = g.id) AS sim_teams,
       g.owner_verdict,
       CASE WHEN g.owner_verdict IS NOT NULL THEN g.owner_verdict || ' (owner)' ELSE 'popularity' END AS decided_by
  FROM game_formation_families g
  LEFT JOIN game_formation_families par ON par.id = g.parent_id
  LEFT JOIN game_formation_family_links l ON l.family_id = g.id
  LEFT JOIN game_source_formations e ON e.id = l.entry_id
 GROUP BY g.id, par.code;
