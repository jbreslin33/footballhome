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

-- APSL League Conferences (from 2025/2026 standings)
INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Mayflower', 'Mayflower Conference', 'mayflower', 'New England region conference'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'mayflower');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Constitution', 'Constitution Conference', 'constitution', 'Connecticut and surrounding areas'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'constitution');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Metropolitan', 'Metropolitan Conference', 'metropolitan', 'New York metropolitan area'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'metropolitan');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Delaware River', 'Delaware River Conference', 'delaware-river', 'Philadelphia and New Jersey area'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'delaware-river');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Mid-Atlantic', 'Mid-Atlantic Conference', 'mid-atlantic', 'Virginia, Maryland, and Mid-Atlantic region'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'mid-atlantic');

INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Terminus', 'Terminus Conference', 'terminus', 'Georgia and Southeast region'
FROM leagues l 
WHERE l.name = 'APSL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'terminus');

-- APSL Conference Divisions (single Premier division per conference per bylaws)
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'mayflower'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'constitution'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'metropolitan'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'delaware-river'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'mid-atlantic'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Premier', 'Premier Division', 'premier', 1, 'Premier', 'Adult', 'Premier level competition'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'APSL' AND lc.slug = 'terminus'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'premier');

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
SELECT l.id, 'Central New Jersey', 'Central New Jersey Conference', 'central-new-jersey', 'Teams from Central New Jersey region'
FROM leagues l 
WHERE l.name = 'CASA' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'central-new-jersey');

-- Philadelphia Conference Divisions
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Liga 1', 'Liga 1', 'liga-1', 1, 'Premier', 'Adult', 'Top tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'philadelphia'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'liga-1');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Liga 2', 'Liga 2', 'liga-2', 2, 'Competitive', 'Adult', 'Second tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'philadelphia'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'liga-2');

-- Lancaster Conference Division
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Liga 1', 'Liga 1', 'liga-1', 1, 'Premier', 'Adult', 'Top tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'lancaster'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'liga-1');

-- Central New Jersey Conference Division
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Liga 1', 'Liga 1', 'liga-1', 1, 'Premier', 'Adult', 'Top tier competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'CASA' AND lc.slug = 'central-new-jersey'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'liga-1');

-- TCWL League Conference (single conference structure for smaller league)
INSERT INTO league_conferences (league_id, name, display_name, slug, description)
SELECT l.id, 'Main', 'Main Conference', 'main', 'Main conference for Tri County Women''s League'
FROM leagues l 
WHERE l.name = 'TCWL' AND l.season = '2024/25'
AND NOT EXISTS (SELECT 1 FROM league_conferences lc WHERE lc.league_id = l.id AND lc.slug = 'main');

-- TCWL League Divisions
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Division 1', 'Division 1', 'division-1', 1, 'Premier', 'Adult', 'Top tier women''s competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'TCWL' AND lc.slug = 'main'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'division-1');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Division 2', 'Division 2', 'division-2', 2, 'Competitive', 'Adult', 'Second tier women''s competitive division'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'TCWL' AND lc.slug = 'main'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'division-2');

INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, skill_level, age_group, description)
SELECT lc.id, 'Division 3', 'Division 3', 'division-3', 3, 'Recreational', 'Adult', 'Women''s recreational division for casual play'
FROM league_conferences lc 
JOIN leagues l ON lc.league_id = l.id 
WHERE l.name = 'TCWL' AND lc.slug = 'main'
AND NOT EXISTS (SELECT 1 FROM league_divisions ld WHERE ld.conference_id = lc.id AND ld.slug = 'division-3');