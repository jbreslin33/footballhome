-- 880 (2026-10-30) — Tolu Asekun-Masha is a volunteer (mig 704): no dues, no
-- fines, out of the projections.  Owner: "put tolu as volunteer".  Coaches
-- the youth teams.  22598 is the live row; 22599 is an empty duplicate (mig 773).

INSERT INTO club_volunteers (person_id, helps_with)
VALUES (22598, 'Coaching')
ON CONFLICT (person_id) DO NOTHING;
