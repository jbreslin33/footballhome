-- CASA Match Schedule
-- Generated at: 2025-12-16T14:01:56.750Z

INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '1658ed76-d6bb-41cb-8830-765ae5f59be7',
  'Illyrians FC vs Lighthouse Boys Club',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sun Nov 9 3:00 PM EST - 4:45 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:48.805Z',
  '2025-12-16T14:01:48.805Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1658ed76-d6bb-41cb-8830-765ae5f59be7',
  '6c9e49e0-1101-40bb-83fd-0f4a45f59d80',
  '0ba654a6-3f06-4b64-8ff4-d988bc8aed4d',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  'da2d5656-7a28-46aa-8954-3a8a70dae71e',
  'Oaklyn United FC II vs Adé United FC',
  '550e8400-e29b-41d4-a716-446655440402',
  'Thu Nov 6 8:45 PM EST - 10:30 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.731Z',
  '2025-12-16T14:01:56.731Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'da2d5656-7a28-46aa-8954-3a8a70dae71e',
  'c6d0a80d-bbd1-4506-83ed-271f6efab6d7',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '4bc287fd-8011-49c7-892a-6e5260afbcf1',
  'Adé United FC vs Adé United FC',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wed Nov 5 8:45 PM EST - 10:30 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:48.805Z',
  '2025-12-16T14:01:48.805Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4bc287fd-8011-49c7-892a-6e5260afbcf1',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '2f423ad3-cd06-4df1-839c-c1d3622431a7',
  'Persepolis FC vs Lighthouse Old Timers Club',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sun Nov 2 3:00 PM EST - 4:45 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.731Z',
  '2025-12-16T14:01:56.731Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2f423ad3-cd06-4df1-839c-c1d3622431a7',
  '2cc098cc-4723-4cbe-8892-4013b8d8da6a',
  '40b68e65-765b-4ed3-88d8-5629903f1060',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '2604af3e-028c-41a8-86cc-2f595cb5307e',
  'Phoenix SCM vs Lighthouse Old Timers Club',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sun Nov 16 1:30 PM EST - 3:15 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.730Z',
  '2025-12-16T14:01:56.730Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2604af3e-028c-41a8-86cc-2f595cb5307e',
  '973cfd4d-e110-40f6-8bd4-8a730f7e5ca6',
  '40b68e65-765b-4ed3-88d8-5629903f1060',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '043de65a-a142-4756-8632-8c201c97288f',
  'Persepolis FC vs Phoenix SCM',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sun Nov 9 11:45 AM EST - 1:15 PM EST',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.731Z',
  '2025-12-16T14:01:56.731Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '043de65a-a142-4756-8632-8c201c97288f',
  '2cc098cc-4723-4cbe-8892-4013b8d8da6a',
  '973cfd4d-e110-40f6-8bd4-8a730f7e5ca6',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '82844a34-fda6-4bfe-80a6-835d7f5d9b55',
  'Persepolis FC vs Adé United FC',
  '550e8400-e29b-41d4-a716-446655440402',
  'Thu Oct 30 8:45 PM EDT - 10:30 PM EDT',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.732Z',
  '2025-12-16T14:01:56.732Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '82844a34-fda6-4bfe-80a6-835d7f5d9b55',
  '2cc098cc-4723-4cbe-8892-4013b8d8da6a',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  'f7fc03c0-7393-4d59-8db5-3e090ff67792',
  'Phoenix SCM vs Illyrians FC',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wed Oct 29 7:30 PM EDT - 9:15 PM EDT',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.732Z',
  '2025-12-16T14:01:56.732Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f7fc03c0-7393-4d59-8db5-3e090ff67792',
  '973cfd4d-e110-40f6-8bd4-8a730f7e5ca6',
  '6c9e49e0-1101-40bb-83fd-0f4a45f59d80',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '76dd00e8-6606-4127-8802-d60971ad0e68',
  'Adé United FC vs Adé United FC',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sun Oct 12 2:45 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'casa',
  NULL,
  true,
  '2025-12-16T14:01:56.733Z',
  '2025-12-16T14:01:56.733Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '76dd00e8-6606-4127-8802-d60971ad0e68',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
