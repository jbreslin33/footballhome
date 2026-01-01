-- User-emails - Foundation Data
-- This file contains core/foundational data for user-emails that always loads.
-- Tables 001-012 (lookup tables) have data inline in schema, this file is optional.

-- Email for James Breslin
INSERT INTO user_emails (user_id, email, email_type_id, is_primary, is_verified)
VALUES (
    1,
    'soccer@lighthouse1893.org',
    1,  -- 1 = personal (from email_types lookup)
    true,
    true
) ON CONFLICT (email) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified;

