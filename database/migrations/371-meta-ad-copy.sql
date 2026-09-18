-- 371 — Meta ad copy, moved into the DB (pass 4 — the last one).
--
-- Owner 2026-09-17: "we need all messages in db no hard code not even for
-- nudges".  scripts/ads/create-ad.js typed out, per ad: the caption shown in
-- the feed, the lead form's intro card, and its thank-you page.  They are
-- rows now; tier = the ad key (`node scripts/ads/create-ad.js <key>`),
-- tier 'all' = the form an ad gets when it defines none of its own.
--   meta_ad_caption    body = the caption
--   meta_context_card  subject = card title, body = one bullet per line
--   meta_thank_you     subject = page title, body = the sentence under it
--   meta_button        tier continue | follow — the two button labels
-- The script reads them over its DB connection and refuses to build an ad
-- whose caption row is missing.  The wording below is the script's, moved
-- verbatim (generated from its ADS object, not retyped).
--
-- Not rows: lead-form questions (field schema Meta validates), targeting,
-- image URLs, budgets — configuration, not wording.
--
-- A Meta form cannot be edited once created: changing a row here changes
-- the NEXT form the script creates; archive the old one in Ads Manager.
--
-- scripts/setup-lead-forms.py is deleted: a May 2026 one-off (U23 "first
-- match May 31", Grassroots Cup "June 7") whose campaigns are long over.

INSERT INTO club_forms (club_id, code, label, url) VALUES
  (134, 'instagram', 'Instagram — @lighthouse1893soccerclub', 'https://www.instagram.com/lighthouse1893soccerclub/')
ON CONFLICT (club_id, code) DO NOTHING;

CREATE OR REPLACE FUNCTION pg_temp.add_meta_tpl(p_kind text, p_tier text, p_label text,
                                                p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort, true, false
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_meta_tpl('meta_button', 'continue', 'Meta lead form — intro card button', NULL, 'Continue', 500);
SELECT pg_temp.add_meta_tpl('meta_button', 'follow',   'Meta lead form — thank-you page button', NULL, 'Follow @lighthouse1893soccerclub', 500);

-- An ad with no lead form of its own.
SELECT pg_temp.add_meta_tpl('meta_context_card', 'all', 'Meta lead form — intro card (default)', 'Join Lighthouse 1893 Soccer Club', 'Express your interest in joining. We will be in touch with next steps.', 500);
SELECT pg_temp.add_meta_tpl('meta_thank_you',    'all', 'Meta lead form — thank-you page (default)', 'Thanks for your interest!', 'A Lighthouse 1893 coach will reach out to you soon. Follow us on Instagram for updates.', 500);

-- u23-mens — U23 Mens Interest Form
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'u23-mens', E'Meta ad — caption (U23 Mens Interest Form)', NULL, E'Now forming Lighthouse Boys Club U23 team in CASA Men''s U23 Premier League.\n\n📅 First Match: May 30, 2026\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer', 501);

-- u23-womens — U23 Womens Interest Form
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'u23-womens', E'Meta ad — caption (U23 Womens Interest Form)', NULL, E'⚽ NOW FORMING: LIGHTHOUSE WOMEN''S CLUB U23!\n\nLighthouse Women''s Club U23 is forming a team in partnership with CASA Soccer!\n\n📅 First Match: TBD\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players · Ages 16–25 eligible\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer #Lighthouse1893SC #PhillyFootball #WomensSoccer', 502);

-- grassroots-brazil — Philly Grassroots Cup — Brazil
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'grassroots-brazil', E'Meta ad — caption (Philly Grassroots Cup — Brazil)', NULL, E'🇧🇷 WE''RE GOING TO THE PHILLY GRASSROOTS CUP — BRAZIL TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Brazil team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Brazilian!\n⚠️ Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #Brazil #Lighthouse1893 #PhillySoccer #CASASoccer', 503);

