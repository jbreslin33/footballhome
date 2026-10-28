-- 781 (2026-10-28) — copy for the three year-round player ads (owner:
-- "we are all year programs … Fall, Winter, Spring and Summer", "3 ads",
-- "Join now", "stress its full year program … so the ad can just hum all
-- year and is not tied to a specific time").  Evergreen: no dates, no
-- season singled out, nothing that goes stale.  tier = the ad
-- key in scripts/ads/create-ad.js; same kinds as 371.
CREATE OR REPLACE FUNCTION pg_temp.add_meta_tpl(p_kind text, p_tier text, p_label text,
                                                p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort, true, false
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_meta_tpl('meta_ad_caption', 'youth-year-round', 'Meta ad caption — Youth year-round', NULL,
E'⚽ LIGHTHOUSE YOUTH SOCCER — ALL YEAR ROUND\n\nBoys & Girls · a full-year program:\n🍂 Fall — outdoor league\n❄️ Winter — indoor, Philadelphia Parks & Rec league\n🌸 Spring — outdoor league\n☀️ Summer — training\n\nJoin now — all skill levels welcome.\n\nPhiladelphia''s oldest non-profit ⚽ club.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer', 500);
SELECT pg_temp.add_meta_tpl('meta_context_card', 'youth-year-round', 'Meta lead form intro — Youth year-round',
'Lighthouse Youth Soccer — Boys & Girls, All Year',
E'Fall · Winter indoor · Spring · Summer\n199 East Erie Avenue · Philadelphia\nA coach will follow up with season dates, fees, and next steps.', 500);
SELECT pg_temp.add_meta_tpl('meta_thank_you', 'youth-year-round', 'Meta thank-you — Youth year-round',
'Thanks — talk soon!', 'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 500);

SELECT pg_temp.add_meta_tpl('meta_ad_caption', 'mens-year-round', 'Meta ad caption — Men year-round', NULL,
E'⚽ LIGHTHOUSE MENS CLUB — SOCCER ALL YEAR ROUND\n\nAdult men''s soccer, a full-year program:\n🍂 Fall — APSL & CASA Liga 1 games\n❄️ Winter — indoor training\n🌸 Spring — APSL & CASA Liga 1 games\n☀️ Summer — training\n\nJoin now — all skill levels welcome.\n\nAmerica''s oldest active ⚽ club.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #APSL #Liga1 #PhillySoccer #MensSoccer', 500);
SELECT pg_temp.add_meta_tpl('meta_context_card', 'mens-year-round', 'Meta lead form intro — Men year-round',
'Lighthouse Mens Club — Soccer All Year Round',
E'Fall · Winter indoor · Spring · Summer — APSL & CASA Liga 1\n199 East Erie Avenue · since 1893\nA coach will follow up with training times, fees, and next steps.', 500);
SELECT pg_temp.add_meta_tpl('meta_thank_you', 'mens-year-round', 'Meta thank-you — Men year-round',
'Thanks — talk soon!', 'A Lighthouse 1893 coach will reach out within 24–48 hours with training times and next steps.', 500);

SELECT pg_temp.add_meta_tpl('meta_ad_caption', 'womens-year-round', 'Meta ad caption — Women year-round', NULL,
E'⚽ LIGHTHOUSE WOMEN''S CLUB 1895 — SOCCER ALL YEAR ROUND\n\nAdult women''s 11v11 soccer, a full-year program:\n🍂 Fall — Tri County Womens League games\n❄️ Winter — indoor training\n🌸 Spring — Tri County Womens League games\n☀️ Summer — training\n\nJoin now — open to everyone, all skill levels, no experience required.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #TriCountyWomensLeague #PhillySoccer #WomensSoccer', 500);
SELECT pg_temp.add_meta_tpl('meta_context_card', 'womens-year-round', 'Meta lead form intro — Women year-round',
'Lighthouse Women''s Club 1895 — Soccer All Year Round',
E'Fall · Winter indoor · Spring · Summer — Tri County Womens League\n199 East Erie Avenue · since 1895\nA coach will follow up with training times, fees, and next steps.', 500);
SELECT pg_temp.add_meta_tpl('meta_thank_you', 'womens-year-round', 'Meta thank-you — Women year-round',
'Thanks — talk soon!', 'A Lighthouse 1893 coach will reach out within 24–48 hours with training times and next steps.', 500);
