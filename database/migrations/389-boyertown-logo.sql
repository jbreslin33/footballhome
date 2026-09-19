-- 389 — Boyertown's crest for the women's Tri County game.
--
-- Owner 2026-09-19: "store boyertown in db ... and use their logo this
-- week."  Boyertown Breakers have no teams row, so the crest goes where
-- EventController's away-logo fallback reads it for a free-text
-- opponent: opponent_logo_cache, keyed on fh_events.opponent.  The file
-- is a local copy (frontend/images/teams/logos/, from the club's
-- profile image, white surround cut away and cropped to the shield so
-- it fills the crest tile) because html2canvas cannot capture a cross-origin
-- host that is not on the logo proxy's allowlist.
INSERT INTO opponent_logo_cache (opponent_text, logo_url, source)
VALUES ('Boyertown Breakers', '/images/teams/logos/boyertown-breakers.png', 'manual')
ON CONFLICT (lower(btrim(opponent_text)))
DO UPDATE SET logo_url = EXCLUDED.logo_url, source = EXCLUDED.source, fetched_at = now();
