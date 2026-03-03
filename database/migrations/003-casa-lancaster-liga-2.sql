-- Migration 003: Add CASA Lancaster Liga 2 division
--
-- Lancaster Liga 2 launched for spring 2026 with 4 teams:
--   - Lancaster Bible College
--   - Millersville Men's Club Soccer
--   - YorkPA FC
--   - West Chester University Club
--
-- Uses Lancaster Conference (conference_id=26), season 2025/2026 (season_id=5)
-- SportsEngine page_node_id: 9270318

INSERT INTO divisions (id, season_id, conference_id, name, external_id, source_system_id, sort_order) VALUES
(70, 5, 26, 'Lancaster Liga 2', '9270318', 2, 5)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    external_id = EXCLUDED.external_id,
    sort_order = EXCLUDED.sort_order;

SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
