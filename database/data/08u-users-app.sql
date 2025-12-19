-- ========================================
-- DEV/STAGING APP-GENERATED USERS
-- ========================================
-- Users created via the web application in DEV environment
-- Auto-appended by backend on user creation/update
-- Loaded only when ENVIRONMENT=dev
-- ========================================

-- Logged at: 2025-12-18 20:00:00
-- Add phone field to users table for SMS notifications
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

