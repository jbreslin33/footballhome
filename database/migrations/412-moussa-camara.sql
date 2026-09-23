-- 412 — Moussa Kamara (person 22269, Men's Liga 1 / APSL Reserves) → Moussa Camara.
--
-- Owner 2026-09-23: "Moussa Kamara in fh needs to be changed to Moussa
-- Camara to match apsl roster."  LA has Kamara.  Same shape as 411: the
-- men's boards read persons directly, so the row changes; the override
-- row keeps LA's original on record.
UPDATE persons
   SET last_name  = 'Camara',
       updated_at = NOW()
 WHERE id = 22269 AND first_name = 'Moussa' AND last_name = 'Kamara';

INSERT INTO person_field_overrides (person_id, field_name, value, source_was, original_value, note)
VALUES (22269, 'lastName', 'Camara', 'la', 'Kamara',
        'APSL roster lists him as Moussa Camara; LA has Kamara. Owner 2026-09-23.')
ON CONFLICT (person_id, field_name) DO UPDATE
   SET value = EXCLUDED.value, original_value = EXCLUDED.original_value,
       note = EXCLUDED.note, updated_at = NOW();
