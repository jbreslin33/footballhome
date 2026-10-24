-- 682 (2026-10-24) — A kid can have more than one parent, and every
-- message goes to each parent separately.
--
-- Owner: "add raynel Terrero to angel, ryan and alex. its the dad … any
-- text should go out separate to both … they are divorced so we want
-- option to send to both but sep. this should be the normal for all."
--
-- persons.parent_person_id held exactly ONE parent; every sender picked
-- it (COALESCE(parent_person_id, id)) and every "parent sees / acts for
-- the kid" check compared against it.  person_guardians holds N.
-- parent_person_id stays as the PRIMARY parent (LeagueApps' registrant),
-- kept in step by trigger, so the LA linker and every youth flag keep
-- working unchanged.
--
-- Self-contact adults (person_self_contacts, mig 464/533 — e.g. an adult
-- on a CHILD-typed LA registration) keep today's meaning: their own
-- contact and no parent authority, so their guardian rows go too.

-- 1. Table + backfill -------------------------------------------------------
CREATE TABLE IF NOT EXISTS person_guardians (
    child_person_id    INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    guardian_person_id INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    is_primary         BOOLEAN NOT NULL DEFAULT false,
    source             TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('la', 'manual')),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (child_person_id, guardian_person_id),
    CHECK (child_person_id <> guardian_person_id)
);
CREATE INDEX IF NOT EXISTS idx_person_guardians_guardian ON person_guardians (guardian_person_id);
COMMENT ON TABLE person_guardians IS
    'mig 682: every parent of a kid (divorced parents each get their own texts, links and #my view). '
    'is_primary = persons.parent_person_id (LeagueApps registrant), synced by trigger; other rows are added by hand or by a second LA parent.';

INSERT INTO person_guardians (child_person_id, guardian_person_id, is_primary, source)
SELECT id, parent_person_id, true, 'la' FROM persons WHERE parent_person_id IS NOT NULL
ON CONFLICT (child_person_id, guardian_person_id) DO NOTHING;

-- 2. parent_person_id → primary guardian row -------------------------------
CREATE OR REPLACE FUNCTION persons_sync_primary_guardian() RETURNS trigger AS $fn$
BEGIN
    IF NEW.parent_person_id IS NOT DISTINCT FROM (CASE WHEN TG_OP = 'UPDATE' THEN OLD.parent_person_id END) THEN
        RETURN NEW;
    END IF;
    IF NEW.parent_person_id IS NULL THEN
        DELETE FROM person_guardians WHERE child_person_id = NEW.id AND is_primary;
    ELSE
        UPDATE person_guardians SET is_primary = false
         WHERE child_person_id = NEW.id AND guardian_person_id <> NEW.parent_person_id AND is_primary;
        INSERT INTO person_guardians (child_person_id, guardian_person_id, is_primary, source)
        VALUES (NEW.id, NEW.parent_person_id, true, 'la')
        ON CONFLICT (child_person_id, guardian_person_id) DO UPDATE SET is_primary = true;
    END IF;
    RETURN NEW;
END $fn$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS persons_sync_primary_guardian ON persons;
CREATE TRIGGER persons_sync_primary_guardian
    AFTER INSERT OR UPDATE OF parent_person_id ON persons
    FOR EACH ROW EXECUTE FUNCTION persons_sync_primary_guardian();

-- Self-contact: no parent routing AND no parent authority (mirror of mig 533).
CREATE OR REPLACE FUNCTION person_self_contacts_clear_parent() RETURNS trigger AS $fn$
BEGIN
    UPDATE persons SET parent_person_id = NULL, updated_at = NOW()
     WHERE id = NEW.person_id AND parent_person_id IS NOT NULL;
    DELETE FROM person_guardians WHERE child_person_id = NEW.person_id;
    RETURN NEW;
END $fn$ LANGUAGE plpgsql;
DELETE FROM person_guardians g USING person_self_contacts s WHERE g.child_person_id = s.person_id;

-- 3. Helpers: the rules every sender and every "is mine" check share -------
CREATE OR REPLACE FUNCTION fh_is_guardian(p_guardian int, p_child int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM person_guardians g
                    WHERE g.child_person_id = p_child AND g.guardian_person_id = p_guardian)
$$;
COMMENT ON FUNCTION fh_is_guardian(int, int) IS 'mig 682: is p_guardian one of p_child''s parents (any of them).';

-- Who a message about p_person goes to: each parent (primary first,
-- ord 1..n), or the person themself when they have none.
CREATE OR REPLACE FUNCTION fh_message_recipients(p_person int)
RETURNS TABLE(recipient_person_id int, is_guardian boolean, ord int)
LANGUAGE sql STABLE AS $$
    SELECT g.guardian_person_id, true,
           (row_number() OVER (ORDER BY g.is_primary DESC, g.created_at, g.guardian_person_id))::int
      FROM person_guardians g
     WHERE g.child_person_id = p_person
    UNION ALL
    SELECT p_person, false, 1
     WHERE NOT EXISTS (SELECT 1 FROM person_guardians g WHERE g.child_person_id = p_person)
$$;
COMMENT ON FUNCTION fh_message_recipients(int) IS 'mig 682: every parent of a kid (each messaged separately, primary = ord 1), else the person.';

-- A recipient's texting number for a message about p_player: theirs first,
-- the player's own as the fallback (the rule RsvpBoard & co. inlined).
CREATE OR REPLACE FUNCTION fh_recipient_phone(p_recipient int, p_player int) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT x.phone_number::text FROM person_phones x
     WHERE x.person_id IN (p_recipient, p_player) AND COALESCE(x.can_receive_sms, true)
     ORDER BY (x.person_id = p_recipient) DESC, x.is_primary DESC NULLS LAST, x.id LIMIT 1
$$;
CREATE OR REPLACE FUNCTION fh_recipient_email(p_recipient int, p_player int) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT x.email::text FROM person_emails x
     WHERE x.person_id IN (p_recipient, p_player)
     ORDER BY (x.person_id = p_recipient) DESC, x.is_primary DESC NULLS LAST, x.id LIMIT 1
$$;

-- 4. Replies: "(parent of …)" names every kid of any parent -----------------
DO $$
DECLARE d text;
BEGIN
    d := pg_get_functiondef('fh_sms_reply_forwards'::regproc);
    IF position('k.parent_person_id = p.id' IN d) > 0 THEN
        EXECUTE replace(d, 'k.parent_person_id = p.id', 'fh_is_guardian(p.id, k.id)');
    END IF;
END $$;

-- 5. Raynel Terrero: dad of Ryan Terrero, Angel Terrero and Alex Bassett ---
--    (his mobile is loaded into person_phones by hand — contacts stay out of git)
INSERT INTO persons (first_name, last_name)
SELECT 'Raynel', 'Terrero'
 WHERE NOT EXISTS (SELECT 1 FROM persons WHERE first_name = 'Raynel' AND last_name = 'Terrero');
INSERT INTO person_guardians (child_person_id, guardian_person_id, is_primary, source)
SELECT k.id, r.id, false, 'manual'
  FROM persons r, persons k
 WHERE r.first_name = 'Raynel' AND r.last_name = 'Terrero'
   AND (k.first_name, k.last_name) IN (('Ryan', 'Terrero'), ('Angel', 'Terrero'), ('Alex', 'Bassett'))
   AND k.parent_person_id = (SELECT id FROM persons WHERE first_name = 'Lina' AND last_name = 'Bono')
ON CONFLICT (child_person_id, guardian_person_id) DO NOTHING;
