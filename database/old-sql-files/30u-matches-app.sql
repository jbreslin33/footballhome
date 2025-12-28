
-- Logged at: 2025-12-21 19:37:29
INSERT INTO matches (id, away_team_id, home_away_status_id, home_team_id, match_status) VALUES ('de9cb60d-1b7c-4126-be78-e2dc1f0a5226', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '550e8400-e29b-41d4-a716-446655440801', '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057', 'scheduled') ON CONFLICT (id) DO UPDATE SET away_team_id = EXCLUDED.away_team_id, home_away_status_id = EXCLUDED.home_away_status_id, home_team_id = EXCLUDED.home_team_id, match_status = EXCLUDED.match_status;

-- Logged at: 2025-12-23 12:47:51
INSERT INTO matches (id, away_team_id, home_away_status_id, home_team_id, match_status) VALUES ('6885cc06-f695-4d79-9ae0-b5a3264bfa06', '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47', '550e8400-e29b-41d4-a716-446655440801', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', 'scheduled') ON CONFLICT (id) DO UPDATE SET away_team_id = EXCLUDED.away_team_id, home_away_status_id = EXCLUDED.home_away_status_id, home_team_id = EXCLUDED.home_team_id, match_status = EXCLUDED.match_status;

-- Logged at: 2025-12-23 14:15:39
INSERT INTO matches (id, away_team_id, home_away_status_id, home_team_id, match_status) VALUES ('ad3c1ea3-cc6f-4025-b1a3-ba39b249661e', 'd7ec30af-80bb-4972-894b-4a441b6bc7a9', '550e8400-e29b-41d4-a716-446655440801', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', 'scheduled') ON CONFLICT (id) DO UPDATE SET away_team_id = EXCLUDED.away_team_id, home_away_status_id = EXCLUDED.home_away_status_id, home_team_id = EXCLUDED.home_team_id, match_status = EXCLUDED.match_status;

-- Logged at: 2025-12-23 15:06:59
INSERT INTO matches (id, away_team_id, home_away_status_id, home_team_id, match_status) VALUES ('01022d00-ee95-4a0a-8be8-e18b786d34f2', 'a16e9445-9bed-4fe6-804d-e77c56258610', '550e8400-e29b-41d4-a716-446655440801', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', 'scheduled') ON CONFLICT (id) DO UPDATE SET away_team_id = EXCLUDED.away_team_id, home_away_status_id = EXCLUDED.home_away_status_id, home_team_id = EXCLUDED.home_team_id, match_status = EXCLUDED.match_status;
