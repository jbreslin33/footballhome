-- ========================================
-- Fix Broken Player Names
-- ========================================
-- Some player names were imported with jersey numbers or special characters
-- This script fixes those records

-- Fix Joaquin Ladeuix (was "11 "Joaquin)
UPDATE users 
SET first_name = 'Joaquin', 
    last_name = 'Ladeuix',
    updated_at = CURRENT_TIMESTAMP
WHERE id = '1b32de71-7367-5a7f-b486-5532b184e2b6'
  AND (first_name = '11' OR first_name LIKE '%Joaquin%');

-- Verify the fix
SELECT 'Joaquin Ladeuix fixed' as status, 
       (SELECT COUNT(*) FROM users WHERE first_name = 'Joaquin' AND last_name = 'Ladeuix') as count;
