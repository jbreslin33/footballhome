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
  ('bd545b7e-410d-49df-8e43-f2d612355ae2', '62d30cd4-fb69-4a97-84bd-0e506564c188', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('3286bf3d-15ef-4e9c-964d-40c36330c7f2', '62d30cd4-fb69-4a97-84bd-0e506564c188', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('da3b0e89-7312-432f-8e01-29914a258878', '2537da99-8f86-4c23-81f7-b0ea2621bb05', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('d86d29a7-94a5-4bd4-bd9a-94f2908bbf40', '2537da99-8f86-4c23-81f7-b0ea2621bb05', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a0924932-7540-4ef5-8a63-f5f95f2ab680', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('53add692-3736-4d02-bcf8-71c24cc0f355', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('de3c2d80-9f55-4c9b-8d53-6b48fbd51c6f', '4d734c38-ec21-47a9-8b6a-1e8395f2afc1', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('10e84286-34ff-43cd-80b9-1fc164b29ee2', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('3ecb62d8-6ce0-43be-b045-5f8bb5692838', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8508f5e4-552d-4af0-8293-90c02724ef5a', '4d524c17-9d79-4153-8a04-7aeab379e450', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('13b083e3-740b-4e5b-accb-43563cc504c2', '83d619c8-bca1-42a1-8b4f-096d80083a5c', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('7888da50-7160-41dd-a4bf-c06531c56632', '83d619c8-bca1-42a1-8b4f-096d80083a5c', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a43d8ada-3245-4632-9e9e-291f3f06f859', 'fc19745e-b7ac-4b64-8731-a256613e1534', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('3c7bfa66-0d43-4fd3-899f-0ceb74e608b0', 'fc19745e-b7ac-4b64-8731-a256613e1534', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3dbc060d-9b20-46fc-9106-8bde65883fe4', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('3a14b827-1b6b-4f00-8729-958f6ef8c7a8', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1c8a0183-459f-4c2b-9246-5aa92f6551ac', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('13e94080-3f29-4db5-8501-9e72c3e6526d', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('72a98240-0c6f-42cb-82a7-d11ce8804914', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701'),
  ('b14e75da-829d-4a93-91e7-93ac066a25b1', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5957b0a2-914d-471e-95b5-5781b1464f44', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('067157b0-8128-40f6-96c2-79f2d0e62ff6', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e5ebe168-a73b-4d6b-b128-24ba0aee53ba', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('3733942f-4c29-490e-885b-034a9bf6cd88', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5c9c9c0f-38f0-4e6a-9461-f2b3632261f6', '8165bc74-cfe4-495b-86e4-86702b0dbf41', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('92f28242-48c9-443f-8f03-a63b4db131da', '8165bc74-cfe4-495b-86e4-86702b0dbf41', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('120452bd-2e4a-41d8-9784-4137a75a5fbe', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('bd976ceb-b5e9-4b02-a207-1e8c89765f23', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('69eaba40-5cad-4b42-bc4b-ad0c2bc8e9b9', '91a9c8b7-406d-41de-8df6-8607f59396cf', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701'),
  ('1f4e08d1-a14d-4fda-9283-3de91ca8d5c2', '91a9c8b7-406d-41de-8df6-8607f59396cf', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ba4cd828-b9de-4557-87ab-37825c281933', '52f4814d-e1a3-468f-89bd-6e02155b6129', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e848ded0-05aa-4469-99d1-0ab089661418', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('a01c6249-b1b2-416c-8f0d-54cf0c01b854', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e900a051-36b3-438b-af08-2646379b0f49', '55b1a2da-7521-4691-82ae-831d929ec711', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('2084b7b5-49a9-416c-bd0d-490a7cc17209', '55b1a2da-7521-4691-82ae-831d929ec711', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('96ea2ac6-1187-4853-bdc8-595fdfa0ecbd', '34bb814d-67bc-489f-8c94-2198057fb592', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5bff6745-1499-4387-94ad-6a70a9ea3ccb', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('05f4ff68-9efc-42e7-b9ac-228f83fa6265', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b9276ca3-30a3-41cc-82d0-00b524181199', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('27359035-7da9-46b9-802b-60ea6b3cc448', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e6ab2970-0b94-4084-b39c-870c748020c6', 'e082a5b2-71e3-474a-8256-16ce76e60795', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8460333f-db6b-47fc-bc98-10a3273f0c47', '91ebabec-ce77-47e8-832e-99263cba41e6', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('82c2a8ce-c8e3-4225-80cf-8f0439e2e16b', '91ebabec-ce77-47e8-832e-99263cba41e6', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9f2a019f-4335-4e78-b2ab-ba0ba5dfeb8f', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('8c4c85ab-da12-4e2e-93a2-bf6530cc01ca', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b4cf6297-42d3-4059-8421-1528280e91f8', 'abcbff6c-c508-4198-86c6-d093e886f9d7', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('471e57d6-7f03-474c-90a3-a1e0850fa96e', 'abcbff6c-c508-4198-86c6-d093e886f9d7', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3fc1d257-d46d-4990-b62b-187c9d135b4b', 'afafacd7-d142-4996-881f-cbade4ac2ca9', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('23804daf-b8f0-406a-8238-a441e937ae1f', 'afafacd7-d142-4996-881f-cbade4ac2ca9', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5fff7d84-a4bb-4116-ba90-23dcede3d43f', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('cd2f6c16-45e2-4818-ac90-a82c79c8a636', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a6cc18a0-cb10-4b07-b276-618a6c7dbf22', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('4045594d-99bb-423a-b8db-dcd42360ee5b', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e61a79cb-06c4-4c9d-8767-485d4ad52f51', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('2a76ba9f-ab40-439b-a90f-f53ad76be355', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0a4acb11-ae41-4c7a-940d-134c0feda8d1', 'd5e6fbec-5173-4a03-83ad-97f5620f579e', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81cd57e3-8f64-4839-bf21-c35334e4206d', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('b9fc35f9-34b5-4970-8fd9-a80da67a4b81', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('11070feb-8170-4921-b13d-f9cbbb443e8b', '9885c815-fde9-407e-861c-06510f86d8df', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('1fbcaff9-ac7b-448b-b3a5-460d106a8366', '9885c815-fde9-407e-861c-06510f86d8df', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ca2d70a5-ff2c-4ee0-9389-92c93bc0e7d6', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('4b8f63d9-3d65-455a-aa9e-dd48cddd5970', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1b958dee-ca14-4047-a7cb-9ca2402a1560', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('0f9c5f4d-a720-4b85-9ec7-deac40852b5f', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8bdbc5de-1fc1-49ad-a3a4-63142a8c0d0e', '9577b205-2607-4ba5-80c6-494adbbfeea4', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('f8fcc2bf-5832-418b-88ed-bdddb26ba8d7', '9577b205-2607-4ba5-80c6-494adbbfeea4', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d599fc6c-02bf-475c-b80a-5007b6cbf12a', 'f887a773-2b54-4713-8b04-8ca7a7721cce', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('76aaf655-6be9-40cf-91ea-685cd7bdd03d', 'f887a773-2b54-4713-8b04-8ca7a7721cce', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f7cf9d14-5d0a-468f-827d-d6b81be77d0d', '581c00d7-bf32-4533-8032-a953bf35aba8', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('91fe11cd-22c3-44b5-9807-0e46e665bfdc', '581c00d7-bf32-4533-8032-a953bf35aba8', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a444ceb5-4dfd-4804-afc1-849baa4f4ed8', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('9707a1ae-dac6-4baa-a836-3170c2bbf5e1', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fdb4dcb5-f278-40dc-87c1-537b9c695b58', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('dbc7d057-7636-40d5-824b-65e27dd2f1c6', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9413d10a-a247-45e2-bfa5-7d0a51d3b286', 'b44929d2-3a68-4879-8639-6546d1c9f548', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('54a44472-0bfb-450b-9902-24115b898987', 'b44929d2-3a68-4879-8639-6546d1c9f548', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d10e4803-5362-475e-9ac6-650bd9f9bb84', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('18c2e10a-95be-48ab-b9fb-fb4c08c71efc', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ffa7ea93-30a5-47df-9f35-0b810e16c7b1', '28f04c53-c630-49d1-8af2-f3cde837a516', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('e40480cf-1834-4f82-a66e-ad962a9bcb53', '28f04c53-c630-49d1-8af2-f3cde837a516', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4be32955-7b8a-47ce-9236-bf96fb868672', '58b9196a-7093-49e8-82f1-6bd71921cc22', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('248a6c2f-4d35-4682-a572-71660e237b04', '58b9196a-7093-49e8-82f1-6bd71921cc22', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f573545e-c9de-47b5-a251-2da3016e671c', '6bacf64d-c627-48f1-8956-2f9f5476e047', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701'),
  ('370be705-68b5-4ab5-b267-31683da03c2c', '6bacf64d-c627-48f1-8956-2f9f5476e047', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c144a382-6c99-410c-b620-bcdc294b08d4', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('2b73377e-f133-42fa-b030-dc468fe083bc', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c7d810ef-de4d-4208-b24a-071383ae8bf4', 'b9402498-7473-457a-8010-50103bb7dc44', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('da0fbe4e-a3b4-41ee-bda9-5431782e503c', 'b9402498-7473-457a-8010-50103bb7dc44', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dd32da1c-2836-41eb-89f1-7b75451d7af9', '7807d12f-bcfc-4391-80b5-8588cee543fb', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('046e6c74-0c5f-4afb-bd61-91677789830a', '7807d12f-bcfc-4391-80b5-8588cee543fb', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('89d3900e-64e5-4707-944c-6fbf6df4d026', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('7fc4fc05-721e-4326-96ac-1e0de404ab2a', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a7f00cc8-4cb4-421e-911e-27ccc4eb7671', '536c950d-5e71-4511-8e29-39f40af7c7cc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('958a93c0-9186-4af2-892f-10fd862879a5', '536c950d-5e71-4511-8e29-39f40af7c7cc', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('32bf6986-0310-412c-ac8f-628098127832', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('c75a5c41-ec34-44d1-9f35-fe68fd24ea13', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5de8e94f-5ecb-4382-8de8-9b34001667c9', '121331ca-679b-4406-84f7-95ef8f4669d8', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('9a1cb97b-6511-489d-9abd-5c72aa72d29d', '121331ca-679b-4406-84f7-95ef8f4669d8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('45073b5a-87c5-459d-be5b-05682616753d', '04b6bf56-3721-4e88-81e1-1a9889d75a08', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('045b52d1-5398-467f-abf2-780296f71ea7', '04b6bf56-3721-4e88-81e1-1a9889d75a08', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7b1f371a-bd4a-4537-99ed-3498dba95dd2', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('a734ef74-ea72-424b-bc53-6a1af093f383', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8b2bcf5c-7ff1-4d3e-a2bc-22afd370e6da', 'ccdb6d59-c7bb-436d-801c-346952a049df', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('f1876770-8f15-43e7-9bd6-ae6748e5c504', 'ccdb6d59-c7bb-436d-801c-346952a049df', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ebaffcc3-bac7-4260-bcfd-d37de5561ab2', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('b9cc427f-2a65-4281-b456-e4cdfa2b6656', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9d3574c0-b354-4f28-ae10-f345978ee2da', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('e973c0e4-41cc-4d91-90b9-869b125ddcc1', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a7b7ca13-f841-4180-9b76-fbe3db3ca8ab', '7d035123-7c88-4349-80a5-fdca105d0c22', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('9c7a795e-05cc-48af-a3d7-f47d2aea0273', '7d035123-7c88-4349-80a5-fdca105d0c22', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('94a7175b-8429-4287-8a49-e5fcc73dba35', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('0f2d8dfa-13f5-49fb-aa6c-ec64e7f09377', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6cfa3f9e-5cc2-47b7-91ac-4012efcfb2a2', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('9cbe50c2-7a79-49cd-a51e-8a8f1f1610e9', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a989d57d-d0dc-47cd-af35-b575b613b24e', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('aa4c9cc5-22e7-4e82-934a-90383b104811', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4e299a45-fefc-4ac6-91f2-e4a9fe64503a', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('f27431d4-27f6-4eb8-9234-ebf9c4ff97e5', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c9ee6864-68b4-4319-a6ac-34eeaca5af0a', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('1e22e548-ea55-400e-bc45-e7ea72f296d4', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e6ef203a-865f-4ce0-9227-462f4c41449f', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('826d8ce7-ffec-4513-9607-ad2fb136ff1e', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('01e74969-f315-4aa8-80ea-b0c129c5b9b5', '29641fce-744f-48b2-8102-d1f234d2dddc', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('06a96d18-2cf0-4547-b89e-af387fb55587', '29641fce-744f-48b2-8102-d1f234d2dddc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f59ab90f-4529-4e96-a73f-9c875a8c9ca6', '96a1189e-373f-4de5-81f7-3869b7486f77', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('c34eaf17-2e68-4c7e-be19-3f5131416be1', '96a1189e-373f-4de5-81f7-3869b7486f77', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('35641d63-926e-4a54-a8ce-405ca5c47898', '471ee4f9-72a6-4432-8aa5-a3740830921f', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('a21a71b7-b4d9-4ebe-b15f-f634a8d5b56b', '471ee4f9-72a6-4432-8aa5-a3740830921f', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6582c47f-9151-45fb-b2e3-74e1d4056374', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('6fbb9c2d-917a-456e-a5a3-ee0e2b05f4a5', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('10d5ff72-2780-4b79-97a9-e9e9ad7a2d74', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('c58915a0-3c42-4833-957a-65c52ef90cdd', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('909286c8-9d93-4729-b75e-666d36aa9ae3', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701'),
  ('23c18e12-0589-4f8e-bd51-4169f22d03aa', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('51ae707d-3afc-4753-aa00-91697e807ade', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('313e3d62-dc8e-4dc8-95c3-4f15003c2fb3', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7f1befed-05fa-4107-8e3f-575bdd943645', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701'),
  ('d8de2a5d-285f-41b9-b106-6f4c8b8b1cfe', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a5d4f3cb-0161-46fd-9c5a-69e3253f253b', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('e787fe16-2edc-482a-9ad2-2ee97499d080', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5b81f735-9499-46f0-a6fe-c2e6246e5981', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('23bbbb01-d3d0-4dc2-b4c6-f948ad5ab530', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b50be404-b1f5-4aa1-bc23-e471a3105bb0', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('804cddf1-cbd9-486a-9d1a-54ab74ca77b3', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ee084b9d-6d37-45a1-8cef-f32eadd9d528', '8a557316-f880-44f0-8028-97b52d290cae', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('44650a1d-6ed7-49f5-a624-6d1498649840', '8a557316-f880-44f0-8028-97b52d290cae', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3f80eac7-d547-4af5-9511-dc97d1a204d6', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('41053961-4964-4310-8307-4e404c5184ae', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701')
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
  ('27b8fa05-484f-4f4b-b56e-d5542511352b', '44687709-00cd-4828-8492-eb117a75be45', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('5055ff6c-7775-4cba-84cf-b6a6bd6c7877', '44687709-00cd-4828-8492-eb117a75be45', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b237c7e1-10be-4da4-8262-7e125c987fe9', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('da904315-35e3-4354-b49e-5a9d0add0de5', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6353b9f9-d065-4f72-a0d2-40d480e84e8c', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('225f76c4-52ab-4680-805b-7a2af903e49f', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1f004df9-096f-4d0d-9c52-9e0288d442d2', 'bbb552d5-3241-4dca-8824-69be1f232855', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('b7aa137d-a98b-4be8-884d-ce61ed660e29', 'bbb552d5-3241-4dca-8824-69be1f232855', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('71163b69-330c-4152-9282-423690d2864e', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('e1d3c4fa-f0e2-458a-8924-5fb26759c607', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('709da320-6be1-4637-82f5-69fb7ec39b77', '628a1237-b966-42f2-8927-678809d67be4', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('1c8e888c-60f3-4563-9022-9ec75e63f425', '628a1237-b966-42f2-8927-678809d67be4', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e5c9ac27-5412-4a99-8733-99f57308a39f', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701'),
  ('f91b71fb-de55-46fb-9451-61c0d194afed', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c6e59900-5787-49de-9d2e-7a62e0fd77e8', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('9b9fabf5-1547-4a6e-b23d-0afe7503e11d', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
