-- Link external_identities to users based on team context and name/email matching
-- This script runs after all data is loaded and handles auto-linking of external records
-- Priority order: team+name match, then email match, then leave unlinked for manual resolution

-- Priority 1: Link by team_id + first_name + last_name match (most reliable)
-- This handles cases where the external record has parsed names that match exactly
UPDATE user_external_identities uei
SET user_id = u.id
WHERE uei.user_id IS NULL
  AND uei.team_id IS NOT NULL
  AND uei.first_name IS NOT NULL
  AND uei.last_name IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM team_players tp
    WHERE tp.team_id = uei.team_id
      AND tp.player_id = u.id
  )
  AND LOWER(TRIM(u.first_name)) = LOWER(TRIM(uei.first_name))
  AND LOWER(TRIM(u.last_name)) = LOWER(TRIM(uei.last_name));

-- Priority 2: Link by email (if available and unique)
-- This handles cases where email is the only reliable identifier
UPDATE user_external_identities uei
SET user_id = u.id
WHERE uei.user_id IS NULL
  AND uei.email IS NOT NULL
  AND u.email IS NOT NULL
  AND LOWER(TRIM(u.email)) = LOWER(TRIM(uei.email))
  -- Only link if there's a single match (prevent ambiguous linking)
  AND (
    SELECT COUNT(*)
    FROM users u2
    WHERE LOWER(TRIM(u2.email)) = LOWER(TRIM(uei.email))
  ) = 1;

-- Log any remaining unlinked external_identities for manual review
-- These would benefit from UI-based linking in the division roster editor
SELECT
  COUNT(*) as total_unlinked,
  provider_id,
  COUNT(CASE WHEN team_id IS NOT NULL THEN 1 END) as with_team_context,
  COUNT(CASE WHEN email IS NOT NULL THEN 1 END) as with_email,
  COUNT(CASE WHEN first_name IS NOT NULL AND last_name IS NOT NULL THEN 1 END) as with_names
FROM user_external_identities
WHERE user_id IS NULL
GROUP BY provider_id;
