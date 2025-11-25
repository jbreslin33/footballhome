-- ========================================
-- ALL COACHES
-- ========================================
-- All coaches in the system
-- This file is idempotent - can be run multiple times safely

-- jbreslin@footballhome.org coach entity
INSERT INTO coaches (id, coaching_license, license_expiry, years_experience, bio)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'USSF B License',
    '2026-12-31',
    15,
    'Experienced coach with 15 years in youth soccer development. Focuses on technical skills and positive team culture.'
)
ON CONFLICT (id) DO UPDATE SET
    coaching_license = EXCLUDED.coaching_license,
    license_expiry = EXCLUDED.license_expiry,
    years_experience = EXCLUDED.years_experience,
    bio = EXCLUDED.bio,
    updated_at = CURRENT_TIMESTAMP;

-- APSL Coaches (if any need to be added)
-- TODO: Add other coaches as needed
