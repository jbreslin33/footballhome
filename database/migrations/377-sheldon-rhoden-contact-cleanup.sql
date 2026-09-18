-- 377 — Sheldon Rhoden (person 22433, LA user 57725716): contact cleanup.
--
-- Owner confirmed 2026-09-18 that +12676713124 is his phone and
-- sheldononeil87@gmail.com (already primary + verified) is his email.
-- The other two addresses came in through PersonLinker::upsertContact,
-- one per LeagueApps registration (7/8 and 7/29), and are not his.
--
--   * flag the phone primary — it was the only number and nothing was primary
--   * drop sheldonrhoden03@gmail.com and rrrsheldon@gmail.com
--
-- Caveat: upsertContact runs on every LA sync (linkLa fast path), so if
-- LeagueApps still carries one of those addresses on his registration it
-- comes back as a non-primary, unverified row.  The lasting fix for that
-- is correcting the email in LeagueApps.
--
-- Idempotent: no-ops once the rows are gone / the phone is primary.
DO $$
DECLARE
  pid CONSTANT int := 22433;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM person_emails
                  WHERE person_id = pid
                    AND lower(email) = 'sheldononeil87@gmail.com'
                    AND is_primary) THEN
    RAISE NOTICE 'person % has no primary sheldononeil87@gmail.com — skipping', pid;
    RETURN;
  END IF;

  DELETE FROM person_emails
   WHERE person_id = pid
     AND lower(email) IN ('sheldonrhoden03@gmail.com', 'rrrsheldon@gmail.com');

  UPDATE person_phones
     SET is_primary = true
   WHERE person_id = pid
     AND phone_number = '+12676713124'
     AND NOT is_primary
     AND NOT EXISTS (SELECT 1 FROM person_phones
                      WHERE person_id = pid AND is_primary);
END $$;
