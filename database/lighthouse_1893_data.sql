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

