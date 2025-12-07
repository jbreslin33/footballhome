-- ========================================
-- LEAGUE CONFERENCES
-- ========================================
-- Generated: 2025-12-07T16:32:29.902Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('282679d6-baa5-0002-cac6-a8ec79406f30', '00000000-0000-0000-0001-000000000001', 'Mayflower Conference', 'Mayflower Conference', 'mayflower-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('6718a93f-9f0c-0002-e639-c01213b5db55', '00000000-0000-0000-0001-000000000001', 'Constitution Conference', 'Constitution Conference', 'constitution-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('cce826c6-2327-0002-eaa3-795e1b4fe3d0', '00000000-0000-0000-0001-000000000001', 'Metropolitan Conference', 'Metropolitan Conference', 'metropolitan-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('0e4dfe0a-4757-0002-dc8e-92734ef56a74', '00000000-0000-0000-0001-000000000001', 'Delaware River Conference', 'Delaware River Conference', 'delaware-river-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('458151aa-915e-0002-2e19-a8b87de9b135', '00000000-0000-0000-0001-000000000001', 'Mid-Atlantic Conference', 'Mid-Atlantic Conference', 'mid-atlantic-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('222b808e-5cee-0002-80b6-a4f6fa9f2917', '00000000-0000-0000-0001-000000000001', 'Terminus Conference', 'Terminus Conference', 'terminus-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

