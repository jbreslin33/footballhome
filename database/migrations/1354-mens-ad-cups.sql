-- 1354 (2026-11-13) — the men's year-round ad names its cups (owner: "for
-- men US OPEN CUP, US Amateur CUP, STATE CUP").  A second 🏆 line under the
-- leagues (mig 1352); the card carries them as pills.
BEGIN;
UPDATE message_templates
   SET body = replace(body, E'🏆 APSL · CASA Select Liga 1 · U23 · Grass Roots Cup Puerto Rico\n',
                      E'🏆 APSL · CASA Select Liga 1 · U23 · Grass Roots Cup Puerto Rico\n🏆 US Open Cup · US Amateur Cup · State Cup\n'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'mens-year-round' AND body NOT LIKE '%US Open Cup%';
COMMIT;
