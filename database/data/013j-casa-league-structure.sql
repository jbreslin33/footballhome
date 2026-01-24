-- CASA Select 2025 League Structure
-- Season 100, Conferences 100-103, Divisions 100-104
--
-- Covers 4 CASA Select conferences (South NJ and North NJ launching in Spring):
-- - Philadelphia (Liga 1, Liga 2) - 2 divisions, page_node_id values available
-- - Boston (Liga 1) - 1 division, page_node_id needed
-- - Lancaster (Liga 1) - 1 division, page_node_id needed
-- - Central NJ (Liga 1) - 1 division, page_node_id needed
--
-- Total: 4 conferences, 5 divisions (only Philadelphia has 2)
--
-- This file (013j) loads BEFORE 013i-casa-scrape-targets.sql (alphabetically)
-- to ensure divisions exist before scrape targets reference them.

-- ============================================================================
-- SEASON
-- ============================================================================
INSERT INTO seasons (id, league_id, name, start_date, end_date, is_active, source_system_id) VALUES
(100, 2, '2025', '2025-01-01', '2025-12-31', true, 2)
ON CONFLICT (league_id, name) DO NOTHING;

-- ============================================================================
-- PHILADELPHIA CONFERENCE (Conference 100) - 2 divisions
-- ============================================================================
INSERT INTO conferences (id, season_id, name, abbreviation, region, source_system_id, sort_order) VALUES
(100, 100, 'Philadelphia Conference', 'PHIL', 'Philadelphia, PA', 2, 1)
ON CONFLICT (season_id, name) DO NOTHING;

INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, skill_level, skill_label, source_system_id, external_id, sort_order) VALUES
(100, 100, 100, 'Liga 1', 1, 1, 'Liga 1', 2, '9090889', 1),
(101, 100, 100, 'Liga 2', 1, 2, 'Liga 2', 2, '9096430', 2)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- BOSTON CONFERENCE (Conference 101) - 1 division
-- ============================================================================
INSERT INTO conferences (id, season_id, name, abbreviation, region, source_system_id, sort_order) VALUES
(101, 100, 'Boston Conference', 'BOS', 'Boston, MA', 2, 2)
ON CONFLICT (season_id, name) DO NOTHING;

INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, skill_level, skill_label, source_system_id, external_id, sort_order) VALUES
(102, 100, 101, 'Liga 1', 1, 1, 'Liga 1', 2, NULL, 1)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- LANCASTER CONFERENCE (Conference 102) - 1 division
-- ============================================================================
INSERT INTO conferences (id, season_id, name, abbreviation, region, source_system_id, sort_order) VALUES
(102, 100, 'Lancaster Conference', 'LANC', 'Lancaster, PA', 2, 3)
ON CONFLICT (season_id, name) DO NOTHING;

INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, skill_level, skill_label, source_system_id, external_id, sort_order) VALUES
(103, 100, 102, 'Liga 1', 1, 1, 'Liga 1', 2, NULL, 1)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- CENTRAL NEW JERSEY CONFERENCE (Conference 103) - 1 division
-- ============================================================================
INSERT INTO conferences (id, season_id, name, abbreviation, region, source_system_id, sort_order) VALUES
(103, 100, 'Central New Jersey Conference', 'CNJ', 'Central NJ', 2, 4)
ON CONFLICT (season_id, name) DO NOTHING;

INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, skill_level, skill_label, source_system_id, external_id, sort_order) VALUES
(104, 100, 103, 'Liga 1', 1, 1, 'Liga 1', 2, NULL, 1)
ON CONFLICT DO NOTHING;

-- Reset sequences
SELECT setval('seasons_id_seq', (SELECT MAX(id) FROM seasons));
SELECT setval('conferences_id_seq', (SELECT MAX(id) FROM conferences));
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
