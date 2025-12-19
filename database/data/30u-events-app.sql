
-- Logged at: 2025-12-19 16:55:31
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('fe93e915-a8ee-4651-b40e-2d2f96b607cb', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Monday', 'c5f5eda1-91fc-4a4b-915f-69bc58441e10') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-19 16:55:31
INSERT INTO practices (id, team_id) VALUES ('fe93e915-a8ee-4651-b40e-2d2f96b607cb', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-19 17:08:36
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('2979ff84-1adf-4787-81e9-5554af2cbd51', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'monday', 'c5f66f56-c416-4134-b909-00dd7ec81cf8') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-19 17:08:36
INSERT INTO practices (id, team_id) VALUES ('2979ff84-1adf-4787-81e9-5554af2cbd51', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;

-- Logged at: 2025-12-19 17:41:34
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('b563bd5e-946a-449e-8a24-1fceebba1e7e', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Monday', '2d6765e1-605b-47ae-9217-59f1dc62dd25') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-19 17:41:34
INSERT INTO practices (id, team_id) VALUES ('b563bd5e-946a-449e-8a24-1fceebba1e7e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;
