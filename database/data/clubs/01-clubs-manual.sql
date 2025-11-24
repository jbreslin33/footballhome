-- ========================================
-- MANUAL CLUBS
-- ========================================
-- Manually managed clubs
-- Note: Lighthouse is also in APSL scrape, but this ensures it exists before scraper runs

-- Lighthouse 1893 SC club
INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES (
    'b89d4e7e-6c5a-4b3d-9e2f-1a8c7d6e5f4b',
    'Lighthouse 1893 SC',
    'Lighthouse 1893 Soccer Club',
    'lighthouse-1893-sc',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    updated_at = CURRENT_TIMESTAMP;
