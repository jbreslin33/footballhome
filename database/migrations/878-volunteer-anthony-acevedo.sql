-- 878 (2026-10-30) — Anthony Acevedo is a volunteer (mig 704): no dues, no
-- fines, out of the projections.  Owner: "move acevedo to volunteer for
-- tuition".  He coaches the youth teams.

INSERT INTO club_volunteers (person_id, helps_with)
VALUES (22397, 'Coaching')
ON CONFLICT (person_id) DO NOTHING;
