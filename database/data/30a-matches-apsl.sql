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
  ('891c4551-7015-448a-abad-bcd622c62b50', '1f416b10-a260-431c-834a-e4fe84e4644c', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('26baf5b1-db38-4119-9df4-53725e65e436', '449b6087-e020-4191-88d4-b691274fe05d', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('482be49f-76ad-41cb-88b5-4b24524e65f0', '8cec13fe-ae6f-4801-8038-0ea910621545', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('95bb6690-f0d4-464e-9160-f487e3fd050b', '56c57180-23d6-435e-8bae-093a9e6b858e', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6ff7c70a-eeaa-4b7f-ac44-c072d04416a4', '4dbd7acb-4e9b-4ac5-8ecc-4251d218cf53', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dddf66c3-037d-4a3c-b469-f8a8e70d264c', 'ecc56ef1-df94-4eb3-8aa8-0595450e3823', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8c4cf02b-a8a8-4a68-99de-304bc09f4c9e', '177f0885-6a3d-4b96-8738-8459f94d3814', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('990a0775-bc4f-48ea-a8b4-885f17ad03a9', '31d0e2b0-f1b8-4b7c-8757-f59727425d8a', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('50ee6f80-5109-4f3f-93c4-acc7e1e0d055', 'c179ba09-d16b-4492-890f-138b260d593f', 'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f1a9885d-cc21-48d5-84f7-44dfd63e60cc', '7b749306-1fb3-4b30-89a9-60e40ec9da43', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('34c18d31-f619-4277-98e4-27bf755e60eb', '18473423-df44-4c59-81fa-621cad15a47b', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7341cfc3-cb6a-46eb-93f4-5528c3123a22', '35f30df7-28d0-435e-8cf8-b0b887b68f34', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('45d387aa-fd25-44a9-a3f2-352071e5e7f5', '5a9c5176-109d-4f82-85e5-9b4f1ec043ea', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bfe43db7-5a43-4e34-9583-c3ae6cea0da7', '65ff8f4a-751b-461b-8775-954fc3e96bb5', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f352a98d-b1a2-44fc-96fa-33777f5b1aaf', '9f3bff6c-c01d-436e-83ee-909ba9c3aa67', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('23383e9e-ac68-47dd-9a71-e679e32caad9', 'd2f916b2-7dfa-4203-820c-d360a3cfd4ad', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('47d02013-f429-4d70-9cd1-2c06275226e7', '49c35565-fffe-43a2-86fb-c43ffead2085', '8a804c82-814c-4a90-856b-441236c695ed', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6836ae0a-333e-45fb-a163-69b434cf7f59', '7f057a54-a9f4-4f23-86f2-9b63070c55e5', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8a32352b-3304-495f-be34-3f477fec5cfb', '1f6db006-8277-44e6-86e2-cb9e54563239', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ae3ca408-cfd6-4239-aed9-bbae4caf6908', '61b592c1-525b-4f72-8ed8-b841a17c55d0', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c4d36862-6eb3-4c56-bbb1-fd3342aed592', 'f8368656-ca81-4cb1-873d-25e2d556d485', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('743e597a-8f10-4473-8523-6afd0e661e73', 'edd08e8b-3e53-4041-8a98-437944dea4a4', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('87dbd858-a887-48ae-ae75-cdcc41aa2932', '6689f8ff-594c-478a-8b33-5f41baa352f3', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fe5f4cf2-def5-41a6-893a-d1973be37185', 'd9ce3a96-b0b2-44f2-84ed-1fbb8244b850', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8078d868-60d9-4673-87e8-c62df5e7a7f1', '0f93e7e9-f3eb-4b95-86d9-57e02e747a50', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dbecca99-a5a7-44b4-827d-c1736aff971a', 'e234e02b-786e-4084-8ee8-fbfaaf8ada2d', '14bb3090-8e24-4cb6-82e6-73fc6fc04278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3129ca10-8d7b-4ba7-8d41-8c03ad76af21', '0b7a53d0-70af-45bc-84c3-d9b28eb8e778', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bab4ec0f-33f8-42ad-b996-6821fc87fe9c', 'a539ef69-793d-4432-8962-49ac5548e38c', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f846cf95-a049-4dc6-8bab-0f6a2806bf8a', 'be592985-c13f-4d81-8cfa-235b0cb37d90', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2c890425-cc09-4b1b-b6c5-b46561b1127c', 'b73ae17a-c079-4d78-827c-6884bb29269b', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3f9f5690-fabb-46cf-8476-adfa9b6a3a49', '90189ec6-e985-45e2-8a8f-8f8f29e6a15c', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9a66a4fe-58d8-46cd-8598-0edfc6fb6615', 'd365afa6-1f99-4575-8608-15bf2983359b', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('69637877-5323-4035-9c4d-2bd77cf9fd68', 'e901c31c-165b-424c-86b6-c2805129e4db', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('664ec46b-8cc7-4914-9b68-5f67325a57b4', '1e4ecae5-cdfd-4fcd-8d1a-96f556ad2d48', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8c0e2b92-7dff-4bfa-8a43-82a98b9fadb9', 'f52a1c06-ff5d-486b-853f-e9e6c7e1b937', 'b23a377a-cf24-46e6-8fb2-09faa87fc064', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2cf4a90e-2a1c-4ca1-9a09-a692ebf32d21', 'afa1a1bb-a3c2-4164-80d4-bdd98c0919ce', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('83d11881-af5b-4d0d-a16f-83c1f1c18882', 'd301c767-ecc0-4576-8f10-2cc087f3dde6', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('09658b20-99f5-46e2-bf21-d91348a036f1', '471c6d0d-7f80-4de1-8ca5-558a0be8cd11', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c258f305-ae04-461a-9fc3-1c46cd00fc43', 'd97e2da2-d1b2-4106-80b5-f362dacfe7a0', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('47766691-a4f0-4cda-9bc5-3c8532fd7af7', '9b98df9c-b56f-4c5d-8c8a-436918d3ecfe', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cb4fdb61-6b6e-458a-a45c-3a080ed94a63', 'efa207df-aa48-4129-82f8-95176a3c6616', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b43eea38-47df-47ef-bec7-e950ee91f932', 'e6b59e45-d630-4f0d-8ece-8f49e5c26ff6', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('92a03cc6-d430-4594-99bf-530b9b8c019b', 'a78b3c5e-4839-41b2-8a22-54f30a4604aa', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bd09c864-13f8-4879-9e1f-697b9c6367e3', '4eb2803d-f1ad-4d5f-8819-3827a6e085f0', '5330ce61-ccc0-4d8e-8a2b-7b092655c952', '550e8400-e29b-41d4-a716-446655440701')
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
  ('245869d3-cdca-4727-8975-03a9af0e0940', '3be9c444-42f3-436e-8bde-8b3551f0d989', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7ee57a04-ab9f-416a-a6dd-9416b48f9027', 'bb0c0a77-2969-45ec-8041-ea7fafaf959f', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e400cf11-58c9-4524-b673-101146e20c65', '5d1f8ecf-952c-4d0f-805b-1bbb8c86526c', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('51250ddf-e3a1-4214-9f35-254fe0370a97', 'ef8b0bf3-6c30-4ad6-8107-6e6e5db76598', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b3aea139-524e-4fd2-9a7f-7e9ff52089dd', '5fe39844-d731-41f3-8a4a-198a97ca20e7', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dc54fb53-8d1a-45e0-8c72-8424e484cc10', 'cc2b0bd1-42df-44e7-853a-22065325d422', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f0018879-2a31-4d11-9020-dc7b1d36020d', '37a3737d-d106-426f-8cdf-c7d87ce8c685', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('24e1a0bd-e013-46ed-866c-8bb14f6b6c31', '3fdb6a6a-f4e5-464d-85f4-d481c0a97061', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4e840ca1-68ac-4fcd-a77d-14baf0308f4f', 'bffad959-3eab-4137-8426-94721f625634', '272b83b4-1153-402d-8a47-015cb13cd376', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4ad35914-f40a-46ec-a023-2b00d08bb34b', '08a63cb0-808a-48fa-875a-6ffed43371b1', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b736cbf6-5233-4572-87a6-ed4f910baa65', '5913597a-a16b-4d45-8def-8306446bd0c7', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2f9c8062-5b56-4f3b-ba13-b61239abc918', '04ce9ef2-8739-4717-8b18-2732142a6633', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('67258060-0fe8-4679-90b2-1e20b0a5ac77', 'c5bf91e7-d173-4afc-857e-22d7ef1a783a', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('acc0ea2e-0598-4a6c-8dd4-4c2b189bbecf', '7e501e9d-32c1-4206-8168-53c6ca6d0bf4', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('35fdf4fa-2700-45e4-be89-55024f092567', '635b270d-dfff-49df-8f7e-9f83aa4dff3e', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e2773b17-cc8f-4e1c-ae44-a5b823cbbff7', 'ab205bbb-0602-46c8-8317-ff4221a1cdf2', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3137546b-2efc-4350-9159-075f3ea927d9', 'aae45895-aa67-4d40-8c6a-b64aad4b24c3', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440701')
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
  ('18f89b99-3577-4de3-9fb4-43f5b3527071', '92346dd9-c078-459c-851f-084a6c5268cb', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('02bd846c-dad3-4f27-9660-8e05443786bb', 'fb0d3a40-1876-4ae3-8169-6faee5589ba7', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ae81401d-4284-4055-8447-4432d9c8432c', '2ec19fd1-2b32-487d-8b7f-aa52463f1af4', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c5fd9d72-b038-4beb-922a-800d0be4bd66', 'b5a3a8c5-7f7f-47b9-8ebf-720785a1093a', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c4f76cd8-4ce6-4bd6-b85e-bc28945de762', '947f3b67-ee12-4221-8a5f-92bd1a53068d', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('15b405f2-b459-4e43-b7eb-0645729449a7', 'c2817f70-949e-4082-8a6d-e375fc048560', 'b67749bd-3006-4977-81db-c16e5c10143c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cc434a09-65d2-4dfb-9443-f41f3fbba95a', '95a67d82-637b-4376-8cee-34af118c23f7', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1904e73b-7326-49f3-8520-4b409987c744', '9faf01aa-2ed9-4bd9-87e1-1c2cfba48e1e', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aa175fb4-b0d2-4bd7-8f7c-97fc1a2b59e0', 'f5405daa-2cf5-47e9-89b5-916c96529540', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fd9b9e90-842a-4b7b-8941-16dcb5122bf2', '866d83aa-f32d-4afb-8db6-122031d958dd', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bba74114-5d53-422e-8ba6-91a297449138', '820c6943-27ad-4a8a-8d94-487028b52370', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7c364a62-cf87-44eb-81ec-a4eed927a6e9', 'fd13b4b6-25c1-4660-86c0-255776167608', '5d045d5d-e0de-4bf1-803a-3a751a0bd108', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2417e10d-7649-4dc6-9a6a-34ee2c1921e0', '716d5363-bb66-4fe1-8464-c47d2e951a86', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5e7bf293-f32d-4ece-b59d-1141858a9acd', 'a3766a72-7ff1-453f-89d9-a9481e1c8c36', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bcf0af3d-0f22-45ab-8db4-370adc443f97', '57d38fdb-1541-42e9-8c91-a42b43fb01ea', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7b2d28f6-f892-49dd-8669-cc932df77645', 'b09392ac-a20b-4ab6-8271-2eda67850246', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f56f7aa8-1604-446f-ad50-43b339b78a9a', 'c0e65e14-e9f8-4d87-819a-37786b3c9347', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('94b709d5-049c-4eb7-b02f-a3b3d2c8094b', 'e257683f-bee6-49b7-883c-8ba755719abd', 'f98df7c4-dd4b-47e7-86ed-6221c02b28a3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('89b6ba63-01b0-48ab-b777-af405a295b04', 'bf717ec4-11e7-40b6-81f8-1788c30f549e', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b11be5a6-a5b4-402c-999e-689ffac0245d', '2971250f-9d16-41b7-83d6-dffd12ec3b0a', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9df9fa6f-f2ba-4e17-a876-b70f489e76d2', '3aba5895-f105-4fbc-815a-ac7f47c76f9c', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d6e9fd71-2051-41be-a286-a3ed1b77137f', '2f9e064b-4c75-4552-8ef7-3a3a5db190a2', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('03a2d8fe-7b7a-4d2c-880d-63b58b75dfea', '7355fc03-e3cb-45bd-80a8-fde40d88f0a2', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('851f4197-0e42-49ef-bc4b-84cabe10f1e0', '444721d0-db3f-4ec8-838f-d8f448f1c4fa', '78550a78-2da7-4ad0-8dff-8ca3ae1446ea', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8614d7a9-e6cd-46f9-9e63-8bb0c1b83f60', '22902313-1b23-4a0d-85a9-38d963b24fdf', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('002207f0-69a6-4245-a3c1-40e260a5bd90', 'bf2ba0e1-54bc-46bd-8e38-a293524add85', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('79c0d62b-7826-4104-8935-17d1f9608aff', '9af809f3-8cb4-4235-873f-c1b2f6fd7a99', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a4c40d7a-71e7-473e-b925-3ba9705363c1', '61df792f-a023-46ec-88f3-f427c3595c58', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('28b3b0ef-1da8-46cc-b5a2-2b157556cffa', '770a13f1-15c6-4c84-81db-629343e1bd0d', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b3efbc32-90d6-47de-ab9d-6dbd7cbb1fa0', 'c379c330-ba1c-4357-8c64-62023ba2d2fb', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b0fda912-eeb9-40ff-ae45-3001c780f3f1', 'f92d6fa5-dda1-4723-8622-2dab514ee440', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('474fedc4-601d-4393-8ab8-71c0d52cff1f', '09c857eb-42d6-40bd-82f7-63418d3b685a', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1223c93e-dd54-48db-9438-cbd0c6e6f82a', 'e821e14e-41cc-4fe9-850a-b4a46a208d23', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2f670056-c7af-421a-ac73-3d2dd77aadd3', 'beba0dcf-183d-40b9-8ab9-f686ceef7017', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2e93a522-91da-4853-83db-e551a5334370', '4c7d9483-8519-4937-89ba-9abb354da2e8', '05ec5303-e217-4602-8c03-06fb02c3c083', '550e8400-e29b-41d4-a716-446655440701')
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
  ('daf18c2c-d4ff-4bda-9553-975735db5638', 'b853e310-9d5b-4af3-8820-2874065c8934', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4b242e38-057b-48b0-9161-ca520acbe88e', '223e44cc-0833-4a0e-80bf-e4ae5bcab2fe', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6bbf6e21-7f15-473c-8baf-8457d91c829c', '524f20af-1e0a-4102-8013-11648e5fe96a', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8d6ef5bd-7226-4e45-b25f-d7c0d6903f32', 'f8b0d394-472f-4268-8cd1-8adaebf85bb9', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('74204f27-0da2-43b2-9036-60f97955a845', '2b900d7c-d692-40d2-8f41-ba29829f0161', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e933df93-36d4-4041-b746-11117459a4fd', '01c83a39-2baf-4c92-8fb2-33ccd333a1e8', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6b0002b0-173b-4c98-82d6-b274ee73ee04', '93b3465d-97e4-487c-898a-680a1fbe6586', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9a2ed9d8-9369-4bd9-a95c-d08efd3bc9a2', '1b694658-0235-434a-80e9-c993a7e9d001', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c010b9c6-3a5f-4ebd-bf99-83d52d048a0c', '5e0f8e22-c56f-4d2b-8259-6ce23a40127c', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0956c6c5-22c9-4b18-ba3f-f49fa4b69cb8', '7fe14c5b-b005-43d3-8de7-946ab148eb6a', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9555f297-afa7-4d8b-ba3d-e4f75297cfda', 'ea337c0f-4571-4ba7-812f-c2ac917723af', '1ab54f95-8510-412c-8d6e-c203ee8cd727', '550e8400-e29b-41d4-a716-446655440701')
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
  ('65989701-2dda-4e45-a3b3-cb70ffd10b7d', '1411d826-dbec-4681-8a6e-108e9549402e', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f546ca75-baef-4957-8e1d-5c546a06a09a', '8fcb2850-9cf5-4729-85e3-1c85e82652fc', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3ee3745b-0bdc-47ba-b076-d1752b672b26', '53d6e723-3685-469d-8c33-61b2b2987089', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('175900f9-485d-4520-8550-7a3ff515a92f', '7a3721d0-899f-4db5-8cf6-0d3428a0399a', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dffbc137-d052-419f-bb1e-725a7a721cca', '966aabe0-483f-471a-8682-bf7525c2966e', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('21da3475-f9c9-40a8-98c2-05671e058f92', 'cc9ad460-ab3c-4cef-8033-607572d140a2', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d10346c0-f8d9-4c8b-975d-e8546aafc629', '6c7f83b2-5f5c-499f-8608-e92609f55b85', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b321e2c4-8ee5-42e6-a28a-65be9b525d0e', 'f132adc6-0434-44e8-8aa2-ea9a06f0f5fc', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('be3ad9e1-cfd2-4b4f-a517-09ac75f964cf', 'd8f082b9-8955-4efe-80ec-d917cd9c1790', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0a3b09aa-19bc-4a8f-a37a-601da1bc70c5', 'be46bcc0-077e-42a3-8515-390fc052a298', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f6eb3cc8-9443-4f88-9727-a66df74ec8cd', '9c095888-fb6b-425b-85b9-1c67b7ec1d16', '998d8d80-fabe-4b10-83f5-6ad236885249', '550e8400-e29b-41d4-a716-446655440701')
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
  ('05781b4a-6a3c-4785-8b17-60656ebddd3e', '0e1d399c-64bf-4fae-844a-e56fe549c30e', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7d7572a5-6897-4784-9c41-821064dc1b27', 'a6992975-2640-4279-81ed-1c01e92abd34', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('84d25b33-2ad2-431d-b90e-21a78cf12ddc', 'cd98987f-9199-4b12-8648-c42b89ab0f76', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b522c937-f7fd-409b-a25e-76c8e7e7b349', 'ee3d020e-e50d-406b-8870-8684789ab5ff', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ba680122-0b2d-4c34-a4a4-91ef47f1d74b', '13536e07-0eaa-45be-83a3-5b33e97491c2', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f63ad4bd-d891-4228-b367-3e52a617ef49', 'c1a8c8d6-66f7-447a-8a66-d1268e0b2f31', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('64aefd8a-e8ba-4e08-94f2-75b8d77a8e24', '00815dbf-c586-41c0-8bb8-766e96fbd77f', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4979b1a9-960e-495f-939f-bf4b41eb0505', 'ae61ff0b-ac40-4fb1-81d6-6e3acdd6aa14', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('db2a5e7f-415e-47db-93ff-74429edceb31', '999ef2b2-ce9b-43a1-8063-880670f632ff', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('de268c07-3641-491c-a4bf-184d5f459226', '97c68150-5ed3-46f3-8c83-cbe80667bbce', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('be9931c7-a51a-444d-8c50-ed0fd0e3e726', 'f789350c-17b8-49e5-81ae-71ea516428fc', 'c618dc61-7e80-45fc-8879-0dc3ad29a499', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7d55efb8-f59c-4f47-bd8d-201f443384c2', '1a5b4f4c-72ef-475a-8007-df817fc4e553', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3b738a33-572b-449a-a004-369584174c15', 'ce65e7fd-173a-426c-8d6f-ceee7899ffc5', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ea70953e-9ca3-4b25-880d-8325ee367df1', '51d810b3-89b2-46f4-8b72-3bc861eebaaf', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e7748705-4910-4fa1-9224-8394a71ace7d', 'dfb90bbe-1520-4c2a-8457-51e94fef5404', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bfd4514c-878e-444c-9872-091bb0b5f44b', '20c97885-8d40-406c-89e7-4f767bfc03c7', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('99e33ea5-8340-4275-aa42-22666cf7dfa3', '1c874b2c-fe54-436b-8e32-892e79efe585', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4c69343c-2d89-44a1-bb95-e8af2c781769', '20552c62-d1a5-4a5c-8dab-f368cb355204', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8f969d3a-4139-4498-9849-94d727b1a768', '0fce3e01-f29b-4375-8d18-1cf9e288e824', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('026e217c-1185-4001-84fe-370b1fd7868b', 'c2e6ed23-fc42-4af6-859b-bcf2449d87c6', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4fff6b55-6f6b-4227-b524-5c3489287b92', '9facfea4-c369-404b-8767-4b1316ce5588', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bdbb5811-e755-4df1-b3cd-df6c8127e89b', '70131a82-bfa5-4ebd-82d2-a3b1fed7ff2a', 'b59f4742-28b4-46db-8a70-f819f7935278', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1a429d0d-03f2-4b8a-b67b-42caa2c196a0', '65257a25-5438-4952-8f76-ea3226919766', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('691412e1-c404-47d4-a0b9-021e1319a887', '2af8713a-b460-401a-80c6-9d72aa9f1db7', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c62d3f16-ac5f-4721-9bfa-62b001b741f3', '4be4b1a9-054f-4024-8994-9b61af812893', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c12bf7e1-a1c0-4855-870c-9fdc5b97482a', 'af5c501a-19ec-4de0-8a77-3e8426df003a', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d7c24880-4d32-41c4-89e9-e126911c7055', '68d843a4-aa7b-4885-833c-15fc7a19976e', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b7a46ee2-a689-4fd0-97a2-5d58f59d56c3', '9ca30953-b7dd-4747-8b89-86dcd9f235e1', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('243a1a72-5618-426b-9bee-93f04131a70c', '024e0a05-0abc-439f-8f8a-7b67ae6a27d5', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ef7d3f4f-5664-4bce-9838-631535f4b9c1', 'fa570d75-d29f-468f-83d2-77816ac76883', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5ef0d76c-ab3f-40da-aac2-a6a9de7125c9', '72c87dff-ac2b-47b8-8db2-37661280b42d', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6ca9fd5a-11b9-41bf-bcb3-108091c326d6', '71bcb289-8602-457c-866c-07ae89e3fbaa', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5d996896-0415-46c3-92cb-46e35dbeb07a', '5e8f3c17-a12a-4221-8563-15efa2871301', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4b1f9c8b-5dc9-43b7-a6b2-f9a7616f1599', '4399c9b1-fe11-4e11-89c4-dea00ce50e15', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('19f8e220-c967-40bc-b7ee-83ceeea74816', '953f59aa-23cb-4382-8730-d39a2a3bca1d', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aa2bc84c-d991-41c8-8e22-bf6dda3caf56', '00c75a41-b05b-4acf-8302-2b6356ebee76', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b7de3e22-4744-458d-8b62-8461364e6e7f', '3ff42d46-9d99-4080-82d9-646bfb891468', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7e2b0b07-dd3e-4806-8d62-16f0da3fe1f4', 'dd3df2f8-afae-4d2b-80c7-453e802fd477', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('49dd308a-8653-47f6-8c3b-a34aa8250d64', '193601e0-1f17-4c06-8cf3-7db5294414d4', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7e37079e-3195-40d9-b3e0-5d8d13b59961', '323ef57e-fee9-4ae3-823f-84cf0be5a07a', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a9d635cb-4136-4601-8bef-8513cc1aac4d', '3ff420c7-fce4-428f-88b0-e6422df8a549', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c0f9dc9d-dbd2-47d3-a41b-092ba4a019bd', '9233de23-f36f-47f4-81b7-cae8045b283c', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c5119787-d4fe-44a6-b77f-054091418fff', '4cd4fe33-797e-4f9b-8d4d-fbbaa95f129b', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('39b741bb-3a44-4b3f-a2c6-43e0ec78ea4a', '1a25e8d0-dadf-4887-8218-70423e987a49', 'cfc9b089-1fc3-48b4-89b8-41df1c9013c3', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5953c7df-f056-4439-85a7-d8e273f48799', 'bfdc3ce6-3441-488c-8d2f-b4fa5e184de8', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0bf1d0d0-5227-46cb-a354-07cb33209dc4', '1ac99156-3e08-41ce-8725-d857bfc1ff59', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('95b4adac-a7b7-48cd-bc43-21c8f83f2fa8', 'ee899840-4161-4243-8eba-bc005b88a516', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ff1f24d1-6da3-4b91-a264-c31c15bcbe6c', '29ed5a5a-25ec-465e-8b1a-23355ad08d8b', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e9967d19-af48-4e75-b66a-19427894a514', 'fa051061-6609-4b56-893d-a4637874ec60', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4142c5ae-78d7-4278-a34a-7d1d6d5107d3', '569aadc4-f7aa-4e83-82c3-0f7fd6aac21c', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7d9b9328-6c85-47b5-a7be-e9338028a7b0', 'df34f881-8e9f-4094-8645-67c79cce6d26', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c1b9b6f6-30a7-4c43-a81f-f26f2d322a24', '00a1fcb6-e405-4475-83b7-9faa124314fc', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c146746e-fea9-4083-9788-e5dd2f579010', '87f4055c-2e72-429e-8d11-3d77c36e0bc5', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d6102d00-f12d-4f88-93d6-3f4a787f26b4', '75556b19-d978-4562-8779-7a9742dea888', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f5102e97-a841-4e1a-9ac9-e5feae3a6814', 'a5b0faa6-2bd4-40ac-825a-3d22a4d4c84f', '139b5b54-bef5-4b6a-8863-57ce6e6d399d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f70a79d3-15ab-4f10-8e7f-a8880ce159ad', '3a8b507b-7cc0-4837-8ec5-6cffef98ffc6', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fa84355c-6784-4b82-9bfa-f74adb451b3e', 'e3fa4e58-3fe9-4603-856e-aab8d88cac2f', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0ae30e76-9fa2-44f8-9ca1-1f09044da1db', '6e5f8bc6-d54c-4f70-87a1-f9f46253f09e', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6b44b8b6-9480-4f89-a2ae-5e895e370689', '169ba4a8-8738-4f3f-89c1-49746904e11a', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c0ba9f3d-44ca-4243-a1a4-3bef8bf8feb8', '3846b9e6-3246-480c-8b09-3d274f3a32d7', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e726739b-061d-4df5-a2e0-cadeba8cca52', '8b171446-ea15-4bc9-8fdf-854026b46913', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dc2889b5-710e-48d2-a884-25f72891c567', '1d368b30-4bd3-449c-8ed2-e3e19300592d', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bb60be51-6022-482a-a0f5-31596dc6a110', '361d2ac0-f61b-4fa2-8529-45c08d85f694', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8075f271-f566-4d78-9caf-67af8b7acf86', 'ea986a0e-3221-4a45-847c-e86fc4d73a8e', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cd81c092-1643-4b3f-8ce6-537abe981e06', '7e414a7a-9253-4b3d-867d-ff2eba115bd5', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81b0eb4f-cb3b-45b1-b36c-f3a00649861b', '50b9ce91-ad0f-46aa-8c8c-3a6444149e6c', '5b5c9fa8-a519-4711-8638-247856aa639f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ad57976a-72f2-4a65-9d65-14fdc4e79856', '65a4cb58-8d75-422c-811e-d255419e1815', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('21034b3f-54ea-4417-a2ce-e6579d9f8425', '6e06e8c4-8862-420a-85ee-044316743d60', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ebafd3d5-86fc-4b4d-a2e9-ea223012f23f', 'bf60af4b-18b5-4344-8961-c9676dd39e3d', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e4e0af0b-9d93-414e-8e9b-5e10e424aedd', '47f0e427-69c2-4fce-8c30-0df21e67f5ce', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8ad839ed-2b65-4d79-901f-4f37627a6b77', '8f1561cc-73c0-4907-8f43-71481b8d61d4', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d199f7d6-5ab7-46ea-8ed1-9769596123a0', '6b58546b-ec69-43ed-80d7-7869e9dcfd13', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81e9253e-5ade-48e8-9755-3179cc543b2d', '1adb0e49-62c4-42f9-8f36-e2170cb1d6dd', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('63b33da6-8a17-4274-a158-a54cedb6ce63', '784cd6a5-ea49-4961-82e7-62dea15501dc', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('351270d4-4202-4129-9e0b-c97aec4dd3af', 'bb34abd0-6580-4afc-8af7-c6f6ac0575f4', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dd38c083-f87d-4043-a915-391628d664fd', 'ec59a7d0-2729-4303-82f1-3b67ded1fb45', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4038ce6a-7549-4916-b526-3be4496b18a1', 'ff64d119-6872-46f4-81c7-655d979feaf3', 'ae682d5e-54bb-480c-81b9-64294c39fd79', '550e8400-e29b-41d4-a716-446655440701')
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
  ('854301ef-44e1-4bfb-b525-c3bdff821496', '1a2db9e0-cc7a-43b5-847d-4f77669b495c', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('122bbb41-78e6-4e80-ae1e-d10b6430412d', '580706a3-4a36-4715-8a1a-431fb3ab7d72', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7a958ffb-3af6-4816-8116-765baad860a8', 'd7da22e0-2879-4085-8d04-c202ab727d22', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5bcf03da-775e-45b7-90b2-8461636bb15b', '7200f69e-cd9f-4781-8a7e-e1bb3b66f387', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('61e9c437-4688-46be-a99e-ae8b8cc00fa2', 'aacfde2b-61e4-4807-8a34-464a39b6ca86', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('068a0abf-f924-40a1-9d0d-88e434cc70d7', '38fd74cc-1e0a-4130-8551-08c1c0993c08', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8a4da9fa-c3ef-4d4f-a3e2-3c4ad51fe3b9', 'b4450567-89f2-4dc9-8111-1de2443e49d5', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('094906fa-837e-4c05-892f-c437ad78bd97', '71601a04-da5f-4885-8fa5-9d1ac1fecb38', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9e669da9-959a-4568-b101-e4a26b1dbcc4', 'ac439fde-1c04-4538-83be-f66b6dd9c0d0', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('41dd257e-7d67-4869-874b-71bb5d033df3', 'f283b3d9-97ea-4fa0-800f-34b5448b0e17', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('750dc41f-e72c-41a9-8133-15a26067222c', '28137129-7505-4522-894d-25e8b4629299', '88e20e8e-ce66-41d6-833d-07e5a25cd61c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5a726e4a-43bf-49a3-b804-406d4893906c', '5764f5f3-8f57-48ea-870b-f4524b4fe539', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f7346e96-b6db-4012-a6a7-399eda892007', '9d59439d-52f7-4bac-8a80-3e5b59df9c52', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cbc614ba-c784-420f-8035-b03da7473e22', 'ffb1d360-ce84-4a56-871c-3af1e55c1053', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('45dff75a-00bc-4035-97cd-04c2794783f0', 'a678bc70-c525-4b4f-8917-2cac9d3f4367', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7ae1addf-f291-4bcf-804b-db40452cd7d2', 'a1f14465-7c3c-4985-88bf-09eb55092fe6', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('87899b0d-a86f-4f4b-bc82-b912aebfbc84', 'fa5ac455-a2ec-4a25-87fa-67235a2c83e3', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d86c2ce9-42bc-4052-8430-50d87144b5c5', '17a23a8b-88ed-4824-87e2-08c9c7706eda', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('463136f3-dc2f-434b-857c-ae4a7122a5ba', '8f99c913-9369-4ca6-820b-eade1e25677b', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d78b289c-28c2-4627-9258-bb03409565d3', 'c644a24d-a035-46aa-87bc-ee29acff6d2d', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4a64243c-06fd-4c0f-b060-725c00708e4e', '2c96ae4d-4fac-41b2-87b0-4fa86221f220', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2393b39d-44dd-4d96-a1c9-419c4411480f', 'bfce5b73-66f5-4d76-8fbf-659f3fb0dfea', '6312950e-7d25-4b0d-8bfb-8e34e8f29515', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3388f815-5cad-4fe0-8c5a-4a38c73bffc4', '55cf4d9e-3f61-4052-83a1-f5d751503b0f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d242e158-ea65-471f-b16b-ab223c30deb4', '10f89768-605b-4a9e-88df-5535ffb87e8f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bb6d12e2-9b01-45ad-be08-fa37faa53404', '5bc511d0-03f7-4314-88f7-973941894939', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aa872373-a086-4065-9b1a-d7fd7e9a2ed8', '805caa90-4227-439c-81f9-7c40322c9e67', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9c939d28-e03d-436a-b39b-c3b04025e8e8', '90e6c3ab-9be3-4f99-8da6-51b9d6396d5a', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e12c272f-ff46-4bf2-9b6d-7222050c59eb', '0e17b395-4ee5-4ab4-8c81-0a72d60de6fe', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0c21dd62-b836-433b-a99a-c1de6f3dce03', 'cd86ae17-ffcb-41a6-8904-4c3193753448', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('668ded4e-647b-45b5-b7ef-fd3089ceb4b3', 'baacd09e-e142-4cce-8221-f79db14c4516', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1ca1c566-31f6-4d04-9f29-fadd74a4d1f3', '25a486e6-c6e5-4ed6-8c24-0c2d78a6e485', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0bc5ad30-4d16-4e6b-8363-4605742e06ee', '91a4fcda-aa0b-46c5-85da-b72adce7b656', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4407beab-7e6b-48fc-96b7-44f9b9dd25dc', '3f4bfcad-41b8-4c13-816f-a24689c9c17f', 'a1288ba5-ae67-43df-8fbe-4a63a7702603', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ea3670f1-e66d-4b31-aefe-6a270106a3bf', 'b2ff24cf-4f1e-4fa0-8f1a-3721155e16c0', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d7c9650e-016f-4ef8-b405-1d8ff2c1c63d', '97acfed3-e2ec-4a95-8847-cb18d71c255c', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c4ff5ca8-92b1-47ad-9420-1bbd1ebc5e2a', '4a2e0cff-c49e-4a3d-8326-0654dcc1d756', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('72bea7f2-115a-4fe5-977a-1ec2fc5b0c71', 'e14be16f-8fe3-4c4b-8055-77527d8c97df', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ed2f9a3c-7465-435b-aa52-d101fcb8a18a', 'e6c1aab8-d00a-44ba-8699-060f821cd6aa', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6fb56771-8361-439d-a530-921a20b507ff', '83ea5e90-2bdc-4fe1-8366-02243d87b671', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('14fad90f-9ad0-42ca-90a8-d2dd84e7b90c', '391d6c63-a218-4632-8e6b-bd0e08cfc17b', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('27bb00dc-5ca3-4e50-be43-3ce22cc23116', 'e27491bb-41f5-4df3-8a26-75488dd6c1af', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aa270cd6-9c91-48b7-b921-af07a4d3b485', '127a13d9-67bc-41d9-85ea-2fba4c2c3d96', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4519b46a-0ade-4e4c-bea1-abd3211e27a7', '2276494f-3058-4412-8618-5877958b7ef8', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('545b395d-dc85-438a-8dec-63bd200b181e', '6a94b022-cfb5-469a-8502-ac712acc6ad7', '1b01904c-2aca-4467-80c9-705893293f40', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6b9e7302-08f3-42e2-82cd-937d67c65319', 'd171002c-3753-4ce3-8c0a-7f70346079b2', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('58def6e5-c977-4013-9d4a-c2cd89c70e91', '6162ebac-f1fa-47d0-8294-b37569a82f59', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1fe31b60-a1be-4b19-bdb2-ed2ef2f85bfe', '02d06173-fbc0-4254-884b-68ac3771ad4d', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('308af706-e02e-4d59-a37c-46fd60613878', 'fd79e19a-cc61-44eb-82d1-7b43a9ffdbe1', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3bb89330-5fb2-4d74-ab27-a85d7c73b0b6', '51913cda-967d-4f8e-8c92-d0f7c1582dc4', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8586f001-c52d-480f-9043-8c85af59eef1', '115c2dda-2569-4459-86d9-3067ad37ee9c', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('83822afc-c2db-4e2f-8635-eb6d2d6e6df5', '01770ff2-9bfe-45ca-8c83-ebedd646ff7b', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e31c76b9-be5e-4741-9cda-dccb737a3d81', '9d38b113-e27e-4e8e-879b-3a7636202065', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6df43a92-b18b-4883-bfca-6c98b6304c85', '3c1de2fe-f8fe-4dd0-83cd-a88cbb2330eb', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f3fa610d-000c-4af7-88f8-1fbd79fc628e', '415e7dcb-55d0-4970-818d-48dcd22c1b31', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('66a681b1-7679-4a1c-888e-a048dbf0d0a7', 'a61a3c2b-6db4-4c7a-8c12-d5d55a8e7906', 'd48fb053-a685-499e-8663-9e5a3f8ec6c5', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2d7f43df-172c-400a-b589-0a89c3e13625', '5bfdd3a7-6829-428a-8a0e-4795fbda815d', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('019544c5-a3e2-4d2f-b796-baf665490c2c', '7cbb9a91-4ab8-4e37-8754-9b8e93693f68', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('262502ce-c883-4ad4-9ca0-9e8dcb45b074', 'b5494e1c-d02e-4ad5-8b5b-28c9ff116e09', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('daee22cd-aaff-476d-a879-0449215c3354', 'f2f9090d-c1c6-4fff-8c81-9be8b61512b1', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3f0ab4f9-012a-4ee1-b1ac-dd2db3ba7d6b', 'eba93ee7-0935-4715-821d-6966454b67e6', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f7fa0bf7-59c9-40b8-9164-d0c1c73c6381', 'ca39fa0b-99dc-42c0-82e1-9fce5e4fc644', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ca9d80e3-b1b7-486d-b130-2c201560c286', 'ec1c5a47-fa21-4cc1-835c-d3ace90e8b67', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('84d00688-3f11-47ef-b4c9-7e8abfea84f5', 'e303e0ac-8550-406a-8fcc-fc772b87b590', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fb696a26-ba01-4212-9022-e5820835808e', 'e3bf4eec-84f3-428a-898b-6eb12723c8e6', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1e95060c-b849-4ce0-90d5-0f70e96b1f54', 'ebdafa49-1fc6-4006-881e-b6628afe7f0d', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('36ae5537-e80e-4f87-82ee-945b3238ae55', '6e4c7a29-a3be-46bf-8072-e414106a0c20', 'dc27803e-61df-4da0-8d93-3ebad8e0cc15', '550e8400-e29b-41d4-a716-446655440701')
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
  ('65877f22-e639-4867-b850-65004e9c34a5', 'cd067475-9f4e-4857-8a6e-e7bd340e9ac0', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f46ac752-3049-4c7a-9455-0fdb471e6c64', '8550d6c8-b4a7-4fd5-84ab-4f3cefc0d879', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('98ea24b5-fa6f-43c1-b07f-25d225f62ea8', '833f830d-c95e-4c69-8a7c-987261873346', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1fd798a1-a029-4005-adab-e280faefdb7b', '2b1524f7-8c04-45cc-87f4-ea1888355e88', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f83054df-1efa-45ca-8b48-e8d3c7c6b9b7', '9bebe48c-614e-4992-809a-6910f6b84f0d', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a89100af-36cc-4af3-a1f2-34c34719a167', '0d56b42d-3e95-4840-8e91-faf67d93f4d2', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('10a19123-4941-4bdc-9dcd-add08b0214ec', 'c1a0a909-2864-4e9f-853a-3a189ae6c509', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('50c9d6be-3eee-4be9-8ad7-79b345b3567c', 'bf93f35e-3564-407e-8702-37493044a0dd', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7b9a8ca0-8fc9-441b-a5d4-264083a77fbf', 'b9d10f48-a6fe-44b3-8f56-35772bad4aa3', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('45490e7b-bc45-46d2-bdb1-67a9b7ad18b9', '96c42f78-ac01-4f2d-8670-ba6024c4b705', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b18f8012-4e31-451d-9a96-bbb4e8d5639c', '261f16a8-f1f5-4a93-8546-df8b1fff220a', '31c888be-7a06-4c53-8321-a91d8aa7d63a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dbd450ac-5de3-4726-9021-735452062c6b', '03885bbc-2c22-4ba1-8cc4-2c461d34a3d0', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2b68208c-dc73-42a5-bb15-ce16af008e9c', '6dc1f569-23b0-451d-8955-056a83758168', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('503e46be-7b6c-43bf-ae05-e2cacc90a3a8', '066cb992-78db-478e-8386-37554ace3451', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('59100c64-966a-43ed-b6d0-91282e3a10d1', '7fddd652-e1c2-410d-8e93-e5c337bd847f', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7a940253-ef39-42fc-9817-56848ae48e1c', '228bb0d8-64d1-4fc8-869e-b8e774b6b77e', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4c038aaa-4e11-4107-9310-b0110daa8c06', '6956814d-0a15-4bb1-8a19-5c36bdcf6356', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('655ac427-5c1e-47d1-9d2a-b814087ea91e', 'd160d243-756b-453e-8fca-1a2c73bfcb1c', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5abeba22-e8f3-4696-9ea4-26a67a71dd3b', 'f75411e1-17e9-4f93-8587-7c93b8072de2', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1eb735ef-7bce-4af0-8b90-545ce15fc64d', 'afb6beb0-20fa-45a1-853b-a8dd22f6df58', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d8787635-29ec-4610-8a9d-7ed3ec1a5189', 'cb3dac7f-dbae-41be-8fc1-e0b7c0bcd9cc', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c57f7c07-f8e5-4d8d-a539-9aecebdd0f2e', 'fa42ede2-db5b-4886-81c2-7724383b4370', 'f7621fc8-ea3b-477d-8a61-96e77b3dac29', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5689c7b8-0d76-4e2d-8cf5-6e5851a0f018', 'c7e28322-88cf-4075-8bab-c80c93eff0e3', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3b52fd87-d01d-47e5-90fc-10fcb3ca8461', '2beae674-4e95-4aed-840b-612e9dbfe742', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2f9a1233-9eb3-4e78-a6d7-2d90182845e5', 'ab9aa236-f573-424d-81d0-03ee97271d28', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8b4cb77d-28a2-48f8-a335-1fc8b4101a85', '207101fe-df0d-4321-8c02-ad510d5991bc', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('94bca7b0-d226-4842-b6c2-74397dfdaee8', 'c46924d5-8873-4ec2-8c3b-bb43f689552f', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c1b9771c-8a89-48eb-8f96-86bf1999ff4f', 'ae9af858-1250-4ff9-827f-0d30650953ae', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b22a6ee3-1d07-4fcd-83e5-d0f83e887aeb', '44c503a1-cb47-4923-8e61-dab63954bcd0', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d7d6483a-d0af-46ee-9b1d-190a8bb76a88', 'c1f5400d-7d9a-429c-84ca-a9c182eb14fd', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a2fd1ede-1e84-43d9-97f1-45d6186b861b', '4c15f925-5189-4e84-8b76-a4d45ced0ead', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('da487274-6867-4288-b9e8-04004a3abd36', 'f0a1da4b-e42e-4493-8ed1-909ea460b900', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1a5503ca-9577-477f-9866-a1059bf73da0', '8b893ad6-a228-4a3d-826d-a81ef32b6104', '79e4d7bd-bad2-4af9-8fbf-7f48bab11290', '550e8400-e29b-41d4-a716-446655440701')
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
  ('81f95e72-360a-49bf-8917-986b1284fb26', '2a40fa8e-1891-4ef7-8641-b11b7fa885e9', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('7adc7487-c311-47f0-a82c-d3256b91c7cc', 'e388a11f-4c16-41cf-8ccc-cdaf79d7bb66', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c9b10c01-cc19-4de1-8757-fb21c7560909', '941b5be6-3f26-4c07-8db8-3996bb22512c', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2e37a842-593f-419a-8b38-03300a99224e', '08e9ad59-8ff1-4c76-8395-1caa1be80918', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8d2882a4-9f8f-430f-b9f3-bbd7d8fee665', '241d7f88-5440-48a5-866a-b00ceaa7bcbc', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1f3975ca-8bc1-485e-8253-fa541b0d1df7', 'b1d97297-cb41-4071-8b9c-5f5dffc6cc78', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8a197677-b0f8-47e2-b0de-d05655be97d5', '72405d32-737e-48b9-80f8-71373190c6c6', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c4974c50-7e59-414b-9182-a93692b6eeee', 'efd6cf7c-7edb-4ff3-8eec-e5095e119229', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('53945641-c0b0-44e5-95ea-fac5e8a6f8e6', '772844b0-058e-4919-82ae-95639aea8657', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3e7d92b5-8f8c-4456-9dec-b783d99c21cf', '81c390c1-6de1-4dd7-8b5e-cd720a1f4b06', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a9a79232-3c73-48b6-9a7d-e5da308a6f32', '7d7c0d58-02db-4edc-8773-3e255a9e05aa', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d9bc432d-1f6f-47dd-9951-3460fafb86d2', 'cb7a0309-439d-40af-8943-1f6c1594a8fb', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9f5cea62-8993-459c-9467-01b6b84abfec', 'c6e81e24-c66a-473c-8d7b-96f7f31b663c', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ee3527f2-a86c-42b2-8f43-da6d20deebc9', '6baf75a6-3c94-4b8b-82b8-5da0166d4b1c', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f4475ec5-e2f0-4e17-ad99-d5e0a9f43101', '058f612d-bd46-47e3-85d4-d4c9c3e99cc9', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9651733a-82ea-4856-925f-296231565de6', 'fb42bd1d-08e3-4d25-80cd-e37e1e154360', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('79664a79-5ff0-410b-9fe9-c92c967d2357', '6378d9fc-d297-4653-8a3b-1bc39e424ca4', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('edd3d1db-5757-4c5c-9926-c3d51c092e40', '67348b86-ca32-40f7-892e-6596fc1f8bc6', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5c241542-406c-4e62-abd2-568671ec8c39', 'a1dd4e09-6caf-4963-8914-efde0e59b452', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('acf8d114-9e11-4a07-82ce-f67bd2a95fcf', '244e60cd-22ce-4263-834f-72ab6a4f0f2d', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('db853187-213a-4a3f-ab42-3b167a608e47', '07f6fcc4-c550-4a96-81de-70e1c12c6580', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b3d928ad-91fc-4b39-94d2-cd21e5ca8281', '3343e6f9-7887-405b-8755-ae6bc9ec73b7', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e495efaa-e11d-469d-be1d-7c6b15d5f09c', '58fce49b-8346-491c-836d-e7a9dd938d37', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4eba0525-357b-4fda-b8c9-b03fa0eee705', '1a2c226d-f6ed-4fbb-8008-add5e9d3c1c9', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5a51d500-e880-481d-9a70-125f36f9b30a', 'dd37f2ad-0fe7-44a5-8738-d4b47c18ce5a', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8d39a728-3806-455e-bc0a-2b77fa6bdac7', '95ecb689-312d-41f2-8e22-99690481b597', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('31c29493-ea41-4093-8f17-2058a821fe78', '3e510137-2d47-426b-80ea-9d80b397b23c', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cfbfb825-0145-4bb6-8a54-d41f2ebaabf2', 'ba08bf12-c629-4866-8174-77a1662e2ce7', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b0c3a0c1-20b4-4c0e-a5b6-36db230a3a3d', '55d1c0c0-1d1f-4ea2-857d-e4332a25b91d', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1a4fbe24-9d92-4d08-842a-b84c1030279b', '08cdc33a-d799-42d9-8779-744237f084a4', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('e511cf1b-1420-4c45-8a81-4642c97b34a7', 'ac60b673-e81a-49c0-8621-b01b2c16fa80', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('25ceb25d-e2cd-4f60-abe6-736d2d2a372c', '00acb148-6b5b-4d39-8272-4ce87e9c65d5', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ea8a5493-5bb0-440b-af08-9c4f61801750', '0f828e1f-51b5-4f8b-8b27-a1d9ce850112', '63a2603e-8e5c-49eb-826b-ab90969aef98', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0d8e082b-fb67-4b3a-ae5b-8f85f5563c2e', 'b3a32e98-5434-4dd7-8431-a7f62c54dcdf', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d64288f7-b1a1-44d7-9052-a90cf05b6912', '6cca01a5-1ea3-4e5d-888e-42dcf4733023', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('18907161-83d8-411c-9e9f-5aa915a86e1b', '96765e7e-1092-4f7d-8b27-23955919925e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6a30fd98-98d7-467b-9e77-c9a482c9c5a1', '6318bd72-3070-46d3-8909-338a0fff99c3', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('147528ce-c00a-426b-a766-baeca5fa0576', '04c48caf-285f-4181-88c9-a191b0124399', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('df2c7918-426c-4bda-b1ce-b47512085b46', 'b0c65cdf-85e1-4ba9-8df3-bc0c55a0ef35', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('50e14e9e-4e4d-412d-bf60-af7e7392e111', '7127bff8-d032-4e3c-8c2c-f678651eb62f', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a63d35f9-e3dd-4fe3-bd5c-4d86666b6f2e', 'b734676c-1838-4e6a-8d1e-00ea72cec79e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4c9386d5-53e0-4031-bac9-d1b40152c465', 'ce225a1d-231a-49c1-8fe0-4fedfb8f3a98', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6cd57d40-ccba-4311-9801-ace8ae2dd5a5', 'c574f737-5016-4ee7-8a0f-9eaf107d876f', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8b1fa0ac-0011-415b-a821-c1be314a4eb9', '033ec43f-7328-47db-86f5-212f4abc878e', 'cb4a6b7d-d81d-4101-8328-16528f344477', '550e8400-e29b-41d4-a716-446655440701')
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
  ('00691efe-0caa-46d4-8d94-639f1a2834f0', 'fbfabdc4-36ec-4301-8dba-d622d88cd4ac', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('885b7b93-b244-4d00-897f-0d12b8a59e2e', '5276e974-19a3-4684-8e5d-ec8f100f49b0', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('01d00272-b525-4564-8448-7bebfb4097a3', 'ff53826c-c8ac-408f-8d3f-822cc11af125', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bf8e1cc2-546b-4d97-8141-59c709017c55', '44b0e992-2e22-4595-8145-71f8e0b99f47', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('56648f58-6455-4dd9-a71f-225ea3bd28c1', '4d92df9f-a493-47b7-8f66-eb5edbffd23f', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b4a3c26c-a96b-4d87-8ea2-aa68fd99f2b5', '630e2b41-138d-4a12-8256-d3d8c46d514e', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('16bfe146-ca83-40b4-a4fc-9276075291f4', '29250683-9c01-4d58-8d9e-8a8537e600e1', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f0e9a6ac-d487-44f3-a069-1aedc19db92b', '0917aba2-5857-4aec-8860-d29462fd5301', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1c4a4cfa-7db5-468e-aeb4-e92d59fb8d22', 'ef4b020e-935a-43dd-88a1-3a58323e73b0', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('086272d9-2a67-4995-9ac9-ded32d11d7ca', '508fc113-44a2-4b53-8486-cf4e72c0537f', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('593f16e6-f93f-40f6-a174-b2ce25c3246b', 'b2fd7472-2b9d-4f0f-8bc3-0decd3a808a6', '7ffd000f-d10c-4270-8342-fd0c583b6855', '550e8400-e29b-41d4-a716-446655440701')
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
  ('077db4de-03a0-45da-a6e4-3c3807ca1768', '1bd8e559-ea36-47da-8b57-531189a3c53b', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('56344a6c-0fbf-4627-bfb4-25ed43f99606', 'a3231f82-01bc-4f53-8fd2-7c888959a45a', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ef22f0eb-b9c0-47eb-b083-8b2660cfb6b1', '2840691a-9bf2-42ca-8e4c-f699bad3d558', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a7f5a287-965b-495e-9a82-f653c94312af', '02dfa0c7-4f8d-48a0-879b-a649f5b78e5f', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b4bf2e42-8043-49d3-9b17-65b13cd85a2e', 'ba2e073e-24ce-4f38-8ab7-efa3a07f6261', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('289d6e0b-4572-4fe9-b8f1-ff116e8c1838', 'fefd6ec5-d9ed-4df2-8f4e-ef815f85c9ff', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6cc9d0b0-32c4-47ff-97a1-7a743a3688ee', 'f440a629-7ef5-43c9-8b93-090633cc0302', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ea9307bd-7160-41a9-afeb-b32641dd1b90', 'de64bdd6-9125-40f9-8ac6-fd47cdaecc48', '81100354-bd19-444e-8ef5-9864a598b2b6', '550e8400-e29b-41d4-a716-446655440701')
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
  ('34d0770f-f643-4684-9f59-f22eb78ff619', '62fb1ec4-8c9b-437d-8be3-202a573db283', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c9551a1c-f704-4d77-8821-1e5f4078088d', '7a1494ed-a731-4e2c-8f29-cf525f5a74ab', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2ad70e52-0d36-4616-a875-aaf1883e2240', 'f2647efc-4894-4cdf-8e0d-170ce19e6403', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a271aac3-8f32-4e2f-8801-3539969cca64', '6692c5cc-f695-46c2-8774-72b0774015ca', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('55d5a273-aec1-4188-b3e3-776dc17ac00b', '885e90a2-c1fd-4956-8b48-50c9db7f7574', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('add7d4dd-b21b-4478-a10f-36ed439d4b12', '72647206-0e29-4c3a-81dc-64862a04b046', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('90e7e140-e0f1-4c0b-a36e-04335aead462', '87bf8e26-5161-469d-81fe-94c9baead681', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8377e397-fffc-4521-b511-e17e00554718', 'c796d015-02f4-49f0-8436-0ebdf7894f82', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a9edf807-1706-434f-8348-a027d69060a8', '1eb593e9-6425-48b2-8f0a-4d21010884ec', '8844cece-ce0f-4f9c-8637-403ce90ce0dd', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1055692f-8f86-4e8d-8aa5-05fb733ca145', '251084a0-619e-4d78-8bfa-140ae791be70', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ff76c93b-6585-4fce-a59a-8d56b893965c', 'ac5f9ccf-375e-44db-8cc9-d09662639188', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('05ef23f6-121e-4f04-ae41-2acf5f63f396', '38267124-f4a1-454a-8457-397c4b7eec40', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('aedb2dcb-c567-48ce-bc33-689dffd75980', '65504e3a-2071-463c-8fe6-689c8df9937a', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bae084be-65e7-4524-877a-4613ad73a55f', '2e816037-f881-490d-831a-f581c80583c1', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('27f67289-fb82-45bf-b853-e68f24056e13', 'd7d079cc-a140-45a3-823f-c1b2669c4a5d', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d64f7875-14ca-459e-8812-51718d4009dd', '51538e46-6ba4-49c9-8359-cb3ef784b0ff', 'd7112da9-db42-48d3-8bed-a12bd56a8888', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dfd6268c-e2c0-4c64-932e-99e8085ea2f2', '5741860e-9136-4441-82ce-f16a77a52ab4', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6c114c8f-2d9e-48c8-8af3-d2553a728579', '70491f20-2988-4e45-86cf-d5460acc424b', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ae26aab6-e088-4eea-b274-5526b92bf999', '02bfe26b-1f47-4313-857a-bb30bd90c66a', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('127aab22-385d-4f8e-8edc-8d4b909ecd96', 'a24e1fbc-db38-4a57-877b-9d24594c28b9', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ceac216d-1003-4946-9a92-e9d61c5fc766', '6284ce72-655b-40b7-856e-df74513723b8', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5675de82-2afb-4310-8e2d-63243aa038ed', 'cd88baa3-fb28-47c9-8160-2c7f80d8a30a', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('74d2257c-403c-4e17-8255-71905eba8d11', '5a6c3cac-544f-443c-86fc-e4d9dad681a4', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1ed8940d-6d36-442d-8bbd-b1ef0b36d827', '9590c734-e06d-447c-87b8-1ec36064d142', 'b289a801-2713-4e48-80cf-bf45994b4b4b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fdaec2df-4f68-4f74-a04d-1a751f3dbadd', '3a5cba94-14c4-466b-8fab-ed1b13fef954', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('abceb9c6-136a-40ae-9976-120dd9769315', '9520dcf2-721b-4fe9-873e-74b2a8a4ada9', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5cfc8350-f974-4885-ae32-2416979d78ff', 'a3c02d1b-c9d2-4334-8de9-930882f45839', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d6a47e5e-ba01-4e9b-8747-9091b4e1a674', '73504d7e-ff7c-4ed1-8671-820bd06014c2', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ee9fe502-e4f7-4617-b3b4-ce04ee80b4ad', '2a2dbbf5-35cf-4fea-860e-a37a804c7311', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('3bb4287b-35cd-44a1-b87e-c08e934d0eab', '22ad0d56-98e9-4cd1-8a1c-9823a44bfabf', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('42dfc4f6-34f5-4e0c-a860-db69389a2f4f', 'd86b0e2d-70e9-4fac-897f-40a1854205cf', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('15f53a36-57d4-4633-879c-0a23b98845ef', 'a827ef33-7122-475d-8c30-1d99cb57c181', '26ee5a1c-466b-46a2-8b88-b49bc8194989', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a81b32ec-d646-427c-9750-07e21d9cc4e2', '10b607e7-46d2-428b-83fb-ead94dc9418f', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1d5fb314-f717-4aa9-ba1f-a29d2e306c0a', '41f8370c-d73e-49a8-814f-35a2d88ee818', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('54635f8c-1741-4273-a72b-d97c0e79f467', '91b31495-7eee-4d4e-8d66-0453aca7e7cb', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f6434c25-ce04-4006-8f06-ff144513e7e6', '0e721685-1326-4e85-89a0-d8d8b9454d56', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c10bb30b-ee7c-44cc-9320-2444a26a78b2', '73e85eb9-f787-43df-8744-81196c9b6abc', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('85e45847-714d-49e2-8ed2-3003cbb063a1', '74bf771d-f20d-46ba-8717-0fccaaca606a', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b6b5178c-037e-44fa-bb7e-927e41d77173', '15ad4223-e06e-4b10-8297-dc394100662e', '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9dd6e24e-01b7-452c-ba13-edbc98cb6f71', '047df210-3eed-42d8-89b2-0021704b70c5', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c17962d4-4159-4dc6-a609-54b9c25665de', '7cd7d86d-b893-4b42-8214-165cf842d1b5', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9fbb2768-8558-455b-b663-03096f681e42', 'baa72563-cc2a-47d2-84e7-169fc7c104cf', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('676d9033-5b9e-4d44-a094-90a6176359e9', '83ce9341-be86-4d87-8379-5b8cb14dbbae', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8c190de4-c48a-41ab-9f84-0947917b6b2e', 'fd5e8f2f-cc9d-4102-89df-2ea09a17dd83', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('08fa75d8-e383-48dc-a95b-f05dc1244b29', '5dc4363e-8c50-408d-81e4-87c5bc1f903a', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8eb62f5a-8bcb-4090-985d-360814931d72', 'a063642f-3cda-444e-879e-f53a5cb48d24', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b80d1036-f205-45b8-96db-4a1008c2e049', 'f47e3d3d-0d64-4df7-8a6f-122a0466610e', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5da734ee-a952-4c9e-99e9-7606cc6a419a', '0754a7ed-e2e2-4437-8ef1-888cc063e626', '6240b09d-0bbb-4731-8e61-664f69ad8b49', '550e8400-e29b-41d4-a716-446655440701')
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
  ('65dbf7ba-3fa3-4c4e-973b-9534b68c0f3e', '9223499b-a617-4861-8758-cb76a32d9d01', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('27732457-1f88-4ae5-906d-c04d3d212019', '0a9d37e8-eb74-458a-8a9a-f0a6148c2dee', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bc9b54b1-6a1e-4f34-b1a4-49e10719daa8', '99b333b9-18da-4bd3-840b-8b2319d6b3f4', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('64226fef-036b-44e4-a515-464e45429a00', '3dcbf8ac-a2e8-4760-8467-cfb63f1e2fbc', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('724a27a6-d1eb-41ab-b476-c58c204426d2', 'd2c24acb-38d3-415c-8e2f-eeb14a231e98', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('dac89514-5b86-4fcb-9ade-0747c6046df1', '70ce87e6-5dd7-4302-80fa-e4113825c9fb', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('393d4bfe-db71-4d04-95db-373057893bef', '0c482758-b457-48a1-87b7-754e85eeec2f', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b6bbac0a-c3bd-49b5-9cce-876cc4376892', 'c43ca74e-44ad-476a-8921-036805af2bc0', 'ec459901-be4c-4586-8296-a0ca018b0759', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5275635a-485c-4002-ba03-461941487002', '7f808227-8b9a-49a3-8546-6d8d19c66001', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5976ad30-7187-4218-b65e-7134d5b9e121', '0e860a7a-ae6b-4e55-899f-96ec5a7bb6ac', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('caa7bef5-3705-4c83-836c-2755b39ef664', 'f67491f3-d30a-4842-805b-411d99f361ee', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b967a11c-c882-4a9b-bc0c-a4f39f0b9228', '08cb5033-bc10-4180-8f40-940b4dd1ac39', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fb629b53-7f3b-466a-8d10-6651734c0a27', '1464070c-2fb2-44f6-8c60-0bb415fce44c', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('00526607-4662-46a2-8d30-8de4ed1b90ea', '91dcb708-a0a2-4f46-830a-833660e5b998', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2e62991c-b121-4926-812d-89da263d8dd1', '3740c914-8948-4f5d-840b-3533f61c5535', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('a66b8b36-b038-4117-baab-7c5bb2679597', '33d2bbfa-6e2a-48b5-8e41-92c5d88b9bc7', '67f4893b-5422-4c7e-868f-f3d27642a12b', '550e8400-e29b-41d4-a716-446655440701')
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
  ('fb566769-1476-45bb-90bc-ce4c48ab52fa', 'c0540918-a15f-46aa-8e16-ff01c2c1799d', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('44e4f27d-e79c-444b-b373-95ad1cfa57e6', 'cc47a121-3ee6-4a0e-847e-08984b5dc896', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('d9d8b8e6-04a8-4ea1-a264-b5704a29d71b', '1f4ee96e-b212-4093-83e8-fe3dda6c7853', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('92c707b1-68c5-40b4-b0df-83e16b89eec3', 'e6195fe2-dbda-4c25-87ab-ea9641f2d6cf', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ff30391f-5a2a-4147-aea4-95ca3d081b6e', 'c563e77c-19c5-4b7a-8e19-5558a0d1aee3', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ff9e7c26-c150-4078-b0ef-0bf7018c8263', '300f402f-3318-4580-8f60-e05beb6927f1', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('79523864-f1c5-4307-b54d-3b7f195a3f60', '62195179-8e92-4198-8011-c44c91aea058', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('713cfd3b-0d4f-4b29-8016-d17aa6223606', '9b5b38b9-2a22-429f-8a14-96430dc37846', '1cb0c041-5949-4337-8a8b-3762f395e59a', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8673afa7-f988-49c3-98d5-bfae23c5d91c', 'fdde1f37-c3f0-478d-885d-873465d5eb2d', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2fe8890c-faf1-48dc-8d58-2b0599642164', '5aedde46-3bb4-41dc-825d-d65eaeaf3518', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c1468e3b-235b-48ab-abb1-6e6641b7755e', '9ffc358d-3d0e-4ddc-874c-63545f20cc6b', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('754c9bbb-070e-4038-9595-58b0461ed8ca', '07b85f41-8fa0-4378-8b96-ac4ef92024cd', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('19a7cae7-b2de-4c4d-bc76-ce417993eeb6', 'fb6550ed-e94f-47ac-828a-c6b1a3fca28f', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('91e0abfc-6afb-4a61-9841-dbe9b3d55259', '6f8ef26c-81fc-4ffe-87da-fbdb959a32fc', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f817baa8-8cc2-4ea7-9bdc-c0495bf21136', '8c3b039c-3784-4bcf-83c1-21374d9fec62', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('8369e7e2-1d0f-4549-ab38-aef0f15bb687', '7d2fb269-679f-4a27-8e73-18da3fbdaeee', 'e8d0e257-ec0b-4fdf-818a-9d4e026b4756', '550e8400-e29b-41d4-a716-446655440701')
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
  ('82ff888e-c6e7-4245-bc72-2060e8883935', 'd5e48b57-1b1b-4a88-8933-db136a326fd8', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('0dd0e1f0-0986-45c9-9ce5-cd92123d28d0', 'fb8893bc-e654-46a4-893a-c9c5290222af', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('842117b0-9321-45db-9d16-2ba9c857d57b', '48c4b3c7-bab2-4ab9-8c5a-d0d0e531d191', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c1fe296d-2ffa-433b-be63-71ec57ea7e96', '1bc9d4ee-b4a9-435d-8526-9be21568f613', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('113f6900-bf4c-490a-ad03-94bde6fb57b9', 'c716e8b8-7a44-4dd7-8362-ad60cc30c2da', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('1ff06d8e-5ad0-4364-96a8-1e5555ddb38e', '82a75797-65ec-4cc6-8c67-4947f6dc2388', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('02447fc5-24a8-4e29-be1e-5d93c014c1d4', '01aca96c-41bf-450d-816f-e1a46fd4b7d0', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9917b1f4-a7d6-4ce1-b4bb-5ea1b3d4683e', '45f617f5-79c5-40ee-8c75-079c38b6753d', 'bfb11081-eb6a-43ec-872b-55e2ef6aca28', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b475ae64-9afc-49d0-b5ab-4768438a54b8', 'dc56c4d1-ce11-4efc-8010-9f0076ae5b47', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('2a5a098e-31de-4c42-ab2d-cd750c363cc2', '0682f9f9-cd83-4dfd-85db-20c1936cdc1b', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('9247d182-bf78-484e-bed9-15fc9784b171', '56fda2d5-6836-451b-82b5-8cdf1356615a', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('06ea17b7-dff7-4824-91b9-951ca41a9eed', '40a5a544-1502-43bf-8f34-3379fa85931d', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('adf5a14e-b804-4033-b347-22153fb81885', '44f35138-d986-4629-8863-4dd558b06578', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('712b8442-031a-49d5-9305-434bceb45115', 'd68d2610-db40-4ed5-8891-8ec3065bcc99', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('260e0c8a-7b00-4838-b84c-28d8ca6dc31c', '405a83ca-2690-4ae7-8e9d-ced974cbb442', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('165d8154-66b5-4ef5-8e96-24765a052c88', 'c20ff445-1db8-4381-855b-79ec7088cc34', '8c230f20-9233-4477-83a3-8d14b4c7e25d', '550e8400-e29b-41d4-a716-446655440701')
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
  ('adfc3033-63a1-49e2-967a-257fbba7ccbc', 'f50c0c3f-9b35-4d26-8cf7-9a2fc15f8cd9', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6366c159-8d8f-450b-bbda-16eb3a28da5b', '94fd6594-ad9c-4993-8d2f-3a8774a432f6', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('c3cf63fb-d36d-49c5-82f5-89a66bd626f4', '862e9630-7aba-4a1a-8327-f4127c446c9d', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('880a125a-c2a9-4856-9b08-ec90a03a10b4', '85efc97e-2887-410a-8581-4964a62e8546', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('bbfefeaf-7afb-440d-ae77-63715beeebb2', 'd5636064-ee89-4761-81d4-f793bdb26764', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ff2d517a-c78b-4d92-8e46-0b866b132b13', 'cb3664af-c00a-4e09-8ee0-8a54757ea440', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('358b7f18-56e8-43aa-b181-94d68a87dba3', '8fbb86d1-5e96-4562-8a5c-a07ea764f4cf', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('db482542-4838-4f1e-b6c4-6ccfcba11076', 'cc48989d-250a-48e5-81df-77dca4145624', '53b2b1be-a6d3-4bbf-86db-d622fa72352c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('4d676999-3831-410c-9b2d-62dc17cf0ca4', '1cb328bc-eef4-4468-8094-3cf707aeb204', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cbb64409-db68-418e-9869-af8c9f137b74', '41caed55-57b8-49b7-8dfb-71c06aa71e24', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('118ad999-fcbe-45ed-a994-ec17a0ba0189', '4d0b9300-468c-4c5f-8732-195a83d0c178', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('76789579-6a08-4479-b69f-a7e25dc2b5f6', '628b2d64-3adf-4cf7-8d69-40f16d8a50a0', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('581fefaa-6ab9-4f20-8435-e04b9de2251d', '21cbae42-2ac1-43a7-8e2c-d036be7b765e', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('763a8eb0-e2b7-4105-b142-26db5b0cd6af', '25579a5d-3c48-4f82-87d2-b100ebc6efca', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('ceb0f316-ba3c-4bd0-9a86-6c119bbd6827', '981839ad-6c40-4269-8b9f-f58f5b161915', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b0cb375a-2aab-41c7-b053-422069ccb5a1', '6ddaae61-dd8f-4762-8743-1bdfc5c3d84e', '5bd11942-7e6b-4b91-85a0-f7842b7e6340', '550e8400-e29b-41d4-a716-446655440701')
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
  ('95180d25-baf4-4733-8221-d53499c0eda8', '9c39796a-4653-4ca7-81ba-eb23cafde892', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('5c3af2cb-7cb1-4b29-baf7-2ca27ddf7cf4', '1c4f607d-655a-4ec8-801d-813aa877b021', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('6d93b767-5ba5-4182-945f-c82503bf73ba', 'a3cb1ffd-9207-4e5a-8a3f-103a110d15b2', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('405885bf-424e-4dd7-b541-9082339b1f99', '766c1937-33f7-499c-8cc1-400d7dc5468f', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('b5c356c5-24fc-4000-8b21-d6f552383c38', '19a978a9-994c-46bb-81bc-2d25ba975417', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('afefd1cf-a4ee-4c17-9d08-05d19e5aae48', '06b48914-a8be-4c35-86ee-f13de91faebf', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('f2380600-bafb-4fc0-9267-0761865b6722', '76f6a17e-98ec-4afb-8198-20a3a37596ea', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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
  ('cb03ee92-e139-4cf7-bf0c-d56b42419d57', '585202d6-ada8-4b28-8ccf-8b928dc30117', '582ace7a-0fbe-4368-8f03-462dae171b0c', '550e8400-e29b-41d4-a716-446655440701')
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

