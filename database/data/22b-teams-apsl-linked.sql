-- APSL Teams (Linked)

INSERT INTO apsl_teams (id, apsl_id, name, apsl_division_id, team_id)
VALUES
  ('a3a33071-7808-4ca9-8525-ffa58cfeb673', '116079', 'Lighthouse 1893 SC', NULL, 'a16e9445-9bed-4fe6-804d-e77c56258610')
ON CONFLICT (id) DO UPDATE SET
  apsl_id = EXCLUDED.apsl_id,
  name = EXCLUDED.name,
  apsl_division_id = EXCLUDED.apsl_division_id,
  team_id = EXCLUDED.team_id
;

