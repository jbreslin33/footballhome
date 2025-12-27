-- APSL Clubs

INSERT INTO clubs (id, name, display_name, slug, parent_club_id, description, logo_url, website, founded_year, contact_email, contact_phone, address, city, state, postal_code, country, is_active)
VALUES (
  '235a623c-7368-4c4e-8984-d42da5a47abf',
  'Lighthouse 1893 SC',
  'Lighthouse 1893 SC',
  'lighthouse-1893-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'USA',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  parent_club_id = EXCLUDED.parent_club_id,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  website = EXCLUDED.website,
  founded_year = EXCLUDED.founded_year,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  state = EXCLUDED.state,
  postal_code = EXCLUDED.postal_code,
  country = EXCLUDED.country,
  is_active = EXCLUDED.is_active;
