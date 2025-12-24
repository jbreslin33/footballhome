-- Create users and players from unlinked external identities
-- This script runs after 80-link-external-identities-to-users.sql
-- It handles the creation of new user accounts for people found in chats who don't exist yet

-- 1. Assign new User IDs to unlinked identities
-- We do this first so we have the IDs to insert into the users table
UPDATE user_external_identities
SET user_id = uuid_generate_v4()
WHERE user_id IS NULL
  AND first_name IS NOT NULL
  AND last_name IS NOT NULL;

-- 2. Create User records
INSERT INTO users (id, first_name, last_name, is_active, created_at, updated_at)
SELECT DISTINCT
    user_id,
    first_name,
    last_name,
    true,
    NOW(),
    NOW()
FROM user_external_identities
WHERE user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM users WHERE id = user_external_identities.user_id);

-- 3. Create Player records (all chat members are assumed to be players)
INSERT INTO players (id)
SELECT DISTINCT user_id
FROM user_external_identities
WHERE user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM players WHERE id = user_external_identities.user_id);

-- 4. Create Team Player records (roster entries)
-- Only for identities that have a team_id context
INSERT INTO team_players (team_id, player_id, is_active, joined_at)
SELECT DISTINCT
    team_id,
    user_id,
    true,
    NOW()
FROM user_external_identities
WHERE user_id IS NOT NULL
  AND team_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM team_players 
    WHERE team_id = user_external_identities.team_id 
      AND player_id = user_external_identities.user_id
  );

-- 5. Log results
SELECT 
    COUNT(*) as new_users_created,
    COUNT(DISTINCT team_id) as teams_affected
FROM user_external_identities
WHERE created_at > NOW() - INTERVAL '1 minute';
