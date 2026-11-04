-- 1029: Fathy Elhadidy (person 22765) is injured, not Inactive (owner
-- 2026-11-04: "make fathy actually injured").  His 💤 Inactive category
-- (mig 999 / 1009) comes off — the section trigger returns his Liga 1,
-- Reserves and Cup rows to full spots — and a 🩹 short-term injury opens
-- with no back-on day (same row as the #teams health dropdown writes).
-- While injured he owes no RSVP and is not fined (fh_person_injured_at);
-- short-term keeps dues as they were (long-term would waive them, mig 715).

BEGIN;

DELETE FROM person_section_squad_statuses WHERE person_id = 22765 AND club_section_id = 1;

INSERT INTO person_injuries (person_id, health_status_id, created_by_user_id)
SELECT 22765, (SELECT id FROM health_statuses WHERE code = 'short_term_injury'), 1
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22765 AND first_name = 'Fathy' AND last_name = 'Elhadidy')
   AND NOT EXISTS (SELECT 1 FROM person_injuries WHERE person_id = 22765 AND (ends_at IS NULL OR ends_at > now()));

COMMIT;
