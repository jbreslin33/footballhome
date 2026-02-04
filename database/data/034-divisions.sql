-- Divisions
-- Divisions belong to conferences and seasons
-- Teams are assigned to divisions via the division_teams junction table
-- 
-- This file contains manually-managed division structures for APSL and CSL.

-- ==================================================
-- APSL 2022/2023 Divisions (season_id=2)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(7, 2, 7, 'Northeast-Fall', 1),
(8, 2, 8, 'Metropolitan', 1),
(9, 2, 9, 'Delaware River', 1),
(10, 2, 10, 'Mid-Atlantic-Fall', 1)
ON CONFLICT (id) DO NOTHING;

-- ==================================================
-- APSL 2023/2024 Divisions (season_id=3)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(11, 3, 11, 'Northeast-Fall', 1),
(12, 3, 12, 'Northeast-Spring', 1),
(13, 3, 13, 'Metropolitan', 1),
(14, 3, 14, 'Delaware River', 1),
(15, 3, 15, 'Mid-Atlantic-Fall', 1),
(16, 3, 16, 'Mid-Atlantic-Spring', 1),
(17, 3, 17, 'State Cup', 1),
(18, 3, 18, 'Mid-Atlantic WL', 1)
ON CONFLICT (id) DO NOTHING;

-- ==================================================
-- APSL 2024/2025 Divisions (season_id=4)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(19, 4, 19, 'Mayflower Conference', 1),
(20, 4, 20, 'Constitution Conference', 1),
(21, 4, 21, 'Metropolitan Conference', 1),
(22, 4, 22, 'Delaware River Conference', 1),
(23, 4, 23, 'Mid-Atlantic Conference', 1)
ON CONFLICT (id) DO NOTHING;

-- ==================================================
-- APSL 2025/2026 Divisions (season_id=1)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(1, 1, 1, 'Mayflower Conference', 1),
(2, 1, 2, 'Constitution Conference', 1),
(3, 1, 3, 'Metropolitan Conference', 1),
(4, 1, 4, 'Delaware River Conference', 1),
(5, 1, 5, 'Mid-Atlantic Conference', 1),
(6, 1, 6, 'Terminus Conference', 1),
(24, 1, 7, 'Trinity Conference', 1)
ON CONFLICT (id) DO NOTHING;

-- ==================================================
-- CASA Select 2025/2026 Divisions (season_id=5)
-- See end of file for actual CASA division inserts
-- ==================================================

-- ==================================================
-- CSL 2025/2026 Divisions (season_id=6, conference_id=27)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(24, 6, 27, 'Division 1', 3, 1),
(25, 6, 27, 'Division 1 Reserve', 3, 2),
(26, 6, 27, 'Division 2', 3, 3),
(27, 6, 27, 'Division 2 Reserve', 3, 4),
(28, 6, 27, 'Division 3', 3, 5),
(29, 6, 27, 'Division 4', 3, 6),
(30, 6, 27, 'Over-40 Division', 3, 7);

-- ==================================================
-- CSL 2022/2023 Divisions (season_id=7, conference_id=28)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(31, 7, 28, 'Division 1', 3, 1),
(32, 7, 28, 'Division 1 Reserve', 3, 2),
(33, 7, 28, 'Division 2', 3, 3),
(34, 7, 28, 'Division 2 Reserve', 3, 4),
(35, 7, 28, 'Division 3', 3, 5),
(36, 7, 28, 'Division 4', 3, 6),
(37, 7, 28, 'Spring Division', 3, 7),
(38, 7, 28, 'Over-40 Division', 3, 8);

-- ==================================================
-- CSL 2023/2024 Divisions (season_id=8, conference_id=29)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(39, 8, 29, 'Division 1', 3, 1),
(40, 8, 29, 'Division 1 Reserve', 3, 2),
(41, 8, 29, 'Division 2', 3, 3),
(42, 8, 29, 'Division 2 Reserve', 3, 4),
(43, 8, 29, 'Division 3', 3, 5),
(44, 8, 29, 'Division 4', 3, 6),
(45, 8, 29, 'Spring Division', 3, 7),
(46, 8, 29, 'Over-40 Division', 3, 8);

-- ==================================================
-- CSL 2024/2025 Divisions (season_id=9, conference_id=30)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(47, 9, 30, 'Division 1', 3, 1),
(48, 9, 30, 'Division 1 Reserve', 3, 2),
(49, 9, 30, 'Division 2', 3, 3),
(50, 9, 30, 'Division 2 Reserve', 3, 4),
(51, 9, 30, 'Division 3', 3, 5),
(52, 9, 30, 'Division 4', 3, 6),
(53, 9, 30, 'Over-40 Division', 3, 7);

-- ==================================================
-- CASA 2025/2026 Divisions (season_id=5)
-- Philadelphia Conference (conference_id=24)
-- Boston Conference (conference_id=25)
-- Lancaster Conference (conference_id=26)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, external_id, source_system_id, sort_order) VALUES
(54, 5, 24, 'Philadelphia Liga 1', '9090889', 2, 1),
(55, 5, 24, 'Philadelphia Liga 2', '9096430', 2, 2),
(56, 5, 25, 'Boston Liga 1', '9090891', 2, 3),
(57, 5, 26, 'Lancaster Liga 1', '9090893', 2, 4);

-- Update sequence
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
