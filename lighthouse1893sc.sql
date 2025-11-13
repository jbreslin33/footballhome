-- lighthouse1893sc.sql
-- SQL script to set up jbreslin@footballhome.org as both player and coach for Lighthouse 1893 SC

-- Team and User IDs (from database)
-- Team: Lighthouse 1893 SC - d37eb44b-8e47-0005-9060-f0cbe96fe089
-- User: James Breslin - 77d77471-1250-47e0-81ab-d4626595d63c

-- 1. Create player record for jbreslin (if not exists)
INSERT INTO players (id, preferred_position_id, height_cm, weight_kg, dominant_foot, notes, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    NULL,                                         -- Position will be set later
    180,                                          -- Height in cm
    75,                                           -- Weight in kg
    'Right',                                      -- Dominant foot
    'System administrator who also plays for the team',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 2. Create coach record for jbreslin (if not exists)
INSERT INTO coaches (id, coaching_license, license_expiry, years_experience, certifications, specializations, bio, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'USSF Level 1',                               -- Coaching license
    '2025-12-31',                                 -- License expiry
    5,                                            -- Years experience
    ARRAY['USSF Level 1', 'CPR Certified'],      -- Certifications array
    ARRAY['Youth Development', 'Technical Skills'], -- Specializations array
    'System administrator who also coaches the team',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 3. Add jbreslin as a player to Lighthouse 1893 SC team
INSERT INTO team_players (
    id,
    team_id,
    player_id,
    jersey_number,
    position_id,
    is_captain,
    is_vice_captain,
    is_active,
    joined_at,
    notes
) VALUES (
    uuid_generate_v4(),
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',  -- Lighthouse 1893 SC
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- James Breslin
    10,                                       -- Jersey number
    NULL,                                     -- Position (will be set later)
    false,                                    -- Not captain
    false,                                    -- Not vice captain
    true,                                     -- Active player
    CURRENT_TIMESTAMP,                        -- Joined at
    'System admin playing as #10'             -- Notes
) ON CONFLICT (team_id, player_id) DO NOTHING;

-- 4. Add jbreslin as a coach to Lighthouse 1893 SC team
INSERT INTO team_coaches (
    id,
    team_id,
    coach_id,
    coach_role,
    is_primary,
    is_active,
    joined_at,
    notes
) VALUES (
    uuid_generate_v4(),
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',  -- Lighthouse 1893 SC
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- James Breslin
    'assistant_coach',                        -- Coach role
    false,                                    -- Not primary coach
    true,                                     -- Active coach
    CURRENT_TIMESTAMP,                        -- Joined at
    'System admin also coaching the team'     -- Notes
) ON CONFLICT (team_id, coach_id) DO NOTHING;

-- 5. Verify the assignments
SELECT 'VERIFICATION RESULTS:' as result;

SELECT 
    'Player Assignment:' as type,
    u.name,
    u.email,
    t.name as team_name,
    tp.jersey_number,
    tp.is_active
FROM team_players tp
JOIN users u ON tp.player_id = u.id
JOIN teams t ON tp.team_id = t.id
WHERE u.email = 'jbreslin@footballhome.org';

SELECT 
    'Coach Assignment:' as type,
    u.name,
    u.email,
    t.name as team_name,
    tc.coach_role,
    tc.is_active
FROM team_coaches tc
JOIN users u ON tc.coach_id = u.id
JOIN teams t ON tc.team_id = t.id
WHERE u.email = 'jbreslin@footballhome.org';