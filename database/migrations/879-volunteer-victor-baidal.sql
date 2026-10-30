-- 879 (2026-10-30) — Victor Baidal is a volunteer (mig 704): no dues, no
-- fines, out of the projections.  Owner: "put victor as volunteer".  He
-- coaches the youth teams.

INSERT INTO club_volunteers (person_id, helps_with)
VALUES (22301, 'Coaching')
ON CONFLICT (person_id) DO NOTHING;
