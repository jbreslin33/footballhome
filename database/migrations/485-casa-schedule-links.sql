-- 485 (2026-09-28) — CASA Liga 1 / Liga 2 on SportsEngine: per-team pages.
-- Owner: "casa crests can be gotten from casa website … you can get schedule
-- there just like apsl".  The league pages (casasoccerleagues.com/page/show/
-- 9496155-liga-1, …9496153-liga-2) embed a SportsEngine "season microsite";
-- each team has its own page there with schedule + standings, the way
-- apslsoccer.com/APSL/Team/<id> does for APSL.  Season 69f8ec901f20d170d3795cec
-- = 2026/27.  Crests were stored through POST /api/club-logos/from-url from
-- the #logos session (S3 se-team-service-production), not by migration.
--
-- 1. Our Liga 1 team's schedule link points at OUR team page (the old link
--    was the whole-season schedule).  The Reserves' Liga 1 link likewise.
UPDATE team_schedule_links
   SET url = 'https://season-microsites.ui.sportsengine.com/seasons/69f8ec901f20d170d3795cec/teams/6a8f04089d166850e308b54a',
       label = 'League schedule (CASA Liga 1)'
 WHERE team_id IN (120, 938) AND url LIKE 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule%';

-- 2. Every CASA opponent's league page on its Opponents card ("league page ↗").
CREATE OR REPLACE FUNCTION pg_temp.casa_url(p_alias text, p_team text) RETURNS void LANGUAGE sql AS $$
  UPDATE club_competitions k SET external_url = 'https://season-microsites.ui.sportsengine.com/seasons/69f8ec901f20d170d3795cec/teams/' || p_team, updated_at = now()
   WHERE k.league_label = 'CASA' AND k.season = '2026/27'
     AND k.club_id = COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_alias)) LIMIT 1),
                              (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_alias)) ORDER BY id LIMIT 1));
$$;
-- Liga 1
SELECT pg_temp.casa_url('Oaklyn United FC II', '6a8f0408389ac15101d723a4');
SELECT pg_temp.casa_url('Desert Hawks FC', '6a8f04f1a79fcee7ada0ea1d');
SELECT pg_temp.casa_url('Phoenix SCM', '6a8f04084ad175a038915572');
SELECT pg_temp.casa_url('Philadelphia Sierra Stars', '6a8f040897a77290a4d23ba5');
SELECT pg_temp.casa_url('WC Predators II', '6a8f04f197a77290a4d23bd0');
SELECT pg_temp.casa_url('VE Reserves', '6a8f04f13036ef20dd2cdfd8');
SELECT pg_temp.casa_url('Philadelphia SC Select', '6a8f04f1ebd33aa14dd4805f');
-- Liga 2
SELECT pg_temp.casa_url('Philadelphia Lions', '6a8f04f17f7a136eaed23a1b');
SELECT pg_temp.casa_url('Phila Heritage SC II', '6a8f04f1131e277a210fdeed');
SELECT pg_temp.casa_url('Phoenix SCR', '6a8f040850e26b9b5a915576');
SELECT pg_temp.casa_url('Street Soccer USA Philly', '6a8f04f1ddd82e22e9d71eb8');
SELECT pg_temp.casa_url('Persepolis United FC II', '6a8f04087f7a136eaed23a16');
SELECT pg_temp.casa_url('Nomads FC', '6a8f04f19d166850e308b57b');
SELECT pg_temp.casa_url('Danubia SC', '6a8f04f18d6c1366680fe342');
SELECT pg_temp.casa_url('Desert Hawks II', '6a8f04f1e83649e6ab0b517b');
-- The league's own spellings, so the calendar's opponent text resolves too.
INSERT INTO club_aliases (club_id, alias, notes)
SELECT c.club_id, v.alias, 'mig 485 casa spelling' FROM (VALUES
  ('Vereinigung Erzgebirge Reserves', 'VE Reserves'), ('Philadelphia Lions Fc', 'Philadelphia Lions'), ('Street Soccer USA-Philly', 'Street Soccer USA Philly'),
  ('Lighthouse Mens Club 1893', 'Lighthouse 1893 SC')) AS v(alias, known)
JOIN LATERAL (SELECT COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(alias) = LOWER(v.known) LIMIT 1), (SELECT id FROM clubs WHERE LOWER(name) = LOWER(v.known) LIMIT 1)) AS club_id) c ON c.club_id IS NOT NULL
WHERE NOT EXISTS (SELECT 1 FROM club_aliases a WHERE LOWER(a.alias) = LOWER(v.alias));
