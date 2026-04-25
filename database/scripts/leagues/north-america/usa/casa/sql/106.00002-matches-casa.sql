-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: 35
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
  1, '2025-09-28', NULL, 3,
  ht.id, at.id, NULL,
  5, 0,
  2, '0a2bf975-e9e1-4169-956d-df9f170938d4'
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
  1, '2025-10-05', NULL, 3,
  ht.id, at.id, NULL,
  2, 0,
  2, 'e5e823fc-3a6b-41ee-b965-70efeb1e03b7'
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
  1, 9,
  2, 'f1ee6819-519b-40a9-9c60-6e2f0f8eed9b'
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
  2, '804316a8-f57a-4351-878e-a582b8647d46'
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
  1, '2026-03-15', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
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
  1, '2026-03-22', NULL, 3,
  ht.id, at.id, NULL,
  1, 1,
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
  1, '2026-03-22', NULL, 3,
  ht.id, at.id, NULL,
  8, 0,
  2, '62294e19-4b8a-481b-bcf5-6e4f80baa542'
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
  1, '2026-03-29', NULL, 3,
  ht.id, at.id, NULL,
  1, 3,
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
  1, '2026-04-12', NULL, 3,
  ht.id, at.id, NULL,
  5, 2,
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
  1, '2026-04-12', NULL, 3,
  ht.id, at.id, NULL,
  1, 4,
  2, 'bb5b99db-cc7f-412a-a89b-448969a627d5'
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
  1, '2026-04-19', NULL, 3,
  ht.id, at.id, NULL,
  4, 2,
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
  1, '2026-04-19', NULL, 3,
  ht.id, at.id, NULL,
  1, 6,
  2, '171f7db4-1f3b-429d-9320-9d156fc1bd5f'
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
  1, '2026-04-23', NULL, 3,
  ht.id, at.id, NULL,
  1, 2,
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
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
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

