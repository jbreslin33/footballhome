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
  ('27adb266-a348-40db-b245-e5d7fd3b43e6', '62d30cd4-fb69-4a97-84bd-0e506564c188', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('d9b9d1a5-f385-4bee-ab0f-354bd6ae215c', '62d30cd4-fb69-4a97-84bd-0e506564c188', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c1d812a0-3a87-4a0e-a3f4-e6da4461db4f', '2537da99-8f86-4c23-81f7-b0ea2621bb05', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('ae4572ae-43cc-480e-9a9b-4f580d8505ba', '2537da99-8f86-4c23-81f7-b0ea2621bb05', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bace7f76-dd8d-4c6e-a44b-d16549d20c48', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('51d5e2a2-fc73-4f3d-b2fc-4340476d779a', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81a10fb5-326c-40a4-8a85-977bb7a4604d', '4d734c38-ec21-47a9-8b6a-1e8395f2afc1', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d3e0d752-a63a-4488-8d3f-8d5645a5fd57', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('24c075e2-14ed-4b0c-b4c9-f045cacdbfba', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('24d84ca5-c146-4dc6-b8d7-067d02e06caf', '4d524c17-9d79-4153-8a04-7aeab379e450', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d5a87395-bff4-40a5-9a93-408aa53997a3', '83d619c8-bca1-42a1-8b4f-096d80083a5c', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('5811b4df-46a2-4f99-a1e3-6873c2188280', '83d619c8-bca1-42a1-8b4f-096d80083a5c', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d87d6942-c8d3-431b-bbdb-7320e7e1b80d', 'fc19745e-b7ac-4b64-8731-a256613e1534', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('13557b7a-fac4-4c0b-8cb1-33ef71e91bbf', 'fc19745e-b7ac-4b64-8731-a256613e1534', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c0436fc5-2cd8-4eb8-bbc8-260862134c93', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('1c07b195-afec-4a09-a3ac-4b4024718732', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5a2373a9-1be1-4cf5-ad79-db35c0989375', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('e728ce5f-7559-4cdd-968f-f78fa531bc13', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3395aca0-32a2-467c-b681-9b540336d2fa', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701'),
  ('87b8f792-f661-406a-b371-8c368f48461b', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('74648a45-15c9-4264-a4d2-920c96dbe5b2', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('14a1ef2e-c7be-452e-b8e8-966578125b66', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('958b8ee9-9c1f-4821-b59a-b6abe73782a0', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('5639f50f-5006-4e80-9624-105ecef0d5dc', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('343d4a3d-0584-4347-8bb0-f5ac16341ac4', '8165bc74-cfe4-495b-86e4-86702b0dbf41', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('1e11a3ed-6b4a-4db3-a9cd-eddd82c9450b', '8165bc74-cfe4-495b-86e4-86702b0dbf41', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1d6060d2-66fe-401c-9f8a-dd70d9a45cdb', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('9d69f3b7-d8cf-4436-b2ed-b8776cb2468f', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('93ecd5c1-9883-4cac-80de-91d7311fc9e0', '91a9c8b7-406d-41de-8df6-8607f59396cf', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701'),
  ('ee83b420-531c-401b-bb04-61f69483400f', '91a9c8b7-406d-41de-8df6-8607f59396cf', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ceceb192-6ba5-403c-a5f8-778fb6a29361', '52f4814d-e1a3-468f-89bd-6e02155b6129', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('76446b69-0447-4efd-9c39-3e356c2148b0', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('f90d05cd-f82a-4287-b742-cd18dbcd789f', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c91f4fbf-1827-4d00-a2d0-ec6036c9a60c', '55b1a2da-7521-4691-82ae-831d929ec711', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('9ed68549-7ef6-4ed4-b2f6-6ddfec442e35', '55b1a2da-7521-4691-82ae-831d929ec711', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('432d7a74-9838-4150-bd70-2e9feb31b74a', '34bb814d-67bc-489f-8c94-2198057fb592', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c9ca69b6-9fca-422b-a504-4566b033e46b', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('96cfffea-02d6-44fc-a87c-ae84a838d6bf', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2c2b4b74-6d02-4775-83d0-9edcd2903e2e', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('85875419-b8a0-432b-8ef4-342e7387e399', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7aad7212-ba50-47b9-a7b9-81514356d48e', 'e082a5b2-71e3-474a-8256-16ce76e60795', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4b0c8bf5-c631-475e-af82-43a9dfe7be78', '91ebabec-ce77-47e8-832e-99263cba41e6', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('71c5a446-21a4-4291-9ad1-9ebf1c97b7dc', '91ebabec-ce77-47e8-832e-99263cba41e6', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('85a0a3e4-9a43-4220-8fd4-5cb7872882a5', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('3e51535f-74ba-4ba6-a921-4e786bb42b54', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('41c10138-9e6d-4ce1-9f2e-527ecb671e67', 'abcbff6c-c508-4198-86c6-d093e886f9d7', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('f3166ec2-25ea-4745-a696-6f5ddd7d99ee', 'abcbff6c-c508-4198-86c6-d093e886f9d7', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4bcfb354-549f-4094-b8ae-8560b8176087', 'afafacd7-d142-4996-881f-cbade4ac2ca9', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('6f7bde7b-29ab-484d-ac9f-711c9ae7ed8b', 'afafacd7-d142-4996-881f-cbade4ac2ca9', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e729eaa8-2bbe-4107-b123-d76b60ac90c0', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('63b37614-cfa2-47cc-a66f-55e8ba72c9b5', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bc8e05bd-ec7d-463c-a55d-77369d742765', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('6efffa9a-4917-4e20-8863-18fa2ae2e60e', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e54f97f6-cb5e-4044-be1a-dd4afdba1ba8', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('36df5994-328f-4b81-b385-51a954515d86', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a5bf9045-d422-45e4-bebc-154b2fd66f6a', 'd5e6fbec-5173-4a03-83ad-97f5620f579e', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('74c9f964-fa1b-419e-8198-22b729044903', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('a03b5b11-d573-47b4-8767-70b9c04aa583', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1eeb9291-f09f-455e-9f38-474d7c1909fb', '9885c815-fde9-407e-861c-06510f86d8df', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('4098f228-7e23-4162-acf9-7c50e3c1c656', '9885c815-fde9-407e-861c-06510f86d8df', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f735dc0e-21c8-44e0-b6fe-d21875022cc8', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('595f2f65-d4ec-4a54-949a-32780a484ace', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ca2fedb4-9265-4085-bc74-a3c51287c559', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('39704b1e-a696-4284-bf85-0b53c2ead888', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('685f37a6-e616-4805-809b-f02da3345fac', '9577b205-2607-4ba5-80c6-494adbbfeea4', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('ae8f7156-c4b7-4860-96ba-d162f76936a5', '9577b205-2607-4ba5-80c6-494adbbfeea4', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('058f7e81-035a-4689-bc69-2669eff5018f', 'f887a773-2b54-4713-8b04-8ca7a7721cce', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('7d0e0add-2241-4fb4-9a55-c57175cff768', 'f887a773-2b54-4713-8b04-8ca7a7721cce', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b2d3f208-2bb1-4511-b53c-91e885e12d97', '581c00d7-bf32-4533-8032-a953bf35aba8', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('78d541e7-172f-4228-9b18-b9de031abe3e', '581c00d7-bf32-4533-8032-a953bf35aba8', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cbc858a9-7799-4be7-a754-19711c6083a2', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('8c0107f4-faf8-449e-968c-def9a74d79a0', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701')
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
  ('17608c34-f705-492a-be3b-efb158b85cc1', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('cbb606fc-6bff-4d35-a1e4-2ff29781c335', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dac15a72-d86a-41b9-85b2-a6c6275894c4', 'b44929d2-3a68-4879-8639-6546d1c9f548', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('2c4f7484-8f9e-419c-a07f-418a39b9a82f', 'b44929d2-3a68-4879-8639-6546d1c9f548', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2ecf4680-6f2e-4777-b254-e483e13d90cf', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('ebf68d01-5722-4998-b23b-29b91469a928', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e6212c88-62dd-40dc-9722-41351df1b12f', '28f04c53-c630-49d1-8af2-f3cde837a516', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('7b8f6ec2-89dc-431f-bccd-ae70374877d8', '28f04c53-c630-49d1-8af2-f3cde837a516', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c21b3be2-07d8-445d-af18-babbfda659de', '58b9196a-7093-49e8-82f1-6bd71921cc22', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('f2047df3-8105-448a-8792-1c735b664243', '58b9196a-7093-49e8-82f1-6bd71921cc22', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2cf7e6e5-5131-47a1-ae9a-fba19d4cbe26', '6bacf64d-c627-48f1-8956-2f9f5476e047', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701'),
  ('0f4a8b4a-a92b-4792-810d-25b0e63ead67', '6bacf64d-c627-48f1-8956-2f9f5476e047', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9da31922-4ff2-48e8-8815-5ff604907a91', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('bd7cfd14-cb1b-481f-b889-c852918e8ab2', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0b540bd1-6444-458e-b41e-03d86e656362', 'b9402498-7473-457a-8010-50103bb7dc44', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('386503a5-bac4-4f40-9e02-23e68010ed83', 'b9402498-7473-457a-8010-50103bb7dc44', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d26902bb-58ef-4cf2-8835-894e45a6f6c0', '7807d12f-bcfc-4391-80b5-8588cee543fb', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('6a8a7e69-85c2-4eb5-a8a6-632d867384a9', '7807d12f-bcfc-4391-80b5-8588cee543fb', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0ae0c21a-6a4b-4606-a3be-48bd00c4268b', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('76693c7b-094b-4df5-84fc-9004ecb22436', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1b4ebbce-e35f-494d-a29f-d61af15d80ba', '536c950d-5e71-4511-8e29-39f40af7c7cc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('072883e3-2082-44aa-be0c-be0d91ce40b8', '536c950d-5e71-4511-8e29-39f40af7c7cc', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e23cc1d5-09a3-4bd4-97c5-44c95958b64e', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('1e367948-58fe-404c-871a-14c0eab4d1ee', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9784d02d-0551-4f5c-94c6-07d4aa2bfae3', '121331ca-679b-4406-84f7-95ef8f4669d8', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('11ca42ef-d7b4-4eec-a1d8-d966b3e095fc', '121331ca-679b-4406-84f7-95ef8f4669d8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('53946b26-fbb3-4ea8-b7e1-f8a9de583aa1', '04b6bf56-3721-4e88-81e1-1a9889d75a08', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('ed74ba62-457e-40ec-a4e8-1d829ccd7165', '04b6bf56-3721-4e88-81e1-1a9889d75a08', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ad39fed7-51e2-4b17-b471-d58a8400b58b', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('b36f378a-0575-415c-88d3-5c7459a1993e', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f6b584c9-a41b-4d86-b139-0f096647c397', 'ccdb6d59-c7bb-436d-801c-346952a049df', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('68101986-a17c-468d-8bd5-487061860e69', 'ccdb6d59-c7bb-436d-801c-346952a049df', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('69d641ee-c6be-40ed-ba00-6fdfeac10771', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('172a32f2-3d44-4dcc-abd9-66121561ddac', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1c213f24-d8bd-4455-b470-c8de04744278', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('e0ca4730-4f46-4b5e-8c0a-9d257822b8fe', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6216485c-a11d-4aee-8a46-ad0b00b2bb7a', '7d035123-7c88-4349-80a5-fdca105d0c22', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('80e34539-41f8-4457-be6d-9fa03797b513', '7d035123-7c88-4349-80a5-fdca105d0c22', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0bab3d86-b8cf-4388-a498-3e2d9d268707', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('8c4f0638-d578-41d7-8127-045c827855c8', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('082f8462-e4c5-4a84-8b94-e25b43d8d890', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('c964ec61-9559-4ef5-975a-cdd2f0a02e11', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a36d8280-865a-4d21-8dca-828a22c7e466', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('ad8845cb-c8b2-4fd9-8c8f-c5567b612094', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4a007c7e-233e-4ae4-913a-6167f68ba56a', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('ed8ae96c-68d9-47b0-ad35-e2619624ba0b', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1549c924-9a84-43b4-8caf-97eceed1f72d', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('f7aca30e-771e-4120-8a4e-b19658f56908', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7286809a-7923-44fb-b458-fcd87d2d6245', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('2ab29f94-793c-4f55-8543-c93036f664bd', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a1f96d05-07d0-4824-9790-ca61d2c2dabd', '29641fce-744f-48b2-8102-d1f234d2dddc', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('e1344dc9-6e93-4c41-ab6d-953a2a732163', '29641fce-744f-48b2-8102-d1f234d2dddc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e22852f7-7e22-4082-bcc5-4c38e4117227', '96a1189e-373f-4de5-81f7-3869b7486f77', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('8ac1f083-aa0b-479b-85cd-855c62cd4cc8', '96a1189e-373f-4de5-81f7-3869b7486f77', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8cd792fc-a60c-4617-9c51-8983a88766ce', '471ee4f9-72a6-4432-8aa5-a3740830921f', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('8f822222-0045-4180-a22b-db5fb8ba8485', '471ee4f9-72a6-4432-8aa5-a3740830921f', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e6e76921-f3dd-4ece-9687-e3fba73c8271', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('aad5a248-6525-43b2-8630-c07e3406335c', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('490403aa-49f5-4b0d-a0c9-e6cd1713b199', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('c0fdc64e-974b-4bd1-907d-892d2ee85bca', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d785a342-db39-4178-9a82-659336fa700a', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701'),
  ('96e0b017-f10d-49d7-8a54-64e8d6ab5307', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a0d773d4-fb85-492d-9522-7b6405a78532', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('968adc1f-2a19-4eda-84d8-d98977437b81', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701')
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
  ('05100083-eff0-42c3-9454-bd7d4d6ea9ba', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701'),
  ('253c1331-aa83-42c0-8317-0b3b38bc05ad', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('93dfff7d-e27d-403e-aab7-2600760ce062', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('a68a1ab3-bdff-46b0-972e-7cbe1643bea7', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9f495a6a-a183-494f-9690-9781594f30cd', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('b361ba11-2b7d-453d-b2b3-cf0a8a78b915', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('119dc42a-2880-48ef-9dd2-56160dacf946', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('0b9f4b19-62eb-45e3-814f-eb97acc3dd78', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('67bc7cab-c4fa-4b14-8a0b-74f49a5a717a', '8a557316-f880-44f0-8028-97b52d290cae', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('88547d3f-d6c2-4735-9000-985a67b2c818', '8a557316-f880-44f0-8028-97b52d290cae', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('236c9533-17c0-47fe-b539-c20ebe61d2b6', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('3124a624-02b3-4317-a434-5306c3d91177', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6a3bf10f-4a32-47d1-b9c5-b80a76e512f6', '44687709-00cd-4828-8492-eb117a75be45', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('64684de5-eb7a-4dc3-aab2-a78d4f241033', '44687709-00cd-4828-8492-eb117a75be45', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9748610c-2697-4fe0-b148-20e5e828de33', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('ed6d97bd-bb55-423d-9af6-e32e2f718110', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c7bb5c35-78a2-4806-a18a-d96c2dfd0d95', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('ae8e5e71-8bfd-4a6e-8e19-b420e002da1d', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8628e9b2-38b6-48d5-9bff-75c55650accb', 'bbb552d5-3241-4dca-8824-69be1f232855', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('cb2ffca5-b348-4263-982d-009c51c0a77c', 'bbb552d5-3241-4dca-8824-69be1f232855', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('77048076-ff10-4762-b440-84930c074be2', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('103e7b06-c000-4dcd-b6b0-66a346cacbbc', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('416d82c5-01a4-4b65-883a-c18339206b6b', '628a1237-b966-42f2-8927-678809d67be4', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('242836b3-f69a-45f3-b22e-30e0e3214796', '628a1237-b966-42f2-8927-678809d67be4', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('23537496-d43e-43c5-b70c-88962fd6f1d6', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701'),
  ('83c7dc8e-b24f-4109-a119-6388f4763ce0', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4e09300c-4191-4120-8ead-5cdbff74296a', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('f8500847-0c12-4220-a6f8-176fc130f054', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
