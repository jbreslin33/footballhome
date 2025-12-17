-- CASA Conferences
-- Generated at: 2025-12-17T15:54:44.353Z

INSERT INTO league_conferences (id, league_id, name, display_name, slug, description, contact_email, contact_phone, is_active)
VALUES
  ('c435f97d-f0eb-4616-84f3-0075e6375c0d', '00000000-0000-0000-0001-000000000002', 'CASA Conference', 'CASA Conference', 'casa-conference', NULL, NULL, NULL, true)
ON CONFLICT (id) DO UPDATE SET
  league_id = EXCLUDED.league_id,
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  description = EXCLUDED.description,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  is_active = EXCLUDED.is_active
;

