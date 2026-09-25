-- 452 (2026-09-25) — Dani "Eddy" Ortiz: mobile + nickname.
-- Owner: "dani ortiz (eddy) is nickname phone 2159828781".  Person 22607
-- had no phone row, and persons had nowhere to keep a nickname — this
-- adds the column (not shown anywhere yet; boards still print the legal
-- first name).
ALTER TABLE persons ADD COLUMN IF NOT EXISTS nickname TEXT;
COMMENT ON COLUMN persons.nickname IS 'What people call them, when it is not first_name (mig 452). Not yet used by any screen.';
UPDATE persons SET nickname = 'Eddy' WHERE id = 22607 AND nickname IS DISTINCT FROM 'Eddy';
INSERT INTO person_phones (person_id, phone_number, is_primary, can_receive_sms, can_receive_calls)
SELECT 22607, '+12159828781', true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM person_phones WHERE person_id = 22607 AND phone_number = '+12159828781');
