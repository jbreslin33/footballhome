-- ========================================
-- MIGRATION: Fix CASA Player Names
-- ========================================
-- Purpose: Normalize CASA player names in users table
-- 
-- Issue: CASA external_identities were imported with:
--   - Jersey number as first_name
--   - Player first name as last_name
--   - Player last name in external_data.jersey_number
--
-- Fix: Update users table to have proper first_name, last_name
--
-- Generated: 2025-12-14

BEGIN;

-- Create temporary table to map correct names
CREATE TEMP TABLE casa_name_fixes AS
SELECT 
    u.id,
    uei.last_name as correct_first_name,
    (uei.external_data->>'jersey_number')::text as correct_last_name
FROM users u
JOIN user_external_identities uei ON u.id = uei.user_id
WHERE uei.provider = 'casa'
  AND uei.external_data->>'jersey_number' IS NOT NULL
  AND uei.external_data->>'jersey_number' != '';

-- Update users with correct first and last names
UPDATE users u
SET 
    first_name = cnf.correct_first_name,
    last_name = cnf.correct_last_name,
    updated_at = CURRENT_TIMESTAMP
FROM casa_name_fixes cnf
WHERE u.id = cnf.id;

-- Report the changes
SELECT 
    COUNT(*) as players_updated,
    'CASA player names normalized' as action
FROM casa_name_fixes;

COMMIT;
