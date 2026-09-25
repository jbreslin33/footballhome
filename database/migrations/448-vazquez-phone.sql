-- 448 (2026-09-25) — Joseph Vazquez's mobile.
-- Owner: "vazquez phone is 4849298861".  Person 22277 had no phone row.
INSERT INTO person_phones (person_id, phone_number, is_primary, can_receive_sms, can_receive_calls)
SELECT 22277, '+14849298861', true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM person_phones WHERE person_id = 22277 AND phone_number = '+14849298861');
