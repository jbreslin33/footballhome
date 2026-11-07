-- 1154: Ali Salah Alshami (person 3509, Men's — 1893 / Liga 1) is a
-- Volunteer (owner 2026-11-06: "move ali salah to volunteer").  Mig 704
-- club_volunteers: $0 dues balance, no notices / alternate flag, never
-- fined, out of income projections.
INSERT INTO club_volunteers (person_id, helps_with)
SELECT 3509, NULL
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3509 AND first_name = 'Ali Salah' AND last_name = 'Alshami')
ON CONFLICT (person_id) DO NOTHING;
