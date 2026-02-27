-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 29
-- Match type: 1=league
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Matches
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_philadelphia-sierra-stars_vs_oaklyn-united-fc-ii_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_illyrians-fc_vs_phoenix-scm_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_persepolis-fc_vs_lighthouse-boys-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_philly-blackstars_vs_adé-united-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_philadelphia-sierra-stars_vs_phoenix-scm_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_illyrians-fc_vs_oaklyn-united-fc-ii_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_philly-blackstars_vs_lighthouse-boys-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_adé-united-fc_vs_persepolis-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090889_oaklyn-united-fc-ii_vs_philly-blackstars_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_south-shore-fc_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_south-shore-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_bcfc-all-stars_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_gambeta-fc_vs_jaguars-united-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_gambeta-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_jaguars-united-fc_vs_bcfc-all-stars_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_flatley-fc_vs_gambeta-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_strictly-nos-fc_vs_south-shore-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_jaguars-united-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_gambeta-fc_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_lancaster-city-fc_vs_kutztown-men''s-soccer_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_f&m-fc_vs_alloy-soccer-club-reserves_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_alloy-soccer-club-reserves_vs_lancaster-city-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_keystone-elite_vs_kutztown-men''s-soccer_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_alloy-soccer-club-reserves_vs_keystone-elite_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_philadelphia-sc-select_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_persepolis-united-fc-ii_vs_lighthouse-old-timers-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_phoenix-scr_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_philadelphia-sc-select_vs_persepolis-united-fc-ii_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_lighthouse-old-timers-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;


-- === CHANGES 2026-02-27 ===
-- Added: 23, Updated: 0
-- Added: Sewell's Old Boys vs Philadelphia SC Select
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:00 PM EST - 3:30 PM EST', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_philadelphia-sc-select_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Persepolis United FC II vs Lighthouse Old Timers Club
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:45 PM EST - 4:15 PM EST', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_persepolis-united-fc-ii_vs_lighthouse-old-timers-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Sewell's Old Boys vs Phoenix SCR
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '10:30 AM EDT - 12:00 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_phoenix-scr_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Philadelphia SC Select vs Persepolis United FC II
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:45 PM EDT - 4:15 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_philadelphia-sc-select_vs_persepolis-united-fc-ii_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Oaklyn United Nor'Easters II vs Persepolis United FC II
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '7:00 PM EDT - 8:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_oaklyn-united-nor''easters-ii_vs_persepolis-united-fc-ii_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-oaklyn-united-nor''easters-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Sewell's Old Boys vs Lighthouse Old Timers Club
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:00 PM EDT - 3:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_sewell''s-old-boys_vs_lighthouse-old-timers-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Ade United FC vs Phoenix SCR
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '3:00 PM EDT - 4:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_ade-united-fc_vs_phoenix-scr_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-ade-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Oaklyn United Nor'Easters II vs Lighthouse Old Timers Club
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '12:00 PM EDT - 1:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9096430_oaklyn-united-nor''easters-ii_vs_lighthouse-old-timers-club_1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-oaklyn-united-nor''easters-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: South Shore FC vs Strictly Nos Fc
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', 'TBD', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090891_south-shore-fc_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: South Shore FC vs Flatley FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '6:00 PM EDT - 7:30 PM EDT', 3,
  ht.id, at.id, NULL,
  1, 5,
  2, '9090891_south-shore-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: BCFC All Stars vs Strictly Nos Fc
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:30 PM EDT - 4:00 PM EDT', 3,
  ht.id, at.id, NULL,
  0, 2,
  2, '9090891_bcfc-all-stars_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Gambeta FC vs Jaguars United FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '12:30 PM EDT - 2:00 PM EDT', 3,
  ht.id, at.id, NULL,
  10, 0,
  2, '9090891_gambeta-fc_vs_jaguars-united-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Gambeta FC vs Flatley FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '8:15 PM EDT - 9:45 PM EDT', 3,
  ht.id, at.id, NULL,
  6, 0,
  2, '9090891_gambeta-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Jaguars United FC vs BCFC All Stars
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '6:00 PM EDT - 7:30 PM EDT', 3,
  ht.id, at.id, NULL,
  2, 4,
  2, '9090891_jaguars-united-fc_vs_bcfc-all-stars_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Flatley FC vs Gambeta FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '12:15 PM EDT - 1:45 PM EDT', 3,
  ht.id, at.id, NULL,
  4, 7,
  2, '9090891_flatley-fc_vs_gambeta-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Strictly Nos Fc vs South Shore FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '3:00 PM EDT - 4:30 PM EDT', 3,
  ht.id, at.id, NULL,
  2, 1,
  2, '9090891_strictly-nos-fc_vs_south-shore-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Jaguars United FC vs Flatley FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '6:00 PM EDT - 7:30 PM EDT', 3,
  ht.id, at.id, NULL,
  1, 8,
  2, '9090891_jaguars-united-fc_vs_flatley-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Gambeta FC vs Strictly Nos Fc
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '3:45 PM EDT - 5:15 PM EDT', 3,
  ht.id, at.id, NULL,
  8, 1,
  2, '9090891_gambeta-fc_vs_strictly-nos-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Lancaster City FC vs Kutztown Men's Soccer
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '11:00 AM EST - 12:30 PM EST', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_lancaster-city-fc_vs_kutztown-men''s-soccer_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: F&M FC vs Alloy Soccer Club Reserves
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '2:30 PM EST - 4:00 PM EST', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_f&m-fc_vs_alloy-soccer-club-reserves_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Alloy Soccer Club Reserves vs Lancaster City FC
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '6:00 PM EST - 7:30 PM EST', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_alloy-soccer-club-reserves_vs_lancaster-city-fc_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Keystone Elite vs Kutztown Men's Soccer
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '3:00 PM EDT - 4:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_keystone-elite_vs_kutztown-men''s-soccer_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
-- Added: Alloy Soccer Club Reserves vs Keystone Elite
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '2026-01-01', '6:00 PM EDT - 7:30 PM EDT', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9090893_alloy-soccer-club-reserves_vs_keystone-elite_1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;
