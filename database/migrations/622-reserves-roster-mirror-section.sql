-- 622 (2026-10-21) — The Reserves' own 🌐 roster mirror, by page section.
--
-- TeamPass's 10/21 restyle put BOTH of our squads on the one team page
-- (app.teampass.com/APSL/Team/165430): the first team's grid, then an
-- "<h2>Reserve Roster (…)</h2>" grid.  The blind scan swallowed both
-- (the APSL pill briefly read 50), so sources now name their section:
-- section_label scopes the TeamPass parse to the grid under the <h2>
-- containing that text; NULL keeps the first grid, and non-TeamPass
-- systems ignore it.  That same section gives the APSL Reserves column
-- (team 938) its own mirror row — owner 2026-10-21: "this should be
-- done for each roster online".

ALTER TABLE official_roster_sources ADD COLUMN IF NOT EXISTS section_label text;
COMMENT ON COLUMN official_roster_sources.section_label IS
  'mig 622: for teampass sources, the heading text of the squad''s grid on the team page (e.g. ''Reserve Roster''); NULL reads the first grid.';

INSERT INTO official_roster_sources
    (team_id, league_label, season, system, site_slug, external_team_id, credentials_key, is_active, section_label)
SELECT 938, 'APSL Reserves', '2026/27', 'teampass', 'APSL', '165430', 'APSL', true, 'Reserve Roster'
WHERE NOT EXISTS (
    SELECT 1 FROM official_roster_sources WHERE team_id = 938 AND season = '2026/27'
);
