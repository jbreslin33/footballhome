-- 🏟 Turf Mini Pitch: the slab can be painted for basketball, so no tiles to
-- keep up (James 11/23 "our cement under sport court could be painted for
-- basketball and then no need for sport court up keep of tiles"). Added as
-- the alternative to laying the tiles back, in the summary, the site, the
-- scope, the not-in-any-package list and the decisions. Not priced yet.
BEGIN;

UPDATE proposal_sections s SET body = replace(s.body,
  'roll up the turf and lay the tiles back. The hoops stay up throughout.',
  'roll up the turf and lay the tiles back. Or the concrete slab can be painted for basketball: then the court is ready as soon as the turf is rolled up, and there are no tiles to keep up. The hoops stay up throughout.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  '**Tiles.** They lift off, are stored on site, and can go back down for basketball.',
  '**Tiles.** They lift off, are stored on site, and can go back down for basketball. If the slab is painted for basketball instead, the tiles are not needed again.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 2;

UPDATE proposal_sections s SET body = replace(s.body,
  'so the court goes back to basketball: roll up the turf and lay the tiles back.',
  'so the court goes back to basketball: roll up the turf and lay the tiles back, or play on the slab if it has been painted for basketball.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 3;

UPDATE proposal_sections s SET body = replace(s.body,
  '**Not in any package:** benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).',
  '**Not in any package:** painting the slab for basketball (price when bid), benches, and taking the hoops out for soccer ($2,000–$6,000, estimate).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;

UPDATE proposal_sections s SET body = s.body || E'\n- **Basketball:** keep the tiles to lay back, or paint the slab so no tiles are needed?'
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10
  AND s.body NOT LIKE '%paint the slab%';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND s.sort_order IN (1,2,3,4,10) AND s.body LIKE '%painted for basketball%' OR
         (p.code = 'erie-avenue-turf' AND s.sort_order IN (4,10) AND (s.body LIKE '%painting the slab for basketball%' OR s.body LIKE '%paint the slab%'));
  IF n <> 5 THEN RAISE EXCEPTION 'mini pitch: painted slab in % of 5 sections', n; END IF;
END $$;

COMMIT;
