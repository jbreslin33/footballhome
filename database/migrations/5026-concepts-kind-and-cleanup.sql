-- 5026 (2026-11-27): concepts revisit, step 1 — what KIND of thing each concept is, three homeless
-- concepts given a principle, five missing refinement links. No ids change (wired ids are wire format).
--   skill  a piece of understanding a player has or lacks (rated per player, drilled, pointed at in replay)
--   style  a dial a game model / style sets for the team (man vs zonal, verticality, block height ...)
--   call   a spoken instruction one player gives another
-- Book patterns and exercises get tagged against this list next (pilot first).
BEGIN;

ALTER TABLE game_concepts ADD COLUMN kind text NOT NULL DEFAULT 'skill'
  CHECK (kind IN ('skill', 'style', 'call'));

UPDATE game_concepts SET kind = 'style' WHERE name IN (
  'man-mark', 'zonal-marking',        -- the marking dial's two ends
  'verticality', 'pass-ladder',       -- how forward we look first
  'short-simple', 'direct-ball',      -- the passing dial's two ends
  'counter-attack', 'libero', 'block-height');

UPDATE game_concepts SET kind = 'call' WHERE name IN (
  'call-man-on', 'call-time', 'call-turn', 'call-squeeze', 'call-line', 'call-adjust-shadow');

UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-mark')
 WHERE name IN ('hold-between', 'straddle');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-press-team')
 WHERE name = 'deter';

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, 'refines' FROM (VALUES
  ('side-on-jockey',     'jockey-angle'),
  ('line-step',          'push-up'),
  ('beat-the-high-line', 'over-top'),
  ('pack-the-middle',    'close-the-centre'),
  ('engage-line',        'block-height')) v(a, b)
JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b
ON CONFLICT DO NOTHING;

COMMIT;
