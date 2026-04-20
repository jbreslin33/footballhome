DO $$
DECLARE
  lh_team UUID := 'd37eb44b-8e47-0005-9060-f0cbe96fe089';
  falcons UUID := '093a47d2-4a1d-0005-6ab0-93e9e96847d7';
  scrub UUID := 'cd2f494d-83b2-0005-7009-2d86f0e05d52';
  praia UUID := '2a1d62b2-aa71-0005-a6eb-1657e21800bf';
  south UUID := '3b1d4171-c61d-0005-82fe-0b134f83622d';
  project UUID := 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a';
  invictus UUID := 'aa0aab49-a007-0005-2697-8c6ceac5beb7';
  venue1 UUID := '66dbcbef-8376-401e-b940-abb80dd0975a';
  venue2 UUID := 'fe708250-6cfc-41e7-b17a-46ff33c3d182';
  venue3 UUID := '31c0bce5-fa54-4206-9185-48cdc03c7ab2';
  match_type UUID := '550e8400-e29b-41d4-a716-446655440402';
  creator UUID := '77d77471-1250-47e0-81ab-d4626595d63c';
  eid UUID;
BEGIN
  -- Past completed match (2 weeks ago, home vs Falcons)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() - INTERVAL '14 days', venue1, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, home_team_score, away_team_score, match_status, competition_name)
    VALUES (eid, lh_team, falcons, 3, 1, 'completed', 'APSL Spring 2026');

  -- Past completed match (1 week ago, away at Scrub Nation)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() - INTERVAL '7 days', venue2, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, home_team_score, away_team_score, match_status, competition_name)
    VALUES (eid, scrub, lh_team, 0, 2, 'completed', 'APSL Spring 2026');

  -- Upcoming match (tomorrow, home vs Praia Kapital)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() + INTERVAL '1 day', venue1, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, match_status, competition_name)
    VALUES (eid, lh_team, praia, 'scheduled', 'APSL Spring 2026');

  -- Upcoming match (next week, away at South Coast Union)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() + INTERVAL '8 days', venue2, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, match_status, competition_name)
    VALUES (eid, south, lh_team, 'scheduled', 'APSL Spring 2026');

  -- Upcoming match (2 weeks out, home vs Invictus FC)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() + INTERVAL '15 days', venue3, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, match_status, competition_name)
    VALUES (eid, lh_team, invictus, 'scheduled', 'APSL Spring 2026');

  -- Upcoming match (3 weeks out, away at Project Football)
  eid := uuid_generate_v4();
  INSERT INTO events (id, created_by, event_type_id, event_date, venue_id, duration_minutes)
    VALUES (eid, creator, match_type, NOW() + INTERVAL '22 days', venue1, 90);
  INSERT INTO matches (id, home_team_id, away_team_id, match_status, competition_name)
    VALUES (eid, project, lh_team, 'scheduled', 'APSL Spring 2026');

  RAISE NOTICE 'Seeded 6 matches for Lighthouse 1893 SC';
END $$;