-- grassroots-puertorico — Philly Grassroots Cup — Puerto Rico
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'grassroots-puertorico', E'Meta ad — caption (Philly Grassroots Cup — Puerto Rico)', NULL, E'🇵🇷 WE''RE GOING TO THE PHILLY GRASSROOTS CUP — PUERTO RICO TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Puerto Rico team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Puerto Rican!\n⚠️ Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #PuertoRico #Lighthouse1893 #PhillySoccer #CASASoccer', 504);

-- youth-signup — Lighthouse Youth Soccer — Now Enrolling (Grades 1–6)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'youth-signup', E'Meta ad — caption (Lighthouse Youth Soccer — Now Enrolling (Grades 1–6))', NULL, E'⚽ LIGHTHOUSE YOUTH SOCCER — NOW ENROLLING\n\nBoys & girls, grades 1–6.\nTravel & In-House Leagues.\n\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer', 505);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'youth-signup', E'Meta lead form — intro card (Lighthouse Youth Soccer — Now Enrolling (Grades 1–6))', E'Lighthouse Youth Soccer — Travel & In-House', E'Local community-based club — Philadelphia\n199 East Erie Avenue · since 1893\nA coach will follow up with season dates, fees, and next steps.', 505);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'youth-signup', E'Meta lead form — thank-you page (Lighthouse Youth Soccer — Now Enrolling (Grades 1–6))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 505);

-- club-wide — Lighthouse 1893 — All Programs (Men · Women · Boys · Girls)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'club-wide', E'Meta ad — caption (Lighthouse 1893 — All Programs (Men · Women · Boys · Girls))', NULL, E'⚽ LIGHTHOUSE 1893 — NOW ENROLLING\n\nJoin Philadelphia''s oldest non-profit ⚽ club — and America''s oldest active ⚽ club.\n\nOne club, four programs: Men''s, Women''s, Boys and Girls.\nA neighborhood club since 1893 — join the squad down the street.\n\nYear-round program · all ages · all skill levels welcome.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer', 506);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'club-wide', E'Meta lead form — intro card (Lighthouse 1893 — All Programs (Men · Women · Boys · Girls))', E'Lighthouse 1893 — Men, Women, Boys & Girls', E'Local community-based club — Philadelphia\n199 East Erie Avenue · since 1893\nA coach will follow up with season dates, fees, and next steps.', 506);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'club-wide', E'Meta lead form — thank-you page (Lighthouse 1893 — All Programs (Men · Women · Boys · Girls))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 506);

-- trial-pathway — APSL & CASA Select — Summer Trial Pathway
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'trial-pathway', E'Meta ad — caption (APSL & CASA Select — Summer Trial Pathway)', NULL, E'Join now and compete in meaningful competitions and train with the teams during summer to prepare for APSL season.', 507);

-- mens-club — Lighthouse Mens Club — APSL / Liga 1
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'mens-club', E'Meta ad — caption (Lighthouse Mens Club — APSL / Liga 1)', NULL, E'⚽ JOIN LIGHTHOUSE MENS CLUB — APSL / LIGA 1\n\nOpen-tryout adult men''s team competing in APSL / Liga 1.\nAll skill levels welcome. Train with the squad, compete on weekends.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #APSL #Liga1 #PhillySoccer #MensSoccer', 508);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'mens-club', E'Meta lead form — intro card (Lighthouse Mens Club — APSL / Liga 1)', E'Lighthouse Mens Club — APSL / Liga 1', E'Adult open-tryout team — Philadelphia\n199 East Erie Avenue · since 1893\nA coach will follow up with tryout dates, fees, and next steps.', 508);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'mens-club', E'Meta lead form — thank-you page (Lighthouse Mens Club — APSL / Liga 1)', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with tryout details and next steps.', 508);

