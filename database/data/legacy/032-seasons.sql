-- Seasons
-- Seasons belong to leagues and represent a competition year
-- 
-- This file contains manually-managed seasons for APSL and CSL.
-- Seasons are named in "YYYY/YYYY" format for leagues that span calendar years.

-- APSL Seasons
INSERT INTO seasons (id, league_id, name, is_active) VALUES
(1, 1, '2025/2026', true),
(2, 1, '2022/2023', false),
(3, 1, '2023/2024', false),
(4, 1, '2024/2025', false);

-- CASA Select Seasons (Fall/Spring format like APSL/CSL)
INSERT INTO seasons (id, league_id, name, is_active) VALUES
(5, 2, '2025/2026', true);

-- CASA Traditional Seasons (not yet implemented)
-- Note: Traditional uses single-season format: "Fall 2025", "Spring 2026" (not "2025/2026")

-- CSL Seasons
INSERT INTO seasons (id, league_id, name, is_active) VALUES
(6, 4, '2025/2026', true),
(7, 4, '2022/2023', false),
(8, 4, '2023/2024', false),
(9, 4, '2024/2025', false);

-- EPSA Open State Cup Seasons
INSERT INTO seasons (id, league_id, name, is_active) VALUES
(10, 5, '2025/2026', true);

-- Update sequence
SELECT setval('seasons_id_seq', (SELECT MAX(id) FROM seasons));
