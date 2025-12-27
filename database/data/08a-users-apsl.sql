-- APSL Users

INSERT INTO users (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, first_name, last_name, email, phone, date_of_birth, is_active, apsl_player_id, casa_player_id)
VALUES
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '40ec02c5-fb91-4291-8ceb-9bc9c05ff016',
  'Musa',
  'Abdelgadir',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '40ec02c5-fb91-4291-8ceb-9bc9c05ff016',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4f521fde-a21a-47a0-8119-fa9620588c85',
  'Amar',
  'Abdelrazek',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '4f521fde-a21a-47a0-8119-fa9620588c85',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '62b437b5-8f56-4656-8302-91d73dfcdf2d',
  'Abdelrahman',
  'Ali',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '62b437b5-8f56-4656-8302-91d73dfcdf2d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '326afaa9-78f2-4afd-8bfe-54fcd609011f',
  'Ahmed',
  'Ali',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '326afaa9-78f2-4afd-8bfe-54fcd609011f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9cbae92e-dc47-4652-8625-5290c0ccbc57',
  'Erwa',
  'Babiker',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '9cbae92e-dc47-4652-8625-5290c0ccbc57',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '873cbd3f-e5aa-43d2-81d5-b3e8728a54b0',
  'Arsene',
  'Bado',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '873cbd3f-e5aa-43d2-81d5-b3e8728a54b0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'aa1fa5e4-b5bb-4564-8d36-06dbd4d49fac',
  'Logan',
  'Bersani',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'aa1fa5e4-b5bb-4564-8d36-06dbd4d49fac',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'cbf1a0b4-2a27-4006-8db1-9ad86b1521a4',
  'Mohamed',
  'Bility',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'cbf1a0b4-2a27-4006-8db1-9ad86b1521a4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a12f890e-be4b-49f0-8d67-95d7fdd805f6',
  'Hamzah',
  'Dabbour',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'a12f890e-be4b-49f0-8d67-95d7fdd805f6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fcb79856-84dc-4262-8ab8-99b0d7e608bc',
  'Terrence',
  'Doe',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'fcb79856-84dc-4262-8ab8-99b0d7e608bc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '29de4344-124c-47bc-8ca6-cf5415bca661',
  'Musa',
  'Donza',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '29de4344-124c-47bc-8ca6-cf5415bca661',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f0c2c317-a6ad-4439-8009-0f1398874a34',
  'Alexander',
  'Duopu',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'f0c2c317-a6ad-4439-8009-0f1398874a34',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2ecf11c2-efd4-4e92-8f25-2332454ce35d',
  'Luis',
  'Espejo',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '2ecf11c2-efd4-4e92-8f25-2332454ce35d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8c8a0777-0fd6-4cfe-84b9-b9663da89ac7',
  'Christopher',
  'Fletcher',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '8c8a0777-0fd6-4cfe-84b9-b9663da89ac7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7fcb45b4-5984-4091-8023-62aaab73faed',
  'Mujtaba',
  'Galas',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '7fcb45b4-5984-4091-8023-62aaab73faed',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0fdb3031-94ab-438e-826e-b2e2ce92eb4d',
  'Mustafa',
  'Galas',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '0fdb3031-94ab-438e-826e-b2e2ce92eb4d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b1a92aed-cc81-4765-8b98-c8010da51080',
  'John',
  'Gonzalez',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'b1a92aed-cc81-4765-8b98-c8010da51080',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '978312f0-43c5-4d3c-808b-6520582ff7b8',
  'Ahmed',
  'Gosie',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '978312f0-43c5-4d3c-808b-6520582ff7b8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '69b58dbe-3d56-4d95-8fa3-30ac086aa5e0',
  'Maccarrey',
  'Guillaume',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '69b58dbe-3d56-4d95-8fa3-30ac086aa5e0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b7c238e5-1f2a-4f3e-8db7-b0f828cda76c',
  'Otmane',
  'Houasli',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'b7c238e5-1f2a-4f3e-8db7-b0f828cda76c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5a3a94d3-8f8f-46f5-8a4d-18f144d68c38',
  'Esnayder',
  'Josue',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '5a3a94d3-8f8f-46f5-8a4d-18f144d68c38',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a942a402-d84b-4c5e-804a-22c5e2467b67',
  'Abdoulaye',
  'Kamagate',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'a942a402-d84b-4c5e-804a-22c5e2467b67',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f9111610-235d-4965-8ba9-2a21e666d7a7',
  'Amadou',
  'Kamagate',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'f9111610-235d-4965-8ba9-2a21e666d7a7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f97f58e8-6a44-4b15-83be-c668409c4259',
  'Majid',
  'Kawa',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'f97f58e8-6a44-4b15-83be-c668409c4259',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e7d338ff-ca88-4165-8f06-3ad8f5d6f97e',
  'Mohamed',
  'Khalafalla',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'e7d338ff-ca88-4165-8f06-3ad8f5d6f97e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1920c979-2534-4cca-87d0-6b24ddd2b482',
  'Kouassi',
  'Nguessan',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '1920c979-2534-4cca-87d0-6b24ddd2b482',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '289ca5c6-502b-4aaa-89c1-0c1e45f036dd',
  'Benell',
  'Saygarn',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  '289ca5c6-502b-4aaa-89c1-0c1e45f036dd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;,
  INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'dbb43302-2369-4fe9-8d59-7c5601efe207',
  'Oumar',
  'Sylla',
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth);

INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
  'dbb43302-2369-4fe9-8d59-7c5601efe207',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = EXCLUDED.preferred_position_id,
  photo_url = EXCLUDED.photo_url,
  height_cm = EXCLUDED.height_cm,
  weight_kg = EXCLUDED.weight_kg,
  dominant_foot = EXCLUDED.dominant_foot,
  player_rating = EXCLUDED.player_rating,
  notes = EXCLUDED.notes,
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  date_of_birth = EXCLUDED.date_of_birth,
  is_active = EXCLUDED.is_active,
  apsl_player_id = EXCLUDED.apsl_player_id,
  casa_player_id = EXCLUDED.casa_player_id
;

