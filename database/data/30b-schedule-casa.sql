-- CASA Match Schedule
-- Generated at: 2025-12-17T23:37:09.742Z

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
  '2025-12-17T23:35:38.444Z',
  '2025-12-17T23:35:38.444Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1658ed76-d6bb-41cb-8830-765ae5f59be7',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
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
  '2025-12-17T23:36:13.248Z',
  '2025-12-17T23:36:13.248Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'da2d5656-7a28-46aa-8954-3a8a70dae71e',
  '158e321e-2dd5-4926-82ce-c31822bde965',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
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
  '2025-12-17T23:35:38.444Z',
  '2025-12-17T23:35:38.444Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4bc287fd-8011-49c7-892a-6e5260afbcf1',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
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
  '2025-12-17T23:36:13.247Z',
  '2025-12-17T23:36:13.247Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2604af3e-028c-41a8-86cc-2f595cb5307e',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
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
  '2025-12-17T23:36:13.247Z',
  '2025-12-17T23:36:13.247Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '043de65a-a142-4756-8632-8c201c97288f',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'aad58707-7310-4751-86c5-e403a28757f4',
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
  '2025-12-17T23:36:13.248Z',
  '2025-12-17T23:36:13.248Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2f423ad3-cd06-4df1-839c-c1d3622431a7',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
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
  '2025-12-17T23:36:13.249Z',
  '2025-12-17T23:36:13.249Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '82844a34-fda6-4bfe-80a6-835d7f5d9b55',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
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
  '2025-12-17T23:36:13.249Z',
  '2025-12-17T23:36:13.249Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f7fc03c0-7393-4d59-8db5-3e090ff67792',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
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
  '2e7ef834-0565-4dc2-8789-f2a99acc4821',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Old Timers Club vs Persepolis FC',
  NULL,
  'Sun Oct 12 2:45 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:13.249Z',
  '2025-12-17T23:36:13.249Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2e7ef834-0565-4dc2-8789-f2a99acc4821',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
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
  '2513e617-6742-4dc5-80b3-6a0357c5adcc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs F&M FC',
  NULL,
  'Sun Nov 9 1:00 PM EST - 2:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.245Z',
  '2025-12-17T23:36:51.245Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2513e617-6742-4dc5-80b3-6a0357c5adcc',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
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
  '431d2eef-b565-4311-870c-e8c99c02c9ef',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Kutztown Men''s Soccer vs Alloy Soccer Club Reserves',
  NULL,
  'Sun Nov 2 6:00 PM EST - 7:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.245Z',
  '2025-12-17T23:36:51.245Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '431d2eef-b565-4311-870c-e8c99c02c9ef',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
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
  'd19c9db0-c7cc-4f34-8bbd-519f9b3b1f2c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs Keystone Elite',
  NULL,
  'Sun Oct 26 3:00 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.246Z',
  '2025-12-17T23:36:51.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd19c9db0-c7cc-4f34-8bbd-519f9b3b1f2c',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
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
  'e0ef9903-f1a4-491e-8631-cb90cd2dfc3d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs Lancaster City FC',
  NULL,
  'Sun Oct 19 4:00 PM EDT - 5:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.246Z',
  '2025-12-17T23:36:51.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e0ef9903-f1a4-491e-8631-cb90cd2dfc3d',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
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
  '51cb3649-9a00-4cb2-8036-cf7535f6b41e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'F&M FC vs Alloy Soccer Club Reserves',
  NULL,
  'Wed Oct 15 7:00 PM EDT - 8:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.247Z',
  '2025-12-17T23:36:51.247Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '51cb3649-9a00-4cb2-8036-cf7535f6b41e',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
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
  'aab295a9-5fe3-407b-87eb-17ec63b65b8b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs Keystone Elite',
  NULL,
  'Sun Oct 12 3:00 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:36:51.247Z',
  '2025-12-17T23:36:51.247Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'aab295a9-5fe3-407b-87eb-17ec63b65b8b',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
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
  '69e5a862-fb03-426a-8b0b-a37c19a5bbd5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'FeelsGood FC vs FeelsGood FC',
  NULL,
  'Sun Dec 7 10:00 AM EST - 12:00 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.320Z',
  '2025-12-17T23:37:06.320Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '69e5a862-fb03-426a-8b0b-a37c19a5bbd5',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
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
  '017e5474-28fb-4eb2-88cb-505fcda0ee3f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'FeelsGood FC vs FeelsGood FC',
  NULL,
  'Sun Nov 23 1:00 PM EST - 3:00 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.320Z',
  '2025-12-17T23:37:06.320Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '017e5474-28fb-4eb2-88cb-505fcda0ee3f',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
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
  '636e25c9-ab26-4584-8697-5eb60cf5ee1e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Rondo Football Club vs Jersey Shore Boca Reserves',
  NULL,
  'Sun Nov 16 1:00 PM EST - 3:00 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.321Z',
  '2025-12-17T23:37:06.321Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '636e25c9-ab26-4584-8697-5eb60cf5ee1e',
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
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
  'a61d7d58-145b-4934-8a2e-e624efdd7181',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Milan Football Club vs Jersey Shore Boca Reserves',
  NULL,
  'Sun Nov 9 6:30 PM EST - 8:00 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.321Z',
  '2025-12-17T23:37:06.321Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a61d7d58-145b-4934-8a2e-e624efdd7181',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
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
  '0987f84e-fdf2-4a98-8b07-4f26e7048eea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Milan Football Club vs FeelsGood FC',
  NULL,
  'Sat Nov 8 10:00 AM EST - 11:30 AM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.322Z',
  '2025-12-17T23:37:06.322Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0987f84e-fdf2-4a98-8b07-4f26e7048eea',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
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
  '3849adb0-90ef-45a8-8751-f9ab001cc0a1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca Reserves vs Princeton International FC',
  NULL,
  'Wed Nov 5 8:30 PM EST - 10:00 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.322Z',
  '2025-12-17T23:37:06.322Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3849adb0-90ef-45a8-8751-f9ab001cc0a1',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  '7708a49e-8512-43b2-8b85-13e98a4af318',
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
  '4d3587bb-c481-4be1-8892-a2ef11a0c0d6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ II vs Alaso FC',
  NULL,
  'Sun Nov 2 7:00 PM EST - 8:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T23:37:06.323Z',
  '2025-12-17T23:37:06.323Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4d3587bb-c481-4be1-8892-a2ef11a0c0d6',
  'bb5768e2-fac3-42e0-8d07-f18a63fb2278',
  'dda012cd-f081-48df-8903-d997d9fa6f96',
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
