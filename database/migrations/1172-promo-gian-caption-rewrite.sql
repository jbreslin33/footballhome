-- 1172: Gian Maldonado promo (#17) — owner 2026-11-07 approved the full
-- caption rewrite ("yes save it"): opens like the card, trials listed once,
-- closing split in two, #APSL.  Draft only.
UPDATE promotional_posts
   SET caption = E'🌍⚽ NORTH PHILLY AND LIGHTHOUSE''S OWN — GIAN MALDONADO\n\nGian grew up near Lighthouse Field in North Philadelphia, off Lehigh Avenue. In the past month alone, the Lighthouse Men''s 1893 APSL player has been invited to three trials:\n\n🇩🇪 Bremer SV (Germany, Regionalliga Nord), founded 1906\n🇺🇸 Tampa Bay Rowdies (USL Championship)\n🏟️ Lehigh Valley Spirits (MASL top level), on trial now ahead of their Dec 5 opener at PPL Center\n\nThe invitations mean others are noticing what we already know. Gian embodies the Lighthouse ethos: opportunity through hard work and practice.\n\nEvery invite is a step on the journey. Stay focused and keep working, Gian. North Philly and the whole club are behind you! 💙\n\n#Lighthouse1893 #PhillySoccer #NorthPhilly #APSL #LighthouseSportsComplex #BremerSV #LVSpirits #MASL',
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
