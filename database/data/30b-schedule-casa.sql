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
  ('0f296bc5-71d5-4265-8c23-8229af6721d9', '62d30cd4-fb69-4a97-84bd-0e506564c188', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('5a9731da-b4d9-43b2-ab1d-b72ec8047d3f', '62d30cd4-fb69-4a97-84bd-0e506564c188', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dc73713f-b4ad-4b3a-93f0-e83954ced338', '2537da99-8f86-4c23-81f7-b0ea2621bb05', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('7525d997-7697-4dfa-96ec-b2a72b463913', '2537da99-8f86-4c23-81f7-b0ea2621bb05', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('37c8a043-3894-4b85-a4ae-cdabec1d85b3', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('141a6866-bb6a-4668-82ef-cd061054ea57', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a212b344-f0c6-4939-9a2e-c9590c131117', '4d734c38-ec21-47a9-8b6a-1e8395f2afc1', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bb86d3f9-fe7c-4251-8485-db457dcca298', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('bf0bc351-84fa-45fd-ad88-01b370cf5b19', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('da011c2f-d60d-4338-8a9d-3652ce7d0db4', '4d524c17-9d79-4153-8a04-7aeab379e450', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bc009214-7124-41e8-9220-78461ec3262d', '83d619c8-bca1-42a1-8b4f-096d80083a5c', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('3ab6508b-f8a7-4a55-bbf0-75ebe9b6edb1', '83d619c8-bca1-42a1-8b4f-096d80083a5c', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7ea115dd-118b-42eb-80a0-7ad53155a3d5', 'fc19745e-b7ac-4b64-8731-a256613e1534', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('13c310c6-01f0-491e-94f8-e31d16fba9cc', 'fc19745e-b7ac-4b64-8731-a256613e1534', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('994bfed0-041a-48fe-981e-2fc902edbd2d', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('c88af3a7-0067-45f3-af6d-31b4d03353ca', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('101793a8-d143-44ca-abba-ea30c0a508fe', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('cb90aa2f-3660-4747-8bf8-d44c801283f5', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('78157b49-c78e-44e8-8f1b-861267b03515', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701'),
  ('0a49e6c3-14a9-4358-a4fc-bb7acaf99fea', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('98a64ace-0b02-4111-9dd3-de3aac2023a2', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('39cac561-201f-47ab-a01c-7db6ecd3c601', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f26b98f7-dc66-499f-aa79-5b4c1760e688', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('1a6d3240-0208-4e0d-90bf-a86b26948675', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8d675b48-b72d-4cb1-b334-ba2185ac736e', '8165bc74-cfe4-495b-86e4-86702b0dbf41', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('3947dc39-a08c-40bd-bf87-0d14384dcda7', '8165bc74-cfe4-495b-86e4-86702b0dbf41', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8ecb8456-9b70-4289-b690-05e785a4b948', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('fa3d4a29-85cd-4c4f-8f71-2b2b4977d89a', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5dcebe17-1fa6-4254-b881-747f7fd163e7', '91a9c8b7-406d-41de-8df6-8607f59396cf', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701'),
  ('4901e717-0655-4ee9-bdc3-a0890451190e', '91a9c8b7-406d-41de-8df6-8607f59396cf', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('467707e8-4fa8-4eac-924e-efcbdc4f58a0', '52f4814d-e1a3-468f-89bd-6e02155b6129', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('19549122-ef5c-4786-9cad-fd6ff7d261e1', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('5225c595-03e2-434d-8b06-6843a13512c0', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('649342f5-8f26-4951-a3a2-44de5ee17e9e', '55b1a2da-7521-4691-82ae-831d929ec711', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('2ac72b9d-d824-4b8c-a49b-6e6d690403c9', '55b1a2da-7521-4691-82ae-831d929ec711', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('128ee27d-8118-4366-abb5-4c4b1d986cc8', '34bb814d-67bc-489f-8c94-2198057fb592', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('863dcacc-aa85-45de-b257-b80ee918aaf5', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('0a8a40f2-5b7b-4d02-b2a1-4585e61e395a', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0f3f35af-a827-421e-a6d8-3064be7a4200', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('7d7f9feb-9462-41b0-8900-a8dd1059a612', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('507a46b3-486c-442c-8fa0-f5b4f8761911', 'e082a5b2-71e3-474a-8256-16ce76e60795', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d53f7c3b-8a39-42fc-83c4-cf2dfba9fbcb', '91ebabec-ce77-47e8-832e-99263cba41e6', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('2d075e6d-8789-43aa-89e5-f5919439f7a9', '91ebabec-ce77-47e8-832e-99263cba41e6', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cbd6a6a4-051e-4c61-8235-4569bc7e9638', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('4203eee8-b5cc-4348-945c-b5b81c456b4a', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a2604afc-2769-4ee5-9cf7-3d1590c69694', 'abcbff6c-c508-4198-86c6-d093e886f9d7', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('a4ccd11d-9115-4ba6-a325-c552bd7814f2', 'abcbff6c-c508-4198-86c6-d093e886f9d7', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('016a9562-c4c1-46a0-98cd-c0f40aa7716d', 'afafacd7-d142-4996-881f-cbade4ac2ca9', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('cdc80934-2936-4613-b17e-cec331f3da0d', 'afafacd7-d142-4996-881f-cbade4ac2ca9', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8f865b1e-6298-4ef0-9cfb-c2afd9a65e00', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('069b77ae-babd-4961-989d-ba649da8e744', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('91961f50-e742-4741-876f-91c34bb57e02', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('e80f490d-0f2a-4728-9135-bf187afb111e', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4d5ccefe-48a2-4b73-812d-9f3adeaf26fb', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('6bf44b32-45f4-4de6-b1eb-f92d7f1479b4', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('77cb7f53-3bf2-4de1-9816-6dfe37098072', 'd5e6fbec-5173-4a03-83ad-97f5620f579e', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('39a29088-fb58-48da-b732-5a0f79ef5c49', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('087446eb-5f42-4d80-ba88-67764d94312e', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c165692d-2f42-43bc-9ba9-d870b252f701', '9885c815-fde9-407e-861c-06510f86d8df', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('68d7a570-4db1-4156-9e76-aa7e82e3e195', '9885c815-fde9-407e-861c-06510f86d8df', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f0783abe-4ad7-4534-8bd1-e01b1934428f', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('5507ed5a-34f9-4649-a4ce-a17ab135571e', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('341ff5af-6f93-4785-b86d-5d4cfb0d78f5', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('aea96883-ced0-4903-9f50-77098cc78db9', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b1286c94-915f-4715-bb10-c0d0a91426fb', '9577b205-2607-4ba5-80c6-494adbbfeea4', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('eb3d30bc-5d95-4d19-bef0-cdf02f703bee', '9577b205-2607-4ba5-80c6-494adbbfeea4', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81747b26-d073-404c-afbd-a0d820a15854', 'f887a773-2b54-4713-8b04-8ca7a7721cce', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('5f31198b-27bc-424f-9a52-e93f30d4ed24', 'f887a773-2b54-4713-8b04-8ca7a7721cce', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1367e744-88d9-417f-9964-ef6e8ba91283', '581c00d7-bf32-4533-8032-a953bf35aba8', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('5bc814f4-752d-462c-be58-49fa4e733249', '581c00d7-bf32-4533-8032-a953bf35aba8', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d0ab8f0c-015c-406b-b298-18f84647eb40', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('17df61f2-a122-4f08-8ade-31d1a80a343e', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701')
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
  ('faf2ca14-ffd9-4202-9b2d-144223e57627', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('ec195b7b-3cd2-4200-8678-d3016cecca2f', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('687cf2b0-51f2-4128-8cdb-c460319a8411', 'b44929d2-3a68-4879-8639-6546d1c9f548', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('b33ab192-fdbe-4c90-a631-cb9c5287bbbb', 'b44929d2-3a68-4879-8639-6546d1c9f548', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('57104e84-c70e-47d3-b351-1a22a2e1c11c', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('ae6754aa-e71f-4091-9016-0f81b03e0395', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('16697d8f-fde2-4267-bd9c-a96261069664', '28f04c53-c630-49d1-8af2-f3cde837a516', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('805ee5bc-efb5-42b3-9269-a2f3265282ee', '28f04c53-c630-49d1-8af2-f3cde837a516', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c60c0d8d-0084-46bd-b3f4-efd561f8ef6d', '58b9196a-7093-49e8-82f1-6bd71921cc22', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('cf68d752-37cd-42c5-b46f-692081d71860', '58b9196a-7093-49e8-82f1-6bd71921cc22', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('881aca93-a5fa-4d05-ad4b-fc02ffc302f8', '6bacf64d-c627-48f1-8956-2f9f5476e047', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701'),
  ('c7db749e-c01c-41e0-b0c3-17274b715b95', '6bacf64d-c627-48f1-8956-2f9f5476e047', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cefbec6f-3f42-42b5-9b1f-db9712d80455', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('edd21063-7a23-4970-b4eb-43ab9cf81a26', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c29c4533-30b6-484a-b274-e9d47969a222', 'b9402498-7473-457a-8010-50103bb7dc44', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('84dffe4c-872f-4ebe-90b5-3c79ffa7546e', 'b9402498-7473-457a-8010-50103bb7dc44', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b67de61b-f16a-4c36-9978-996d8d9513aa', '7807d12f-bcfc-4391-80b5-8588cee543fb', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('e952abac-db5d-4997-917e-c6272916a95b', '7807d12f-bcfc-4391-80b5-8588cee543fb', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('be924a66-653f-4716-9c63-a1e7c2b11b0b', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('865b2fe8-eb34-4906-b0c6-c8be9780f876', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c005998a-7950-4b61-9a3d-7439c107b538', '536c950d-5e71-4511-8e29-39f40af7c7cc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('24175581-481f-47b4-9ea7-e615b90ec716', '536c950d-5e71-4511-8e29-39f40af7c7cc', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a572cdda-e94d-4e71-9529-6750401aa5b4', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('f56d5296-1b8e-42cc-9e04-fec8de707003', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9a3e6d4d-cabe-4444-86eb-a726cb0b1081', '121331ca-679b-4406-84f7-95ef8f4669d8', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('8666050a-dd38-45a1-b594-2063962aacb1', '121331ca-679b-4406-84f7-95ef8f4669d8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('64d89aeb-af1a-4afa-92c2-06e793b0665e', '04b6bf56-3721-4e88-81e1-1a9889d75a08', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('0fdae29b-62b5-4be7-87a9-031c6594cea9', '04b6bf56-3721-4e88-81e1-1a9889d75a08', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('489ab01a-4dd3-48e0-873f-bee75dd73e8d', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('d92725b9-3bb1-4187-97cc-3147d7af47dd', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d9c49329-bd98-45da-8785-865cfc11980b', 'ccdb6d59-c7bb-436d-801c-346952a049df', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('7357760e-9bc8-4378-bd50-ad030bc6a36b', 'ccdb6d59-c7bb-436d-801c-346952a049df', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('687f4deb-ef48-4925-8cb7-db8c758cb895', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('e8478533-7e04-4b41-a728-31bf8af09e07', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('71e40a1e-3fb2-4976-8ee9-fa67cea97549', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('cefb2173-96d3-434b-9f73-d4882384b87e', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('69e329b4-758c-4343-89ed-80186499a87c', '7d035123-7c88-4349-80a5-fdca105d0c22', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('6d586219-4a81-4a75-8b92-dd69d225be66', '7d035123-7c88-4349-80a5-fdca105d0c22', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b3ba9e37-0c34-4076-82d0-7730f3925618', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('765efe6f-0bfe-4100-89f7-a25dd6850707', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c290314a-0ad9-48e2-90f6-4602282fed76', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('2740e046-416f-4d19-b0da-8ecc4f72c864', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0195b710-86da-4e49-aba8-577b894daae3', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('5af886e6-ef92-41b1-929f-1d03329051e3', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f6f66c4b-ccff-4cc3-927e-40207d21cde8', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('e497d161-9d3f-4976-9280-e8e53043c135', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a1e23c5e-422a-4ce6-9c75-b82f31c8f398', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('865b53d0-f5d0-491e-8f07-a01834c66ed6', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e21d6a89-a284-4a6c-b9e5-ba8ec3da29cf', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('048f3e01-2ae5-40cf-a9fb-26a42dac571d', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6427afc1-6775-44f8-8dde-5a794f19e1c9', '29641fce-744f-48b2-8102-d1f234d2dddc', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('b93950fd-39a9-478e-838d-5c5c271c168b', '29641fce-744f-48b2-8102-d1f234d2dddc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8b858fa8-a02c-4aee-a21c-035627927d48', '96a1189e-373f-4de5-81f7-3869b7486f77', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('4486ddcb-cc49-439a-a780-0776e159280e', '96a1189e-373f-4de5-81f7-3869b7486f77', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6178d41c-b453-45ed-a3eb-d7115a504c47', '471ee4f9-72a6-4432-8aa5-a3740830921f', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('f1d7faa0-6fef-4f60-99d1-d03977ab47e2', '471ee4f9-72a6-4432-8aa5-a3740830921f', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3fffcedc-98fd-43e8-b0c7-b557192c6332', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('7642acee-f900-4215-a534-6dd2093b5069', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5efcf94e-012c-4344-a100-5ee139254461', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('5828ab05-73d9-487d-a061-c10dc485eec8', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('27069bd6-5585-4ce2-acd4-c0b2b7b893be', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701'),
  ('88a017c6-41c2-4f69-bef5-920557a23b31', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('59c41a19-e163-48dc-bc7d-fab72ddd4615', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('2a8427f3-98e4-4446-88bc-5cbd0dbbb3aa', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701')
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
  ('26122e5c-a5b0-45a4-a286-138dcbd9f1a0', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701'),
  ('76464618-ebb0-45e1-96f8-2a3e4989f239', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e6454909-3186-4d5a-91bf-0ce6d40b661b', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('a1694051-c5ac-40e7-8107-dd6ed55c6b23', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c8bde6c3-da4c-460b-9b58-fe1aae7295db', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('c30b5cea-4845-4667-9d97-15fdfe301f91', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5e6684bb-ca98-487a-8bc8-70552aab657b', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('1495a5e1-7ea3-4581-be91-4e2a4b66ff04', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3356bb8f-5cd3-46c9-97b5-e2f6702e4c71', '8a557316-f880-44f0-8028-97b52d290cae', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('dd8c4fa7-18b8-4c1f-80b7-c9da0f1f940c', '8a557316-f880-44f0-8028-97b52d290cae', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fef33006-f558-4812-8ff4-e335e4f98a1f', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('1d32ed8f-a03e-4452-9b5c-767d8d19203d', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a86de661-c4f1-4067-a078-7f84223d27aa', '44687709-00cd-4828-8492-eb117a75be45', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('30265003-99ac-469e-a1e4-cce929a5ceaa', '44687709-00cd-4828-8492-eb117a75be45', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5e2861d7-46a3-4032-9d39-7b504b1b47e5', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('9b41c41e-14f0-4582-961c-3f855fb0ddd7', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4a1e357c-50f2-4b86-a41c-803bc00a3180', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('343fa94e-3c3b-4d8e-a94a-a24b84c53c7d', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0204e255-d671-4678-b46b-ffa58ec0a856', 'bbb552d5-3241-4dca-8824-69be1f232855', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('08d4f5be-6356-4b41-a4da-81e2b1a77b4e', 'bbb552d5-3241-4dca-8824-69be1f232855', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f7ded879-d834-48a2-b561-081881935374', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('f0789fed-8c34-4d52-b8bb-41ea998c6eb2', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5025aa16-5e91-4658-aab0-2158e4d6070c', '628a1237-b966-42f2-8927-678809d67be4', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('35a2430d-3ae9-4d4b-b788-8ac1776d77d0', '628a1237-b966-42f2-8927-678809d67be4', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f15be561-912b-4ae1-a4f4-c8490c555b93', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701'),
  ('3f14e4fa-b162-4fd1-9dff-0e870057e35a', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b11e3c94-cbec-45fe-b329-2c9a24f28e69', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('7ca999f0-048e-4852-a485-6c9cbd1a0559', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
