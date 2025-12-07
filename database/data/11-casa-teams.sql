-- CASA Soccer League Data
-- Adds CASA League, Conferences, Divisions, and Lighthouse Teams

-- 1. Add CASA League
INSERT INTO leagues (name, display_name, sport_id, season, is_active)
VALUES (
    'CASA Soccer League', 
    'CASA Soccer League', 
    (SELECT id FROM sports WHERE name = 'soccer'), 
    '2025', 
    true
) ON CONFLICT DO NOTHING;

-- 2. Add CASA Conference (Philadelphia)
INSERT INTO league_conferences (league_id, name, display_name, slug, is_active)
VALUES (
    (SELECT id FROM leagues WHERE name = 'CASA Soccer League'),
    'Philadelphia',
    'Philadelphia Conference',
    'casa-philadelphia',
    true
) ON CONFLICT DO NOTHING;

-- 3. Add CASA Divisions (Liga 1, Liga 2)
INSERT INTO league_divisions (conference_id, name, display_name, slug, tier, is_active)
VALUES 
(
    (SELECT id FROM league_conferences WHERE slug = 'casa-philadelphia'),
    'Liga 1',
    'Liga 1',
    'casa-liga-1',
    1,
    true
),
(
    (SELECT id FROM league_conferences WHERE slug = 'casa-philadelphia'),
    'Liga 2',
    'Liga 2',
    'casa-liga-2',
    2,
    true
) ON CONFLICT DO NOTHING;

-- 4. Add Lighthouse Teams for CASA
-- Note: We assume 'Lighthouse 1893 SC' club and its sport division already exist from APSL data.
-- If not, we'd need to create them. But since Lighthouse is in APSL, the Club/Division should be there.

-- Lighthouse Boys Club (Liga 1)
INSERT INTO teams (id, name, division_id, league_division_id, is_active)
VALUES (
    'b0c1abb0-c1ab-0001-b0c1-ab0c1abb0c1a',  -- Fixed UUID for Boys Club
    'Lighthouse Boys Club',
    (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-sc-soccer'), -- Assumes this exists
    (SELECT id FROM league_divisions WHERE slug = 'casa-liga-1'),
    true
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    league_division_id = EXCLUDED.league_division_id,
    is_active = EXCLUDED.is_active;

-- Lighthouse Old Timers Club (Liga 2)
INSERT INTO teams (id, name, division_id, league_division_id, is_active)
VALUES (
    '01d71ee5-01d7-0002-1ee5-01d71ee501d7',  -- Fixed UUID for Old Timers
    'Lighthouse Old Timers Club',
    (SELECT id FROM sport_divisions WHERE slug = 'lighthouse-1893-sc-soccer'), -- Assumes this exists
    (SELECT id FROM league_divisions WHERE slug = 'casa-liga-2'),
    true
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    league_division_id = EXCLUDED.league_division_id,
    is_active = EXCLUDED.is_active;
