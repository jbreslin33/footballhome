-- 1155: Lucca Santos (person 22698, Men's — 1893 / Liga 1 / APSL Reserves)
-- is a Volunteer (owner 2026-11-06: "make lucca santos a volunteer").
-- Mig 704 club_volunteers: $0 dues balance, no notices / alternate flag,
-- never fined, out of income projections.
INSERT INTO club_volunteers (person_id, helps_with)
SELECT 22698, NULL
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22698 AND first_name = 'Lucca' AND last_name = 'Santos')
ON CONFLICT (person_id) DO NOTHING;
