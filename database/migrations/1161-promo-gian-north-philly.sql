-- 1161: Gian Maldonado promo (#17, mig 1160) — owner 2026-11-07: "Gian
-- Maldonado grew up near Lighthouse Field in North Philadelphia off Lehigh
-- Avenue."  The caption opens with it.  Draft only; still unposted.
UPDATE promotional_posts
   SET caption = E'🌍⚽ PROUD OF OUR OWN — GIAN MALDONADO\n\nGian grew up near Lighthouse Field in North Philadelphia, off Lehigh Avenue — and now one of our Men''s 1893 players is taking his game around the world:\n\n🇩🇪 Trial in Germany with Bremer SV — founded 1906, playing in the Regionalliga Nord\n🇺🇸 Invited to play a friendly against the Tampa Bay Rowdies of the USL Championship\n🏟️ Invited to trial — and on trial now — with the Lehigh Valley Spirits, the new Major Arena Soccer League team at the MASL''s top level, opening Dec 5 at PPL Center\n\nFrom the neighborhood to trials at home and abroad. North Philly and the whole club are behind you, Gian! 💙\n\n#Lighthouse1893 #PhillySoccer #NorthPhilly #LighthouseSportsComplex #BremerSV #LVSpirits #MASL',
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
