-- Manual User Additions
-- Add users not in scraped rosters (coaches, parents, etc.)
-- NOTE: Admin credentials are set in 51-admins.sql

-- James Breslin phone number
UPDATE users 
SET phone = '+12158284924' 
WHERE email = 'soccer@lighthouse1893.org';
