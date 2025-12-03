-- ========================================
-- TEST FRIENDLY MATCHES - Winter 2025-2026
-- ========================================
-- Thursday night friendly matches for Lighthouse 1893 SC
-- Loaded only when --test-data flag is passed to dev.sh
-- ========================================

-- Team/User References:
-- Lighthouse 1893 SC:           d37eb44b-8e47-0005-9060-f0cbe96fe089
-- Created by (jbreslin):        77d77471-1250-47e0-81ab-d4626595d63c
-- Friendly event_type_id:       550e8400-e29b-41d4-a716-446655440405
-- Home status_id:               550e8400-e29b-41d4-a716-446655440801
-- Lighthouse Field venue_id:    5cd5a6f6-3ac7-4093-924f-55fe7f08807d

-- ========================================
-- THURSDAY FRIENDLY MATCHES (December 2025 - February 2026)
-- 7pm @ Lighthouse Field
-- Note: matches.id = events.id (FK relationship)
-- ========================================

-- December 2025
-- Dec 4, 2025 - vs Alliance SC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000001', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Alliance SC', '2025-12-04 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000001', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Dec 11, 2025 - vs Alloy Soccer Club (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000002', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Alloy Soccer Club', '2025-12-11 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000002', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '0223b314-0973-0005-f017-a5527b76a814', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Dec 18, 2025 - vs Bel Calcio FC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000003', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Bel Calcio FC', '2025-12-18 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000003', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '268164a2-111d-0005-9ea6-900cd6c9f197', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- January 2026
-- Jan 2, 2026 - vs Buckhead SC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000004', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Buckhead SC', '2026-01-02 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000004', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Jan 9, 2026 - vs Central Park Rangers FC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000005', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Central Park Rangers', '2026-01-09 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000005', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '48a40f97-9111-0005-2e29-709bd3953df2', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Jan 16, 2026 - vs Christos FC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000006', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Christos FC', '2026-01-16 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000006', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Jan 23, 2026 - vs Delmarva Thunder (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000007', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Delmarva Thunder', '2026-01-23 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000007', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '171f448b-97a3-0005-b875-35f9861c31b6', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Jan 30, 2026 - vs Doxa FCW (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000008', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Doxa FCW', '2026-01-30 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000008', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- February 2026
-- Feb 6, 2026 - vs Falcons FC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000009', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Falcons FC', '2026-02-06 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000009', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Feb 13, 2026 - vs Fitchburg FC (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000010', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs Fitchburg FC', '2026-02-13 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000010', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;

-- Feb 20, 2026 - vs GAK (Home)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('c1000001-0000-0000-0000-000000000011', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440405', 'Friendly vs GAK', '2026-02-20 19:00:00-05', 90, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name)
VALUES ('c1000001-0000-0000-0000-000000000011', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '550e8400-e29b-41d4-a716-446655440801', 'Friendly')
ON CONFLICT (id) DO UPDATE SET home_team_id = EXCLUDED.home_team_id, away_team_id = EXCLUDED.away_team_id;
