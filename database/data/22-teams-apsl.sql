-- APSL Teams
-- Generated at: 2025-12-15T18:14:19.492Z

INSERT INTO teams (id, sport_division_id, league_division_id, name, display_name, short_name, slug, logo_url, home_venue_id, primary_color, secondary_color, founded_year, is_active, created_at, updated_at)
VALUES (
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  'TBD',
  NULL,
  'Lighthouse 1893 SC',
  'Lighthouse 1893 SC',
  NULL,
  'lighthouse-1893-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-15T18:14:19.491Z',
  '2025-12-15T18:14:19.491Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = EXCLUDED.updated_at;
