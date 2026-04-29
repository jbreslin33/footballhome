-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 18
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, 'f3ec8843-5439-41e1-90fc-411a4055eff7'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', NULL, 3,
  ht.id, at.id, NULL,
  5, 2,
  2, 'cd722083-b2a0-459d-8b3b-91d00769de2d'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', NULL, 3,
  ht.id, at.id, NULL,
  4, 0,
  2, 'b6706459-e1ba-4f3b-ba87-dfe8f94cc0a9'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', NULL, 3,
  ht.id, at.id, NULL,
  5, 0,
  2, 'f0de1594-558a-459f-96e9-bd85082c30c7'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-ade-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, '19d9976a-3d19-43d6-a7ce-8f1b95593a1d'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', NULL, 3,
  ht.id, at.id, NULL,
  8, 0,
  2, 'd4060108-b706-4f5f-a165-8a93b1d36f75'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '181b0c79-9df5-40d7-8914-059918a54bba'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, '2691872e-1ba7-46c8-8734-2882ce88cd80'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philly-black-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', NULL, 3,
  ht.id, at.id, NULL,
  0, 2,
  2, '77bbf9e9-7d6c-490c-9aa7-530fe5136be1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '350f8806-0194-40a3-b301-98c2c835e3ea'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', NULL, 3,
  ht.id, at.id, NULL,
  3, 1,
  2, '90e6d273-4df2-4d40-99fe-b60f597f9e71'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, '06b972a1-c5ad-4dda-b1f5-e2ef609f3fab'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', NULL, 3,
  ht.id, at.id, NULL,
  8, 0,
  2, '21b167eb-781e-489f-8eda-41ec926a4ba3'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-oaklyn-united-nor''easters-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', NULL, 3,
  ht.id, at.id, NULL,
  5, 1,
  2, '4a88faec-37e9-46dc-a5c4-819bedae41eb'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 3,
  ht.id, at.id, NULL,
  1, 4,
  2, 'fc3a66ec-1d87-491a-85a4-8ba9322bea3e'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 3,
  ht.id, at.id, NULL,
  1, 6,
  2, 'ff714569-61d8-4b38-a652-28243676b709'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-illyrians' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 3,
  ht.id, at.id, NULL,
  5, 0,
  2, 'ecb165b3-a21f-47df-ad53-4762827218aa'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'e2350470-d8a1-4cfe-8d33-210ece9f3904'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-boys-club-u23' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

