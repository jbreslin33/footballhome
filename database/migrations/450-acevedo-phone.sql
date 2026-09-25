-- 450 (2026-09-25) — Anthony Acevedo's mobile.
-- Owner: "acevedo 215 618 5562".  Person 22397 had no phone row.
INSERT INTO person_phones (person_id, phone_number, is_primary, can_receive_sms, can_receive_calls)
SELECT 22397, '+12156185562', true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM person_phones WHERE person_id = 22397 AND phone_number = '+12156185562');
