-- CASA Conferences
-- Generated at: 2025-12-18T00:39:16.588Z

INSERT INTO league_conferences (id, league_id, name, display_name, slug, description, contact_email, contact_phone, is_active)
VALUES
  ('608a4eb6-432e-43f3-853f-1438f93528f9', '00000000-0000-0000-0001-000000000002', 'Philadelphia', 'Philadelphia', 'philadelphia', NULL, NULL, NULL, true),
  ('b7c0b518-29f2-4bf3-8651-9b6d699f01b7', '00000000-0000-0000-0001-000000000002', 'Boston', 'Boston', 'boston', NULL, NULL, NULL, true),
  ('00ad821c-1bee-4c78-8756-d4172c82f976', '00000000-0000-0000-0001-000000000002', 'Lancaster', 'Lancaster', 'lancaster', NULL, NULL, NULL, true),
  ('49df086e-f87b-4fb4-8640-dccaf6fdc1e9', '00000000-0000-0000-0001-000000000002', 'Central NJ', 'Central NJ', 'central-nj', NULL, NULL, NULL, true)
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

