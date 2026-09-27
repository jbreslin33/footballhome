-- 464 (2026-09-27) — Sheldon Rhoden gets his own RSVP reminders.
--
-- Owner: "sheldon phone for fh should be 2676713124" /
-- "sheldononeil87@gmail.com is his fh email for reminders etc".
--
-- Both were already on file as person 22433's primary phone + email.
-- The reminders were going elsewhere because his LeagueApps registration
-- is a youth (userType CHILD) record, so PersonLinker::ensureParentLink
-- set persons.parent_person_id = 22530 (Amoy Hepburn), and everything
-- that routes contact for a youth (RsvpBoard, PersonPayments, magic
-- links) sends to the parent's phone/email instead.  He plays for the
-- Men's APSL side and manages his own RSVPs, so treat him as an adult.
--
-- Clearing the FK alone is not enough: the next LA sync would re-link
-- him (ensureParentLink re-sets a NULL parent).  person_self_contacts
-- records people whose LA record carries a guardian but who are
-- contacted directly; ensureParentLink skips anyone listed here.

CREATE TABLE IF NOT EXISTS person_self_contacts (
    person_id  INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    note       TEXT,
    set_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE person_self_contacts IS
  'People whose LeagueApps record names a guardian but who are contacted directly (adult on a youth-typed registration). PersonLinker never sets parent_person_id for them.';

INSERT INTO person_self_contacts (person_id, note)
VALUES (22433, 'Sheldon Rhoden — Men''s APSL; LA registration is CHILD-typed with Amoy Hepburn (22530) as guardian. Owner 2026-09-27.')
ON CONFLICT (person_id) DO NOTHING;

UPDATE persons SET parent_person_id = NULL, updated_at = NOW()
 WHERE id = 22433 AND parent_person_id IS NOT NULL;

-- Belt and braces: his own mobile + email are the primaries.
UPDATE person_phones SET is_primary = true, can_receive_sms = true, can_receive_calls = true
 WHERE person_id = 22433 AND phone_number = '+12676713124';
UPDATE person_phones SET is_primary = false
 WHERE person_id = 22433 AND phone_number <> '+12676713124';
UPDATE person_emails SET is_primary = (LOWER(email) = 'sheldononeil87@gmail.com')
 WHERE person_id = 22433;
