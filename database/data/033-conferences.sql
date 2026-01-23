-- Conferences
-- Conferences belong to seasons and group divisions
-- APSL has multiple conferences per season, CSL has one "Main" conference
-- 
-- This file contains manually-managed conference structures.

-- APSL 2025/2026 Conferences
INSERT INTO conferences (id, season_id, name, is_active) VALUES
(1, 1, 'Mayflower Conference', true),
(2, 1, 'Constitution Conference', true),
(3, 1, 'Metropolitan Conference', true),
(4, 1, 'Delaware River Conference', true),
(5, 1, 'Mid-Atlantic Conference', true),
(6, 1, 'Terminus Conference', true);

-- APSL 2024/2025 Conferences
INSERT INTO conferences (id, season_id, name, is_active) VALUES
(19, 4, 'Mayflower Conference', false),
(20, 4, 'Constitution Conference', false),
(21, 4, 'Metropolitan Conference', false),
(22, 4, 'Delaware River Conference', false),
(23, 4, 'Mid-Atlantic Conference', false);

-- APSL 2023/2024 Conferences
INSERT INTO conferences (id, season_id, name, is_active) VALUES
(11, 3, 'Northeast Conference-Fall', false),
(12, 3, 'Northeast Conference-Spring', false),
(13, 3, 'Metropolitan Conference', false),
(14, 3, 'Delaware River Conference', false),
(15, 3, 'Mid-Atlantic Conference - Fall', false),
(16, 3, 'Mid-Atlantic Conference- Spring', false),
(17, 3, 'State Cup', false),
(18, 3, 'Mid-Atlantic WL', false);

-- APSL 2022/2023 Conferences  
INSERT INTO conferences (id, season_id, name, is_active) VALUES
(7, 2, 'Northeast Conference-Fall', false),
(8, 2, 'Metropolitan Conference', false),
(9, 2, 'Delaware River Conference', false),
(10, 2, 'Mid-Atlantic Conference - Fall', false);

-- CSL Conferences (one "Main" conference per season)
INSERT INTO conferences (id, season_id, name, is_active) VALUES
(24, 5, 'Main', true),   -- 2025/2026
(25, 6, 'Main', false),  -- 2022/2023
(26, 7, 'Main', false),  -- 2023/2024
(27, 8, 'Main', false);  -- 2024/2025

-- Update sequence
SELECT setval('conferences_id_seq', (SELECT MAX(id) FROM conferences));
