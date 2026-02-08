-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 34
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  3, 6,
  2, '9090889_9090889-lighthouse-boys-club_9090889-illyrians-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  3, 1,
  2, '9090889_9090889-phoenix-scm_9090889-oaklyn-united-fc-ii'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  2, '9090889_9090889-philadelphia-sierra-stars_9090889-adé-united-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '9090889_9096430-phoenix-scr_9090889-persepolis-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
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
  2, '9090889_9096430-lighthouse-old-timers-club_9090889-philly-blackstars'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '9090889_9096430-philadelphia-sc-ii_9090889-oaklyn-united-fc-ii'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '9090889_9090889-illyrians-fc_9090889-adé-united-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '9090889_9090889-philadelphia-sierra-stars_9090889-philly-blackstars'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '9090889_9090889-phoenix-scm_9090889-persepolis-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  9, 1,
  2, '9090889_9096430-lighthouse-old-timers-club_9090889-persepolis-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, '9096430_9096430-lighthouse-old-timers-club_9096430-phoenix-scr'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
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
  2, '9096430_9096430-philadelphia-sc-ii_9096430-phoenix-scr'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, '9096430_9090889-illyrians-fc_9096430-phoenix-scr'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 8,
  2, '9096430_9096430-persepolis-united-fc-ii_9096430-lighthouse-old-timers-club'
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
  2, '9090891_9090891-south-shore-fc_9090891-strictly-nos-fc'
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
  2, '9090891_9090891-south-shore-fc_9090891-flatley-fc'
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
  2, '9090891_9090891-bcfc-all-stars_9090891-strictly-nos-fc'
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
  2, '9090891_9090891-gambeta-fc_9090891-jaguars-united-fc'
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
  2, '9090891_9090891-gambeta-fc_9090891-flatley-fc'
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
  2, '9090891_9090891-jaguars-united-fc_9090891-bcfc-all-stars'
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
  2, '9090891_9090891-flatley-fc_9090891-gambeta-fc'
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
  2, '9090891_9090891-strictly-nos-fc_9090891-south-shore-fc'
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
  2, '9090891_9090891-jaguars-united-fc_9090891-flatley-fc'
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
  2, '9090891_9090891-gambeta-fc_9090891-strictly-nos-fc'
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
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, '9090893_9090893-f&m-fc_9090893-lancaster-city-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '9090893_9090893-kutztown-men''s-soccer_9090893-keystone-elite'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, '9090893_9090893-alloy-soccer-club-reserves_9090893-kutztown-men''s-soccer'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '9090893_9090893-keystone-elite_9090893-f&m-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  3, 2,
  2, '9090893_9090893-keystone-elite_9090893-alloy-soccer-club-reserves'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, '9090893_9090893-kutztown-men''s-soccer_9090893-lancaster-city-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 0,
  2, '9090893_9090893-lancaster-city-fc_9090893-alloy-soccer-club-reserves'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 1,
  2, '9090893_9090893-kutztown-men''s-soccer_9090893-f&m-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '9090893_9090893-alloy-soccer-club-reserves_9090893-f&m-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-01-01', NULL, 3,
  ht.id, at.id, NULL,
  4, 3,
  2, '9090893_9090893-keystone-elite_9090893-lancaster-city-fc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

