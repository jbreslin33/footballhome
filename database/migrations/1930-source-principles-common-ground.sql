-- 1930 (2026-11-26): principles of play as a TAXONOMY — every source's own term, linked to one canonical principle.
-- Owner 11/26: "this is a taxonomy right? we need them all right? we need to find the ones that are same and put them
-- linked in db. the ones that are one offs we can have them but they are one offs and the ones with few sources we
-- still have" · "then we can say list the most popular principles sorted by pop".
--
--   game_sources               one source (federation, book, paper, club)
--   game_source_principles       a principle AS THAT SOURCE NAMES IT: its word, language, level, side, where
--   game_common_principle_links  which canonical principle the term is, and how closely: same | part_of | overlaps
--   game_play_principles       the canonical ideas (mig 1929), widened: level, side 'both', parent (sub-kinds)
--   game_principle_popularity  the view: sources per canonical principle, most first
--
-- Levels (Bayer's three, as Spain/Portugal teach them, + narrower ones sources call principles):
--   general (superiority) · operational (team aims) · fundamental (the ten +) · sub (narrower: overlaps, permuta …)
-- One organisation = one source (county FAs, write-ups of Wade not counted again). Everything from the 11/26 web
-- search is verified = false (secondary sources) until the research session checks the text.
-- Renames from the common usage: Pressure → Delay, Cover → Depth, Compactness → Concentration (old name kept in aka).

ALTER TABLE game_play_principles ADD COLUMN IF NOT EXISTS level text NOT NULL DEFAULT 'fundamental';
ALTER TABLE game_play_principles ADD COLUMN IF NOT EXISTS parent_id integer REFERENCES game_play_principles(id);
ALTER TABLE game_play_principles DROP CONSTRAINT IF EXISTS game_play_principles_side_check;
ALTER TABLE game_play_principles ADD CONSTRAINT game_play_principles_side_check CHECK (side IN ('attack', 'defend', 'both'));
ALTER TABLE game_play_principles DROP CONSTRAINT IF EXISTS game_play_principles_level_check;
ALTER TABLE game_play_principles ADD CONSTRAINT game_play_principles_level_check
    CHECK (level IN ('general', 'operational', 'fundamental', 'sub'));

UPDATE game_play_principles SET title = 'Delay', aka = 'pressure; the first defender; contención' WHERE code = 'pressure';
UPDATE game_play_principles SET title = 'Depth', aka = 'cover; the second defender; cobertura' WHERE code = 'cover';
UPDATE game_play_principles SET title = 'Concentration', aka = 'compactness' WHERE code = 'compactness';

INSERT INTO game_play_principles (code, side, level, title, aka, definition, is_not, sort_order) VALUES
  ('superiority', 'both', 'general', 'Superiority', 'create superiority, avoid equality, never accept inferiority',
   'Where the ball is, have the advantage: with the ball create it, without the ball never accept being outnumbered — delay and recover until the numbers are level.',
   'Not just more men on the pitch: superiority is local, in the space round the ball.', 0),
  ('keep-ball', 'attack', 'operational', 'Keep the ball', 'conservar; possession', 'The team''s first aim with the ball: do not lose it.', '', 11),
  ('progress', 'attack', 'operational', 'Progress', 'progresar; build up', 'Move the ball and the team toward their goal.', '', 12),
  ('finish', 'attack', 'operational', 'Finish', 'finalizar; score', 'Turn the attack into a shot and a goal.', '', 13),
  ('win-back', 'defend', 'operational', 'Win the ball back', 'recuperar; regain', 'The team''s first aim without the ball: get it back.', '', 14),
  ('stop-progress', 'defend', 'operational', 'Stop their progress', 'impedir la progresión; disrupt their build-up',
   'Keep the ball and their team from moving toward our goal.', '', 15),
  ('protect-goal', 'defend', 'operational', 'Protect our goal', 'proteger la portería; prevent goals', 'Stop the shot and the goal.', '', 16),
  ('immediate-regain', 'defend', 'fundamental', 'Immediate regain', 'immediate chase; win it straight back',
   'The moment we lose it, the men nearest go at once to win it back before they can organise.',
   'Not the whole team chasing: the nearest men press, the rest secure.', 17),
  ('offensive-unity', 'attack', 'fundamental', 'Offensive unity', 'unidad ofensiva', 'The team attacks as one block: the back line moves up behind the ball, distances kept.', '', 18),
  ('defensive-unity', 'defend', 'fundamental', 'Defensive unity', 'unidad defensiva', 'The team defends as one block: lines move together, distances kept, nobody left behind or ahead.', '', 19),
  ('mark', 'defend', 'sub', 'Mark', 'marking', 'Take a man and stay close enough to stop him receiving or turning.', '', 30),
  ('speed-of-play', 'attack', 'sub', 'Speed of play', '', 'Move the ball quickly enough that their defence cannot shift in time.', '', 31),
  ('overlap', 'attack', 'sub', 'Overlap', '', 'A team-mate runs round the outside of the man on the ball to give him a pass or pull a defender.', '', 32),
  ('diagonal-run', 'attack', 'sub', 'Diagonal run', '', 'A run across and forward, hard for a back line to pass on.', '', 33),
  ('permuta', 'defend', 'sub', 'Permuta (the swap)', 'rotation', 'When the cover man steps out to the ball, a team-mate fills the place he left.', '', 34),
  ('shift', 'defend', 'sub', 'Shift', 'basculación; sliding', 'The whole block slides across with the ball.', '', 35),
  ('help', 'defend', 'sub', 'Help', 'ayudas', 'A team-mate comes in to double on the ball when the first defender needs it.', '', 36)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_play_principles (code, side, level, title, aka, definition, is_not, sort_order, parent_id)
SELECT v.code, 'both', 'general', v.title, '', v.def, '', v.o, p.id
  FROM (VALUES
    ('numerical-superiority', 'Numerical superiority', 'More of us than them in the space round the ball.', 1),
    ('positional-superiority', 'Positional superiority', 'We stand in better places for getting to their goal than they do for stopping us.', 2),
    ('qualitative-superiority', 'Qualitative superiority', 'One of ours beats his man: a better player in that duel.', 3),
    ('socio-affective-superiority', 'Socio-affective superiority', 'Our men in that space understand each other better than theirs do.', 4)
  ) AS v(code, title, def, o), game_play_principles p
 WHERE p.code = 'superiority'
ON CONFLICT (code) DO NOTHING;

-- Sources not yet in game_sources.
INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('ussf-d-licence', 'federation', 'US Soccer "D" licence manual — principles of attack and defense', 'https://soccerxpert.com/docs/us-soccer-d-license.pdf', false),
  ('ussf-curriculum', 'federation', 'US Soccer curriculum (8U–18U) — attacking and defending principles', 'https://tshq.bluesombrero.com/portals/26410/docs/training/u.s.%20soccer%20curriculum.pdf', false),
  ('united-soccer-coaches', 'federation', 'United Soccer Coaches (Ian Barker) — five attacking concepts', 'https://us.humankinetics.com/blogs/excerpt/principles-of-attack', false),
  ('costa-2009', 'analysis', 'Costa, Garganta, Greco & Mesquita (2009), Tactical principles of soccer, Motriz 15(3) 657–668', 'https://www.periodicos.rc.biblioteca.unesp.br/index.php/motriz/article/download/2488/2534', false),
  ('bayer', 'book', 'Claude Bayer, La enseñanza de los juegos deportivos colectivos — general and operational principles', NULL, false),
  ('es-fundamental', 'analysis', 'Spanish school fundamental principles (Universidad de Antioquia, ¿Cómo evaluar la táctica en fútbol?)', 'https://revistas.udea.edu.co/index.php/educacionfisicaydeporte/article/download/21945/20782967?inline=1', false),
  ('es-zonal-course', 'coach', 'Spanish coaches'' course — zonal defending concepts (BCN Win Method)', 'https://bcnwinmethod.com/wp-content/uploads/2021/03/DOCUMENTO-CURSO-copia.pdf', false),
  ('rfef', 'federation', 'RFEF (Spain) — youth national teams'' model: positional play (via FIFA Training Centre, David Gordo)', 'https://www.fifatrainingcentre.com/en/environment/interviews/coaching-perspectives/david-gordo-on-spains-playing-style.php', false),
  ('barca-seirulo', 'club', 'FC Barcelona — Paco Seirul·lo''s four superiorities (Barça Innovation Hub)', 'https://elearning.barcainnovationhub.com/how-to-design-tasks-to-improve-collective-game-in-team-sports/', false),
  ('barca-masia', 'club', 'FC Barcelona La Masia — possession, position, pressing (Sergio Vallecillo)', 'https://www.barcafutbol.com/la-masia-the-idea-that-became-an-identity/', false),
  ('fff', 'federation', 'FFF (France) — league / district projet de jeu documents', 'https://liguefoot-reunion.fff.fr/wp-content/uploads/sites/116/2020/04/Projet-de-Jeu-Foot-A-8.pdf', false)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS game_source_principles (
    id         serial PRIMARY KEY,
    source_id  integer NOT NULL REFERENCES game_sources(id),
    term       text NOT NULL,
    lang       text NOT NULL DEFAULT 'en',
    level      text NOT NULL CHECK (level IN ('general', 'operational', 'fundamental', 'sub')),
    side       text NOT NULL CHECK (side IN ('attack', 'defend', 'both')),
    locator    text NOT NULL DEFAULT '',      -- page, section or URL
    verified   boolean NOT NULL DEFAULT false,
    UNIQUE (source_id, term)
);

CREATE TABLE IF NOT EXISTS game_common_principle_links (
    term_id      integer NOT NULL REFERENCES game_source_principles(id) ON DELETE CASCADE,
    principle_id integer NOT NULL REFERENCES game_play_principles(id),
    relation     text NOT NULL CHECK (relation IN ('same', 'part_of', 'overlaps')),
    PRIMARY KEY (term_id, principle_id)
);

CREATE TEMP TABLE t_terms (src text, term text, lang text, lvl text, side text, canon text, rel text) ON COMMIT DROP;
INSERT INTO t_terms VALUES
  -- Wade, FA 1967
  ('wade-fa-guide-1967', 'Penetration', 'en', 'fundamental', 'attack', 'penetration', 'same'),
  ('wade-fa-guide-1967', 'Support', 'en', 'fundamental', 'attack', 'support', 'same'),
  ('wade-fa-guide-1967', 'Width', 'en', 'fundamental', 'attack', 'width', 'same'),
  ('wade-fa-guide-1967', 'Mobility', 'en', 'fundamental', 'attack', 'mobility', 'same'),
  ('wade-fa-guide-1967', 'Improvisation', 'en', 'fundamental', 'attack', 'improvisation', 'same'),
  ('wade-fa-guide-1967', 'Delay', 'en', 'fundamental', 'defend', 'pressure', 'same'),
  ('wade-fa-guide-1967', 'Depth', 'en', 'fundamental', 'defend', 'cover', 'same'),
  ('wade-fa-guide-1967', 'Balance', 'en', 'fundamental', 'defend', 'balance', 'same'),
  ('wade-fa-guide-1967', 'Concentration', 'en', 'fundamental', 'defend', 'compactness', 'same'),
  ('wade-fa-guide-1967', 'Control and restraint', 'en', 'fundamental', 'defend', 'control-restraint', 'same'),
  -- US Soccer D licence
  ('ussf-d-licence', 'Penetration', 'en', 'fundamental', 'attack', 'penetration', 'same'),
  ('ussf-d-licence', 'Depth (attack)', 'en', 'fundamental', 'attack', 'support', 'same'),
  ('ussf-d-licence', 'Mobility', 'en', 'fundamental', 'attack', 'mobility', 'same'),
  ('ussf-d-licence', 'Width', 'en', 'fundamental', 'attack', 'width', 'same'),
  ('ussf-d-licence', 'Improvisation', 'en', 'fundamental', 'attack', 'improvisation', 'same'),
  ('ussf-d-licence', 'Immediate chase', 'en', 'fundamental', 'defend', 'immediate-regain', 'same'),
  ('ussf-d-licence', 'Delay', 'en', 'fundamental', 'defend', 'pressure', 'same'),
  ('ussf-d-licence', 'Depth (defense)', 'en', 'fundamental', 'defend', 'cover', 'same'),
  ('ussf-d-licence', 'Balance', 'en', 'fundamental', 'defend', 'balance', 'same'),
  ('ussf-d-licence', 'Concentration', 'en', 'fundamental', 'defend', 'compactness', 'same'),
  ('ussf-d-licence', 'Control and restraint', 'en', 'fundamental', 'defend', 'control-restraint', 'same'),
  -- US Soccer curriculum
  ('ussf-curriculum', 'Creating space', 'en', 'fundamental', 'attack', 'mobility', 'overlaps'),
  ('ussf-curriculum', 'Support', 'en', 'fundamental', 'attack', 'support', 'same'),
  ('ussf-curriculum', 'Width', 'en', 'fundamental', 'attack', 'width', 'same'),
  ('ussf-curriculum', 'Depth', 'en', 'fundamental', 'attack', 'support', 'same'),
  ('ussf-curriculum', 'Overlaps', 'en', 'sub', 'attack', 'overlap', 'same'),
  ('ussf-curriculum', 'Diagonal runs', 'en', 'sub', 'attack', 'diagonal-run', 'same'),
  ('ussf-curriculum', 'Forward play', 'en', 'fundamental', 'attack', 'penetration', 'same'),
  ('ussf-curriculum', 'Speed of play', 'en', 'sub', 'attack', 'speed-of-play', 'same'),
  ('ussf-curriculum', 'Switching positions', 'en', 'fundamental', 'attack', 'mobility', 'part_of'),
  ('ussf-curriculum', 'Mark', 'en', 'sub', 'defend', 'mark', 'same'),
  ('ussf-curriculum', 'Press', 'en', 'fundamental', 'defend', 'pressure', 'same'),
  ('ussf-curriculum', 'Cover', 'en', 'fundamental', 'defend', 'cover', 'same'),
  ('ussf-curriculum', 'Balance', 'en', 'fundamental', 'defend', 'balance', 'same'),
  ('ussf-curriculum', 'Compactness', 'en', 'fundamental', 'defend', 'compactness', 'same'),
  -- United Soccer Coaches
  ('united-soccer-coaches', 'Penetration', 'en', 'fundamental', 'attack', 'penetration', 'same'),
  ('united-soccer-coaches', 'Support', 'en', 'fundamental', 'attack', 'support', 'same'),
  ('united-soccer-coaches', 'Mobility', 'en', 'fundamental', 'attack', 'mobility', 'same'),
  ('united-soccer-coaches', 'Width', 'en', 'fundamental', 'attack', 'width', 'same'),
  ('united-soccer-coaches', 'Improvisation, creativity and surprise', 'en', 'fundamental', 'attack', 'improvisation', 'same'),
  -- Costa et al. 2009
  ('costa-2009', 'Penetration', 'pt', 'fundamental', 'attack', 'penetration', 'same'),
  ('costa-2009', 'Offensive coverage', 'pt', 'fundamental', 'attack', 'support', 'same'),
  ('costa-2009', 'Depth mobility', 'pt', 'fundamental', 'attack', 'mobility', 'same'),
  ('costa-2009', 'Width and length', 'pt', 'fundamental', 'attack', 'width', 'part_of'),
  ('costa-2009', 'Offensive unity', 'pt', 'fundamental', 'attack', 'offensive-unity', 'same'),
  ('costa-2009', 'Delay', 'pt', 'fundamental', 'defend', 'pressure', 'same'),
  ('costa-2009', 'Defensive coverage', 'pt', 'fundamental', 'defend', 'cover', 'same'),
  ('costa-2009', 'Balance', 'pt', 'fundamental', 'defend', 'balance', 'same'),
  ('costa-2009', 'Concentration', 'pt', 'fundamental', 'defend', 'compactness', 'same'),
  ('costa-2009', 'Defensive unity', 'pt', 'fundamental', 'defend', 'defensive-unity', 'same'),
  -- Bayer (general + operational)
  ('bayer', 'Crear superioridad numérica; evitar la igualdad; no permitir la inferioridad', 'es', 'general', 'both', 'superiority', 'same'),
  ('bayer', 'Conservar el balón', 'es', 'operational', 'attack', 'keep-ball', 'same'),
  ('bayer', 'Progresar hacia la meta adversaria', 'es', 'operational', 'attack', 'progress', 'same'),
  ('bayer', 'Finalizar', 'es', 'operational', 'attack', 'finish', 'same'),
  ('bayer', 'Recuperar el balón', 'es', 'operational', 'defend', 'win-back', 'same'),
  ('bayer', 'Impedir la progresión', 'es', 'operational', 'defend', 'stop-progress', 'same'),
  ('bayer', 'Proteger la portería', 'es', 'operational', 'defend', 'protect-goal', 'same'),
  -- Spanish school fundamental
  ('es-fundamental', 'Penetración', 'es', 'fundamental', 'attack', 'penetration', 'same'),
  ('es-fundamental', 'Cobertura ofensiva', 'es', 'fundamental', 'attack', 'support', 'same'),
  ('es-fundamental', 'Movilidad (desmarque)', 'es', 'fundamental', 'attack', 'mobility', 'same'),
  ('es-fundamental', 'Espacio', 'es', 'fundamental', 'attack', 'width', 'overlaps'),
  ('es-fundamental', 'Unidad ofensiva', 'es', 'fundamental', 'attack', 'offensive-unity', 'same'),
  ('es-fundamental', 'Contención', 'es', 'fundamental', 'defend', 'pressure', 'same'),
  ('es-fundamental', 'Cobertura', 'es', 'fundamental', 'defend', 'cover', 'same'),
  ('es-fundamental', 'Equilibrio', 'es', 'fundamental', 'defend', 'balance', 'same'),
  ('es-fundamental', 'Concentración', 'es', 'fundamental', 'defend', 'compactness', 'same'),
  ('es-fundamental', 'Unidad defensiva', 'es', 'fundamental', 'defend', 'defensive-unity', 'same'),
  -- Spanish zonal course
  ('es-zonal-course', 'Cobertura', 'es', 'fundamental', 'defend', 'cover', 'same'),
  ('es-zonal-course', 'Permuta', 'es', 'sub', 'defend', 'permuta', 'same'),
  ('es-zonal-course', 'Ayudas defensivas', 'es', 'sub', 'defend', 'help', 'same'),
  ('es-zonal-course', 'Basculaciones defensivas', 'es', 'sub', 'defend', 'shift', 'same'),
  ('es-zonal-course', 'Distancias entre jugadores y líneas', 'es', 'fundamental', 'defend', 'compactness', 'part_of'),
  -- RFEF
  ('rfef', 'Juego de posición: la posesión para generar superioridades', 'es', 'general', 'attack', 'superiority', 'same'),
  ('rfef', 'Posesión', 'es', 'operational', 'attack', 'keep-ball', 'same'),
  ('rfef', 'Recuperación rápida tras pérdida', 'es', 'fundamental', 'defend', 'immediate-regain', 'same'),
  -- Barça
  ('barca-seirulo', 'Superioridad numérica', 'es', 'general', 'both', 'numerical-superiority', 'same'),
  ('barca-seirulo', 'Superioridad posicional', 'es', 'general', 'both', 'positional-superiority', 'same'),
  ('barca-seirulo', 'Superioridad cualitativa', 'es', 'general', 'both', 'qualitative-superiority', 'same'),
  ('barca-seirulo', 'Superioridad socio-afectiva', 'es', 'general', 'both', 'socio-affective-superiority', 'same'),
  ('barca-masia', 'Possession', 'en', 'operational', 'attack', 'keep-ball', 'same'),
  ('barca-masia', 'Position', 'en', 'general', 'attack', 'positional-superiority', 'overlaps'),
  ('barca-masia', 'Pressing: recover it as soon as possible', 'en', 'fundamental', 'defend', 'immediate-regain', 'same'),
  -- England DNA
  ('fa-england', 'Progress the play and penetrate', 'en', 'fundamental', 'attack', 'penetration', 'same'),
  ('fa-england', 'Intelligently dominate possession', 'en', 'operational', 'attack', 'keep-ball', 'same'),
  ('fa-england', 'Regain possession early', 'en', 'fundamental', 'defend', 'immediate-regain', 'same'),
  ('fa-england', 'Pressing: Delay', 'en', 'fundamental', 'defend', 'pressure', 'same'),
  -- KNVB team tasks
  ('knvb', 'Building up', 'nl', 'operational', 'attack', 'progress', 'same'),
  ('knvb', 'Scoring', 'nl', 'operational', 'attack', 'finish', 'same'),
  ('knvb', 'Disrupting their build-up', 'nl', 'operational', 'defend', 'stop-progress', 'same'),
  ('knvb', 'Preventing goals', 'nl', 'operational', 'defend', 'protect-goal', 'same'),
  -- FFF
  ('fff', 'Conserver', 'fr', 'operational', 'attack', 'keep-ball', 'same'),
  ('fff', 'Progresser', 'fr', 'operational', 'attack', 'progress', 'same'),
  ('fff', 'Déséquilibrer', 'fr', 'fundamental', 'attack', 'penetration', 'overlaps'),
  ('fff', 'Finir', 'fr', 'operational', 'attack', 'finish', 'same'),
  ('fff', 'Récupérer le ballon', 'fr', 'operational', 'defend', 'win-back', 'same'),
  ('fff', 'Réduire les espaces entre les lignes', 'fr', 'fundamental', 'defend', 'compactness', 'same'),
  ('fff', 'Reformer le bloc équipe', 'fr', 'fundamental', 'defend', 'defensive-unity', 'overlaps'),
  ('fff', 'Récupérer en moins de 6 secondes', 'fr', 'fundamental', 'defend', 'immediate-regain', 'same');

INSERT INTO game_source_principles (source_id, term, lang, level, side, locator, verified)
SELECT s.id, t.term, t.lang, t.lvl, t.side, coalesce(s.url, ''), false
  FROM t_terms t JOIN game_sources s ON s.code = t.src
ON CONFLICT (source_id, term) DO NOTHING;

INSERT INTO game_common_principle_links (term_id, principle_id, relation)
SELECT pt.id, p.id, t.rel
  FROM t_terms t
  JOIN game_sources s ON s.code = t.src
  JOIN game_source_principles pt ON pt.source_id = s.id AND pt.term = t.term
  JOIN game_play_principles p ON p.code = t.canon
ON CONFLICT DO NOTHING;

-- Popularity: how many sources name it (same or part of), how many only overlap it. A sub-kind counts toward its parent too.
DROP VIEW IF EXISTS game_principle_popularity;
CREATE VIEW game_principle_popularity AS
WITH hits AS (
    SELECT l.principle_id, t.source_id, l.relation FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
    UNION ALL
    SELECT p.parent_id, t.source_id, l.relation
      FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
      JOIN game_play_principles p ON p.id = l.principle_id WHERE p.parent_id IS NOT NULL
)
SELECT p.id, p.code, p.title, p.level, p.side,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation IN ('same', 'part_of')) AS sources,
       count(DISTINCT h.source_id) FILTER (WHERE h.relation = 'overlaps') AS overlap_sources,
       string_agg(DISTINCT s.code, ', ') AS source_codes
  FROM game_play_principles p
  LEFT JOIN hits h ON h.principle_id = p.id
  LEFT JOIN game_sources s ON s.id = h.source_id
 GROUP BY p.id;
