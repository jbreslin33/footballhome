-- CASA Match Schedule

INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '62d30cd4-fb69-4a97-84bd-0e506564c188',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Boys Club vs Illyrians FC',
  NULL,
  '2025-11-09 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '62d30cd4-fb69-4a97-84bd-0e506564c188',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8511cf4c-39e1-4b9d-9100-be82b752629c', '62d30cd4-fb69-4a97-84bd-0e506564c188', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('783959f5-aee3-453f-8ed8-7026e7fc91d4', '62d30cd4-fb69-4a97-84bd-0e506564c188', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2537da99-8f86-4c23-81f7-b0ea2621bb05',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Oaklyn United FC II',
  NULL,
  '2025-11-09 19:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2537da99-8f86-4c23-81f7-b0ea2621bb05',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '158e321e-2dd5-4926-82ce-c31822bde965',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3ddb90f2-6b39-4d09-92a2-f39a540113db', '2537da99-8f86-4c23-81f7-b0ea2621bb05', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('ee246e15-7a43-4abf-a1ef-dfbc225109c4', '2537da99-8f86-4c23-81f7-b0ea2621bb05', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '49f8304b-9d17-4990-82c5-c29a7fa32ac5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Sierra Stars vs Adé United FC',
  NULL,
  '2025-11-09 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '49f8304b-9d17-4990-82c5-c29a7fa32ac5',
  '3a2468dd-a31c-456a-88a9-fe7699d2b079',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bc494c14-5a2b-499a-8b03-83563f5349e2', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('527ac75a-c0f5-4c2e-8588-2044aef9d67b', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4d734c38-ec21-47a9-8b6a-1e8395f2afc1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix Reserves vs Persepolis FC',
  NULL,
  '2025-11-09 16:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4d734c38-ec21-47a9-8b6a-1e8395f2afc1',
  NULL,
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d29750aa-9700-45e1-b98b-44d23809fea0', '4d734c38-ec21-47a9-8b6a-1e8395f2afc1', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a2da5631-8d20-47c6-8c65-e39aa953fd8c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Old Timers Club vs Philly BlackStars',
  NULL,
  '2025-11-09 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a2da5631-8d20-47c6-8c65-e39aa953fd8c',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('17397dd4-32bd-4c57-a505-c27c2c068517', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('5a655b19-a5d5-4c60-bdf5-a84b60504950', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4d524c17-9d79-4153-8a04-7aeab379e450',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Oaklyn United FC II',
  NULL,
  '2025-11-07 01:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4d524c17-9d79-4153-8a04-7aeab379e450',
  NULL,
  '158e321e-2dd5-4926-82ce-c31822bde965',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b04d4e13-030e-42a6-bf23-6ba8da041f2b', '4d524c17-9d79-4153-8a04-7aeab379e450', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '83d619c8-bca1-42a1-8b4f-096d80083a5c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Illyrians FC vs Adé United FC',
  NULL,
  '2025-11-07 00:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '83d619c8-bca1-42a1-8b4f-096d80083a5c',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ac96934f-09a1-46a3-aad2-d5bb4aed6af7', '83d619c8-bca1-42a1-8b4f-096d80083a5c', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('443faefb-fdf2-4b9f-b765-76bc04535b02', '83d619c8-bca1-42a1-8b4f-096d80083a5c', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fc19745e-b7ac-4b64-8731-a256613e1534',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Sierra Stars vs Philly BlackStars',
  NULL,
  '2025-11-06 01:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fc19745e-b7ac-4b64-8731-a256613e1534',
  '3a2468dd-a31c-456a-88a9-fe7699d2b079',
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d0ca4e20-4dbf-47a5-acb6-9409e8ab66e8', 'fc19745e-b7ac-4b64-8731-a256613e1534', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('a95e1702-29fc-433f-ad8e-21f59b5d0029', 'fc19745e-b7ac-4b64-8731-a256613e1534', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'eca34b29-7579-4b19-8833-5f5acf847b86',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Persepolis FC',
  NULL,
  '2025-11-06 01:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'eca34b29-7579-4b19-8833-5f5acf847b86',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('314d3bf2-fe24-4f58-8a97-a84eb22d917c', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('c2df5d87-1642-4db4-a9a3-c2385f62fea2', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd21597c2-6129-466a-8e93-2ac187d2fd9e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Old Timers Club vs Persepolis FC',
  NULL,
  '2025-11-02 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd21597c2-6129-466a-8e93-2ac187d2fd9e',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e31a6d2c-65c9-489e-97cf-661938f0ffd5', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('ad4aebd0-0454-4ad4-8d73-becabda6c6ee', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3a2d7ecc-fa9b-4169-874b-72b07ddf204f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philly BlackStars vs Illyrians FC',
  NULL,
  '2025-09-07 16:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3a2d7ecc-fa9b-4169-874b-72b07ddf204f',
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fe842cfb-617b-470d-9371-6ec516ff045d', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701'),
  ('9ded5b37-69e4-4e91-80b0-e3c90d6e5904', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3ad04f53-81ed-43b8-8b7e-fc544d239d67',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Boys Club vs Oaklyn United FC II',
  NULL,
  '2025-09-07 17:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3ad04f53-81ed-43b8-8b7e-fc544d239d67',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  '158e321e-2dd5-4926-82ce-c31822bde965',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8bb6fd78-7ce8-4e69-9ec0-6d4d50879bf2', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('196394e1-cd46-4858-b921-264176274178', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a652c999-a49e-4a94-8cd9-1d098cf426f9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Adé United FC',
  NULL,
  '2025-09-07 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a652c999-a49e-4a94-8cd9-1d098cf426f9',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('70fc2cad-431d-40b3-b023-e74d9e88854a', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('7c902b37-1b22-47c4-9d95-0ae63b2b676d', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8165bc74-cfe4-495b-86e4-86702b0dbf41',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Sierra Stars vs Persepolis FC',
  NULL,
  '2025-09-07 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8165bc74-cfe4-495b-86e4-86702b0dbf41',
  '3a2468dd-a31c-456a-88a9-fe7699d2b079',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6746f8e9-41db-454f-ae5e-b4c2d129a037', '8165bc74-cfe4-495b-86e4-86702b0dbf41', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('51677725-bdc3-422f-835c-3367b5560e30', '8165bc74-cfe4-495b-86e4-86702b0dbf41', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2517d2fd-90c5-471a-84de-4f7d3ec058ec',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis FC vs Philly BlackStars',
  NULL,
  '2025-09-14 16:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2517d2fd-90c5-471a-84de-4f7d3ec058ec',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ade44114-cab0-4453-9efa-f2dea6ef6370', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('bc97b287-b6a1-4844-a6f9-79747f5d5738', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '91a9c8b7-406d-41de-8df6-8607f59396cf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC II vs Adé United FC',
  NULL,
  '2025-09-14 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '91a9c8b7-406d-41de-8df6-8607f59396cf',
  '158e321e-2dd5-4926-82ce-c31822bde965',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2479c3ae-03b9-43ae-80c2-78e176e877ee', '91a9c8b7-406d-41de-8df6-8607f59396cf', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701'),
  ('56637a2f-c3ca-477e-8d48-8ce9f420cbcf', '91a9c8b7-406d-41de-8df6-8607f59396cf', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '52f4814d-e1a3-468f-89bd-6e02155b6129',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Philadelphia SC II',
  NULL,
  '2025-09-14 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '52f4814d-e1a3-468f-89bd-6e02155b6129',
  'aad58707-7310-4751-86c5-e403a28757f4',
  NULL,
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f3aa3842-5576-4ddd-a521-b3718fd7f6e6', '52f4814d-e1a3-468f-89bd-6e02155b6129', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4705a186-2ec4-4a63-8c68-f2921e2bc16f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Illyrians FC vs Lighthouse Boys Club',
  NULL,
  '2025-09-14 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4705a186-2ec4-4a63-8c68-f2921e2bc16f',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('af4d0b39-3822-4028-88f1-2987f0ec5841', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('7bb2ee31-4729-4c23-aef2-3cd75494c9fc', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '55b1a2da-7521-4691-82ae-831d929ec711',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Adé United FC vs Illyrians FC',
  NULL,
  '2025-09-21 15:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '55b1a2da-7521-4691-82ae-831d929ec711',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6ff6038d-2459-4094-b64a-2f1c2535f3cf', '55b1a2da-7521-4691-82ae-831d929ec711', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('c76ddf06-db05-48a4-858b-ffd0741a6599', '55b1a2da-7521-4691-82ae-831d929ec711', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '34bb814d-67bc-489f-8c94-2198057fb592',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Boys Club vs Phoenix Reserves',
  NULL,
  '2025-09-21 15:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '34bb814d-67bc-489f-8c94-2198057fb592',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  NULL,
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('78a548dc-d8fc-4d53-9c3f-f1d3c33d9e7c', '34bb814d-67bc-489f-8c94-2198057fb592', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '69b364be-8f29-4a83-8fb9-69c70a476f67',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Old Timers Club vs Phoenix SCM',
  NULL,
  '2025-11-16 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '69b364be-8f29-4a83-8fb9-69c70a476f67',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ed04e3a-4a46-4758-9fd3-981d59004114', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('c356ad33-6910-4ec9-b9b3-9bf153b6a034', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '09e2955e-5f2f-441b-8fb0-d033f67dc791',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Persepolis FC',
  NULL,
  '2025-11-09 16:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '09e2955e-5f2f-441b-8fb0-d033f67dc791',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e46d86b8-8573-4e3e-a06d-5e3dc6da50c9', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('ebdc8aeb-788d-465b-8ceb-e392107dd805', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e082a5b2-71e3-474a-8256-16ce76e60795',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Oaklyn United Nor’Easters II',
  NULL,
  '2025-11-07 01:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e082a5b2-71e3-474a-8256-16ce76e60795',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  NULL,
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2d2c9d8f-1081-46ba-99a7-62a6fed21417', 'e082a5b2-71e3-474a-8256-16ce76e60795', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '91ebabec-ce77-47e8-832e-99263cba41e6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Phoenix SCM',
  NULL,
  '2025-11-02 19:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '91ebabec-ce77-47e8-832e-99263cba41e6',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b675fcff-6b46-4c95-a2fa-08dc4601cd5a', '91ebabec-ce77-47e8-832e-99263cba41e6', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('c73f0f63-2c6d-4256-a569-140770e73b65', '91ebabec-ce77-47e8-832e-99263cba41e6', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65ba7c5f-18c6-4fb1-8eca-963156acf6f3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Persepolis FC',
  NULL,
  '2025-10-31 00:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65ba7c5f-18c6-4fb1-8eca-963156acf6f3',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6d17452f-dbed-4f04-b9ad-fef418f543d7', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('a450c692-edb9-4d4b-9df5-22a2b1e1cf99', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'abcbff6c-c508-4198-86c6-d093e886f9d7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Illyrians FC vs Phoenix SCM',
  NULL,
  '2025-10-29 23:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'abcbff6c-c508-4198-86c6-d093e886f9d7',
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('12362b62-b4a6-4ff1-b07f-5ef02077ddea', 'abcbff6c-c508-4198-86c6-d093e886f9d7', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('1113c486-2d13-4a14-8a28-0995366e04ab', 'abcbff6c-c508-4198-86c6-d093e886f9d7', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'afafacd7-d142-4996-881f-cbade4ac2ca9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Philly BlackStars',
  NULL,
  '2025-10-12 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'afafacd7-d142-4996-881f-cbade4ac2ca9',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('50470c16-442d-4d6f-bb71-d27c29da46cb', 'afafacd7-d142-4996-881f-cbade4ac2ca9', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('d3f2ca2a-9291-4be3-aa5b-4b9641ecd115', 'afafacd7-d142-4996-881f-cbade4ac2ca9', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '81da90ed-f792-4c81-8f6b-4e74349bea1d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis FC vs Lighthouse Old Timers Club',
  NULL,
  '2025-10-12 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '81da90ed-f792-4c81-8f6b-4e74349bea1d',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('68737c10-7136-4abe-8552-02cfd5f97a93', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('0996d79d-bb1a-4ac5-bcb9-9773fb124cad', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1ef4683f-b4d8-41d6-8c35-21df11a48cff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Philadelphia SC II',
  NULL,
  '2025-09-07 16:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1ef4683f-b4d8-41d6-8c35-21df11a48cff',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a8c4b69a-292b-4999-98b8-61a36b54d170', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('1c7adf1a-960a-424f-aab0-8310e7718616', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65f7a58b-d5f2-4aff-842b-49089f156b53',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Lighthouse Old Timers Club',
  NULL,
  '2025-09-14 16:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65f7a58b-d5f2-4aff-842b-49089f156b53',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d1c8b229-9e4d-4a60-af61-63ae3d4b16b8', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('5171235d-9094-4280-89cb-309b1741a610', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd5e6fbec-5173-4a03-83ad-97f5620f579e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Phoenix Majors',
  NULL,
  '2025-09-14 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd5e6fbec-5173-4a03-83ad-97f5620f579e',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  NULL,
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8bfa64aa-9880-44d5-9a24-fb9bc23554ce', 'd5e6fbec-5173-4a03-83ad-97f5620f579e', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1a769bff-9ff3-447b-85c7-d57d62d5dcfd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Boys Club vs Phoenix SCM',
  NULL,
  '2025-09-21 15:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1a769bff-9ff3-447b-85c7-d57d62d5dcfd',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  'aad58707-7310-4751-86c5-e403a28757f4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('369ed456-61bf-4a8f-b830-b3390e0a3692', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('b20b74e6-76c9-485a-921f-eabc2c549b74', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9885c815-fde9-407e-861c-06510f86d8df',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Lighthouse Old Timers Club',
  NULL,
  '2025-09-21 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9885c815-fde9-407e-861c-06510f86d8df',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5b5acad0-b9c7-479e-98bb-0c680eacd134', '9885c815-fde9-407e-861c-06510f86d8df', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('271196c7-bbf5-4934-9055-17b531137976', '9885c815-fde9-407e-861c-06510f86d8df', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ce16612f-bb54-4993-875f-e511bac9c82d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCM vs Persepolis FC',
  NULL,
  '2025-09-28 16:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ce16612f-bb54-4993-875f-e511bac9c82d',
  'aad58707-7310-4751-86c5-e403a28757f4',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f37060db-9b9a-41f4-9edf-45321840aec1', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('7cd2beb9-c22c-4c7f-ba9b-40d8f11958bc', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3ac0f639-cef4-4ab4-8eee-8818085b4cae',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Adé United FC vs Lighthouse Old Timers Club',
  NULL,
  '2025-09-28 16:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3ac0f639-cef4-4ab4-8eee-8818085b4cae',
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('184c1ece-7080-4d2e-9015-45444b83a478', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('13872a83-f770-4ce2-8bff-ab8c609df238', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9577b205-2607-4ba5-80c6-494adbbfeea4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Old Timers Club vs Lighthouse Boys Club',
  NULL,
  '2025-10-05 15:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9577b205-2607-4ba5-80c6-494adbbfeea4',
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bcbb6e9f-8b57-493f-afc8-c63186fb6b28', '9577b205-2607-4ba5-80c6-494adbbfeea4', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('5548660d-2444-49f2-a53c-3fa76eafc193', '9577b205-2607-4ba5-80c6-494adbbfeea4', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f887a773-2b54-4713-8b04-8ca7a7721cce',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Persepolis FC',
  NULL,
  '2025-10-05 18:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f887a773-2b54-4713-8b04-8ca7a7721cce',
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Philadelphia Liga 2',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4c174c5b-8cdf-40a9-bd63-ef8fad2c99c1', 'f887a773-2b54-4713-8b04-8ca7a7721cce', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('79d01f4f-f831-40c2-8a50-838f95a27f90', 'f887a773-2b54-4713-8b04-8ca7a7721cce', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '581c00d7-bf32-4533-8032-a953bf35aba8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Shore FC vs Strictly Nos Fc',
  NULL,
  '2025-12-31 05:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '581c00d7-bf32-4533-8032-a953bf35aba8',
  '895ff6df-959f-4a46-80c9-fbef6eed5b78',
  '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7ca3ecd9-80f0-4a9d-aa83-965798ec1be7', '581c00d7-bf32-4533-8032-a953bf35aba8', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('66d4b561-a42c-4a01-8d12-81b3ed500605', '581c00d7-bf32-4533-8032-a953bf35aba8', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '97175e59-2b10-47ac-8ef7-d276b0aafb77',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'BCFC All Stars vs Flatley FC',
  NULL,
  '2025-09-07 15:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '97175e59-2b10-47ac-8ef7-d276b0aafb77',
  '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9',
  '3ded57de-85a3-41e5-8b3e-87ea2a84de13',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('baf1358b-c7ed-4e1d-866b-1217e1d4c597', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('34043f8a-912f-4844-bf90-2f36eef860f0', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0aaa8905-7f99-4ea2-8829-c4991fcb539f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Strictly Nos Fc vs Jaguars United FC',
  NULL,
  '2025-09-07 17:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0aaa8905-7f99-4ea2-8829-c4991fcb539f',
  '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7',
  '9795925d-4af7-449a-86fd-e27cdfe9eced',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('25d684e2-d4f4-41a1-ad5a-c2e8384f7f49', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('32a6a5aa-1d7b-45a4-95da-64e9fb4183c3', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b44929d2-3a68-4879-8639-6546d1c9f548',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Gambeta FC vs South Shore FC',
  NULL,
  '2025-09-07 21:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b44929d2-3a68-4879-8639-6546d1c9f548',
  '2bf2f14b-8e84-44ec-825c-bc6031d385de',
  '895ff6df-959f-4a46-80c9-fbef6eed5b78',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('32e50878-2920-4e7d-9d0b-26e43df37a24', 'b44929d2-3a68-4879-8639-6546d1c9f548', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('a7b938e9-e135-4e1a-93ca-de3d809e984f', 'b44929d2-3a68-4879-8639-6546d1c9f548', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'BCFC All Stars vs Jaguars United FC',
  NULL,
  '2025-09-13 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e',
  '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9',
  '9795925d-4af7-449a-86fd-e27cdfe9eced',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('34c200ff-8206-4d33-b844-1d68ee16275e', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('3e219178-690f-4ade-9f7d-a32640c1e17b', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '28f04c53-c630-49d1-8af2-f3cde837a516',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Flatley FC vs Strictly Nos Fc',
  NULL,
  '2025-09-21 16:15:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '28f04c53-c630-49d1-8af2-f3cde837a516',
  '3ded57de-85a3-41e5-8b3e-87ea2a84de13',
  '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1c7098c1-aef3-4223-8b72-eec089fb7f78', '28f04c53-c630-49d1-8af2-f3cde837a516', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('9959b8c3-85fc-4bde-b2ba-d7700dd827cd', '28f04c53-c630-49d1-8af2-f3cde837a516', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '58b9196a-7093-49e8-82f1-6bd71921cc22',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Gambeta FC vs BCFC All Stars',
  NULL,
  '2025-09-21 18:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '58b9196a-7093-49e8-82f1-6bd71921cc22',
  '2bf2f14b-8e84-44ec-825c-bc6031d385de',
  '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4a738054-734c-4491-85fd-f2f4e627a626', '58b9196a-7093-49e8-82f1-6bd71921cc22', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('b3f30fbd-5858-4f0c-904e-feeb14f155ac', '58b9196a-7093-49e8-82f1-6bd71921cc22', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6bacf64d-c627-48f1-8956-2f9f5476e047',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jaguars United FC vs South Shore FC',
  NULL,
  '2025-09-21 22:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6bacf64d-c627-48f1-8956-2f9f5476e047',
  '9795925d-4af7-449a-86fd-e27cdfe9eced',
  '895ff6df-959f-4a46-80c9-fbef6eed5b78',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b8113cf2-3b2f-4d19-b1cd-3413e72409a4', '6bacf64d-c627-48f1-8956-2f9f5476e047', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701'),
  ('09d55440-416f-4ee1-a8d8-495ada822b9e', '6bacf64d-c627-48f1-8956-2f9f5476e047', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '53389dfc-19cd-4eca-811c-61e5f1dff3d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Strictly Nos Fc vs Gambeta FC',
  NULL,
  '2025-09-27 20:45:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '53389dfc-19cd-4eca-811c-61e5f1dff3d0',
  '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7',
  '2bf2f14b-8e84-44ec-825c-bc6031d385de',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4bd32562-01d1-47eb-9192-1a44c01906c4', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('641d3aca-ef16-4bbc-bdae-503cb9f480f6', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b9402498-7473-457a-8010-50103bb7dc44',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Shore FC vs BCFC All Stars',
  NULL,
  '2025-09-28 18:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b9402498-7473-457a-8010-50103bb7dc44',
  '895ff6df-959f-4a46-80c9-fbef6eed5b78',
  '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('53dfaf71-63cb-479d-a950-496cfc743f1f', 'b9402498-7473-457a-8010-50103bb7dc44', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('694cdaf8-5a10-41de-83f2-fb3ec41e4e24', 'b9402498-7473-457a-8010-50103bb7dc44', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7807d12f-bcfc-4391-80b5-8588cee543fb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Flatley FC vs Jaguars United FC',
  NULL,
  '2025-09-28 23:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7807d12f-bcfc-4391-80b5-8588cee543fb',
  '3ded57de-85a3-41e5-8b3e-87ea2a84de13',
  '9795925d-4af7-449a-86fd-e27cdfe9eced',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Boston Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2a8618f8-7b85-45ca-8cac-0020b911a95e', '7807d12f-bcfc-4391-80b5-8588cee543fb', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('28b462c7-ba95-4b6a-ad81-08ebda1b2602', '7807d12f-bcfc-4391-80b5-8588cee543fb', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '345f0215-c3c6-419f-8b1f-5e6d8178af5d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'F&M FC vs Lancaster City FC',
  NULL,
  '2025-11-09 18:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '345f0215-c3c6-419f-8b1f-5e6d8178af5d',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('83e7a191-4b6f-40c5-939d-aa26c36a1a88', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('94c6be90-00a1-435f-bd8a-7f5ab18cf630', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '536c950d-5e71-4511-8e29-39f40af7c7cc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Kutztown Men''s Soccer vs Keystone Elite',
  NULL,
  '2025-11-09 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '536c950d-5e71-4511-8e29-39f40af7c7cc',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('451fe05f-2cc2-48e7-b9e5-bbfa3719911a', '536c950d-5e71-4511-8e29-39f40af7c7cc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('c0a9072b-a8e5-4d7b-b41e-384a7d5a57fb', '536c950d-5e71-4511-8e29-39f40af7c7cc', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2752740a-b05a-4c4e-8137-1c7d0a03b5ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs Kutztown Men''s Soccer',
  NULL,
  '2025-11-02 23:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2752740a-b05a-4c4e-8137-1c7d0a03b5ea',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ba79d00-86ce-443d-bde2-3402d091c360', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('e181fd1f-1f38-4fdd-82ff-b0e4572152cc', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '121331ca-679b-4406-84f7-95ef8f4669d8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Keystone Elite vs F&M FC',
  NULL,
  '2025-11-02 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '121331ca-679b-4406-84f7-95ef8f4669d8',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('76ee6d32-7ab1-4de0-a4a9-1cae0fd3e8e6', '121331ca-679b-4406-84f7-95ef8f4669d8', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('8a6cc917-ef1f-4c63-adff-f26d42f61dea', '121331ca-679b-4406-84f7-95ef8f4669d8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '04b6bf56-3721-4e88-81e1-1a9889d75a08',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Keystone Elite vs Alloy Soccer Club Reserves',
  NULL,
  '2025-10-26 19:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '04b6bf56-3721-4e88-81e1-1a9889d75a08',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d7482762-558d-485a-9062-790a1ef10000', '04b6bf56-3721-4e88-81e1-1a9889d75a08', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('50d747a3-79bb-4e40-a459-12dbb36b51e4', '04b6bf56-3721-4e88-81e1-1a9889d75a08', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Kutztown Men''s Soccer vs Lancaster City FC',
  NULL,
  '2025-10-26 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9e12f8e9-042a-432e-814d-0812cfad0f18', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('239ee975-deed-4f1b-91cd-a3ce520f2a0c', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ccdb6d59-c7bb-436d-801c-346952a049df',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs Alloy Soccer Club Reserves',
  NULL,
  '2025-10-19 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ccdb6d59-c7bb-436d-801c-346952a049df',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a5929461-f0ec-4fb2-9d9e-ce797e6d1bfa', 'ccdb6d59-c7bb-436d-801c-346952a049df', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('46393ce6-0e37-45a9-8087-983d4853768b', 'ccdb6d59-c7bb-436d-801c-346952a049df', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd0398281-b2c4-488f-8cf2-9b1a5e52d373',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Kutztown Men''s Soccer vs F&M FC',
  NULL,
  '2025-10-19 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd0398281-b2c4-488f-8cf2-9b1a5e52d373',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9df8407d-eb97-4576-87f8-734b76a06f7c', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('379cc32c-fb5d-4189-b80d-f7bda85d9443', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3166f851-6d5d-4d21-8b24-b4a114a0d7d6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs F&M FC',
  NULL,
  '2025-10-15 23:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3166f851-6d5d-4d21-8b24-b4a114a0d7d6',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a676d940-bc17-4110-85cc-0706bd825412', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('70da8038-58ba-411d-abad-f39fd8d10c34', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7d035123-7c88-4349-80a5-fdca105d0c22',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Keystone Elite vs Lancaster City FC',
  NULL,
  '2025-10-12 19:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7d035123-7c88-4349-80a5-fdca105d0c22',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('47782a2f-b30c-4968-a636-533207d43721', '7d035123-7c88-4349-80a5-fdca105d0c22', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('c14b37b5-d4c7-4e65-8bf5-a9e23400c7d4', '7d035123-7c88-4349-80a5-fdca105d0c22', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ff8f2f8c-4a57-4823-890a-44e19272bac4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs F&M FC',
  NULL,
  '2025-09-07 15:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ff8f2f8c-4a57-4823-890a-44e19272bac4',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('28d0c4c9-62a2-47ba-8ea9-a7d27fd5759b', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('b52c793b-c498-4fa4-8db0-3afde25c2eea', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7f3c7055-8217-4efe-8b6f-c426f8e4804c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Keystone Elite vs Kutztown Men''s Soccer',
  NULL,
  '2025-09-07 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7f3c7055-8217-4efe-8b6f-c426f8e4804c',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9c3efa41-5ff3-49dd-9ec1-80f183f0ae98', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('8acbd2ce-df25-42c7-b964-36ec1610224a', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7dbf50e1-dc5f-45a8-895f-962cc2187b96',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'F&M FC vs Keystone Elite',
  NULL,
  '2025-09-14 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7dbf50e1-dc5f-45a8-895f-962cc2187b96',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4b6906f8-f93a-436c-8d31-678f5eacc5e7', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('90773024-761d-4780-82bf-fbb6026249c7', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b249c4dc-4ba3-42f5-8281-5819e4dc67a7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs Lancaster City FC',
  NULL,
  '2025-09-14 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b249c4dc-4ba3-42f5-8281-5819e4dc67a7',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('238757db-6b8b-4634-9687-56ccf181ad90', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('df084aa7-a3b0-4237-9a71-d13ff7757f4a', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e97dd3af-d2fe-4679-810a-2b5758f7b6e2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs Keystone Elite',
  NULL,
  '2025-09-20 19:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e97dd3af-d2fe-4679-810a-2b5758f7b6e2',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2e630a40-9c5f-4eaf-80b7-987db9114f21', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('a7a58ca0-0449-4a45-849e-18c7410579cf', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '41ccaddc-8057-4d9a-8821-ad5657d9b6a9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Kutztown Men''s Soccer vs Alloy Soccer Club Reserves',
  NULL,
  '2025-09-21 17:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '41ccaddc-8057-4d9a-8821-ad5657d9b6a9',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('64365c67-51e2-4152-95b3-b15854d01792', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('2fc08795-b35e-4bba-a914-31d286b97220', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '29641fce-744f-48b2-8102-d1f234d2dddc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'F&M FC vs Kutztown Men''s Soccer',
  NULL,
  '2025-09-28 17:15:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '29641fce-744f-48b2-8102-d1f234d2dddc',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ba0a4c28-ac70-4fa8-a90a-16a78a100c9f', '29641fce-744f-48b2-8102-d1f234d2dddc', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('4c1dab42-2f0a-42a5-be6c-78e6e38ad857', '29641fce-744f-48b2-8102-d1f234d2dddc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '96a1189e-373f-4de5-81f7-3869b7486f77',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club Reserves vs Keystone Elite',
  NULL,
  '2025-09-28 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '96a1189e-373f-4de5-81f7-3869b7486f77',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('219d856f-a66b-494c-837f-92bca3b96535', '96a1189e-373f-4de5-81f7-3869b7486f77', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('c8d2f3cf-e54f-4f66-b926-1ec4ddb232b9', '96a1189e-373f-4de5-81f7-3869b7486f77', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '471ee4f9-72a6-4432-8aa5-a3740830921f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lancaster City FC vs Kutztown Men''s Soccer',
  NULL,
  '2025-10-05 15:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '471ee4f9-72a6-4432-8aa5-a3740830921f',
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  '5541a60c-6517-4e66-8c25-a513298fd487',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a908905d-bed1-4f23-b7bb-bf632f1acb49', '471ee4f9-72a6-4432-8aa5-a3740830921f', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('715eaca1-a3a3-4382-8637-2f3c87944f09', '471ee4f9-72a6-4432-8aa5-a3740830921f', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6a283f17-da54-4e7b-812c-3299d4d9eeb8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'F&M FC vs Alloy Soccer Club Reserves',
  NULL,
  '2025-10-05 21:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6a283f17-da54-4e7b-812c-3299d4d9eeb8',
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Lancaster Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0563a0b7-2a72-46b2-a094-2913af41275c', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('55bf4038-cc20-4646-8358-c9efaedeca98', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca Reserves vs Milan Football Club',
  NULL,
  '2025-11-09 23:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e4a16413-de59-4bcd-a861-453f68e19cff', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('7ad21385-e7e9-4a49-931b-b9204c15a818', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fee5ff6c-fa94-46f2-87ed-014d3f9d164b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Monmouth Light FC vs Jersey Shore Hounds',
  NULL,
  '2025-11-09 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fee5ff6c-fa94-46f2-87ed-014d3f9d164b',
  'd9b9ff4c-052c-4c9f-8d2d-483f66125de4',
  'eb1511a3-cc96-4387-80c1-c8e470338ddc',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('66d41297-077d-43d0-82f6-4ea8f3723cf1', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701'),
  ('9c7457cc-a194-4aaa-ae22-5aad4e371b92', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a9299cdb-4795-4ae2-8563-c3b062d9aa9b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Rondo Football Club vs Alaso FC',
  NULL,
  '2025-11-09 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a9299cdb-4795-4ae2-8563-c3b062d9aa9b',
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  'dda012cd-f081-48df-8903-d997d9fa6f96',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('34f46cf5-0ce8-4ac6-a2df-3810608822cf', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('81d42626-9cf0-4927-abae-a8bdaa89859d', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'FeelsGood FC vs Milan Football Club',
  NULL,
  '2025-11-08 15:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('167c02d0-90e7-4433-9b1c-a04ac38a9cab', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701'),
  ('3835ba9d-cc6d-481a-8506-19f9789e8a97', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Princeton International FC vs Jersey Shore Boca Reserves',
  NULL,
  '2025-11-06 01:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0',
  '7708a49e-8512-43b2-8b85-13e98a4af318',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26cb221c-1ee4-4899-8c28-c0351b6d37eb', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('0989e460-dd82-49c8-833b-cd5da75b13ef', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '13ae55a8-01d6-4849-8327-bcbea6d52cfb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alaso FC vs Real Central NJ II',
  NULL,
  '2025-11-03 00:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '13ae55a8-01d6-4849-8327-bcbea6d52cfb',
  'dda012cd-f081-48df-8903-d997d9fa6f96',
  'bb5768e2-fac3-42e0-8d07-f18a63fb2278',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('48360375-8360-4324-aa2e-224a06b3c433', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('b7055135-acdc-48bf-9316-cbbde1713322', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0cf035b4-2b92-4468-8cd4-cb30251db88d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Rondo Football Club vs MFC Stars',
  NULL,
  '2025-11-02 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0cf035b4-2b92-4468-8cd4-cb30251db88d',
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  '3e87d61d-3093-41a0-888a-83f66923a34b',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('adc6992b-0cd9-4d21-9815-6a51229f3b72', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('f7c66e85-a4d4-4ed8-9ddd-01054a494ae4', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8a557316-f880-44f0-8028-97b52d290cae',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Hounds vs Real Central NJ II',
  NULL,
  '2025-09-07 13:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8a557316-f880-44f0-8028-97b52d290cae',
  'eb1511a3-cc96-4387-80c1-c8e470338ddc',
  'bb5768e2-fac3-42e0-8d07-f18a63fb2278',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1e451f0b-80b3-491c-94aa-7ed05e31952c', '8a557316-f880-44f0-8028-97b52d290cae', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('0ce01e88-6dd0-47a9-a8ed-6e8be4ef2077', '8a557316-f880-44f0-8028-97b52d290cae', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9cc8bfe7-2df1-434e-8313-3e592dfc9d53',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Milan Football Club vs Rondo Football Club',
  NULL,
  '2025-09-07 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9cc8bfe7-2df1-434e-8313-3e592dfc9d53',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d9bc6665-f769-438e-93b7-4925c0a2246a', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('1d9f5a82-373b-4e20-8960-e21b94454374', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '44687709-00cd-4828-8492-eb117a75be45',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Princeton International FC vs FeelsGood FC',
  NULL,
  '2025-09-07 14:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '44687709-00cd-4828-8492-eb117a75be45',
  '7708a49e-8512-43b2-8b85-13e98a4af318',
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e5ad146c-532d-404d-b8c6-22cf4c1add1e', '44687709-00cd-4828-8492-eb117a75be45', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('1d9bee83-3850-4d8f-a135-db01c2a38c7a', '44687709-00cd-4828-8492-eb117a75be45', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'da8d12b0-afd7-4b1f-8f5b-63620db06ff2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca Reserves vs Monmouth Light FC',
  NULL,
  '2025-09-07 22:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'da8d12b0-afd7-4b1f-8f5b-63620db06ff2',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  'd9b9ff4c-052c-4c9f-8d2d-483f66125de4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5d43fb22-f86d-499a-b2be-9d612aaac904', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('0f8f7960-9b67-4eea-8d87-8843544696da', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8e018dcd-a2a5-4f4d-8cad-9406b56458b6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alaso FC vs MFC Stars',
  NULL,
  '2025-09-07 23:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8e018dcd-a2a5-4f4d-8cad-9406b56458b6',
  'dda012cd-f081-48df-8903-d997d9fa6f96',
  '3e87d61d-3093-41a0-888a-83f66923a34b',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('74cf6fad-bd93-4e76-9feb-90b33c3705c4', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('f6c842e7-1b8a-47c6-ba55-18f662ce9bfe', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bbb552d5-3241-4dca-8824-69be1f232855',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Rondo Football Club vs Monmouth Light FC',
  NULL,
  '2025-09-14 12:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bbb552d5-3241-4dca-8824-69be1f232855',
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  'd9b9ff4c-052c-4c9f-8d2d-483f66125de4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7f0f485e-3109-4795-aa32-9cc32c4c6c2b', 'bbb552d5-3241-4dca-8824-69be1f232855', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('14a5b8fe-6d1a-4c8c-91a4-6880ea48086c', 'bbb552d5-3241-4dca-8824-69be1f232855', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '54e7ac62-60c6-4da1-8ca0-48e735edd4d6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Hounds vs Jersey Shore Boca Reserves',
  NULL,
  '2025-09-14 13:30:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '54e7ac62-60c6-4da1-8ca0-48e735edd4d6',
  'eb1511a3-cc96-4387-80c1-c8e470338ddc',
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ae744f95-9a9d-4cde-9b5a-364cff010da0', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('b26a8c11-8cf6-4369-817b-4f0b1280e5c1', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '628a1237-b966-42f2-8927-678809d67be4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Milan Football Club vs Real Central NJ II',
  NULL,
  '2025-09-14 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '628a1237-b966-42f2-8927-678809d67be4',
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  'bb5768e2-fac3-42e0-8d07-f18a63fb2278',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('95f037f1-1f3e-4655-a465-4e95ce51c04b', '628a1237-b966-42f2-8927-678809d67be4', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('08773704-0b7e-4393-ae28-0feca71e116c', '628a1237-b966-42f2-8927-678809d67be4', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'MFC Stars vs Princeton International FC',
  NULL,
  '2025-09-14 20:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9',
  '3e87d61d-3093-41a0-888a-83f66923a34b',
  '7708a49e-8512-43b2-8b85-13e98a4af318',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('969962d2-a420-4efe-9ec4-f888503a9afe', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701'),
  ('557caf79-72e4-45d6-91cc-e1bdc4d8e31f', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b0dfa54d-7374-4e08-8840-cafe6aa4b951',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Princeton International FC vs Monmouth Light FC',
  NULL,
  '2025-09-21 14:00:00',
  NULL,
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b0dfa54d-7374-4e08-8840-cafe6aa4b951',
  '7708a49e-8512-43b2-8b85-13e98a4af318',
  'd9b9ff4c-052c-4c9f-8d2d-483f66125de4',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  'Central NJ Liga 1',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('326bb557-1701-4dcd-819f-228882711b93', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('e192c247-4a52-49f1-bdd8-1f87e5c0576b', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
