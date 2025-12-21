
-- Logged at: 2025-12-21 19:37:29
INSERT INTO matches (id, away_team_id, home_away_status_id, home_team_id, match_status) VALUES ('de9cb60d-1b7c-4126-be78-e2dc1f0a5226', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440801', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', 'scheduled') ON CONFLICT (id) DO UPDATE SET away_team_id = EXCLUDED.away_team_id, home_away_status_id = EXCLUDED.home_away_status_id, home_team_id = EXCLUDED.home_team_id, match_status = EXCLUDED.match_status;
