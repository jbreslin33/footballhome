
-- Logged at: 2025-12-21 19:37:29
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('de9cb60d-1b7c-4126-be78-e2dc1f0a5226', '77d77471-1250-47e0-81ab-d4626595d63c', '120', '2026-01-03 15:00:00', '550e8400-e29b-41d4-a716-446655440402', 'GAK', '1ae3dcd8-d825-4f25-8d2f-ccdd1db869d8') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-21 21:21:13
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('0f71bd2f-96cf-4deb-9765-e9644c7a7301', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'monday', '76de38a6-fde1-49f3-ba4c-25aa57bbdf3e') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-21 21:21:13
INSERT INTO practices (id, team_id) VALUES ('0f71bd2f-96cf-4deb-9765-e9644c7a7301', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;
