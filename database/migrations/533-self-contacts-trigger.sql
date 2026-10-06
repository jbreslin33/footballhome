-- 533 (2026-10-06) — Sheldon Rhoden's parent link came back; make the
-- self-contact rule structural.
-- Owner: "we need all sheldon emails to go to sheldononeil87@gmail.com …
-- and texts and calls to go to 2676713124 i thought we did this already".
--
-- Mig 464 (2026-09-27 19:59) cleared persons.parent_person_id for person
-- 22433 and listed him in person_self_contacts so PersonLinker would not
-- re-link him.  The LA sync re-set the link at 20:02 — three minutes
-- later, from the backend still running without the guard — and the
-- guard deployed after that only stops a NEW link, so every reminder
-- since has gone to the guardian's phone and email.  Clear it again, and
-- let the table enforce itself: a BEFORE trigger drops any parent set on
-- a self-contact person, whichever code path tries.
CREATE OR REPLACE FUNCTION persons_keep_self_contact() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.parent_person_id IS NOT NULL
       AND EXISTS (SELECT 1 FROM person_self_contacts s WHERE s.person_id = NEW.id) THEN
        NEW.parent_person_id := NULL;
    END IF;
    RETURN NEW;
END $$;
COMMENT ON FUNCTION persons_keep_self_contact() IS 'A person in person_self_contacts never carries parent_person_id (mig 533).';

DROP TRIGGER IF EXISTS persons_keep_self_contact ON persons;
CREATE TRIGGER persons_keep_self_contact
    BEFORE INSERT OR UPDATE OF parent_person_id ON persons
    FOR EACH ROW EXECUTE FUNCTION persons_keep_self_contact();

-- Listing someone later clears a link already there.
CREATE OR REPLACE FUNCTION person_self_contacts_clear_parent() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE persons SET parent_person_id = NULL, updated_at = NOW()
     WHERE id = NEW.person_id AND parent_person_id IS NOT NULL;
    RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS person_self_contacts_clear_parent ON person_self_contacts;
CREATE TRIGGER person_self_contacts_clear_parent
    AFTER INSERT ON person_self_contacts
    FOR EACH ROW EXECUTE FUNCTION person_self_contacts_clear_parent();

-- Everyone already listed (Sheldon, person 22433) is cleared now.
UPDATE persons p SET parent_person_id = NULL, updated_at = NOW()
  FROM person_self_contacts s
 WHERE s.person_id = p.id AND p.parent_person_id IS NOT NULL;
