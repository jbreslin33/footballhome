-- 447 (2026-09-25) — Michael Lopez's mobile.
-- Owner: "lopez phone is 2678158593".  Person 22439 had no phone row at
-- all, so texts (RSVP reminders, lock-up alerts) could not reach him.
-- E.164 like every other row.
INSERT INTO person_phones (person_id, phone_number, is_primary, can_receive_sms, can_receive_calls)
SELECT 22439, '+12678158593', true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM person_phones WHERE person_id = 22439 AND phone_number = '+12678158593');
