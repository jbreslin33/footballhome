-- CASA Match Schedule
-- Generated at: 2025-12-17T15:25:10.758Z

INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '1658ed76-d6bb-41cb-8830-765ae5f59be7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Illyrians FC vs Lighthouse Boys Club',
  NULL,
  'Sun Nov 9 3:00 PM EST - 4:45 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:26.975Z',
  '2025-12-17T15:24:26.975Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1658ed76-d6bb-41cb-8830-765ae5f59be7',
  '7bf6867b-ae73-42ee-82dc-ce4b3502b828',
  'de13b049-e584-4672-84e3-a24668a88c57',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  'da2d5656-7a28-46aa-8954-3a8a70dae71e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC II vs Adé United FC',
  NULL,
  'Thu Nov 6 8:45 PM EST - 10:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.875Z',
  '2025-12-17T15:24:34.875Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'da2d5656-7a28-46aa-8954-3a8a70dae71e',
  '3bf9c8b4-1edf-42d6-8b8f-63d248c1ea92',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '4bc287fd-8011-49c7-892a-6e5260afbcf1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Adé United FC vs Adé United FC',
  NULL,
  'Wed Nov 5 8:45 PM EST - 10:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:26.975Z',
  '2025-12-17T15:24:26.975Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4bc287fd-8011-49c7-892a-6e5260afbcf1',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '2f423ad3-cd06-4df1-839c-c1d3622431a7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis FC vs Lighthouse Old Timers Club',
  NULL,
  'Sun Nov 2 3:00 PM EST - 4:45 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.876Z',
  '2025-12-17T15:24:34.876Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2f423ad3-cd06-4df1-839c-c1d3622431a7',
  '79571455-9a4b-4e3e-8a40-bc5fefa21a1c',
  'cbb53b2c-26ce-488f-8c6f-3c589fadddbe',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '2604af3e-028c-41a8-86cc-2f595cb5307e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Lighthouse Old Timers Club',
  NULL,
  'Sun Nov 16 1:30 PM EST - 3:15 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.875Z',
  '2025-12-17T15:24:34.875Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2604af3e-028c-41a8-86cc-2f595cb5307e',
  '7b5fcaec-c079-4132-8087-de29ad6ff2db',
  'cbb53b2c-26ce-488f-8c6f-3c589fadddbe',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '043de65a-a142-4756-8632-8c201c97288f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis FC vs Phoenix SCM',
  NULL,
  'Sun Nov 9 11:45 AM EST - 1:15 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.875Z',
  '2025-12-17T15:24:34.875Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '043de65a-a142-4756-8632-8c201c97288f',
  '79571455-9a4b-4e3e-8a40-bc5fefa21a1c',
  '7b5fcaec-c079-4132-8087-de29ad6ff2db',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '82844a34-fda6-4bfe-80a6-835d7f5d9b55',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis FC vs Adé United FC',
  NULL,
  'Thu Oct 30 8:45 PM EDT - 10:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.876Z',
  '2025-12-17T15:24:34.876Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '82844a34-fda6-4bfe-80a6-835d7f5d9b55',
  '79571455-9a4b-4e3e-8a40-bc5fefa21a1c',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  'f7fc03c0-7393-4d59-8db5-3e090ff67792',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Illyrians FC',
  NULL,
  'Wed Oct 29 7:30 PM EDT - 9:15 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.876Z',
  '2025-12-17T15:24:34.876Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f7fc03c0-7393-4d59-8db5-3e090ff67792',
  '7b5fcaec-c079-4132-8087-de29ad6ff2db',
  '7bf6867b-ae73-42ee-82dc-ce4b3502b828',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '76dd00e8-6606-4127-8802-d60971ad0e68',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Adé United FC vs Adé United FC',
  NULL,
  'Sun Oct 12 2:45 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T15:24:34.876Z',
  '2025-12-17T15:24:34.876Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '76dd00e8-6606-4127-8802-d60971ad0e68',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
