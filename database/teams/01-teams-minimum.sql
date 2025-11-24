-- ========================================
-- LIGHTHOUSE 1893 SC TEAM
-- ========================================
-- Core Lighthouse team (always loaded)

-- Insert Lighthouse 1893 SC club
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

-- Insert sport division for Lighthouse (Men's Soccer)
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

-- Insert Lighthouse 1893 SC team
INSERT INTO teams (id, name, division_id, season, is_active)
VALUES (
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',
    'Lighthouse 1893 SC',
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4b',
    '2024-2025',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    updated_at = CURRENT_TIMESTAMP;

-- Assign jbreslin as coach to Lighthouse 1893 SC
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000001-0000-0000-0000-000000000001',
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',  -- Lighthouse team
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- jbreslin
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;
