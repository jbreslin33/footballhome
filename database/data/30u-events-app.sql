
-- Logged at: 2025-12-19 16:55:31
INSERT INTO events (id, created_by, duration_minutes, event_date, event_type_id, title, venue_id) VALUES ('fe93e915-a8ee-4651-b40e-2d2f96b607cb', '311ee799-a6a1-450f-8bad-5140a021c92b', '90', '2025-12-22 18:00:00', '550e8400-e29b-41d4-a716-446655440401', 'Monday', 'c5f5eda1-91fc-4a4b-915f-69bc58441e10') ON CONFLICT (id) DO UPDATE SET created_by = EXCLUDED.created_by, duration_minutes = EXCLUDED.duration_minutes, event_date = EXCLUDED.event_date, event_type_id = EXCLUDED.event_type_id, title = EXCLUDED.title, venue_id = EXCLUDED.venue_id;

-- Logged at: 2025-12-19 16:55:31
INSERT INTO practices (id, team_id) VALUES ('fe93e915-a8ee-4651-b40e-2d2f96b607cb', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11') ON CONFLICT (id) DO UPDATE SET team_id = EXCLUDED.team_id;
