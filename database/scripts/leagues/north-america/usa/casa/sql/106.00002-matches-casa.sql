-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 221
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  3, 8,
  2, 'dc6ccb40-e5c8-4f77-a1f7-e4289e685617'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 2,
  2, 'b3300d0f-cb63-4c00-b298-b224c2610317'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  1, 4,
  2, 'e74fc9dc-256c-4e3d-9a32-7af13d2e4e7d'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 0,
  2, '29856560-a8dc-4787-b7bc-274390ab3b57'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  6, 0,
  2, 'c26933ba-949e-446e-9809-01c9ddc7c9eb'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, '947e1255-be86-4268-a644-08321f309449'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  2, 2,
  2, '9da3c018-7448-468a-8555-63d42c2f1380'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  4, 0,
  2, '3e7af5a0-057e-4db5-b787-15f8b5054b01'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  6, 1,
  2, 'ed3f1a1c-1d83-4133-ab37-69f9ed8673a7'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  2, 'efc3a3b9-745e-46ad-9182-2cf5c1f1f008'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  2, 3,
  2, 'c9a534d4-4c0b-4c1d-9e38-dec2941044c2'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  0, 1,
  2, '8ec82fc3-873b-40c3-8326-9d160e602023'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  4, 2,
  2, '9394fcb2-8352-461b-b5cd-4fbc21bac687'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  5, 3,
  2, '64d3c363-a4ed-41ff-925a-7e15ac9b24f4'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  2, 0,
  2, 'cc0e979d-f7f9-46e4-a32c-332ad94fc867'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  3, 1,
  2, '7bc336c5-b4f6-42c4-8283-4cf0462cbb9d'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  2, 3,
  2, '9f087b0c-7e6b-482e-9c6e-6acf5cb9847a'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  2, 1,
  2, 'b119eaf1-b38e-4baa-b924-782da953601c'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, 4,
  2, 'ed9b0cba-5853-4ed0-ade7-359831cf483e'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  3, 0,
  2, '4d0aec19-d08e-48e8-82a6-69719da11fc7'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  3, 3,
  2, '1a466ec4-664e-430b-8e47-a42b5b7b510d'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  2, 2,
  2, '39068930-b37c-4b74-9342-365975083bd1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
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
  1, '2025-10-19', NULL, 3,
  ht.id, at.id, NULL,
  3, 2,
  2, 'c566d9d3-1f1b-4919-a9b4-4e2c3a61b951'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2025-10-29', NULL, 3,
  ht.id, at.id, NULL,
  3, 2,
  2, '457b3df2-1cbf-4668-9fa1-d939b6145168'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2025-10-30', NULL, 3,
  ht.id, at.id, NULL,
  4, 1,
  2, '86f991e2-3a19-4774-9556-2c37e22dbe58'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2025-10-30', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, '9e2bbb5e-7d4f-4be9-b00f-5c568d9eb6f1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2025-10-31', NULL, 3,
  ht.id, at.id, NULL,
  5, 1,
  2, '24730300-c55f-4811-8444-5ee7c3bcdcaa'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  2, 4,
  2, '08b7c432-0fa1-407f-8968-221dc2ee07f6'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  2, 1,
  2, '610ab78c-e2ba-418c-9286-563bdc52bdf8'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  1, 3,
  2, '5d04c17c-b3ca-44b8-8dfb-db93fece8871'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2025-11-06', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, '349116fd-0244-49a9-b863-22e4a612abe0'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2025-11-06', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '547f5b1b-0eda-4659-b1c8-9925dde33a44'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2025-11-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, 'fc780790-8e02-44fc-855a-cde65a0f24d4'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2025-11-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, '08ac4dd8-3fdd-40bd-b1bf-95302006a543'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '7d71e9e0-2d66-44a8-a6c8-ba94a77e8d6a'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, 'f205f1e1-339e-4552-a5b9-14b6e661811a'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, 3,
  2, 'a626ab3c-f16e-47d0-8f62-97e988d205ed'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  6, 3,
  2, '94b4c1b4-8f70-4373-8cdb-f2217950a044'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  0, 1,
  2, '97f6cb8b-e96c-40c8-908c-7811c25bdefd'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  4, 3,
  2, '150ab0ff-9a95-42fc-92ab-dea7d680ec59'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f394c026-6768-41bc-8c1c-4935589024e3'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
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
  1, '2026-03-01', NULL, 3,
  ht.id, at.id, NULL,
  1, 3,
  2, '0b81a198-cc66-439e-99b0-d2cbfe130cab'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, 'be9a0154-1a39-4637-adae-fe53324c9c50'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  1, 6,
  2, '9d780e42-fb7e-4aae-b828-ea635ea28f62'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, 'd0f75702-a4c5-4c74-af9c-53a7cdb26140'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  1, 7,
  2, '8184478a-5e8c-4fa5-9624-623616fd23ce'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2851e153-f467-426f-96a0-72791af7f5eb'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '6296e19b-b4fd-4983-b3b3-a4086567e543'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'a7ba1a7e-1c16-489c-b9f2-f69eca4cf7d6'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '45913079-5a2d-4c00-b44d-d406614a7192'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '658779a1-a514-4289-abe4-03f8a275dae8'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
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
  1, '2026-03-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '01eb55cf-9f65-4853-81e8-8f74b9a4d055'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '47649325-1732-42e9-92d5-2d9e3b7227d2'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '62294e19-4b8a-481b-bcf5-6e4f80baa542'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '7c505606-7538-4254-b75f-1f8335bb68f4'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0eb0f7bc-d966-461c-9db2-6df19e5cb91c'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '5e1c1adb-1606-4a8c-a28e-f67a167eaacb'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
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
  1, '2026-03-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '3265ccb1-af30-4fa5-97d0-1e1ef4e2ae56'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '975e6446-a502-4263-8d12-74083d123347'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '264d201b-7f35-42f3-b19b-61e7effdb658'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '209ee67c-ee21-4200-b3bc-45f0f7964612'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ffc59cbe-a8c5-4592-bc6b-41a05a108854'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0990d763-287f-4d88-840f-bf777c37f6be'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-sewell''s-old-boys' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f9723869-a966-4a8e-9ee4-d36eab6620ea'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'cc54baea-5c9b-4b38-9e5e-4f0a89c49ab0'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'caf414b4-7f9a-4507-8132-d20d9dddba55'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-sewell''s-old-boys' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'a435f090-bb85-470a-8e7b-7b1e3e91258e'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
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
  1, '2026-04-16', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '30bbc7cd-6e90-4678-af6a-e532be5cadd1'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '21d2bea7-e180-440e-ae34-2adedb51a239'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '567017b2-88e9-45c7-b6ed-33e49398fb7c'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ef8894b1-a525-4ce0-bd80-a28b3e8c7163'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '75853064-d047-4398-b292-8124f6382b11'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'd8ff1358-b741-4f1c-a1bf-f95831aa7a58'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f435b363-e72d-49b5-baed-cc8d09514092'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
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
  1, '2026-04-27', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '85f9381f-3278-4ca9-88e9-0b7b653718a5'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
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
  1, '2026-04-30', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0a9f8712-a8b9-4058-bc6f-df425fe74b19'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
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
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '98abeb8e-572a-4195-8a58-75fecb6cc379'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  2, 'a14e2f82-b510-4ca9-a203-4fe744448d69'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
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
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0458da0c-e574-40d8-a9e0-bec88c6b1615'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
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
  2, 'af153708-2f4f-4dd9-8971-2b960ee84093'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '102e7b4f-ae55-4f81-85f6-ed74a18c62b5'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-lighthouse-boys-club' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'a7386a54-6abe-45bb-9dc3-39fb5d0cad46'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'e8aa0e9b-8216-4c09-b643-4806af64dc39'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '703293fc-8366-4dd5-93c8-3afc5e6b415e'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  1, 3,
  2, 'ef489f44-88bf-4caa-a0ea-979dd2d20f8f'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  2, 2,
  2, '65e764a6-ef1c-40c6-903c-7866c89c2867'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-phoenix-scm' AND at.source_system_id = 2
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
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
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
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
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
  1, '2025-10-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'a365caf9-9070-445c-9c83-3d7bcdba5a96'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-fc-ii' AND at.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, '5e17f40f-dcc5-4cf4-973d-287136f16897'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
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
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
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
  1, 6,
  2, 'd39f4e00-03cc-49e8-87c1-d1821fbb098e'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, 'da1a7639-30b9-4b55-82aa-2684619ea5fd'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '21b167eb-781e-489f-8eda-41ec926a4ba3'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-boys-club-u23' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '6221cd0d-a385-4478-a2d0-7dec7543076b'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'fc3a66ec-1d87-491a-85a4-8ba9322bea3e'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ff714569-61d8-4b38-a652-28243676b709'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '5e8e4dde-a165-42bf-b967-9b559e75c162'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-sewell''s-old-boys' AND at.source_system_id = 2
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
  1, '2026-04-23', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '60679fcd-c0c7-4423-83bc-9bd64a756ce2'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0812a16e-cf25-4ba2-877d-acb125162844'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
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

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  7, 2,
  2, '43748bdb-ff51-42cf-ad3e-db2513cc4be3'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  2, 2,
  2, 'f3799381-f531-49d1-b667-391351ee9a3b'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  3, 7,
  2, 'a9222fd7-f9a8-486b-96b4-e91091052424'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2025-09-13', NULL, 3,
  ht.id, at.id, NULL,
  0, 4,
  2, '090aeb07-5fbb-44e5-a5e2-aff9afa19baa'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  0, 4,
  2, '9cbec86b-8e9e-4ca4-979a-a8afb49f8f6b'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  4, 8,
  2, 'c62c602e-dc61-4f1b-b510-0f9ebe2a2b64'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  0, 2,
  2, 'b9a2ca7b-2fe0-48c2-b42c-dd68875a60f1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2025-09-27', NULL, 3,
  ht.id, at.id, NULL,
  5, 1,
  2, 'dfd3124c-20b9-4a72-a90c-c8251c2af20f'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  4, 3,
  2, 'b1852d3a-b459-4e6e-8650-cacb813603d7'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, 6,
  2, 'bf586a93-0774-4eb4-9633-30336670dc83'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2025-10-04', NULL, 3,
  ht.id, at.id, NULL,
  1, 1,
  2, 'aa7f2b43-dd26-4f3e-b6bb-d6dec6467b95'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, 9,
  2, '3cb64f14-1cbd-4b01-85e2-8a6362a16c5a'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  6, 2,
  2, '86bfc7ca-05ac-4bfd-a2c9-95865253e5f1'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, 3,
  2, '89bb6477-08fa-4d54-aeba-721e5d9dc60b'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, 8,
  2, '98e212a2-c093-4885-9795-07e1198a1ef8'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  8, 1,
  2, 'e59b1526-7335-4a4e-b7e6-a6f2cd0b1fb5'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2025-10-18', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, 'd60c4fdc-f4b6-41eb-9ab9-c8696add77de'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2025-10-19', NULL, 3,
  ht.id, at.id, NULL,
  7, 4,
  2, 'e1e7d51c-023d-4177-8ced-0b5f1234e83a'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2025-10-19', NULL, 3,
  ht.id, at.id, NULL,
  4, 2,
  2, '9a64b2d8-630e-454a-b1f0-b0b007188298'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2025-10-24', NULL, 3,
  ht.id, at.id, NULL,
  0, 6,
  2, '12ffb6a6-ca54-452d-846e-c70c2c85fdc7'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2025-10-26', NULL, 3,
  ht.id, at.id, NULL,
  0, 10,
  2, 'af05cce5-3715-4673-a4b7-8d9b939fce4a'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2025-10-26', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, 'dad8e18e-c795-4395-970e-09f9726e083b'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, '2025-10-26', NULL, 3,
  ht.id, at.id, NULL,
  5, 1,
  2, 'a00c1b15-6ebc-46b6-bfd4-18c876b82f58'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'e28d3e3b-f4d6-42f5-bbce-8cbbc1beb7c2'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '4d4cb7a0-9255-4c13-896e-3aa104605c3b'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0745ee5f-277c-4501-bb33-2e6fe38fdfcc'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-somerville-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '4ecc9412-b8f9-4db8-aef1-feb2c8bead33'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '233a48e0-7ed0-467c-90c0-3315d8ae7dd4'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-somerville-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0b6d6ac1-b516-4557-826f-0823d2576131'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2026-04-04', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'c8a9e404-a831-4d75-bac1-26950c9feb04'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, '2026-04-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'e8de2369-457a-4667-b88f-c856e7390f4c'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '64674b29-182e-4be5-afad-90b38201a1db'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '7da002dd-7e42-4969-adab-8e083f99d5eb'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-somerville-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '55496d08-f6fa-4dd8-b060-fbc5f2333af7'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '66cfeb40-cb14-4f60-b072-3cda6e2b24f8'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'e28111b8-e537-4fbe-8b4f-a6cd9b11110a'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-somerville-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '08214ec4-597f-4d81-aad0-6916663a2fb4'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2ce744fa-1bf1-42d9-8170-a41410456722'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2ef2c4ba-eacd-4c40-9ef0-a2dcaa2cf6b2'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-somerville-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2aa23d2c-1f6f-4d05-9241-c68240c4e991'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  2, '5df0888e-069e-47f6-ad2d-d422ba24577e'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-gambeta-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  2, '39a43ca4-d079-4618-ad03-bc850edb1012'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  2, '53da0fc9-44e1-444c-9e7e-774b0c9abd75'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2c5a9545-abcf-4be2-acb3-162626a1ed03'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f71feb2c-736e-476f-b69c-a94640095a60'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2c9f6c76-dc41-46d6-9cb3-5e8483b76582'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-somerville-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-flatley-fc' AND ht.source_system_id = 2
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
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'fbf37a92-5d02-4125-b34c-139f8a56e6ac'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-strictly-nos-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-bcfc-all-stars' AND ht.source_system_id = 2
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
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '708abba0-c4c4-442c-8b4f-84ca5037d356'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-jaguars-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-gambeta-fc' AND ht.source_system_id = 2
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
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '142e1c8d-7c12-4639-a5e9-4070a0921096'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-south-shore-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-somerville-united-fc-ii' AND ht.source_system_id = 2
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
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2eb57186-388d-4850-b6be-f2248fdd8993'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-somerville-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-jaguars-united-fc' AND ht.source_system_id = 2
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
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '2b164a9b-5ced-4f98-8964-b02c259e4130'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-bcfc-all-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-south-shore-fc' AND ht.source_system_id = 2
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
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '264ea405-c94d-4e5a-8ef0-b070dab81c13'
FROM teams ht
JOIN teams at ON at.external_id = '9090891-flatley-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090891-strictly-nos-fc' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '7a9784a3-81ca-44fc-a6f6-ca5872cf5c87'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, '0f2e56e5-12f5-4284-bb4e-438071cfb670'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, '645c2f75-488c-4a7b-ada8-9c3d00d5c3b9'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2025-09-14', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '0ac6aa74-e137-49a5-bddf-2672ad639b49'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2025-09-20', NULL, 3,
  ht.id, at.id, NULL,
  1, 6,
  2, '717ee722-12c4-41ed-ac18-834678f3ee41'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  2, 0,
  2, '82f8e4f2-05d6-4d0a-9fbc-f805b23a74d7'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  2, 2,
  2, '5ebd8799-9caa-4a96-8f9e-591780512d43'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, 2,
  2, '769cd0d9-ed17-4547-96a4-11b128a738a8'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  2, 3,
  2, 'ce6df7ba-1535-463d-89c0-f5c305d1b45c'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  0, 6,
  2, 'ad6795be-a39e-47ab-908a-ada58dd5d6e1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  3, 4,
  2, '5022ebd9-0755-4173-9427-9c02fe086df4'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2025-10-15', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '4089eaac-b5d8-4f6a-937e-331753f9f166'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2025-10-19', NULL, 3,
  ht.id, at.id, NULL,
  0, 0,
  2, 'd2f9a55f-f205-41b6-9ec7-2c1a12db05ed'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  1, '2025-10-19', NULL, 3,
  ht.id, at.id, NULL,
  1, 1,
  2, '1386477d-2f34-4e54-9ce6-2187df1192c8'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2025-10-26', NULL, 3,
  ht.id, at.id, NULL,
  3, 2,
  2, '13d29fff-0e35-4145-a03a-515d7699671c'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2025-10-26', NULL, 3,
  ht.id, at.id, NULL,
  2, 3,
  2, 'f9d52741-ecb8-4f43-a524-f0e1d656dae7'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, 'a6523b61-91d7-4f66-9164-c98d378718c1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  1, 0,
  2, '89131c08-e034-46b4-b447-80abbb52d48a'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  3, 0,
  2, '0a30179e-8217-447e-92db-77ab55d3de3c'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  3, 2,
  2, '8fdb51aa-c13b-43fd-9657-f3b15e7b28bc'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  3, 0,
  2, '01d4dd60-dd5f-4e4d-8f3b-908604951396'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  0, 3,
  2, 'b5527e91-452f-4f12-8cf4-c259251f7cfa'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2026-03-02', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '6ce2b3f4-1e72-49d1-9410-b9cd1899accf'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-lancaster-bible-college' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2026-03-07', NULL, 3,
  ht.id, at.id, NULL,
  5, 2,
  2, 'f9faf11a-6938-4563-8f53-136efc294f57'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  2, 1,
  2, 'a6374cb1-0895-4f3b-9d92-7eb17bb3e713'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-yorkpa-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2026-03-14', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'bf0f4bc9-0e29-4ec0-987c-618891490000'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '1011f11d-985a-4b1c-bbb2-84dbe119f855'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-yorkpa-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  1, '2026-03-21', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '12239797-ef2c-4e55-9291-7e1040bf04a1'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-lancaster-bible-college' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f3302399-f480-4343-abd9-10621ef3b12e'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-millersville-men''s-club-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '6b238965-bc43-4c60-be51-e556b1ea0371'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9aa26d15-9e56-48fc-976b-576dba695454'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2026-04-04', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '7018b701-2c80-419b-a850-74ff6d36faea'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-west-chester-university-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9191ae8c-984a-425e-afc7-cdb348f52f5f'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2026-04-11', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '8f281dfd-83d5-42ac-954f-52d0c2983d32'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0b602b05-f408-4018-a519-a2c8fc07aa75'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9fdc1a0a-0e36-4ea4-980c-9e7719796785'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2026-04-16', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ff8b2f9f-7a1e-4ec8-9e49-0e3887786da1'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-millersville-men''s-club-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-18', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '8a0867f0-4d81-489d-8401-46a93ea02978'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-alloy-soccer-club-reserves' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '411d026a-403e-4567-a619-480fc6301b31'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '19a7e38d-9d84-42d0-bca4-ad1951230fd9'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9ec32619-41ad-43a8-970f-b1e65ba5d370'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-keystone-elite' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ecc25592-d58d-4c44-9b8f-6893143aa01b'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-west-chester-university-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'af416431-dada-4544-a356-4b36208d57d2'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
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
  2, '7871174c-e524-4865-80e1-fb69b62b3dc3'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-kutztown-men''s-soccer' AND ht.source_system_id = 2
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
  3, 0,
  2, 'face7315-9548-4d3f-91c4-8f8bdf930d8b'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-west-chester-university-club' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-millersville-men''s-club-soccer' AND ht.source_system_id = 2
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
  1, '2026-03-02', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '6ac32a81-68b3-49cf-9094-98dfb9c3b385'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-keystone-elite' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-lancaster-bible-college' AND ht.source_system_id = 2
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
  1, '2026-03-08', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, 'de47f2a0-e141-469b-8768-24da5135ae36'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-yorkpa-fc' AND ht.source_system_id = 2
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '3d97e3b6-ab54-4596-b947-3bc02c3b2b5a'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-lancaster-city-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-yorkpa-fc' AND ht.source_system_id = 2
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
  1, '2026-03-18', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'cae1c03d-bbb7-406f-9176-d0c8b691fc30'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-yorkpa-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-lancaster-bible-college' AND ht.source_system_id = 2
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
  1, '2026-03-21', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '3d76341a-9b65-41c7-a09e-7fee4deefa41'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-alloy-soccer-club-reserves' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-lancaster-bible-college' AND ht.source_system_id = 2
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
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '677181c1-7791-4eaf-8fc4-1ff08b38f5fb'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-yorkpa-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-west-chester-university-club' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0330a870-cf4b-4129-b2ea-3273ca18dfb0'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-west-chester-university-club' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-lancaster-bible-college' AND ht.source_system_id = 2
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'bc0b95d4-daa8-4790-a1bd-a8a7cfb7607d'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-millersville-men''s-club-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-yorkpa-fc' AND ht.source_system_id = 2
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
  1, '2026-04-04', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '63741a6f-2813-49fe-95f8-4ba726e59307'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-west-chester-university-club' AND ht.source_system_id = 2
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
  1, '2026-04-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '936ce5ab-abbb-4fbf-b268-0ef05fd0cc69'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-millersville-men''s-club-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-lancaster-bible-college' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'db180893-fbd0-4e68-a79f-2e4ded2d3f8d'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-millersville-men''s-club-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-west-chester-university-club' AND ht.source_system_id = 2
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
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ad697c65-8457-4487-9c67-2a0287c06ed8'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-lancaster-bible-college' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-yorkpa-fc' AND ht.source_system_id = 2
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
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'b67dd2d0-4bc2-4ba7-aa08-e0b2501af2ec'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-west-chester-university-club' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-yorkpa-fc' AND ht.source_system_id = 2
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
  1, '2026-04-23', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '847d3602-b591-4dd5-bd1b-c5bea28fcf09'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-lancaster-bible-college' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-millersville-men''s-club-soccer' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '53a76191-20ae-42d4-b92a-2cc654dfbba8'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-west-chester-university-club' AND ht.source_system_id = 2
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ad8390c4-4a56-45ea-891c-eb4b61a8ceb0'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-yorkpa-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-millersville-men''s-club-soccer' AND ht.source_system_id = 2
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
  2, '5d83d3af-9274-43c5-b6be-8fb61e2f1b07'
FROM teams ht
JOIN teams at ON at.external_id = '9270318-lancaster-bible-college' AND at.source_system_id = 2
WHERE ht.external_id = '9270318-west-chester-university-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time;

