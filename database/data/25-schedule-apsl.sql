-- APSL Match Schedule
-- Generated at: 2025-12-15T19:22:54.659Z

INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  '2b312eac-64ef-4320-8354-4eba767080b3',
  'Falcons FC vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2b312eac-64ef-4320-8354-4eba767080b3',
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  NULL,
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
  'b1622db1-b21b-4805-8795-a6d9a4197be2',
  'Falcons FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b1622db1-b21b-4805-8795-a6d9a4197be2',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  'b04baaca-3775-4ae5-8a4d-3a824032e388',
  'Falcons FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T21:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b04baaca-3775-4ae5-8a4d-3a824032e388',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  '56aa9856-a6a9-4b70-8753-3fafb4736721',
  'Falcons FC vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '56aa9856-a6a9-4b70-8753-3fafb4736721',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  '9d701c19-d272-4ee9-8bbd-08c943add4fc',
  'Falcons FC vs roberts playground',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9d701c19-d272-4ee9-8bbd-08c943add4fc',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  'd7810b99-f373-4263-88b9-38183c8df59d',
  'Falcons FC vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-01T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd7810b99-f373-4263-88b9-38183c8df59d',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  'e46f8eba-0e2b-4e1a-88bd-f26199b5c906',
  'Falcons FC vs brush field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-07T00:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e46f8eba-0e2b-4e1a-88bd-f26199b5c906',
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  NULL,
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
  '9078841d-85a5-45be-8ea4-52cd7b59cccc',
  'Falcons FC vs lunenburg middle high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9078841d-85a5-45be-8ea4-52cd7b59cccc',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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
  '3027194a-9c90-4fc5-81b1-12fbae9ea6c0',
  'Falcons FC vs brush field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:47.811Z',
  '2025-12-15T19:21:47.811Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3027194a-9c90-4fc5-81b1-12fbae9ea6c0',
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  NULL,
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
  '943699e7-d522-417c-8a0d-fb4f1cb2d9fc',
  'Scrub Nation vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T18:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '943699e7-d522-417c-8a0d-fb4f1cb2d9fc',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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
  'fbed644f-52e0-4630-8a29-529fe531929c',
  'Scrub Nation vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fbed644f-52e0-4630-8a29-529fe531929c',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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
  'bf3d0aff-1e5b-4bb0-823c-143d8064ebf3',
  'Scrub Nation vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T17:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bf3d0aff-1e5b-4bb0-823c-143d8064ebf3',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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
  'eda230bf-89ee-44b4-8985-c3f2e614a378',
  'Scrub Nation vs east boston memorial stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-25T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'eda230bf-89ee-44b4-8985-c3f2e614a378',
  '8a804c82-814c-4a90-856b-441236c695ed',
  NULL,
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
  '3b960a5f-b2d4-4b78-8c49-a4213b860a01',
  'Scrub Nation vs ceylon park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3b960a5f-b2d4-4b78-8c49-a4213b860a01',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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
  '7f89e962-cff2-44a7-8aa6-d29d7592cfde',
  'Scrub Nation vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7f89e962-cff2-44a7-8aa6-d29d7592cfde',
  '8a804c82-814c-4a90-856b-441236c695ed',
  NULL,
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
  '15f4b65d-af56-4471-85a2-c6e559627a71',
  'Scrub Nation vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T15:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '15f4b65d-af56-4471-85a2-c6e559627a71',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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
  'f75cd554-a62a-48a5-8bc2-8cc76ac7f450',
  'Scrub Nation vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:48.834Z',
  '2025-12-15T19:21:48.834Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f75cd554-a62a-48a5-8bc2-8cc76ac7f450',
  '8a804c82-814c-4a90-856b-441236c695ed',
  NULL,
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
  '3cde3fe5-7ff5-4efa-80b5-5312043185a3',
  'Praia Kapital vs carter playground',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3cde3fe5-7ff5-4efa-80b5-5312043185a3',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '42e4d688-8913-4599-8ffd-1bda59a610ba',
  'Praia Kapital vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '42e4d688-8913-4599-8ffd-1bda59a610ba',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
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
  '6c83b874-f2b2-4926-881d-7155d2319231',
  'Praia Kapital vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6c83b874-f2b2-4926-881d-7155d2319231',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '288c07ec-1035-4920-84f2-82f6bee363d2',
  'Praia Kapital vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '288c07ec-1035-4920-84f2-82f6bee363d2',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
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
  'a27ecb03-c392-4fb4-81cc-5663f9f9a19f',
  'Praia Kapital vs ceylon park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a27ecb03-c392-4fb4-81cc-5663f9f9a19f',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '6253703c-f619-4bac-83a2-bd2e7292f349',
  'Praia Kapital vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6253703c-f619-4bac-83a2-bd2e7292f349',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '2c691d0b-80fc-4902-88a9-00f1eff02279',
  'Praia Kapital vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2c691d0b-80fc-4902-88a9-00f1eff02279',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '1807ef94-f17a-44fd-83bf-2efc7ed830f3',
  'Praia Kapital vs roberts playground',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1807ef94-f17a-44fd-83bf-2efc7ed830f3',
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  NULL,
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
  '8e399da9-78bf-4008-8ffa-c7c62a790de2',
  'Praia Kapital vs tbd',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-04T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:49.814Z',
  '2025-12-15T19:21:49.814Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8e399da9-78bf-4008-8ffa-c7c62a790de2',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
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
  '9553907f-b8f4-4657-8ba3-11b6f80942e1',
  'South Coast Union vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T18:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9553907f-b8f4-4657-8ba3-11b6f80942e1',
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  NULL,
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
  'c99b1c16-eeb2-4279-8506-fba67091c878',
  'South Coast Union vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T17:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c99b1c16-eeb2-4279-8506-fba67091c878',
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  NULL,
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
  'bf3590e4-be6b-4aa6-8475-dd21fcf7a7a2',
  'South Coast Union vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bf3590e4-be6b-4aa6-8475-dd21fcf7a7a2',
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  NULL,
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
  '1c85b4b4-c4b5-4ad1-8f38-d47a50f089c2',
  'South Coast Union vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1c85b4b4-c4b5-4ad1-8f38-d47a50f089c2',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
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
  '5350dade-5ee9-40ce-8f2d-7838d2694ff0',
  'South Coast Union vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5350dade-5ee9-40ce-8f2d-7838d2694ff0',
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  NULL,
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
  '45159e12-a19c-4568-8c8f-ac8064c8415e',
  'South Coast Union vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T17:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '45159e12-a19c-4568-8c8f-ac8064c8415e',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
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
  'c1a81185-067c-4133-8d81-defb487544de',
  'South Coast Union vs dilboy stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c1a81185-067c-4133-8d81-defb487544de',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
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
  '15c81134-e4eb-4c89-8dfa-c248603f840b',
  'South Coast Union vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T18:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '15c81134-e4eb-4c89-8dfa-c248603f840b',
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  NULL,
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
  'd4aa3ae4-a167-4ba3-8904-8ff61df1b0d0',
  'South Coast Union vs brush field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:51.342Z',
  '2025-12-15T19:21:51.342Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd4aa3ae4-a167-4ba3-8904-8ff61df1b0d0',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
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
  'e766de4f-ae5d-4af4-8635-cf63f5a252b7',
  'Project Football vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T21:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e766de4f-ae5d-4af4-8635-cf63f5a252b7',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
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
  'e42f74a0-5d88-4e77-858b-ea2e12992808',
  'Project Football vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e42f74a0-5d88-4e77-858b-ea2e12992808',
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  NULL,
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
  '6eddb57a-a3a1-4a0c-8345-e5290ed54610',
  'Project Football vs east boston memorial stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6eddb57a-a3a1-4a0c-8345-e5290ed54610',
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  NULL,
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
  'e31ac2fd-dca5-47d6-8cdf-8fe62c1df3a4',
  'Project Football vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e31ac2fd-dca5-47d6-8cdf-8fe62c1df3a4',
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  NULL,
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
  '63906696-7f0c-419f-8a82-31513cbbf264',
  'Project Football vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '63906696-7f0c-419f-8a82-31513cbbf264',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
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
  '5e0e3dca-0978-4865-8cac-e1e106676088',
  'Project Football vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5e0e3dca-0978-4865-8cac-e1e106676088',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
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
  '4e1c8b2d-6177-433f-8a46-b3ba9f257e61',
  'Project Football vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T15:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4e1c8b2d-6177-433f-8a46-b3ba9f257e61',
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  NULL,
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
  'be3a3cfc-916b-4a5c-8045-6e85bb8f47c9',
  'Project Football vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'be3a3cfc-916b-4a5c-8045-6e85bb8f47c9',
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  NULL,
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
  'a59e9501-d3ad-4685-8b8e-fd81489e8f33',
  'Project Football vs new bedford regional vocational technical hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T18:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:52.345Z',
  '2025-12-15T19:21:52.345Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a59e9501-d3ad-4685-8b8e-fd81489e8f33',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
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
  'c7e27b2f-4307-471c-899c-769d64287c00',
  'Invictus FC vs carter playground',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c7e27b2f-4307-471c-899c-769d64287c00',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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
  '54b23bd3-7ed2-4682-811f-b7ea73692106',
  'Invictus FC vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '54b23bd3-7ed2-4682-811f-b7ea73692106',
  '272b83b4-1153-402d-8a47-015cb13cd376',
  NULL,
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
  '55c9e473-0735-43ba-899f-b309d760a7f2',
  'Invictus FC vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '55c9e473-0735-43ba-899f-b309d760a7f2',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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
  'fd4fb292-c41a-4737-8897-da2963211bcf',
  'Invictus FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fd4fb292-c41a-4737-8897-da2963211bcf',
  '272b83b4-1153-402d-8a47-015cb13cd376',
  NULL,
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
  'e864d0d7-38ec-42e5-860b-c7bda0bd58ba',
  'Invictus FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T21:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e864d0d7-38ec-42e5-860b-c7bda0bd58ba',
  '272b83b4-1153-402d-8a47-015cb13cd376',
  NULL,
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
  '9c46748b-fbca-479b-88dc-51b1e10be5ac',
  'Invictus FC vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9c46748b-fbca-479b-88dc-51b1e10be5ac',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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
  '2c9995bf-8b93-4deb-879b-a15ddbc34f67',
  'Invictus FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T17:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2c9995bf-8b93-4deb-879b-a15ddbc34f67',
  '272b83b4-1153-402d-8a47-015cb13cd376',
  NULL,
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
  '2530d293-0be8-4605-8de6-2984e5cd0bb4',
  'Invictus FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2530d293-0be8-4605-8de6-2984e5cd0bb4',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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
  '224d3324-22ce-45b4-8dd5-34b09783bd5e',
  'Invictus FC vs brush field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-07T00:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:53.527Z',
  '2025-12-15T19:21:53.527Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '224d3324-22ce-45b4-8dd5-34b09783bd5e',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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
  '3da720a4-0f1d-4a73-812c-fb532a9a3abb',
  'Fitchburg FC vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2026-08-24T21:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3da720a4-0f1d-4a73-812c-fb532a9a3abb',
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  NULL,
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
  'fc2f6705-507b-4a35-8864-b933e66361c7',
  'Fitchburg FC vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fc2f6705-507b-4a35-8864-b933e66361c7',
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  NULL,
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
  '90983305-b737-49ff-8b88-4675011bbf6a',
  'Fitchburg FC vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '90983305-b737-49ff-8b88-4675011bbf6a',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
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
  '3ec252a2-8b1c-4079-824a-4fb4066baeda',
  'Fitchburg FC vs harry della russo stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3ec252a2-8b1c-4079-824a-4fb4066baeda',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
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
  '67ae9a9c-2eec-492e-87ed-e5ea0bed3f18',
  'Fitchburg FC vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '67ae9a9c-2eec-492e-87ed-e5ea0bed3f18',
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  NULL,
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
  'ce6680ab-9b28-4ee4-87cc-7108bbff8944',
  'Fitchburg FC vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ce6680ab-9b28-4ee4-87cc-7108bbff8944',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
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
  '2cfac7b3-5300-4cc2-819a-cd03de0f50f7',
  'Fitchburg FC vs pine banks park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2cfac7b3-5300-4cc2-819a-cd03de0f50f7',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
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
  '1d923fa3-da36-42df-8eb4-b76430afebfa',
  'Fitchburg FC vs lunenburg middle high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:54.874Z',
  '2025-12-15T19:21:54.874Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1d923fa3-da36-42df-8eb4-b76430afebfa',
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  NULL,
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
  '9d57e871-40c6-4488-8c3c-968da63a9b7b',
  'Sete Setembro USA vs game on fitchburg',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9d57e871-40c6-4488-8c3c-968da63a9b7b',
  NULL,
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
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
  '20b25881-09e9-42f6-80cc-9b684e9e38b8',
  'Sete Setembro USA vs brush field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '20b25881-09e9-42f6-80cc-9b684e9e38b8',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  'da35b7d7-80cb-4c8a-86cb-4fbd595bae44',
  'Sete Setembro USA vs east boston memorial stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-25T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'da35b7d7-80cb-4c8a-86cb-4fbd595bae44',
  NULL,
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
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
  '4c49b2c6-9753-4c22-8eab-02b78a5cde89',
  'Sete Setembro USA vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4c49b2c6-9753-4c22-8eab-02b78a5cde89',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  '53f757b0-66b7-4e54-858c-07abc1fcc59a',
  'Sete Setembro USA vs english high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '53f757b0-66b7-4e54-858c-07abc1fcc59a',
  NULL,
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
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
  'ccc06594-13e5-4f70-8d84-35863a5e01d8',
  'Sete Setembro USA vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T22:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ccc06594-13e5-4f70-8d84-35863a5e01d8',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  'e1e08417-eb3e-40cd-87a4-509dcc772fea',
  'Sete Setembro USA vs dilboy stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e1e08417-eb3e-40cd-87a4-509dcc772fea',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  '77f4d45f-25ef-4b4e-8446-1124d2c8c8d4',
  'Sete Setembro USA vs burlington high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-01T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '77f4d45f-25ef-4b4e-8446-1124d2c8c8d4',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  '45612c25-da7f-4f04-88c8-8ca2d408d200',
  'Sete Setembro USA vs tbd',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-04T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:56.228Z',
  '2025-12-15T19:21:56.228Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '45612c25-da7f-4f04-88c8-8ca2d408d200',
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  NULL,
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
  'f6043743-f6e0-4efa-8d20-4ed52c800c9e',
  'KO Elites vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f6043743-f6e0-4efa-8d20-4ed52c800c9e',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
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
  'ad9e0a3d-b10e-4849-8330-a40ffd1e98f4',
  'KO Elites vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ad9e0a3d-b10e-4849-8330-a40ffd1e98f4',
  'b67749bd-3006-4977-81db-c16e5c10143c',
  NULL,
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
  'b5c2629e-bb4e-4f56-892a-ca5e0272733a',
  'KO Elites vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b5c2629e-bb4e-4f56-892a-ca5e0272733a',
  'b67749bd-3006-4977-81db-c16e5c10143c',
  NULL,
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
  'a8ae9c47-0500-49dc-84a3-ef4d7cc4fb9c',
  'KO Elites vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a8ae9c47-0500-49dc-84a3-ef4d7cc4fb9c',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
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
  '192b5a19-e442-4f01-8fd7-766c96c5fb98',
  'KO Elites vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '192b5a19-e442-4f01-8fd7-766c96c5fb98',
  'b67749bd-3006-4977-81db-c16e5c10143c',
  NULL,
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
  'd4d20d57-8d2d-4712-87c7-355e59e9b7d4',
  'KO Elites vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:58.201Z',
  '2025-12-15T19:21:58.201Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd4d20d57-8d2d-4712-87c7-355e59e9b7d4',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
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
  '696a3359-97c3-4ed6-846d-26eaa595404e',
  'Glastonbury Celtic vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '696a3359-97c3-4ed6-846d-26eaa595404e',
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  NULL,
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
  '48234cc7-96fa-4cc1-8307-d2e0be7dae2e',
  'Glastonbury Celtic vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '48234cc7-96fa-4cc1-8307-d2e0be7dae2e',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
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
  'fcf2e44d-565e-459a-88a5-127789d56b03',
  'Glastonbury Celtic vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fcf2e44d-565e-459a-88a5-127789d56b03',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
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
  '9d04dd5f-9b5a-4e7c-8f35-67b8908c4aa9',
  'Glastonbury Celtic vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9d04dd5f-9b5a-4e7c-8f35-67b8908c4aa9',
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  NULL,
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
  '1530829f-e7ae-4016-802b-ed80621740ec',
  'Glastonbury Celtic vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1530829f-e7ae-4016-802b-ed80621740ec',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
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
  '181c71f8-9cd5-4659-841d-9accb041ff2d',
  'Glastonbury Celtic vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:21:59.331Z',
  '2025-12-15T19:21:59.331Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '181c71f8-9cd5-4659-841d-9accb041ff2d',
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  NULL,
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
  '6e864af8-3e74-4ca8-8752-0cd5bc0f90b2',
  'Wildcat FC vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6e864af8-3e74-4ca8-8752-0cd5bc0f90b2',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
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
  '07828101-f1b0-4a67-81d0-4b4a0e61d708',
  'Wildcat FC vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '07828101-f1b0-4a67-81d0-4b4a0e61d708',
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  NULL,
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
  '964b24a9-0183-46c6-80d6-2cc1afc958b8',
  'Wildcat FC vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '964b24a9-0183-46c6-80d6-2cc1afc958b8',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
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
  'ca073103-666b-4347-8949-58f5e03d7fe7',
  'Wildcat FC vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ca073103-666b-4347-8949-58f5e03d7fe7',
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  NULL,
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
  '604a2d11-d7b3-4ed3-88d3-fb9ea0c309d3',
  'Wildcat FC vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '604a2d11-d7b3-4ed3-88d3-fb9ea0c309d3',
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  NULL,
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
  '9d2360cd-d7c1-4b9b-87b8-40e6f7a7654a',
  'Wildcat FC vs cfc park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:00.377Z',
  '2025-12-15T19:22:00.377Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9d2360cd-d7c1-4b9b-87b8-40e6f7a7654a',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
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
  'd47cc490-80ba-4dea-8f77-3e9eb8177e33',
  'Hermandad Connecticut vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd47cc490-80ba-4dea-8f77-3e9eb8177e33',
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  NULL,
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
  'b7543420-2970-42dc-8970-16f4f63aad49',
  'Hermandad Connecticut vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b7543420-2970-42dc-8970-16f4f63aad49',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
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
  '08262422-ce74-429c-824a-97400f5f06e8',
  'Hermandad Connecticut vs municipal stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '08262422-ce74-429c-824a-97400f5f06e8',
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  NULL,
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
  'f6f7babc-94d0-4961-866c-c67b11f205f5',
  'Hermandad Connecticut vs irish american home society',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f6f7babc-94d0-4961-866c-c67b11f205f5',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
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
  'a21dc3da-43ea-4aab-80c0-47869ba60c69',
  'Hermandad Connecticut vs vale forge',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a21dc3da-43ea-4aab-80c0-47869ba60c69',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
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
  '9376dc77-9263-478b-8410-548ecb4422fc',
  'Hermandad Connecticut vs cfc park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:01.487Z',
  '2025-12-15T19:22:01.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9376dc77-9263-478b-8410-548ecb4422fc',
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  NULL,
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
  '40057249-05f8-47fd-846a-e5c18d4da3c1',
  'NY Greek Americans vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '40057249-05f8-47fd-846a-e5c18d4da3c1',
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  NULL,
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
  '45983c31-5534-4bce-81ec-69d161b2c126',
  'NY Greek Americans vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '45983c31-5534-4bce-81ec-69d161b2c126',
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  NULL,
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
  '07a2df04-fdbe-4b57-8dd8-e610a4896246',
  'NY Greek Americans vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '07a2df04-fdbe-4b57-8dd8-e610a4896246',
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  NULL,
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
  '281f7179-e054-482f-83e5-7913b89d8a68',
  'NY Greek Americans vs randalls island - field 75',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '281f7179-e054-482f-83e5-7913b89d8a68',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  'afa68b9b-f543-45f8-8137-4237f2ba203a',
  'NY Greek Americans vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'afa68b9b-f543-45f8-8137-4237f2ba203a',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  '382fa54c-ba92-40bd-8926-fd21f5814d8d',
  'NY Greek Americans vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-24T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '382fa54c-ba92-40bd-8926-fd21f5814d8d',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  '9e2b2c5f-428b-4deb-8c01-abdfd0918581',
  'NY Greek Americans vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9e2b2c5f-428b-4deb-8c01-abdfd0918581',
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  NULL,
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
  'eee0e1ca-5b8f-418d-8bd6-718302998284',
  'NY Greek Americans vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-13T02:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'eee0e1ca-5b8f-418d-8bd6-718302998284',
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  NULL,
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
  '52649a12-4b53-4b4c-89a1-a0db2d2e19aa',
  'NY Greek Americans vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '52649a12-4b53-4b4c-89a1-a0db2d2e19aa',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  '57ee5d44-c57d-4a40-8a6c-eb7d25d8ee94',
  'NY Greek Americans vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '57ee5d44-c57d-4a40-8a6c-eb7d25d8ee94',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  '29e9fa20-b35f-42a6-8ea2-4af44276ab4d',
  'NY Greek Americans vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:02.789Z',
  '2025-12-15T19:22:02.789Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '29e9fa20-b35f-42a6-8ea2-4af44276ab4d',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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
  '6c9b841e-c026-4bc2-84c1-286c8568ed3f',
  'Hoboken FC 1912 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6c9b841e-c026-4bc2-84c1-286c8568ed3f',
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  NULL,
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
  'f79deb02-33ff-41e7-8ed7-0e783497fe94',
  'Hoboken FC 1912 vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-15T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f79deb02-33ff-41e7-8ed7-0e783497fe94',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  'b5861285-d78c-4557-8382-32419882b36f',
  'Hoboken FC 1912 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b5861285-d78c-4557-8382-32419882b36f',
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  NULL,
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
  '45e38173-7aa5-4cf4-883f-1c4f2b2afa70',
  'Hoboken FC 1912 vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '45e38173-7aa5-4cf4-883f-1c4f2b2afa70',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  '410bcd58-9b60-44ec-8cfa-d343f2591537',
  'Hoboken FC 1912 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '410bcd58-9b60-44ec-8cfa-d343f2591537',
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  NULL,
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
  '3b0d69ea-e4ff-4181-86f1-407ff914a989',
  'Hoboken FC 1912 vs randalls island - field 75',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-24T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3b0d69ea-e4ff-4181-86f1-407ff914a989',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  '2c0bc1e3-afdb-449d-88ac-fdd30baa14ea',
  'Hoboken FC 1912 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2c0bc1e3-afdb-449d-88ac-fdd30baa14ea',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  '1f37a9e8-ad4d-4f5f-8d17-ce2e5d88231a',
  'Hoboken FC 1912 vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-07T01:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1f37a9e8-ad4d-4f5f-8d17-ce2e5d88231a',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  'bc3d847e-fbbc-4439-82b9-a5cbc0d997ce',
  'Hoboken FC 1912 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-20T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bc3d847e-fbbc-4439-82b9-a5cbc0d997ce',
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  NULL,
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
  '66f98d3b-14ad-47a9-8720-7b59b2e6f157',
  'Hoboken FC 1912 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '66f98d3b-14ad-47a9-8720-7b59b2e6f157',
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  NULL,
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
  '74ede661-1d2a-4bcb-8058-4e37818ce572',
  'Hoboken FC 1912 vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:03.912Z',
  '2025-12-15T19:22:03.912Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '74ede661-1d2a-4bcb-8058-4e37818ce572',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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
  'b9ff9b48-053a-4e68-830e-818cfce8ac19',
  'NY Pancyprian Freedoms vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b9ff9b48-053a-4e68-830e-818cfce8ac19',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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
  'c4128a84-056a-4746-8e30-83be86b72d92',
  'NY Pancyprian Freedoms vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-22T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c4128a84-056a-4746-8e30-83be86b72d92',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  '9fcef746-d156-4d46-8ced-dda652311391',
  'NY Pancyprian Freedoms vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9fcef746-d156-4d46-8ced-dda652311391',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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
  '1d8f29b4-8a14-4c56-8c11-1db1c72ad64f',
  'NY Pancyprian Freedoms vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1d8f29b4-8a14-4c56-8c11-1db1c72ad64f',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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
  '99b63b18-96be-4280-826f-2dc33f9ac63e',
  'NY Pancyprian Freedoms vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '99b63b18-96be-4280-826f-2dc33f9ac63e',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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
  'cb36daf4-c366-486e-82be-903b94c22a3a',
  'NY Pancyprian Freedoms vs queens college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cb36daf4-c366-486e-82be-903b94c22a3a',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  '62ff6e89-8312-4df1-8cb4-81f077a63bef',
  'NY Pancyprian Freedoms vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '62ff6e89-8312-4df1-8cb4-81f077a63bef',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  '52237953-8012-4d10-86e6-afcf93550ab7',
  'NY Pancyprian Freedoms vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '52237953-8012-4d10-86e6-afcf93550ab7',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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
  '70312de2-a2be-4b46-8913-6ff7c8a0b91b',
  'NY Pancyprian Freedoms vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '70312de2-a2be-4b46-8913-6ff7c8a0b91b',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  'ff1cd690-c186-4b3e-8924-08072644652e',
  'NY Pancyprian Freedoms vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-24T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ff1cd690-c186-4b3e-8924-08072644652e',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  'f6150d68-a4fc-428d-8074-49fd6c81ee19',
  'NY Pancyprian Freedoms vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:05.313Z',
  '2025-12-15T19:22:05.313Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f6150d68-a4fc-428d-8074-49fd6c81ee19',
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  NULL,
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
  '1c4056e2-ceea-4007-8092-77cb7700a1c2',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1c4056e2-ceea-4007-8092-77cb7700a1c2',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  'a9c52970-de60-4a4a-8924-79750acb1d5a',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a9c52970-de60-4a4a-8924-79750acb1d5a',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  '10fab9df-0b5b-40d2-8b9c-63783c76e076',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-26T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '10fab9df-0b5b-40d2-8b9c-63783c76e076',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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
  '8cfd5bb5-2209-42b6-8dc6-503b33453b1d',
  'Lansdowne Yonkers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8cfd5bb5-2209-42b6-8dc6-503b33453b1d',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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
  '1460eb77-f3ea-4cfb-88d7-6da6524c3a5d',
  'Lansdowne Yonkers FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1460eb77-f3ea-4cfb-88d7-6da6524c3a5d',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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
  '6c6291ff-bf76-4160-828c-f76c254a57dc',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-15T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6c6291ff-bf76-4160-828c-f76c254a57dc',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  '805f25cc-0e89-4d32-8571-7e316fa63a82',
  'Lansdowne Yonkers FC vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '805f25cc-0e89-4d32-8571-7e316fa63a82',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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
  '8cc5635e-00d7-4063-8c9b-31904ab4ea0a',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-07T01:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8cc5635e-00d7-4063-8c9b-31904ab4ea0a',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  'a2134a69-ac6d-47ed-8986-2b3f974230cd',
  'Lansdowne Yonkers FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a2134a69-ac6d-47ed-8986-2b3f974230cd',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  '6f915f98-888a-45cb-8f3e-6698be87407e',
  'Lansdowne Yonkers FC vs fleming park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-10T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6f915f98-888a-45cb-8f3e-6698be87407e',
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  NULL,
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
  '741436d2-6fe0-4196-8c35-e5e0bc49392a',
  'Lansdowne Yonkers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-15T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:06.727Z',
  '2025-12-15T19:22:06.727Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '741436d2-6fe0-4196-8c35-e5e0bc49392a',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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
  '054510ab-5766-4f14-8269-70205ae07bc1',
  'Doxa FCW vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '054510ab-5766-4f14-8269-70205ae07bc1',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  '020b35cb-f926-479f-8f04-bf2b9fbc9c23',
  'Doxa FCW vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '020b35cb-f926-479f-8f04-bf2b9fbc9c23',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  '4085ffdf-3ef8-437d-8c13-1d26db2fdc2b',
  'Doxa FCW vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-26T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4085ffdf-3ef8-437d-8c13-1d26db2fdc2b',
  'b59f4742-28b4-46db-8a70-f819f7935278',
  NULL,
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
  'fd695df8-2ada-4005-8361-a20571c39a38',
  'Doxa FCW vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fd695df8-2ada-4005-8361-a20571c39a38',
  'b59f4742-28b4-46db-8a70-f819f7935278',
  NULL,
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
  '2871b594-e034-4268-885f-4db53b3a5381',
  'Doxa FCW vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2871b594-e034-4268-885f-4db53b3a5381',
  'b59f4742-28b4-46db-8a70-f819f7935278',
  NULL,
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
  'c2605d28-33ea-49e0-8605-34f1bbfdf2eb',
  'Doxa FCW vs queens college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c2605d28-33ea-49e0-8605-34f1bbfdf2eb',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  'a33c3084-145b-4357-8244-b7ad1783c1b4',
  'Doxa FCW vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-27T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a33c3084-145b-4357-8244-b7ad1783c1b4',
  'b59f4742-28b4-46db-8a70-f819f7935278',
  NULL,
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
  '9949cea9-15e5-4ab9-89bb-9e3fdbea82b8',
  'Doxa FCW vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9949cea9-15e5-4ab9-89bb-9e3fdbea82b8',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  'b19b733e-dd12-450e-86ea-a826cff95c43',
  'Doxa FCW vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b19b733e-dd12-450e-86ea-a826cff95c43',
  'b59f4742-28b4-46db-8a70-f819f7935278',
  NULL,
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
  'b0c0c2de-d8dd-4ad2-877e-449bd1d83864',
  'Doxa FCW vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b0c0c2de-d8dd-4ad2-877e-449bd1d83864',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  'a924d1b8-9c62-40fa-8af4-3c15bc64b1a6',
  'Doxa FCW vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-13T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:07.937Z',
  '2025-12-15T19:22:07.937Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a924d1b8-9c62-40fa-8af4-3c15bc64b1a6',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
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
  'c828d577-5c45-49b0-842b-f7b47b45ae20',
  'Leros SC vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c828d577-5c45-49b0-842b-f7b47b45ae20',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  '174ec455-f59a-4fab-8938-f83b1ff1acc7',
  'Leros SC vs susa orlin & cohen sports complex - field 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '174ec455-f59a-4fab-8938-f83b1ff1acc7',
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  NULL,
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
  'ad2b9568-ec0c-4e15-8add-4586823fb242',
  'Leros SC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ad2b9568-ec0c-4e15-8add-4586823fb242',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  '10d8ad79-5ff3-4573-8e52-1afba742f30e',
  'Leros SC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '10d8ad79-5ff3-4573-8e52-1afba742f30e',
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  NULL,
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
  '8372a9df-93fe-4909-8aee-ed7671a556cc',
  'Leros SC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8372a9df-93fe-4909-8aee-ed7671a556cc',
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  NULL,
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
  '422a5b0c-3f23-43d2-867e-addbc5777434',
  'Leros SC vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '422a5b0c-3f23-43d2-867e-addbc5777434',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  '20c595fc-255e-4771-897b-c3ff77743a93',
  'Leros SC vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-31T00:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '20c595fc-255e-4771-897b-c3ff77743a93',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  'db413916-3f91-42f4-8de6-711c5ef3a31e',
  'Leros SC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'db413916-3f91-42f4-8de6-711c5ef3a31e',
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  NULL,
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
  'c37faec1-1a24-4e9c-87a7-93947f3ef9d7',
  'Leros SC vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c37faec1-1a24-4e9c-87a7-93947f3ef9d7',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  '35b34e67-fea8-42ac-8e44-b09b52124a5b',
  'Leros SC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '35b34e67-fea8-42ac-8e44-b09b52124a5b',
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  NULL,
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
  'b57732e3-ed70-44dc-858f-25e7d3965242',
  'Leros SC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:09.053Z',
  '2025-12-15T19:22:09.053Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b57732e3-ed70-44dc-858f-25e7d3965242',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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
  'a14003b0-52ee-44e8-8c15-ace861726592',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a14003b0-52ee-44e8-8c15-ace861726592',
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  NULL,
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
  'c19211d9-414d-4fc5-8ad2-7c6b04adb03b',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c19211d9-414d-4fc5-8ad2-7c6b04adb03b',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  'a49bc491-aaed-4706-8052-08099fc15290',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a49bc491-aaed-4706-8052-08099fc15290',
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  NULL,
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
  '3bf49b1a-93f0-4872-81a8-b7dff35579c2',
  'NY International FC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3bf49b1a-93f0-4872-81a8-b7dff35579c2',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  '0c309a89-50ce-4d73-8485-5611b505fdbc',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0c309a89-50ce-4d73-8485-5611b505fdbc',
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  NULL,
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
  'c6cd9a67-7e44-46ea-880e-2a1558367384',
  'NY International FC vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-15T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c6cd9a67-7e44-46ea-880e-2a1558367384',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  '8d2bbfce-3ee2-49a9-8481-6734903e33e4',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8d2bbfce-3ee2-49a9-8481-6734903e33e4',
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  NULL,
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
  '1eae28b4-42eb-4853-8ef6-6babe848b88a',
  'NY International FC vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1eae28b4-42eb-4853-8ef6-6babe848b88a',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  'fb5e390b-dc0d-4e54-8e3e-e47fc16220ef',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fb5e390b-dc0d-4e54-8e3e-e47fc16220ef',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  'f4ba7095-5db5-443f-813d-db9b2ff18e84',
  'NY International FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f4ba7095-5db5-443f-813d-db9b2ff18e84',
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  NULL,
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
  '387c83f3-7905-45a7-80f9-b416116e32e0',
  'NY International FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-15T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:10.340Z',
  '2025-12-15T19:22:10.340Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '387c83f3-7905-45a7-80f9-b416116e32e0',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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
  '25f1fd50-464b-4750-8373-cbd39180e76e',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-08T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '25f1fd50-464b-4750-8373-cbd39180e76e',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  'eac30eba-5e6a-476b-824b-a37c53a03fc7',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-15T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'eac30eba-5e6a-476b-824b-a37c53a03fc7',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  'd86dfd16-8d04-4ab8-81d8-d37f84d0a185',
  'Richmond County FC vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd86dfd16-8d04-4ab8-81d8-d37f84d0a185',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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
  '4473366d-5bbc-4a37-8c4a-092507126b4e',
  'Richmond County FC vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4473366d-5bbc-4a37-8c4a-092507126b4e',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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
  '98565947-fb53-49cf-8a5b-d0cec59b6a39',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '98565947-fb53-49cf-8a5b-d0cec59b6a39',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  'e82d1566-58fa-4a4f-8512-5cd6b245a6ac',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-13T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e82d1566-58fa-4a4f-8512-5cd6b245a6ac',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  '14c5b6a7-c9d4-48b8-8c74-a5d930be4505',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-27T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '14c5b6a7-c9d4-48b8-8c74-a5d930be4505',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  '4af1aad4-ce55-40b8-86d6-c6b4bd232070',
  'Richmond County FC vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4af1aad4-ce55-40b8-86d6-c6b4bd232070',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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
  '203b22ad-82db-4da3-8003-5dfdf9443a36',
  'Richmond County FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '203b22ad-82db-4da3-8003-5dfdf9443a36',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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
  '9a70a5ed-d4b7-4c01-8677-ee324a38c520',
  'Richmond County FC vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9a70a5ed-d4b7-4c01-8677-ee324a38c520',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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
  '800d8cf0-64d1-44f4-8767-d6eb761b118a',
  'Richmond County FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-15T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:11.544Z',
  '2025-12-15T19:22:11.544Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '800d8cf0-64d1-44f4-8767-d6eb761b118a',
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  NULL,
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
  'b3bb0ec5-8209-4cd4-872d-750f7bce83c4',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b3bb0ec5-8209-4cd4-872d-750f7bce83c4',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  '905eef36-8e52-400d-8468-7e502ef1e1d0',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '905eef36-8e52-400d-8468-7e502ef1e1d0',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  '23faead7-468f-4e9f-8c8a-241515483e85',
  'Zum Schneider FC 03 vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '23faead7-468f-4e9f-8c8a-241515483e85',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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
  '7bf35b94-7b3e-4a76-8163-7168c6e89329',
  'Zum Schneider FC 03 vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7bf35b94-7b3e-4a76-8163-7168c6e89329',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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
  '1d51c8dc-fcb7-4f4e-820c-d535fabc26b2',
  'Zum Schneider FC 03 vs susa orlin & cohen sports complex - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1d51c8dc-fcb7-4f4e-820c-d535fabc26b2',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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
  '7678bebf-e202-4038-89c5-122cba90966c',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-24T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7678bebf-e202-4038-89c5-122cba90966c',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  '1f38332e-18dd-49ec-8e09-ba34ac14acc4',
  'Zum Schneider FC 03 vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-27T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1f38332e-18dd-49ec-8e09-ba34ac14acc4',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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
  '20138813-1a72-4b51-8aab-3f4301bdc5a2',
  'Zum Schneider FC 03 vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '20138813-1a72-4b51-8aab-3f4301bdc5a2',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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
  'bf710c3d-37bd-4de8-8663-71b0fe468184',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bf710c3d-37bd-4de8-8663-71b0fe468184',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  'bd86759d-9a1c-4b05-8dff-3be628aaecf2',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-08T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bd86759d-9a1c-4b05-8dff-3be628aaecf2',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  'b2097c89-f863-44ec-8a79-c75a94acde45',
  'Zum Schneider FC 03 vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-15T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:12.957Z',
  '2025-12-15T19:22:12.957Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b2097c89-f863-44ec-8a79-c75a94acde45',
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  NULL,
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
  'bcc3aa2e-c522-4527-8d54-aa45d4d0693d',
  'Central Park Rangers FC vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-08T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bcc3aa2e-c522-4527-8d54-aa45d4d0693d',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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
  '63eb2d80-af73-4ab9-88c0-4d4e882b7094',
  'Central Park Rangers FC vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-22T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '63eb2d80-af73-4ab9-88c0-4d4e882b7094',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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
  '99d98138-8950-4411-8382-0b721ab68850',
  'Central Park Rangers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '99d98138-8950-4411-8382-0b721ab68850',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '5b8e18e7-a235-4283-8ad5-ff8295333f65',
  'Central Park Rangers FC vs randalls island - field 75',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5b8e18e7-a235-4283-8ad5-ff8295333f65',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '16ed3699-8772-40a2-855a-7d1ab1a7ba15',
  'Central Park Rangers FC vs randalls island - field 75',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-24T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '16ed3699-8772-40a2-855a-7d1ab1a7ba15',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '7bdd59f1-d401-4e7c-85de-c7a29b8597f6',
  'Central Park Rangers FC vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7bdd59f1-d401-4e7c-85de-c7a29b8597f6',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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
  '163ad030-c34c-42d1-89d5-05861b89744e',
  'Central Park Rangers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '163ad030-c34c-42d1-89d5-05861b89744e',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '96a1b403-edeb-43d4-80f9-39e06d2439fe',
  'Central Park Rangers FC vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-10T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '96a1b403-edeb-43d4-80f9-39e06d2439fe',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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
  '43059b55-7448-470b-893d-d2bc6c0c71a0',
  'Central Park Rangers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '43059b55-7448-470b-893d-d2bc6c0c71a0',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '10d4f8dd-b38d-44f2-86a5-4a5af935c73f',
  'Central Park Rangers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-08T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '10d4f8dd-b38d-44f2-86a5-4a5af935c73f',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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
  '7dec9386-f3bc-4962-80a6-058a1addc23f',
  'Central Park Rangers FC vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:14.453Z',
  '2025-12-15T19:22:14.453Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7dec9386-f3bc-4962-80a6-058a1addc23f',
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  NULL,
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
  '706ec04b-5e2e-4d95-867f-c18ec96d156a',
  'SC Vistula Garfield vs roosevelt island - jack mcmanus field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '706ec04b-5e2e-4d95-867f-c18ec96d156a',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  'e3547383-56a3-4bb4-8938-7af326ffae5f',
  'SC Vistula Garfield vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e3547383-56a3-4bb4-8938-7af326ffae5f',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  'cfe7b9a6-0df2-4074-873f-ab5d811a0642',
  'SC Vistula Garfield vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cfe7b9a6-0df2-4074-873f-ab5d811a0642',
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  NULL,
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
  '01968a1d-e93e-4a32-83c5-26a596324dd0',
  'SC Vistula Garfield vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '01968a1d-e93e-4a32-83c5-26a596324dd0',
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  NULL,
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
  '64ed6f74-4005-410f-8b57-00ad37469380',
  'SC Vistula Garfield vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-27T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '64ed6f74-4005-410f-8b57-00ad37469380',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  '894d600b-8d84-4903-8ba2-b174553236a8',
  'SC Vistula Garfield vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-31T00:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '894d600b-8d84-4903-8ba2-b174553236a8',
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  NULL,
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
  '1ccd0b00-fd85-46eb-8a2c-e470e841d3a9',
  'SC Vistula Garfield vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-10T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1ccd0b00-fd85-46eb-8a2c-e470e841d3a9',
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  NULL,
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
  'e62c2ff3-8491-4a27-8054-652f39533d42',
  'SC Vistula Garfield vs hofstra university soccer stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-13T02:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e62c2ff3-8491-4a27-8054-652f39533d42',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  '701ce0b7-ff90-4a27-87e7-bc406cfa0c1c',
  'SC Vistula Garfield vs laurel hill park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-20T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '701ce0b7-ff90-4a27-87e7-bc406cfa0c1c',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  '997f77b0-0714-4664-8a01-3a68f14b8405',
  'SC Vistula Garfield vs fleming park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-10T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '997f77b0-0714-4664-8a01-3a68f14b8405',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
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
  '62e5930f-1e33-43b9-8d40-5a2473d69623',
  'SC Vistula Garfield vs garfield high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-13T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:15.607Z',
  '2025-12-15T19:22:15.607Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '62e5930f-1e33-43b9-8d40-5a2473d69623',
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  NULL,
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
  '912dcfdd-c4a6-45b9-84ba-3eed3bbf070f',
  'NY Athletic Club vs tibbetts brook park - field 3',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '912dcfdd-c4a6-45b9-84ba-3eed3bbf070f',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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
  'f075a299-86c9-40da-859b-043a7258a435',
  'NY Athletic Club vs susa orlin & cohen sports complex - field 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f075a299-86c9-40da-859b-043a7258a435',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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
  'aa53ebef-a9a2-4bba-8608-f99dadc8ac5c',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'aa53ebef-a9a2-4bba-8608-f99dadc8ac5c',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  'cdaf948e-7c88-460b-8cd2-84e3f87e7581',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cdaf948e-7c88-460b-8cd2-84e3f87e7581',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  '02a17bf7-b127-4844-8988-9cc5548c4392',
  'NY Athletic Club vs joseph f. fosina field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '02a17bf7-b127-4844-8988-9cc5548c4392',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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
  '07e2c902-b571-475c-889b-445056a0f9f6',
  'NY Athletic Club vs owl hollow field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-13T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '07e2c902-b571-475c-889b-445056a0f9f6',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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
  '66303d34-d245-4302-8bb0-7026e9e93033',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T16:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '66303d34-d245-4302-8bb0-7026e9e93033',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  'be62aef2-857d-42b6-8fba-678a392301b5',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'be62aef2-857d-42b6-8fba-678a392301b5',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  '05e0a639-a4f3-4078-8fb1-4407055acd26',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '05e0a639-a4f3-4078-8fb1-4407055acd26',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  '7c86959b-be8e-4081-8ee7-a08a76d0293f',
  'NY Athletic Club vs st. john''s university - belson stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-24T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7c86959b-be8e-4081-8ee7-a08a76d0293f',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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
  '05def8ed-5489-4991-88ec-36a223ab2fc0',
  'NY Athletic Club vs travers island',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T17:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:16.649Z',
  '2025-12-15T19:22:16.649Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '05def8ed-5489-4991-88ec-36a223ab2fc0',
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  NULL,
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
  '4eec1bcb-01eb-4add-8ea9-335b578cf79c',
  'WC Predators vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4eec1bcb-01eb-4add-8ea9-335b578cf79c',
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  NULL,
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
  '0f48efde-a6d3-4da8-839b-d8c79ee108f5',
  'WC Predators vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0f48efde-a6d3-4da8-839b-d8c79ee108f5',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  'ccc6a7ef-df00-4f64-88b6-84323b7b11be',
  'WC Predators vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ccc6a7ef-df00-4f64-88b6-84323b7b11be',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  '485b5310-ad88-433e-800a-7eaf465ffec2',
  'WC Predators vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '485b5310-ad88-433e-800a-7eaf465ffec2',
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  NULL,
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
  'c2aef720-fe3f-4fce-8037-32c8a9ebb04e',
  'WC Predators vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-04T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c2aef720-fe3f-4fce-8037-32c8a9ebb04e',
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  NULL,
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
  '6f23b5a5-4433-4a11-8b07-eb607f6357b7',
  'WC Predators vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6f23b5a5-4433-4a11-8b07-eb607f6357b7',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  '22b19f55-b91a-4999-83cf-ace50fe020e8',
  'WC Predators vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '22b19f55-b91a-4999-83cf-ace50fe020e8',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  'eac194e0-3f4f-4c68-8994-78b43cb84733',
  'WC Predators vs thornbury soccer park - field 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'eac194e0-3f4f-4c68-8994-78b43cb84733',
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  NULL,
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
  '418be9b8-93b8-42c1-82b9-22c6e9c4e756',
  'WC Predators vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '418be9b8-93b8-42c1-82b9-22c6e9c4e756',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  'c8a15321-599f-4e15-8fa8-a38611a596f2',
  'WC Predators vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c8a15321-599f-4e15-8fa8-a38611a596f2',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
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
  '46fd0900-1dda-4ad9-87c3-57a46d852db6',
  'WC Predators vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-03T01:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:18.401Z',
  '2025-12-15T19:22:18.401Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '46fd0900-1dda-4ad9-87c3-57a46d852db6',
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  NULL,
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
  'b698fd79-6f84-441d-85e9-84be0fcd8855',
  'Alloy Soccer Club vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b698fd79-6f84-441d-85e9-84be0fcd8855',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
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
  '19ae89ed-cf70-4905-8c7e-a8bbe8086218',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '19ae89ed-cf70-4905-8c7e-a8bbe8086218',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  '50c3f618-b26d-4d13-8384-c4828896bc9e',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '50c3f618-b26d-4d13-8384-c4828896bc9e',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  '4eed4631-e057-44e5-8811-2d6400840ecb',
  'Alloy Soccer Club vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4eed4631-e057-44e5-8811-2d6400840ecb',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
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
  '41097e63-c1a8-48f9-8bd6-9c107578de62',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '41097e63-c1a8-48f9-8bd6-9c107578de62',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  'a4bfd629-35bc-4e96-8802-bd745f1e519e',
  'Alloy Soccer Club vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a4bfd629-35bc-4e96-8802-bd745f1e519e',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
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
  'e6796e71-25b6-434a-82ca-1878b39a1771',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-01T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e6796e71-25b6-434a-82ca-1878b39a1771',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  'b5c9f9da-6f70-4b03-8f46-b5f74c7e7f48',
  'Alloy Soccer Club vs holy family university - tiger field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b5c9f9da-6f70-4b03-8f46-b5f74c7e7f48',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
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
  '98c09e97-f0f1-4bdf-8851-7b05556a6286',
  'Alloy Soccer Club vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '98c09e97-f0f1-4bdf-8851-7b05556a6286',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
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
  'cbb500df-b50e-4777-8e42-fa4b34f93165',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cbb500df-b50e-4777-8e42-fa4b34f93165',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  '8bc5ad14-2fd0-4f5b-863e-b11317bcdb0c',
  'Alloy Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:19.678Z',
  '2025-12-15T19:22:19.678Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8bc5ad14-2fd0-4f5b-863e-b11317bcdb0c',
  '1b01904c-2aca-4467-80c9-705893293f40',
  NULL,
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
  '51556f4a-3b47-439f-8e82-a76f35a0f381',
  'Oaklyn United FC vs rowan university',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '51556f4a-3b47-439f-8e82-a76f35a0f381',
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  NULL,
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
  '0a5aaa2e-b966-46ba-8d86-136323a02317',
  'Oaklyn United FC vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-18T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0a5aaa2e-b966-46ba-8d86-136323a02317',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  '58585512-4ad2-4c19-89e1-0cf227299aad',
  'Oaklyn United FC vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '58585512-4ad2-4c19-89e1-0cf227299aad',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  'a67c061b-a3f5-425b-8b79-1fb75b98c9a3',
  'Oaklyn United FC vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a67c061b-a3f5-425b-8b79-1fb75b98c9a3',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  '7556dbea-61d0-4126-80f2-f19aa12b7366',
  'Oaklyn United FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7556dbea-61d0-4126-80f2-f19aa12b7366',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  '4367353c-c389-434f-8fd7-fba150c1689c',
  'Oaklyn United FC vs rowan university',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4367353c-c389-434f-8fd7-fba150c1689c',
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  NULL,
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
  '208d1e8d-c784-4062-872a-7743566df2c2',
  'Oaklyn United FC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '208d1e8d-c784-4062-872a-7743566df2c2',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  '50e30783-6b18-4c31-87f6-4563a7115578',
  'Oaklyn United FC vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '50e30783-6b18-4c31-87f6-4563a7115578',
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  NULL,
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
  '69034059-5f48-4c7e-8ccc-fb5f8bff5c44',
  'Oaklyn United FC vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '69034059-5f48-4c7e-8ccc-fb5f8bff5c44',
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  NULL,
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
  'ad90050d-e3be-4348-8d42-0b0732c24b8c',
  'Oaklyn United FC vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-08T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ad90050d-e3be-4348-8d42-0b0732c24b8c',
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  NULL,
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
  '722c9d60-14c5-4989-8368-317e8503f094',
  'Oaklyn United FC vs james j. ramp athletic complex - ramp athletic complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:21.069Z',
  '2025-12-15T19:22:21.069Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '722c9d60-14c5-4989-8368-317e8503f094',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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
  '0c3111b9-ed2c-419b-8830-808ea3fcfec9',
  'Real Central NJ Soccer vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0c3111b9-ed2c-419b-8830-808ea3fcfec9',
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  NULL,
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
  '5c2e3dd9-da6f-4d21-88c5-3fa950c753bb',
  'Real Central NJ Soccer vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5c2e3dd9-da6f-4d21-88c5-3fa950c753bb',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  '80575173-942a-4d85-8e88-cfbcd4f604bd',
  'Real Central NJ Soccer vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '80575173-942a-4d85-8e88-cfbcd4f604bd',
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  NULL,
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
  '2322803b-a77d-4f64-8527-43da2a9e420a',
  'Real Central NJ Soccer vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2322803b-a77d-4f64-8527-43da2a9e420a',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  '84ff37a6-a26f-4e44-8a04-c1e729887356',
  'Real Central NJ Soccer vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-04T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '84ff37a6-a26f-4e44-8a04-c1e729887356',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  'bfc407e1-d6b3-438a-8ddd-76a0c529a5c7',
  'Real Central NJ Soccer vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bfc407e1-d6b3-438a-8ddd-76a0c529a5c7',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  '556f1def-3139-4fe1-8fcd-ae5af150ab87',
  'Real Central NJ Soccer vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-03T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '556f1def-3139-4fe1-8fcd-ae5af150ab87',
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  NULL,
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
  'd866d7ec-ec9e-4675-8ceb-694a4dd63f90',
  'Real Central NJ Soccer vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd866d7ec-ec9e-4675-8ceb-694a4dd63f90',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  'f949ce3c-79b0-4f10-8919-86e5cb463477',
  'Real Central NJ Soccer vs twin pines field -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-24T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f949ce3c-79b0-4f10-8919-86e5cb463477',
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  NULL,
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
  'a42b1604-52ea-4ea2-8ff0-f9f15afa69a0',
  'Real Central NJ Soccer vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-04T01:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a42b1604-52ea-4ea2-8ff0-f9f15afa69a0',
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  NULL,
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
  '6eb59fa8-3189-42a1-8074-99a413fd474a',
  'Real Central NJ Soccer vs james j. ramp athletic complex - ramp athletic complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:22.753Z',
  '2025-12-15T19:22:22.753Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6eb59fa8-3189-42a1-8074-99a413fd474a',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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
  '93431255-6554-480d-85fb-5f229bbe2f94',
  'Philadelphia Heritage SC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '93431255-6554-480d-85fb-5f229bbe2f94',
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  NULL,
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
  '88886815-1231-4049-846b-14528d59ebdc',
  'Philadelphia Heritage SC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '88886815-1231-4049-846b-14528d59ebdc',
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  NULL,
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
  'bff419bc-a3e2-43d1-8bb0-3c3a5dd927bd',
  'Philadelphia Heritage SC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bff419bc-a3e2-43d1-8bb0-3c3a5dd927bd',
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  NULL,
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
  '885181a2-d7c9-4413-8b76-b1f484ddb3af',
  'Philadelphia Heritage SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '885181a2-d7c9-4413-8b76-b1f484ddb3af',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  'e460e2be-5e65-4716-838a-7c6d13a19e99',
  'Philadelphia Heritage SC vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e460e2be-5e65-4716-838a-7c6d13a19e99',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  'cd65ded4-bd68-4792-88aa-9b0a9a759ac4',
  'Philadelphia Heritage SC vs rowan university',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cd65ded4-bd68-4792-88aa-9b0a9a759ac4',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  '260aaea9-9a76-491e-8659-5fd6878d7d96',
  'Philadelphia Heritage SC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '260aaea9-9a76-491e-8659-5fd6878d7d96',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  'd10e08cb-6e03-4fe3-8c6b-2c867d0fa04c',
  'Philadelphia Heritage SC vs holy family university - tiger field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd10e08cb-6e03-4fe3-8c6b-2c867d0fa04c',
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  NULL,
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
  'd5dd7bed-68e8-48b3-80fb-d2a09f27fa44',
  'Philadelphia Heritage SC vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd5dd7bed-68e8-48b3-80fb-d2a09f27fa44',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  'f27c4e34-f01d-4415-88a1-9c9007273391',
  'Philadelphia Heritage SC vs twin pines field -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-24T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f27c4e34-f01d-4415-88a1-9c9007273391',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
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
  'f5a0a8e7-63a3-4940-8551-9635f9e85581',
  'Philadelphia Heritage SC vs united sports - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-11T01:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:24.071Z',
  '2025-12-15T19:22:24.071Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f5a0a8e7-63a3-4940-8551-9635f9e85581',
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  NULL,
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
  '6eafdcad-01cd-4604-8a9a-b377f8afcae1',
  'Philadelphia Soccer Club vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6eafdcad-01cd-4604-8a9a-b377f8afcae1',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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
  'bab939cc-2f17-4e2f-87ed-02e1facd13fc',
  'Philadelphia Soccer Club vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bab939cc-2f17-4e2f-87ed-02e1facd13fc',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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
  'f9001bd4-b872-4aa3-8c0a-977b9465ef53',
  'Philadelphia Soccer Club vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f9001bd4-b872-4aa3-8c0a-977b9465ef53',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'e75e65e0-3b86-435c-8f34-99b7d87f3b6a',
  'Philadelphia Soccer Club vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e75e65e0-3b86-435c-8f34-99b7d87f3b6a',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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
  '267d2448-e6c4-4112-802b-25c31e2b7bc1',
  'Philadelphia Soccer Club vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '267d2448-e6c4-4112-802b-25c31e2b7bc1',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'a42e2a3c-f6b0-481a-8644-8ccbe66b126b',
  'Philadelphia Soccer Club vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a42e2a3c-f6b0-481a-8644-8ccbe66b126b',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'bfcedbc9-8df5-45f0-8d54-ade0f27d3c46',
  'Philadelphia Soccer Club vs thornbury soccer park - field 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bfcedbc9-8df5-45f0-8d54-ade0f27d3c46',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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
  '9381e067-7762-450e-8873-31a740e2f07f',
  'Philadelphia Soccer Club vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9381e067-7762-450e-8873-31a740e2f07f',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'ee43e6e5-9a5c-4e30-8b08-e4479d1117db',
  'Philadelphia Soccer Club vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ee43e6e5-9a5c-4e30-8b08-e4479d1117db',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'f6803297-d275-4261-807e-19096ea43594',
  'Philadelphia Soccer Club vs united sports - field 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-11T01:15:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f6803297-d275-4261-807e-19096ea43594',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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
  '955303d4-bc1d-4d39-88b9-76eb25c65922',
  'Philadelphia Soccer Club vs james j. ramp athletic complex - ramp athletic complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:25.156Z',
  '2025-12-15T19:22:25.156Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '955303d4-bc1d-4d39-88b9-76eb25c65922',
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  NULL,
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
  'cc156a8b-476f-4a40-87fa-208e89971a20',
  'Vidas United FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cc156a8b-476f-4a40-87fa-208e89971a20',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  'f5197f30-9929-4ce7-88f4-13ad790d042e',
  'Vidas United FC vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f5197f30-9929-4ce7-88f4-13ad790d042e',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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
  'b842a55b-7a6a-4e0d-8f8d-b1087530b981',
  'Vidas United FC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b842a55b-7a6a-4e0d-8f8d-b1087530b981',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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
  'b8ec8fa7-c7c5-45fa-876c-8dbc8d4dc512',
  'Vidas United FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b8ec8fa7-c7c5-45fa-876c-8dbc8d4dc512',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  '15aa28bc-dce8-43b5-836f-96f194e1c7a3',
  'Vidas United FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '15aa28bc-dce8-43b5-836f-96f194e1c7a3',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  '121daecf-833c-4561-83ea-c03e91a814f1',
  'Vidas United FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '121daecf-833c-4561-83ea-c03e91a814f1',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  'a00fc188-0603-4207-8328-1db67db81c00',
  'Vidas United FC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a00fc188-0603-4207-8328-1db67db81c00',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  '0c34a94c-3b5e-451f-857b-6688a6b8373a',
  'Vidas United FC vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-01T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0c34a94c-3b5e-451f-857b-6688a6b8373a',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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
  '70405b3c-e1a2-437c-8dbb-8ffc6a723979',
  'Vidas United FC vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '70405b3c-e1a2-437c-8dbb-8ffc6a723979',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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
  'f1f9775a-b4bb-4af0-8e32-a7e3f22b5328',
  'Vidas United FC vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f1f9775a-b4bb-4af0-8e32-a7e3f22b5328',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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
  'fa6adc64-1581-41fb-875c-ab523e770c8e',
  'Vidas United FC vs james j. ramp athletic complex - ramp athletic complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:26.455Z',
  '2025-12-15T19:22:26.455Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fa6adc64-1581-41fb-875c-ab523e770c8e',
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  NULL,
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
  '14732830-f60f-465b-8bcf-3372038c3674',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-18T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '14732830-f60f-465b-8bcf-3372038c3674',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  '9f7696d5-1eb0-4a10-8a55-5f5ccd8b4762',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9f7696d5-1eb0-4a10-8a55-5f5ccd8b4762',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  'bde8ce8e-b45c-4785-86d1-dc3073c8aca7',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-02T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bde8ce8e-b45c-4785-86d1-dc3073c8aca7',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  'bd0a7d89-3213-4bc3-811b-315ff0609c9f',
  'GAK vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bd0a7d89-3213-4bc3-811b-315ff0609c9f',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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
  '23e4649c-5fb4-4f95-836c-032b1529b799',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '23e4649c-5fb4-4f95-836c-032b1529b799',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  '70e29610-d2e6-41eb-8aa0-4d1ced281a46',
  'GAK vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '70e29610-d2e6-41eb-8aa0-4d1ced281a46',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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
  'ee640b50-d0a9-4705-812e-784a9a81b022',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ee640b50-d0a9-4705-812e-784a9a81b022',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  'dcb3141e-e3b6-4d1c-8b9c-c25da73fbaa0',
  'GAK vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-14T02:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'dcb3141e-e3b6-4d1c-8b9c-c25da73fbaa0',
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  NULL,
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
  '47b07274-c05d-4898-8dc3-b34cec05cd2f',
  'GAK vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '47b07274-c05d-4898-8dc3-b34cec05cd2f',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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
  '0623324d-9bad-409f-8234-49cc014d147b',
  'GAK vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0623324d-9bad-409f-8234-49cc014d147b',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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
  'c7650069-d40d-464a-83fa-2c28b6a805c7',
  'GAK vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:27.979Z',
  '2025-12-15T19:22:27.979Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c7650069-d40d-464a-83fa-2c28b6a805c7',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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
  'bc72a351-f2bf-4c57-8437-6d8b58997294',
  'Lighthouse 1893 SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T20:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bc72a351-f2bf-4c57-8437-6d8b58997294',
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  NULL,
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
  'aaa110ac-755b-41f9-8b21-027655b4fd3a',
  'Lighthouse 1893 SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'aaa110ac-755b-41f9-8b21-027655b4fd3a',
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  NULL,
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
  '3d832b30-239d-4e42-884d-450412dc7cf2',
  'Lighthouse 1893 SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3d832b30-239d-4e42-884d-450412dc7cf2',
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  NULL,
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
  '899e31bd-0dda-48df-8e6a-0bd6a7c928f5',
  'Lighthouse 1893 SC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '899e31bd-0dda-48df-8e6a-0bd6a7c928f5',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  'b45a27db-ce63-4b7f-87f4-6ef21458c2c9',
  'Lighthouse 1893 SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b45a27db-ce63-4b7f-87f4-6ef21458c2c9',
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  NULL,
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
  'e76ecf32-b915-4e2c-8598-b5d91a5a9a26',
  'Lighthouse 1893 SC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e76ecf32-b915-4e2c-8598-b5d91a5a9a26',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  '82e378e8-051c-455f-8028-fd8f0a074b4f',
  'Lighthouse 1893 SC vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '82e378e8-051c-455f-8028-fd8f0a074b4f',
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  NULL,
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
  'adbe119d-7cfc-40d3-8c47-de594498b8d0',
  'Lighthouse 1893 SC vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-14T02:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'adbe119d-7cfc-40d3-8c47-de594498b8d0',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  '6c49e8ec-2df4-4474-8de8-4e62816d7dc5',
  'Lighthouse 1893 SC vs lancaster catholic high school - crusader stadium',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6c49e8ec-2df4-4474-8de8-4e62816d7dc5',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  'f0a569e9-81a5-49b6-8fc4-7a529cf0adc3',
  'Lighthouse 1893 SC vs toms river high school south',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-30T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f0a569e9-81a5-49b6-8fc4-7a529cf0adc3',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  'dc6597eb-fbfc-42b7-8199-845a4e0ac0e3',
  'Lighthouse 1893 SC vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-03T01:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:29.308Z',
  '2025-12-15T19:22:29.308Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'dc6597eb-fbfc-42b7-8199-845a4e0ac0e3',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
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
  '990da56e-2e28-4d1f-8506-dd8c812cde18',
  'Jersey Shore Boca vs penn fusion - kildare''s turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-06T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '990da56e-2e28-4d1f-8506-dd8c812cde18',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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
  'd6885222-f24b-460f-835a-e69ec99764d8',
  'Jersey Shore Boca vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd6885222-f24b-460f-835a-e69ec99764d8',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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
  '679a54bd-5088-4645-836f-9113e489dde7',
  'Jersey Shore Boca vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '679a54bd-5088-4645-836f-9113e489dde7',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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
  '73f5d5e0-c378-4cae-8b5f-952a9fa1e722',
  'Jersey Shore Boca vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '73f5d5e0-c378-4cae-8b5f-952a9fa1e722',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  '59fef697-1020-4c2d-8f9b-e478bafd46d7',
  'Jersey Shore Boca vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '59fef697-1020-4c2d-8f9b-e478bafd46d7',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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
  'ead86b62-2e7f-4607-8ca1-dceb66b4fa2f',
  'Jersey Shore Boca vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ead86b62-2e7f-4607-8ca1-dceb66b4fa2f',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  '04ff15dc-e529-4da7-8490-706aa7f2b1ac',
  'Jersey Shore Boca vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '04ff15dc-e529-4da7-8490-706aa7f2b1ac',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  'a4332c44-a9c1-46ca-8b8c-6583498b87d5',
  'Jersey Shore Boca vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a4332c44-a9c1-46ca-8b8c-6583498b87d5',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  '38bea10b-c1ae-4ec0-8dda-9406e7b434d0',
  'Jersey Shore Boca vs toms river high school south',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-30T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '38bea10b-c1ae-4ec0-8dda-9406e7b434d0',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  '71ba0936-ba35-4d64-898c-7fd57afadef4',
  'Jersey Shore Boca vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '71ba0936-ba35-4d64-898c-7fd57afadef4',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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
  'd206b6da-3e52-42de-803d-d1a50c70104a',
  'Jersey Shore Boca vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:30.564Z',
  '2025-12-15T19:22:30.564Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd206b6da-3e52-42de-803d-d1a50c70104a',
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  NULL,
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
  '5a899863-b6cb-4c44-8451-5fd50c64d3b4',
  'Sewell Old Boys FC vs john bartram high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5a899863-b6cb-4c44-8451-5fd50c64d3b4',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
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
  'cb686186-d108-49b4-87f7-974f1dbada38',
  'Sewell Old Boys FC vs germantown supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cb686186-d108-49b4-87f7-974f1dbada38',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  'ac8b7927-217e-477a-8861-4945de52c347',
  'Sewell Old Boys FC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ac8b7927-217e-477a-8861-4945de52c347',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  '8a40cc10-1a82-4fb8-84c4-77daa0b92558',
  'Sewell Old Boys FC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8a40cc10-1a82-4fb8-84c4-77daa0b92558',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  '02932d4d-7efc-4e0b-88b6-0f34d709abba',
  'Sewell Old Boys FC vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '02932d4d-7efc-4e0b-88b6-0f34d709abba',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  '12bb9e8a-dbb0-49fd-8760-4c088943bad9',
  'Sewell Old Boys FC vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '12bb9e8a-dbb0-49fd-8760-4c088943bad9',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
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
  '2a5ef3d5-f2fe-424f-8e62-1cda0aa6a373',
  'Sewell Old Boys FC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2a5ef3d5-f2fe-424f-8e62-1cda0aa6a373',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  'a6043f01-62d4-4323-8166-2b1f75fde6e6',
  'Sewell Old Boys FC vs south philadelphia supersite',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a6043f01-62d4-4323-8166-2b1f75fde6e6',
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  NULL,
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
  'a54e157e-236c-4d80-876b-0f4f3346c46d',
  'Sewell Old Boys FC vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a54e157e-236c-4d80-876b-0f4f3346c46d',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
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
  '9676d889-84b2-455d-8770-d0c0e640199c',
  'Sewell Old Boys FC vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-04T01:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9676d889-84b2-455d-8770-d0c0e640199c',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
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
  '289a422f-d709-4313-8e29-73c988cd2a04',
  'Sewell Old Boys FC vs st joseph academy - moss mill park turf',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-08T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:31.710Z',
  '2025-12-15T19:22:31.710Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '289a422f-d709-4313-8e29-73c988cd2a04',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
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
  '868e6782-00e3-49d5-8b7e-82f1716c6fac',
  'Medford Strikers vs rowan university',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-07T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '868e6782-00e3-49d5-8b7e-82f1716c6fac',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  'd47626ed-a62e-4945-8b5c-beb7a328edbb',
  'Medford Strikers vs lighthouse field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-14T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd47626ed-a62e-4945-8b5c-beb7a328edbb',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  '26293262-4269-4f39-877e-72df0015ac58',
  'Medford Strikers vs german american society - nick wiener sr field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '26293262-4269-4f39-877e-72df0015ac58',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  '893994ce-275e-4933-833e-79e0eb25e2ad',
  'Medford Strikers vs northeast high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '893994ce-275e-4933-833e-79e0eb25e2ad',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  '748ea494-264d-482e-864b-241ec393f8e8',
  'Medford Strikers vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-11T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '748ea494-264d-482e-864b-241ec393f8e8',
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  NULL,
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
  '2feff6a7-c36a-48d2-8458-1662616f5ee3',
  'Medford Strikers vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2feff6a7-c36a-48d2-8458-1662616f5ee3',
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  NULL,
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
  'ba242b99-84c1-4781-897c-7f1ef65c87fa',
  'Medford Strikers vs mercer county community college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-03T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ba242b99-84c1-4781-897c-7f1ef65c87fa',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  '45ce78df-2da2-4dc0-829f-58800533099a',
  'Medford Strikers vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '45ce78df-2da2-4dc0-829f-58800533099a',
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  NULL,
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
  '469028ae-3e71-4f18-8458-f420a57e791e',
  'Medford Strikers vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '469028ae-3e71-4f18-8458-f420a57e791e',
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  NULL,
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
  'b025ac8e-ea86-44ac-817e-ac02653db113',
  'Medford Strikers vs veteran''s park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-21T01:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b025ac8e-ea86-44ac-817e-ac02653db113',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
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
  'f1a6db57-6e50-49da-8db3-0464d7ccecd3',
  'Medford Strikers vs westhampton sports complex',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:32.821Z',
  '2025-12-15T19:22:32.821Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f1a6db57-6e50-49da-8db3-0464d7ccecd3',
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  NULL,
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
  'e8c598b1-68c2-4992-8d30-3178fcab4ffe',
  'Nova FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e8c598b1-68c2-4992-8d30-3178fcab4ffe',
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  NULL,
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
  'e7465b99-a43c-439a-8843-2e81cebb8807',
  'Nova FC vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e7465b99-a43c-439a-8843-2e81cebb8807',
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  NULL,
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
  '5306bb89-2b97-443d-8ff4-23151d1efc1c',
  'Nova FC vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5306bb89-2b97-443d-8ff4-23151d1efc1c',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
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
  'd73dca30-313c-4bdf-835f-9ca3e38ce3b6',
  'Nova FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd73dca30-313c-4bdf-835f-9ca3e38ce3b6',
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  NULL,
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
  'da5c55c3-80c4-4b9e-826b-0e3c54d81d58',
  'Nova FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'da5c55c3-80c4-4b9e-826b-0e3c54d81d58',
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  NULL,
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
  '0f986d56-0616-4a06-8471-341da7cb64f7',
  'Nova FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0f986d56-0616-4a06-8471-341da7cb64f7',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
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
  '951e8908-07de-4886-844b-4f37b451f069',
  'Nova FC vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-10T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '951e8908-07de-4886-844b-4f37b451f069',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
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
  '914a3101-5e7e-43ab-8f24-341d8167805e',
  'Nova FC vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T00:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:34.591Z',
  '2025-12-15T19:22:34.591Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '914a3101-5e7e-43ab-8f24-341d8167805e',
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  NULL,
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
  '71e43269-483f-4b57-88d8-fcbf6a5515d0',
  'VA Marauders FC vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-15T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '71e43269-483f-4b57-88d8-fcbf6a5515d0',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  '65d80ba9-ee44-43ea-8e57-2c0f62b5362d',
  'VA Marauders FC vs woodbridge middle school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '65d80ba9-ee44-43ea-8e57-2c0f62b5362d',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  '9c2354da-1033-4756-8e1e-825c504fb518',
  'VA Marauders FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9c2354da-1033-4756-8e1e-825c504fb518',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  'f578d3aa-6bbb-4d20-893a-dce3e77f040d',
  'VA Marauders FC vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f578d3aa-6bbb-4d20-893a-dce3e77f040d',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
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
  '891ec698-5c8f-4a0b-80e9-dcc71364fd8f',
  'VA Marauders FC vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '891ec698-5c8f-4a0b-80e9-dcc71364fd8f',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  '55bf754a-526a-4f2d-8997-dc01d53b889e',
  'VA Marauders FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '55bf754a-526a-4f2d-8997-dc01d53b889e',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  '1469a26c-4883-46e4-84d7-164c09e8ba52',
  'VA Marauders FC vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1469a26c-4883-46e4-84d7-164c09e8ba52',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  'c5626055-17c1-4b70-895e-9fe2fc9db7cc',
  'VA Marauders FC vs norfolk christian school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c5626055-17c1-4b70-895e-9fe2fc9db7cc',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
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
  'fa32384f-e112-4e8c-8e98-8110ecfee194',
  'VA Marauders FC vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:36.046Z',
  '2025-12-15T19:22:36.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fa32384f-e112-4e8c-8e98-8110ecfee194',
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  NULL,
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
  '66bb3108-953d-4b4a-8f9d-cdd7b1642177',
  'Wave FC vs woodbridge middle school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '66bb3108-953d-4b4a-8f9d-cdd7b1642177',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
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
  'dbb9579a-3bb5-4638-8436-06f690c60d65',
  'Wave FC vs tucker hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'dbb9579a-3bb5-4638-8436-06f690c60d65',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
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
  'bd40c3ea-fbcb-4153-833a-1d5bc1b217de',
  'Wave FC vs norfolk collegiate school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-04T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bd40c3ea-fbcb-4153-833a-1d5bc1b217de',
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  NULL,
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
  '85170684-9635-4b21-83d4-f3e6a07f5b3e',
  'Wave FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '85170684-9635-4b21-83d4-f3e6a07f5b3e',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
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
  'bebf3df1-fa58-4268-8ba4-7097f19fe0cb',
  'Wave FC vs norfolk christian school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'bebf3df1-fa58-4268-8ba4-7097f19fe0cb',
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  NULL,
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
  '4bb01bad-ab08-4096-84c4-c06d8dc450e4',
  'Wave FC vs norfolk collegiate school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-08T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4bb01bad-ab08-4096-84c4-c06d8dc450e4',
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  NULL,
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
  '84ec242d-2c0b-4186-8559-3c2721144e5d',
  'Wave FC vs norfolk christian school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:37.170Z',
  '2025-12-15T19:22:37.170Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '84ec242d-2c0b-4186-8559-3c2721144e5d',
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  NULL,
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
  '6dbf057b-ba1d-42ab-8cd2-7fd92a335280',
  'PFA EPSL vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6dbf057b-ba1d-42ab-8cd2-7fd92a335280',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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
  'ded9a904-07fc-424f-8fa7-fc0b431f35b1',
  'PFA EPSL vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ded9a904-07fc-424f-8fa7-fc0b431f35b1',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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
  '466b67ea-0987-4db4-8057-315225bd34b7',
  'PFA EPSL vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '466b67ea-0987-4db4-8057-315225bd34b7',
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  NULL,
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
  'e91d0104-e2d9-4d9c-8ab3-5776d87a8c55',
  'PFA EPSL vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e91d0104-e2d9-4d9c-8ab3-5776d87a8c55',
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  NULL,
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
  'd8551557-65f7-48ec-8287-e0d81b243b34',
  'PFA EPSL vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-10T00:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd8551557-65f7-48ec-8287-e0d81b243b34',
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  NULL,
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
  '9721637e-547a-4279-8bea-ca6878454d84',
  'PFA EPSL vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9721637e-547a-4279-8bea-ca6878454d84',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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
  '4d917dd6-30ca-4d06-85af-3937ad109e09',
  'PFA EPSL vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4d917dd6-30ca-4d06-85af-3937ad109e09',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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
  'cafef2ee-993d-4331-82cc-2a0563935703',
  'PFA EPSL vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-07T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:38.188Z',
  '2025-12-15T19:22:38.188Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cafef2ee-993d-4331-82cc-2a0563935703',
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  NULL,
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
  '6577e903-0823-4e50-8af6-721d9e091a29',
  'Grove Soccer United vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-13T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6577e903-0823-4e50-8af6-721d9e091a29',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
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
  'b4c9b146-40e5-40af-8649-2db4af29afb2',
  'Grove Soccer United vs woodbridge middle school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b4c9b146-40e5-40af-8649-2db4af29afb2',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
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
  '9d77a9d5-3c31-448e-8b31-97649a9ab713',
  'Grove Soccer United vs tucker hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9d77a9d5-3c31-448e-8b31-97649a9ab713',
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  NULL,
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
  '66b8803e-de4f-4fbe-8715-7903ab6276ad',
  'Grove Soccer United vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '66b8803e-de4f-4fbe-8715-7903ab6276ad',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
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
  'd7a7c817-9f8d-4014-8e98-c7a62b9ee673',
  'Grove Soccer United vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T22:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd7a7c817-9f8d-4014-8e98-c7a62b9ee673',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
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
  '92c8957a-88d8-42b1-81e7-f7cee7007597',
  'Grove Soccer United vs norfolk collegiate school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-08T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '92c8957a-88d8-42b1-81e7-f7cee7007597',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
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
  '7496ab3c-39b4-4e3b-8193-4002e6d76091',
  'Grove Soccer United vs godwin high school -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T19:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7496ab3c-39b4-4e3b-8193-4002e6d76091',
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  NULL,
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
  'cc7c0aba-95f3-48c9-8e2f-beede78080b4',
  'Grove Soccer United vs reynolds cc -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:39.522Z',
  '2025-12-15T19:22:39.522Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cc7c0aba-95f3-48c9-8e2f-beede78080b4',
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  NULL,
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
  '011bccfc-5f25-4b73-8560-0578251542d9',
  'Christos FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '011bccfc-5f25-4b73-8560-0578251542d9',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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
  '0eb6e260-836f-418f-87fb-19faeeb60d95',
  'Christos FC vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0eb6e260-836f-418f-87fb-19faeeb60d95',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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
  '5f8c5972-79d1-49f5-8dc9-8c67881cb3dc',
  'Christos FC vs patriot park - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T23:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5f8c5972-79d1-49f5-8dc9-8c67881cb3dc',
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  NULL,
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
  'fee6d01b-70a2-4048-8d95-922956304f4d',
  'Christos FC vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fee6d01b-70a2-4048-8d95-922956304f4d',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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
  'a2a7faaa-13c2-4ed8-8f4b-63611dc65892',
  'Christos FC vs tbd',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a2a7faaa-13c2-4ed8-8f4b-63611dc65892',
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  NULL,
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
  'e1e1f674-5707-4e36-878a-61dd14662c0b',
  'Christos FC vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-17T00:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e1e1f674-5707-4e36-878a-61dd14662c0b',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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
  '3b2c2a6b-be6e-4fc0-88ef-e8f9367d8989',
  'Christos FC vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-22T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:40.878Z',
  '2025-12-15T19:22:40.878Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3b2c2a6b-be6e-4fc0-88ef-e8f9367d8989',
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  NULL,
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
  '5f8f56ad-3ee7-49c8-829f-891ec3386fd7',
  'Delmarva Thunder vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-20T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5f8f56ad-3ee7-49c8-829f-891ec3386fd7',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  '626daae5-6a3f-4147-89a3-f46221f33abc',
  'Delmarva Thunder vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-27T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '626daae5-6a3f-4147-89a3-f46221f33abc',
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  NULL,
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
  'acf81349-0ba1-4caa-8aed-71e392a57ff4',
  'Delmarva Thunder vs norfolk collegiate school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-04T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'acf81349-0ba1-4caa-8aed-71e392a57ff4',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  '8bbd8400-69fb-42d1-81bf-4278b6e26c62',
  'Delmarva Thunder vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-18T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8bbd8400-69fb-42d1-81bf-4278b6e26c62',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  'e8aadbe0-83e3-4c23-88d6-dc7fbbd26a13',
  'Delmarva Thunder vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-25T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e8aadbe0-83e3-4c23-88d6-dc7fbbd26a13',
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  NULL,
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
  'ec55aff8-7dc6-40a4-8e18-829537c2b86d',
  'Delmarva Thunder vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-08T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ec55aff8-7dc6-40a4-8e18-829537c2b86d',
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  NULL,
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
  '08510ceb-a4a8-48b9-8a32-a269666cbff8',
  'Delmarva Thunder vs godwin high school -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T19:45:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '08510ceb-a4a8-48b9-8a32-a269666cbff8',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  '30ba53ae-7e6b-4625-85ee-657f8652ac7a',
  'Delmarva Thunder vs tbd',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-15T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '30ba53ae-7e6b-4625-85ee-657f8652ac7a',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  'af88acf2-b1eb-41ea-8779-f231902f2bc6',
  'Delmarva Thunder vs edison high school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-06T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.024Z',
  '2025-12-15T19:22:42.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'af88acf2-b1eb-41ea-8779-f231902f2bc6',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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
  'c32ae5a3-b452-4458-827f-a3d8bb39608b',
  'PW Nova vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-15T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c32ae5a3-b452-4458-827f-a3d8bb39608b',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
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
  'ce1116e7-0726-431d-8bff-91fef1ca8e7d',
  'PW Nova vs woodbridge middle school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'ce1116e7-0726-431d-8bff-91fef1ca8e7d',
  'ec459901-be4c-4586-8296-a0ca018b0759',
  NULL,
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
  '109d33e4-13a6-4fc7-8f3f-f432a8770125',
  'PW Nova vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-29T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '109d33e4-13a6-4fc7-8f3f-f432a8770125',
  'ec459901-be4c-4586-8296-a0ca018b0759',
  NULL,
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
  '55d510dc-1b40-48cd-8902-589d78de8e70',
  'PW Nova vs poplar tree park - 2',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-06T00:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '55d510dc-1b40-48cd-8902-589d78de8e70',
  'ec459901-be4c-4586-8296-a0ca018b0759',
  NULL,
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
  '7bd56c22-ac5c-4fa1-8808-4d602c6e6ed7',
  'PW Nova vs norfolk christian school - 1',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-02T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7bd56c22-ac5c-4fa1-8808-4d602c6e6ed7',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
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
  '2af70697-c811-40d0-89d2-e7ba5db6ff70',
  'PW Nova vs seaford high school - seaford hs',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-08T20:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2af70697-c811-40d0-89d2-e7ba5db6ff70',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
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
  '745c479c-3485-47ea-8f6d-33d210f6174b',
  'PW Nova vs reynolds cc -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '745c479c-3485-47ea-8f6d-33d210f6174b',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
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
  'aa765d2c-8704-41ca-85cd-0478b650df3b',
  'PW Nova vs liberty sports park -',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-07T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:42.952Z',
  '2025-12-15T19:22:42.952Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'aa765d2c-8704-41ca-85cd-0478b650df3b',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
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
  'f6262131-728c-4466-80b1-20bafcea4fd6',
  'Terminus FC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f6262131-728c-4466-80b1-20bafcea4fd6',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
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
  '0f9377de-425f-44fd-84ce-0c548c99bb0d',
  'Terminus FC vs piedmont park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0f9377de-425f-44fd-84ce-0c548c99bb0d',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
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
  'adde9a32-25f2-4b29-8674-9551912bc7f2',
  'Terminus FC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'adde9a32-25f2-4b29-8674-9551912bc7f2',
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  NULL,
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
  'daaf1da9-cf08-4460-8a84-12651cbad979',
  'Terminus FC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'daaf1da9-cf08-4460-8a84-12651cbad979',
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  NULL,
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
  'd0a34270-273d-4918-82f8-f81d32fb6cd6',
  'Terminus FC vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd0a34270-273d-4918-82f8-f81d32fb6cd6',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
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
  'a69e5433-ece1-41c8-8eee-d63fde72a605',
  'Terminus FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a69e5433-ece1-41c8-8eee-d63fde72a605',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
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
  '1d2e2f11-c0eb-4572-89af-38d2574e8987',
  'Terminus FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1d2e2f11-c0eb-4572-89af-38d2574e8987',
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  NULL,
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
  '35eee203-4e30-4ded-8378-7946cd6a4631',
  'Terminus FC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:44.240Z',
  '2025-12-15T19:22:44.240Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '35eee203-4e30-4ded-8378-7946cd6a4631',
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  NULL,
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
  '7212e4f9-fa10-4237-8ccb-8c9ff7732c3c',
  'Prima FC vs piedmont park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7212e4f9-fa10-4237-8ccb-8c9ff7732c3c',
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  NULL,
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
  '7b01af5c-d972-473b-82a0-52efd9e57620',
  'Prima FC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7b01af5c-d972-473b-82a0-52efd9e57620',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
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
  '5d44e3ac-31cb-473d-854b-68e5a7ea5aa0',
  'Prima FC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '5d44e3ac-31cb-473d-854b-68e5a7ea5aa0',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
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
  'f4929c55-3dbe-49cb-8e3b-7ed072285e97',
  'Prima FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f4929c55-3dbe-49cb-8e3b-7ed072285e97',
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  NULL,
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
  '990ea5a8-c8d4-4e9f-8ac6-8959c418c1cb',
  'Prima FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '990ea5a8-c8d4-4e9f-8ac6-8959c418c1cb',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
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
  'a8f0cece-ce84-436b-83b0-7616485ac146',
  'Prima FC vs ebster field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a8f0cece-ce84-436b-83b0-7616485ac146',
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  NULL,
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
  'cdc60918-111e-4797-8bbe-8c5a60b460a2',
  'Prima FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-07T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cdc60918-111e-4797-8bbe-8c5a60b460a2',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
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
  'a84900af-b57c-454a-8857-cfa52a8f548f',
  'Prima FC vs ebster field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:45.468Z',
  '2025-12-15T19:22:45.468Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a84900af-b57c-454a-8857-cfa52a8f548f',
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  NULL,
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
  'f940843a-3144-4205-8282-ec504bb53f09',
  'Majestic SC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f940843a-3144-4205-8282-ec504bb53f09',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
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
  '3b1b0c54-a25d-4f4f-85a7-cbee2c70b312',
  'Majestic SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3b1b0c54-a25d-4f4f-85a7-cbee2c70b312',
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  NULL,
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
  'a77dd4a9-f924-41c0-8526-b06aae3ee81e',
  'Majestic SC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a77dd4a9-f924-41c0-8526-b06aae3ee81e',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
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
  'c60877e8-a2aa-4f9a-839d-ee247dec1b6d',
  'Majestic SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c60877e8-a2aa-4f9a-839d-ee247dec1b6d',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
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
  '9e60c9f5-4ae9-4622-89d9-5c0c31cec0df',
  'Majestic SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9e60c9f5-4ae9-4622-89d9-5c0c31cec0df',
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  NULL,
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
  'fce53c6b-1d17-44e6-843e-472129e05da9',
  'Majestic SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'fce53c6b-1d17-44e6-843e-472129e05da9',
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  NULL,
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
  '2d4ae6e0-bacd-4a92-8ecd-54d0fc6ac9c8',
  'Majestic SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '2d4ae6e0-bacd-4a92-8ecd-54d0fc6ac9c8',
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  NULL,
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
  '1a598689-bc58-4c98-80cc-53bfea6dc636',
  'Majestic SC vs ebster field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-14T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:46.690Z',
  '2025-12-15T19:22:46.690Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1a598689-bc58-4c98-80cc-53bfea6dc636',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
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
  '1f4958b6-d745-43b5-8425-3831b243ddae',
  'Peachtree FC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1f4958b6-d745-43b5-8425-3831b243ddae',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
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
  'e5bb9430-412a-4429-86d2-aa82905d8275',
  'Peachtree FC vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'e5bb9430-412a-4429-86d2-aa82905d8275',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
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
  'a48d3e50-0f4f-4ce0-800a-afd7483cfe30',
  'Peachtree FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'a48d3e50-0f4f-4ce0-800a-afd7483cfe30',
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  NULL,
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
  '77a1f482-c73f-4b1a-8fe7-10b07bacc6c6',
  'Peachtree FC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '77a1f482-c73f-4b1a-8fe7-10b07bacc6c6',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
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
  '29511dcd-e24c-4371-8315-d861bf78a486',
  'Peachtree FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '29511dcd-e24c-4371-8315-d861bf78a486',
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  NULL,
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
  '273ebb6d-1a45-4ff9-8d3d-d0453229db44',
  'Peachtree FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '273ebb6d-1a45-4ff9-8d3d-d0453229db44',
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  NULL,
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
  '7756ccd3-036c-4934-87ac-e89b6a327bf4',
  'Peachtree FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T16:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7756ccd3-036c-4934-87ac-e89b6a327bf4',
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  NULL,
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
  '574f9c4c-d333-42a0-869b-1983790da701',
  'Peachtree FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:48.062Z',
  '2025-12-15T19:22:48.062Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '574f9c4c-d333-42a0-869b-1983790da701',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
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
  '380451d9-dc39-4b76-8460-77bcf8702967',
  'Bel Calcio FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '380451d9-dc39-4b76-8460-77bcf8702967',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
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
  '8d0cd33e-1593-450b-8a02-89770a6054f5',
  'Bel Calcio FC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8d0cd33e-1593-450b-8a02-89770a6054f5',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
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
  '40964053-c533-4e56-8ed9-b7bc8d0521e6',
  'Bel Calcio FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '40964053-c533-4e56-8ed9-b7bc8d0521e6',
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  NULL,
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
  '00a20fd4-2826-4440-84fc-a6e5a256b8a4',
  'Bel Calcio FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '00a20fd4-2826-4440-84fc-a6e5a256b8a4',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
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
  'aaacb9a8-503c-4757-8bbf-5f399a140e89',
  'Bel Calcio FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'aaacb9a8-503c-4757-8bbf-5f399a140e89',
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  NULL,
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
  'd3b19f88-0391-4171-82a2-ff00c04afe5b',
  'Bel Calcio FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd3b19f88-0391-4171-82a2-ff00c04afe5b',
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  NULL,
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
  '3dee3f92-ab95-4adc-854b-528649328e54',
  'Bel Calcio FC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3dee3f92-ab95-4adc-854b-528649328e54',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
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
  '63c55b18-6b2e-4fe5-8add-ebc0fc273beb',
  'Bel Calcio FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-12-07T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:49.382Z',
  '2025-12-15T19:22:49.382Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '63c55b18-6b2e-4fe5-8add-ebc0fc273beb',
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  NULL,
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
  'd212ad09-8528-4e17-8349-4e8680ad6e83',
  'Buckhead SC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd212ad09-8528-4e17-8349-4e8680ad6e83',
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  NULL,
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
  '6e5a1173-b48e-4a2f-8c70-b78c29c148f0',
  'Buckhead SC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6e5a1173-b48e-4a2f-8c70-b78c29c148f0',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
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
  'c749d97c-5c95-4fbb-8f1d-00864a4ea231',
  'Buckhead SC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T17:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c749d97c-5c95-4fbb-8f1d-00864a4ea231',
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  NULL,
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
  'c94edc33-1dd4-4600-8f2d-eadee78067d9',
  'Buckhead SC vs brook run park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T13:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c94edc33-1dd4-4600-8f2d-eadee78067d9',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
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
  'd0290853-4535-48c4-8771-8ee3afc952a9',
  'Buckhead SC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T16:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd0290853-4535-48c4-8771-8ee3afc952a9',
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  NULL,
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
  '7183aae1-59de-447f-8537-c7530116e434',
  'Buckhead SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7183aae1-59de-447f-8537-c7530116e434',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
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
  'd846f093-33c6-438b-8814-904a25367b8c',
  'Buckhead SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'd846f093-33c6-438b-8814-904a25367b8c',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
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
  '8d46ea3b-b44e-4d59-809e-f70dcf44f140',
  'Buckhead SC vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:50.808Z',
  '2025-12-15T19:22:50.808Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8d46ea3b-b44e-4d59-809e-f70dcf44f140',
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  NULL,
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
  'b40ce421-a6fd-4af9-8f5f-ecf5660f9a0a',
  'Alliance SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'b40ce421-a6fd-4af9-8f5f-ecf5660f9a0a',
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  NULL,
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
  '7ce6bff3-044e-4e79-8223-d47eabaeebd3',
  'Alliance SC vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7ce6bff3-044e-4e79-8223-d47eabaeebd3',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
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
  '3e784d48-c2b1-4fde-8d3e-39efc26bfaf3',
  'Alliance SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3e784d48-c2b1-4fde-8d3e-39efc26bfaf3',
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  NULL,
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
  '1f624d83-2822-458a-8044-130a22613456',
  'Alliance SC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1f624d83-2822-458a-8044-130a22613456',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
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
  '8f0c8b07-024c-4829-83e3-cec341c7d7f0',
  'Alliance SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '8f0c8b07-024c-4829-83e3-cec341c7d7f0',
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  NULL,
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
  '682e74c9-d0bb-423e-8daa-88542f707a95',
  'Alliance SC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '682e74c9-d0bb-423e-8daa-88542f707a95',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
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
  '7b834b50-4717-41fb-8a84-f5b906f50421',
  'Alliance SC vs empower college & career center',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T23:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7b834b50-4717-41fb-8a84-f5b906f50421',
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  NULL,
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
  '61acb7b3-fc9e-4fc8-8c3d-669bbe549a27',
  'Alliance SC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T19:30:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:51.988Z',
  '2025-12-15T19:22:51.988Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '61acb7b3-fc9e-4fc8-8c3d-669bbe549a27',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
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
  '6fef3ae9-2b59-46b5-8e27-25f71d38ffc9',
  'SC Gwinnett vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '6fef3ae9-2b59-46b5-8e27-25f71d38ffc9',
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  NULL,
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
  '125f75b4-84f2-433a-87dd-9a94897e2016',
  'SC Gwinnett vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-05T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '125f75b4-84f2-433a-87dd-9a94897e2016',
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  NULL,
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
  'cd97f608-ef4f-4b76-893e-d367db76573e',
  'SC Gwinnett vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cd97f608-ef4f-4b76-893e-d367db76573e',
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  NULL,
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
  'dbb15e49-1f56-4397-8f93-83a7217dddb0',
  'SC Gwinnett vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'dbb15e49-1f56-4397-8f93-83a7217dddb0',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
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
  '503898df-1f11-40fe-8e2a-1a3936a1b869',
  'SC Gwinnett vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '503898df-1f11-40fe-8e2a-1a3936a1b869',
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  NULL,
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
  '1bf9212e-fa07-42fc-873b-97c76094291a',
  'SC Gwinnett vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T21:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '1bf9212e-fa07-42fc-873b-97c76094291a',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
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
  'cdc310d0-0be8-4cb0-84d8-fbeeaea93dda',
  'SC Gwinnett vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T15:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'cdc310d0-0be8-4cb0-84d8-fbeeaea93dda',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
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
  '4c6b17af-0621-459d-866c-a43b908205be',
  'SC Gwinnett vs agnes scott college',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T18:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:53.450Z',
  '2025-12-15T19:22:53.450Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '4c6b17af-0621-459d-866c-a43b908205be',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
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
  'f0464e09-3469-415a-8fb2-5b33f7182fcb',
  'Lithonia City FC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-21T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'f0464e09-3469-415a-8fb2-5b33f7182fcb',
  '55ed4434-a232-448f-8f3b-b52933af199b',
  NULL,
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
  'c00d36d8-e4b4-4444-81c7-e3c63f220d76',
  'Lithonia City FC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-09-28T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  'c00d36d8-e4b4-4444-81c7-e3c63f220d76',
  '55ed4434-a232-448f-8f3b-b52933af199b',
  NULL,
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
  '0d443b89-cb48-44be-81ea-c502de291c26',
  'Lithonia City FC vs jm tull gwinnett family ymca',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-12T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '0d443b89-cb48-44be-81ea-c502de291c26',
  NULL,
  '55ed4434-a232-448f-8f3b-b52933af199b',
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
  '462be6b4-42f8-4bc8-8ba2-8ea60300bdb8',
  'Lithonia City FC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-19T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '462be6b4-42f8-4bc8-8ba2-8ea60300bdb8',
  '55ed4434-a232-448f-8f3b-b52933af199b',
  NULL,
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
  '7a03a6e9-9e86-44f2-8749-50d2ce616dfd',
  'Lithonia City FC vs bay creek park',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-10-26T22:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '7a03a6e9-9e86-44f2-8749-50d2ce616dfd',
  '55ed4434-a232-448f-8f3b-b52933af199b',
  NULL,
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
  '3b90d82c-1837-431e-878b-5313a3d513ff',
  'Lithonia City FC vs maynard h jackson high school',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-09T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3b90d82c-1837-431e-878b-5313a3d513ff',
  NULL,
  '55ed4434-a232-448f-8f3b-b52933af199b',
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
  '3e3dd324-18ba-48d9-873c-e0f93a9190c2',
  'Lithonia City FC vs the best academy',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-16T14:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '3e3dd324-18ba-48d9-873c-e0f93a9190c2',
  NULL,
  '55ed4434-a232-448f-8f3b-b52933af199b',
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
  '9959b234-8acc-4e22-8d71-94e7ae9a991d',
  'Lithonia City FC vs ebster field',
  '550e8400-e29b-41d4-a716-446655440402',
  '2025-11-23T19:00:00.000Z',
  NULL,
  NULL,
  NULL,
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440311',
  'apsl',
  NULL,
  true,
  '2025-12-15T19:22:54.648Z',
  '2025-12-15T19:22:54.648Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  '9959b234-8acc-4e22-8d71-94e7ae9a991d',
  NULL,
  '55ed4434-a232-448f-8f3b-b52933af199b',
  NULL,
  NULL,
  'scheduled',
  NULL
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;
