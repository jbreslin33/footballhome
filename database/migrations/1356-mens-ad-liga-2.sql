-- 1356 (2026-11-13) — the men's year-round ad lists Liga 2 (owner: "liga 2
-- to leagues for men" + "yes put it in grphic too").  Recruiting for the
-- spring 2027 Liga 2 entry (team 958, mig 1333): a level for men who won't
-- make Liga 1 / APSL.  Caption 🏆 leagues line (mig 1352); the card gets a
-- CASA SELECT LIGA 2 pill (scripts/generate-year-round-cards.js).
BEGIN;
UPDATE message_templates
   SET body = replace(body, '🏆 APSL · CASA Select Liga 1 · U23 ·', '🏆 APSL · CASA Select Liga 1 · Liga 2 · U23 ·'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'mens-year-round' AND body NOT LIKE '%Liga 2%';
COMMIT;
