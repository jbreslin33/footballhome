-- 404 — Remove Marcelo Osorio-Soto from the coaching list.
--
-- Owner 2026-09-22: "take Marcelo Osorio off list too" (right after Ali
-- Kol, migration 403).
--
-- Person 22319, open coach rows on all 13 teams (mens, womens, boys,
-- every youth team; most from 2026-08-25, APSL Reserves from 09-12).  No
-- playing rows.  Ended the way the Teams screen does it — ended_at
-- stamped, rows kept for history — so every coach check
-- (tc.ended_at IS NULL) stops seeing him.  His coaches row stays.

BEGIN;

UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id
   AND c.person_id = 22319
   AND tc.ended_at IS NULL;

DO $$
DECLARE still INT;
BEGIN
    SELECT count(*) INTO still
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 22319 AND tc.ended_at IS NULL;
    IF still <> 0 THEN
        RAISE EXCEPTION 'Marcelo Osorio-Soto still coaches % team(s)', still;
    END IF;
END $$;

COMMIT;
