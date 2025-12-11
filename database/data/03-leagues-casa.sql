-- ========================================
-- CASA LEAGUE
-- ========================================

INSERT INTO leagues (id, name, display_name, sport_id, season, website, is_active)
VALUES ('00000000-0000-0000-0001-000000000002', 'CASA', 'CASA Soccer League', '550e8400-e29b-41d4-a716-446655440101', '2024-2025', 'https://www.casasoccerleagues.com', true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  website = EXCLUDED.website,
  updated_at = CURRENT_TIMESTAMP;
