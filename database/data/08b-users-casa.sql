-- CASA Players (Users)
-- Generated at: 2025-12-17T13:30:51.939Z

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e35f1984-8864-4b32-8d48-c61998309f65',
  'Sammy',
  'Amin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e35f1984-8864-4b32-8d48-c61998309f65',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '05adbf9f-3e6a-48f8-89b6-3655112365f2',
  'Jeffrey',
  'Asiedu',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '05adbf9f-3e6a-48f8-89b6-3655112365f2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ca31c325-7369-420a-8c2d-6844d20a96bf',
  'Theo',
  'Biddle',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ca31c325-7369-420a-8c2d-6844d20a96bf',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '13e23a85-e580-4b40-879d-090e66c85d39',
  'Tyler',
  'Caton',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '13e23a85-e580-4b40-879d-090e66c85d39',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ce8bbbd7-bc94-4e87-8e8d-f804cb7539ac',
  'Jorge',
  'Cervantes',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ce8bbbd7-bc94-4e87-8e8d-f804cb7539ac',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3f6215fc-7112-4da5-82d6-5f04f572d620',
  'Manuel',
  'Chacon Fallas',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3f6215fc-7112-4da5-82d6-5f04f572d620',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '46ef392c-9cda-46f7-800f-928d47f2dfbc',
  'Miguel',
  'Cortes',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '46ef392c-9cda-46f7-800f-928d47f2dfbc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '866795eb-66da-411f-8424-a7a9378a5655',
  'Tyler',
  'Dautrich',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '866795eb-66da-411f-8424-a7a9378a5655',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ea4c9011-0df9-467c-81f1-06ef0fe8613b',
  'Cameron',
  'Dennis',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ea4c9011-0df9-467c-81f1-06ef0fe8613b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '084a72bc-df5d-454f-8904-044788e03938',
  'Aaron',
  'Endres',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '084a72bc-df5d-454f-8904-044788e03938',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '97184d09-3eee-4948-8024-a6a55eb0ae82',
  'Evan',
  'Kent',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '97184d09-3eee-4948-8024-a6a55eb0ae82',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd0ff527e-74f7-4f10-8088-82732c5c3a7a',
  'Lekan',
  'King',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd0ff527e-74f7-4f10-8088-82732c5c3a7a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5ae32b68-128a-462f-86d4-6e6056be7386',
  'Mateo',
  'Loyo',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5ae32b68-128a-462f-86d4-6e6056be7386',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3baf19da-b3b5-4d4e-8f16-b89f79daae53',
  'Christopher',
  'Manful',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3baf19da-b3b5-4d4e-8f16-b89f79daae53',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '37228bec-43a2-4639-8cd8-a90abc35aee7',
  'Sammy',
  'Monistere',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '37228bec-43a2-4639-8cd8-a90abc35aee7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3cf10468-bee5-403a-8324-fcc9c8e59ebb',
  'Rocco',
  'Monteiro',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3cf10468-bee5-403a-8324-fcc9c8e59ebb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e069a0fc-9146-4859-87d6-31dd53fd427e',
  'Eli',
  'Moraru',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e069a0fc-9146-4859-87d6-31dd53fd427e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '0bfb86e9-9f20-4260-8b51-1265725132a7',
  'Zachery',
  'Moyer',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '0bfb86e9-9f20-4260-8b51-1265725132a7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2145cfb1-5528-4619-8e81-c2dbe5b1ceae',
  'Michael',
  'Oh',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2145cfb1-5528-4619-8e81-c2dbe5b1ceae',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '128b9113-2619-4549-8e4e-04885fed0e33',
  'David',
  'Olukoya',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '128b9113-2619-4549-8e4e-04885fed0e33',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1c9aaa26-9d76-47f4-8868-eb0cfe72fb77',
  'Tamer',
  'Ozturk',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1c9aaa26-9d76-47f4-8868-eb0cfe72fb77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'fc11c2c0-9c85-409b-84ca-e0482ec0770d',
  'Joao',
  'Patelli Ramos dos Santos',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'fc11c2c0-9c85-409b-84ca-e0482ec0770d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1519432a-a6c5-4644-8c25-33753ea8d089',
  'Ethan',
  'Reta',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1519432a-a6c5-4644-8c25-33753ea8d089',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'eb342260-f180-437a-8189-9d4895ecfe15',
  'Gonzalo',
  'Reyes',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'eb342260-f180-437a-8189-9d4895ecfe15',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'a7bd5ebc-5c42-40d8-8a2c-be4ee348abd8',
  'justin',
  'reynoso',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'a7bd5ebc-5c42-40d8-8a2c-be4ee348abd8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '787401ec-ae7a-4d11-89c5-0343f98cf89c',
  'Cole',
  'Roddy',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '787401ec-ae7a-4d11-89c5-0343f98cf89c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '239f9f07-444e-4aca-84a9-6850b1e3fa4b',
  'Adam',
  'Silberg',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '239f9f07-444e-4aca-84a9-6850b1e3fa4b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '62b40b6c-d4fd-4b24-81b5-afd1310cd389',
  'Ethan',
  'Spence',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '62b40b6c-d4fd-4b24-81b5-afd1310cd389',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9434abbb-80e7-4b8e-8fc3-f32a53a7b0ca',
  'Kevin',
  'Taipe',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9434abbb-80e7-4b8e-8fc3-f32a53a7b0ca',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:20.643Z',
  '2025-12-17T13:30:20.643Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2a51a35c-59be-474c-873e-555bb6bc2f8d',
  'Kevin',
  'Bowers',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.487Z',
  '2025-12-17T13:30:32.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2a51a35c-59be-474c-873e-555bb6bc2f8d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.487Z',
  '2025-12-17T13:30:32.487Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '566e75a7-7566-4b1f-87e5-975c57f6d8d2',
  'Emile',
  'Diderot',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '566e75a7-7566-4b1f-87e5-975c57f6d8d2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd254ba27-b5f0-496e-80ad-cfb4bfa95f01',
  'Joseph',
  'Duddy',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd254ba27-b5f0-496e-80ad-cfb4bfa95f01',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5f88357a-63db-44b6-8875-40dea076b711',
  'Alexander',
  'Graul',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5f88357a-63db-44b6-8875-40dea076b711',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '8a4b30f8-c1fe-450a-8501-6504fccb78e2',
  'Brendan',
  'Hanratty',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '8a4b30f8-c1fe-450a-8501-6504fccb78e2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '05f5978d-fa9c-465a-8684-9b5aa31927c3',
  'Kevin',
  'Hanuscin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '05f5978d-fa9c-465a-8684-9b5aa31927c3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '29bd2c0c-5515-4aba-88c6-7c76406ee94f',
  'Malcolm',
  'Kane',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '29bd2c0c-5515-4aba-88c6-7c76406ee94f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'fd116369-fc63-486e-8748-7c6a1601e99e',
  'Nicholas',
  'LeFevre',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'fd116369-fc63-486e-8748-7c6a1601e99e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '816bd5df-3e9b-4120-894e-9969b8eacd12',
  'Juan',
  'López',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '816bd5df-3e9b-4120-894e-9969b8eacd12',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3d10a1a3-41ad-4077-84f5-09af544604fb',
  'Jimmy',
  'Manning',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3d10a1a3-41ad-4077-84f5-09af544604fb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '841f0865-c776-4c40-852d-8e9ad71797f1',
  'Alejandro',
  'Medina',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '841f0865-c776-4c40-852d-8e9ad71797f1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5949b2fd-8d34-4989-89f9-40e4f7754fd7',
  'Jose',
  'Moura Filho',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5949b2fd-8d34-4989-89f9-40e4f7754fd7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '0190177c-4dcd-4674-8008-b8d8d1939f29',
  'Khalidi',
  'Ponela',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '0190177c-4dcd-4674-8008-b8d8d1939f29',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '8c7ff374-fc28-4f76-88c8-6aba0b9f2048',
  'Alec',
  'Power',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '8c7ff374-fc28-4f76-88c8-6aba0b9f2048',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '62b67437-137c-4c51-87dc-367b23a3f837',
  'Jim',
  'Power',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '62b67437-137c-4c51-87dc-367b23a3f837',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:32.488Z',
  '2025-12-17T13:30:32.488Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '19c54f13-ddb3-4f84-886d-552d82f48b7a',
  'Hamid',
  'Afolabi',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '19c54f13-ddb3-4f84-886d-552d82f48b7a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5565ab00-70f2-4823-84c7-c4ad22387cd8',
  'Costas',
  'Angelis',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5565ab00-70f2-4823-84c7-c4ad22387cd8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd9640918-5401-4bb6-8db2-2a607e8f2914',
  'Jesus',
  'Colin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd9640918-5401-4bb6-8db2-2a607e8f2914',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '8243278f-2739-4157-8690-98b4a513e4bc',
  'Yoofi',
  'Danquah',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '8243278f-2739-4157-8690-98b4a513e4bc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'a22d39de-28aa-43e3-821d-7745e53bc6ad',
  'Bryan',
  'De Quadros',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'a22d39de-28aa-43e3-821d-7745e53bc6ad',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '404232d7-59d7-455e-8dfd-6ca45286a361',
  'Robert',
  'Ertel',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '404232d7-59d7-455e-8dfd-6ca45286a361',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'b04226fe-4b62-4ee4-8ea8-05dfc7bfc29b',
  'Ahmed',
  'Faik',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'b04226fe-4b62-4ee4-8ea8-05dfc7bfc29b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'b8c2427f-2118-4a6a-8b57-2b24336877e7',
  'Kaua',
  'Freitas',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'b8c2427f-2118-4a6a-8b57-2b24336877e7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '643d27fd-f65c-4ad1-8827-0cfa4ef09fb8',
  'Kareem',
  'Green',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '643d27fd-f65c-4ad1-8827-0cfa4ef09fb8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5f8608ce-56ba-4593-88cf-b8146d85e309',
  'Nigel',
  'Johnson',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5f8608ce-56ba-4593-88cf-b8146d85e309',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '8b5166c1-41f8-4008-804d-00861ffdaba8',
  'Paul',
  'Kwoyelo',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '8b5166c1-41f8-4008-804d-00861ffdaba8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2dabbf72-53e5-4469-8650-1bfaca0bf7e6',
  'Jonatan',
  'Lopez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2dabbf72-53e5-4469-8650-1bfaca0bf7e6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '7d3271f9-24d7-42c7-8913-d0c90e491f77',
  'Zach',
  'Morrison',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '7d3271f9-24d7-42c7-8913-d0c90e491f77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5a32c88f-7999-43ef-837b-d2908905015c',
  'Bryan',
  'Da Silva',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5a32c88f-7999-43ef-837b-d2908905015c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ee0eb503-2d86-4515-86a6-92356520a210',
  'Diego',
  'Murillo',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ee0eb503-2d86-4515-86a6-92356520a210',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '4ffddd3d-daa9-4a54-824d-e0596cdf631d',
  'Paolo',
  'Musumeci',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '4ffddd3d-daa9-4a54-824d-e0596cdf631d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '02dcff73-bb5c-4446-8301-c5b92ec07267',
  'Zabi',
  'Naseri',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '02dcff73-bb5c-4446-8301-c5b92ec07267',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'be045c73-4808-4bd8-8ea5-5864c318fa17',
  'Roni',
  'Rountree',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'be045c73-4808-4bd8-8ea5-5864c318fa17',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '61f3194d-6d63-423d-847a-0e736d4e1667',
  'Luca',
  'Ruggiero',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '61f3194d-6d63-423d-847a-0e736d4e1667',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '6d51ac35-b9f1-4999-8c4f-2443f83d05b4',
  'Mohammad',
  'Sanim',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '6d51ac35-b9f1-4999-8c4f-2443f83d05b4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd3579709-ea0c-416f-843e-f9d64c321844',
  'Aaron',
  'Sexton',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd3579709-ea0c-416f-843e-f9d64c321844',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '6174a31d-9f2f-45a3-8791-02c5e9790c78',
  'Lamin',
  'Sidibeh',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '6174a31d-9f2f-45a3-8791-02c5e9790c78',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3ffa93a5-ba3c-4f6f-80fd-29f7824cf61f',
  'Anis',
  'Slimane',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3ffa93a5-ba3c-4f6f-80fd-29f7824cf61f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9bd181da-df79-4e0e-8bca-4aa4561065ba',
  'Casey',
  'Sorell',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9bd181da-df79-4e0e-8bca-4aa4561065ba',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '84d3ef73-5d77-4323-85df-37dffbd49e89',
  'Cavit',
  'ULA',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '84d3ef73-5d77-4323-85df-37dffbd49e89',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'de1bb2b3-8fa1-46fa-8922-49d60a917ede',
  'Thiago',
  'Vazquez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'de1bb2b3-8fa1-46fa-8922-49d60a917ede',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd2d38540-3323-42e0-8d8f-b6a2ce4f19e0',
  'Sergio',
  'Villanueva',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd2d38540-3323-42e0-8d8f-b6a2ce4f19e0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '614e434d-1736-4cc9-807f-187f6e7edf54',
  'Michael',
  'Wambold',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '614e434d-1736-4cc9-807f-187f6e7edf54',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9115b321-bc4f-4e0a-82a1-d7d3846486fe',
  'Phillip',
  'Washington',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9115b321-bc4f-4e0a-82a1-d7d3846486fe',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:35.024Z',
  '2025-12-17T13:30:35.024Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1b403caf-8c4b-4fa9-8773-675ae2b46fad',
  'Sulaiman',
  'Adegoke',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1b403caf-8c4b-4fa9-8773-675ae2b46fad',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2b76488b-4aec-481c-89c4-d1d6842b5a1c',
  'Promise',
  'Adeyi',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2b76488b-4aec-481c-89c4-d1d6842b5a1c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f57fee7f-722c-4002-861e-f2619d02d331',
  'Ashkon',
  'Ashrafiuon',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f57fee7f-722c-4002-861e-f2619d02d331',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '39cf3f42-ee92-4bd1-8671-56dd1b09f00b',
  'Thomas',
  'Attamante',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '39cf3f42-ee92-4bd1-8671-56dd1b09f00b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5d666b1d-89d3-47a3-84e1-b1b876b50364',
  'Mama',
  'Bah',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5d666b1d-89d3-47a3-84e1-b1b876b50364',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c46c12b6-c5d1-46e8-8449-7e1601db90a4',
  'Cee',
  'Brown',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c46c12b6-c5d1-46e8-8449-7e1601db90a4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '6ddc2f28-00ac-4791-81bf-6752763c3d77',
  'John',
  'Costello',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '6ddc2f28-00ac-4791-81bf-6752763c3d77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5c50db35-a96a-4d6e-8a19-00f9b1a84e6c',
  'patrick',
  'cronin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5c50db35-a96a-4d6e-8a19-00f9b1a84e6c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '443b1e9b-c08b-4d78-836c-e65c6ad4dacf',
  'Jorge',
  'Diaz',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '443b1e9b-c08b-4d78-836c-e65c6ad4dacf',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '25d04673-0dc8-475f-8a15-88a4afa9ac3d',
  'T-Ben',
  'Donnie',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '25d04673-0dc8-475f-8a15-88a4afa9ac3d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '338af739-9497-4bf8-8e32-024399a62595',
  'Oluwaseun',
  'Falayi',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '338af739-9497-4bf8-8e32-024399a62595',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2ccb8d83-0166-4931-8307-7d5393aa3773',
  'Alfred Wakai',
  'Gibson jr',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2ccb8d83-0166-4931-8307-7d5393aa3773',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ad17b8fc-d07e-495e-8bb7-7f1f9ec7d069',
  'Peter',
  'Jakubik',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ad17b8fc-d07e-495e-8bb7-7f1f9ec7d069',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c7b888f8-9307-46eb-897d-3221f6f1586f',
  'Mark',
  'Manis',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c7b888f8-9307-46eb-897d-3221f6f1586f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ab65948e-6a81-482a-85f4-eda13025c28d',
  'Oluwaferanmi',
  'Omidiran',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ab65948e-6a81-482a-85f4-eda13025c28d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd5d12240-d4a6-44eb-8678-84f75f189b3b',
  'Kevin',
  'Sadeghipour',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd5d12240-d4a6-44eb-8678-84f75f189b3b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f3cfd5c5-af13-4c40-8d11-63b2b509f6f7',
  'Zouma',
  'Sanya',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f3cfd5c5-af13-4c40-8d11-63b2b509f6f7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'af37c372-426e-443b-8107-70bf3169865b',
  'CJ',
  'Smolyn',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'af37c372-426e-443b-8107-70bf3169865b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f8b1fe94-1987-421d-82c5-8cbea065f222',
  'Fawaz',
  'Somoye',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f8b1fe94-1987-421d-82c5-8cbea065f222',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '50ed7fcf-58a9-4a9a-8e84-55a98b2d9850',
  'Sebastain',
  'Stelmach',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '50ed7fcf-58a9-4a9a-8e84-55a98b2d9850',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f9c22419-2b14-458d-8c84-31871c7b86a6',
  'Tonny',
  'Temple',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f9c22419-2b14-458d-8c84-31871c7b86a6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '86154741-0e30-4b3a-8298-027663ec0a1f',
  'Christian',
  'Toussaint',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '86154741-0e30-4b3a-8298-027663ec0a1f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '07642694-c458-4c60-89c4-fceaa5a38b57',
  'Albano',
  'Troplini',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '07642694-c458-4c60-89c4-fceaa5a38b57',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ed3b7e72-1578-4bbb-8385-57375fb45417',
  'Henry',
  'Tye',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ed3b7e72-1578-4bbb-8385-57375fb45417',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3f9f5e11-ccc0-431e-82d8-eeb52629c4b5',
  'Bill',
  'Wilson',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3f9f5e11-ccc0-431e-82d8-eeb52629c4b5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.664Z',
  '2025-12-17T13:30:36.664Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'eaa58f0c-7f6c-488b-8d23-240199161142',
  'Sean',
  'Khazael',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'eaa58f0c-7f6c-488b-8d23-240199161142',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1720cc7d-ccb5-484d-8eb5-692134c70651',
  'Boubacar',
  'Traire',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1720cc7d-ccb5-484d-8eb5-692134c70651',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '7da2aa78-2b2d-4dd6-8bfe-e4a8328674ea',
  'Clement',
  'Atebi',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '7da2aa78-2b2d-4dd6-8bfe-e4a8328674ea',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '775a9b0f-35f3-47b5-87fa-7454514b9a29',
  'Osman',
  'Lopez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '775a9b0f-35f3-47b5-87fa-7454514b9a29',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '287b134c-f3c6-406f-8883-0781443019b3',
  'Jevin',
  'Nathaniel',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '287b134c-f3c6-406f-8883-0781443019b3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd8ee9013-e89e-4bbc-846f-7ff2bebaf19b',
  'Clarence',
  'Cole',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd8ee9013-e89e-4bbc-846f-7ff2bebaf19b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:36.665Z',
  '2025-12-17T13:30:36.665Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c6993636-6323-49ab-8c1d-39de0c288aff',
  'Martin',
  'Amaro',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c6993636-6323-49ab-8c1d-39de0c288aff',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '44f9dfa4-b877-433d-8e56-d66707f20903',
  'Georges',
  'Aravidis Rojas',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '44f9dfa4-b877-433d-8e56-d66707f20903',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '0874e3cd-fa29-47d9-8217-d0e071f524e6',
  'Jorge',
  'Argueta',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '0874e3cd-fa29-47d9-8217-d0e071f524e6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '6497e560-43aa-41fb-8ddc-0d3c89961abe',
  'Leandro',
  'Caccin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '6497e560-43aa-41fb-8ddc-0d3c89961abe',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c534b69b-86d3-4368-8ef3-cc1dd0ff5ca4',
  'Pedro',
  'Carone',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c534b69b-86d3-4368-8ef3-cc1dd0ff5ca4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ab7bf0a4-b9f5-4517-8ae4-d90e3902cb52',
  'Angel',
  'Corea Pineda',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ab7bf0a4-b9f5-4517-8ae4-d90e3902cb52',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '440ce350-359e-4e50-8e07-53c381d34b5e',
  'Adair',
  'Espino-Hernandez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '440ce350-359e-4e50-8e07-53c381d34b5e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd1203055-af92-41ff-8e07-2287276c6298',
  'Adrian',
  'Gonzalez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd1203055-af92-41ff-8e07-2287276c6298',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1e054327-e68c-4f3d-89fb-08faf1479da4',
  'Nicolás',
  'Ortiz',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1e054327-e68c-4f3d-89fb-08faf1479da4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '23232f51-d472-4305-8558-c0b9bf0c72f1',
  'Aristides',
  'Pina',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '23232f51-d472-4305-8558-c0b9bf0c72f1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1e3fbff1-1156-4cfd-8f2f-4cf64776524d',
  'Samuel',
  'Reeves',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1e3fbff1-1156-4cfd-8f2f-4cf64776524d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9450ceb0-0997-48d6-8a62-97e1de98f76b',
  'Jhonathan',
  'Ribeiro Enes Sarmento',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9450ceb0-0997-48d6-8a62-97e1de98f76b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '4bd50e62-612c-410e-84b8-af3af340e7e7',
  'Hector',
  'Rivera',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '4bd50e62-612c-410e-84b8-af3af340e7e7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd63e6384-7825-4b74-87c0-d63c830a0217',
  'Kevin',
  'Rivera',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd63e6384-7825-4b74-87c0-d63c830a0217',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1bff2a29-631d-4713-8ff9-c42462a94408',
  'Jonathan',
  'Romero',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1bff2a29-631d-4713-8ff9-c42462a94408',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'eca830f8-e607-432a-8315-e65e4ae07d8b',
  'Katriel',
  'Vargas',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'eca830f8-e607-432a-8315-e65e4ae07d8b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '3edb67ce-c5ba-45dd-8440-32b7e4dc7a16',
  'Jordan',
  'Walls',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '3edb67ce-c5ba-45dd-8440-32b7e4dc7a16',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '4cba20ef-89be-44e9-845d-d3d819b24802',
  'Joshua',
  'Zamora-Solano',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '4cba20ef-89be-44e9-845d-d3d819b24802',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:42.006Z',
  '2025-12-17T13:30:42.006Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'aa1fa5e4-b5bb-4564-8d36-06dbd4d49fac',
  'Logan',
  'Bersani',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'aa1fa5e4-b5bb-4564-8d36-06dbd4d49fac',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ddc3dd00-3caa-46fd-8940-57b84bb23957',
  'Amer',
  'Bleik',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ddc3dd00-3caa-46fd-8940-57b84bb23957',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '311ee799-a6a1-450f-8bad-5140a021c92b',
  'James',
  'Breslin',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '311ee799-a6a1-450f-8bad-5140a021c92b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'b3d30d72-ba8e-443d-8cb5-a35adf1c6f03',
  'Tom',
  'Diguilio',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'b3d30d72-ba8e-443d-8cb5-a35adf1c6f03',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '91e2ef3e-13a2-43ea-8c33-1b362ecee0af',
  'Furkan',
  'Elmas',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '91e2ef3e-13a2-43ea-8c33-1b362ecee0af',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '60401cc2-a615-4626-8d5b-61aed6a4daf7',
  'Birru',
  'Golden',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '60401cc2-a615-4626-8d5b-61aed6a4daf7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'b1a92aed-cc81-4765-8b98-c8010da51080',
  'John',
  'Gonzalez',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'b1a92aed-cc81-4765-8b98-c8010da51080',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '7090816c-81bd-4f4d-89b3-34bbdb59953f',
  'John',
  'Heiler',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '7090816c-81bd-4f4d-89b3-34bbdb59953f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e2046300-3517-4b62-8ec7-b21f7e3c8d2c',
  'Justin',
  'Katz',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e2046300-3517-4b62-8ec7-b21f7e3c8d2c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '48d4c94a-e912-454d-824b-476214fd252d',
  'Brian',
  'Kenny',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '48d4c94a-e912-454d-824b-476214fd252d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '628c2325-8fcc-4ff6-8fd9-d4cfc7cb544c',
  'Joaquin',
  'Ladeuix',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '628c2325-8fcc-4ff6-8fd9-d4cfc7cb544c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2e032730-95f4-4669-87cb-3d5b9a0f4da7',
  'Sam',
  'Lipsey',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2e032730-95f4-4669-87cb-3d5b9a0f4da7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '53e5dfbb-cd45-4ae3-8ae6-4c2c991db547',
  'Juan Cruz',
  'Llambias',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '53e5dfbb-cd45-4ae3-8ae6-4c2c991db547',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '83377f10-8f9c-4ff5-8c78-e8076d71c13d',
  'Sean',
  'McConnel',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '83377f10-8f9c-4ff5-8c78-e8076d71c13d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '587274a3-726d-4a0e-848f-a9764b703cd8',
  'Antonio',
  'Moral',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '587274a3-726d-4a0e-848f-a9764b703cd8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '43a15550-037f-4889-8ff6-3f8046f607f0',
  'Manuel',
  'Morales',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '43a15550-037f-4889-8ff6-3f8046f607f0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '90876152-d23c-4949-8b81-d7fa17eaef7c',
  'Kevin',
  'Nguyen',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '90876152-d23c-4949-8b81-d7fa17eaef7c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'a1fe51ce-36be-4005-81a6-9fd9e8d0133f',
  'Musa',
  'Osman',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'a1fe51ce-36be-4005-81a6-9fd9e8d0133f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f3e840a5-8a22-433d-86c7-439ad8983ee8',
  'Marcelo',
  'Osorio-Soto',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f3e840a5-8a22-433d-86c7-439ad8983ee8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '4616466d-df90-4b39-8f30-58c914d8ddf8',
  'Fabian',
  'Padilla',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '4616466d-df90-4b39-8f30-58c914d8ddf8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '0f7fffb4-62eb-4b7e-8a91-60c059a3f92a',
  'Ruben',
  'Piazzesi',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '0f7fffb4-62eb-4b7e-8a91-60c059a3f92a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9758fca4-9674-4ab1-8d32-1fd6ed81abf2',
  'Joshua',
  'Rosato',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9758fca4-9674-4ab1-8d32-1fd6ed81abf2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1a1ae484-268d-43e0-8274-cb205214cb75',
  'Anthony',
  'Sagustume',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1a1ae484-268d-43e0-8274-cb205214cb75',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'd185276c-1e70-436f-88b8-c78ded6c54c6',
  'Leo',
  'Santa',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'd185276c-1e70-436f-88b8-c78ded6c54c6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9c195cfb-2ab1-4056-8169-b70c00ce379a',
  'Anuar',
  'Santos',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9c195cfb-2ab1-4056-8169-b70c00ce379a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '5d8b7e3d-98a2-4211-8802-42658e8a6c9f',
  'Yakup',
  'Serce',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '5d8b7e3d-98a2-4211-8802-42658e8a6c9f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '7f1ad647-a68a-40aa-82eb-8dceacf35ef8',
  'Christopher',
  'Solis',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '7f1ad647-a68a-40aa-82eb-8dceacf35ef8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'dea0e908-3d64-45ef-8b7d-2dc74a21c1ea',
  'Juan',
  'Vizcaino',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'dea0e908-3d64-45ef-8b7d-2dc74a21c1ea',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:46.372Z',
  '2025-12-17T13:30:46.372Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '30197f42-2b1b-478c-8eef-078abb118a5e',
  'Bassam',
  'Ahmed',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '30197f42-2b1b-478c-8eef-078abb118a5e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '1a82bf4d-2a6f-4265-81ef-97412cec2f6a',
  'Nicholas',
  'Bowman',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '1a82bf4d-2a6f-4265-81ef-97412cec2f6a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '12fbbff2-2861-4c5f-863b-b2f7c5704260',
  'Uriel',
  'Cabello',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '12fbbff2-2861-4c5f-863b-b2f7c5704260',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '0c86dacf-00ee-4e63-80d0-af5838272fce',
  'Tushaar',
  'Godbole',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '0c86dacf-00ee-4e63-80d0-af5838272fce',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'f8ad9f2a-a393-4dcc-893b-c2ef1a26d058',
  'Payman',
  'Mirzaei',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'f8ad9f2a-a393-4dcc-893b-c2ef1a26d058',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:48.446Z',
  '2025-12-17T13:30:48.446Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '76a34018-9e32-40e0-8ee4-23bee5fbab5f',
  'Fritz',
  'Amazan',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '76a34018-9e32-40e0-8ee4-23bee5fbab5f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '703777ad-d6af-4634-8393-8f0607dcb17b',
  'David',
  'Aquino',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '703777ad-d6af-4634-8393-8f0607dcb17b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '862bff0a-288b-4c78-8ab1-15d2895252f1',
  'Christian',
  'Aurand',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '862bff0a-288b-4c78-8ab1-15d2895252f1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '32255111-c422-47fe-8088-094da86aef9e',
  'TJ',
  'Butler',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '32255111-c422-47fe-8088-094da86aef9e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9fc9d386-a256-4792-8075-8c278704bfea',
  'Troy',
  'Eutermoser',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9fc9d386-a256-4792-8075-8c278704bfea',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'b0de4247-65ec-4f2f-8331-bfbfe343eb85',
  'Jeffrey',
  'Forbes',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'b0de4247-65ec-4f2f-8331-bfbfe343eb85',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c5e3cb94-6793-42b3-8de3-353b1bcdd06f',
  'Alex',
  'Freeman',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c5e3cb94-6793-42b3-8de3-353b1bcdd06f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '8073d74a-3bfa-4071-8e9b-c97bd9902466',
  'William',
  'Hanratty',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '8073d74a-3bfa-4071-8e9b-c97bd9902466',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '838ae745-fd7e-477c-89b5-7f90f0beccb2',
  'Dimitri',
  'Jikhvashvili',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '838ae745-fd7e-477c-89b5-7f90f0beccb2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e91297cc-dc4f-4d94-81d0-440d25f184bd',
  'Ryan',
  'Kerr',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e91297cc-dc4f-4d94-81d0-440d25f184bd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'ed071e88-5d39-474e-8cbd-d373f7ffa1c3',
  'Jake',
  'Kucowski',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'ed071e88-5d39-474e-8cbd-d373f7ffa1c3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e4f00bec-c872-4994-88f6-2b55ba7a533f',
  'Rood charleson',
  'Labossiere',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e4f00bec-c872-4994-88f6-2b55ba7a533f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '502560c8-fc62-46c7-8623-b3830d693b1a',
  'Ed-steeve',
  'Madere',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '502560c8-fc62-46c7-8623-b3830d693b1a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '52979385-a492-425a-841e-ac83a765fb60',
  'Daniel',
  'Maggio',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '52979385-a492-425a-841e-ac83a765fb60',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '21ac4afe-f225-41b7-8374-5a0f8b156540',
  'Christopher',
  'McDonnell',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '21ac4afe-f225-41b7-8374-5a0f8b156540',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '42eb5866-55db-4695-8717-53e7d12b2de5',
  'Lasha',
  'Megeneishvili',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '42eb5866-55db-4695-8717-53e7d12b2de5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '28eb8ff0-e397-4945-8a6c-c32535ea0c1a',
  'Merabi',
  'Megreladze',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '28eb8ff0-e397-4945-8a6c-c32535ea0c1a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '2c78541c-e1e4-412a-85b9-c0fbbab76a25',
  'Marc Jerry',
  'Midy',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '2c78541c-e1e4-412a-85b9-c0fbbab76a25',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'c669ac7d-310c-40ed-842b-69e7d90ce9aa',
  'Giorgi',
  'Nikabadze',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'c669ac7d-310c-40ed-842b-69e7d90ce9aa',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'cf274adb-ec8f-4cfd-8604-133329f86a5c',
  'Fran',
  'Pitonyak',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'cf274adb-ec8f-4cfd-8604-133329f86a5c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e2c37098-818f-46cd-8d1f-ae0d11ba91d9',
  'Chris',
  'Rutledge',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e2c37098-818f-46cd-8d1f-ae0d11ba91d9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'e9ce3cc2-a615-47c0-86e5-66935b97d84b',
  'Givi',
  'Svanidze',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'e9ce3cc2-a615-47c0-86e5-66935b97d84b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  'a09a1209-f3c9-4008-80f4-7727c36f514a',
  'Revazi',
  'Tcheshmaritashvili',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  'a09a1209-f3c9-4008-80f4-7727c36f514a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  '9c68fa90-3438-40ff-8846-7d312863c628',
  'Nick',
  'Webster',
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  '9c68fa90-3438-40ff-8846-7d312863c628',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2025-12-17T13:30:51.914Z',
  '2025-12-17T13:30:51.914Z'
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
