-- ========================================
-- AUTHENTICATION CREDENTIALS
-- ========================================
-- Set email addresses and passwords for users who need web login access
-- This runs after users are scraped (08a/08b) but before role assignments (51-admins, etc.)

-- James Breslin - Club Administrator
-- Update scraped user record with email and password for web login
UPDATE users 
SET 
    email = 'soccer@lighthouse1893.org',
    password_hash = crypt('1893Soccer!', gen_salt('bf')),
    preferred_name = 'James'
WHERE 
    id = '311ee799-a6a1-450f-8bad-5140a021c92b';
