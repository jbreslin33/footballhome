-- 411 — Ali Salah Alshami: the surname is Alshami.
--
-- 410 put the whole "Salah Alshami" in last_name, which files him under
-- S.  Owner 2026-09-23: "he is not getting put to top of list when i
-- sort alphabetically in teams" — the boards' alpha order is last name
-- then first, and the APSL roster surname is Alshami.  So: first name
-- "Ali Salah", last name "Alshami".  Override rows keep LA's originals.
UPDATE persons
   SET first_name = 'Ali Salah',
       last_name  = 'Alshami',
       updated_at = NOW()
 WHERE id = 3509 AND first_name = 'Ali' AND last_name = 'Salah Alshami';

INSERT INTO person_field_overrides (person_id, field_name, value, source_was, original_value, note)
VALUES
  (3509, 'firstName', 'Ali Salah', 'la', 'Ali',
   'APSL roster: Ali Salah Alshami, surname Alshami; LA has Ali Salah. Owner 2026-09-23.'),
  (3509, 'lastName',  'Alshami',   'la', 'Salah',
   'APSL roster: Ali Salah Alshami, surname Alshami; LA has Ali Salah. Owner 2026-09-23.')
ON CONFLICT (person_id, field_name) DO UPDATE
   SET value = EXCLUDED.value, original_value = EXCLUDED.original_value,
       note = EXCLUDED.note, updated_at = NOW();
