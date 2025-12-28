-- APSL Lighthouse - Schedule

INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '0fab98fb-e4f7-44bc-8958-031c32b9a351',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse Vs Jersey Shore Boca',
  NULL,
  '2025-11-30T22:00:00.000Z',
  NULL,
  210,
  false,
  NULL,
  '13d1c1ded4484cad838f882b9c76b086'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '0fab98fb-e4f7-44bc-8958-031c32b9a351',
  NULL,
  NULL,
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
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '4362e150-1c1c-4792-86c4-8aef5f31d3ce',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  '1st Team APSL Vs West Chester',
  NULL,
  '2025-12-03T00:00:00.000Z',
  NULL,
  210,
  false,
  NULL,
  '4380b75755934f949c6a530bb7bb1b1a'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  '4362e150-1c1c-4792-86c4-8aef5f31d3ce',
  NULL,
  NULL,
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
