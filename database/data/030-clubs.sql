-- Clubs (Football Home club data)
-- Clubs using Football Home platform for team management
-- Each club can have multiple sport divisions (teams grouped by age/competition)

INSERT INTO clubs (id, display_name, slug, is_active) VALUES
    (1, 'Lighthouse 1893 SC', 'lighthouse-1893', true)
ON CONFLICT (id) DO NOTHING;
