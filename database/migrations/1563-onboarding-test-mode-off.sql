-- 1563 (2026-11-19) — 🧪 onboarding TEST MODE OFF (after the owner's phone NSOR
-- test + a server-side run of every step: uploads, refuse non-documents,
-- check, redo, re-upload, both email stages — all passed).  Real addresses
-- back: both stages → Yineska (compliance.director@lighthouse1893.org), NSOR →
-- the state (RA-PWNSOR@pa.gov).  The owner's test record and test files go.
UPDATE onboarding_stages SET email_to = 'compliance.director@lighthouse1893.org' WHERE stage IN ('volunteer', 'paid');
UPDATE message_templates SET body = 'RA-PWNSOR@pa.gov', updated_at = now() WHERE kind = 'onboarding' AND tier = 'nsor_to';
DELETE FROM person_onboarding_files        WHERE person_id = 1;
DELETE FROM person_onboarding_steps        WHERE person_id = 1;
DELETE FROM person_onboarding_stage_sends  WHERE person_id = 1;
DELETE FROM person_onboarding              WHERE person_id = 1 AND note = '🧪 test';
