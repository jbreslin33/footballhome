-- CASA Match Schedule
-- Generated at: 2025-12-17T13:30:51.941Z

INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  'b63e0074-d457-4ac7-8f9c-d1986ded807c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Philadelphia SC II',
  NULL,
  'Wed Nov 5 8:45 PM EST - 10:30 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:07.413Z',
  '2025-12-17T13:30:07.413Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'b63e0074-d457-4ac7-8f9c-d1986ded807c',
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  'c6e0ceeb-e214-4276-8635-684551e1bf32',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis United FC II vs Lighthouse Old Timers Club',
  NULL,
  'Sun Nov 2 3:00 PM EST - 4:45 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:17.008Z',
  '2025-12-17T13:30:17.008Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  'c6e0ceeb-e214-4276-8635-684551e1bf32',
  '003dd334-88bf-4682-857f-b0571daa11ac',
  'cbb53b2c-26ce-488f-8c6f-3c589fadddbe',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '49751d33-77c6-4345-864b-840ff0e79847',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Phoenix SCR vs Lighthouse Old Timers Club',
  NULL,
  'Sun Nov 16 1:30 PM EST - 3:15 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:17.007Z',
  '2025-12-17T13:30:17.007Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '49751d33-77c6-4345-864b-840ff0e79847',
  'b8dcec03-3f55-44cc-838a-d50739f9b342',
  'cbb53b2c-26ce-488f-8c6f-3c589fadddbe',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '4f031c69-6a47-47d3-8552-b04885e376e6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis United FC II vs Phoenix SCR',
  NULL,
  'Sun Nov 9 11:45 AM EST - 1:15 PM EST',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:17.007Z',
  '2025-12-17T13:30:17.007Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4f031c69-6a47-47d3-8552-b04885e376e6',
  '003dd334-88bf-4682-857f-b0571daa11ac',
  'b8dcec03-3f55-44cc-838a-d50739f9b342',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '932cf6a7-1c74-4810-8460-738fe1ea4a83',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Persepolis United FC II vs Philadelphia SC II',
  NULL,
  'Thu Oct 30 8:45 PM EDT - 10:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:17.008Z',
  '2025-12-17T13:30:17.008Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '932cf6a7-1c74-4810-8460-738fe1ea4a83',
  '003dd334-88bf-4682-857f-b0571daa11ac',
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id, created_at, updated_at)
VALUES (
  '22c52222-5926-4dad-8c90-b26d24cef2f7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia SC II vs Philadelphia SC II',
  NULL,
  'Sun Oct 12 2:45 PM EDT - 4:30 PM EDT',
  NULL,
  NULL,
  false,
  NULL,
  NULL,
  '2025-12-17T13:30:17.008Z',
  '2025-12-17T13:30:17.008Z'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '22c52222-5926-4dad-8c90-b26d24cef2f7',
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  '550e8400-e29b-41d4-a716-446655440801',
  NULL,
  NULL,
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;
