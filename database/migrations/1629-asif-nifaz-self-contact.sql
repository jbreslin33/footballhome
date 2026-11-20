-- 1629 (2026-11-20) — Asif Nifaz (22796) contacts himself, like Sheldon
-- (mig 464) / Dylan (mig 598).  Owner: "since he is on mens we need to use
-- his contacts instead of parents for rsvp. so his number is 215-316-4660
-- and his email is asifnifazo@gmail.com make them default on all".
--
-- LA keyed him as a child of Sherin Mazumder (22797), whose row carried
-- asifnifazo@gmail.com.  Emails are globally unique, so that address moves
-- to Asif and becomes his primary; the new phone is his primary; his other
-- LA address (asifnifazk) stays as a non-primary.  The person_self_contacts
-- row + clearing parent_person_id (its trigger keeps it clear on every LA
-- re-sync; the guardian sync drops the primary guardian row) sends every
-- reminder / text / email button to him, never a parent.

UPDATE person_emails SET is_primary = false WHERE person_id = 22796;
UPDATE person_phones SET is_primary = false WHERE person_id = 22796;

UPDATE person_emails
   SET person_id = 22796, is_primary = true
 WHERE lower(email) = 'asifnifazo@gmail.com' AND person_id = 22797;

INSERT INTO person_emails (person_id, email, is_primary)
SELECT 22796, 'asifnifazo@gmail.com', true
 WHERE NOT EXISTS (SELECT 1 FROM person_emails WHERE lower(email) = 'asifnifazo@gmail.com');

INSERT INTO person_phones (person_id, phone_number, is_primary, can_receive_sms, can_receive_calls)
VALUES (22796, '+12153164660', true, true, true)
ON CONFLICT (phone_number) DO NOTHING;
UPDATE person_phones SET is_primary = true WHERE person_id = 22796 AND phone_number = '+12153164660';

INSERT INTO person_self_contacts (person_id, note)
SELECT 22796, 'mig 1629 (owner 2026-11-20): Asif plays men''s — all RSVP / text / email buttons go to him (+12153164660, asifnifazo@gmail.com), never a parent row'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22796)
ON CONFLICT (person_id) DO NOTHING;

UPDATE persons SET parent_person_id = NULL WHERE id = 22796 AND parent_person_id IS NOT NULL;
