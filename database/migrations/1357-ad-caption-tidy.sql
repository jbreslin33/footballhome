-- 1357 (2026-11-13) — three caption fixes on the year-round ads (owner: "fix
-- all three"):
--   youth  — the 📧 Questions line the adult ads carry (parents ask most)
--   men's  — #Liga2 hashtag beside #Liga1 (Liga 2 listed since mig 1356)
--   women's — a heritage line, the one already on the women's card
--             ("Philadelphia's oldest non-profit ⚽ club")
BEGIN;
UPDATE message_templates
   SET body = replace(body, E'199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893',
                      E'199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'youth-year-round' AND body NOT LIKE '%📧%';
UPDATE message_templates
   SET body = replace(body, '#Liga1 ', '#Liga1 #Liga2 '), updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'mens-year-round' AND body NOT LIKE '%#Liga2%';
UPDATE message_templates
   SET body = replace(body, E'🇺🇸 US Soccer affiliated.\n\n📍',
                      E'🇺🇸 US Soccer affiliated.\n\nPhiladelphia''s oldest non-profit ⚽ club.\n\n📍'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'womens-year-round' AND body NOT LIKE '%oldest%';
COMMIT;
