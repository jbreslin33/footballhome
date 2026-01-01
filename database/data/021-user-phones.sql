-- User-phones - Foundation Data
-- This file contains core/foundational data for user-phones that always loads.
-- Tables 001-012 (lookup tables) have data inline in schema, this file is optional.

-- Phone for James Breslin
INSERT INTO user_phones (user_id, phone_number, phone_type_id, is_primary, is_verified, can_receive_sms, can_receive_calls)
VALUES (
    1,
    '+12158284924',
    1,  -- 1 = mobile (from phone_types lookup)
    true,
    true,
    true,
    true
) ON CONFLICT (phone_number) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified;
