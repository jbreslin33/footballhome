
-- Logged at: 2025-12-21 19:37:29
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('de9cb60d-1b7c-4126-be78-e2dc1f0a5226', '77d77471-1250-47e0-81ab-d4626595d63c', '120', '2026-01-03 15:00:00', '550e8400-e29b-41d4-a716-446655440402', 'GAK', '1ae3dcd8-d825-4f25-8d2f-ccdd1db869d8') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-21 21:21:13
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('0f71bd2f-96cf-4deb-9765-e9644c7a7301', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'monday', '76de38a6-fde1-49f3-ba4c-25aa57bbdf3e') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-21 21:21:13
INSERT INTO practices (id, team_id) VALUES ('0f71bd2f-96cf-4deb-9765-e9644c7a7301', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 12:46:16
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('14ae6fa0-3187-4d42-86f0-85040e772991', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', 'a1d5dcf6-ff30-417a-b700-fa9f02a3fb62') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 12:46:17
INSERT INTO practices (id, team_id) VALUES ('14ae6fa0-3187-4d42-86f0-85040e772991', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 12:47:51
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('6885cc06-f695-4d79-9ae0-b5a3264bfa06', '77d77471-1250-47e0-81ab-d4626595d63c', '120', '2026-01-15 19:00:00', '550e8400-e29b-41d4-a716-446655440402', 'Intra Squad 1', 'f10f2568-ac79-4344-b0d4-45879a2555cb') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 13:40:28
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('17dcf7de-d8c3-4409-9d7a-ecc6d2381e92', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', '84bfe176-d566-4dcf-a4d8-11cd97964137') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 13:40:28
INSERT INTO practices (id, team_id) VALUES ('17dcf7de-d8c3-4409-9d7a-ecc6d2381e92', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 13:54:08
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('9d90dd8b-1e09-44b8-ae5e-1527c99cecd7', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', '0b1dbb9c-8e91-4122-bbd8-44f9d35c23c5') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 13:54:08
INSERT INTO practices (id, team_id) VALUES ('9d90dd8b-1e09-44b8-ae5e-1527c99cecd7', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 13:59:47
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('b19cf695-fa5a-481e-970b-11bbdd061e78', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', 'e5457d27-e5c9-4222-b201-0a1eb281a410') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 13:59:47
INSERT INTO practices (id, team_id) VALUES ('b19cf695-fa5a-481e-970b-11bbdd061e78', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 14:14:15
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('8c390073-a30b-42f7-b256-fceb17759515', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', '61c3fe19-80ce-4bd3-9e5a-d443063dc0ed') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 14:14:15
INSERT INTO practices (id, team_id) VALUES ('8c390073-a30b-42f7-b256-fceb17759515', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 14:15:39
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('ad3c1ea3-cc6f-4025-b1a3-ba39b249661e', '77d77471-1250-47e0-81ab-d4626595d63c', '120', '2026-01-15 19:00:00', '550e8400-e29b-41d4-a716-446655440402', 'Thursday', '61c3fe19-80ce-4bd3-9e5a-d443063dc0ed') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 14:59:42
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('0b02afbf-75e9-4719-8bc3-e129146fb2bf', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', '293ea405-f38f-4097-9aed-3385b30d0bce') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 14:59:42
INSERT INTO practices (id, team_id) VALUES ('0b02afbf-75e9-4719-8bc3-e129146fb2bf', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 15:03:32
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('6a3bb17d-407c-4881-9989-d511ff56ea87', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', 'f7962d6e-15b3-477c-b95d-7a596ed0db18') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 15:03:32
INSERT INTO practices (id, team_id) VALUES ('6a3bb17d-407c-4881-9989-d511ff56ea87', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-23 15:06:59
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title) VALUES ('01022d00-ee95-4a0a-8be8-e18b786d34f2', '77d77471-1250-47e0-81ab-d4626595d63c', '120', '2026-01-15 19:00:00', '550e8400-e29b-41d4-a716-446655440402', 'Intra Squad Thurs') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title;

-- Logged at: 2025-12-23 15:14:56
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('d51f653c-3aee-4cbb-8d36-54336c178002', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-27 09:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Saturday', '565a2520-4c8d-4d7f-b1b4-94549c90d788') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-23 15:14:56
INSERT INTO practices (id, team_id) VALUES ('d51f653c-3aee-4cbb-8d36-54336c178002', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;
