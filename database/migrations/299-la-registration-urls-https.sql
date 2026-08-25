-- 299 — Store the LeagueApps registration URLs as https, not http.
--
-- Why (2026-08-25, owner: "yes flip them to https"). Migration 291
-- backfilled these URLs exactly as they were copied out of LeagueApps,
-- scheme included, and every one of the eight rows came over as http.
-- They are not broken — LeagueApps answers http with a 301 — but the
-- redirect it issues is to `https://lighthouse1893.leagueapps.com:443/…`,
-- an explicit port that then sits in the lead's address bar. These URLs
-- go out in recruiting email and SMS to real leads, so the first hop is
-- also the first impression: an http link in the message body is what a
-- cautious parent looks at before deciding to tap.
--
-- Rewriting the scheme in place keeps the single source of truth intact:
-- program-info.js, leads.js and flyers.js all read these rows live off
-- GET /api/public/leagueapps-registration-links and need no change, and
-- neither does the ad scripts' separate copy, which is already https.
--
-- Scoped to the leagueapps.com host and anchored at the start of the
-- string so it can only ever touch the scheme of a URL we recognise; the
-- two inactive rows hold NULL and are left alone. Idempotent — a row
-- already on https does not match.
UPDATE leagueapps_programs
   SET registration_url = 'https://' || SUBSTRING(registration_url FROM 8),
       updated_at       = NOW()
 WHERE registration_url LIKE 'http://%leagueapps.com/%';
