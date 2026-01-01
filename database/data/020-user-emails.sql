-- Person-emails - Foundation Data
-- Emails belong to persons (used for login when person has user account)

-- Email for James Breslin
INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified)
VALUES (
    1,
    'soccer@lighthouse1893.org',
    1,  -- 1 = personal (from email_types lookup)
    true,
    true
) ON CONFLICT (email) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified;

