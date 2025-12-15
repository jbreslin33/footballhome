-- APSL League
-- Generated at: 2025-12-15T18:14:19.491Z

INSERT INTO leagues (id, name, display_name, slug, sport_id, country, region, level, is_active, created_at, updated_at)
VALUES (
  '00000000-0000-0000-0001-000000000001',
  'APSL',
  'American Premier Soccer League',
  'apsl',
  '550e8400-e29b-41d4-a716-446655440101',
  'United States',
  NULL,
  NULL,
  true,
  '2025-12-15T18:14:17.900Z',
  '2025-12-15T18:14:17.900Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  updated_at = EXCLUDED.updated_at;
