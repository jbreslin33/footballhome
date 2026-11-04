-- 1065: Isaac Anderson (person 22228; "Isaac Modesto-Anderson" on the Liga 1
-- / Reserves boards) injured (owner 2026-11-04: "put isaac on injured
-- list").  🩹 Short-term injury from today, no back-on day — same row the
-- #teams health dropdown writes.  No RSVP asks or fines while injured
-- (fh_person_injured_at); short-term keeps dues.  His teams and his
-- standing APSL call-up are unchanged.

INSERT INTO person_injuries (person_id, health_status_id, created_by_user_id)
SELECT 22228, (SELECT id FROM health_statuses WHERE code = 'short_term_injury'), 1
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22228 AND first_name = 'Isaac' AND last_name = 'Anderson')
   AND NOT EXISTS (SELECT 1 FROM person_injuries WHERE person_id = 22228 AND (ends_at IS NULL OR ends_at > now()));
