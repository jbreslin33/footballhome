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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 5,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 2,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  10, 0,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  6, 0,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 4,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  4, 7,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 1,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 8,
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  8, 1,
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

