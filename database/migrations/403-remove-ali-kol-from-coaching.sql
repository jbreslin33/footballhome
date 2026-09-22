-- 403 — Remove Ali Kol from the coaching list.
--
-- Owner 2026-09-22: "remove ali kol from coaching list".
--
-- Person 22688 (added as youth coach by migration 358 on 2026-09-16, and
-- also carrying open coach rows on Liga 1 / APSL / APSL Reserves from the
-- same day).  Ended the way the Teams screen does it — ended_at stamped,
-- rows kept for history — so every "coach" check (tc.ended_at IS NULL)
-- stops seeing him.  His coaches row stays (harmless, and re-adding is
-- then a team_coaches insert).  His Liga 1 playing row is untouched.
-- Person 550 is his brother, not him — not touched.

BEGIN;

UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id
   AND c.person_id = 22688
   AND tc.ended_at IS NULL;

DO $$
DECLARE still INT; plays INT;
BEGIN
    SELECT count(*) INTO still
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 22688 AND tc.ended_at IS NULL;
    IF still <> 0 THEN
        RAISE EXCEPTION 'Ali Kol still coaches % team(s)', still;
    END IF;

    SELECT count(*) INTO plays FROM team_persons tp
     WHERE tp.person_id = 22688 AND tp.team_id = 120 AND tp.removed_at IS NULL;
    IF plays = 0 THEN
        RAISE EXCEPTION 'Ali Kol lost his Liga 1 playing row — aborting';
    END IF;
END $$;

COMMIT;