-- apsl-trials — Lighthouse APSL Trials — Fall 2026
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'apsl-trials', E'Meta ad — caption (Lighthouse APSL Trials — Fall 2026)', NULL, E'⚽ APSL TRYOUTS — FALL 2026 SEASON\n\nLighthouse 1893 is finalizing its roster for the fall APSL season.\nSemi-pro level, committed players only — regular training, real competition. Come earn one of the remaining spots.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #APSL #Tryouts #PhillySoccer #MensSoccer', 509);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'apsl-trials', E'Meta lead form — intro card (Lighthouse APSL Trials — Fall 2026)', E'Lighthouse APSL Trials — Fall 2026', E'Semi-pro APSL — committed players only\nRegular training, not a rec team\n199 East Erie Avenue · since 1893\nA coach will follow up with tryout dates and next steps.', 509);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'apsl-trials', E'Meta lead form — thank-you page (Lighthouse APSL Trials — Fall 2026)', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with tryout dates and next steps.', 509);

-- liga1-trials — Lighthouse CASA Select Liga 1 Trials — Fall 2026
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'liga1-trials', E'Meta ad — caption (Lighthouse CASA Select Liga 1 Trials — Fall 2026)', NULL, E'⚽ CASA SELECT LIGA 1 TRIALS — FALL 2026\n\nOpen tryouts this summer for Lighthouse 1893''s Liga 1 select squad.\nTrain with the group, compete on weekends, earn a fall roster spot.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #Liga1 #Trials #PhillySoccer #MensSoccer', 510);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'liga1-trials', E'Meta lead form — intro card (Lighthouse CASA Select Liga 1 Trials — Fall 2026)', E'Lighthouse CASA Select Liga 1 Trials — Fall 2026', E'Competitive adult men — Philadelphia\n199 East Erie Avenue · since 1893\nTrial this summer, earn your spot for the Liga 1 fall season.', 510);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'liga1-trials', E'Meta lead form — thank-you page (Lighthouse CASA Select Liga 1 Trials — Fall 2026)', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with trial dates and next steps.', 510);

-- womens-club — Lighthouse Women's Club 1895 — Tri County Womens League — LEADS
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'womens-club', E'Meta ad — caption (Lighthouse Women''s Club 1895 — Tri County Womens League — LEADS)', NULL, E'⚽ JOIN LIGHTHOUSE WOMEN''S CLUB 1895\n\nAdult women''s 11v11 soccer, open to everyone — all skill levels, all backgrounds, no experience required.\nTrain with the squad, play in the Tri County Womens League this season.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #TriCountyWomensLeague #PhillySoccer #WomensSoccer', 511);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'womens-club', E'Meta lead form — intro card (Lighthouse Women''s Club 1895 — Tri County Womens League — LEADS)', E'Lighthouse Women''s Club 1895 — Tri County Womens League', E'Adult women''s 11v11 soccer — open to everyone, all skill levels\n199 East Erie Avenue · since 1895\nA coach will follow up with season details and next steps.', 511);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'womens-club', E'Meta lead form — thank-you page (Lighthouse Women''s Club 1895 — Tri County Womens League — LEADS)', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 511);

-- boys-club — Lighthouse Boys Club — Now Enrolling (K-12)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'boys-club', E'Meta ad — caption (Lighthouse Boys Club — Now Enrolling (K-12))', NULL, E'⚽ LIGHTHOUSE BOYS CLUB — NOW ENROLLING\n\nKindergarten through 12th grade · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #BoysClub', 512);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'boys-club', E'Meta lead form — intro card (Lighthouse Boys Club — Now Enrolling (K-12))', E'Lighthouse Boys Club — Travel & In-House', E'Local community-based club — Philadelphia\n199 East Erie Avenue · since 1893\nA coach will follow up with season dates, fees, and next steps.', 512);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'boys-club', E'Meta lead form — thank-you page (Lighthouse Boys Club — Now Enrolling (K-12))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 512);

