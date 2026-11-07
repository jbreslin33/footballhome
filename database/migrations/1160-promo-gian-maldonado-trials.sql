-- 1160: Draft on #promo-posts (owner 2026-11-07): Gian Maldonado (person
-- 14454, Men's 1893) — trial with Bremer SV (Germany, Regionalliga Nord),
-- friendly vs Tampa Bay Rowdies (USL Championship), now on trial with the
-- Lehigh Valley Spirits (MASL).  Card rendered from club_files 53 (selfie
-- un-mirrored) at footballhome.org/images/posts/gian-maldonado-trials-2026-11.jpg.
-- Draft only — the owner posts or schedules it from #promo-posts.
INSERT INTO promotional_posts (title, caption, image_url, status, heading, subheading)
SELECT 'Gian Maldonado — Bremer SV trial, Rowdies friendly, Spirits trial',
       E'🌍⚽ PROUD OF OUR OWN — GIAN MALDONADO\n\nOne of our Men''s 1893 players has had quite a run:\n\n🇩🇪 Trial in Germany with Bremer SV — founded 1906, playing in the Regionalliga Nord\n🇺🇸 Invited to play a friendly against the Tampa Bay Rowdies of the USL Championship\n🏟️ Invited to trial — and on trial now — with the Lehigh Valley Spirits, the new Major Arena Soccer League team at the MASL''s top level, opening Dec 5 at PPL Center\n\nFrom the fields at Lighthouse to trials at home and abroad. The whole club is behind you, Gian! 💙\n\n#Lighthouse1893 #PhillySoccer #LighthouseSportsComplex #BremerSV #LVSpirits #MASL',
       'https://footballhome.org/images/posts/gian-maldonado-trials-2026-11.jpg', 'draft',
       'Gian Maldonado', 'From Lighthouse to the pros'
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%gian-maldonado-trials-2026-11%');
