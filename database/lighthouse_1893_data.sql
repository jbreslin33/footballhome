-- Lighthouse 1893 Club Setup (Normalized Structure)
-- Creates pure organizational club and sport-specific division

-- Insert the Lighthouse 1893 organization (pure organizational entity)
INSERT INTO clubs (name, display_name, slug, description, founded_year, parent_club_id) 
VALUES (
    'Lighthouse 1893',
    'Lighthouse 1893',
    'lighthouse-1893',
    'Multi-sport athletic organization founded in 1893',
    1893,
    NULL  -- Parent organization
) ON CONFLICT (slug) DO NOTHING;

-- Insert the Soccer Division (sport-specific division within the club)
INSERT INTO sport_divisions (club_id, sport_id, name, display_name, slug, description) 
VALUES (
    (SELECT id FROM clubs WHERE slug = 'lighthouse-1893'),
    (SELECT id FROM sports WHERE name = 'soccer'),
    'Soccer Division',
    'Lighthouse 1893 Soccer Club',
    'lighthouse-1893-soccer',
    'Soccer division of Lighthouse 1893 athletic organization'
) ON CONFLICT (club_id, sport_id, slug) DO NOTHING;

-- Insert the teams
INSERT INTO teams (name, division_id, age_group, skill_level, season, description) VALUES
('Lighthouse 1893 SC', 
 (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-soccer'), 
 'Adult', 'First Team', '2024/25', 'Men''s first team'),

('Lighthouse Women''s Club', 
 (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-soccer'), 
 'Adult', 'First Team', '2024/25', 'Women''s team'),

('Lighthouse Boys Club', 
 (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-soccer'), 
 'Youth', 'Competitive', '2024/25', 'Boys youth team'),

('Lighthouse Old Timers Club', 
 (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-soccer'), 
 'Adult', 'Recreational', '2024/25', 'Veterans/older players team');

-- Assign Lighthouse 1893 SC to APSL Delaware River Conference Premier Division
UPDATE teams 
SET league_division_id = (
    SELECT ld.id 
    FROM league_divisions ld
    JOIN league_conferences lc ON ld.conference_id = lc.id
    JOIN leagues l ON lc.league_id = l.id
    WHERE l.name = 'APSL' AND lc.slug = 'delaware-river' AND ld.slug = 'premier'
)
WHERE name = 'Lighthouse 1893 SC';

