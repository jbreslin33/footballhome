-- APSL Matches

INSERT INTO matches (event_id, title, event_type_id, event_date, duration_minutes, venue_id, description, created_by, external_event_id, cancelled, cancellation_reason, created_at, updated_at, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1f416b10-a260-431c-834a-e4fe84e4644c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Fitchburg FC',
  NULL,
  '2025-09-13T20:00:00.000Z',
  '03c24bc9-e61d-44a5-8a35-5d1005a5a98a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1f416b10-a260-431c-834a-e4fe84e4644c',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f3ae6c56-a7aa-46b7-b262-e850e2d00e28', '1f416b10-a260-431c-834a-e4fe84e4644c', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '449b6087-e020-4191-88d4-b691274fe05d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Project Football',
  NULL,
  '2025-09-21T15:00:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '449b6087-e020-4191-88d4-b691274fe05d',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f8ce921d-892d-4660-9e70-96d9b51b4376', '449b6087-e020-4191-88d4-b691274fe05d', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8cec13fe-ae6f-4801-8038-0ea910621545',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Invictus FC',
  NULL,
  '2025-09-28T21:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8cec13fe-ae6f-4801-8038-0ea910621545',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2e6e5722-3406-442d-a30d-ec35cef5bb84', '8cec13fe-ae6f-4801-8038-0ea910621545', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '56c57180-23d6-435e-8bae-093a9e6b858e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Scrub Nation',
  NULL,
  '2025-10-05T19:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '56c57180-23d6-435e-8bae-093a9e6b858e',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3ae12e2e-09ea-4795-97d2-9f659cf83a95', '56c57180-23d6-435e-8bae-093a9e6b858e', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4dbd7acb-4e9b-4ac5-8ecc-4251d218cf53',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Praia Kapital',
  NULL,
  '2025-10-26T22:00:00.000Z',
  '4864695a-2d0f-4f8d-86d9-98b53a96cccc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4dbd7acb-4e9b-4ac5-8ecc-4251d218cf53',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e8f3af7d-ccac-4889-a36e-9e71b4768ed8', '4dbd7acb-4e9b-4ac5-8ecc-4251d218cf53', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ecc56ef1-df94-4eb3-8aa8-0595450e3823',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Sete Setembro USA',
  NULL,
  '2025-11-01T19:00:00.000Z',
  '03c24bc9-e61d-44a5-8a35-5d1005a5a98a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ecc56ef1-df94-4eb3-8aa8-0595450e3823',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6feaa2f4-b56b-4690-8f3e-644ad7200811', 'ecc56ef1-df94-4eb3-8aa8-0595450e3823', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '177f0885-6a3d-4b96-8738-8459f94d3814',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Invictus FC',
  NULL,
  '2025-11-07T00:15:00.000Z',
  '6f8dac90-b04c-4b52-84e4-974956cfd196',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '177f0885-6a3d-4b96-8738-8459f94d3814',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d0ae9d83-3cf2-47ff-ae55-adc6666a984d', '177f0885-6a3d-4b96-8738-8459f94d3814', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '31d0e2b0-f1b8-4b7c-8757-f59727425d8a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Fitchburg FC',
  NULL,
  '2025-11-09T19:00:00.000Z',
  '09ef72d2-04b3-44d8-877c-42b91b2a083b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '31d0e2b0-f1b8-4b7c-8757-f59727425d8a',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  8,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('624c578e-1a62-4cf7-8532-f9cbd3e6f9bb', '31d0e2b0-f1b8-4b7c-8757-f59727425d8a', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c179ba09-d16b-4492-890f-138b260d593f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs South Coast Union',
  NULL,
  '2025-11-21T01:00:00.000Z',
  '6f8dac90-b04c-4b52-84e4-974956cfd196',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c179ba09-d16b-4492-890f-138b260d593f',
  NULL,
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c5fd897a-97e3-4046-93e0-4df0830a3dc6', 'c179ba09-d16b-4492-890f-138b260d593f', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7b749306-1fb3-4b30-89a9-60e40ec9da43',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs South Coast Union',
  NULL,
  '2026-08-24T18:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7b749306-1fb3-4b30-89a9-60e40ec9da43',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('56adac54-0c2d-4960-8976-be66c6fcc130', '7b749306-1fb3-4b30-89a9-60e40ec9da43', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '18473423-df44-4c59-81fa-621cad15a47b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Invictus FC',
  NULL,
  '2025-09-07T19:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '18473423-df44-4c59-81fa-621cad15a47b',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f950c8f6-694a-4255-8ff7-efa1eb78e40e', '18473423-df44-4c59-81fa-621cad15a47b', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '35f30df7-28d0-435e-8cf8-b0b887b68f34',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs South Coast Union',
  NULL,
  '2025-09-14T17:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '35f30df7-28d0-435e-8cf8-b0b887b68f34',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d21d6513-50fe-4186-966b-a415c3ea00f6', '35f30df7-28d0-435e-8cf8-b0b887b68f34', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5a9c5176-109d-4f82-85e5-9b4f1ec043ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Sete Setembro USA',
  NULL,
  '2025-09-25T00:30:00.000Z',
  '3124cfb1-e99e-409c-8b80-c9b95e29a579',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5a9c5176-109d-4f82-85e5-9b4f1ec043ea',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('25b03d05-3086-4b27-9d5b-7f61c53eaaa9', '5a9c5176-109d-4f82-85e5-9b4f1ec043ea', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65ff8f4a-751b-461b-8775-954fc3e96bb5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Praia Kapital',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '0302dce8-6cc8-4c02-849f-c787b3d60e64',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65ff8f4a-751b-461b-8775-954fc3e96bb5',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('348c0452-7f58-484e-b4d1-de67ff0d6f39', '65ff8f4a-751b-461b-8775-954fc3e96bb5', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9f3bff6c-c01d-436e-83ee-909ba9c3aa67',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Falcons FC',
  NULL,
  '2025-10-05T19:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9f3bff6c-c01d-436e-83ee-909ba9c3aa67',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4fae4308-433c-4770-b0de-26a723e0e4ee', '9f3bff6c-c01d-436e-83ee-909ba9c3aa67', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd2f916b2-7dfa-4203-820c-d360a3cfd4ad',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Project Football',
  NULL,
  '2025-10-19T15:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd2f916b2-7dfa-4203-820c-d360a3cfd4ad',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('91093bb6-dc62-4bc6-8057-385b6a219069', 'd2f916b2-7dfa-4203-820c-d360a3cfd4ad', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '49c35565-fffe-43a2-86fb-c43ffead2085',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Fitchburg FC',
  NULL,
  '2025-10-26T16:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '49c35565-fffe-43a2-86fb-c43ffead2085',
  NULL,
  '8a804c82-814c-4a90-856b-441236c695ed',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  10,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('10b2c54d-6878-4c2a-9cbd-b53054ba20bd', '49c35565-fffe-43a2-86fb-c43ffead2085', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7f057a54-a9f4-4f23-86f2-9b63070c55e5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Invictus FC',
  NULL,
  '2026-08-24T22:00:00.000Z',
  '6b9153b1-ab90-4baa-81a9-16b2634cc494',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7f057a54-a9f4-4f23-86f2-9b63070c55e5',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('181840ab-8fc9-4dd2-ad88-4e455f065846', '7f057a54-a9f4-4f23-86f2-9b63070c55e5', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1f6db006-8277-44e6-86e2-cb9e54563239',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Project Football',
  NULL,
  '2025-09-06T23:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1f6db006-8277-44e6-86e2-cb9e54563239',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6e29d234-cb88-4bdc-99ed-25d1a19ba710', '1f6db006-8277-44e6-86e2-cb9e54563239', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '61b592c1-525b-4f72-8ed8-b841a17c55d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Invictus FC',
  NULL,
  '2025-09-14T23:00:00.000Z',
  'b89fa1ae-d6ef-43ae-8d93-749eea3ac111',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '61b592c1-525b-4f72-8ed8-b841a17c55d0',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b2b4a80f-332e-4ff1-8116-1e28e1c394f5', '61b592c1-525b-4f72-8ed8-b841a17c55d0', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f8368656-ca81-4cb1-873d-25e2d556d485',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs South Coast Union',
  NULL,
  '2025-09-21T17:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f8368656-ca81-4cb1-873d-25e2d556d485',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('22815843-5f49-4bc3-868b-7049f2c7dea3', 'f8368656-ca81-4cb1-873d-25e2d556d485', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'edd08e8b-3e53-4041-8a98-437944dea4a4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Scrub Nation',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '0302dce8-6cc8-4c02-849f-c787b3d60e64',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'edd08e8b-3e53-4041-8a98-437944dea4a4',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('22125057-e77b-494f-8573-bf5da6be3111', 'edd08e8b-3e53-4041-8a98-437944dea4a4', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6689f8ff-594c-478a-8b33-5f41baa352f3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Sete Setembro USA 


				

			
				APSL New England Cup',
  NULL,
  '2025-10-05T23:00:00.000Z',
  'b89fa1ae-d6ef-43ae-8d93-749eea3ac111',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6689f8ff-594c-478a-8b33-5f41baa352f3',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6c1a4b16-353f-4d09-b522-7cb9ce3c1db9', '6689f8ff-594c-478a-8b33-5f41baa352f3', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd9ce3a96-b0b2-44f2-84ed-1fbb8244b850',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Fitchburg FC',
  NULL,
  '2025-10-12T22:00:00.000Z',
  'b89fa1ae-d6ef-43ae-8d93-749eea3ac111',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd9ce3a96-b0b2-44f2-84ed-1fbb8244b850',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  8,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('27213cb1-3ed1-47ac-8365-3419f3e7eb57', 'd9ce3a96-b0b2-44f2-84ed-1fbb8244b850', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0f93e7e9-f3eb-4b95-86d9-57e02e747a50',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Falcons FC',
  NULL,
  '2025-10-26T22:00:00.000Z',
  '4864695a-2d0f-4f8d-86d9-98b53a96cccc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0f93e7e9-f3eb-4b95-86d9-57e02e747a50',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8543f524-2dff-42fa-ab19-a8abde7fdaa8', '0f93e7e9-f3eb-4b95-86d9-57e02e747a50', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e234e02b-786e-4084-8ee8-fbfaaf8ada2d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Sete Setembro USA',
  NULL,
  '2025-11-04T01:00:00.000Z',
  'ef0480f1-d7ac-4d3f-879b-7735a8a5d36b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e234e02b-786e-4084-8ee8-fbfaaf8ada2d',
  NULL,
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2dc9b231-ba03-47b2-8e2b-8f83a8c78700', 'e234e02b-786e-4084-8ee8-fbfaaf8ada2d', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0b7a53d0-70af-45bc-84c3-d9b28eb8e778',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Scrub Nation',
  NULL,
  '2026-08-24T18:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0b7a53d0-70af-45bc-84c3-d9b28eb8e778',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3d35c511-b3a2-4f8d-b02d-54a9b6f57007', '0b7a53d0-70af-45bc-84c3-d9b28eb8e778', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a539ef69-793d-4432-8962-49ac5548e38c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Scrub Nation',
  NULL,
  '2025-09-14T17:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a539ef69-793d-4432-8962-49ac5548e38c',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1ff4d6e3-96e6-4439-a74e-8f3cc13a29b3', 'a539ef69-793d-4432-8962-49ac5548e38c', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'be592985-c13f-4d81-8cfa-235b0cb37d90',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Praia Kapital',
  NULL,
  '2025-09-21T17:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'be592985-c13f-4d81-8cfa-235b0cb37d90',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6596a9a8-3906-45f6-b12c-2bd66d6aeaf2', 'be592985-c13f-4d81-8cfa-235b0cb37d90', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b73ae17a-c079-4d78-827c-6884bb29269b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Fitchburg FC',
  NULL,
  '2025-09-28T19:30:00.000Z',
  '166f8c9c-62e3-4f44-8f89-b466980698b2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b73ae17a-c079-4d78-827c-6884bb29269b',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('88be99cd-7628-49a9-a0e2-4ac6591fa8dc', 'b73ae17a-c079-4d78-827c-6884bb29269b', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '90189ec6-e985-45e2-8a8f-8f8f29e6a15c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Project Football',
  NULL,
  '2025-10-05T16:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '90189ec6-e985-45e2-8a8f-8f8f29e6a15c',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ca3d5409-f005-4e82-b4d0-352df334a41e', '90189ec6-e985-45e2-8a8f-8f8f29e6a15c', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd365afa6-1f99-4575-8608-15bf2983359b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Invictus FC',
  NULL,
  '2025-10-19T17:45:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd365afa6-1f99-4575-8608-15bf2983359b',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cb321151-bfda-497c-bbdd-dd9b5997fc04', 'd365afa6-1f99-4575-8608-15bf2983359b', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e901c31c-165b-424c-86b6-c2805129e4db',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Sete Setembro USA',
  NULL,
  '2025-10-25T22:00:00.000Z',
  '0aa98063-9c32-47d6-82ac-069da80393f8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e901c31c-165b-424c-86b6-c2805129e4db',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9d0db6ab-58d5-40af-b4c3-fe4ad0d3055e', 'e901c31c-165b-424c-86b6-c2805129e4db', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1e4ecae5-cdfd-4fcd-8d1a-96f556ad2d48',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Project Football',
  NULL,
  '2025-11-09T18:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1e4ecae5-cdfd-4fcd-8d1a-96f556ad2d48',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ffdbbf91-197a-4067-a164-dc8d2baf4747', '1e4ecae5-cdfd-4fcd-8d1a-96f556ad2d48', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f52a1c06-ff5d-486b-853f-e9e6c7e1b937',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Falcons FC',
  NULL,
  '2025-11-21T01:00:00.000Z',
  '6f8dac90-b04c-4b52-84e4-974956cfd196',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f52a1c06-ff5d-486b-853f-e9e6c7e1b937',
  NULL,
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c2c0cf97-4296-43f8-b8e0-85cfb0dc00eb', 'f52a1c06-ff5d-486b-853f-e9e6c7e1b937', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'afa1a1bb-a3c2-4164-80d4-bdd98c0919ce',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Fitchburg FC',
  NULL,
  '2026-08-24T21:30:00.000Z',
  '166f8c9c-62e3-4f44-8f89-b466980698b2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'afa1a1bb-a3c2-4164-80d4-bdd98c0919ce',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4588d9e0-80fe-4315-94ba-5c1b4de7f786', 'afa1a1bb-a3c2-4164-80d4-bdd98c0919ce', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd301c767-ecc0-4576-8f10-2cc087f3dde6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Praia Kapital',
  NULL,
  '2025-09-06T23:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd301c767-ecc0-4576-8f10-2cc087f3dde6',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7c9a52e0-1faf-40c9-9e36-7f563a88c4db', 'd301c767-ecc0-4576-8f10-2cc087f3dde6', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '471c6d0d-7f80-4de1-8ca5-558a0be8cd11',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Strictly Nos FC',
  NULL,
  '2025-09-13T23:30:00.000Z',
  '3124cfb1-e99e-409c-8b80-c9b95e29a579',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '471c6d0d-7f80-4de1-8ca5-558a0be8cd11',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f0352661-95b7-4ba1-8235-272bfc6489c8', '471c6d0d-7f80-4de1-8ca5-558a0be8cd11', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd97e2da2-d1b2-4106-80b5-f362dacfe7a0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Falcons FC',
  NULL,
  '2025-09-21T15:00:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd97e2da2-d1b2-4106-80b5-f362dacfe7a0',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b12ac4fd-17ec-4a04-8dd1-2c85173c5a5a', 'd97e2da2-d1b2-4106-80b5-f362dacfe7a0', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9b98df9c-b56f-4c5d-8c8a-436918d3ecfe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Sete Setembro USA',
  NULL,
  '2025-09-27T22:15:00.000Z',
  '03c24bc9-e61d-44a5-8a35-5d1005a5a98a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9b98df9c-b56f-4c5d-8c8a-436918d3ecfe',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('255712a3-8f82-4579-81b6-943d5a9c926b', '9b98df9c-b56f-4c5d-8c8a-436918d3ecfe', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'efa207df-aa48-4129-82f8-95176a3c6616',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs South Coast Union',
  NULL,
  '2025-10-05T16:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'efa207df-aa48-4129-82f8-95176a3c6616',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9c0a4543-cc72-4944-a83d-de9100d92464', 'efa207df-aa48-4129-82f8-95176a3c6616', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e6b59e45-d630-4f0d-8ece-8f49e5c26ff6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Scrub Nation',
  NULL,
  '2025-10-19T15:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e6b59e45-d630-4f0d-8ece-8f49e5c26ff6',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('19864f6a-63eb-476e-8d2e-296f7ff17bbb', 'e6b59e45-d630-4f0d-8ece-8f49e5c26ff6', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a78b3c5e-4839-41b2-8a22-54f30a4604aa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Invictus FC',
  NULL,
  '2025-10-25T22:15:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a78b3c5e-4839-41b2-8a22-54f30a4604aa',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2cfba703-60b6-4eb8-9d82-a9d47a4a91bd', 'a78b3c5e-4839-41b2-8a22-54f30a4604aa', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4eb2803d-f1ad-4d5f-8819-3827a6e085f0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs South Coast Union',
  NULL,
  '2025-11-09T18:30:00.000Z',
  '117876be-9102-4783-86ab-7718a45eab10',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4eb2803d-f1ad-4d5f-8819-3827a6e085f0',
  NULL,
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('35191224-ee56-4571-a29a-7a9b637956c5', '4eb2803d-f1ad-4d5f-8819-3827a6e085f0', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3be9c444-42f3-436e-8bde-8b3551f0d989',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Praia Kapital',
  NULL,
  '2026-08-24T22:00:00.000Z',
  '6b9153b1-ab90-4baa-81a9-16b2634cc494',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3be9c444-42f3-436e-8bde-8b3551f0d989',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cbb78f4d-8a51-4f9e-9e1e-41d52d826ece', '3be9c444-42f3-436e-8bde-8b3551f0d989', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bb0c0a77-2969-45ec-8041-ea7fafaf959f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Scrub Nation',
  NULL,
  '2025-09-07T19:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bb0c0a77-2969-45ec-8041-ea7fafaf959f',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('280b5113-9dd7-4bef-97a3-2556b5d54840', 'bb0c0a77-2969-45ec-8041-ea7fafaf959f', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5d1f8ecf-952c-4d0f-805b-1bbb8c86526c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Praia Kapital',
  NULL,
  '2025-09-14T23:00:00.000Z',
  'b89fa1ae-d6ef-43ae-8d93-749eea3ac111',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5d1f8ecf-952c-4d0f-805b-1bbb8c86526c',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('693484e2-1aa1-4248-a497-d1a8217868d0', '5d1f8ecf-952c-4d0f-805b-1bbb8c86526c', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ef8b0bf3-6c30-4ad6-8107-6e6e5db76598',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Fitchburg FC',
  NULL,
  '2025-09-21T17:15:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ef8b0bf3-6c30-4ad6-8107-6e6e5db76598',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('64b7f2f7-0bb1-4aa0-9b60-f3a79a84085c', 'ef8b0bf3-6c30-4ad6-8107-6e6e5db76598', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5fe39844-d731-41f3-8a4a-198a97ca20e7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Falcons FC',
  NULL,
  '2025-09-28T21:30:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5fe39844-d731-41f3-8a4a-198a97ca20e7',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('65d99590-b276-4285-a3b8-f6bc27a77ef1', '5fe39844-d731-41f3-8a4a-198a97ca20e7', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cc2b0bd1-42df-44e7-853a-22065325d422',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Sete Setembro USA',
  NULL,
  '2025-10-11T22:15:00.000Z',
  '03c24bc9-e61d-44a5-8a35-5d1005a5a98a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cc2b0bd1-42df-44e7-853a-22065325d422',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e9593cfd-970a-4c39-bfa9-4b41ad600f9c', 'cc2b0bd1-42df-44e7-853a-22065325d422', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '37a3737d-d106-426f-8cdf-c7d87ce8c685',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs South Coast Union',
  NULL,
  '2025-10-19T17:45:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '37a3737d-d106-426f-8cdf-c7d87ce8c685',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('da185eb8-9537-4326-89fa-0aff1438711a', '37a3737d-d106-426f-8cdf-c7d87ce8c685', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3fdb6a6a-f4e5-464d-85f4-d481c0a97061',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Project Football',
  NULL,
  '2025-10-25T22:15:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3fdb6a6a-f4e5-464d-85f4-d481c0a97061',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4387c7b5-4555-4149-84d3-418bc891f88d', '3fdb6a6a-f4e5-464d-85f4-d481c0a97061', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bffad959-3eab-4137-8426-94721f625634',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Falcons FC',
  NULL,
  '2025-11-07T00:15:00.000Z',
  '6f8dac90-b04c-4b52-84e4-974956cfd196',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bffad959-3eab-4137-8426-94721f625634',
  NULL,
  '272b83b4-1153-402d-8a47-015cb13cd376',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('46f1470e-9546-473f-a5c7-fe0903b06f3f', 'bffad959-3eab-4137-8426-94721f625634', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '08a63cb0-808a-48fa-875a-6ffed43371b1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Project Football',
  NULL,
  '2026-08-24T21:30:00.000Z',
  '166f8c9c-62e3-4f44-8f89-b466980698b2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '08a63cb0-808a-48fa-875a-6ffed43371b1',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26c61b84-0809-4880-a557-9c6b8b536aa6', '08a63cb0-808a-48fa-875a-6ffed43371b1', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5913597a-a16b-4d45-8def-8306446bd0c7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Sete Setembro USA',
  NULL,
  '2025-09-06T20:00:00.000Z',
  '166f8c9c-62e3-4f44-8f89-b466980698b2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5913597a-a16b-4d45-8def-8306446bd0c7',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7924aa8a-16c8-49a5-9c7c-4e950b89107c', '5913597a-a16b-4d45-8def-8306446bd0c7', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '04ce9ef2-8739-4717-8b18-2732142a6633',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Falcons FC',
  NULL,
  '2025-09-13T20:00:00.000Z',
  '03c24bc9-e61d-44a5-8a35-5d1005a5a98a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '04ce9ef2-8739-4717-8b18-2732142a6633',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('69f89e3b-2fcc-40c8-a78f-3f08df8c18f5', '04ce9ef2-8739-4717-8b18-2732142a6633', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c5bf91e7-d173-4afc-857e-22d7ef1a783a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Invictus FC',
  NULL,
  '2025-09-21T17:15:00.000Z',
  '6bba8e3f-1909-421e-847e-4b3fa0cdd509',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c5bf91e7-d173-4afc-857e-22d7ef1a783a',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('64b63eea-d20f-4c0c-b217-041cd9ab76c5', 'c5bf91e7-d173-4afc-857e-22d7ef1a783a', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7e501e9d-32c1-4206-8168-53c6ca6d0bf4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs South Coast Union',
  NULL,
  '2025-09-28T19:30:00.000Z',
  '166f8c9c-62e3-4f44-8f89-b466980698b2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7e501e9d-32c1-4206-8168-53c6ca6d0bf4',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0593b7b5-d9a2-47ed-8a77-bfaeca33c3d0', '7e501e9d-32c1-4206-8168-53c6ca6d0bf4', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '635b270d-dfff-49df-8f7e-9f83aa4dff3e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Praia Kapital',
  NULL,
  '2025-10-12T22:00:00.000Z',
  'b89fa1ae-d6ef-43ae-8d93-749eea3ac111',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '635b270d-dfff-49df-8f7e-9f83aa4dff3e',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  8,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2a1563a7-60f1-47fd-a927-c2c895ff7950', '635b270d-dfff-49df-8f7e-9f83aa4dff3e', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ab205bbb-0602-46c8-8317-ff4221a1cdf2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Scrub Nation',
  NULL,
  '2025-10-26T16:30:00.000Z',
  '9e1dcb9e-5b8a-426c-8066-75193c06487a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ab205bbb-0602-46c8-8317-ff4221a1cdf2',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  10,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7a4faa80-c864-401c-9b44-ad90f92bd0de', 'ab205bbb-0602-46c8-8317-ff4221a1cdf2', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'aae45895-aa67-4d40-8c6a-b64aad4b24c3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Falcons FC',
  NULL,
  '2025-11-09T19:00:00.000Z',
  '09ef72d2-04b3-44d8-877c-42b91b2a083b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'aae45895-aa67-4d40-8c6a-b64aad4b24c3',
  NULL,
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  8,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5c0423e0-9ff8-4cb1-b549-125dcec0a0e7', 'aae45895-aa67-4d40-8c6a-b64aad4b24c3', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '92346dd9-c078-459c-851f-084a6c5268cb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Hermandad Connecticut',
  NULL,
  '2025-09-06T23:00:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '92346dd9-c078-459c-851f-084a6c5268cb',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fbfc3bd4-08f4-45b8-b9f0-1c718cec208c', '92346dd9-c078-459c-851f-084a6c5268cb', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fb0d3a40-1876-4ae3-8169-6faee5589ba7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Glastonbury Celtic',
  NULL,
  '2025-09-13T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fb0d3a40-1876-4ae3-8169-6faee5589ba7',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1887db6d-ac82-4015-8a83-8f162d661fec', 'fb0d3a40-1876-4ae3-8169-6faee5589ba7', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2ec19fd1-2b32-487d-8b7f-aa52463f1af4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Wildcat FC',
  NULL,
  '2025-09-20T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2ec19fd1-2b32-487d-8b7f-aa52463f1af4',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('acf86a17-8633-4108-b807-812089dcfcab', '2ec19fd1-2b32-487d-8b7f-aa52463f1af4', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b5a3a8c5-7f7f-47b9-8ebf-720785a1093a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Wildcat FC',
  NULL,
  '2025-09-28T22:30:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b5a3a8c5-7f7f-47b9-8ebf-720785a1093a',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f6ec6d5a-3839-4691-abb4-bbb833dd5440', 'b5a3a8c5-7f7f-47b9-8ebf-720785a1093a', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '947f3b67-ee12-4221-8a5f-92bd1a53068d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Hermandad Connecticut',
  NULL,
  '2025-10-18T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '947f3b67-ee12-4221-8a5f-92bd1a53068d',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('98480713-c77e-461a-91e7-278244ae8f8c', '947f3b67-ee12-4221-8a5f-92bd1a53068d', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c2817f70-949e-4082-8a6d-e375fc048560',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Glastonbury Celtic',
  NULL,
  '2025-10-26T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c2817f70-949e-4082-8a6d-e375fc048560',
  NULL,
  'b67749bd-3006-4977-81db-c16e5c10143c',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('77d7e9ed-8ccf-43cc-8273-55b6b28616bc', 'c2817f70-949e-4082-8a6d-e375fc048560', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '95a67d82-637b-4376-8cee-34af118c23f7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Wildcat FC',
  NULL,
  '2025-09-07T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '95a67d82-637b-4376-8cee-34af118c23f7',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('602b1e4b-ae1d-427c-a790-42bc62463dcc', '95a67d82-637b-4376-8cee-34af118c23f7', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9faf01aa-2ed9-4bd9-87e1-1c2cfba48e1e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs KO Elites',
  NULL,
  '2025-09-13T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9faf01aa-2ed9-4bd9-87e1-1c2cfba48e1e',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('faffb75b-ff85-4c86-aaec-e6f10742b147', '9faf01aa-2ed9-4bd9-87e1-1c2cfba48e1e', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f5405daa-2cf5-47e9-89b5-916c96529540',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Hermandad Connecticut',
  NULL,
  '2025-09-20T23:00:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f5405daa-2cf5-47e9-89b5-916c96529540',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('68c568aa-8d1c-4d1b-b0ac-6ce570810f09', 'f5405daa-2cf5-47e9-89b5-916c96529540', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '866d83aa-f32d-4afb-8db6-122031d958dd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Hermandad Connecticut',
  NULL,
  '2025-09-28T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '866d83aa-f32d-4afb-8db6-122031d958dd',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2926b41f-ab40-45ab-97a9-e86d74d8bd9a', '866d83aa-f32d-4afb-8db6-122031d958dd', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '820c6943-27ad-4a8a-8d94-487028b52370',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Wildcat FC',
  NULL,
  '2025-10-19T22:30:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '820c6943-27ad-4a8a-8d94-487028b52370',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('883e8736-fd60-4a58-95f5-d5ee24624164', '820c6943-27ad-4a8a-8d94-487028b52370', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fd13b4b6-25c1-4660-86c0-255776167608',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs KO Elites',
  NULL,
  '2025-10-26T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fd13b4b6-25c1-4660-86c0-255776167608',
  NULL,
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5284f29f-0f03-4f85-9b12-06c87ed69f6d', 'fd13b4b6-25c1-4660-86c0-255776167608', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '716d5363-bb66-4fe1-8464-c47d2e951a86',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Glastonbury Celtic',
  NULL,
  '2025-09-07T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '716d5363-bb66-4fe1-8464-c47d2e951a86',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('840c850e-ef16-4c30-8cb4-fd13a6789527', '716d5363-bb66-4fe1-8464-c47d2e951a86', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a3766a72-7ff1-453f-89d9-a9481e1c8c36',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Hermandad Connecticut',
  NULL,
  '2025-09-14T22:30:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a3766a72-7ff1-453f-89d9-a9481e1c8c36',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ff6c41be-5f92-402a-81ad-01fc3a781c68', 'a3766a72-7ff1-453f-89d9-a9481e1c8c36', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '57d38fdb-1541-42e9-8c91-a42b43fb01ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs KO Elites',
  NULL,
  '2025-09-20T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '57d38fdb-1541-42e9-8c91-a42b43fb01ea',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9128ca2f-55e3-4ecd-a066-22d324cc0e9b', '57d38fdb-1541-42e9-8c91-a42b43fb01ea', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b09392ac-a20b-4ab6-8271-2eda67850246',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs KO Elites',
  NULL,
  '2025-09-28T22:30:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b09392ac-a20b-4ab6-8271-2eda67850246',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fd74ee1a-6841-4105-bf78-bc160f2104f6', 'b09392ac-a20b-4ab6-8271-2eda67850246', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c0e65e14-e9f8-4d87-819a-37786b3c9347',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Glastonbury Celtic',
  NULL,
  '2025-10-19T22:30:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c0e65e14-e9f8-4d87-819a-37786b3c9347',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('def189cd-0656-433d-aaaf-92d6476625de', 'c0e65e14-e9f8-4d87-819a-37786b3c9347', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e257683f-bee6-49b7-883c-8ba755719abd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Hermandad Connecticut',
  NULL,
  '2025-10-26T16:30:00.000Z',
  'c756db72-4789-4a8a-8776-d596c6b66a3a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e257683f-bee6-49b7-883c-8ba755719abd',
  NULL,
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a3cfa391-6caa-4f63-85e6-b7f55f753609', 'e257683f-bee6-49b7-883c-8ba755719abd', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bf717ec4-11e7-40b6-81f8-1788c30f549e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs KO Elites',
  NULL,
  '2025-09-06T23:00:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bf717ec4-11e7-40b6-81f8-1788c30f549e',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d7a86c13-6806-4ca6-841f-6c477ebb38f0', 'bf717ec4-11e7-40b6-81f8-1788c30f549e', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2971250f-9d16-41b7-83d6-dffd12ec3b0a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Wildcat FC',
  NULL,
  '2025-09-14T22:30:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2971250f-9d16-41b7-83d6-dffd12ec3b0a',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('471b6e92-85aa-402e-8e03-ffd54944d20d', '2971250f-9d16-41b7-83d6-dffd12ec3b0a', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3aba5895-f105-4fbc-815a-ac7f47c76f9c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Glastonbury Celtic',
  NULL,
  '2025-09-20T23:00:00.000Z',
  '07f09e31-f50d-4429-8b40-581a0537ca2f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3aba5895-f105-4fbc-815a-ac7f47c76f9c',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9ebfd21a-d58d-43ff-b0dc-128fd2c10cd6', '3aba5895-f105-4fbc-815a-ac7f47c76f9c', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2f9e064b-4c75-4552-8ef7-3a3a5db190a2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Glastonbury Celtic',
  NULL,
  '2025-09-28T17:00:00.000Z',
  '77603323-802b-4a03-80d8-15778e540de8',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2f9e064b-4c75-4552-8ef7-3a3a5db190a2',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2a3bb500-acfe-4ef2-bdd0-4ae42afa47a0', '2f9e064b-4c75-4552-8ef7-3a3a5db190a2', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7355fc03-e3cb-45bd-80a8-fde40d88f0a2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs KO Elites',
  NULL,
  '2025-10-18T23:00:00.000Z',
  'cab7e0f5-4c7e-438d-89dd-312e3f88fd68',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7355fc03-e3cb-45bd-80a8-fde40d88f0a2',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4b66bcf7-e194-4a1b-b8c1-f731728f8def', '7355fc03-e3cb-45bd-80a8-fde40d88f0a2', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '444721d0-db3f-4ec8-838f-d8f448f1c4fa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Wildcat FC',
  NULL,
  '2025-10-26T16:30:00.000Z',
  'c756db72-4789-4a8a-8776-d596c6b66a3a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '444721d0-db3f-4ec8-838f-d8f448f1c4fa',
  NULL,
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('287bc402-385d-45aa-a681-8cc1b4fc05c4', '444721d0-db3f-4ec8-838f-d8f448f1c4fa', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '22902313-1b23-4a0d-85a9-38d963b24fdf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Doxa FCW',
  NULL,
  '2025-09-07T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '22902313-1b23-4a0d-85a9-38d963b24fdf',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d54ecadf-e8fe-4f28-b955-ac90c315e818', '22902313-1b23-4a0d-85a9-38d963b24fdf', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bf2ba0e1-54bc-46bd-8e38-a293524add85',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Richmond County FC',
  NULL,
  '2025-09-21T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bf2ba0e1-54bc-46bd-8e38-a293524add85',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9a0106cb-44cb-4c2e-9866-96e0ec38125b', 'bf2ba0e1-54bc-46bd-8e38-a293524add85', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9af809f3-8cb4-4235-873f-c1b2f6fd7a99',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs NY Pancyprian Freedoms',
  NULL,
  '2025-09-29T01:00:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9af809f3-8cb4-4235-873f-c1b2f6fd7a99',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8dde3299-663e-4714-acdd-9d2090108429', '9af809f3-8cb4-4235-873f-c1b2f6fd7a99', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '61df792f-a023-46ec-88f3-f427c3595c58',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Central Park Rangers FC',
  NULL,
  '2025-10-02T00:30:00.000Z',
  '4792d9ee-3862-4bfb-8035-166ccafe2ebb',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '61df792f-a023-46ec-88f3-f427c3595c58',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2c3d8d59-f878-41ee-83b8-1b9ae8346822', '61df792f-a023-46ec-88f3-f427c3595c58', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '770a13f1-15c6-4c84-81db-629343e1bd0d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Hoboken FC 1912',
  NULL,
  '2025-10-05T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '770a13f1-15c6-4c84-81db-629343e1bd0d',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d1b50db2-e561-4859-8217-10d05e7220ff', '770a13f1-15c6-4c84-81db-629343e1bd0d', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c379c330-ba1c-4357-8c64-62023ba2d2fb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Zum Schneider FC 03',
  NULL,
  '2025-10-24T00:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c379c330-ba1c-4357-8c64-62023ba2d2fb',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0eae19ec-5c60-412e-83ac-0e92c2a0f39a', 'c379c330-ba1c-4357-8c64-62023ba2d2fb', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f92d6fa5-dda1-4723-8622-2dab514ee440',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Leros SC',
  NULL,
  '2025-10-26T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f92d6fa5-dda1-4723-8622-2dab514ee440',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('320367db-23ff-4803-b203-f12c67bf402e', 'f92d6fa5-dda1-4723-8622-2dab514ee440', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '09c857eb-42d6-40bd-82f7-63418d3b685a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs SC Vistula Garfield',
  NULL,
  '2025-11-13T02:00:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '09c857eb-42d6-40bd-82f7-63418d3b685a',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ae0979e-358b-4766-9992-ffe88b709d17', '09c857eb-42d6-40bd-82f7-63418d3b685a', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e821e14e-41cc-4fe9-850a-b4a46a208d23',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Lansdowne Yonkers FC',
  NULL,
  '2025-11-16T00:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e821e14e-41cc-4fe9-850a-b4a46a208d23',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9894b0e7-a997-48dd-8c66-1178661b8202', 'e821e14e-41cc-4fe9-850a-b4a46a208d23', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'beba0dcf-183d-40b9-8ab9-f686ceef7017',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs NY International FC',
  NULL,
  '2025-11-23T19:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'beba0dcf-183d-40b9-8ab9-f686ceef7017',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e120297b-b3f7-4d69-8b4e-4660082fb285', 'beba0dcf-183d-40b9-8ab9-f686ceef7017', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4c7d9483-8519-4937-89ba-9abb354da2e8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs NY Athletic Club',
  NULL,
  '2026-01-11T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4c7d9483-8519-4937-89ba-9abb354da2e8',
  NULL,
  '05ec5303-e217-4602-8c03-06fb02c3c083',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c16100a2-17bb-4ffd-b077-a9bab9273e46', '4c7d9483-8519-4937-89ba-9abb354da2e8', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b853e310-9d5b-4af3-8820-2874065c8934',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Leros SC',
  NULL,
  '2025-09-07T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b853e310-9d5b-4af3-8820-2874065c8934',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('94973f68-70fa-4522-b330-c126cd1da070', 'b853e310-9d5b-4af3-8820-2874065c8934', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '223e44cc-0833-4a0e-80bf-e4ae5bcab2fe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Richmond County FC',
  NULL,
  '2025-09-15T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '223e44cc-0833-4a0e-80bf-e4ae5bcab2fe',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  8,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('74aa6d26-483f-4e41-8efd-c6cc86bd30a4', '223e44cc-0833-4a0e-80bf-e4ae5bcab2fe', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '524f20af-1e0a-4102-8013-11648e5fe96a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Zum Schneider FC 03',
  NULL,
  '2025-09-21T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '524f20af-1e0a-4102-8013-11648e5fe96a',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f890c115-e22c-4a2a-86be-e91a6a4c0a6c', '524f20af-1e0a-4102-8013-11648e5fe96a', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f8b0d394-472f-4268-8cd1-8adaebf85bb9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs NY Athletic Club',
  NULL,
  '2025-09-28T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f8b0d394-472f-4268-8cd1-8adaebf85bb9',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('53148480-531b-4686-b70a-217fc22a2467', 'f8b0d394-472f-4268-8cd1-8adaebf85bb9', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2b900d7c-d692-40d2-8f41-ba29829f0161',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs NY Greek Americans',
  NULL,
  '2025-10-05T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2b900d7c-d692-40d2-8f41-ba29829f0161',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c7780d87-c6c1-4e1b-b3ee-689fe3e3caa5', '2b900d7c-d692-40d2-8f41-ba29829f0161', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '01c83a39-2baf-4c92-8fb2-33ccd333a1e8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Central Park Rangers FC',
  NULL,
  '2025-10-24T01:00:00.000Z',
  '4792d9ee-3862-4bfb-8035-166ccafe2ebb',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '01c83a39-2baf-4c92-8fb2-33ccd333a1e8',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('47f7f8d3-7abd-410a-afeb-154212f59f8b', '01c83a39-2baf-4c92-8fb2-33ccd333a1e8', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '93b3465d-97e4-487c-898a-680a1fbe6586',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs NY International FC',
  NULL,
  '2025-10-26T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '93b3465d-97e4-487c-898a-680a1fbe6586',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3171b804-203b-4045-8bae-05edaa0e3000', '93b3465d-97e4-487c-898a-680a1fbe6586', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1b694658-0235-434a-80e9-c993a7e9d001',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Lansdowne Yonkers FC',
  NULL,
  '2025-11-07T01:45:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1b694658-0235-434a-80e9-c993a7e9d001',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('39af940e-3b9a-460a-811b-34a3f964b850', '1b694658-0235-434a-80e9-c993a7e9d001', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5e0f8e22-c56f-4d2b-8259-6ce23a40127c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs SC Vistula Garfield',
  NULL,
  '2025-11-20T01:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5e0f8e22-c56f-4d2b-8259-6ce23a40127c',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a84f845c-d320-4ef6-84fe-8e1e6a3cdaa7', '5e0f8e22-c56f-4d2b-8259-6ce23a40127c', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7fe14c5b-b005-43d3-8de7-946ab148eb6a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Doxa FCW',
  NULL,
  '2025-11-23T21:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7fe14c5b-b005-43d3-8de7-946ab148eb6a',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('310dbaff-7ed8-4e49-b7bd-ac85768aa9c5', '7fe14c5b-b005-43d3-8de7-946ab148eb6a', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ea337c0f-4571-4ba7-812f-c2ac917723af',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs NY Pancyprian Freedoms',
  NULL,
  '2025-12-14T21:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ea337c0f-4571-4ba7-812f-c2ac917723af',
  NULL,
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d4cf234c-b26a-4769-af6b-c54aebc5880d', 'ea337c0f-4571-4ba7-812f-c2ac917723af', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1411d826-dbec-4681-8a6e-108e9549402e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Zum Schneider FC 03',
  NULL,
  '2025-09-07T23:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1411d826-dbec-4681-8a6e-108e9549402e',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b4a4537f-e5b7-469c-ac15-dfde3fe38698', '1411d826-dbec-4681-8a6e-108e9549402e', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8fcb2850-9cf5-4729-85e3-1c85e82652fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Central Park Rangers FC',
  NULL,
  '2025-09-22T00:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8fcb2850-9cf5-4729-85e3-1c85e82652fc',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('81688731-4e85-4c3b-8b25-dd9d0e305c80', '8fcb2850-9cf5-4729-85e3-1c85e82652fc', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '53d6e723-3685-469d-8c33-61b2b2987089',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs NY Greek Americans',
  NULL,
  '2025-09-29T01:00:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '53d6e723-3685-469d-8c33-61b2b2987089',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('aeb7d179-0bcf-4d50-b98b-ce5187678214', '53d6e723-3685-469d-8c33-61b2b2987089', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7a3721d0-899f-4db5-8cf6-0d3428a0399a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs SC Vistula Garfield',
  NULL,
  '2025-10-02T00:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7a3721d0-899f-4db5-8cf6-0d3428a0399a',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1975a240-bc8d-41b3-8895-19aa46382697', '7a3721d0-899f-4db5-8cf6-0d3428a0399a', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '966aabe0-483f-471a-8682-bf7525c2966e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs NY International FC',
  NULL,
  '2025-10-05T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '966aabe0-483f-471a-8682-bf7525c2966e',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('441cb066-eae8-401b-a21c-ee3fc013c64f', '966aabe0-483f-471a-8682-bf7525c2966e', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cc9ad460-ab3c-4cef-8033-607572d140a2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Doxa FCW',
  NULL,
  '2025-10-23T00:00:00.000Z',
  '23941031-c1b7-4596-8673-117ed76efb4a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cc9ad460-ab3c-4cef-8033-607572d140a2',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c36b0a68-5fba-48c7-b56c-e45fdc3517bf', 'cc9ad460-ab3c-4cef-8033-607572d140a2', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6c7f83b2-5f5c-499f-8608-e92609f55b85',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Lansdowne Yonkers FC',
  NULL,
  '2025-10-26T22:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6c7f83b2-5f5c-499f-8608-e92609f55b85',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b4be8ab8-9450-4072-85f8-07fbf704ed84', '6c7f83b2-5f5c-499f-8608-e92609f55b85', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f132adc6-0434-44e8-8aa2-ea9a06f0f5fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Leros SC',
  NULL,
  '2025-11-02T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f132adc6-0434-44e8-8aa2-ea9a06f0f5fc',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('dc3d8e31-183a-4fc1-b611-f61b02ad0db2', 'f132adc6-0434-44e8-8aa2-ea9a06f0f5fc', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd8f082b9-8955-4efe-80ec-d917cd9c1790',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Richmond County FC',
  NULL,
  '2025-11-17T01:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd8f082b9-8955-4efe-80ec-d917cd9c1790',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f945fcb8-cdde-4595-81f3-6202a5ac4f4d', 'd8f082b9-8955-4efe-80ec-d917cd9c1790', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'be46bcc0-077e-42a3-8515-390fc052a298',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs NY Athletic Club',
  NULL,
  '2025-11-24T01:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'be46bcc0-077e-42a3-8515-390fc052a298',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('836f41a1-e14f-47bf-be3e-ca14dbc00cd1', 'be46bcc0-077e-42a3-8515-390fc052a298', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9c095888-fb6b-425b-85b9-1c67b7ec1d16',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Hoboken FC 1912',
  NULL,
  '2025-12-14T21:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9c095888-fb6b-425b-85b9-1c67b7ec1d16',
  NULL,
  '998d8d80-fabe-4b10-83f5-6ad236885249',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2043f563-0971-4f2f-b29a-1b955cc9e29f', '9c095888-fb6b-425b-85b9-1c67b7ec1d16', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0e1d399c-64bf-4fae-844a-e56fe549c30e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY Athletic Club',
  NULL,
  '2025-09-06T22:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0e1d399c-64bf-4fae-844a-e56fe549c30e',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('900da240-ed61-4b5d-bddd-7aefbfa37ba4', '0e1d399c-64bf-4fae-844a-e56fe549c30e', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a6992975-2640-4279-81ed-1c01e92abd34',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Leros SC',
  NULL,
  '2025-09-20T23:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a6992975-2640-4279-81ed-1c01e92abd34',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1b11ceff-765c-4d45-a8db-135755e67e37', 'a6992975-2640-4279-81ed-1c01e92abd34', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cd98987f-9199-4b12-8648-c42b89ab0f76',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Doxa FCW',
  NULL,
  '2025-09-26T00:30:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cd98987f-9199-4b12-8648-c42b89ab0f76',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c6747051-f0fd-4cd6-9c15-c8b5fab344e8', 'cd98987f-9199-4b12-8648-c42b89ab0f76', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ee3d020e-e50d-406b-8870-8684789ab5ff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Central Park Rangers FC',
  NULL,
  '2025-09-28T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ee3d020e-e50d-406b-8870-8684789ab5ff',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('baf403d9-5f72-4b4b-a2ad-011f32df867b', 'ee3d020e-e50d-406b-8870-8684789ab5ff', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '13536e07-0eaa-45be-83a3-5b33e97491c2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Richmond County FC',
  NULL,
  '2025-10-06T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '13536e07-0eaa-45be-83a3-5b33e97491c2',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fb43b2f5-94a2-4b3a-85d8-0a4b7d1b0770', '13536e07-0eaa-45be-83a3-5b33e97491c2', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c1a8c8d6-66f7-447a-8a66-d1268e0b2f31',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY International FC',
  NULL,
  '2025-10-15T00:30:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c1a8c8d6-66f7-447a-8a66-d1268e0b2f31',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e9b49d0e-dfc5-4acd-8450-af7b29c0deb5', 'c1a8c8d6-66f7-447a-8a66-d1268e0b2f31', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '00815dbf-c586-41c0-8bb8-766e96fbd77f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY Pancyprian Freedoms',
  NULL,
  '2025-10-26T22:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '00815dbf-c586-41c0-8bb8-766e96fbd77f',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('71fc0cfe-76f4-4c75-8bb9-6f0c8f5ac2ad', '00815dbf-c586-41c0-8bb8-766e96fbd77f', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ae61ff0b-ac40-4fb1-81d6-6e3acdd6aa14',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Hoboken FC 1912',
  NULL,
  '2025-11-07T01:45:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ae61ff0b-ac40-4fb1-81d6-6e3acdd6aa14',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bccf0798-e575-41f8-9c3f-9d3d144d213f', 'ae61ff0b-ac40-4fb1-81d6-6e3acdd6aa14', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '999ef2b2-ce9b-43a1-8063-880670f632ff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY Greek Americans',
  NULL,
  '2025-11-16T00:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '999ef2b2-ce9b-43a1-8063-880670f632ff',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3c6d999e-5a41-46a8-b409-5da4f91833b9', '999ef2b2-ce9b-43a1-8063-880670f632ff', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '97c68150-5ed3-46f3-8c83-cbe80667bbce',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs SC Vistula Garfield',
  NULL,
  '2025-12-10T01:00:00.000Z',
  '35fa9928-ff8c-4c2b-8b46-071424c0362c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '97c68150-5ed3-46f3-8c83-cbe80667bbce',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f952ac51-80da-4d7e-b969-30838e7bb251', '97c68150-5ed3-46f3-8c83-cbe80667bbce', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f789350c-17b8-49e5-81ae-71ea516428fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Zum Schneider FC 03',
  NULL,
  '2025-12-15T00:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f789350c-17b8-49e5-81ae-71ea516428fc',
  NULL,
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c677d987-bb1b-4e1d-9318-2d83f0832e73', 'f789350c-17b8-49e5-81ae-71ea516428fc', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1a5b4f4c-72ef-475a-8007-df817fc4e553',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs NY Greek Americans',
  NULL,
  '2025-09-07T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1a5b4f4c-72ef-475a-8007-df817fc4e553',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2c43f0ca-18bc-46f5-9334-9b1da27c2ea0', '1a5b4f4c-72ef-475a-8007-df817fc4e553', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ce65e7fd-173a-426c-8d6f-ceee7899ffc5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs NY International FC',
  NULL,
  '2025-09-21T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ce65e7fd-173a-426c-8d6f-ceee7899ffc5',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('47579234-1f70-4078-8370-63af44552291', 'ce65e7fd-173a-426c-8d6f-ceee7899ffc5', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '51d810b3-89b2-46f4-8b72-3bc861eebaaf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Lansdowne Yonkers FC',
  NULL,
  '2025-09-26T00:30:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '51d810b3-89b2-46f4-8b72-3bc861eebaaf',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26656266-deed-479c-8db2-8767f793bee7', '51d810b3-89b2-46f4-8b72-3bc861eebaaf', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'dfb90bbe-1520-4c2a-8457-51e94fef5404',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Richmond County FC',
  NULL,
  '2025-09-29T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'dfb90bbe-1520-4c2a-8457-51e94fef5404',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('32a1fba5-fa20-4deb-b4cc-bf931ac06dce', 'dfb90bbe-1520-4c2a-8457-51e94fef5404', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '20c97885-8d40-406c-89e7-4f767bfc03c7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs NY Athletic Club',
  NULL,
  '2025-10-06T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '20c97885-8d40-406c-89e7-4f767bfc03c7',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7327752c-e7f9-40f9-a883-89367cd6edda', '20c97885-8d40-406c-89e7-4f767bfc03c7', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1c874b2c-fe54-436b-8e32-892e79efe585',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs NY Pancyprian Freedoms',
  NULL,
  '2025-10-23T00:00:00.000Z',
  '23941031-c1b7-4596-8673-117ed76efb4a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1c874b2c-fe54-436b-8e32-892e79efe585',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('784497bd-402b-467c-95d2-db0cf9fef40e', '1c874b2c-fe54-436b-8e32-892e79efe585', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '20552c62-d1a5-4a5c-8dab-f368cb355204',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Zum Schneider FC 03',
  NULL,
  '2025-10-27T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '20552c62-d1a5-4a5c-8dab-f368cb355204',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b7d5615e-1ca2-4741-b8a3-c9fa9efffab7', '20552c62-d1a5-4a5c-8dab-f368cb355204', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0fce3e01-f29b-4375-8d18-1cf9e288e824',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Central Park Rangers FC',
  NULL,
  '2025-11-02T21:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0fce3e01-f29b-4375-8d18-1cf9e288e824',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bd785ad6-4a97-4c5a-9c7b-0d01c37b31fb', '0fce3e01-f29b-4375-8d18-1cf9e288e824', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c2e6ed23-fc42-4af6-859b-bcf2449d87c6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Leros SC',
  NULL,
  '2025-11-17T01:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c2e6ed23-fc42-4af6-859b-bcf2449d87c6',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9a4b9ed1-0b93-4030-b8fe-e2da70bb1c2c', 'c2e6ed23-fc42-4af6-859b-bcf2449d87c6', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9facfea4-c369-404b-8767-4b1316ce5588',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Hoboken FC 1912',
  NULL,
  '2025-11-23T21:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9facfea4-c369-404b-8767-4b1316ce5588',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c2f48e70-ab7d-4f8e-a9da-117bc5154ae1', '9facfea4-c369-404b-8767-4b1316ce5588', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '70131a82-bfa5-4ebd-82d2-a3b1fed7ff2a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs SC Vistula Garfield',
  NULL,
  '2025-12-13T23:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '70131a82-bfa5-4ebd-82d2-a3b1fed7ff2a',
  NULL,
  'b59f4742-28b4-46db-8a70-f819f7935278',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2cdb3f4b-696f-4f1d-b954-d27773248483', '70131a82-bfa5-4ebd-82d2-a3b1fed7ff2a', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65257a25-5438-4952-8f76-ea3226919766',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Hoboken FC 1912',
  NULL,
  '2025-09-07T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65257a25-5438-4952-8f76-ea3226919766',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a49b7fac-2269-439c-9a94-18d2f7f8e1d8', '65257a25-5438-4952-8f76-ea3226919766', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2af8713a-b460-401a-80c6-9d72aa9f1db7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY Athletic Club',
  NULL,
  '2025-09-14T22:00:00.000Z',
  'adfd29a0-dd49-443a-86e6-7a585239d1b5',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2af8713a-b460-401a-80c6-9d72aa9f1db7',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('557788f3-8f3d-4cbf-86df-ac34bb75f8d2', '2af8713a-b460-401a-80c6-9d72aa9f1db7', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4be4b1a9-054f-4024-8994-9b61af812893',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Lansdowne Yonkers FC',
  NULL,
  '2025-09-20T23:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4be4b1a9-054f-4024-8994-9b61af812893',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('93927169-cab1-46a3-8e1b-c5cf085200f4', '4be4b1a9-054f-4024-8994-9b61af812893', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'af5c501a-19ec-4de0-8a77-3e8426df003a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY International FC',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'af5c501a-19ec-4de0-8a77-3e8426df003a',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5e1795ea-0bba-4d6b-b5bb-19cf0c948f39', 'af5c501a-19ec-4de0-8a77-3e8426df003a', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '68d843a4-aa7b-4885-833c-15fc7a19976e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Zum Schneider FC 03',
  NULL,
  '2025-10-05T22:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '68d843a4-aa7b-4885-833c-15fc7a19976e',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4b773de3-926e-4bff-9bc6-1453526e31d7', '68d843a4-aa7b-4885-833c-15fc7a19976e', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9ca30953-b7dd-4747-8b89-86dcd9f235e1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY Greek Americans',
  NULL,
  '2025-10-26T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9ca30953-b7dd-4747-8b89-86dcd9f235e1',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('76592b70-f566-453c-9e62-924e46b992e4', '9ca30953-b7dd-4747-8b89-86dcd9f235e1', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '024e0a05-0abc-439f-8f8a-7b67ae6a27d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs SC Vistula Garfield',
  NULL,
  '2025-10-31T00:15:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '024e0a05-0abc-439f-8f8a-7b67ae6a27d5',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ae6a0af5-758f-4b54-9fb0-ee57c9fea7dd', '024e0a05-0abc-439f-8f8a-7b67ae6a27d5', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fa570d75-d29f-468f-83d2-77816ac76883',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY Pancyprian Freedoms',
  NULL,
  '2025-11-02T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fa570d75-d29f-468f-83d2-77816ac76883',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('33ac5390-7abd-46e8-ab2a-a0c4f18eb1ab', 'fa570d75-d29f-468f-83d2-77816ac76883', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '72c87dff-ac2b-47b8-8db2-37661280b42d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Doxa FCW',
  NULL,
  '2025-11-17T01:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '72c87dff-ac2b-47b8-8db2-37661280b42d',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9f8f28e7-f3fd-4cfe-9d07-118663c54058', '72c87dff-ac2b-47b8-8db2-37661280b42d', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '71bcb289-8602-457c-866c-07ae89e3fbaa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Richmond County FC',
  NULL,
  '2025-11-23T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '71bcb289-8602-457c-866c-07ae89e3fbaa',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6d325a42-4603-4620-9ed7-3fbfa12fd9fa', '71bcb289-8602-457c-866c-07ae89e3fbaa', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5e8f3c17-a12a-4221-8563-15efa2871301',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Central Park Rangers FC',
  NULL,
  '2026-01-11T19:00:00.000Z',
  'e12084fc-a5ac-492a-85bb-ff8697bea483',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5e8f3c17-a12a-4221-8563-15efa2871301',
  NULL,
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8ae44d14-df12-406d-b36f-7b0d026a66e5', '5e8f3c17-a12a-4221-8563-15efa2871301', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4399c9b1-fe11-4e11-89c4-dea00ce50e15',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs SC Vistula Garfield',
  NULL,
  '2025-09-07T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4399c9b1-fe11-4e11-89c4-dea00ce50e15',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3ecd9d62-3a48-488a-884a-8adf4fc35be1', '4399c9b1-fe11-4e11-89c4-dea00ce50e15', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '953f59aa-23cb-4382-8730-d39a2a3bca1d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Zum Schneider FC 03',
  NULL,
  '2025-09-14T23:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '953f59aa-23cb-4382-8730-d39a2a3bca1d',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6b6c6c3e-962d-4fe6-9a7e-6b1dc373c9ef', '953f59aa-23cb-4382-8730-d39a2a3bca1d', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '00c75a41-b05b-4acf-8302-2b6356ebee76',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Doxa FCW',
  NULL,
  '2025-09-21T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '00c75a41-b05b-4acf-8302-2b6356ebee76',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('eb1477b2-8892-4bb1-ad41-944bf3960aef', '00c75a41-b05b-4acf-8302-2b6356ebee76', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3ff42d46-9d99-4080-82d9-646bfb891468',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Leros SC',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3ff42d46-9d99-4080-82d9-646bfb891468',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('adbe2763-cef2-4fd3-ab2f-7444c6440d92', '3ff42d46-9d99-4080-82d9-646bfb891468', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'dd3df2f8-afae-4d2b-80c7-453e802fd477',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs NY Pancyprian Freedoms',
  NULL,
  '2025-10-05T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'dd3df2f8-afae-4d2b-80c7-453e802fd477',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('aa3f58a2-6673-4283-aeea-80299427621e', 'dd3df2f8-afae-4d2b-80c7-453e802fd477', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '193601e0-1f17-4c06-8cf3-7db5294414d4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Lansdowne Yonkers FC',
  NULL,
  '2025-10-15T00:30:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '193601e0-1f17-4c06-8cf3-7db5294414d4',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('23762c99-258f-4a3b-a410-a9af80a3a0e4', '193601e0-1f17-4c06-8cf3-7db5294414d4', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '323ef57e-fee9-4ae3-823f-84cf0be5a07a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Hoboken FC 1912',
  NULL,
  '2025-10-26T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '323ef57e-fee9-4ae3-823f-84cf0be5a07a',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('04961ca3-aba9-4862-8fa8-53f74b65918d', '323ef57e-fee9-4ae3-823f-84cf0be5a07a', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3ff420c7-fce4-428f-88b0-e6422df8a549',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs NY Athletic Club',
  NULL,
  '2025-11-02T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3ff420c7-fce4-428f-88b0-e6422df8a549',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('620a05ea-8b9d-4605-9e81-4ed584c1f20d', '3ff420c7-fce4-428f-88b0-e6422df8a549', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9233de23-f36f-47f4-81b7-cae8045b283c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Central Park Rangers FC',
  NULL,
  '2025-11-16T21:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9233de23-f36f-47f4-81b7-cae8045b283c',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('56ed5575-24cd-42c9-97cb-ad0ab4ceb233', '9233de23-f36f-47f4-81b7-cae8045b283c', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4cd4fe33-797e-4f9b-8d4d-fbbaa95f129b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs NY Greek Americans',
  NULL,
  '2025-11-23T19:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4cd4fe33-797e-4f9b-8d4d-fbbaa95f129b',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e6f023cb-cfd6-4d06-a942-8828261d4411', '4cd4fe33-797e-4f9b-8d4d-fbbaa95f129b', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1a25e8d0-dadf-4887-8218-70423e987a49',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Richmond County FC',
  NULL,
  '2026-01-11T18:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1a25e8d0-dadf-4887-8218-70423e987a49',
  NULL,
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('405234cd-8eb4-4fea-b6b7-987466313d7f', '1a25e8d0-dadf-4887-8218-70423e987a49', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bfdc3ce6-3441-488c-8d2f-b4fa5e184de8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Central Park Rangers FC',
  NULL,
  '2025-09-08T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bfdc3ce6-3441-488c-8d2f-b4fa5e184de8',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c98fa20f-c81b-4df1-9049-48a7ebcb91ca', 'bfdc3ce6-3441-488c-8d2f-b4fa5e184de8', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1ac99156-3e08-41ce-8725-d857bfc1ff59',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Hoboken FC 1912',
  NULL,
  '2025-09-15T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1ac99156-3e08-41ce-8725-d857bfc1ff59',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  8,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b356059b-9794-4594-8d5c-dae62558b6d6', '1ac99156-3e08-41ce-8725-d857bfc1ff59', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ee899840-4161-4243-8eba-bc005b88a516',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY Greek Americans',
  NULL,
  '2025-09-21T23:30:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ee899840-4161-4243-8eba-bc005b88a516',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0e50d729-e9ae-4ec9-952c-b5bb45b5b411', 'ee899840-4161-4243-8eba-bc005b88a516', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '29ed5a5a-25ec-465e-8b1a-23355ad08d8b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Doxa FCW',
  NULL,
  '2025-09-29T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '29ed5a5a-25ec-465e-8b1a-23355ad08d8b',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('268a6969-72e1-4c63-b986-2e6ee61f1270', '29ed5a5a-25ec-465e-8b1a-23355ad08d8b', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fa051061-6609-4b56-893d-a4637874ec60',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Lansdowne Yonkers FC',
  NULL,
  '2025-10-06T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fa051061-6609-4b56-893d-a4637874ec60',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('20d76a6c-918c-4d71-893f-ce09d73ac3b8', 'fa051061-6609-4b56-893d-a4637874ec60', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '569aadc4-f7aa-4e83-82c3-0f7fd6aac21c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY Athletic Club',
  NULL,
  '2025-10-13T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '569aadc4-f7aa-4e83-82c3-0f7fd6aac21c',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c4dd1b9e-5f21-4701-8bac-1a631cccccdd', '569aadc4-f7aa-4e83-82c3-0f7fd6aac21c', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'df34f881-8e9f-4094-8645-67c79cce6d26',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs SC Vistula Garfield',
  NULL,
  '2025-10-27T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'df34f881-8e9f-4094-8645-67c79cce6d26',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('58efa9d5-0afb-4f28-b6d0-01156db68ffe', 'df34f881-8e9f-4094-8645-67c79cce6d26', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '00a1fcb6-e405-4475-83b7-9faa124314fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY Pancyprian Freedoms',
  NULL,
  '2025-11-17T01:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '00a1fcb6-e405-4475-83b7-9faa124314fc',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ab5e7fdc-216f-4120-93ed-82029154111b', '00a1fcb6-e405-4475-83b7-9faa124314fc', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '87f4055c-2e72-429e-8d11-3d77c36e0bc5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Zum Schneider FC 03',
  NULL,
  '2025-11-21T01:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '87f4055c-2e72-429e-8d11-3d77c36e0bc5',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ac378b1-2e64-4cbc-82c5-0569ca336d6e', '87f4055c-2e72-429e-8d11-3d77c36e0bc5', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '75556b19-d978-4562-8779-7a9742dea888',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Leros SC',
  NULL,
  '2025-11-23T23:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '75556b19-d978-4562-8779-7a9742dea888',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('848964b7-eb88-4f1a-b3ae-1c3b93a7d7ce', '75556b19-d978-4562-8779-7a9742dea888', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a5b0faa6-2bd4-40ac-825a-3d22a4d4c84f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY International FC',
  NULL,
  '2026-01-11T18:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a5b0faa6-2bd4-40ac-825a-3d22a4d4c84f',
  NULL,
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2c3d3fe1-6fbd-4f1a-b2ef-b89894c5b578', 'a5b0faa6-2bd4-40ac-825a-3d22a4d4c84f', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3a8b507b-7cc0-4837-8ec5-6cffef98ffc6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY Pancyprian Freedoms',
  NULL,
  '2025-09-07T23:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3a8b507b-7cc0-4837-8ec5-6cffef98ffc6',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('afe62203-f3f1-4d48-9837-2f609e041eaa', '3a8b507b-7cc0-4837-8ec5-6cffef98ffc6', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e3fa4e58-3fe9-4603-856e-aab8d88cac2f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY International FC',
  NULL,
  '2025-09-14T23:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e3fa4e58-3fe9-4603-856e-aab8d88cac2f',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('74810ea4-dae0-4898-b0a9-d96faf4fe056', 'e3fa4e58-3fe9-4603-856e-aab8d88cac2f', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6e5f8bc6-d54c-4f70-87a1-f9f46253f09e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Hoboken FC 1912',
  NULL,
  '2025-09-21T20:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6e5f8bc6-d54c-4f70-87a1-f9f46253f09e',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('349316a1-f14f-4be1-bac4-3b228b933856', '6e5f8bc6-d54c-4f70-87a1-f9f46253f09e', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '169ba4a8-8738-4f3f-89c1-49746904e11a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs SC Vistula Garfield',
  NULL,
  '2025-09-27T22:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '169ba4a8-8738-4f3f-89c1-49746904e11a',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3a4d8bb2-d482-48c2-8414-ccb36cfe6b68', '169ba4a8-8738-4f3f-89c1-49746904e11a', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3846b9e6-3246-480c-8b09-3d274f3a32d7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Leros SC',
  NULL,
  '2025-10-05T22:00:00.000Z',
  '61f223f0-47c7-44bc-843b-78253c7676d2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3846b9e6-3246-480c-8b09-3d274f3a32d7',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('95c1bdd4-4f63-4329-8df4-aa1f8f6df999', '3846b9e6-3246-480c-8b09-3d274f3a32d7', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8b171446-ea15-4bc9-8fdf-854026b46913',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY Greek Americans',
  NULL,
  '2025-10-24T00:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8b171446-ea15-4bc9-8fdf-854026b46913',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('86076161-d628-466b-9606-a5dfa93dc8ad', '8b171446-ea15-4bc9-8fdf-854026b46913', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1d368b30-4bd3-449c-8ed2-e3e19300592d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Doxa FCW',
  NULL,
  '2025-10-27T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1d368b30-4bd3-449c-8ed2-e3e19300592d',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('73f1fa34-cefb-4063-b225-639c2565965c', '1d368b30-4bd3-449c-8ed2-e3e19300592d', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '361d2ac0-f61b-4fa2-8529-45c08d85f694',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY Athletic Club',
  NULL,
  '2025-11-16T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '361d2ac0-f61b-4fa2-8529-45c08d85f694',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('88a37f9d-b2df-45aa-acc7-dc580c5601f3', '361d2ac0-f61b-4fa2-8529-45c08d85f694', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ea986a0e-3221-4a45-847c-e86fc4d73a8e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Richmond County FC',
  NULL,
  '2025-11-21T01:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ea986a0e-3221-4a45-847c-e86fc4d73a8e',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f67cd1f7-de7e-4320-8789-de1d4971c274', 'ea986a0e-3221-4a45-847c-e86fc4d73a8e', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7e414a7a-9253-4b3d-867d-ff2eba115bd5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Central Park Rangers FC',
  NULL,
  '2025-12-08T00:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7e414a7a-9253-4b3d-867d-ff2eba115bd5',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1f012632-c1e2-4589-b27c-c59bfaf8c44e', '7e414a7a-9253-4b3d-867d-ff2eba115bd5', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '50b9ce91-ad0f-46aa-8c8c-3a6444149e6c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Lansdowne Yonkers FC',
  NULL,
  '2025-12-15T00:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '50b9ce91-ad0f-46aa-8c8c-3a6444149e6c',
  NULL,
  '5b5c9fa8-a519-4711-8638-247856aa639f',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('446f7ba7-004c-49bb-9582-aff82e569d70', '50b9ce91-ad0f-46aa-8c8c-3a6444149e6c', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65a4cb58-8d75-422c-811e-d255419e1815',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Richmond County FC',
  NULL,
  '2025-09-08T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65a4cb58-8d75-422c-811e-d255419e1815',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8dec5455-f6d1-4f76-b4b8-3a8d42c20dd3', '65a4cb58-8d75-422c-811e-d255419e1815', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6e06e8c4-8862-420a-85ee-044316743d60',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY Pancyprian Freedoms',
  NULL,
  '2025-09-22T00:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6e06e8c4-8862-420a-85ee-044316743d60',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7cefb046-f211-40fa-97b4-56f5b71d602c', '6e06e8c4-8862-420a-85ee-044316743d60', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bf60af4b-18b5-4344-8961-c9676dd39e3d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Lansdowne Yonkers FC',
  NULL,
  '2025-09-28T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bf60af4b-18b5-4344-8961-c9676dd39e3d',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5388c0f6-2779-41d8-be28-d28d26074dcb', 'bf60af4b-18b5-4344-8961-c9676dd39e3d', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '47f0e427-69c2-4fce-8c30-0df21e67f5ce',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY Greek Americans',
  NULL,
  '2025-10-02T00:30:00.000Z',
  '4792d9ee-3862-4bfb-8035-166ccafe2ebb',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '47f0e427-69c2-4fce-8c30-0df21e67f5ce',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8c77b20d-7904-409d-93a2-5b09cb0ad712', '47f0e427-69c2-4fce-8c30-0df21e67f5ce', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8f1561cc-73c0-4907-8f43-71481b8d61d4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Hoboken FC 1912',
  NULL,
  '2025-10-24T01:00:00.000Z',
  '4792d9ee-3862-4bfb-8035-166ccafe2ebb',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8f1561cc-73c0-4907-8f43-71481b8d61d4',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ed5f7cf-6ee2-406f-8335-9e1b916b2b43', '8f1561cc-73c0-4907-8f43-71481b8d61d4', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6b58546b-ec69-43ed-80d7-7869e9dcfd13',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY Athletic Club',
  NULL,
  '2025-10-26T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6b58546b-ec69-43ed-80d7-7869e9dcfd13',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2a6337f1-0b84-47c6-a4e9-aad0988fe3c6', '6b58546b-ec69-43ed-80d7-7869e9dcfd13', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1adb0e49-62c4-42f9-8f36-e2170cb1d6dd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Doxa FCW',
  NULL,
  '2025-11-02T21:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1adb0e49-62c4-42f9-8f36-e2170cb1d6dd',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f6342f72-4e43-472a-a5ab-8983d5662d3f', '1adb0e49-62c4-42f9-8f36-e2170cb1d6dd', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '784cd6a5-ea49-4961-82e7-62dea15501dc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs SC Vistula Garfield',
  NULL,
  '2025-11-10T00:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '784cd6a5-ea49-4961-82e7-62dea15501dc',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('32c7d1f7-610a-415b-b285-4b0537fa8104', '784cd6a5-ea49-4961-82e7-62dea15501dc', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bb34abd0-6580-4afc-8af7-c6f6ac0575f4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY International FC',
  NULL,
  '2025-11-16T21:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bb34abd0-6580-4afc-8af7-c6f6ac0575f4',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bc998089-03a1-459f-8716-d5ea78e99dc7', 'bb34abd0-6580-4afc-8af7-c6f6ac0575f4', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ec59a7d0-2729-4303-82f1-3b67ded1fb45',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Zum Schneider FC 03',
  NULL,
  '2025-12-08T00:30:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ec59a7d0-2729-4303-82f1-3b67ded1fb45',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6b3730ed-c69b-44d2-8944-2767d9ac20b2', 'ec59a7d0-2729-4303-82f1-3b67ded1fb45', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ff64d119-6872-46f4-81c7-655d979feaf3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Leros SC',
  NULL,
  '2026-01-11T19:00:00.000Z',
  'e12084fc-a5ac-492a-85bb-ff8697bea483',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ff64d119-6872-46f4-81c7-655d979feaf3',
  NULL,
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('344364cc-dd7d-431c-be44-6222ffec295b', 'ff64d119-6872-46f4-81c7-655d979feaf3', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1a2db9e0-cc7a-43b5-847d-4f77669b495c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs NY International FC',
  NULL,
  '2025-09-07T20:00:00.000Z',
  'e20e49ec-2347-4906-868c-1354616529ed',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1a2db9e0-cc7a-43b5-847d-4f77669b495c',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d6c1b885-2f25-4e4a-ba51-43c882ff9d13', '1a2db9e0-cc7a-43b5-847d-4f77669b495c', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '580706a3-4a36-4715-8a1a-431fb3ab7d72',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs NY Athletic Club',
  NULL,
  '2025-09-21T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '580706a3-4a36-4715-8a1a-431fb3ab7d72',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d4d35054-fe6c-4dc9-9c26-727d9ceecc88', '580706a3-4a36-4715-8a1a-431fb3ab7d72', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd7da22e0-2879-4085-8d04-c202ab727d22',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Zum Schneider FC 03',
  NULL,
  '2025-09-27T22:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd7da22e0-2879-4085-8d04-c202ab727d22',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e3602caf-6684-4b22-afb9-4f923dd7d86e', 'd7da22e0-2879-4085-8d04-c202ab727d22', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7200f69e-cd9f-4781-8a7e-e1bb3b66f387',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs NY Pancyprian Freedoms',
  NULL,
  '2025-10-02T00:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7200f69e-cd9f-4781-8a7e-e1bb3b66f387',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4971258e-2088-4a52-93ba-bc9d97c9f3c9', '7200f69e-cd9f-4781-8a7e-e1bb3b66f387', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'aacfde2b-61e4-4807-8a34-464a39b6ca86',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Richmond County FC',
  NULL,
  '2025-10-27T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'aacfde2b-61e4-4807-8a34-464a39b6ca86',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5fc90cb2-dae2-4111-be96-7606baab4bfa', 'aacfde2b-61e4-4807-8a34-464a39b6ca86', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '38fd74cc-1e0a-4130-8551-08c1c0993c08',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Leros SC',
  NULL,
  '2025-10-31T00:15:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '38fd74cc-1e0a-4130-8551-08c1c0993c08',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c00332a1-b74d-4bee-a1ec-0e15f3231aa1', '38fd74cc-1e0a-4130-8551-08c1c0993c08', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b4450567-89f2-4dc9-8111-1de2443e49d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Central Park Rangers FC',
  NULL,
  '2025-11-10T00:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b4450567-89f2-4dc9-8111-1de2443e49d5',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bb7111b6-0250-4156-99e4-42f9a2bada01', 'b4450567-89f2-4dc9-8111-1de2443e49d5', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '71601a04-da5f-4885-8fa5-9d1ac1fecb38',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs NY Greek Americans',
  NULL,
  '2025-11-13T02:00:00.000Z',
  'c902809d-fb2c-4942-8851-32ad3cd55bfc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '71601a04-da5f-4885-8fa5-9d1ac1fecb38',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('533d21a6-096d-4132-a6b5-47be829ad212', '71601a04-da5f-4885-8fa5-9d1ac1fecb38', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ac439fde-1c04-4538-83be-f66b6dd9c0d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Hoboken FC 1912',
  NULL,
  '2025-11-20T01:00:00.000Z',
  'f7c48038-7e48-4062-891e-86ca38660158',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ac439fde-1c04-4538-83be-f66b6dd9c0d0',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('46a35ff5-ee95-4626-ab57-6bf2bcbc7945', 'ac439fde-1c04-4538-83be-f66b6dd9c0d0', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f283b3d9-97ea-4fa0-800f-34b5448b0e17',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Lansdowne Yonkers FC',
  NULL,
  '2025-12-10T01:00:00.000Z',
  '35fa9928-ff8c-4c2b-8b46-071424c0362c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f283b3d9-97ea-4fa0-800f-34b5448b0e17',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2cfaefff-0b9c-4b4b-9240-b7ce3b929248', 'f283b3d9-97ea-4fa0-800f-34b5448b0e17', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '28137129-7505-4522-894d-25e8b4629299',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Doxa FCW',
  NULL,
  '2025-12-13T23:00:00.000Z',
  '5043dd1f-768a-4c09-84c7-18321792d602',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '28137129-7505-4522-894d-25e8b4629299',
  NULL,
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d31c4ef6-45ce-490e-a2f1-9bd711024314', '28137129-7505-4522-894d-25e8b4629299', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5764f5f3-8f57-48ea-870b-f4524b4fe539',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Lansdowne Yonkers FC',
  NULL,
  '2025-09-06T22:00:00.000Z',
  '0f67db32-8209-41f0-89d3-60da8bd4dd2d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5764f5f3-8f57-48ea-870b-f4524b4fe539',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f80b4f4d-0e8c-4a72-a5b4-c725579c004e', '5764f5f3-8f57-48ea-870b-f4524b4fe539', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9d59439d-52f7-4bac-8a80-3e5b59df9c52',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Leros SC',
  NULL,
  '2025-09-14T22:00:00.000Z',
  'adfd29a0-dd49-443a-86e6-7a585239d1b5',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9d59439d-52f7-4bac-8a80-3e5b59df9c52',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('09cfcf12-46b1-4821-81b8-b25110075a9a', '9d59439d-52f7-4bac-8a80-3e5b59df9c52', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ffb1d360-ce84-4a56-871c-3af1e55c1053',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs SC Vistula Garfield',
  NULL,
  '2025-09-21T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ffb1d360-ce84-4a56-871c-3af1e55c1053',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('68ebd679-f27e-4fed-8c99-2d5dc07f8815', 'ffb1d360-ce84-4a56-871c-3af1e55c1053', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a678bc70-c525-4b4f-8917-2cac9d3f4367',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Hoboken FC 1912',
  NULL,
  '2025-09-28T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a678bc70-c525-4b4f-8917-2cac9d3f4367',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6b0f4a8a-3b4a-4cbb-9568-ccf7e26c84df', 'a678bc70-c525-4b4f-8917-2cac9d3f4367', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a1f14465-7c3c-4985-88bf-09eb55092fe6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Doxa FCW',
  NULL,
  '2025-10-06T00:00:00.000Z',
  'f88e0821-6caf-4cf9-8f82-cd7d133c64a7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a1f14465-7c3c-4985-88bf-09eb55092fe6',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ec0e9486-4b50-4ca1-8176-929a2f8609a3', 'a1f14465-7c3c-4985-88bf-09eb55092fe6', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fa5ac455-a2ec-4a25-87fa-67235a2c83e3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Richmond County FC',
  NULL,
  '2025-10-13T00:00:00.000Z',
  '84d89876-f08a-4eef-851a-de3a03516466',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fa5ac455-a2ec-4a25-87fa-67235a2c83e3',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4804c173-3472-4fd5-8f3c-3b3291b9b847', 'fa5ac455-a2ec-4a25-87fa-67235a2c83e3', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '17a23a8b-88ed-4824-87e2-08c9c7706eda',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Central Park Rangers FC',
  NULL,
  '2025-10-26T16:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '17a23a8b-88ed-4824-87e2-08c9c7706eda',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('99a6f0f9-6aec-4028-99f1-e29443191819', '17a23a8b-88ed-4824-87e2-08c9c7706eda', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8f99c913-9369-4ca6-820b-eade1e25677b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs NY International FC',
  NULL,
  '2025-11-02T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8f99c913-9369-4ca6-820b-eade1e25677b',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('22e9db9b-77b2-453d-b0df-55370ac562dd', '8f99c913-9369-4ca6-820b-eade1e25677b', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c644a24d-a035-46aa-87bc-ee29acff6d2d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Zum Schneider FC 03',
  NULL,
  '2025-11-16T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c644a24d-a035-46aa-87bc-ee29acff6d2d',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b37dd62b-7e20-4e65-9ca7-fa34136c6b4a', 'c644a24d-a035-46aa-87bc-ee29acff6d2d', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2c96ae4d-4fac-41b2-87b0-4fa86221f220',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs NY Pancyprian Freedoms',
  NULL,
  '2025-11-24T01:00:00.000Z',
  'f1a5c7d8-03b6-4306-8e69-4e30d2eefd88',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2c96ae4d-4fac-41b2-87b0-4fa86221f220',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('af3dcd86-7326-4253-9f56-ae35978dcee9', '2c96ae4d-4fac-41b2-87b0-4fa86221f220', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bfce5b73-66f5-4d76-8fbf-659f3fb0dfea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs NY Greek Americans',
  NULL,
  '2026-01-11T17:15:00.000Z',
  'b4b04f20-9c51-4b83-8f33-9a76c2a27794',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bfce5b73-66f5-4d76-8fbf-659f3fb0dfea',
  NULL,
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('96b1c450-4b7e-4a21-868c-0690446fa585', 'bfce5b73-66f5-4d76-8fbf-659f3fb0dfea', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '55cf4d9e-3f61-4052-83a1-f5d751503b0f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Jersey Shore Boca',
  NULL,
  '2025-09-06T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '55cf4d9e-3f61-4052-83a1-f5d751503b0f',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7625bec7-deeb-4782-b0a5-144b3bb5745b', '55cf4d9e-3f61-4052-83a1-f5d751503b0f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '10f89768-605b-4a9e-88df-5535ffb87e8f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Sewell Old Boys FC',
  NULL,
  '2025-09-14T15:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '10f89768-605b-4a9e-88df-5535ffb87e8f',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('59eb1ebc-4e78-4e75-8f95-93bc7bb95dbc', '10f89768-605b-4a9e-88df-5535ffb87e8f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5bc511d0-03f7-4314-88f7-973941894939',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Philadelphia Heritage SC',
  NULL,
  '2025-09-21T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5bc511d0-03f7-4314-88f7-973941894939',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4a2feef9-6282-4258-99b9-8360cb80d3a9', '5bc511d0-03f7-4314-88f7-973941894939', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '805caa90-4227-439c-81f9-7c40322c9e67',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Oaklyn United FC',
  NULL,
  '2025-09-27T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '805caa90-4227-439c-81f9-7c40322c9e67',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8e3c7aba-611c-4f96-85e3-60d57b5770b3', '805caa90-4227-439c-81f9-7c40322c9e67', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '90e6c3ab-9be3-4f99-8da6-51b9d6396d5a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Real Central NJ Soccer',
  NULL,
  '2025-10-04T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '90e6c3ab-9be3-4f99-8da6-51b9d6396d5a',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3caa9cde-4a6b-45b0-b5aa-3f4c7ea7a6d6', '90e6c3ab-9be3-4f99-8da6-51b9d6396d5a', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0e17b395-4ee5-4ab4-8c81-0a72d60de6fe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Alloy Soccer Club',
  NULL,
  '2025-10-11T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0e17b395-4ee5-4ab4-8c81-0a72d60de6fe',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fce3472a-31ec-4910-b19d-e24080f025ed', '0e17b395-4ee5-4ab4-8c81-0a72d60de6fe', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cd86ae17-ffcb-41a6-8904-4c3193753448',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Vidas United FC',
  NULL,
  '2025-10-23T00:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cd86ae17-ffcb-41a6-8904-4c3193753448',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9b8d8e49-c497-44af-abcc-aa107c479ae5', 'cd86ae17-ffcb-41a6-8904-4c3193753448', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'baacd09e-e142-4cce-8221-f79db14c4516',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Philadelphia Soccer Club',
  NULL,
  '2025-11-02T19:30:00.000Z',
  '27ef82a7-eda5-471b-80a8-ec7c9cac6635',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'baacd09e-e142-4cce-8221-f79db14c4516',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  10,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2f7f5a4e-1738-4dcf-a1bf-ac5dd1563917', 'baacd09e-e142-4cce-8221-f79db14c4516', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '25a486e6-c6e5-4ed6-8c24-0c2d78a6e485',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs GAK',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '25a486e6-c6e5-4ed6-8c24-0c2d78a6e485',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  12,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ecb6d23a-6ddb-4506-9678-a629b958c88b', '25a486e6-c6e5-4ed6-8c24-0c2d78a6e485', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '91a4fcda-aa0b-46c5-85da-b72adce7b656',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Medford Strikers',
  NULL,
  '2025-11-23T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '91a4fcda-aa0b-46c5-85da-b72adce7b656',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8e0a62b5-b4ed-46f2-888e-83722e829fc9', '91a4fcda-aa0b-46c5-85da-b72adce7b656', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3f4bfcad-41b8-4c13-816f-a24689c9c17f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Lighthouse 1893 SC',
  NULL,
  '2025-12-03T01:30:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3f4bfcad-41b8-4c13-816f-a24689c9c17f',
  NULL,
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('47eec0c1-c247-4b22-b0c9-6d5895a11245', '3f4bfcad-41b8-4c13-816f-a24689c9c17f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b2ff24cf-4f1e-4fa0-8f1a-3721155e16c0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Real Central NJ Soccer',
  NULL,
  '2025-09-07T23:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b2ff24cf-4f1e-4fa0-8f1a-3721155e16c0',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d30a3a6f-bf05-4363-9cfb-9800c0fc279d', 'b2ff24cf-4f1e-4fa0-8f1a-3721155e16c0', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '97acfed3-e2ec-4a95-8847-cb18d71c255c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Philadelphia Soccer Club',
  NULL,
  '2025-09-13T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '97acfed3-e2ec-4a95-8847-cb18d71c255c',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7ec41de4-9dc6-48b8-82c2-43ce27c4887d', '97acfed3-e2ec-4a95-8847-cb18d71c255c', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4a2e0cff-c49e-4a3d-8326-0654dcc1d756',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Oaklyn United FC',
  NULL,
  '2025-09-20T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4a2e0cff-c49e-4a3d-8326-0654dcc1d756',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6b85834b-c558-4ad6-a8c9-24c519388da1', '4a2e0cff-c49e-4a3d-8326-0654dcc1d756', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e14be16f-8fe3-4c4b-8055-77527d8c97df',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Jersey Shore Boca',
  NULL,
  '2025-09-28T22:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e14be16f-8fe3-4c4b-8055-77527d8c97df',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('85324db3-6c91-48e8-a31a-8115aca7c306', 'e14be16f-8fe3-4c4b-8055-77527d8c97df', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e6c1aab8-d00a-44ba-8699-060f821cd6aa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs WC Predators',
  NULL,
  '2025-10-11T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e6c1aab8-d00a-44ba-8699-060f821cd6aa',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6cb302e2-8ba4-4182-9fc3-a306200db71f', 'e6c1aab8-d00a-44ba-8699-060f821cd6aa', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '83ea5e90-2bdc-4fe1-8366-02243d87b671',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Medford Strikers',
  NULL,
  '2025-10-18T23:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '83ea5e90-2bdc-4fe1-8366-02243d87b671',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('48517b8c-4c29-4ef5-a79e-f464da904597', '83ea5e90-2bdc-4fe1-8366-02243d87b671', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '391d6c63-a218-4632-8e6b-bd0e08cfc17b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Vidas United FC',
  NULL,
  '2025-11-01T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '391d6c63-a218-4632-8e6b-bd0e08cfc17b',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5209bd3d-7645-4b43-b55f-6fb2acbd79e6', '391d6c63-a218-4632-8e6b-bd0e08cfc17b', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e27491bb-41f5-4df3-8a26-75488dd6c1af',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Philadelphia Heritage SC',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '8d0b0b2c-4755-41c1-8206-8f6ac5de04c2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e27491bb-41f5-4df3-8a26-75488dd6c1af',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d6bbe3c3-013a-4f9f-b09c-857d4f38594a', 'e27491bb-41f5-4df3-8a26-75488dd6c1af', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '127a13d9-67bc-41d9-85ea-2fba4c2c3d96',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Sewell Old Boys FC',
  NULL,
  '2025-11-16T16:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '127a13d9-67bc-41d9-85ea-2fba4c2c3d96',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fcb6bf8a-a164-4822-89f0-ae9ac014e1f2', '127a13d9-67bc-41d9-85ea-2fba4c2c3d96', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2276494f-3058-4412-8618-5877958b7ef8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Lighthouse 1893 SC',
  NULL,
  '2025-11-22T23:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2276494f-3058-4412-8618-5877958b7ef8',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fce61c91-9254-49ac-8c39-bd643ebaa8fa', '2276494f-3058-4412-8618-5877958b7ef8', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6a94b022-cfb5-469a-8502-ac712acc6ad7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs GAK',
  NULL,
  '2025-12-06T23:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6a94b022-cfb5-469a-8502-ac712acc6ad7',
  NULL,
  '1b01904c-2aca-4467-80c9-705893293f40',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('42ee6318-65bf-4d70-896e-389dca4ead3b', '6a94b022-cfb5-469a-8502-ac712acc6ad7', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd171002c-3753-4ce3-8c0a-7f70346079b2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Medford Strikers',
  NULL,
  '2025-09-07T22:00:00.000Z',
  'f5bc1d47-85c4-4c8d-8cee-d78e48d54708',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd171002c-3753-4ce3-8c0a-7f70346079b2',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bf9aa78e-ebb4-4d33-a92e-5de74bd6a0ca', 'd171002c-3753-4ce3-8c0a-7f70346079b2', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6162ebac-f1fa-47d0-8294-b37569a82f59',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs GAK',
  NULL,
  '2025-09-18T00:30:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6162ebac-f1fa-47d0-8294-b37569a82f59',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5207cd3c-b37b-44b4-bd9b-61b6d57f638d', '6162ebac-f1fa-47d0-8294-b37569a82f59', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '02d06173-fbc0-4254-884b-68ac3771ad4d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Alloy Soccer Club',
  NULL,
  '2025-09-20T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '02d06173-fbc0-4254-884b-68ac3771ad4d',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0275b7e2-e9d4-4abd-92c0-f9239e4ca315', '02d06173-fbc0-4254-884b-68ac3771ad4d', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fd79e19a-cc61-44eb-82d1-7b43a9ffdbe1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs WC Predators',
  NULL,
  '2025-09-27T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fd79e19a-cc61-44eb-82d1-7b43a9ffdbe1',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('433376c8-6fa8-4871-a899-6c7a3c7311d5', 'fd79e19a-cc61-44eb-82d1-7b43a9ffdbe1', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '51913cda-967d-4f8e-8c92-d0f7c1582dc4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Vidas United FC',
  NULL,
  '2025-10-05T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '51913cda-967d-4f8e-8c92-d0f7c1582dc4',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('998d437d-f713-433a-b2b8-402530da5eba', '51913cda-967d-4f8e-8c92-d0f7c1582dc4', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '115c2dda-2569-4459-86d9-3067ad37ee9c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Philadelphia Heritage SC',
  NULL,
  '2025-10-19T22:00:00.000Z',
  'f5bc1d47-85c4-4c8d-8cee-d78e48d54708',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '115c2dda-2569-4459-86d9-3067ad37ee9c',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a57d275d-fae4-428c-8e5f-d35abf0ebbfb', '115c2dda-2569-4459-86d9-3067ad37ee9c', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '01770ff2-9bfe-45ca-8c83-ebedd646ff7b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Lighthouse 1893 SC',
  NULL,
  '2025-11-09T18:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '01770ff2-9bfe-45ca-8c83-ebedd646ff7b',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5345d67c-68f3-4885-978b-f09404a85c88', '01770ff2-9bfe-45ca-8c83-ebedd646ff7b', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9d38b113-e27e-4e8e-879b-3a7636202065',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Real Central NJ Soccer',
  NULL,
  '2025-11-15T01:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9d38b113-e27e-4e8e-879b-3a7636202065',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('467b886a-c7bf-472c-893c-910752f44a7a', '9d38b113-e27e-4e8e-879b-3a7636202065', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3c1de2fe-f8fe-4dd0-83cd-a88cbb2330eb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Jersey Shore Boca',
  NULL,
  '2025-12-06T01:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3c1de2fe-f8fe-4dd0-83cd-a88cbb2330eb',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4f01184a-9587-495e-9154-bedb48eddfb4', '3c1de2fe-f8fe-4dd0-83cd-a88cbb2330eb', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '415e7dcb-55d0-4970-818d-48dcd22c1b31',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Sewell Old Boys FC',
  NULL,
  '2025-12-08T00:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '415e7dcb-55d0-4970-818d-48dcd22c1b31',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f20ac194-ac8e-4979-a227-21b7b5402351', '415e7dcb-55d0-4970-818d-48dcd22c1b31', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a61a3c2b-6db4-4c7a-8c12-d5d55a8e7906',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Philadelphia Soccer Club',
  NULL,
  '2025-12-19T01:15:00.000Z',
  '10331275-70d4-4b29-8d67-8764f559d039',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a61a3c2b-6db4-4c7a-8c12-d5d55a8e7906',
  NULL,
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('22eeadb7-f2c8-471e-804c-198f800592d9', 'a61a3c2b-6db4-4c7a-8c12-d5d55a8e7906', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5bfdd3a7-6829-428a-8a0e-4795fbda815d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Alloy Soccer Club',
  NULL,
  '2025-09-07T23:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5bfdd3a7-6829-428a-8a0e-4795fbda815d',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ac64ae7d-13ac-47e1-9935-6a2e81770016', '5bfdd3a7-6829-428a-8a0e-4795fbda815d', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7cbb9a91-4ab8-4e37-8754-9b8e93693f68',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Lighthouse 1893 SC',
  NULL,
  '2025-09-21T20:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7cbb9a91-4ab8-4e37-8754-9b8e93693f68',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('432f9b5c-a46c-49d7-bd6c-55e07e613d52', '7cbb9a91-4ab8-4e37-8754-9b8e93693f68', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b5494e1c-d02e-4ad5-8b5b-28c9ff116e09',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Philadelphia Soccer Club',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b5494e1c-d02e-4ad5-8b5b-28c9ff116e09',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('48537d16-5ab1-41b5-8f51-d14e852e6215', 'b5494e1c-d02e-4ad5-8b5b-28c9ff116e09', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f2f9090d-c1c6-4fff-8c81-9be8b61512b1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs GAK',
  NULL,
  '2025-10-02T01:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f2f9090d-c1c6-4fff-8c81-9be8b61512b1',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5039dd85-33fa-4218-9d16-0289efd94f35', 'f2f9090d-c1c6-4fff-8c81-9be8b61512b1', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'eba93ee7-0935-4715-821d-6966454b67e6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs WC Predators',
  NULL,
  '2025-10-04T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'eba93ee7-0935-4715-821d-6966454b67e6',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7d05bf04-1aa1-4d80-a930-cf81e28cad34', 'eba93ee7-0935-4715-821d-6966454b67e6', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ca39fa0b-99dc-42c0-82e1-9fce5e4fc644',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Jersey Shore Boca',
  NULL,
  '2025-10-19T22:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ca39fa0b-99dc-42c0-82e1-9fce5e4fc644',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ae0fcb10-2190-4635-9962-8f1902ffdf1c', 'ca39fa0b-99dc-42c0-82e1-9fce5e4fc644', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ec1c5a47-fa21-4cc1-835c-d3ace90e8b67',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Medford Strikers',
  NULL,
  '2025-11-03T01:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ec1c5a47-fa21-4cc1-835c-d3ace90e8b67',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('89a06e3e-e7a7-4a33-ac04-eb5873260fc5', 'ec1c5a47-fa21-4cc1-835c-d3ace90e8b67', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e303e0ac-8550-406a-8fcc-fc772b87b590',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Oaklyn United FC',
  NULL,
  '2025-11-15T01:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e303e0ac-8550-406a-8fcc-fc772b87b590',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('98cc6bc8-6e55-421e-a459-95319eafc257', 'e303e0ac-8550-406a-8fcc-fc772b87b590', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e3bf4eec-84f3-428a-898b-6eb12723c8e6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Philadelphia Heritage SC',
  NULL,
  '2025-11-24T00:00:00.000Z',
  '14061290-9fe4-4efb-836f-8f8564020138',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e3bf4eec-84f3-428a-898b-6eb12723c8e6',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('65d00b95-a5c1-44aa-84a4-9564cf6322f3', 'e3bf4eec-84f3-428a-898b-6eb12723c8e6', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ebdafa49-1fc6-4006-881e-b6628afe7f0d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Sewell Old Boys FC',
  NULL,
  '2025-12-04T01:30:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ebdafa49-1fc6-4006-881e-b6628afe7f0d',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('046de8a5-5608-4507-960e-d0584a0e935b', 'ebdafa49-1fc6-4006-881e-b6628afe7f0d', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6e4c7a29-a3be-46bf-8072-e414106a0c20',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Vidas United FC',
  NULL,
  '2026-01-11T16:00:00.000Z',
  '9bd2e5a9-960c-430c-8c8f-2b1f1e53184d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6e4c7a29-a3be-46bf-8072-e414106a0c20',
  NULL,
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bf05b45c-2af4-4ed9-a4d1-04a503814eef', '6e4c7a29-a3be-46bf-8072-e414106a0c20', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cd067475-9f4e-4857-8a6e-e7bd340e9ac0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Jersey Shore Boca',
  NULL,
  '2025-09-14T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cd067475-9f4e-4857-8a6e-e7bd340e9ac0',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1bdb3b26-ffa1-42ff-a9b9-fb60eb700245', 'cd067475-9f4e-4857-8a6e-e7bd340e9ac0', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8550d6c8-b4a7-4fd5-84ab-4f3cefc0d879',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs WC Predators',
  NULL,
  '2025-09-21T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8550d6c8-b4a7-4fd5-84ab-4f3cefc0d879',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e362bca1-59d0-4640-8a08-9c1503381228', '8550d6c8-b4a7-4fd5-84ab-4f3cefc0d879', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '833f830d-c95e-4c69-8a7c-987261873346',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Vidas United FC',
  NULL,
  '2025-09-28T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '833f830d-c95e-4c69-8a7c-987261873346',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('65faeb30-d50b-4524-935e-faca8c9c0f20', '833f830d-c95e-4c69-8a7c-987261873346', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2b1524f7-8c04-45cc-87f4-ea1888355e88',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Lighthouse 1893 SC',
  NULL,
  '2025-10-05T19:30:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2b1524f7-8c04-45cc-87f4-ea1888355e88',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2af42c52-2bb9-4f36-aa0f-93fbe3a82b2c', '2b1524f7-8c04-45cc-87f4-ea1888355e88', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9bebe48c-614e-4992-809a-6910f6b84f0d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs GAK',
  NULL,
  '2025-10-12T22:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9bebe48c-614e-4992-809a-6910f6b84f0d',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4b0cea25-e564-4e4c-8a60-c0b28299e672', '9bebe48c-614e-4992-809a-6910f6b84f0d', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0d56b42d-3e95-4840-8e91-faf67d93f4d2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Oaklyn United FC',
  NULL,
  '2025-10-19T22:00:00.000Z',
  'f5bc1d47-85c4-4c8d-8cee-d78e48d54708',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0d56b42d-3e95-4840-8e91-faf67d93f4d2',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6bf094f0-9b9b-42d3-aa3e-4fd466a013e6', '0d56b42d-3e95-4840-8e91-faf67d93f4d2', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c1a0a909-2864-4e9f-853a-3a189ae6c509',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Sewell Old Boys FC',
  NULL,
  '2025-10-26T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c1a0a909-2864-4e9f-853a-3a189ae6c509',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6a2d5008-377f-487a-9c19-380d91fc6988', 'c1a0a909-2864-4e9f-853a-3a189ae6c509', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'bf93f35e-3564-407e-8702-37493044a0dd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Alloy Soccer Club',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '8d0b0b2c-4755-41c1-8206-8f6ac5de04c2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'bf93f35e-3564-407e-8702-37493044a0dd',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ca09d12f-4f1e-4669-83a4-472ddd3d8b81', 'bf93f35e-3564-407e-8702-37493044a0dd', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b9d10f48-a6fe-44b3-8f56-35772bad4aa3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Medford Strikers',
  NULL,
  '2025-11-16T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b9d10f48-a6fe-44b3-8f56-35772bad4aa3',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('610d3cb0-9b97-4bfe-b31c-e8b2f86881f5', 'b9d10f48-a6fe-44b3-8f56-35772bad4aa3', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '96c42f78-ac01-4f2d-8670-ba6024c4b705',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Real Central NJ Soccer',
  NULL,
  '2025-11-24T00:00:00.000Z',
  '14061290-9fe4-4efb-836f-8f8564020138',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '96c42f78-ac01-4f2d-8670-ba6024c4b705',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('085d649a-b610-4395-b1fa-ec64d40bc317', '96c42f78-ac01-4f2d-8670-ba6024c4b705', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '261f16a8-f1f5-4a93-8546-df8b1fff220a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Philadelphia Soccer Club',
  NULL,
  '2025-12-11T01:15:00.000Z',
  '95501db9-8c71-46bf-89d3-fd46353ece60',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '261f16a8-f1f5-4a93-8546-df8b1fff220a',
  NULL,
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('60275dee-6c55-46db-9af5-be4774f538a5', '261f16a8-f1f5-4a93-8546-df8b1fff220a', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '03885bbc-2c22-4ba1-8cc4-2c461d34a3d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Lighthouse 1893 SC',
  NULL,
  '2025-09-07T20:30:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '03885bbc-2c22-4ba1-8cc4-2c461d34a3d0',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5bec410a-c819-47e6-b835-ee5ec538fc2f', '03885bbc-2c22-4ba1-8cc4-2c461d34a3d0', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6dc1f569-23b0-451d-8955-056a83758168',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Alloy Soccer Club',
  NULL,
  '2025-09-13T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6dc1f569-23b0-451d-8955-056a83758168',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d17289a5-f862-45ea-85c1-516dd6cc15db', '6dc1f569-23b0-451d-8955-056a83758168', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '066cb992-78db-478e-8386-37554ace3451',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Vidas United FC',
  NULL,
  '2025-09-21T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '066cb992-78db-478e-8386-37554ace3451',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e3e264c0-24a5-4f45-ae69-a5445dc31a29', '066cb992-78db-478e-8386-37554ace3451', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7fddd652-e1c2-410d-8e93-e5c337bd847f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Real Central NJ Soccer',
  NULL,
  '2025-09-28T23:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7fddd652-e1c2-410d-8e93-e5c337bd847f',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('67e7af45-275a-4aa9-b382-1027624d5961', '7fddd652-e1c2-410d-8e93-e5c337bd847f', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '228bb0d8-64d1-4fc8-869e-b8e774b6b77e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Medford Strikers',
  NULL,
  '2025-10-05T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '228bb0d8-64d1-4fc8-869e-b8e774b6b77e',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e2eed815-30fc-4a9c-9e4f-0c96b4948465', '228bb0d8-64d1-4fc8-869e-b8e774b6b77e', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6956814d-0a15-4bb1-8a19-5c36bdcf6356',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Jersey Shore Boca',
  NULL,
  '2025-10-12T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6956814d-0a15-4bb1-8a19-5c36bdcf6356',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9b67b653-f781-4569-9ab3-c9f5f7da7d28', '6956814d-0a15-4bb1-8a19-5c36bdcf6356', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd160d243-756b-453e-8fca-1a2c73bfcb1c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs WC Predators',
  NULL,
  '2025-11-02T19:30:00.000Z',
  '27ef82a7-eda5-471b-80a8-ec7c9cac6635',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd160d243-756b-453e-8fca-1a2c73bfcb1c',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  10,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e50a8820-a6a7-493f-8dfb-2c9edd85b398', 'd160d243-756b-453e-8fca-1a2c73bfcb1c', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f75411e1-17e9-4f93-8587-7c93b8072de2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs GAK',
  NULL,
  '2025-11-21T01:45:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f75411e1-17e9-4f93-8587-7c93b8072de2',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('03bf609b-62c2-4062-abd4-b41bdee2431c', 'f75411e1-17e9-4f93-8587-7c93b8072de2', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'afb6beb0-20fa-45a1-853b-a8dd22f6df58',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Sewell Old Boys FC',
  NULL,
  '2025-11-23T23:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'afb6beb0-20fa-45a1-853b-a8dd22f6df58',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bebd8070-bf40-4bce-a0e8-fc3d01599fe4', 'afb6beb0-20fa-45a1-853b-a8dd22f6df58', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cb3dac7f-dbae-41be-8fc1-e0b7c0bcd9cc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Philadelphia Heritage SC',
  NULL,
  '2025-12-11T01:15:00.000Z',
  '95501db9-8c71-46bf-89d3-fd46353ece60',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cb3dac7f-dbae-41be-8fc1-e0b7c0bcd9cc',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fa5048bc-a0e4-44dd-b7d3-867daffced25', 'cb3dac7f-dbae-41be-8fc1-e0b7c0bcd9cc', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fa42ede2-db5b-4886-81c2-7724383b4370',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Oaklyn United FC',
  NULL,
  '2025-12-19T01:15:00.000Z',
  '10331275-70d4-4b29-8d67-8764f559d039',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fa42ede2-db5b-4886-81c2-7724383b4370',
  NULL,
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('765aeb9e-4c9d-4ef8-895b-a63abc098029', 'fa42ede2-db5b-4886-81c2-7724383b4370', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c7e28322-88cf-4075-8bab-c80c93eff0e3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Sewell Old Boys FC',
  NULL,
  '2025-09-07T16:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c7e28322-88cf-4075-8bab-c80c93eff0e3',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a8d0327d-23d4-4a72-83f9-eea5bb3da6f0', 'c7e28322-88cf-4075-8bab-c80c93eff0e3', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2beae674-4e95-4aed-840b-612e9dbfe742',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Philadelphia Soccer Club',
  NULL,
  '2025-09-21T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2beae674-4e95-4aed-840b-612e9dbfe742',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('667cf38c-e9b8-4d00-a45a-b4c93abf98ab', '2beae674-4e95-4aed-840b-612e9dbfe742', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ab9aa236-f573-424d-81d0-03ee97271d28',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Philadelphia Heritage SC',
  NULL,
  '2025-09-28T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ab9aa236-f573-424d-81d0-03ee97271d28',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('333a99ba-cc49-4524-9b8b-64ff043f9e88', 'ab9aa236-f573-424d-81d0-03ee97271d28', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '207101fe-df0d-4321-8c02-ad510d5991bc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Oaklyn United FC',
  NULL,
  '2025-10-05T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '207101fe-df0d-4321-8c02-ad510d5991bc',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e544e1b2-758b-434b-a9a9-2282c2caece5', '207101fe-df0d-4321-8c02-ad510d5991bc', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c46924d5-8873-4ec2-8c3b-bb43f689552f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Lighthouse 1893 SC',
  NULL,
  '2025-10-12T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c46924d5-8873-4ec2-8c3b-bb43f689552f',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d5181fcd-e9d0-444c-9e76-e2426a01d4de', 'c46924d5-8873-4ec2-8c3b-bb43f689552f', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ae9af858-1250-4ff9-827f-0d30650953ae',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs GAK',
  NULL,
  '2025-10-19T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ae9af858-1250-4ff9-827f-0d30650953ae',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4654de73-ff51-45f9-abc7-38f78f0bb2df', 'ae9af858-1250-4ff9-827f-0d30650953ae', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '44c503a1-cb47-4923-8e61-dab63954bcd0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs WC Predators',
  NULL,
  '2025-10-23T00:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '44c503a1-cb47-4923-8e61-dab63954bcd0',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2259048d-ae5a-4d7b-850a-72d056108dac', '44c503a1-cb47-4923-8e61-dab63954bcd0', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c1f5400d-7d9a-429c-84ca-a9c182eb14fd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Alloy Soccer Club',
  NULL,
  '2025-11-01T22:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c1f5400d-7d9a-429c-84ca-a9c182eb14fd',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ea705bd0-a96d-4bab-aff3-13b4eaf4844b', 'c1f5400d-7d9a-429c-84ca-a9c182eb14fd', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4c15f925-5189-4e84-8b76-a4d45ced0ead',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Medford Strikers',
  NULL,
  '2025-11-09T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4c15f925-5189-4e84-8b76-a4d45ced0ead',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8c095f07-1ed8-4e5c-baaa-e4936f751b98', '4c15f925-5189-4e84-8b76-a4d45ced0ead', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f0a1da4b-e42e-4493-8ed1-909ea460b900',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Jersey Shore Boca',
  NULL,
  '2025-11-23T23:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f0a1da4b-e42e-4493-8ed1-909ea460b900',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('dc731835-a928-40ad-80dc-b19674002867', 'f0a1da4b-e42e-4493-8ed1-909ea460b900', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8b893ad6-a228-4a3d-826d-a81ef32b6104',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Real Central NJ Soccer',
  NULL,
  '2026-01-11T16:00:00.000Z',
  '9bd2e5a9-960c-430c-8c8f-2b1f1e53184d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8b893ad6-a228-4a3d-826d-a81ef32b6104',
  NULL,
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d7033aab-85b4-44c6-b31e-99d792004373', '8b893ad6-a228-4a3d-826d-a81ef32b6104', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2a40fa8e-1891-4ef7-8641-b11b7fa885e9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Oaklyn United FC',
  NULL,
  '2025-09-18T00:30:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2a40fa8e-1891-4ef7-8641-b11b7fa885e9',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d0c5ee08-6532-45d7-8b7e-23ad9c43d779', '2a40fa8e-1891-4ef7-8641-b11b7fa885e9', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e388a11f-4c16-41cf-8ccc-cdaf79d7bb66',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Medford Strikers',
  NULL,
  '2025-09-21T22:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e388a11f-4c16-41cf-8ccc-cdaf79d7bb66',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b786331c-a4ff-4b05-9a7d-d0a1a76b8c51', 'e388a11f-4c16-41cf-8ccc-cdaf79d7bb66', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '941b5be6-3f26-4c07-8db8-3996bb22512c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Real Central NJ Soccer',
  NULL,
  '2025-10-02T01:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '941b5be6-3f26-4c07-8db8-3996bb22512c',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('de868c7e-c7f8-4030-b054-163855f57ab8', '941b5be6-3f26-4c07-8db8-3996bb22512c', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '08e9ad59-8ff1-4c76-8395-1caa1be80918',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Sewell Old Boys FC',
  NULL,
  '2025-10-05T15:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '08e9ad59-8ff1-4c76-8395-1caa1be80918',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('58a06baf-dc58-4ece-962b-ecf98889409a', '08e9ad59-8ff1-4c76-8395-1caa1be80918', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '241d7f88-5440-48a5-866a-b00ceaa7bcbc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Philadelphia Heritage SC',
  NULL,
  '2025-10-12T22:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '241d7f88-5440-48a5-866a-b00ceaa7bcbc',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7c63abb6-fe7c-43ed-abc8-a2dde82d8eac', '241d7f88-5440-48a5-866a-b00ceaa7bcbc', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b1d97297-cb41-4071-8b9c-5f5dffc6cc78',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Vidas United FC',
  NULL,
  '2025-10-19T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b1d97297-cb41-4071-8b9c-5f5dffc6cc78',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4a7dc279-c445-40ae-aa65-9430393213be', 'b1d97297-cb41-4071-8b9c-5f5dffc6cc78', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '72405d32-737e-48b9-80f8-71373190c6c6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs WC Predators',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '72405d32-737e-48b9-80f8-71373190c6c6',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  12,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1ed5aeea-6d0f-4423-bb80-e8e5a5b2cf9f', '72405d32-737e-48b9-80f8-71373190c6c6', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'efd6cf7c-7edb-4ff3-8eec-e5095e119229',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Lighthouse 1893 SC',
  NULL,
  '2025-11-14T02:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'efd6cf7c-7edb-4ff3-8eec-e5095e119229',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e3287c8a-46d4-49c4-8661-5937656213df', 'efd6cf7c-7edb-4ff3-8eec-e5095e119229', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '772844b0-058e-4919-82ae-95639aea8657',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Philadelphia Soccer Club',
  NULL,
  '2025-11-21T01:45:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '772844b0-058e-4919-82ae-95639aea8657',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('64a9c8b5-8be0-4f3b-aedc-ca29108ba88b', '772844b0-058e-4919-82ae-95639aea8657', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '81c390c1-6de1-4dd7-8b5e-cd720a1f4b06',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Alloy Soccer Club',
  NULL,
  '2025-12-06T23:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '81c390c1-6de1-4dd7-8b5e-cd720a1f4b06',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0743a7a6-c171-49bc-a5d7-4bd2d39d888d', '81c390c1-6de1-4dd7-8b5e-cd720a1f4b06', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7d7c0d58-02db-4edc-8773-3e255a9e05aa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Jersey Shore Boca',
  NULL,
  '2025-12-18T23:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7d7c0d58-02db-4edc-8773-3e255a9e05aa',
  NULL,
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d74e7f60-60df-4abc-98a5-f7980d6e99a3', '7d7c0d58-02db-4edc-8773-3e255a9e05aa', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cb7a0309-439d-40af-8943-1f6c1594a8fb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Philadelphia Soccer Club',
  NULL,
  '2025-09-07T20:30:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cb7a0309-439d-40af-8943-1f6c1594a8fb',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('663076a9-b0bf-41df-b365-452048b1a96a', 'cb7a0309-439d-40af-8943-1f6c1594a8fb', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c6e81e24-c66a-473c-8d7b-96f7f31b663c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Medford Strikers',
  NULL,
  '2025-09-14T20:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c6e81e24-c66a-473c-8d7b-96f7f31b663c',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('546b5ba2-b949-4178-bb71-90d67a9ff564', 'c6e81e24-c66a-473c-8d7b-96f7f31b663c', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6baf75a6-3c94-4b8b-82b8-5da0166d4b1c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Real Central NJ Soccer',
  NULL,
  '2025-09-21T20:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6baf75a6-3c94-4b8b-82b8-5da0166d4b1c',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1587273e-d379-4d9c-b9ad-2b98d3e4c88a', '6baf75a6-3c94-4b8b-82b8-5da0166d4b1c', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '058f612d-bd46-47e3-85d4-d4c9c3e99cc9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Sewell Old Boys FC',
  NULL,
  '2025-09-28T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '058f612d-bd46-47e3-85d4-d4c9c3e99cc9',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c0a2d692-b303-47b0-a8c0-335697bd2b55', '058f612d-bd46-47e3-85d4-d4c9c3e99cc9', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fb42bd1d-08e3-4d25-80cd-e37e1e154360',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Philadelphia Heritage SC',
  NULL,
  '2025-10-05T19:30:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fb42bd1d-08e3-4d25-80cd-e37e1e154360',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0b316b99-0d5f-4b1d-9cd1-e9c893e2dd77', 'fb42bd1d-08e3-4d25-80cd-e37e1e154360', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6378d9fc-d297-4653-8a3b-1bc39e424ca4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Vidas United FC',
  NULL,
  '2025-10-12T17:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6378d9fc-d297-4653-8a3b-1bc39e424ca4',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6fc9e80c-bf21-4f04-9d1c-65768d3437dd', '6378d9fc-d297-4653-8a3b-1bc39e424ca4', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '67348b86-ca32-40f7-892e-6596fc1f8bc6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Oaklyn United FC',
  NULL,
  '2025-11-09T18:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '67348b86-ca32-40f7-892e-6596fc1f8bc6',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('280ce047-1f04-4c8a-9858-43bacadcf475', '67348b86-ca32-40f7-892e-6596fc1f8bc6', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a1dd4e09-6caf-4963-8914-efde0e59b452',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs GAK',
  NULL,
  '2025-11-14T02:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a1dd4e09-6caf-4963-8914-efde0e59b452',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ba81aabb-64fc-4b4b-9afc-104a3cc3f4ae', 'a1dd4e09-6caf-4963-8914-efde0e59b452', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '244e60cd-22ce-4263-834f-72ab6a4f0f2d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Alloy Soccer Club',
  NULL,
  '2025-11-22T23:00:00.000Z',
  'c95ab0fe-9bfa-43a8-8458-3f791062354f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '244e60cd-22ce-4263-834f-72ab6a4f0f2d',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6b45e1ef-15ea-410c-bf63-2b6d08b815ee', '244e60cd-22ce-4263-834f-72ab6a4f0f2d', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '07f6fcc4-c550-4a96-81de-70e1c12c6580',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Jersey Shore Boca',
  NULL,
  '2025-11-30T23:30:00.000Z',
  'd4656e10-2026-4d57-8b43-491f51216268',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '07f6fcc4-c550-4a96-81de-70e1c12c6580',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('56cef6fa-c3e2-4c8c-8bae-53b5f2daf513', '07f6fcc4-c550-4a96-81de-70e1c12c6580', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3343e6f9-7887-405b-8755-ae6bc9ec73b7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs WC Predators',
  NULL,
  '2025-12-03T01:30:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3343e6f9-7887-405b-8755-ae6bc9ec73b7',
  NULL,
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5236b2c7-3e23-44c8-9d97-007126086e75', '3343e6f9-7887-405b-8755-ae6bc9ec73b7', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '58fce49b-8346-491c-836d-e7a9dd938d37',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs WC Predators',
  NULL,
  '2025-09-06T22:00:00.000Z',
  '4204d645-2b9d-4b62-86a1-59883b691702',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '58fce49b-8346-491c-836d-e7a9dd938d37',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e2e9ec9b-c6cd-45b3-84c6-d2fa21d7cf05', '58fce49b-8346-491c-836d-e7a9dd938d37', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1a2c226d-f6ed-4fbb-8008-add5e9d3c1c9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Philadelphia Heritage SC',
  NULL,
  '2025-09-14T22:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1a2c226d-f6ed-4fbb-8008-add5e9d3c1c9',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('272e8f6f-43d7-42b3-b3ce-9e00619868ab', '1a2c226d-f6ed-4fbb-8008-add5e9d3c1c9', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'dd37f2ad-0fe7-44a5-8738-d4b47c18ce5a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Sewell Old Boys FC',
  NULL,
  '2025-09-21T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'dd37f2ad-0fe7-44a5-8738-d4b47c18ce5a',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c67907f5-8ef9-43d0-b954-01f772b2ee01', 'dd37f2ad-0fe7-44a5-8738-d4b47c18ce5a', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '95ecb689-312d-41f2-8e22-99690481b597',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Alloy Soccer Club',
  NULL,
  '2025-09-28T22:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '95ecb689-312d-41f2-8e22-99690481b597',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('769bb155-285c-44da-9523-3c192cb5173b', '95ecb689-312d-41f2-8e22-99690481b597', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3e510137-2d47-426b-80ea-9d80b397b23c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Philadelphia Soccer Club',
  NULL,
  '2025-10-12T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3e510137-2d47-426b-80ea-9d80b397b23c',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('a91981cc-912a-4481-8a80-491454d0524f', '3e510137-2d47-426b-80ea-9d80b397b23c', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ba08bf12-c629-4866-8174-77a1662e2ce7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Real Central NJ Soccer',
  NULL,
  '2025-10-19T22:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ba08bf12-c629-4866-8174-77a1662e2ce7',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ac59f200-535e-4698-b7f3-e81c269c0871', 'ba08bf12-c629-4866-8174-77a1662e2ce7', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '55d1c0c0-1d1f-4ea2-857d-e4332a25b91d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Medford Strikers',
  NULL,
  '2025-11-21T01:00:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '55d1c0c0-1d1f-4ea2-857d-e4332a25b91d',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8f3b31ef-ced1-4c7e-af1c-0e575fd33d12', '55d1c0c0-1d1f-4ea2-857d-e4332a25b91d', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '08cdc33a-d799-42d9-8779-744237f084a4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Vidas United FC',
  NULL,
  '2025-11-23T23:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '08cdc33a-d799-42d9-8779-744237f084a4',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b5d1d915-47b1-4a1c-943c-e14e1faec02d', '08cdc33a-d799-42d9-8779-744237f084a4', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ac60b673-e81a-49c0-8621-b01b2c16fa80',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Lighthouse 1893 SC',
  NULL,
  '2025-11-30T23:30:00.000Z',
  'd4656e10-2026-4d57-8b43-491f51216268',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ac60b673-e81a-49c0-8621-b01b2c16fa80',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('01febca9-a93a-489a-a9be-51fd55f76467', 'ac60b673-e81a-49c0-8621-b01b2c16fa80', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '00acb148-6b5b-4d39-8272-4ce87e9c65d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Oaklyn United FC',
  NULL,
  '2025-12-06T01:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '00acb148-6b5b-4d39-8272-4ce87e9c65d5',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0a65ea3e-76db-4a5d-b43b-40bb59c40119', '00acb148-6b5b-4d39-8272-4ce87e9c65d5', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0f828e1f-51b5-4f8b-8b27-a1d9ce850112',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs GAK',
  NULL,
  '2025-12-18T23:30:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0f828e1f-51b5-4f8b-8b27-a1d9ce850112',
  NULL,
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c3dbb2ad-3f34-4821-ac4c-3452dd9e2fd0', '0f828e1f-51b5-4f8b-8b27-a1d9ce850112', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b3a32e98-5434-4dd7-8431-a7f62c54dcdf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Vidas United FC',
  NULL,
  '2025-09-07T16:00:00.000Z',
  '23b3658d-264d-461f-8feb-ffc87c3a73b3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b3a32e98-5434-4dd7-8431-a7f62c54dcdf',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('571ad070-c3ab-4a7f-a0d2-73c433ead49b', 'b3a32e98-5434-4dd7-8431-a7f62c54dcdf', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6cca01a5-1ea3-4e5d-888e-42dcf4733023',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs WC Predators',
  NULL,
  '2025-09-14T15:00:00.000Z',
  'e9240cd4-d0db-4258-84af-5317918e0342',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6cca01a5-1ea3-4e5d-888e-42dcf4733023',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('93779f69-a604-47c1-b73a-f1fe19f43837', '6cca01a5-1ea3-4e5d-888e-42dcf4733023', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '96765e7e-1092-4f7d-8b27-23955919925e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Jersey Shore Boca',
  NULL,
  '2025-09-21T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '96765e7e-1092-4f7d-8b27-23955919925e',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('69f5f959-c216-43e4-9577-1067a9210cd8', '96765e7e-1092-4f7d-8b27-23955919925e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6318bd72-3070-46d3-8909-338a0fff99c3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Lighthouse 1893 SC',
  NULL,
  '2025-09-28T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6318bd72-3070-46d3-8909-338a0fff99c3',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3590dcf5-9914-4ff1-a529-eb09c7673b32', '6318bd72-3070-46d3-8909-338a0fff99c3', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '04c48caf-285f-4181-88c9-a191b0124399',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs GAK',
  NULL,
  '2025-10-05T15:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '04c48caf-285f-4181-88c9-a191b0124399',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9498f9f7-c51e-4bdc-9fd9-56585716b3d9', '04c48caf-285f-4181-88c9-a191b0124399', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b0c65cdf-85e1-4ba9-8df3-bc0c55a0ef35',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Medford Strikers',
  NULL,
  '2025-10-11T23:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b0c65cdf-85e1-4ba9-8df3-bc0c55a0ef35',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0ff9c696-bd30-4d09-93bd-d8c0b6742744', 'b0c65cdf-85e1-4ba9-8df3-bc0c55a0ef35', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7127bff8-d032-4e3c-8c2c-f678651eb62f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Philadelphia Heritage SC',
  NULL,
  '2025-10-26T15:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7127bff8-d032-4e3c-8c2c-f678651eb62f',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('27786ddc-53b5-43cb-b5df-55f59a9209c0', '7127bff8-d032-4e3c-8c2c-f678651eb62f', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b734676c-1838-4e6a-8d1e-00ea72cec79e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Alloy Soccer Club',
  NULL,
  '2025-11-16T16:00:00.000Z',
  '566a3247-a932-4a7b-88d2-8993b9d0ea1a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b734676c-1838-4e6a-8d1e-00ea72cec79e',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('19c0a424-7f05-4a14-90d0-9bb3fb1130bf', 'b734676c-1838-4e6a-8d1e-00ea72cec79e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ce225a1d-231a-49c1-8fe0-4fedfb8f3a98',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Philadelphia Soccer Club',
  NULL,
  '2025-11-23T23:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ce225a1d-231a-49c1-8fe0-4fedfb8f3a98',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9d3cb423-314f-4d20-8bc6-364ec3e6d740', 'ce225a1d-231a-49c1-8fe0-4fedfb8f3a98', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c574f737-5016-4ee7-8a0f-9eaf107d876f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Real Central NJ Soccer',
  NULL,
  '2025-12-04T01:30:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c574f737-5016-4ee7-8a0f-9eaf107d876f',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c906902a-dff7-43cb-9ef2-d28a37afc26c', 'c574f737-5016-4ee7-8a0f-9eaf107d876f', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '033ec43f-7328-47db-86f5-212f4abc878e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Oaklyn United FC',
  NULL,
  '2025-12-08T00:00:00.000Z',
  '235717f9-ba3c-4fc0-8b49-7232990d3ec3',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '033ec43f-7328-47db-86f5-212f4abc878e',
  NULL,
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9559a698-44ac-4c41-a313-ac2d47f820d1', '033ec43f-7328-47db-86f5-212f4abc878e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fbfabdc4-36ec-4301-8dba-d622d88cd4ac',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Oaklyn United FC',
  NULL,
  '2025-09-07T22:00:00.000Z',
  'f5bc1d47-85c4-4c8d-8cee-d78e48d54708',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fbfabdc4-36ec-4301-8dba-d622d88cd4ac',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9bce1a40-67db-4ad7-9777-2628270eddde', 'fbfabdc4-36ec-4301-8dba-d622d88cd4ac', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5276e974-19a3-4684-8e5d-ec8f100f49b0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Lighthouse 1893 SC',
  NULL,
  '2025-09-14T20:00:00.000Z',
  '54ecf3ae-774a-4d1a-8138-e5e41d81189b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5276e974-19a3-4684-8e5d-ec8f100f49b0',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8d081316-8f37-4ee6-9bb6-31480f9b3a8a', '5276e974-19a3-4684-8e5d-ec8f100f49b0', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ff53826c-c8ac-408f-8d3f-822cc11af125',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs GAK',
  NULL,
  '2025-09-21T22:00:00.000Z',
  '2e3f8834-be8f-4c05-898d-d7368f5a409d',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ff53826c-c8ac-408f-8d3f-822cc11af125',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e9e6629b-a599-42d7-a775-8a14b39bdc42', 'ff53826c-c8ac-408f-8d3f-822cc11af125', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '44b0e992-2e22-4595-8145-71f8e0b99f47',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Philadelphia Soccer Club',
  NULL,
  '2025-10-05T22:00:00.000Z',
  'e47487c5-78ee-4f20-8b59-15931852d1a6',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '44b0e992-2e22-4595-8145-71f8e0b99f47',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9e603d91-7cce-4aea-b40d-1086b87ff1aa', '44b0e992-2e22-4595-8145-71f8e0b99f47', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4d92df9f-a493-47b7-8f66-eb5edbffd23f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Sewell Old Boys FC',
  NULL,
  '2025-10-11T23:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4d92df9f-a493-47b7-8f66-eb5edbffd23f',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b4a54248-11c8-4e6c-bdee-4287ceb0ca7d', '4d92df9f-a493-47b7-8f66-eb5edbffd23f', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '630e2b41-138d-4a12-8256-d3d8c46d514e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Alloy Soccer Club',
  NULL,
  '2025-10-18T23:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '630e2b41-138d-4a12-8256-d3d8c46d514e',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3e214430-917c-498d-a6c8-5fc8e11acdda', '630e2b41-138d-4a12-8256-d3d8c46d514e', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '29250683-9c01-4d58-8d9e-8a8537e600e1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Real Central NJ Soccer',
  NULL,
  '2025-11-03T01:00:00.000Z',
  '1d6fd1fd-e7ef-482c-86b0-89f9f32f93a9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '29250683-9c01-4d58-8d9e-8a8537e600e1',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ebcb2bd5-5f2b-4ff1-b132-1fe606b4926e', '29250683-9c01-4d58-8d9e-8a8537e600e1', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0917aba2-5857-4aec-8860-d29462fd5301',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Vidas United FC',
  NULL,
  '2025-11-09T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0917aba2-5857-4aec-8860-d29462fd5301',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6f1b2d9f-6e80-47c0-a729-2f09522027f5', '0917aba2-5857-4aec-8860-d29462fd5301', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ef4b020e-935a-43dd-88a1-3a58323e73b0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Philadelphia Heritage SC',
  NULL,
  '2025-11-16T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ef4b020e-935a-43dd-88a1-3a58323e73b0',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0bbf8aa1-a5cd-4bb6-aaf4-f3941de7828b', 'ef4b020e-935a-43dd-88a1-3a58323e73b0', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '508fc113-44a2-4b53-8486-cf4e72c0537f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Jersey Shore Boca',
  NULL,
  '2025-11-21T01:00:00.000Z',
  '8f3d2145-3eaf-44b4-8d97-1733adf7a06f',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '508fc113-44a2-4b53-8486-cf4e72c0537f',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('074af97f-a707-479e-804c-5353eff7509c', '508fc113-44a2-4b53-8486-cf4e72c0537f', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b2fd7472-2b9d-4f0f-8bc3-0decd3a808a6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs WC Predators',
  NULL,
  '2025-11-23T00:00:00.000Z',
  'd5fd07e4-243b-43e5-8a51-2b5043938bb4',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b2fd7472-2b9d-4f0f-8bc3-0decd3a808a6',
  NULL,
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b5dfef29-0832-4bd5-9d7f-11d7fd09fbd9', 'b2fd7472-2b9d-4f0f-8bc3-0decd3a808a6', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1bd8e559-ea36-47da-8b57-531189a3c53b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Grove Soccer United',
  NULL,
  '2025-09-13T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1bd8e559-ea36-47da-8b57-531189a3c53b',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6aec34b6-a8a2-47f3-b269-8a92b5b1dc79', '1bd8e559-ea36-47da-8b57-531189a3c53b', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a3231f82-01bc-4f53-8fd2-7c888959a45a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Delmarva Thunder',
  NULL,
  '2025-09-20T23:00:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a3231f82-01bc-4f53-8fd2-7c888959a45a',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  8,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d71d9254-e677-4b33-aafb-d232c15fee7f', 'a3231f82-01bc-4f53-8fd2-7c888959a45a', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2840691a-9bf2-42ca-8e4c-f699bad3d558',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs PW Nova',
  NULL,
  '2025-09-29T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2840691a-9bf2-42ca-8e4c-f699bad3d558',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0eac5275-cf04-47e4-8a1a-71e2bd01d550', '2840691a-9bf2-42ca-8e4c-f699bad3d558', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '02dfa0c7-4f8d-48a0-879b-a649f5b78e5f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs PFA EPSL',
  NULL,
  '2025-10-05T00:00:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '02dfa0c7-4f8d-48a0-879b-a649f5b78e5f',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('74fe5e1f-2d8a-4d43-8793-0198118a1431', '02dfa0c7-4f8d-48a0-879b-a649f5b78e5f', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ba2e073e-24ce-4f38-8ab7-efa3a07f6261',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Wave FC',
  NULL,
  '2025-10-25T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ba2e073e-24ce-4f38-8ab7-efa3a07f6261',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d6e6ea8a-d989-4458-a068-6ae368d15369', 'ba2e073e-24ce-4f38-8ab7-efa3a07f6261', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fefd6ec5-d9ed-4df2-8f4e-ef815f85c9ff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs VA Marauders FC',
  NULL,
  '2025-11-09T00:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fefd6ec5-d9ed-4df2-8f4e-ef815f85c9ff',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('17a0d78f-7ebe-4e55-9233-041acafa761f', 'fefd6ec5-d9ed-4df2-8f4e-ef815f85c9ff', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f440a629-7ef5-43c9-8b93-090633cc0302',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs PFA EPSL',
  NULL,
  '2025-11-10T00:30:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f440a629-7ef5-43c9-8b93-090633cc0302',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('95ca28a7-73c0-4a33-9069-2eb8391a68d7', 'f440a629-7ef5-43c9-8b93-090633cc0302', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'de64bdd6-9125-40f9-8ac6-fd47cdaecc48',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Christos FC',
  NULL,
  '2025-11-17T00:45:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'de64bdd6-9125-40f9-8ac6-fd47cdaecc48',
  NULL,
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('dc28c7da-d322-4c60-8f95-9e22be4f669e', 'de64bdd6-9125-40f9-8ac6-fd47cdaecc48', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '62fb1ec4-8c9b-437d-8be3-202a573db283',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs PW Nova',
  NULL,
  '2025-09-15T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '62fb1ec4-8c9b-437d-8be3-202a573db283',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('61d612a3-aef6-44d3-b984-e8bde347f2ca', '62fb1ec4-8c9b-437d-8be3-202a573db283', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7a1494ed-a731-4e2c-8f29-cf525f5a74ab',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Wave FC',
  NULL,
  '2025-09-21T21:00:00.000Z',
  'faf62a65-95de-4147-86a9-6df8d866a596',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7a1494ed-a731-4e2c-8f29-cf525f5a74ab',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('acd067c5-9e7b-45ab-b5b7-91e659560b7d', '7a1494ed-a731-4e2c-8f29-cf525f5a74ab', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f2647efc-4894-4cdf-8e0d-170ce19e6403',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Christos FC',
  NULL,
  '2025-09-27T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f2647efc-4894-4cdf-8e0d-170ce19e6403',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('11e3d748-cf51-402c-8496-f357288acdf4', 'f2647efc-4894-4cdf-8e0d-170ce19e6403', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6692c5cc-f695-46c2-8774-72b0774015ca',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Delmarva Thunder',
  NULL,
  '2025-10-25T20:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6692c5cc-f695-46c2-8774-72b0774015ca',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d06079b4-215b-4559-a274-f8f6aa52a592', '6692c5cc-f695-46c2-8774-72b0774015ca', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '885e90a2-c1fd-4956-8b48-50c9db7f7574',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Grove Soccer United',
  NULL,
  '2025-11-02T22:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '885e90a2-c1fd-4956-8b48-50c9db7f7574',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('84ad9412-e63c-4886-b1b6-3df457af5974', '885e90a2-c1fd-4956-8b48-50c9db7f7574', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '72647206-0e29-4c3a-81dc-64862a04b046',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Nova FC',
  NULL,
  '2025-11-09T00:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '72647206-0e29-4c3a-81dc-64862a04b046',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c7b145f6-9309-4653-b2a0-d9933c9d8e6e', '72647206-0e29-4c3a-81dc-64862a04b046', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '87bf8e26-5161-469d-81fe-94c9baead681',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs PFA EPSL',
  NULL,
  '2025-11-16T23:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '87bf8e26-5161-469d-81fe-94c9baead681',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2b6474ef-c874-4e5e-84ea-af7f56fc91bb', '87bf8e26-5161-469d-81fe-94c9baead681', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c796d015-02f4-49f0-8436-0ebdf7894f82',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Wave FC',
  NULL,
  '2025-11-22T20:00:00.000Z',
  '1754a50e-887f-4af8-85cb-7c78685bc800',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c796d015-02f4-49f0-8436-0ebdf7894f82',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8de36288-b28a-41a4-8ba4-cd0b76542ef7', 'c796d015-02f4-49f0-8436-0ebdf7894f82', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1eb593e9-6425-48b2-8f0a-4d21010884ec',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Delmarva Thunder',
  NULL,
  '2025-12-06T19:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1eb593e9-6425-48b2-8f0a-4d21010884ec',
  NULL,
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fbfa645d-d1a3-49a0-ad8f-54466a5b7e0b', '1eb593e9-6425-48b2-8f0a-4d21010884ec', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '251084a0-619e-4d78-8bfa-140ae791be70',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs VA Marauders FC',
  NULL,
  '2025-09-21T21:00:00.000Z',
  'faf62a65-95de-4147-86a9-6df8d866a596',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '251084a0-619e-4d78-8bfa-140ae791be70',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('62ba2ae8-7f04-415d-be79-bc13c72538f1', '251084a0-619e-4d78-8bfa-140ae791be70', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'ac5f9ccf-375e-44db-8cc9-d09662639188',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Grove Soccer United',
  NULL,
  '2025-09-27T20:00:00.000Z',
  '547d1dac-25ff-4861-8c45-2864d315a701',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'ac5f9ccf-375e-44db-8cc9-d09662639188',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3e1542f2-01e1-4d67-b27e-2dda0c74cf30', 'ac5f9ccf-375e-44db-8cc9-d09662639188', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '38267124-f4a1-454a-8457-397c4b7eec40',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Delmarva Thunder',
  NULL,
  '2025-10-04T20:00:00.000Z',
  '3d37fd26-47c0-40d7-81f4-a123786a996a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '38267124-f4a1-454a-8457-397c4b7eec40',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('088e7416-0913-4845-a830-93a258697a1d', '38267124-f4a1-454a-8457-397c4b7eec40', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '65504e3a-2071-463c-8fe6-689c8df9937a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Nova FC',
  NULL,
  '2025-10-25T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '65504e3a-2071-463c-8fe6-689c8df9937a',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4d6e1faf-4cd7-46f3-a5b7-f85c1f98088e', '65504e3a-2071-463c-8fe6-689c8df9937a', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2e816037-f881-490d-831a-f581c80583c1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs PW Nova',
  NULL,
  '2025-11-02T23:00:00.000Z',
  '1754a50e-887f-4af8-85cb-7c78685bc800',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2e816037-f881-490d-831a-f581c80583c1',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  10,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('52a1dc97-e761-4c69-ba53-b136b4f4f47e', '2e816037-f881-490d-831a-f581c80583c1', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd7d079cc-a140-45a3-823f-c1b2669c4a5d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Grove Soccer United',
  NULL,
  '2025-11-08T18:00:00.000Z',
  'ef3e77aa-dcda-4970-8fc9-4ca46df49611',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd7d079cc-a140-45a3-823f-c1b2669c4a5d',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9dacb547-9989-467c-97ca-66a1d5b59521', 'd7d079cc-a140-45a3-823f-c1b2669c4a5d', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '51538e46-6ba4-49c9-8359-cb3ef784b0ff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs VA Marauders FC',
  NULL,
  '2025-11-22T20:00:00.000Z',
  '1754a50e-887f-4af8-85cb-7c78685bc800',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '51538e46-6ba4-49c9-8359-cb3ef784b0ff',
  NULL,
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c314d1d1-7492-4718-b8c1-0fa7d5e20757', '51538e46-6ba4-49c9-8359-cb3ef784b0ff', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5741860e-9136-4441-82ce-f16a77a52ab4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Delmarva Thunder',
  NULL,
  '2025-09-27T17:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5741860e-9136-4441-82ce-f16a77a52ab4',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fdb7bdde-3996-46c9-9076-4c695c729d23', '5741860e-9136-4441-82ce-f16a77a52ab4', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '70491f20-2988-4e45-86cf-d5460acc424b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Nova FC',
  NULL,
  '2025-10-05T00:00:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '70491f20-2988-4e45-86cf-d5460acc424b',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('63d7a79b-2e13-4d43-b89f-fd39e9c39f00', '70491f20-2988-4e45-86cf-d5460acc424b', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '02bfe26b-1f47-4313-857a-bb30bd90c66a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Delmarva Thunder',
  NULL,
  '2025-10-18T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '02bfe26b-1f47-4313-857a-bb30bd90c66a',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b80b65cb-3bbb-46c4-be6c-162852e25b89', '02bfe26b-1f47-4313-857a-bb30bd90c66a', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a24e1fbc-db38-4a57-877b-9d24594c28b9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Christos FC',
  NULL,
  '2025-10-25T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a24e1fbc-db38-4a57-877b-9d24594c28b9',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cbf99167-ef9b-4c9c-8f61-98c158612871', 'a24e1fbc-db38-4a57-877b-9d24594c28b9', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6284ce72-655b-40b7-856e-df74513723b8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Nova FC',
  NULL,
  '2025-11-10T00:30:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6284ce72-655b-40b7-856e-df74513723b8',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2fbf68de-5f2f-4178-bfca-2aa2649f1fee', '6284ce72-655b-40b7-856e-df74513723b8', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cd88baa3-fb28-47c9-8160-2c7f80d8a30a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs VA Marauders FC',
  NULL,
  '2025-11-16T23:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cd88baa3-fb28-47c9-8160-2c7f80d8a30a',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1c4d9bf8-da2c-420d-9ffe-6a16c56d8533', 'cd88baa3-fb28-47c9-8160-2c7f80d8a30a', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5a6c3cac-544f-443c-86fc-e4d9dad681a4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Christos FC',
  NULL,
  '2025-11-22T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5a6c3cac-544f-443c-86fc-e4d9dad681a4',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3f2965b9-f61f-4642-b4c8-8c87eee2ed54', '5a6c3cac-544f-443c-86fc-e4d9dad681a4', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9590c734-e06d-447c-87b8-1ec36064d142',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs PW Nova',
  NULL,
  '2025-12-07T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9590c734-e06d-447c-87b8-1ec36064d142',
  NULL,
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7ea37405-b609-4d3f-b97b-b847bcc2fad8', '9590c734-e06d-447c-87b8-1ec36064d142', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3a5cba94-14c4-466b-8fab-ed1b13fef954',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Nova FC',
  NULL,
  '2025-09-13T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3a5cba94-14c4-466b-8fab-ed1b13fef954',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cf5946b9-dbff-47ff-b5f0-0735a91b561f', '3a5cba94-14c4-466b-8fab-ed1b13fef954', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9520dcf2-721b-4fe9-873e-74b2a8a4ada9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs PW Nova',
  NULL,
  '2025-09-21T23:00:00.000Z',
  'faf62a65-95de-4147-86a9-6df8d866a596',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9520dcf2-721b-4fe9-873e-74b2a8a4ada9',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('59ead814-7515-4e25-a9d1-9f6864fb7e67', '9520dcf2-721b-4fe9-873e-74b2a8a4ada9', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a3c02d1b-c9d2-4334-8de9-930882f45839',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Wave FC',
  NULL,
  '2025-09-27T20:00:00.000Z',
  '547d1dac-25ff-4861-8c45-2864d315a701',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a3c02d1b-c9d2-4334-8de9-930882f45839',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9807d35e-b8fb-4119-9d6a-5a48fdce38ac', 'a3c02d1b-c9d2-4334-8de9-930882f45839', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '73504d7e-ff7c-4ed1-8671-820bd06014c2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Christos FC',
  NULL,
  '2025-10-18T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '73504d7e-ff7c-4ed1-8671-820bd06014c2',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('dde5847a-d23f-4f4f-a051-28c2cb457a7f', '73504d7e-ff7c-4ed1-8671-820bd06014c2', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2a2dbbf5-35cf-4fea-860e-a37a804c7311',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs VA Marauders FC',
  NULL,
  '2025-11-02T22:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '2a2dbbf5-35cf-4fea-860e-a37a804c7311',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0eb0cbfc-7462-40d7-b313-f1c69ed61c28', '2a2dbbf5-35cf-4fea-860e-a37a804c7311', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '22ad0d56-98e9-4cd1-8a1c-9823a44bfabf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Wave FC',
  NULL,
  '2025-11-08T18:00:00.000Z',
  'ef3e77aa-dcda-4970-8fc9-4ca46df49611',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '22ad0d56-98e9-4cd1-8a1c-9823a44bfabf',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9958bd61-a3b3-499e-b581-381ffddd974a', '22ad0d56-98e9-4cd1-8a1c-9823a44bfabf', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd86b0e2d-70e9-4fac-897f-40a1854205cf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Delmarva Thunder',
  NULL,
  '2025-11-15T19:45:00.000Z',
  'f8980da4-aaed-4ede-8b94-92d79fa2e906',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd86b0e2d-70e9-4fac-897f-40a1854205cf',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('aca0b26c-04b8-49eb-8c61-7765969dae82', 'd86b0e2d-70e9-4fac-897f-40a1854205cf', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a827ef33-7122-475d-8c30-1d99cb57c181',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs PW Nova',
  NULL,
  '2025-11-16T19:00:00.000Z',
  '2bc6d4bc-48e6-4c74-8abd-cdc8a8bef400',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a827ef33-7122-475d-8c30-1d99cb57c181',
  NULL,
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2a3aa345-3358-4645-88c2-9020372541d8', 'a827ef33-7122-475d-8c30-1d99cb57c181', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '10b607e7-46d2-428b-83fb-ead94dc9418f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs VA Marauders FC',
  NULL,
  '2025-09-27T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '10b607e7-46d2-428b-83fb-ead94dc9418f',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('443d2090-2e22-4db2-a4eb-b5a00126050d', '10b607e7-46d2-428b-83fb-ead94dc9418f', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '41f8370c-d73e-49a8-814f-35a2d88ee818',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs PW Nova',
  NULL,
  '2025-10-06T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '41f8370c-d73e-49a8-814f-35a2d88ee818',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('81650b4a-334d-4a8b-a093-cd3d4173df33', '41f8370c-d73e-49a8-814f-35a2d88ee818', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '91b31495-7eee-4d4e-8d66-0453aca7e7cb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs Grove Soccer United',
  NULL,
  '2025-10-18T23:30:00.000Z',
  '8e42a0dc-2a35-4752-83f9-245acc226b0e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '91b31495-7eee-4d4e-8d66-0453aca7e7cb',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('71c0183f-47db-4a3d-a332-e0f650dd4250', '91b31495-7eee-4d4e-8d66-0453aca7e7cb', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0e721685-1326-4e85-89a0-d8d8b9454d56',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs PFA EPSL',
  NULL,
  '2025-10-25T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0e721685-1326-4e85-89a0-d8d8b9454d56',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('742184ba-c90c-4cb2-8408-5769afa5afb4', '0e721685-1326-4e85-89a0-d8d8b9454d56', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '73e85eb9-f787-43df-8744-81196c9b6abc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs Delmarva Thunder',
  NULL,
  '2025-11-15T20:00:00.000Z',
  'ef0480f1-d7ac-4d3f-879b-7735a8a5d36b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '73e85eb9-f787-43df-8744-81196c9b6abc',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8e8cb0a3-28fd-41bb-b4fd-1801a7ada39a', '73e85eb9-f787-43df-8744-81196c9b6abc', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '74bf771d-f20d-46ba-8717-0fccaaca606a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs Nova FC',
  NULL,
  '2025-11-17T00:45:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '74bf771d-f20d-46ba-8717-0fccaaca606a',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ced3471e-dafb-44e7-b9cf-5fe704b0e7a6', '74bf771d-f20d-46ba-8717-0fccaaca606a', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '15ad4223-e06e-4b10-8297-dc394100662e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs PFA EPSL',
  NULL,
  '2025-11-22T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '15ad4223-e06e-4b10-8297-dc394100662e',
  NULL,
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ecb9ee72-4d31-43cc-9ef0-fabc92814c84', '15ad4223-e06e-4b10-8297-dc394100662e', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '047df210-3eed-42d8-89b2-0021704b70c5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs Nova FC',
  NULL,
  '2025-09-20T23:00:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '047df210-3eed-42d8-89b2-0021704b70c5',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  8,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5ea68fb4-23c1-472f-b278-2bd786de2909', '047df210-3eed-42d8-89b2-0021704b70c5', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7cd7d86d-b893-4b42-8214-165cf842d1b5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs PFA EPSL',
  NULL,
  '2025-09-27T17:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7cd7d86d-b893-4b42-8214-165cf842d1b5',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0cf5e37e-85a9-4416-be14-6ea8428034ba', '7cd7d86d-b893-4b42-8214-165cf842d1b5', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'baa72563-cc2a-47d2-84e7-169fc7c104cf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs Wave FC',
  NULL,
  '2025-10-04T20:00:00.000Z',
  '3d37fd26-47c0-40d7-81f4-a123786a996a',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'baa72563-cc2a-47d2-84e7-169fc7c104cf',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('67693894-9bf3-4a9c-b07a-46845d1ab16d', 'baa72563-cc2a-47d2-84e7-169fc7c104cf', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '83ce9341-be86-4d87-8379-5b8cb14dbbae',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs PFA EPSL',
  NULL,
  '2025-10-18T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '83ce9341-be86-4d87-8379-5b8cb14dbbae',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('189b9fe9-01ef-485c-aa22-534d9be8a791', '83ce9341-be86-4d87-8379-5b8cb14dbbae', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fd5e8f2f-cc9d-4102-89df-2ea09a17dd83',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs VA Marauders FC',
  NULL,
  '2025-10-25T20:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fd5e8f2f-cc9d-4102-89df-2ea09a17dd83',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5cce0314-be99-4723-aa77-a0abfd875e7b', 'fd5e8f2f-cc9d-4102-89df-2ea09a17dd83', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5dc4363e-8c50-408d-81e4-87c5bc1f903a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs PW Nova',
  NULL,
  '2025-11-08T20:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5dc4363e-8c50-408d-81e4-87c5bc1f903a',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('835aef3a-1278-4681-a3cd-4880ca5ff132', '5dc4363e-8c50-408d-81e4-87c5bc1f903a', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a063642f-3cda-444e-879e-f53a5cb48d24',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs Grove Soccer United',
  NULL,
  '2025-11-15T19:45:00.000Z',
  'f8980da4-aaed-4ede-8b94-92d79fa2e906',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a063642f-3cda-444e-879e-f53a5cb48d24',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f7d69194-551b-41b5-96e1-e25bdffe5650', 'a063642f-3cda-444e-879e-f53a5cb48d24', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f47e3d3d-0d64-4df7-8a6f-122a0466610e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs Christos FC',
  NULL,
  '2025-11-15T20:00:00.000Z',
  'ef0480f1-d7ac-4d3f-879b-7735a8a5d36b',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f47e3d3d-0d64-4df7-8a6f-122a0466610e',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('23b488b2-21d7-4305-a81b-e6b96a46d73b', 'f47e3d3d-0d64-4df7-8a6f-122a0466610e', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0754a7ed-e2e2-4437-8ef1-888cc063e626',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs VA Marauders FC',
  NULL,
  '2025-12-06T19:30:00.000Z',
  'ed6a51e3-7615-4c89-8951-f0631e72a0f2',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0754a7ed-e2e2-4437-8ef1-888cc063e626',
  NULL,
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('92cc9cce-49b7-4c11-a2a8-049a363953ca', '0754a7ed-e2e2-4437-8ef1-888cc063e626', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9223499b-a617-4861-8758-cb76a32d9d01',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs VA Marauders FC',
  NULL,
  '2025-09-15T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9223499b-a617-4861-8758-cb76a32d9d01',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f5221c80-674c-4365-ab38-d0a68aee6c6e', '9223499b-a617-4861-8758-cb76a32d9d01', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0a9d37e8-eb74-458a-8a9a-f0a6148c2dee',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Grove Soccer United',
  NULL,
  '2025-09-21T23:00:00.000Z',
  'faf62a65-95de-4147-86a9-6df8d866a596',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0a9d37e8-eb74-458a-8a9a-f0a6148c2dee',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('64a5ccc6-4a75-43c2-91d8-81b9288822d6', '0a9d37e8-eb74-458a-8a9a-f0a6148c2dee', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '99b333b9-18da-4bd3-840b-8b2319d6b3f4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Nova FC',
  NULL,
  '2025-09-29T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '99b333b9-18da-4bd3-840b-8b2319d6b3f4',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6beddc32-3d25-4617-a2e6-b69e66aa108c', '99b333b9-18da-4bd3-840b-8b2319d6b3f4', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3dcbf8ac-a2e8-4760-8467-cfb63f1e2fbc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Christos FC',
  NULL,
  '2025-10-06T00:00:00.000Z',
  'cc9a03a9-a8ca-4d71-8c97-83ad883e217c',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3dcbf8ac-a2e8-4760-8467-cfb63f1e2fbc',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('12edece2-8858-4a65-a836-93dd02fd99fe', '3dcbf8ac-a2e8-4760-8467-cfb63f1e2fbc', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd2c24acb-38d3-415c-8e2f-eeb14a231e98',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Wave FC',
  NULL,
  '2025-11-02T23:00:00.000Z',
  '1754a50e-887f-4af8-85cb-7c78685bc800',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd2c24acb-38d3-415c-8e2f-eeb14a231e98',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  10,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26cae85b-6c69-4ead-91aa-57300c57e5b5', 'd2c24acb-38d3-415c-8e2f-eeb14a231e98', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '70ce87e6-5dd7-4302-80fa-e4113825c9fb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Delmarva Thunder',
  NULL,
  '2025-11-08T20:00:00.000Z',
  'dd8597b9-eb35-4fa5-8dca-00765e3415bd',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '70ce87e6-5dd7-4302-80fa-e4113825c9fb',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('07e1c12d-98b9-46ba-963b-abe9fa2b7697', '70ce87e6-5dd7-4302-80fa-e4113825c9fb', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0c482758-b457-48a1-87b7-754e85eeec2f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Grove Soccer United',
  NULL,
  '2025-11-16T19:00:00.000Z',
  '2bc6d4bc-48e6-4c74-8abd-cdc8a8bef400',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0c482758-b457-48a1-87b7-754e85eeec2f',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('7e52f960-1965-40ce-999d-159126875b60', '0c482758-b457-48a1-87b7-754e85eeec2f', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c43ca74e-44ad-476a-8921-036805af2bc0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs PFA EPSL',
  NULL,
  '2025-12-07T22:00:00.000Z',
  'b09fe85f-928b-4150-8847-98fe8e951eb7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c43ca74e-44ad-476a-8921-036805af2bc0',
  NULL,
  'ec459901-be4c-4586-8296-a0ca018b0759',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b972b7e0-7778-4a7a-8ffb-bd2c3e5290d9', 'c43ca74e-44ad-476a-8921-036805af2bc0', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7f808227-8b9a-49a3-8546-6d8d19c66001',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Alliance SC',
  NULL,
  '2025-09-21T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7f808227-8b9a-49a3-8546-6d8d19c66001',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2fff0e46-e6c1-4826-8c6a-270d12cdb9db', '7f808227-8b9a-49a3-8546-6d8d19c66001', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0e860a7a-ae6b-4e55-899f-96ec5a7bb6ac',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Prima FC',
  NULL,
  '2025-09-28T13:00:00.000Z',
  '6fe49222-2084-4f44-8c0a-e9bd14f0bf40',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0e860a7a-ae6b-4e55-899f-96ec5a7bb6ac',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('4f51d173-1f17-4e2d-95b2-f32916801948', '0e860a7a-ae6b-4e55-899f-96ec5a7bb6ac', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f67491f3-d30a-4842-805b-411d99f361ee',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Majestic SC',
  NULL,
  '2025-10-05T13:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f67491f3-d30a-4842-805b-411d99f361ee',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1f3b68fc-f244-48ad-bc7d-73f40183c627', 'f67491f3-d30a-4842-805b-411d99f361ee', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '08cb5033-bc10-4180-8f40-940b4dd1ac39',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Buckhead SC',
  NULL,
  '2025-10-12T13:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '08cb5033-bc10-4180-8f40-940b4dd1ac39',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b9c3fb4f-335e-4e6f-91ce-7cfa05a6e546', '08cb5033-bc10-4180-8f40-940b4dd1ac39', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1464070c-2fb2-44f6-8c60-0bb415fce44c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs SC Gwinnett',
  NULL,
  '2025-10-26T21:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1464070c-2fb2-44f6-8c60-0bb415fce44c',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c83fe76b-9ec7-4e61-a263-cd2f95e36d26', '1464070c-2fb2-44f6-8c60-0bb415fce44c', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '91dcb708-a0a2-4f46-830a-833660e5b998',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Peachtree FC',
  NULL,
  '2025-11-09T14:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '91dcb708-a0a2-4f46-830a-833660e5b998',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  7,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6cdef6cb-5295-45a4-b9e5-7f31276ccd67', '91dcb708-a0a2-4f46-830a-833660e5b998', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3740c914-8948-4f5d-840b-3533f61c5535',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Lithonia City FC',
  NULL,
  '2025-11-16T14:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '3740c914-8948-4f5d-840b-3533f61c5535',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('12476711-2f57-4b29-a61c-999351622d49', '3740c914-8948-4f5d-840b-3533f61c5535', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '33d2bbfa-6e2a-48b5-8e41-92c5d88b9bc7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Bel Calcio FC',
  NULL,
  '2025-11-23T14:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '33d2bbfa-6e2a-48b5-8e41-92c5d88b9bc7',
  NULL,
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b231da72-1e5b-4bca-9824-bdef52479d95', '33d2bbfa-6e2a-48b5-8e41-92c5d88b9bc7', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c0540918-a15f-46aa-8e16-ff01c2c1799d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Terminus FC',
  NULL,
  '2025-09-28T13:00:00.000Z',
  '6fe49222-2084-4f44-8c0a-e9bd14f0bf40',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c0540918-a15f-46aa-8e16-ff01c2c1799d',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('11057dc9-1c83-4101-9d4e-5848da064c30', 'c0540918-a15f-46aa-8e16-ff01c2c1799d', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cc47a121-3ee6-4a0e-847e-08984b5dc896',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Alliance SC',
  NULL,
  '2025-10-05T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cc47a121-3ee6-4a0e-847e-08984b5dc896',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  6,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('2681fd92-fbf6-49c0-9f62-e0948a2aba43', 'cc47a121-3ee6-4a0e-847e-08984b5dc896', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1f4ee96e-b212-4093-83e8-fe3dda6c7853',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Buckhead SC',
  NULL,
  '2025-10-19T16:30:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1f4ee96e-b212-4093-83e8-fe3dda6c7853',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('781acd1d-f4e3-4c00-9f40-0c8874f6b02d', '1f4ee96e-b212-4093-83e8-fe3dda6c7853', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'e6195fe2-dbda-4c25-87ab-ea9641f2d6cf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs SC Gwinnett',
  NULL,
  '2025-11-09T21:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'e6195fe2-dbda-4c25-87ab-ea9641f2d6cf',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  14,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fe719f0e-da2e-419d-b6e2-35d2307bc03f', 'e6195fe2-dbda-4c25-87ab-ea9641f2d6cf', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c563e77c-19c5-4b7a-8e19-5558a0d1aee3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Peachtree FC',
  NULL,
  '2025-11-16T16:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c563e77c-19c5-4b7a-8e19-5558a0d1aee3',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bc5aa58f-8139-4941-8bc1-167950e4ba3e', 'c563e77c-19c5-4b7a-8e19-5558a0d1aee3', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '300f402f-3318-4580-8f60-e05beb6927f1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Lithonia City FC',
  NULL,
  '2025-11-23T19:00:00.000Z',
  'b750ad2c-c142-4a32-84a0-4a9f49437af7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '300f402f-3318-4580-8f60-e05beb6927f1',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ca8ddc66-acbb-44ed-afb3-160e78e601f6', '300f402f-3318-4580-8f60-e05beb6927f1', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '62195179-8e92-4198-8011-c44c91aea058',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Bel Calcio FC',
  NULL,
  '2025-12-07T19:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '62195179-8e92-4198-8011-c44c91aea058',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e4dfface-3879-46a3-a042-954f0e528b86', '62195179-8e92-4198-8011-c44c91aea058', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9b5b38b9-2a22-429f-8a14-96430dc37846',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Majestic SC',
  NULL,
  '2025-12-14T19:00:00.000Z',
  'b750ad2c-c142-4a32-84a0-4a9f49437af7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9b5b38b9-2a22-429f-8a14-96430dc37846',
  NULL,
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('788ae332-dd79-4e18-8ddd-ce6c60e4015d', '9b5b38b9-2a22-429f-8a14-96430dc37846', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fdde1f37-c3f0-478d-885d-873465d5eb2d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Lithonia City FC',
  NULL,
  '2025-09-21T22:00:00.000Z',
  '95f0912d-fa5c-4370-871a-25b2477f97b9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fdde1f37-c3f0-478d-885d-873465d5eb2d',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('85c67bee-58df-4394-a5e3-b0a0e0816b97', 'fdde1f37-c3f0-478d-885d-873465d5eb2d', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '5aedde46-3bb4-41dc-825d-d65eaeaf3518',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Bel Calcio FC',
  NULL,
  '2025-09-28T14:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '5aedde46-3bb4-41dc-825d-d65eaeaf3518',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d6ae7ec1-73f2-456e-9f13-60a93ee0c02f', '5aedde46-3bb4-41dc-825d-d65eaeaf3518', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9ffc358d-3d0e-4ddc-874c-63545f20cc6b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Terminus FC',
  NULL,
  '2025-10-05T13:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9ffc358d-3d0e-4ddc-874c-63545f20cc6b',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('9e1a6a3a-264d-45e0-a322-16e2cdf7d8ea', '9ffc358d-3d0e-4ddc-874c-63545f20cc6b', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '07b85f41-8fa0-4378-8b96-ac4ef92024cd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Alliance SC',
  NULL,
  '2025-10-19T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '07b85f41-8fa0-4378-8b96-ac4ef92024cd',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('e2cdac3c-7a25-41cb-b70e-23bcb100f807', '07b85f41-8fa0-4378-8b96-ac4ef92024cd', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fb6550ed-e94f-47ac-828a-c6b1a3fca28f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Buckhead SC',
  NULL,
  '2025-10-26T14:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fb6550ed-e94f-47ac-828a-c6b1a3fca28f',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('52738a7f-b344-452e-8a25-b69a5a5f0c83', 'fb6550ed-e94f-47ac-828a-c6b1a3fca28f', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6f8ef26c-81fc-4ffe-87da-fbdb959a32fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs SC Gwinnett',
  NULL,
  '2025-11-16T15:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6f8ef26c-81fc-4ffe-87da-fbdb959a32fc',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  18,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('fa716636-66c2-4231-8761-27bd9e442fe9', '6f8ef26c-81fc-4ffe-87da-fbdb959a32fc', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8c3b039c-3784-4bcf-83c1-21374d9fec62',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Peachtree FC',
  NULL,
  '2025-11-23T15:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8c3b039c-3784-4bcf-83c1-21374d9fec62',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('75e8f4a7-68b7-4bdf-b2dc-a83899af494c', '8c3b039c-3784-4bcf-83c1-21374d9fec62', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '7d2fb269-679f-4a27-8e73-18da3fbdaeee',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Prima FC',
  NULL,
  '2025-12-14T19:00:00.000Z',
  'b750ad2c-c142-4a32-84a0-4a9f49437af7',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '7d2fb269-679f-4a27-8e73-18da3fbdaeee',
  NULL,
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6901f425-280a-4fb0-bd23-6960344c4b53', '7d2fb269-679f-4a27-8e73-18da3fbdaeee', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd5e48b57-1b1b-4a88-8933-db136a326fd8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Buckhead SC',
  NULL,
  '2025-09-21T17:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd5e48b57-1b1b-4a88-8933-db136a326fd8',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('082ab3e6-c820-41c7-817b-b70d77f5d32b', 'd5e48b57-1b1b-4a88-8933-db136a326fd8', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'fb8893bc-e654-46a4-893a-c9c5290222af',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs SC Gwinnett',
  NULL,
  '2025-10-05T21:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'fb8893bc-e654-46a4-893a-c9c5290222af',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  12,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5ce56ed8-73c9-43a9-8b34-983566662577', 'fb8893bc-e654-46a4-893a-c9c5290222af', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '48c4b3c7-bab2-4ab9-8c5a-d0d0e531d191',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Alliance SC',
  NULL,
  '2025-10-12T15:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '48c4b3c7-bab2-4ab9-8c5a-d0d0e531d191',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  9,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f002fd41-2eb9-450b-888b-23d94d1f965f', '48c4b3c7-bab2-4ab9-8c5a-d0d0e531d191', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1bc9d4ee-b4a9-435d-8526-9be21568f613',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Lithonia City FC',
  NULL,
  '2025-10-19T22:00:00.000Z',
  '95f0912d-fa5c-4370-871a-25b2477f97b9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1bc9d4ee-b4a9-435d-8526-9be21568f613',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('39624e8e-b46a-450d-b9f8-efb6c3e51bf7', '1bc9d4ee-b4a9-435d-8526-9be21568f613', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c716e8b8-7a44-4dd7-8362-ad60cc30c2da',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Bel Calcio FC',
  NULL,
  '2025-10-26T15:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c716e8b8-7a44-4dd7-8362-ad60cc30c2da',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ff392269-1204-452f-a8d3-fc1851406582', 'c716e8b8-7a44-4dd7-8362-ad60cc30c2da', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '82a75797-65ec-4cc6-8c67-4947f6dc2388',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Terminus FC',
  NULL,
  '2025-11-09T14:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '82a75797-65ec-4cc6-8c67-4947f6dc2388',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('91cef2cf-0ea6-4d4f-b9f2-fbbe40b9185d', '82a75797-65ec-4cc6-8c67-4947f6dc2388', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '01aca96c-41bf-450d-816f-e1a46fd4b7d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Prima FC',
  NULL,
  '2025-11-16T16:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '01aca96c-41bf-450d-816f-e1a46fd4b7d0',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0bd4b2da-0c93-4d81-b267-46b41340938c', '01aca96c-41bf-450d-816f-e1a46fd4b7d0', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '45f617f5-79c5-40ee-8c75-079c38b6753d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Majestic SC',
  NULL,
  '2025-11-23T15:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '45f617f5-79c5-40ee-8c75-079c38b6753d',
  NULL,
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8ab65062-04ec-49aa-8fbb-7bd4080e9dcb', '45f617f5-79c5-40ee-8c75-079c38b6753d', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'dc56c4d1-ce11-4efc-8010-9f0076ae5b47',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Majestic SC',
  NULL,
  '2025-09-28T14:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'dc56c4d1-ce11-4efc-8010-9f0076ae5b47',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('0cdb98bc-5464-4d9e-bc4a-862a6bd3ff88', 'dc56c4d1-ce11-4efc-8010-9f0076ae5b47', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0682f9f9-cd83-4dfd-85db-20c1936cdc1b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Buckhead SC',
  NULL,
  '2025-10-05T17:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0682f9f9-cd83-4dfd-85db-20c1936cdc1b',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ee6df154-068f-4866-b050-4c647e5f557b', '0682f9f9-cd83-4dfd-85db-20c1936cdc1b', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '56fda2d5-6836-451b-82b5-8cdf1356615a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs SC Gwinnett',
  NULL,
  '2025-10-19T18:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '56fda2d5-6836-451b-82b5-8cdf1356615a',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  8,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('b78d8e43-30bd-4fc4-8fc7-4094ccdf9379', '56fda2d5-6836-451b-82b5-8cdf1356615a', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '40a5a544-1502-43bf-8f34-3379fa85931d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Peachtree FC',
  NULL,
  '2025-10-26T15:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '40a5a544-1502-43bf-8f34-3379fa85931d',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('1f9ba4e4-bb68-4f1e-8c77-ceced0b67fbb', '40a5a544-1502-43bf-8f34-3379fa85931d', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '44f35138-d986-4629-8863-4dd558b06578',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Lithonia City FC',
  NULL,
  '2025-11-09T19:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '44f35138-d986-4629-8863-4dd558b06578',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('f0a06de6-83cf-4102-ac83-dc3d89b1ffba', '44f35138-d986-4629-8863-4dd558b06578', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd68d2610-db40-4ed5-8891-8ec3065bcc99',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Alliance SC',
  NULL,
  '2025-11-16T19:30:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd68d2610-db40-4ed5-8891-8ec3065bcc99',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cedca96c-3b2d-4597-8bb4-b114d0fed12f', 'd68d2610-db40-4ed5-8891-8ec3065bcc99', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '405a83ca-2690-4ae7-8e9d-ced974cbb442',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Terminus FC',
  NULL,
  '2025-11-23T14:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '405a83ca-2690-4ae7-8e9d-ced974cbb442',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('c7080aaa-99e4-4447-a263-1531f06ad5a7', '405a83ca-2690-4ae7-8e9d-ced974cbb442', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c20ff445-1db8-4381-855b-79ec7088cc34',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Prima FC',
  NULL,
  '2025-12-07T19:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c20ff445-1db8-4381-855b-79ec7088cc34',
  NULL,
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('6c21687c-a4f6-42e7-b5f6-48f10b86a307', 'c20ff445-1db8-4381-855b-79ec7088cc34', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'f50c0c3f-9b35-4d26-8cf7-9a2fc15f8cd9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Peachtree FC',
  NULL,
  '2025-09-21T17:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'f50c0c3f-9b35-4d26-8cf7-9a2fc15f8cd9',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3583dcfb-fd19-48d4-89ed-a5d979ae67ae', 'f50c0c3f-9b35-4d26-8cf7-9a2fc15f8cd9', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '94fd6594-ad9c-4993-8d2f-3a8774a432f6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Lithonia City FC',
  NULL,
  '2025-09-28T22:00:00.000Z',
  '95f0912d-fa5c-4370-871a-25b2477f97b9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '94fd6594-ad9c-4993-8d2f-3a8774a432f6',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26296890-f496-48f9-9c81-1830fc64265b', '94fd6594-ad9c-4993-8d2f-3a8774a432f6', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '862e9630-7aba-4a1a-8327-f4127c446c9d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Bel Calcio FC',
  NULL,
  '2025-10-05T17:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '862e9630-7aba-4a1a-8327-f4127c446c9d',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3af133ca-f674-4943-a768-2bbf3fb71cdd', '862e9630-7aba-4a1a-8327-f4127c446c9d', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '85efc97e-2887-410a-8581-4964a62e8546',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Terminus FC',
  NULL,
  '2025-10-12T13:00:00.000Z',
  'c00abb6f-6ae2-4eab-8c51-99cbabb06b3e',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '85efc97e-2887-410a-8581-4964a62e8546',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('cd6f8bcd-706e-472e-a928-e1402f207e86', '85efc97e-2887-410a-8581-4964a62e8546', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'd5636064-ee89-4761-81d4-f793bdb26764',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Prima FC',
  NULL,
  '2025-10-19T16:30:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'd5636064-ee89-4761-81d4-f793bdb26764',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('23cc044f-580d-4d79-8fb4-42bb438d5ed6', 'd5636064-ee89-4761-81d4-f793bdb26764', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cb3664af-c00a-4e09-8ee0-8a54757ea440',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Majestic SC',
  NULL,
  '2025-10-26T14:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cb3664af-c00a-4e09-8ee0-8a54757ea440',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('06a9fed5-a366-48fa-8308-ee5160065479', 'cb3664af-c00a-4e09-8ee0-8a54757ea440', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8fbb86d1-5e96-4562-8a5c-a07ea764f4cf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Alliance SC',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '8fbb86d1-5e96-4562-8a5c-a07ea764f4cf',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5d0d2cb0-a7d3-41ac-9dff-15afbee7d7a0', '8fbb86d1-5e96-4562-8a5c-a07ea764f4cf', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'cc48989d-250a-48e5-81df-77dca4145624',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs SC Gwinnett',
  NULL,
  '2025-11-23T18:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'cc48989d-250a-48e5-81df-77dca4145624',
  NULL,
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  13,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('386db2a7-2746-43ef-8e77-cf3925d8554d', 'cc48989d-250a-48e5-81df-77dca4145624', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1cb328bc-eef4-4468-8094-3cf707aeb204',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Terminus FC',
  NULL,
  '2025-09-21T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1cb328bc-eef4-4468-8094-3cf707aeb204',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  3,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('3f91ff01-be1f-4308-b9a0-afe83591027d', '1cb328bc-eef4-4468-8094-3cf707aeb204', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '41caed55-57b8-49b7-8dfb-71c06aa71e24',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs SC Gwinnett',
  NULL,
  '2025-09-28T19:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '41caed55-57b8-49b7-8dfb-71c06aa71e24',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  5,
  1,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bd53f1b3-76d1-4150-91df-28215156f1fa', '41caed55-57b8-49b7-8dfb-71c06aa71e24', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4d0b9300-468c-4c5f-8732-195a83d0c178',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Prima FC',
  NULL,
  '2025-10-05T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4d0b9300-468c-4c5f-8732-195a83d0c178',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  6,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ec60b84f-5304-430d-8748-8c7621df5b60', '4d0b9300-468c-4c5f-8732-195a83d0c178', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '628b2d64-3adf-4cf7-8d69-40f16d8a50a0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Peachtree FC',
  NULL,
  '2025-10-12T15:00:00.000Z',
  '20f5b568-b92e-4133-8f89-2b5f4823e4ab',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '628b2d64-3adf-4cf7-8d69-40f16d8a50a0',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  9,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('d063f2c4-e8fc-44ad-9d4c-4864a0b7729c', '628b2d64-3adf-4cf7-8d69-40f16d8a50a0', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '21cbae42-2ac1-43a7-8e2c-d036be7b765e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Majestic SC',
  NULL,
  '2025-10-19T22:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '21cbae42-2ac1-43a7-8e2c-d036be7b765e',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  2,
  4,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ef574ee5-0a30-421f-bc02-f19a2cbda83d', '21cbae42-2ac1-43a7-8e2c-d036be7b765e', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '25579a5d-3c48-4f82-87d2-b100ebc6efca',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Lithonia City FC',
  NULL,
  '2025-10-26T22:00:00.000Z',
  '95f0912d-fa5c-4370-871a-25b2477f97b9',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '25579a5d-3c48-4f82-87d2-b100ebc6efca',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('5ec05e14-083f-4152-a7c5-3a905953ef6a', '25579a5d-3c48-4f82-87d2-b100ebc6efca', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '981839ad-6c40-4269-8b9f-f58f5b161915',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Buckhead SC',
  NULL,
  '2025-11-09T23:00:00.000Z',
  '5e5cb8d5-e8cd-43aa-897c-ecc3d9364d49',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '981839ad-6c40-4269-8b9f-f58f5b161915',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  3,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('41615e17-5a5d-4ea0-9b6c-efe25633fb7e', '981839ad-6c40-4269-8b9f-f58f5b161915', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '6ddaae61-dd8f-4762-8743-1bdfc5c3d84e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Bel Calcio FC',
  NULL,
  '2025-11-16T19:30:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '6ddaae61-dd8f-4762-8743-1bdfc5c3d84e',
  NULL,
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  '550e8400-e29b-41d4-a716-446655440801',
  4,
  2,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('bead9752-3adb-4984-8b9e-a025f2786f38', '6ddaae61-dd8f-4762-8743-1bdfc5c3d84e', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '9c39796a-4653-4ca7-81ba-eb23cafde892',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Alliance SC',
  NULL,
  '2025-09-28T19:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '9c39796a-4653-4ca7-81ba-eb23cafde892',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  1,
  5,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('26efd61e-79d7-414f-9359-bd71408c2c63', '9c39796a-4653-4ca7-81ba-eb23cafde892', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '1c4f607d-655a-4ec8-801d-813aa877b021',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Peachtree FC',
  NULL,
  '2025-10-05T21:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '1c4f607d-655a-4ec8-801d-813aa877b021',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  12,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('75442547-e4da-47ad-9e00-efde7117bbeb', '1c4f607d-655a-4ec8-801d-813aa877b021', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'a3cb1ffd-9207-4e5a-8a3f-103a110d15b2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Lithonia City FC',
  NULL,
  '2025-10-12T19:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'a3cb1ffd-9207-4e5a-8a3f-103a110d15b2',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
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

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('791b8fbb-c77c-4317-ad7f-5dca1792a5cf', 'a3cb1ffd-9207-4e5a-8a3f-103a110d15b2', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '766c1937-33f7-499c-8cc1-400d7dc5468f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Bel Calcio FC',
  NULL,
  '2025-10-19T18:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '766c1937-33f7-499c-8cc1-400d7dc5468f',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  8,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('ff489b65-506f-4442-b109-9467e4d52191', '766c1937-33f7-499c-8cc1-400d7dc5468f', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '19a978a9-994c-46bb-81bc-2d25ba975417',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Terminus FC',
  NULL,
  '2025-10-26T21:00:00.000Z',
  '9ba510e8-559c-4e71-81b8-9318e4dc1e29',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '19a978a9-994c-46bb-81bc-2d25ba975417',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  7,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('8d54dc72-0dca-49fc-b2cd-7991505cd50c', '19a978a9-994c-46bb-81bc-2d25ba975417', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '06b48914-a8be-4c35-86ee-f13de91faebf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Prima FC',
  NULL,
  '2025-11-09T21:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '06b48914-a8be-4c35-86ee-f13de91faebf',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  14,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('70140dd6-14d6-4d50-8c3f-083d8d94369c', '06b48914-a8be-4c35-86ee-f13de91faebf', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '76f6a17e-98ec-4afb-8198-20a3a37596ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Majestic SC',
  NULL,
  '2025-11-16T15:00:00.000Z',
  'cd06c6a1-2ada-4299-8ed3-b105c0e25987',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '76f6a17e-98ec-4afb-8198-20a3a37596ea',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  18,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('19325478-21be-4e21-b7a7-146b0294b423', '76f6a17e-98ec-4afb-8198-20a3a37596ea', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;,
  INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '585202d6-ada8-4b28-8ccf-8b928dc30117',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Buckhead SC',
  NULL,
  '2025-11-23T18:00:00.000Z',
  '8915a509-c940-4280-86ac-67336ae8b5fc',
  NULL,
  false,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '585202d6-ada8-4b28-8ccf-8b928dc30117',
  NULL,
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  '550e8400-e29b-41d4-a716-446655440801',
  13,
  NULL,
  'completed',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;

INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
  ('28891a76-b87b-43e6-bb4e-d5cc96025a63', '585202d6-ada8-4b28-8ccf-8b928dc30117', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
ON CONFLICT (id) DO NOTHING;
ON CONFLICT (id) DO UPDATE SET
  event_id = EXCLUDED.event_id,
  title = EXCLUDED.title,
  event_type_id = EXCLUDED.event_type_id,
  event_date = EXCLUDED.event_date,
  duration_minutes = EXCLUDED.duration_minutes,
  venue_id = EXCLUDED.venue_id,
  description = EXCLUDED.description,
  created_by = EXCLUDED.created_by,
  external_event_id = EXCLUDED.external_event_id,
  cancelled = EXCLUDED.cancelled,
  cancellation_reason = EXCLUDED.cancellation_reason,
  updated_at = EXCLUDED.updated_at,
  home_team_id = EXCLUDED.home_team_id,
  away_team_id = EXCLUDED.away_team_id,
  home_away_status_id = EXCLUDED.home_away_status_id,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status,
  competition_name = EXCLUDED.competition_name,
  competition_round = EXCLUDED.competition_round
;

