-- Create users and players from unlinked external identities
-- This script runs after 80-link-external-identities-to-users.sql
-- It handles the creation of new user accounts for people found in chats who don't exist yet

-- Use a DO block to handle the dependency order (User must exist before linking)
DO $$
DECLARE
    r RECORD;
    new_uid UUID;
    counter INTEGER := 0;
BEGIN
    FOR r IN 
        SELECT id, first_name, last_name 
        FROM user_external_identities 
        WHERE user_id IS NULL 
          AND first_name IS NOT NULL 
          AND last_name IS NOT NULL
    LOOP
        new_uid := uuid_generate_v4();
        
        -- 1. Create User
        INSERT INTO users (id, first_name, last_name, is_active, created_at, updated_at)
        VALUES (new_uid, r.first_name, r.last_name, true, NOW(), NOW());
        
        -- 2. Create Player
        INSERT INTO players (id) VALUES (new_uid);
        
        -- 3. Link Identity
        UPDATE user_external_identities
        SET user_id = new_uid
        WHERE id = r.id;
        
        counter := counter + 1;
    END LOOP;
    
    RAISE NOTICE 'Created % new users from external identities', counter;
END $$;

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
    COUNT(*) as total_linked_identities,
    COUNT(DISTINCT team_id) as teams_affected
FROM user_external_identities
WHERE user_id IS NOT NULL;
