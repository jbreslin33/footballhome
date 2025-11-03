-- Leagues Data
-- Shared leagues that multiple clubs can participate in

-- Soccer Leagues
INSERT INTO leagues (name, display_name, sport_id, season, description) VALUES
('APSL',
 'American Premier Soccer League', 
 (SELECT id FROM sports WHERE name = 'soccer'),
 '2024/25',
 'Men''s premier soccer league competition')
ON CONFLICT (name, sport_id, season) DO NOTHING;