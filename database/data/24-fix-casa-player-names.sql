-- ========================================
-- FIX CASA PLAYER NAMES
-- ========================================
-- Purpose: Normalize CASA player names after import
--
-- Issue: External identities import has:
--   - Jersey number as users.first_name
--   - Player first name as users.last_name
--   - Player last name in external_data.jersey_number
--
-- Solution: Update users to have correct first_name and last_name
-- This runs AFTER 23-external-identities-casa.sql loads the raw data

UPDATE users u
SET 
    first_name = uei.last_name,  -- Omar, Edwin, Miles, etc.
    last_name = uei.external_data->>'jersey_number',  -- Alzubair, Garcia, Henry, etc.
    updated_at = CURRENT_TIMESTAMP
FROM user_external_identities uei
WHERE u.id = uei.user_id
  AND uei.provider = 'casa'
  AND uei.external_data->>'jersey_number' IS NOT NULL
  AND uei.external_data->>'jersey_number' != '';

-- Verify the fix
SELECT 
    COUNT(*) as players_fixed,
    'CASA player names corrected' as status
FROM users u
JOIN user_external_identities uei ON u.id = uei.user_id
WHERE uei.provider = 'casa';
