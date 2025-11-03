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

INSERT INTO leagues (name, display_name, sport_id, season, description) 
SELECT 'TCWL', 'Tri County Women''s League', s.id, '2024/25', 'Women''s soccer league serving tri-county area'
FROM sports s 
WHERE s.name = 'soccer' 
AND NOT EXISTS (
    SELECT 1 FROM leagues l 
    WHERE l.name = 'TCWL' AND l.sport_id = s.id AND l.season = '2024/25'
);

-- CASA Soccer League with normalized conference/division structure
INSERT INTO leagues (name, display_name, sport_id, season, description) 
SELECT 'CASA', 'CASA Soccer League', s.id, '2024/25', 'Multi-conference soccer league with geographical divisions'
FROM sports s 
WHERE s.name = 'soccer' 
AND NOT EXISTS (
    SELECT 1 FROM leagues l 
    WHERE l.name = 'CASA' AND l.sport_id = s.id AND l.season = '2024/25'
);

-- CASA League Conferences
INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Philadelphia', 'Philadelphia Conference', 'philadelphia', 'Teams from Philadelphia metropolitan area'
FROM leagues l 
WHERE l.name = 'CASA' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'philadelphia');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Lancaster', 'Lancaster Conference', 'lancaster', 'Teams from Lancaster county area'
FROM leagues l 
WHERE l.name = 'CASA' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'lancaster');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'New Jersey', 'New Jersey Conference', 'new-jersey', 'Teams from New Jersey region'
FROM leagues l 
WHERE l.name = 'CASA' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'new-jersey');

-- Philadelphia Conference Divisions
INSERT INTO league_divisions (conference_id, name, display_name, slug, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 'Premier', 'Adult', 'Top tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'philadelphia'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, skill_level, age_group, description)
SELECT lc.id, 'Division 1', 'Division 1', 'division-1', 'Competitive', 'Adult', 'Second tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'philadelphia'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'division-1');

INSERT INTO league_divisions (conference_id, name, display_name, slug, skill_level, age_group, description)
SELECT lc.id, 'Over 30', 'Over 30 Division', 'over-30', 'Recreational', 'Over 30', 'Veterans division for players over 30'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'philadelphia'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'over-30');