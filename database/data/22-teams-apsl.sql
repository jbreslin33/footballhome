-- APSL Teams

INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active)
VALUES (
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  'Lighthouse 1893 SC',
  '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url);
