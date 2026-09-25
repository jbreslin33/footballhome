-- 449 (2026-09-25) — Yancarlo Corredor's mobile is his primary.
-- Owner: "yancarlo phone 267 298 6027" — already on file (person 22221),
-- just not flagged primary.
UPDATE person_phones SET is_primary = true, can_receive_sms = true, can_receive_calls = true
 WHERE person_id = 22221 AND phone_number = '+12672986027';
UPDATE person_phones SET is_primary = false
 WHERE person_id = 22221 AND phone_number <> '+12672986027';
