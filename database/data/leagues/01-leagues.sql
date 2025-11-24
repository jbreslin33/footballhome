-- ========================================
-- LEAGUES
-- ========================================
-- Generated: 2025-11-24T18:38:23.419Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/leagues/apsl/scrape-apsl.js
-- ========================================

-- APSL (American Premier Soccer League)
INSERT INTO leagues (id, name, display_name, sport_id, season, website, is_active)
VALUES ('00000000-0000-0000-0001-000000000001', 'APSL', 'American Premier Soccer League', '550e8400-e29b-41d4-a716-446655440101', '2024-2025', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  website = EXCLUDED.website,
  updated_at = CURRENT_TIMESTAMP;
