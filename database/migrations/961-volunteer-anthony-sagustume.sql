-- 961 (2026-11-03) — Anthony Sagustume is a volunteer (mig 704): no dues,
-- no fines, out of the projections.  Owner: "add sagustume as volunteer
-- (Physio)".

INSERT INTO club_volunteers (person_id, helps_with)
SELECT 3508, 'Physio'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3508 AND last_name = 'Sagustume')
ON CONFLICT (person_id) DO NOTHING;
