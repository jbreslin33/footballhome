-- Post-Load Processing
-- This script runs after all scraped data is loaded
-- Handles: external identity linking, coach assignments, and other post-scrape setup

-- ============================================================================
-- SECTION 1: Assign Coaches to Teams
-- ============================================================================

-- Assign James Breslin as head coach to all Lighthouse teams
INSERT INTO team_coaches (team_id, coach_id, coach_role_id, is_active)
SELECT 
    t.id,
    1,  -- coach_id=1 (James Breslin from coaches table)
    1,  -- coach_role_id=1 (head_coach from coach_roles lookup)
    true
FROM teams t
JOIN sport_divisions sd ON t.sport_division_id = sd.id
JOIN clubs c ON sd.club_id = c.id
WHERE c.slug = 'lighthouse-1893-sc'
ON CONFLICT (team_id, coach_id) DO NOTHING;

-- ============================================================================
-- SECTION 2: Link External Identities to Users
-- ============================================================================
-- Auto-link external records (GroupMe, etc.) to Football Home users
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
    SELECT 1 FROM team_division_players tp
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
