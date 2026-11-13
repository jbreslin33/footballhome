-- 1352 (2026-11-13) — the adult year-round ads name their leagues (owner:
-- "for men and women we need to show the leagues. for women it should say
-- Tri County Womens League. For men APSL, CASA Select Liga 1, U23, Grass
-- Roots Cup Puerto Rico").  Caption line under the program line; the card
-- graphic carries the same as pills (scripts/generate-year-round-cards.js).
BEGIN;
UPDATE message_templates
   SET body = replace(body, E'League games · Training · Tournaments\n',
                      E'League games · Training · Tournaments\n🏆 APSL · CASA Select Liga 1 · U23 · Grass Roots Cup Puerto Rico\n'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'mens-year-round' AND body NOT LIKE '%🏆%';
UPDATE message_templates
   SET body = replace(body, E'League games · Training · Tournaments\n',
                      E'League games · Training · Tournaments\n🏆 Tri County Women''s League\n'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'womens-year-round' AND body NOT LIKE '%🏆%';
COMMIT;
