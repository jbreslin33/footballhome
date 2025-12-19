-- System User for Scraped Data
-- This user is referenced by schedule entries created by scrapers

INSERT INTO users (
  id, 
  email, 
  password_hash, 
  first_name, 
  last_name, 
  is_active, 
  created_at, 
  updated_at
) VALUES (
  '77d77471-1250-47e0-81ab-d4626595d63c',
  'system@footballhome.app',
  '$2a$10$dummyhashforsystemuseronly',  -- Not a valid login
  'System',
  'Scraper',
  true,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;
