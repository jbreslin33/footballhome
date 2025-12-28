-- CASA Users

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e35f1984-8864-4b32-8d48-c61998309f65',
  'Sammy',
  'Amin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '05adbf9f-3e6a-48f8-89b6-3655112365f2',
  'Jeffrey',
  'Asiedu',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ca31c325-7369-420a-8c2d-6844d20a96bf',
  'Theo',
  'Biddle',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '13e23a85-e580-4b40-879d-090e66c85d39',
  'Tyler',
  'Caton',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ce8bbbd7-bc94-4e87-8e8d-f804cb7539ac',
  'Jorge',
  'Cervantes',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3f6215fc-7112-4da5-82d6-5f04f572d620',
  'Manuel',
  'Chacon Fallas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '46ef392c-9cda-46f7-800f-928d47f2dfbc',
  'Miguel',
  'Cortes',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '866795eb-66da-411f-8424-a7a9378a5655',
  'Tyler',
  'Dautrich',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ea4c9011-0df9-467c-81f1-06ef0fe8613b',
  'Cameron',
  'Dennis',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '084a72bc-df5d-454f-8904-044788e03938',
  'Aaron',
  'Endres',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '97184d09-3eee-4948-8024-a6a55eb0ae82',
  'Evan',
  'Kent',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd0ff527e-74f7-4f10-8088-82732c5c3a7a',
  'Lekan',
  'King',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5ae32b68-128a-462f-86d4-6e6056be7386',
  'Mateo',
  'Loyo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3baf19da-b3b5-4d4e-8f16-b89f79daae53',
  'Christopher',
  'Manful',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '37228bec-43a2-4639-8cd8-a90abc35aee7',
  'Sammy',
  'Monistere',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3cf10468-bee5-403a-8324-fcc9c8e59ebb',
  'Rocco',
  'Monteiro',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e069a0fc-9146-4859-87d6-31dd53fd427e',
  'Eli',
  'Moraru',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0bfb86e9-9f20-4260-8b51-1265725132a7',
  'Zachery',
  'Moyer',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2145cfb1-5528-4619-8e81-c2dbe5b1ceae',
  'Michael',
  'Oh',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '128b9113-2619-4549-8e4e-04885fed0e33',
  'David',
  'Olukoya',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1c9aaa26-9d76-47f4-8868-eb0cfe72fb77',
  'Tamer',
  'Ozturk',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fc11c2c0-9c85-409b-84ca-e0482ec0770d',
  'Joao',
  'Patelli Ramos dos Santos',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1519432a-a6c5-4644-8c25-33753ea8d089',
  'Ethan',
  'Reta',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'eb342260-f180-437a-8189-9d4895ecfe15',
  'Gonzalo',
  'Reyes',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a7bd5ebc-5c42-40d8-8a2c-be4ee348abd8',
  'justin',
  'reynoso',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '787401ec-ae7a-4d11-89c5-0343f98cf89c',
  'Cole',
  'Roddy',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '239f9f07-444e-4aca-84a9-6850b1e3fa4b',
  'Adam',
  'Silberg',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '62b40b6c-d4fd-4b24-81b5-afd1310cd389',
  'Ethan',
  'Spence',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9434abbb-80e7-4b8e-8fc3-f32a53a7b0ca',
  'Kevin',
  'Taipe',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '22de3793-f177-4a82-890b-e72fa5cdc264',
  'Djalilou',
  'Adam-Djobo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ac00beeb-4f5d-4128-8670-8dfc40c55bff',
  'Luke',
  'Archibald',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1cb5dcbb-e342-4d14-8200-a0ed88630fda',
  'Paul',
  'Bechtelheimer',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd79fea20-28b9-47e8-8e9c-47de2c337679',
  'Noah',
  'Blodget',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '676332b0-9f03-4d52-8955-46e133a33d03',
  'Gonazalo',
  'Chiang',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1f119800-0f8c-40fa-889a-67248e311379',
  'Brandon',
  'Da Silva',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ecd1b0fa-b46e-478e-8979-00db1647fe19',
  'Brandon',
  'DeAngelo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '80e074c4-b993-4a2f-8998-9722bad0a37e',
  'Khadim',
  'Drame',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '025c6f43-2d55-44f1-89fa-b1623643100a',
  'Giovanni',
  'Fareri',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '97eee5fb-e0ba-4f1a-85c8-0353ed9c875d',
  'Emin',
  'Gunaydin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9cb0cb82-68fd-4459-893c-cf710b642885',
  'Vincent',
  'Guzzo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1fc0c7f1-c848-497e-8070-32d095d5697f',
  'Rabah',
  'Hameg',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b9c8a53f-e851-485a-837a-f6258d0635ca',
  'Armaghaan',
  'Hasan',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '67438239-0447-47d5-84a1-0c28135038a3',
  'Dimas',
  'Hernandez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '88fe0546-d54f-48a7-8d8a-5aea543e1ba3',
  'Patrick',
  'Jellig',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9df8e5d3-6958-41b5-821d-3c6adad2212a',
  'Sincere',
  'Kato',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1789d463-ae1f-4579-82a4-5e85490db8f8',
  'Aiden',
  'Kenney',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e8164485-b972-4146-89ee-6ab7e59d764b',
  'Cooper',
  'Lang',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd8060aac-2024-42ae-8ec5-f4700fdead92',
  'Alex',
  'Lewis',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0ab159e8-7010-44e9-8528-1e2114a355ae',
  'Lucien',
  'Maslin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3f440b57-b81e-4179-889f-8488b40ebac3',
  'Dayvon',
  'Mbu',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '661e2b62-7378-4dc4-8dee-e34deaacf845',
  'Kevin',
  'Munive',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e8b6d7b5-82da-4c6c-82f4-28b8bd44e53e',
  'Kevin',
  'Nava',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b5d56cb0-e929-4a2b-84a5-ee75f1fb2e3d',
  'Matthew',
  'Pastore',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3155d429-be62-4075-8fc0-1e375413a3fc',
  'Ethan',
  'Romito',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'cf064cb3-ff12-4a32-83b2-44c31a790b3e',
  'Ahmed',
  'Saidi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5345e70f-549f-4223-8788-311bc40e2da1',
  'Dashan',
  'Santiago',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5e87c655-9e61-470f-88ab-1b9ebae9f496',
  'Ethan',
  'Spinatto',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3c0be90a-5e99-42cd-87f6-a626522b0a60',
  'Travis',
  'Spotts',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '85e9b52a-2e28-4c53-80ff-f287e39b5491',
  'Issac',
  'Agyapong',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '96b5a18d-82b0-44d8-8a73-5e0b1a0a16ed',
  'Abdul Razak',
  'Alhassan',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9a0de768-1a8c-4080-84f0-f6a30ad6f731',
  'Hassan',
  'Bah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4fa9f4d5-6804-4435-8d5e-89be5522cb96',
  'Abu',
  'Bangura',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd1058ddf-886e-4d7a-8bd7-05e655140d93',
  'Mustapha',
  'Bangura',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'aa9d6e7e-8c1d-4eea-88e5-c9289c9407c8',
  'Abubakarr',
  'Bangura',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '92a28554-cced-490d-8911-cba08a7990a2',
  'Demba',
  'Camara',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9bf6ac74-c633-4124-8047-a463da73b9fd',
  'Cephas',
  'Forson',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a2b74af2-4c56-451f-8b01-09b795b865da',
  'Richardo',
  'Gaye',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f2b7e3df-fb09-42a7-8fc0-1af1340f9105',
  'John',
  'Gwah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c0c38883-42ea-40fd-8117-3cb04d29afa1',
  'Abraham',
  'Kamara',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e49ecedd-5e84-4528-881a-e49f95c01258',
  'Francis',
  'Kamara',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9c554e81-da84-4697-8241-c73460908cd9',
  'Mohamed',
  'Kamara',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a11e11f7-892b-4e93-89cd-8edaeff417cd',
  'Alpha',
  'Kanu',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0d6ac403-cc8b-4bbf-8cb2-a634826894f2',
  'Nyakeh',
  'Kiawoh',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '83f6ab8a-1137-4163-8379-8118d8799181',
  'Sory',
  'Konneh',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f86af086-1e64-4b06-873b-06a98e057bae',
  'Idrissa',
  'Konobundor',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6d8410b5-1a1d-42dd-81d6-b504268b3d24',
  'Yayah',
  'Koroma',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8ec67b71-f988-4b15-8b33-5ef6dd3e8df5',
  'Alpha',
  'Koroma',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'af1f2eb6-68b8-474e-814e-4904b24e1c12',
  'Moses',
  'Kpalu',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '35a534c2-5d2d-4f3b-854d-a1ebf8449423',
  'Foday',
  'Kuyateh',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '784fcf71-8723-415d-8cb4-a5a53090b3cb',
  'Badamasie',
  'Mujtabah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd0cf5f01-a363-442e-81a3-9eacac7632cb',
  'Benedict',
  'Olaloye',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ddd91285-7040-49c4-88df-b0748b07c050',
  'Emmanuel',
  'Onwubiko',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7ad2ed12-ffe7-450d-8dee-637d4869c08c',
  'Samuel',
  'Sandi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7cba575d-1567-4091-8293-1b9bebc08932',
  'Alim',
  'Sesay',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '33475488-a9f0-4b1f-8d06-ef083b4ac8dc',
  'Abdul',
  'Sesay',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7ca786e4-09ce-4883-861e-3bbdd74160bd',
  'Favor',
  'WeahJr ***** SUSPENDED FOR 1ST GAME OF SPRING SEASON ******',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '98697ac1-7ae6-491a-8eb3-a61b8d2ed2ed',
  'Omar',
  'Alzubair',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6e1e3d62-c553-44cc-8905-1b7c665ef762',
  'Hassane',
  'Abdellaoui',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e2e46159-130e-406e-8a0d-3bc935044130',
  'Victor',
  'Baidel',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '431f3f43-d8e9-491b-83c7-9dcd1ab3fd35',
  'Oumar',
  'Barry',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8ac027a3-00d2-48da-849a-70cbdc08b5bd',
  'Aboubacar',
  'Bayo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ecd247ec-ddc4-4b5d-8b92-631d4a4f68e7',
  'Luke',
  'Breslin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '493d10b8-aca1-4c7a-87f7-554ab8d04d51',
  'Luis',
  'De Jesus',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '873a9102-6772-4dda-8fb3-b00cdc29384b',
  'Abdoul',
  'Diallo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f7b9044a-df0a-4a43-8e51-c26e4180a0e1',
  'Abouya',
  'Gangue',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9978b53a-e8ce-4056-87c8-5cabf2c2a7dc',
  'Edwin',
  'Garcia',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2190af99-00b9-416f-8066-3812512c60e8',
  'Miles',
  'Henry',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c3af604a-8ee6-404d-820d-655b75c2b3e2',
  'Andy',
  'Hizdri',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '251135ad-d4f8-4c6a-896f-0fc474ee0684',
  'Arif',
  'Hossain',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '868dd702-b538-4f5c-8a18-8877acd8f6ed',
  'Zuhab',
  'Imran',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fd39d786-7e2b-4ccf-803e-f9a159dd852b',
  'Alexander',
  'Lara',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6498eba0-d590-422c-84c9-518b001833bd',
  'Valentino',
  'Martinez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8a9ecdab-e7bc-43bf-81c6-bd91031531b3',
  'David',
  'Masi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7343bb6e-d617-4e05-8979-5bd0591ba7df',
  'Elmer',
  'Mendoza',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a31a0457-d65e-4971-86db-8b5be010db6f',
  'Dylan',
  'Moreno',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3974ce27-33ce-4677-81f7-780fbe569c5d',
  'Babacar',
  'Ndiaye',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '71d9a1ed-95e2-4cc9-841d-62c3bb071b8b',
  'Zion',
  'Nwalipenja',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'dc21338b-e04c-420f-88b0-139d7e594a97',
  'John',
  'Oladele',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '62430967-3b59-43ea-8df8-6fe5170afa91',
  'Jemirkel',
  'Ornaque',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b9b87e0a-e7ba-47ad-8254-a6f3a2c681f9',
  'Joe',
  'Riccitelli',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '943e70b6-19d1-4a6f-8c08-34fc2d0e5b64',
  'Caleb',
  'Rojas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b852da3b-ef3d-4a36-80dd-7460ad307717',
  'Ali',
  'Salah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '873eb321-2598-4dfa-8220-ba5fec641a5a',
  'Daniel',
  'Salmanca',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fb0083d0-ad60-4e43-83b8-c0d1f3dbb15c',
  'Eljo',
  'Agolli',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '454ab322-9ae7-4d61-8516-a1f567e86553',
  'Carlos',
  'Aroche',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5250b980-d9f7-4939-81af-dd179cf89a40',
  'Jayden',
  'Barragan',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ea874825-f9f9-4299-82c6-66f2b7eaf5ad',
  'Christian',
  'Cardenas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '442540f6-33cc-4591-8f21-6da75b7c7a78',
  'Ermal',
  'Caushi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '15cbc2d7-7a15-4be0-80f8-54314c7ad9bc',
  'Ilir',
  'Cepani',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '17a25e3f-a028-4916-8209-8fbfa615d7ad',
  'Alexandre',
  'De Souza Jr',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c5a4a3fd-ce04-4925-8fa6-e5aa01c14220',
  'Klevisi',
  'Dervishi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5a732944-f969-4ca0-8c89-b40caf7af8f9',
  'Sidiki',
  'Fofana',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a4fe6e71-3d2c-4654-8fe3-ce71b3ab5206',
  'Evlad',
  'Fonda',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '51ace01d-ab8e-4d9b-8567-f4d87560b286',
  'Zakaria',
  'Gueddar',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd1d0e68b-3dbe-42d0-8baf-86a696aaeeb6',
  'Gavin',
  'Hagen',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '21274459-6654-41e8-82d8-b32c73102f23',
  'Mario',
  'Kureta',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd5fe8726-c05b-4cf1-87ed-04f3e2f1ccb3',
  'Olen',
  'Laze',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'deeaa786-003f-4299-8018-33808f498b40',
  'Mario',
  'Morina',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'aa0a7e48-3259-4227-8e8a-711be50cfe62',
  'Ramadan',
  'Nazeraj',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7e3a7d37-132e-42a9-8a41-30b0b75ee2c6',
  'Youssef',
  'Omer',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a60db8df-2d82-4327-850c-761e492cbad9',
  'Eldion',
  'Pajollari',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a1e19cc6-2abe-4386-84a9-73f8bed44558',
  'Albion',
  'Pajollari',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'be3108ec-2a56-4853-8db2-53d6f75b8cc5',
  'Elsion',
  'Pajollari',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fd589512-f690-42e2-8443-23a940c38d8f',
  'Brahim',
  'Saouid',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'adf29e72-0daa-4437-8e44-ad87f6ff4927',
  'Temur',
  'Temirov',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '82058e18-e758-4948-8c06-80e977840885',
  'Achilles',
  'Triantafyllos',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f8d2bf69-a476-4818-833a-e7e247b5962d',
  'Brendan',
  'Werner',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '061c3308-3730-45e5-8fcf-826051179ffe',
  'Myles',
  'Addy',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c018c1e5-2e51-4e6a-8de7-f55d1e900c10',
  'Charles',
  'Afful',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ef6d0c30-eb76-4251-8e58-3de020279496',
  'Fred',
  'Amadi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '162f1e75-5065-4f4e-8e43-ceebf7c591a8',
  'Edmond',
  'Ansah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '76051a95-fd1a-45b2-8076-06ab0035d387',
  'Joe',
  'Attakora',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3192b8de-99fd-41d7-8afa-940bc2d9838c',
  'Henry',
  'Ayi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3f57543c-5184-474b-88fd-462b9e64eb69',
  'Christian',
  'Bamba',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f6ac5fbd-5447-4c0d-89c6-489a2f69c4d7',
  'Al hassane',
  'Belemou',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b6c5d8d9-be03-484c-8091-32cd3f67054c',
  'Prince',
  'Boafo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'abd8a564-c00a-43b9-8a60-ca05657c6a67',
  'Bartels',
  'Danquah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1d59b36a-f02f-48bf-8ece-dc8c464c3f93',
  'Michael',
  'Danquah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5b130380-9930-477e-86e1-72f0cc7d5281',
  'Joshua',
  'Deets',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '03a74d64-5ff1-48ab-85dc-18ad932d1415',
  'NATHAN',
  'ELIZER',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1c8acb18-1c6f-40aa-813f-d401f8996d57',
  'Rosier',
  'Joseph',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a2a2f066-173e-4a9e-8a0e-1861fe3bcac4',
  'Bernard',
  'Kyei-Mensah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'bfcb61c2-bf30-4b60-85a4-b40200ea6390',
  'Imoro',
  'latif',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '362f7ad5-8ac3-4efc-8a96-df444175abfc',
  'Stephen',
  'Lindsay',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5ddef5ee-0da3-446a-84a3-03ff715066bc',
  'Kingsley',
  'Oppong',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a9c87566-f437-4882-86b1-b1196a99ca59',
  'Richard',
  'Sarpong',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '834f7bf8-66cd-4aaf-8035-86dc4cd0c01e',
  'Kwaku',
  'Sarpong',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'bd48686b-9bc1-41b6-8e0f-89770c2c5a35',
  'Jonathan',
  'Seya',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0cec89c0-56ea-4404-8d71-2a0ea2fb54dc',
  'Kwamina',
  'Thompson',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '50b54c77-049f-4deb-85a0-22dbdd0c52b2',
  'Patrick',
  'Tierney',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'afba9fe3-7a10-4598-81bf-ad5d02bb979b',
  'Sebastian',
  'Tilley',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fd6088ee-512e-4983-8fd7-825a87468090',
  'Swallah',
  'Yussif',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2a51a35c-59be-474c-873e-555bb6bc2f8d',
  'Kevin',
  'Bowers',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '566e75a7-7566-4b1f-87e5-975c57f6d8d2',
  'Emile',
  'Diderot',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd254ba27-b5f0-496e-80ad-cfb4bfa95f01',
  'Joseph',
  'Duddy',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5f88357a-63db-44b6-8875-40dea076b711',
  'Alexander',
  'Graul',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8a4b30f8-c1fe-450a-8501-6504fccb78e2',
  'Brendan',
  'Hanratty',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '05f5978d-fa9c-465a-8684-9b5aa31927c3',
  'Kevin',
  'Hanuscin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '29bd2c0c-5515-4aba-88c6-7c76406ee94f',
  'Malcolm',
  'Kane',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'fd116369-fc63-486e-8748-7c6a1601e99e',
  'Nicholas',
  'LeFevre',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '816bd5df-3e9b-4120-894e-9969b8eacd12',
  'Juan',
  'López',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3d10a1a3-41ad-4077-84f5-09af544604fb',
  'Jimmy',
  'Manning',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '841f0865-c776-4c40-852d-8e9ad71797f1',
  'Alejandro',
  'Medina',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5949b2fd-8d34-4989-89f9-40e4f7754fd7',
  'Jose',
  'Moura Filho',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0190177c-4dcd-4674-8008-b8d8d1939f29',
  'Khalidi',
  'Ponela',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8c7ff374-fc28-4f76-88c8-6aba0b9f2048',
  'Alec',
  'Power',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '62b67437-137c-4c51-87dc-367b23a3f837',
  'Jim',
  'Power',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '19c54f13-ddb3-4f84-886d-552d82f48b7a',
  'Hamid',
  'Afolabi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5565ab00-70f2-4823-84c7-c4ad22387cd8',
  'Costas',
  'Angelis',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd9640918-5401-4bb6-8db2-2a607e8f2914',
  'Jesus',
  'Colin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8243278f-2739-4157-8690-98b4a513e4bc',
  'Yoofi',
  'Danquah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a22d39de-28aa-43e3-821d-7745e53bc6ad',
  'Bryan',
  'De Quadros',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '404232d7-59d7-455e-8dfd-6ca45286a361',
  'Robert',
  'Ertel',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b04226fe-4b62-4ee4-8ea8-05dfc7bfc29b',
  'Ahmed',
  'Faik',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b8c2427f-2118-4a6a-8b57-2b24336877e7',
  'Kaua',
  'Freitas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '643d27fd-f65c-4ad1-8827-0cfa4ef09fb8',
  'Kareem',
  'Green',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5f8608ce-56ba-4593-88cf-b8146d85e309',
  'Nigel',
  'Johnson',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8b5166c1-41f8-4008-804d-00861ffdaba8',
  'Paul',
  'Kwoyelo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2dabbf72-53e5-4469-8650-1bfaca0bf7e6',
  'Jonatan',
  'Lopez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7d3271f9-24d7-42c7-8913-d0c90e491f77',
  'Zach',
  'Morrison',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5a32c88f-7999-43ef-837b-d2908905015c',
  'Bryan',
  'Da Silva',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ee0eb503-2d86-4515-86a6-92356520a210',
  'Diego',
  'Murillo',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4ffddd3d-daa9-4a54-824d-e0596cdf631d',
  'Paolo',
  'Musumeci',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '02dcff73-bb5c-4446-8301-c5b92ec07267',
  'Zabi',
  'Naseri',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'be045c73-4808-4bd8-8ea5-5864c318fa17',
  'Roni',
  'Rountree',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '61f3194d-6d63-423d-847a-0e736d4e1667',
  'Luca',
  'Ruggiero',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6d51ac35-b9f1-4999-8c4f-2443f83d05b4',
  'Mohammad',
  'Sanim',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd3579709-ea0c-416f-843e-f9d64c321844',
  'Aaron',
  'Sexton',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6174a31d-9f2f-45a3-8791-02c5e9790c78',
  'Lamin',
  'Sidibeh',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3ffa93a5-ba3c-4f6f-80fd-29f7824cf61f',
  'Anis',
  'Slimane',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9bd181da-df79-4e0e-8bca-4aa4561065ba',
  'Casey',
  'Sorell',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '84d3ef73-5d77-4323-85df-37dffbd49e89',
  'Cavit',
  'ULA',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'de1bb2b3-8fa1-46fa-8922-49d60a917ede',
  'Thiago',
  'Vazquez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd2d38540-3323-42e0-8d8f-b6a2ce4f19e0',
  'Sergio',
  'Villanueva',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '614e434d-1736-4cc9-807f-187f6e7edf54',
  'Michael',
  'Wambold',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9115b321-bc4f-4e0a-82a1-d7d3846486fe',
  'Phillip',
  'Washington',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1b403caf-8c4b-4fa9-8773-675ae2b46fad',
  'Sulaiman',
  'Adegoke',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2b76488b-4aec-481c-89c4-d1d6842b5a1c',
  'Promise',
  'Adeyi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f57fee7f-722c-4002-861e-f2619d02d331',
  'Ashkon',
  'Ashrafiuon',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '39cf3f42-ee92-4bd1-8671-56dd1b09f00b',
  'Thomas',
  'Attamante',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5d666b1d-89d3-47a3-84e1-b1b876b50364',
  'Mama',
  'Bah',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c46c12b6-c5d1-46e8-8449-7e1601db90a4',
  'Cee',
  'Brown',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6ddc2f28-00ac-4791-81bf-6752763c3d77',
  'John',
  'Costello',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5c50db35-a96a-4d6e-8a19-00f9b1a84e6c',
  'patrick',
  'cronin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '443b1e9b-c08b-4d78-836c-e65c6ad4dacf',
  'Jorge',
  'Diaz',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '25d04673-0dc8-475f-8a15-88a4afa9ac3d',
  'T-Ben',
  'Donnie',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '338af739-9497-4bf8-8e32-024399a62595',
  'Oluwaseun',
  'Falayi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2ccb8d83-0166-4931-8307-7d5393aa3773',
  'Alfred Wakai',
  'Gibson jr',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ad17b8fc-d07e-495e-8bb7-7f1f9ec7d069',
  'Peter',
  'Jakubik',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c7b888f8-9307-46eb-897d-3221f6f1586f',
  'Mark',
  'Manis',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ab65948e-6a81-482a-85f4-eda13025c28d',
  'Oluwaferanmi',
  'Omidiran',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd5d12240-d4a6-44eb-8678-84f75f189b3b',
  'Kevin',
  'Sadeghipour',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f3cfd5c5-af13-4c40-8d11-63b2b509f6f7',
  'Zouma',
  'Sanya',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'af37c372-426e-443b-8107-70bf3169865b',
  'CJ',
  'Smolyn',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f8b1fe94-1987-421d-82c5-8cbea065f222',
  'Fawaz',
  'Somoye',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '50ed7fcf-58a9-4a9a-8e84-55a98b2d9850',
  'Sebastain',
  'Stelmach',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f9c22419-2b14-458d-8c84-31871c7b86a6',
  'Tonny',
  'Temple',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '86154741-0e30-4b3a-8298-027663ec0a1f',
  'Christian',
  'Toussaint',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '07642694-c458-4c60-89c4-fceaa5a38b57',
  'Albano',
  'Troplini',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ed3b7e72-1578-4bbb-8385-57375fb45417',
  'Henry',
  'Tye',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3f9f5e11-ccc0-431e-82d8-eeb52629c4b5',
  'Bill',
  'Wilson',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'eaa58f0c-7f6c-488b-8d23-240199161142',
  'Sean',
  'Khazael',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1720cc7d-ccb5-484d-8eb5-692134c70651',
  'Boubacar',
  'Traire',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7da2aa78-2b2d-4dd6-8bfe-e4a8328674ea',
  'Clement',
  'Atebi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '775a9b0f-35f3-47b5-87fa-7454514b9a29',
  'Osman',
  'Lopez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '287b134c-f3c6-406f-8883-0781443019b3',
  'Jevin',
  'Nathaniel',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd8ee9013-e89e-4bbc-846f-7ff2bebaf19b',
  'Clarence',
  'Cole',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c6993636-6323-49ab-8c1d-39de0c288aff',
  'Martin',
  'Amaro',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '44f9dfa4-b877-433d-8e56-d66707f20903',
  'Georges',
  'Aravidis Rojas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0874e3cd-fa29-47d9-8217-d0e071f524e6',
  'Jorge',
  'Argueta',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '6497e560-43aa-41fb-8ddc-0d3c89961abe',
  'Leandro',
  'Caccin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c534b69b-86d3-4368-8ef3-cc1dd0ff5ca4',
  'Pedro',
  'Carone',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ab7bf0a4-b9f5-4517-8ae4-d90e3902cb52',
  'Angel',
  'Corea Pineda',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '440ce350-359e-4e50-8e07-53c381d34b5e',
  'Adair',
  'Espino-Hernandez',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd1203055-af92-41ff-8e07-2287276c6298',
  'Adrian',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1e054327-e68c-4f3d-89fb-08faf1479da4',
  'Nicolás',
  'Ortiz',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '23232f51-d472-4305-8558-c0b9bf0c72f1',
  'Aristides',
  'Pina',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1e3fbff1-1156-4cfd-8f2f-4cf64776524d',
  'Samuel',
  'Reeves',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9450ceb0-0997-48d6-8a62-97e1de98f76b',
  'Jhonathan',
  'Ribeiro Enes Sarmento',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4bd50e62-612c-410e-84b8-af3af340e7e7',
  'Hector',
  'Rivera',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd63e6384-7825-4b74-87c0-d63c830a0217',
  'Kevin',
  'Rivera',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1bff2a29-631d-4713-8ff9-c42462a94408',
  'Jonathan',
  'Romero',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'eca830f8-e607-432a-8315-e65e4ae07d8b',
  'Katriel',
  'Vargas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '3edb67ce-c5ba-45dd-8440-32b7e4dc7a16',
  'Jordan',
  'Walls',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4cba20ef-89be-44e9-845d-d3d819b24802',
  'Joshua',
  'Zamora-Solano',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ddc3dd00-3caa-46fd-8940-57b84bb23957',
  'Amer',
  'Bleik',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '311ee799-a6a1-450f-8bad-5140a021c92b',
  'James',
  'Breslin',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b3d30d72-ba8e-443d-8cb5-a35adf1c6f03',
  'Tom',
  'Diguilio',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '91e2ef3e-13a2-43ea-8c33-1b362ecee0af',
  'Furkan',
  'Elmas',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '60401cc2-a615-4626-8d5b-61aed6a4daf7',
  'Birru',
  'Golden',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7090816c-81bd-4f4d-89b3-34bbdb59953f',
  'John',
  'Heiler',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e2046300-3517-4b62-8ec7-b21f7e3c8d2c',
  'Justin',
  'Katz',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '48d4c94a-e912-454d-824b-476214fd252d',
  'Brian',
  'Kenny',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '628c2325-8fcc-4ff6-8fd9-d4cfc7cb544c',
  'Joaquin',
  'Ladeuix',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2e032730-95f4-4669-87cb-3d5b9a0f4da7',
  'Sam',
  'Lipsey',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '53e5dfbb-cd45-4ae3-8ae6-4c2c991db547',
  'Juan Cruz',
  'Llambias',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '83377f10-8f9c-4ff5-8c78-e8076d71c13d',
  'Sean',
  'McConnel',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '587274a3-726d-4a0e-848f-a9764b703cd8',
  'Antonio',
  'Moral',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '43a15550-037f-4889-8ff6-3f8046f607f0',
  'Manuel',
  'Morales',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '90876152-d23c-4949-8b81-d7fa17eaef7c',
  'Kevin',
  'Nguyen',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a1fe51ce-36be-4005-81a6-9fd9e8d0133f',
  'Musa',
  'Osman',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f3e840a5-8a22-433d-86c7-439ad8983ee8',
  'Marcelo',
  'Osorio-Soto',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '4616466d-df90-4b39-8f30-58c914d8ddf8',
  'Fabian',
  'Padilla',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0f7fffb4-62eb-4b7e-8a91-60c059a3f92a',
  'Ruben',
  'Piazzesi',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9758fca4-9674-4ab1-8d32-1fd6ed81abf2',
  'Joshua',
  'Rosato',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1a1ae484-268d-43e0-8274-cb205214cb75',
  'Anthony',
  'Sagustume',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'd185276c-1e70-436f-88b8-c78ded6c54c6',
  'Leo',
  'Santa',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9c195cfb-2ab1-4056-8169-b70c00ce379a',
  'Anuar',
  'Santos',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '5d8b7e3d-98a2-4211-8802-42658e8a6c9f',
  'Yakup',
  'Serce',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '7f1ad647-a68a-40aa-82eb-8dceacf35ef8',
  'Christopher',
  'Solis',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'dea0e908-3d64-45ef-8b7d-2dc74a21c1ea',
  'Juan',
  'Vizcaino',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '30197f42-2b1b-478c-8eef-078abb118a5e',
  'Bassam',
  'Ahmed',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '1a82bf4d-2a6f-4265-81ef-97412cec2f6a',
  'Nicholas',
  'Bowman',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '12fbbff2-2861-4c5f-863b-b2f7c5704260',
  'Uriel',
  'Cabello',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '0c86dacf-00ee-4e63-80d0-af5838272fce',
  'Tushaar',
  'Godbole',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'f8ad9f2a-a393-4dcc-893b-c2ef1a26d058',
  'Payman',
  'Mirzaei',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '76a34018-9e32-40e0-8ee4-23bee5fbab5f',
  'Fritz',
  'Amazan',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '703777ad-d6af-4634-8393-8f0607dcb17b',
  'David',
  'Aquino',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '862bff0a-288b-4c78-8ab1-15d2895252f1',
  'Christian',
  'Aurand',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '32255111-c422-47fe-8088-094da86aef9e',
  'TJ',
  'Butler',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9fc9d386-a256-4792-8075-8c278704bfea',
  'Troy',
  'Eutermoser',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'b0de4247-65ec-4f2f-8331-bfbfe343eb85',
  'Jeffrey',
  'Forbes',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c5e3cb94-6793-42b3-8de3-353b1bcdd06f',
  'Alex',
  'Freeman',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '8073d74a-3bfa-4071-8e9b-c97bd9902466',
  'William',
  'Hanratty',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '838ae745-fd7e-477c-89b5-7f90f0beccb2',
  'Dimitri',
  'Jikhvashvili',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e91297cc-dc4f-4d94-81d0-440d25f184bd',
  'Ryan',
  'Kerr',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'ed071e88-5d39-474e-8cbd-d373f7ffa1c3',
  'Jake',
  'Kucowski',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e4f00bec-c872-4994-88f6-2b55ba7a533f',
  'Rood charleson',
  'Labossiere',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '502560c8-fc62-46c7-8623-b3830d693b1a',
  'Ed-steeve',
  'Madere',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '52979385-a492-425a-841e-ac83a765fb60',
  'Daniel',
  'Maggio',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '21ac4afe-f225-41b7-8374-5a0f8b156540',
  'Christopher',
  'McDonnell',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '42eb5866-55db-4695-8717-53e7d12b2de5',
  'Lasha',
  'Megeneishvili',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '28eb8ff0-e397-4945-8a6c-c32535ea0c1a',
  'Merabi',
  'Megreladze',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '2c78541c-e1e4-412a-85b9-c0fbbab76a25',
  'Marc Jerry',
  'Midy',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'c669ac7d-310c-40ed-842b-69e7d90ce9aa',
  'Giorgi',
  'Nikabadze',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'cf274adb-ec8f-4cfd-8604-133329f86a5c',
  'Fran',
  'Pitonyak',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e2c37098-818f-46cd-8d1f-ae0d11ba91d9',
  'Chris',
  'Rutledge',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'e9ce3cc2-a615-47c0-86e5-66935b97d84b',
  'Givi',
  'Svanidze',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  'a09a1209-f3c9-4008-80f4-7727c36f514a',
  'Revazi',
  'Tcheshmaritashvili',
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

INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active)
VALUES (
  '9c68fa90-3438-40ff-8846-7d312863c628',
  'Nick',
  'Webster',
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
