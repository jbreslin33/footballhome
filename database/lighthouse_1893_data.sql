-- Lighthouse 1893 Club Setup
-- Creates only the parent club - no fake data

-- Insert the Lighthouse 1893 parent club
INSERT INTO clubs (name, display_name, slug, description, founded_year, parent_club_id) 
VALUES (
    'Lighthouse 1893',
    'Lighthouse 1893 Soccer Club',
    'lighthouse-1893',
    'Soccer club founded in 1893',
    1893,
    NULL  -- Parent club
) ON CONFLICT (slug) DO NOTHING;

