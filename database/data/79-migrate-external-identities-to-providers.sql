-- Migration: Convert user_external_identities from string provider to provider_id lookup
-- This script migrates existing data to use the new external_providers table
-- Note: The schema was updated to have provider_id as FK to external_providers table

-- Verify migration - show current state
SELECT 
    ep.name as provider,
    COUNT(*) as total,
    COUNT(CASE WHEN uei.user_id IS NOT NULL THEN 1 END) as linked,
    COUNT(CASE WHEN uei.user_id IS NULL THEN 1 END) as unlinked
FROM user_external_identities uei
LEFT JOIN external_providers ep ON uei.provider_id = ep.id
GROUP BY ep.name
ORDER BY COUNT(*) DESC;
