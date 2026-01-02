-- Person-phones - Foundation Data
-- Phones belong to persons

-- Phone for James Breslin
INSERT INTO person_phones (person_id, phone_number, phone_type_id, is_primary, is_verified, can_receive_sms, can_receive_calls)
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
