-- ========================================
-- APP MATCHES DATA (User-created matches for app usage)
-- ========================================
-- This file contains match data created for application usage
-- Naming: 30u-matches-app.sql (u = user/app data, persistent across rebuilds)

-- Old Timers upcoming match
-- First create event
INSERT INTO events (id, team_id, event_type_id, event_date, start_time, end_time, location, notes, is_cancelled, created_at, updated_at)
VALUES (
  '550e8400-e29b-41d4-a716-446655440999',  -- event id
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',  -- Lighthouse Old Timers Club team_id
  (SELECT id FROM event_types WHERE name = 'Match' LIMIT 1),
  '2025-01-15',  -- Next month
  '19:00:00',
  '20:30:00',
  'Lighthouse Field 1',
  'Friendly match - Old Timers vs Classic FC',
  false,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  event_type_id = EXCLUDED.event_type_id,
  event_date = EXCLUDED.event_date,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  location = EXCLUDED.location,
  notes = EXCLUDED.notes,
  is_cancelled = EXCLUDED.is_cancelled,
  updated_at = EXCLUDED.updated_at;

-- Create a dummy "Classic FC" team to play against if it doesn't exist
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, is_active)
VALUES (
  '550e8400-e29b-41d4-a716-446655441000',  -- Classic FC team_id
  'Classic FC',
  '6362c82a-4383-4d2f-8ecc-8b0e87ab1788',  -- Same sport division as Old Timers
  '311fe53c-88df-4efe-8fa9-6f397992b826',  -- Same league division
  '2024-2025',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  is_active = EXCLUDED.is_active;

-- Now create the match
INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, match_status)
VALUES (
  '550e8400-e29b-41d4-a716-446655440999',  -- Same as event id
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',  -- Lighthouse Old Timers Club (home)
  '550e8400-e29b-41d4-a716-446655441000',  -- Classic FC (away)
  (SELECT id FROM home_away_statuses WHERE status = 'Home' LIMIT 1),
  'scheduled'
)
ON CONFLICT (id) DO UPDATE SET
  home_team_id = EXCLUDED.home_team_id,
  away_team_id = EXCLUDED.away_team_id,
  home_away_status_id = EXCLUDED.home_away_status_id,
  match_status = EXCLUDED.match_status;
