-- 376 — The Lighthouse crest lives on the club row.
--
-- Owner 2026-09-18: "for game center we need lighthouse logo for our
-- teams. opponent can have opponent logo or generic league logo."
--
-- Only APSL (35), Reserves (938) and Liga 1 (120) carried a teams.logo_url;
-- the women's, travel and intramural sides had none, so #game-center drew
-- the 🏠 placeholder for them.  The crest is the club's, not each team's:
-- set it once on clubs.logo_url and let EventController's teamCrest()
-- fall back to it for any team without a badge of its own.  The opponent
-- side is unchanged (own logo -> alias / name / cache -> league crest).
--
-- Same file the site already serves as its icon and on the public pages.
UPDATE clubs
   SET logo_url = '/images/lighthouse-1893-crest.png'
 WHERE id = 134
   AND COALESCE(logo_url, '') = '';
