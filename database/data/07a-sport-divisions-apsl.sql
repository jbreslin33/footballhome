-- APSL Sport Divisions

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9',
  '235a623c-7368-4c4e-8984-d42da5a47abf',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse 1893 SC Soccer',
  'Lighthouse 1893 SC Soccer',
  'lighthouse-1893-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
