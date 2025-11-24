-- ========================================
-- MANUAL SPORT DIVISIONS
-- ========================================
-- Manually managed sport divisions
-- Note: Lighthouse is also in APSL scrape, but this ensures it exists before scraper runs

-- Lighthouse 1893 SC Men's Soccer division
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES (
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4b',
    'b89d4e7e-6c5a-4b3d-9e2f-1a8c7d6e5f4b',
    '550e8400-e29b-41d4-a716-446655440101',  -- Soccer sport_id
    'Men''s Soccer',
    'Lighthouse 1893 SC Men''s Soccer',
    'mens-soccer',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    updated_at = CURRENT_TIMESTAMP;
