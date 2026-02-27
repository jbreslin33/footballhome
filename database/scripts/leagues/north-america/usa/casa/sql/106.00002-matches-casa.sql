-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 179
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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', NULL, 3,
  ht.id, at.id, NULL,
  5, 0,
  2, '0a2bf975-e9e1-4169-956d-df9f170938d4'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-adé-united-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, 'e5e823fc-3a6b-41ee-b965-70efeb1e03b7'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  1, 9,
  2, 'f1ee6819-519b-40a9-9c60-6e2f0f8eed9b'
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
  1, '2025-11-06', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, '349116fd-0244-49a9-b863-22e4a612abe0'
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
  1, '2025-11-06', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '547f5b1b-0eda-4659-b1c8-9925dde33a44'
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
  1, '2025-11-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, 'fc780790-8e02-44fc-855a-cde65a0f24d4'
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, '804316a8-f57a-4351-878e-a582b8647d46'
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '7d71e9e0-2d66-44a8-a6c8-ba94a77e8d6a'
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
  2, 'f205f1e1-339e-4552-a5b9-14b6e661811a'
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  1, 3,
  2, 'a626ab3c-f16e-47d0-8f62-97e988d205ed'
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
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  6, 3,
  2, '94b4c1b4-8f70-4373-8cdb-f2217950a044'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '97f6cb8b-e96c-40c8-908c-7811c25bdefd'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '150ab0ff-9a95-42fc-92ab-dea7d680ec59'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f394c026-6768-41bc-8c1c-4935589024e3'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '0b81a198-cc66-439e-99b0-d2cbfe130cab'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'be9a0154-1a39-4637-adae-fe53324c9c50'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9d780e42-fb7e-4aae-b828-ea635ea28f62'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'd0f75702-a4c5-4c74-af9c-53a7cdb26140'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '8184478a-5e8c-4fa5-9624-623616fd23ce'
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
  1, '2026-03-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '3dd63458-c9d3-4483-ba57-d36987284bc1'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philly-blackstars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-philadelphia-sierra-stars' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'bb5b99db-cc7f-412a-a89b-448969a627d5'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '171f7db4-1f3b-429d-9320-9d156fc1bd5f'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-illyrians-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-illyrians-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '02e8b919-f787-4e2b-a5f8-693cc6f9156d'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-phoenix-scm' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9090889-persepolis-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', NULL, 3,
  ht.id, at.id, NULL,
  0, 8,
  2, '4ae7d921-eb35-4bd5-973d-4542c5c9caf0'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', NULL, 3,
  ht.id, at.id, NULL,
  0, 3,
  2, '03728c1d-369d-4ed4-af53-f54f0993d190'
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
  1, '2025-10-12', NULL, 3,
  ht.id, at.id, NULL,
  8, 0,
  2, 'd4060108-b706-4f5f-a165-8a93b1d36f75'
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
  1, '2025-10-12', NULL, 3,
  ht.id, at.id, NULL,
  2, 2,
  2, '50c7a4a7-b9dd-45fa-8573-c5b746b466ed'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philly-blackstars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9090889-persepolis-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-07', NULL, 3,
  ht.id, at.id, NULL,
  0, 1,
  2, 'c669eaa9-ad23-4238-b970-2d7d8ed38677'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-oaklyn-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'd39f4e00-03cc-49e8-87c1-d1821fbb098e'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '350f8806-0194-40a3-b301-98c2c835e3ea'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'da1a7639-30b9-4b55-82aa-2684619ea5fd'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'aa2f28dc-4754-4fa7-a063-5c66652a0789'
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '90e6d273-4df2-4d40-99fe-b60f597f9e71'
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
  1, '2026-03-15', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '06b972a1-c5ad-4dda-b1f5-e2ef609f3fab'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-lighthouse-boys-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9090889-oaklyn-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '83bcb6e5-d194-41c0-b086-eb7bbd3b312c'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-philadelphia-sierra-stars' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
JOIN teams at ON at.external_id = '9096430-lighthouse-old-timers-club' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '13e4df9f-34bc-40f4-9bce-745b23d44792'
FROM teams ht
JOIN teams at ON at.external_id = '9090889-adé-united-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-philadelphia-sc-select' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9cad47d5-989d-46e9-8f0b-4756ad2453db'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-sewell''s-old-boys' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'b5fd9494-8191-44d5-8489-b0c85bdc7acb'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-phoenix-scr' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '631ed140-a881-4ed6-8fb1-87e6b9dd6f66'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-philadelphia-sc-select' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'ecb165b3-a21f-47df-ad53-4762827218aa'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
WHERE ht.external_id = '9096430-lighthouse-old-timers-club' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-07', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '517440d7-7ccd-41b5-9a0a-36770b26fde6'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-phoenix-scr' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-persepolis-united-fc-ii' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '72f6c967-4006-49ff-85d6-56810c81877a'
FROM teams ht
JOIN teams at ON at.external_id = '9096430-persepolis-united-fc-ii' AND at.source_system_id = 2
WHERE ht.external_id = '9096430-sewell''s-old-boys' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'b7f1beb8-d18f-4c05-be3a-ee9ec3b5550f'
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
  1, '2025-09-07', NULL, 3,
  ht.id, at.id, NULL,
  3, 0,
  2, '7a9784a3-81ca-44fc-a6f6-ca5872cf5c87'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-f&m-fc' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-lancaster-city-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '01d4dd60-dd5f-4e4d-8f3b-908604951396'
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
  1, '2026-03-01', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'b5527e91-452f-4f12-8cf4-c259251f7cfa'
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
  1, '2026-03-07', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'f9faf11a-6938-4563-8f53-136efc294f57'
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
  1, '2026-03-08', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '9ec32619-41ad-43a8-970f-b1e65ba5d370'
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
  1, '2026-03-14', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, 'bf0f4bc9-0e29-4ec0-987c-618891490000'
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
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  2, '6b238965-bc43-4c60-be51-e556b1ea0371'
FROM teams ht
JOIN teams at ON at.external_id = '9090893-kutztown-men''s-soccer' AND at.source_system_id = 2
WHERE ht.external_id = '9090893-f&m-fc' AND ht.source_system_id = 2
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

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
ON CONFLICT (source_system_id, external_id) DO NOTHING;

