-- 410 — Ali Salah (person 3509, Men's APSL) → Ali Salah Alshami.
--
-- Owner 2026-09-23: "ali salah in fh needs to be ali salah alshami so it
-- matches apsl roster."  LA has him as Ali Salah; the APSL roster lists
-- the full surname.  The men's boards read persons directly, so the row
-- changes; the override row keeps the LA original on record (same shape
-- as the Carmelo Passineau fix) for the boards that resolve overrides.
UPDATE persons
   SET last_name  = 'Salah Alshami',
       updated_at = NOW()
 WHERE id = 3509 AND first_name = 'Ali' AND last_name = 'Salah';

INSERT INTO person_field_overrides (person_id, field_name, value, source_was, original_value, note)
VALUES (3509, 'lastName', 'Salah Alshami', 'la', 'Salah',
        'APSL roster lists him as Ali Salah Alshami; LA has Ali Salah. Owner 2026-09-23.')
ON CONFLICT (person_id, field_name) DO UPDATE
   SET value = EXCLUDED.value, original_value = EXCLUDED.original_value,
       note = EXCLUDED.note, updated_at = NOW();
