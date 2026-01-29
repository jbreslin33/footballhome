-- ============================================================================
-- 052-matches-casa.sql
-- CASA Select Matches (2025/2026 Season)
-- Generated: 2026-01-29
-- Source: Scraped from casasoccerleagues.com
-- ============================================================================
--
-- Total matches: 34
-- Divisions: 4
--

-- Philadelphia Liga 1 (Division 54)
-- Matches: 10

-- Lighthouse Boys Club vs Illyrians FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Lighthouse Boys Club' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Illyrians FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-0'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Lighthouse Boys Club' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Illyrians FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 3, 
    away_score = 6,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-0';

-- Phoenix SCM vs Oaklyn United FC II (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Phoenix SCM' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Oaklyn United FC II' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '14:30:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-1'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix SCM' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Oaklyn United FC II' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 3, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-1';

-- Philadelphia Sierra Stars vs Adé United FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Adé United FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '13:30:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-2'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Adé United FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-2';

-- Phoenix Reserves vs Persepolis FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Phoenix Reserves' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '11:45:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-3'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix Reserves' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 3, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-3';

-- Lighthouse Old Timers Club vs Philly BlackStars (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Philly BlackStars' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '09:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-4'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Philly BlackStars' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-4';

-- Philadelphia SC II vs Oaklyn United FC II (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Philadelphia SC II' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Oaklyn United FC II' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '20:45:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-5'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Philadelphia SC II' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Oaklyn United FC II' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-5';

-- Illyrians FC vs Adé United FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Illyrians FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Adé United FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '19:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-6'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Illyrians FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Adé United FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 3, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-6';

-- Philadelphia Sierra Stars vs Philly BlackStars (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Philly BlackStars' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '20:45:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-7'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Philly BlackStars' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-7';

-- Phoenix SCM vs Persepolis FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Phoenix SCM' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '20:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-8'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix SCM' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-8';

-- Lighthouse Old Timers Club vs Persepolis FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090889-9'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Persepolis FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 9, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090889-9';


-- Philadelphia Liga 2 (Division 55)
-- Matches: 4

-- Lighthouse Old Timers Club vs Phoenix SCR (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '13:30:00'::time,
    2, -- CASA source_system_id
    'casa-9096430-10'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9096430-10';

-- Philadelphia SC II vs Phoenix SCR (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Philadelphia SC II' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '14:45:00'::time,
    2, -- CASA source_system_id
    'casa-9096430-11'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Philadelphia SC II' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9096430-11';

-- Illyrians vs Phoenix SCR (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Illyrians' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '19:30:00'::time,
    2, -- CASA source_system_id
    'casa-9096430-12'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Illyrians' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Phoenix SCR' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9096430-12';

-- Persepolis United FC II vs Lighthouse Old Timers Club (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Persepolis United FC II' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '14:45:00'::time,
    2, -- CASA source_system_id
    'casa-9096430-13'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Persepolis United FC II' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Lighthouse Old Timers Club' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 8,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9096430-13';


-- Boston Liga 1 (Division 56)
-- Matches: 10

-- South Shore FC vs Strictly Nos Fc (Scheduled)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '12:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-14'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2);

-- South Shore FC vs Flatley FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '18:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-15'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 5,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-15';

-- BCFC All Stars vs Strictly Nos Fc (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'BCFC All Stars' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '14:30:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-16'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'BCFC All Stars' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 2,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-16';

-- Gambeta FC vs Jaguars United FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '12:30:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-17'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 10, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-17';

-- Gambeta FC vs Flatley FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '20:15:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-18'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 6, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-18';

-- Jaguars United FC vs BCFC All Stars (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'BCFC All Stars' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '18:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-19'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'BCFC All Stars' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 4,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-19';

-- Flatley FC vs Gambeta FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '12:15:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-20'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 4, 
    away_score = 7,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-20';

-- Strictly Nos Fc vs South Shore FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-21'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'South Shore FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-21';

-- Jaguars United FC vs Flatley FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '18:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-22'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Jaguars United FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Flatley FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 8,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-22';

-- Gambeta FC vs Strictly Nos Fc (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:45:00'::time,
    2, -- CASA source_system_id
    'casa-9090891-23'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Gambeta FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Strictly Nos Fc' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 8, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090891-23';


-- Lancaster Liga 1 (Division 57)
-- Matches: 10

-- F&M FC vs Lancaster City FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'F&M FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '13:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-24'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'F&M FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-24';

-- Kutztown Men's Soccer vs Keystone Elite (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '12:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-25'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-25';

-- Alloy Soccer Club Reserves vs Kutztown Men's Soccer (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '18:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-26'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-26';

-- Keystone Elite vs F&M FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'F&M FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-27'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'F&M FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-27';

-- Keystone Elite vs Alloy Soccer Club Reserves (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-28'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 3, 
    away_score = 2,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-28';

-- Kutztown Men's Soccer vs Lancaster City FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '13:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-29'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 2, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-29';

-- Lancaster City FC vs Alloy Soccer Club Reserves (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '16:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-30'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 0,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-30';

-- Kutztown Men's Soccer vs F&M FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'F&M FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '16:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-31'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Kutztown Men''s Soccer' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'F&M FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 1, 
    away_score = 1,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-31';

-- Alloy Soccer Club Reserves vs F&M FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'F&M FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '19:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-32'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'F&M FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 0, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-32';

-- Keystone Elite vs Lancaster City FC (Final)
INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2),
    3,
    '2025-09-15'::date,
    '15:00:00'::time,
    2, -- CASA source_system_id
    'casa-9090893-33'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = 'Keystone Elite' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = 'Lancaster City FC' AND source_system_id = 2);

-- Update score for completed match
UPDATE matches 
SET home_score = 4, 
    away_score = 3,
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-9090893-33';


-- ============================================================================
-- Summary
-- ============================================================================
-- Total matches inserted: 34
-- Note: Matches with missing teams (not in database) will be skipped
-- Missing teams detected: Philadelphia Sierra Stars, Phoenix Reserves, Philly BlackStars
-- These teams need to be added or mapped to existing teams
