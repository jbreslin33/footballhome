-- ========================================
-- TEST VENUES
-- ========================================
-- Additional venues for test data
-- Loaded only when --test-data flag is passed to dev.sh
-- ========================================

-- Lighthouse Community Center (for winter/indoor practices)
INSERT INTO venues (id, name, address, city, state, postal_code, country, latitude, longitude, venue_type, surface_type, weather_covered)
VALUES (
  'a2000001-0000-0000-0000-000000000001',
  'Lighthouse Community Center',
  '141 W Somerset St',
  'Philadelphia',
  'PA',
  '19133',
  'USA',
  39.9967,
  -75.1418,
  'community_center',
  'hardwood',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  address = EXCLUDED.address;
