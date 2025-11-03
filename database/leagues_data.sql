-- Leagues Data
-- Shared leagues that multiple clubs can participate in

-- Soccer Leagues
INSERT INTO leagues (name, display_name, sport_id, season, description) 
SELECT 'APSL', 'American Premier Soccer League', s.id, '2024/25', 'Men''s premier soccer league competition'
FROM sports s 
WHERE s.name = 'soccer' 
AND NOT EXISTS (
    SELECT 1 FROM leagues l 
    WHERE l.name = 'APSL' AND l.sport_id = s.id AND l.season = '2024/25'
);