-- 504 (2026-09-30) — CASA's official roster, printed from Game Center.
-- Owner: "now lets do casa roster print" (after the APSL's, mig 501).
--
-- CASA keeps its official rosters as public Google Sheets workbooks, one
-- per division, linked from the league site's Captains & Coaches Corner
-- ("Philadelphia 2026-27 CASA Select Liga 1 Rosters"), one tab per team
-- with every player's headshot.  The sheet a referee sees is that team's
-- tab, exported as a PDF — backend/src/services/GoogleSheetRoster.cpp,
-- system 'google_sheet'.  The workbook is shared by link, so there is no
-- login: credentials_key is NULL for it.
ALTER TABLE official_roster_sources ALTER COLUMN credentials_key DROP NOT NULL;

COMMENT ON COLUMN official_roster_sources.system           IS 'Which fetcher pulls it: teampass (TeamPassRoster) | google_sheet (GoogleSheetRoster).';
COMMENT ON COLUMN official_roster_sources.site_slug        IS 'teampass: the league segment of app.teampass.com/<slug>/Team/<id>.  google_sheet: the workbook id in docs.google.com/spreadsheets/d/<id>.';
COMMENT ON COLUMN official_roster_sources.external_team_id IS 'teampass: the team id in that address (it changes every season).  google_sheet: the team''s tab name, exactly as the workbook spells it.';
COMMENT ON COLUMN official_roster_sources.credentials_key  IS 'teampass: the staff login is the backend env pair <KEY>_EMAIL / <KEY>_PASSWORD; never stored here.  NULL when the source needs no login.';

-- Lighthouse in CASA Select Philadelphia Liga 1, 2026/27: the league's
-- workbook still lists the team under its old name, "Lighthouse Boys Club".
INSERT INTO official_roster_sources (team_id, league_label, season, system, site_slug, external_team_id, credentials_key)
VALUES (120, 'CASA', '2026/27', 'google_sheet', '1qGcNV7z-J9qabBTx_s8oYwrkPXaqqilC', 'Lighthouse Boys Club', NULL)
ON CONFLICT (team_id, season) DO NOTHING;
