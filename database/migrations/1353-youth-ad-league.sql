-- 1353 (2026-11-13) — the youth year-round ad names its league (owner:
-- "for youth league. Philadelphia Parks & Recreation Soccer League").
-- Caption 🏆 line like the adult ads (mig 1352); the card carries it as a
-- pill (scripts/generate-year-round-cards.js).
BEGIN;
UPDATE message_templates
   SET body = replace(body, E'League games · Training · Tournaments\n',
                      E'League games · Training · Tournaments\n🏆 Philadelphia Parks & Recreation Soccer League\n'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'youth-year-round' AND body NOT LIKE '%🏆%';
COMMIT;