-- girls-club — Lighthouse Girls Club — Now Enrolling (K-12)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'girls-club', E'Meta ad — caption (Lighthouse Girls Club — Now Enrolling (K-12))', NULL, E'⚽ LIGHTHOUSE GIRLS CLUB — NOW ENROLLING\n\nKindergarten through 12th grade · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #GirlsClub', 513);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'girls-club', E'Meta lead form — intro card (Lighthouse Girls Club — Now Enrolling (K-12))', E'Lighthouse Girls Club — Travel & In-House', E'Local community-based club — Philadelphia\n199 East Erie Avenue · since 1893\nA coach will follow up with season dates, fees, and next steps.', 513);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'girls-club', E'Meta lead form — thank-you page (Lighthouse Girls Club — Now Enrolling (K-12))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.', 513);

-- boys-u11u12-travel — Lighthouse Boys U11/U12 — Travel Team (Fall 2026)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'boys-u11u12-travel', E'Meta ad — caption (Lighthouse Boys U11/U12 — Travel Team (Fall 2026))', NULL, E'⚽ LIGHTHOUSE BOYS U11/U12 — TRAVEL TEAM\n\nMaking the jump from rec to travel?\nWe''re forming our U11 and U12 boys travel squads for the 2026-27 season.\n\n🏆 Philadelphia League — Boys (USSF-affiliated city pyramid)\n📅 Summer training begins June · Fall placement\n🎯 All skill levels welcome — current club & first-time travel players\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #BoysClub #U11 #U12 #TravelSoccer', 514);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'boys-u11u12-travel', E'Meta lead form — intro card (Lighthouse Boys U11/U12 — Travel Team (Fall 2026))', E'Lighthouse Boys U11/U12 — Travel Team', E'Philadelphia League — Boys · USSF-affiliated city pyramid\nSummer training begins June · Fall placement\nA coach will follow up with tryout dates, fees, and next steps.', 514);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'boys-u11u12-travel', E'Meta lead form — thank-you page (Lighthouse Boys U11/U12 — Travel Team (Fall 2026))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with U11/U12 travel-team details.', 514);

-- girls-u11u12-travel — Lighthouse Girls U11/U12 — Travel Team (Fall 2026)
SELECT pg_temp.add_meta_tpl(E'meta_ad_caption', E'girls-u11u12-travel', E'Meta ad — caption (Lighthouse Girls U11/U12 — Travel Team (Fall 2026))', NULL, E'⚽ LIGHTHOUSE GIRLS U11/U12 — TRAVEL TEAM\n\nMaking the jump from rec to travel?\nWe''re forming our U11 and U12 girls travel squads for the 2026-27 season.\n\nℹ️ Heads up: for Fall 2026 the U11/U12 girls will play on a co-ed travel team alongside the boys in the boys division. Girls-only roster planned as numbers grow.\n\n🏆 Philadelphia League · USSF-affiliated city pyramid\n📅 Summer training begins June · Fall placement\n🎯 All skill levels welcome — current club & first-time travel players\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n📧 Questions? soccer@lighthouse1893.org\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #GirlsClub #U11 #U12 #TravelSoccer', 515);
SELECT pg_temp.add_meta_tpl(E'meta_context_card', E'girls-u11u12-travel', E'Meta lead form — intro card (Lighthouse Girls U11/U12 — Travel Team (Fall 2026))', E'Lighthouse Girls U11/U12 — Travel Team', E'Fall 2026: co-ed team — girls play in the boys division.\nGirls-only roster planned as numbers grow.\nPhiladelphia League · USSF-affiliated city pyramid\nSummer training begins June · Fall placement\nA coach will follow up with tryout dates and next steps.', 515);
SELECT pg_temp.add_meta_tpl(E'meta_thank_you', E'girls-u11u12-travel', E'Meta lead form — thank-you page (Lighthouse Girls U11/U12 — Travel Team (Fall 2026))', E'Thanks — talk soon!', E'A Lighthouse 1893 coach will reach out within 24–48 hours with U11/U12 travel-team details.', 515);
