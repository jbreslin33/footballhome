-- 1932 (2026-11-26): one chain from the principles of play to the engine — research, taxonomy and game are ONE system.
-- Owner 11/26: "for the football research task this is all connected in db not separate and not separate from game".
-- The links already exist; this view walks them for every common-ground principle:
--   sources that name it (game_source_principles via game_common_principle_links, migs 1930/1931)
--   → game-model principles under it (game_principles.play_principle_id, mig 1929)
--   → concepts under those (game_concepts.principle_id)
--   → the engine: behaviours tagged to those concepts (game_engine_behaviours.concept_id), and how many run in the sim
--   → book patterns that show those concepts (coaching_book_patterns.concept_id, mig 1928)
-- A principle with sources but no concepts = football we know of and have not built; concepts with no engine behaviour
-- = catalogued, not in the game.

DROP VIEW IF EXISTS game_taxonomy_chain;
CREATE VIEW game_taxonomy_chain AS
SELECT p.id, p.code, p.title, p.level, p.side,
       (SELECT count(DISTINCT t.source_id) FROM game_common_principle_links l JOIN game_source_principles t ON t.id = l.term_id
         WHERE l.principle_id = p.id) AS sources,
       (SELECT count(*) FROM game_principles g WHERE g.play_principle_id = p.id) AS model_principles,
       (SELECT count(*) FROM game_concepts c JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id) AS concepts,
       (SELECT count(*) FROM game_engine_behaviours b JOIN game_concepts c ON c.id = b.concept_id
          JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id) AS engine_behaviours,
       (SELECT count(*) FROM game_engine_behaviours b JOIN game_concepts c ON c.id = b.concept_id
          JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id AND b.in_sim) AS in_sim,
       (SELECT count(*) FROM coaching_book_patterns bp JOIN game_concepts c ON c.id = bp.concept_id
          JOIN game_principles g ON g.id = c.principle_id WHERE g.play_principle_id = p.id) AS book_patterns
  FROM game_play_principles p;

-- ONE source table: a coaching book is a game_source like every federation, paper and club (owner 11/26 "its ok for
-- an agent to change other agent work"). Each book gets its game_sources row; coaching_books.source_id points to it.
ALTER TABLE coaching_books ADD COLUMN IF NOT EXISTS source_id integer REFERENCES game_sources(id);
INSERT INTO game_sources (code, kind, title, url, verified)
SELECT 'book-' || b.slug, 'book', b.author || ', ' || b.title || coalesce(': ' || b.subtitle, '') || coalesce(' (' || b.publisher || ')', ''), NULL, true
  FROM coaching_books b
 WHERE NOT EXISTS (SELECT 1 FROM game_sources s WHERE s.code = 'book-' || b.slug);
UPDATE coaching_books b SET source_id = s.id FROM game_sources s WHERE s.code = 'book-' || b.slug AND b.source_id IS NULL;

-- "Win it straight back" IS immediate regain (mig 1930's common ground), not plain delay.
UPDATE game_principles g SET play_principle_id = p.id FROM game_play_principles p
 WHERE g.code = 'td-regain' AND p.code = 'immediate-regain';
