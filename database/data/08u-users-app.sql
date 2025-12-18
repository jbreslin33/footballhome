-- ========================================
-- DEV/STAGING APP-GENERATED USERS
-- ========================================
-- Users created via the web application in DEV environment
-- Auto-appended by backend on user creation/update
-- Loaded only when ENVIRONMENT=dev
-- ========================================

-- Test write

-- Direct write test from UserService
UPDATE users SET updated_at = CURRENT_TIMESTAMP, first_name = 'Nick', last_name = 'Webster', email = 'nick.webster@email.com', phone = '555-1234', date_of_birth = '1990-06-15' WHERE id = '9c68fa90-3438-40ff-8846-7d312863c628';

-- Logged at: 2025-12-18 18:58:57
UPDATE users SET updated_at = CURRENT_TIMESTAMP, first_name = 'Nick', last_name = 'Webster', email = 'nick.webster@email.com', phone = '555-1234', date_of_birth = '1990-06-15' WHERE id = '9c68fa90-3438-40ff-8846-7d312863c628';
