-- ========================================
-- CONSOLIDATE LIGHTHOUSE CLUBS
-- ========================================
-- Merge Lighthouse Boys Club and Old Timers into Lighthouse 1893
-- Create single sport division that contains all 3 teams

-- Step 1: Create the unified sport division for Lighthouse 1893
-- This will be "Lighthouse 1893 SC" that contains all 3 teams
INSERT INTO sport_divisions (id, club_id, display_name)
VALUES (
    'c8b1a1b1-0000-0000-0000-000000000001',
    'd37eb44b-8e47-0003-9060-f0cbe96fe089',
    'Lighthouse 1893 SC'
)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Move Lighthouse Boys Club team to the unified division
UPDATE teams
SET division_id = 'c8b1a1b1-0000-0000-0000-000000000001'
WHERE id = '04b164cd-4e35-4302-84b0-60e2a5e71500'
  AND name = 'Lighthouse Boys Club';

-- Step 3: Move Lighthouse Old Timers team to the unified division
UPDATE teams
SET division_id = 'c8b1a1b1-0000-0000-0000-000000000001'
WHERE id = '449ef257-2d8f-43c0-8ae1-6374894d17f1'
  AND name = 'Lighthouse Old Timers';

-- Step 4: Move the APSL Lighthouse 1893 SC team to the unified division
UPDATE teams
SET division_id = 'c8b1a1b1-0000-0000-0000-000000000001'
WHERE id = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'
  AND name = 'Lighthouse 1893 SC';

