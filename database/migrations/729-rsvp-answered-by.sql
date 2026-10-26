-- 729 (2026-10-26) — every RSVP remembers WHO tapped it.  Owner, after a
-- run of APSL players set Not going on the new Tuesday Liga 1 game:
-- "did the not going players really set not going or did you set it?"
-- (they had — but created_via 'manual' can't say whether the player, a
-- parent or an admin answering for them pressed the button).
-- POST /api/calendar/rsvp stores the signed-in caller; NULL = before 729.
ALTER TABLE fh_event_rsvps ADD COLUMN IF NOT EXISTS answered_by_person_id INT REFERENCES persons(id) ON DELETE SET NULL;
COMMENT ON COLUMN fh_event_rsvps.answered_by_person_id IS
  'mig 729: the signed-in person whose tap wrote this answer (= person_id when the player answered themselves; a parent or admin otherwise). NULL for answers before mig 729.';
