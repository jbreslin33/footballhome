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
  ('cbe0747b-62af-423c-b089-78825ac5375b', '62d30cd4-fb69-4a97-84bd-0e506564c188', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('a53766a0-1193-496e-b52e-c084c3324ddb', '62d30cd4-fb69-4a97-84bd-0e506564c188', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9e28b8a6-1f8f-4e23-bfe4-aadf7a9eba40', '2537da99-8f86-4c23-81f7-b0ea2621bb05', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('2ff85662-f2ff-426a-8c50-efe756cb6fea', '2537da99-8f86-4c23-81f7-b0ea2621bb05', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c3969c05-a1ad-4bfb-ad22-a2b74c1cc114', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('567cdf08-1e25-475d-8423-e51732df8c56', '49f8304b-9d17-4990-82c5-c29a7fa32ac5', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('eb50d983-796a-44a6-89f1-363d32b936e3', '4d734c38-ec21-47a9-8b6a-1e8395f2afc1', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aba1d241-0aec-4cdb-af8f-07f245ee6ae8', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('c64f75c0-26f9-4eca-8fae-6b176ee6af48', 'a2da5631-8d20-47c6-8c65-e39aa953fd8c', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ae98b375-0b05-48a3-8aeb-8ac05ec80163', '4d524c17-9d79-4153-8a04-7aeab379e450', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('78a8bc0c-4bb1-463f-9397-0b0530c70974', '83d619c8-bca1-42a1-8b4f-096d80083a5c', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('8bd10920-cf4f-4bb6-b2cb-69f2d6635a79', '83d619c8-bca1-42a1-8b4f-096d80083a5c', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4dca42df-c14a-47bf-a5f7-689646c9d98f', 'fc19745e-b7ac-4b64-8731-a256613e1534', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('5f3508ee-988c-4f3d-92a8-c89a93262ade', 'fc19745e-b7ac-4b64-8731-a256613e1534', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('67f585f1-65e2-45c3-be65-5d4caac94a3f', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('73d779e5-3a9a-4ad1-b022-21532709bb09', 'eca34b29-7579-4b19-8833-5f5acf847b86', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d1a0c9c9-863f-4cf4-b7d4-2d39c2cba671', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('c8860cff-abf1-4455-bb31-b6d466c404c7', 'd21597c2-6129-466a-8e93-2ac187d2fd9e', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7ee67c92-6a5d-48df-9775-ba1873384be2', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701'),
  ('4660fa81-11c0-4108-92b5-9737415ab3ba', '3a2d7ecc-fa9b-4169-874b-72b07ddf204f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9e10d055-5d95-4257-928d-bb3ec0aa6d42', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('2aefd3aa-af1d-49fa-942e-6c82f27c5b31', '3ad04f53-81ed-43b8-8b7e-fc544d239d67', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b3306ee2-0fd5-4631-8ef6-7252469a3d80', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('0d1c0ad6-9c9a-4162-b041-51846aa220df', 'a652c999-a49e-4a94-8cd9-1d098cf426f9', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('da56ab90-5d85-4ee9-889b-815b2670695f', '8165bc74-cfe4-495b-86e4-86702b0dbf41', '3a2468dd-a31c-456a-88a9-fe7699d2b079', '550e8400-e29b-41d4-a716-446655440701'),
  ('7c6b4ef8-6e5a-43b7-9406-854bab051178', '8165bc74-cfe4-495b-86e4-86702b0dbf41', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e23e8e6a-4350-458c-8c45-671e8f83158c', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('a1b110fe-0bff-4692-be22-1d2ff9f4e458', '2517d2fd-90c5-471a-84de-4f7d3ec058ec', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('822651bf-c6bb-452f-bb53-0373b5b1ecec', '91a9c8b7-406d-41de-8df6-8607f59396cf', '158e321e-2dd5-4926-82ce-c31822bde965', '550e8400-e29b-41d4-a716-446655440701'),
  ('fd09ae0d-dfe1-448c-8dfd-cc3dabdbb510', '91a9c8b7-406d-41de-8df6-8607f59396cf', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d5d8897c-f755-4d79-88bd-3e1674af1111', '52f4814d-e1a3-468f-89bd-6e02155b6129', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4ac4333d-5d1c-4048-af42-8c5539788c86', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('d3f05858-811f-4dd3-977f-e8c92d77ee5f', '4705a186-2ec4-4a63-8c68-f2921e2bc16f', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('707e359a-1a2e-49f8-8fab-977fc6aa2947', '55b1a2da-7521-4691-82ae-831d929ec711', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('e9494faa-1478-4c07-9a1b-363b937f1234', '55b1a2da-7521-4691-82ae-831d929ec711', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3d85b5ee-6efa-4bef-9515-66528bd4dd8f', '34bb814d-67bc-489f-8c94-2198057fb592', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('038180fb-40e4-4baa-8b4d-4a2cbfcd68c9', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('cca969e7-69f9-4b2e-8211-655887dd18c3', '69b364be-8f29-4a83-8fb9-69c70a476f67', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f9df5d25-b346-4e3b-82fa-d58f9b0e8d59', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('06f46b0b-4c4f-4c0f-98f9-bf01b3ab2ced', '09e2955e-5f2f-441b-8fb0-d033f67dc791', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f4066128-0d35-4266-b097-640ef72367fd', 'e082a5b2-71e3-474a-8256-16ce76e60795', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('63f951da-0919-4e4c-9c1a-df457f105ea2', '91ebabec-ce77-47e8-832e-99263cba41e6', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('ada6c9f8-0376-4fbe-8291-9034c908fc4a', '91ebabec-ce77-47e8-832e-99263cba41e6', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('991499a4-9ced-4383-8bdc-2ebc7d94ab23', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('6ea4ab7f-3d01-416d-8c29-fb05420ed5d1', '65ba7c5f-18c6-4fb1-8eca-963156acf6f3', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('424cdba2-18df-4583-914c-2d1bebb1002d', 'abcbff6c-c508-4198-86c6-d093e886f9d7', '28134f76-23f8-4e68-80ce-9f9ab2a3942f', '550e8400-e29b-41d4-a716-446655440701'),
  ('f66938ad-e09a-4ac2-b521-75328d410f51', 'abcbff6c-c508-4198-86c6-d093e886f9d7', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a72fcea6-82ca-45b3-9d81-5c04de2a4372', 'afafacd7-d142-4996-881f-cbade4ac2ca9', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('7bf4d0f3-0387-451b-bed5-9764e52cc3dc', 'afafacd7-d142-4996-881f-cbade4ac2ca9', 'bbef7779-4ba7-4939-891e-6d6f96a34577', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5a2e3336-0b5f-4f4b-ac45-00c8d16c4fb9', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701'),
  ('8db7d573-f0c1-478a-af26-40e17a697e3e', '81da90ed-f792-4c81-8f6b-4e74349bea1d', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bd191b2a-ea50-4ba8-b946-93d62ef86f62', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('2acb7330-bbef-4c70-ba6c-dc3a75cf7418', '1ef4683f-b4d8-41d6-8c35-21df11a48cff', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f839ca7e-aad5-400f-a969-7a9ed98e6666', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('63cfd8c6-4b69-43b4-b09e-002636a402a4', '65f7a58b-d5f2-4aff-842b-49089f156b53', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8e2b4f1c-f3dc-4b1f-9e4c-fab55ffe9bf5', 'd5e6fbec-5173-4a03-83ad-97f5620f579e', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2fadff29-4d93-422c-8f06-d42b6cd79fff', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701'),
  ('8e6c73e6-ffa2-442f-a4a9-63a5cef6f25f', '1a769bff-9ff3-447b-85c7-d57d62d5dcfd', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b589f662-9014-475b-8942-01f1953bb3b6', '9885c815-fde9-407e-861c-06510f86d8df', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('72d4541e-7788-4e92-a1ee-5da9c5404522', '9885c815-fde9-407e-861c-06510f86d8df', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('000baf21-75fb-4b03-be98-e4d8138cf21c', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'aad58707-7310-4751-86c5-e403a28757f4', '550e8400-e29b-41d4-a716-446655440701'),
  ('298217e2-fa74-4ed0-b805-145a84cbfa5a', 'ce16612f-bb54-4993-875f-e511bac9c82d', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fa8ba2c8-1d5f-42f6-bdd5-bb2d6a9592e9', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da9e701d-7752-495a-8145-fe967b40c0d3', '550e8400-e29b-41d4-a716-446655440701'),
  ('06beb434-2544-4a50-87f6-5a6c87747745', '3ac0f639-cef4-4ab4-8eee-8818085b4cae', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701')
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
  ('63bdd11b-f0c5-4612-8a63-15c7b7f18c04', '9577b205-2607-4ba5-80c6-494adbbfeea4', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440701'),
  ('c319089d-2b81-4b7c-aef9-8b9cf85e6fb9', '9577b205-2607-4ba5-80c6-494adbbfeea4', '57d88568-993d-4411-8aa3-6244ca7ff704', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d2d62996-f4ff-499c-8c67-4350ee73b74c', 'f887a773-2b54-4713-8b04-8ca7a7721cce', '0033b87c-9650-4c9d-80b3-69ec4751c7cc', '550e8400-e29b-41d4-a716-446655440701'),
  ('1546e7bd-f302-4287-a475-9801e3c8dc5b', 'f887a773-2b54-4713-8b04-8ca7a7721cce', 'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1826bb37-e261-4c58-b3ce-f25fd62a9e4c', '581c00d7-bf32-4533-8032-a953bf35aba8', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('fe760cc0-33ae-4639-a198-86db88a61a9a', '581c00d7-bf32-4533-8032-a953bf35aba8', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('19cdab14-d611-44df-b143-2e0db359b76f', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('178558bc-74f3-46ba-a550-7c6f287f6cf4', '97175e59-2b10-47ac-8ef7-d276b0aafb77', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fa8bb095-7f36-4c59-ad30-0c5d74e835da', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('e113793c-2d25-457d-aa7e-3a0c60245f3b', '0aaa8905-7f99-4ea2-8829-c4991fcb539f', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5ea4d816-2220-4b9f-8d4a-5d30ad0b9701', 'b44929d2-3a68-4879-8639-6546d1c9f548', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('d190d83a-8ac7-460d-a0b5-e3e6dc8fd078', 'b44929d2-3a68-4879-8639-6546d1c9f548', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('259d7610-dd8b-44f3-a6af-1da17744eae1', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701'),
  ('0eba75e9-72c1-4f0f-a96a-818c60f8aa57', 'ce0a90b2-65d2-4ce1-8109-77dfc72d6b7e', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4429d5c4-0d02-4267-b11c-5d3eb4395bef', '28f04c53-c630-49d1-8af2-f3cde837a516', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('5399e3d1-6a1b-4f93-88e7-ab464757a250', '28f04c53-c630-49d1-8af2-f3cde837a516', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701')
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
  ('47df054e-c2e6-4d4b-9a65-f1c63efccfdc', '58b9196a-7093-49e8-82f1-6bd71921cc22', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701'),
  ('cff3ed36-ef07-44fd-9cf6-7a4a728e0d7e', '58b9196a-7093-49e8-82f1-6bd71921cc22', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('29c6b43c-0f4a-4dbd-a4b5-2de4572f93d6', '6bacf64d-c627-48f1-8956-2f9f5476e047', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701'),
  ('0223a8e4-57c0-453f-bb37-0dc205bf6525', '6bacf64d-c627-48f1-8956-2f9f5476e047', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cf2ee344-bf1d-4eb4-9fa4-6a5603d3ad1b', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7', '550e8400-e29b-41d4-a716-446655440701'),
  ('7bb6c6b7-e399-439c-be87-70aae23e572a', '53389dfc-19cd-4eca-811c-61e5f1dff3d0', '2bf2f14b-8e84-44ec-825c-bc6031d385de', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fe8dd65b-3d0a-4e9b-b5e0-3f51628a2121', 'b9402498-7473-457a-8010-50103bb7dc44', '895ff6df-959f-4a46-80c9-fbef6eed5b78', '550e8400-e29b-41d4-a716-446655440701'),
  ('2868539c-deb6-49e2-aea4-8d9d1625ca8b', 'b9402498-7473-457a-8010-50103bb7dc44', '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f106b805-c86f-4e3a-8fd5-d95ac984eb20', '7807d12f-bcfc-4391-80b5-8588cee543fb', '3ded57de-85a3-41e5-8b3e-87ea2a84de13', '550e8400-e29b-41d4-a716-446655440701'),
  ('5156eb52-4b04-412d-901e-aea344567ce8', '7807d12f-bcfc-4391-80b5-8588cee543fb', '9795925d-4af7-449a-86fd-e27cdfe9eced', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cf1d41b5-4fe1-4e59-a9a8-f1d2fe383c47', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('3844fc25-ecab-4e59-b1f8-9e040bbf9da1', '345f0215-c3c6-419f-8b1f-5e6d8178af5d', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3d4e8bb3-9206-421e-8d24-8b04e439d512', '536c950d-5e71-4511-8e29-39f40af7c7cc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('cbb0800d-d2d4-407b-9309-17e2a218b62b', '536c950d-5e71-4511-8e29-39f40af7c7cc', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d1ba9c41-4753-46da-89e3-7db5c3244ed5', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('f0d5b912-95de-49cb-b561-b47b555cc3f5', '2752740a-b05a-4c4e-8137-1c7d0a03b5ea', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('77a76db5-dcef-4dff-bd8f-93d7934c66d4', '121331ca-679b-4406-84f7-95ef8f4669d8', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('f6fb693a-2288-4e2d-b60a-731df4ff9052', '121331ca-679b-4406-84f7-95ef8f4669d8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('844745c3-9793-490f-8d22-6bab80d44d2c', '04b6bf56-3721-4e88-81e1-1a9889d75a08', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('b2397c0b-6824-49eb-ba88-ccb58147a286', '04b6bf56-3721-4e88-81e1-1a9889d75a08', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4da40b8a-6a4e-4121-960d-392027ab3985', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('f2c27c5b-df8c-4408-9f8b-692d98211b6e', '6b61f8ad-b3fe-49b8-8fd5-3f87cf720205', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2f5024cc-1ad8-4d26-8656-67cadd9ab77f', 'ccdb6d59-c7bb-436d-801c-346952a049df', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('baaee87a-dcb1-4c22-8305-7c858ce1c1ec', 'ccdb6d59-c7bb-436d-801c-346952a049df', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('854173cf-2477-4238-968a-83a298ff8fe1', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('3ef4f165-827b-49da-b76c-aca60183eaee', 'd0398281-b2c4-488f-8cf2-9b1a5e52d373', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('331e2f52-a21c-4d32-8d94-3796f99d5c36', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('0eb98498-bde2-4470-bfc0-6c9de3aa0cb1', '3166f851-6d5d-4d21-8b24-b4a114a0d7d6', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a87b5f9e-1fc1-4452-ac5a-1206881860a7', '7d035123-7c88-4349-80a5-fdca105d0c22', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('79bce13b-b430-45df-ac0f-dc8fc7a4ca69', '7d035123-7c88-4349-80a5-fdca105d0c22', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cfadaf39-2e65-4973-834c-ebb46e8a20a8', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('3500958b-ea51-478f-9546-4fa0f9d9a961', 'ff8f2f8c-4a57-4823-890a-44e19272bac4', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a995a7ff-acfe-4f55-9f7c-416518f70f7e', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701'),
  ('3b3d3c85-8dda-4143-8e5d-d899e6c68abe', '7f3c7055-8217-4efe-8b6f-c426f8e4804c', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7eab034a-9b75-4bdc-8117-a8e1507de78d', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('a166a0ac-847d-491b-a3dc-d55899f71faf', '7dbf50e1-dc5f-45a8-895f-962cc2187b96', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a73e4b30-a3d7-4532-95cf-517b5c2c78ea', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('534f8230-bd7a-48e3-9ce1-d738070de000', 'b249c4dc-4ba3-42f5-8281-5819e4dc67a7', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701')
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
  ('724b6108-a879-40e8-9566-080ce0098ff3', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('461b7acd-91c1-4093-9e38-7f2ad9a8a392', 'e97dd3af-d2fe-4679-810a-2b5758f7b6e2', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2d91724b-6818-42b4-87b6-83421662a4a2', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701'),
  ('0459f102-05af-4b89-8d46-36fb843a7b15', '41ccaddc-8057-4d9a-8821-ad5657d9b6a9', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1c1873da-acd9-4d44-93e8-67f85d9fc78a', '29641fce-744f-48b2-8102-d1f234d2dddc', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('d1c90d7b-fc42-487d-80cf-d7e5ad92210e', '29641fce-744f-48b2-8102-d1f234d2dddc', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e77e512e-95a7-4ee3-8dd4-39723b4fe7b3', '96a1189e-373f-4de5-81f7-3869b7486f77', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701'),
  ('1149920d-6b84-4b7f-b33c-c000126fbf40', '96a1189e-373f-4de5-81f7-3869b7486f77', '9dbe9c4a-6108-44fc-898d-33defc0155da', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1eb027e1-b92a-45f2-ba8a-3972d6e30df9', '471ee4f9-72a6-4432-8aa5-a3740830921f', '525d469e-dbdf-475c-8bb3-ecddc849cfe0', '550e8400-e29b-41d4-a716-446655440701'),
  ('6c3474dc-f068-4771-8066-4e36f106be29', '471ee4f9-72a6-4432-8aa5-a3740830921f', '5541a60c-6517-4e66-8c25-a513298fd487', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8e91742f-7af5-47c0-a51d-58c200db210e', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', '1b742914-50d5-4105-81b9-f980ec0fb53e', '550e8400-e29b-41d4-a716-446655440701'),
  ('8e2ab85d-a90a-4aac-b42f-9c867d248272', '6a283f17-da54-4e7b-812c-3299d4d9eeb8', 'c3bfdfa9-ce51-4af4-8c64-778323eff661', '550e8400-e29b-41d4-a716-446655440701')
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
  ('91a86413-1331-4493-b14a-9495a1ad25e1', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('e4478b43-5e79-4ccd-9d8b-816065a70827', 'c6e5a74c-05c9-4ddf-893c-79eeae92b9a3', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('933a588e-db6c-47fa-8241-c0f4e856fa90', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701'),
  ('dedc482b-f625-4bc7-98e1-72bde15e6b43', 'fee5ff6c-fa94-46f2-87ed-014d3f9d164b', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0b012f96-4be3-412f-aa24-fd7ec5c5127d', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('8b85a474-2624-46ce-84d4-525f930b8a32', 'a9299cdb-4795-4ae2-8563-c3b062d9aa9b', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6703fd09-07e4-488f-82cb-b6b9ffdc76f4', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701'),
  ('3c7ca470-4e43-4d5f-8de7-1e1c5e033efa', 'c888f4f9-395d-4d8f-8ee4-39e99c27ae7b', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3e5e0013-f775-401d-bb2c-bba59064ac3f', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('dcdc59bd-820c-4f1a-98f1-d1dea885513a', 'd3d06a09-4ace-4176-8e9c-8a2aedad2ce0', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('298096e0-345b-480d-abc4-bd6f66426a5c', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('e086b811-5e7d-4172-86f6-b9542139dceb', '13ae55a8-01d6-4849-8327-bcbea6d52cfb', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cfc73521-ef73-4cdb-9978-66534b48ba7f', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('c250121b-fdf6-4cd1-816e-1994b643fdd2', '0cf035b4-2b92-4468-8cd4-cb30251db88d', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d675e0d6-0327-46ac-9709-c84a95343569', '8a557316-f880-44f0-8028-97b52d290cae', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('699e46eb-0a21-4c14-973e-35eae8453ef4', '8a557316-f880-44f0-8028-97b52d290cae', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('da2e3d18-ac17-434e-a222-01c2943922ab', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('32a0ad70-6a78-45cf-b630-025ac6cf095b', '9cc8bfe7-2df1-434e-8313-3e592dfc9d53', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3d50dc3b-9f72-4656-8ca8-6c37a423f309', '44687709-00cd-4828-8492-eb117a75be45', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('fac2fd4a-86b9-4336-a146-501bd605d0db', '44687709-00cd-4828-8492-eb117a75be45', 'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d816e749-c888-46ba-9165-0c6d117418ad', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701'),
  ('59b711ff-5e75-4aa3-8eb9-8783d41fa640', 'da8d12b0-afd7-4b1f-8f5b-63620db06ff2', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a47fe6a7-8dbf-45e6-b15e-7d88781e9c8f', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', 'dda012cd-f081-48df-8903-d997d9fa6f96', '550e8400-e29b-41d4-a716-446655440701'),
  ('41106bd4-ba5c-43ad-a106-ba2f0ffeef12', '8e018dcd-a2a5-4f4d-8cad-9406b56458b6', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0e1c6aa8-197f-48bb-9771-4d31326ab6f1', 'bbb552d5-3241-4dca-8824-69be1f232855', '5e07fe31-75ac-4d95-8224-c762b2411566', '550e8400-e29b-41d4-a716-446655440701'),
  ('57dc185f-68a4-4c04-83e4-26bd5f2bcfe5', 'bbb552d5-3241-4dca-8824-69be1f232855', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7e5cd6e4-0101-40e4-a61f-b2feda9ffb4d', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', 'eb1511a3-cc96-4387-80c1-c8e470338ddc', '550e8400-e29b-41d4-a716-446655440701'),
  ('67ee7e92-f198-42e5-831c-5ee589c28625', '54e7ac62-60c6-4da1-8ca0-48e735edd4d6', '2da3f1d4-be7f-4cff-89d8-fea82a640d06', '550e8400-e29b-41d4-a716-446655440701')
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
  ('62563d9f-2f53-45b0-b99c-68c79674d19e', '628a1237-b966-42f2-8927-678809d67be4', 'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b', '550e8400-e29b-41d4-a716-446655440701'),
  ('387d8b18-5f74-4f7f-9c91-bba9cd2dd066', '628a1237-b966-42f2-8927-678809d67be4', 'bb5768e2-fac3-42e0-8d07-f18a63fb2278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d4a1b342-7ff3-4208-81e0-ce8a826e3773', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '3e87d61d-3093-41a0-888a-83f66923a34b', '550e8400-e29b-41d4-a716-446655440701'),
  ('810db9e7-7aa1-4bbc-8453-c332f23c8db9', 'cfe2ecfa-b9b4-4f2c-8baf-25cd902551e9', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fd91178e-b036-4df6-aeff-021c74e3ddc1', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', '7708a49e-8512-43b2-8b85-13e98a4af318', '550e8400-e29b-41d4-a716-446655440701'),
  ('ba55362c-73af-479f-a8b7-c7824b5e2d9d', 'b0dfa54d-7374-4e08-8840-cafe6aa4b951', 'd9b9ff4c-052c-4c9f-8d2d-483f66125de4', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
