-- ========================================
-- TEST MATCHES - Spring 2026 Schedule
-- ========================================
-- This file contains projected spring schedule for testing
-- Spring matches are reverse home/away from fall
-- Loaded only when --test-data flag is passed to dev.sh
-- ========================================

-- Team IDs Reference:
-- Lighthouse 1893 SC:       d37eb44b-8e47-0005-9060-f0cbe96fe089
-- Philadelphia Soccer Club: 907ece9f-5926-0005-cff6-7672dec05648
-- Medford Strikers:         77b6674f-d598-0005-fd48-227b9e088c41
-- Real Central NJ Soccer:   5d95682c-0ec8-0005-0728-deae7986a2e0
-- Sewell Old Boys FC:       50720c09-2e57-0005-da39-afc85228aaa9
-- Philadelphia Heritage SC: 294a08ff-4f18-0005-c42b-a5fb0d5f0896
-- Vidas United FC:          3dd92f09-4a7d-0005-c554-60df95cfb846
-- Oaklyn United FC:         c2402f6c-0036-0005-d453-d68637ee8277
-- GAK:                      f11cc01a-e8d3-0005-74f0-b00c38923236
-- Alloy Soccer Club:        0223b314-0973-0005-f017-a5527b76a814
-- Jersey Shore Boca:        7288846b-402d-0005-9d60-70d5ffcc5588
-- WC Predators:             84a1029b-04c8-0005-5548-e180ad338d6b

-- Constants:
-- Match event_type_id:      550e8400-e29b-41d4-a716-446655440402
-- Home status_id:           550e8400-e29b-41d4-a716-446655440801
-- Away status_id:           550e8400-e29b-41d4-a716-446655440802
-- Created by (jbreslin):    77d77471-1250-47e0-81ab-d4626595d63c

-- ========================================
-- FEBRUARY CUP GAME (Saturday)
-- ========================================

-- Cup Match: Lighthouse vs GAK (neutral venue cup game)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000001',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs GAK (Werner Fricker Cup)',
  '2026-02-14 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000001',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'Werner Fricker Cup',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- ========================================
-- SPRING LEAGUE MATCHES (Reversed home/away from fall)
-- Season starts Sunday March 1st
-- ========================================

-- Match 1: Philadelphia Soccer Club vs Lighthouse (was Lighthouse HOME in fall)
-- Sunday March 1st, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000002',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Lighthouse 1893 SC',
  '2026-03-01 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000002',
  '907ece9f-5926-0005-cff6-7672dec05648',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440802',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 2: Medford Strikers vs Lighthouse (was Lighthouse HOME in fall)
-- Sunday March 8th, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000003',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Lighthouse 1893 SC',
  '2026-03-08 15:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000003',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440802',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 3: Real Central NJ vs Lighthouse (was Lighthouse HOME in fall)
-- Saturday March 14th, 2026 (Saturday game)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000004',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Lighthouse 1893 SC',
  '2026-03-14 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000004',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440802',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 4: Lighthouse vs Sewell Old Boys (was Sewell HOME in fall)
-- Sunday March 22nd, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000005',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Sewell Old Boys FC',
  '2026-03-22 14:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000005',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 5: Philadelphia Heritage vs Lighthouse (was Lighthouse HOME in fall)
-- Sunday March 29th, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000006',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Lighthouse 1893 SC',
  '2026-03-29 15:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000006',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440802',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 6: Lighthouse vs Vidas United (was Vidas HOME in fall)
-- Saturday April 4th, 2026 (Saturday game)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000007',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Vidas United FC',
  '2026-04-04 17:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000007',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 7: Oaklyn United vs Lighthouse (was Lighthouse HOME in fall)
-- Sunday April 12th, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000008',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Lighthouse 1893 SC',
  '2026-04-12 14:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000008',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440802',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 8: Lighthouse vs GAK (was GAK HOME in fall)
-- Sunday April 19th, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000009',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs GAK',
  '2026-04-19 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000009',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 9: Lighthouse vs Alloy (was Alloy HOME in fall)
-- Sunday April 26th, 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000010',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Alloy Soccer Club',
  '2026-04-26 15:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000010',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 10: Lighthouse vs Jersey Shore Boca (was Boca HOME in fall)
-- Saturday May 2nd, 2026 (Saturday game)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000011',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Jersey Shore Boca',
  '2026-05-02 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000011',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;

-- Match 11: Lighthouse vs WC Predators (was Predators HOME in fall)
-- Sunday May 10th, 2026 (Season finale)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1000001-0000-0000-0000-000000000012',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs WC Predators',
  '2026-05-10 14:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status)
VALUES (
  'a1000001-0000-0000-0000-000000000012',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status;
