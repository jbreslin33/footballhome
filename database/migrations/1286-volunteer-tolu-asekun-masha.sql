-- 1286 (2026-11-11) — Tolu Asekun-Masha is a volunteer (mig 704): no dues,
-- no fines, out of the projections.  Owner: "move tolu to volonteer".
-- 22598 is the rostered Tolu (Men's 1893 / Liga 1); 22599 is a team-less
-- duplicate row and is left alone.

INSERT INTO club_volunteers (person_id, helps_with)
SELECT 22598, NULL
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22598 AND last_name = 'Asekun-Masha')
ON CONFLICT (person_id) DO NOTHING;
