-- 291 — Backfill registration_url for every active/pickup LA program.
--
-- Context (2026-08-21): some Men's lead emails/SMS were going out with a
-- bare https://lighthouse1893.leagueapps.com link (no path) because the
-- 'APSL Trials' / 'LIGA 1 Trials' funnels (added 2026-07-04) were never
-- wired into frontend/js/screens/leads.js's hardcoded LINKS map, and fell
-- through to a hardcoded fallback literal. Root problem per
-- migration 097's own stated goal: registration URLs were hardcoded in
-- (now) 4 separate places instead of read from this table.
--
-- Owner verified each URL directly against live LeagueApps pages
-- (2026-08-21), including the wrinkle that Men's active membership has a
-- DIFFERENT public checkout id (5039296) than the LA-internal admin/API
-- league id (5039300, confirmed via manager.leagueapps.com console) that
-- the rest of the backend (LaPool/MensRoster/PaymentsController/etc.)
-- depends on for roster sync + payment matching. Every other
-- category's public id matches its internal id exactly. So: program_id
-- stays untouched everywhere (still the API-facing key), only
-- registration_url text changes.
--
-- Unlike migration 097's backfill (which only set registration_url when
-- NULL, to avoid clobbering hand edits), this overwrites unconditionally
-- for all 8 rows — the Men's active value that was there was wrong, and
-- the point of this migration is establishing verified-correct values as
-- the new baseline.

BEGIN;

UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039296-lighthouse-mens-club-1893-soccer-membership',   updated_at = NOW() WHERE program_id = 5039300; -- men, active (public id 5039296 != internal 5039300)
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5070075-lighthouse-mens-club-1893-pickup-soccer-membership', updated_at = NOW() WHERE program_id = 5070075; -- men, pickup
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039340-lighthouse-womens-club-1895-soccer-membership',   updated_at = NOW() WHERE program_id = 5039340; -- women, active
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5064686-lighthouse-womens-club-1895-pickup-soccer-membership', updated_at = NOW() WHERE program_id = 5064686; -- women, pickup
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer/5039252-lighthouse-boys-club-1897-soccer-membership',              updated_at = NOW() WHERE program_id = 5039252; -- boys, active
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer/5064618-lighthouse-boys-club-1897-pickup-soccer-membership',        updated_at = NOW() WHERE program_id = 5064618; -- boys, pickup
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer/5039357-lighthouse-girls-club-1898-soccer-membership',             updated_at = NOW() WHERE program_id = 5039357; -- girls, active
UPDATE leagueapps_programs SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer/5064662-lighthouse-girls-club-1898-pickup-soccer-membership',       updated_at = NOW() WHERE program_id = 5064662; -- girls, pickup

COMMIT;
