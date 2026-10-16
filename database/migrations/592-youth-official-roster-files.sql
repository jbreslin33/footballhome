-- 592 (2026-10-16) — Youth official rosters: the locked U8/U10/U12 PDFs,
-- printable from Game Center.
--
-- Owner: "i just uploaded u8, u10 and u12 rosters. these are locked so
-- just add them to the game center for ease of printing … need my coaches
-- to be able to print them. or open them from app to show ref at the
-- least."
--
-- Mig 501's 🖨 Official roster panel already does exactly that for APSL
-- (TeamPass) and CASA (Google Sheet); the youth leagues' rosters are
-- locked league PDFs the owner uploads on #files instead, so the third
-- system is 'club_file': external_team_id is the club_files id, and a
-- "pull" copies that file's bytes for the game.  Re-uploading a new
-- version on #files under a new id means a new source row (migration),
-- same as a new season anywhere else.

COMMENT ON COLUMN official_roster_sources.system IS
  'Which fetcher pulls it: teampass (TeamPassRoster) | google_sheet (GoogleSheetRoster) | club_file (an uploaded #files PDF, served as-is).';
COMMENT ON COLUMN official_roster_sources.external_team_id IS
  'teampass: the team id in that address (it changes every season).  google_sheet: the team''s tab name, exactly as the workbook spells it.  club_file: the club_files id of the uploaded roster PDF.';
COMMENT ON COLUMN official_roster_sources.site_slug IS
  'teampass: the league segment of app.teampass.com/<slug>/Team/<id>.  google_sheet: the workbook id in docs.google.com/spreadsheets/d/<id>.  club_file: unused (''club_files'').';

-- Philadelphia Parks & Recreation travel, 2026/27 — club_files 48/49/50,
-- uploaded 2026-10-16.
INSERT INTO official_roster_sources (team_id, league_label, season, system, site_slug, external_team_id, credentials_key)
VALUES (912, 'Parks & Rec', '2026/27', 'club_file', 'club_files', '48', NULL),  -- U8 Travel
       (913, 'Parks & Rec', '2026/27', 'club_file', 'club_files', '49', NULL),  -- U10 Travel
       (914, 'Parks & Rec', '2026/27', 'club_file', 'club_files', '50', NULL)   -- U12 Travel
ON CONFLICT (team_id, season) DO NOTHING;
