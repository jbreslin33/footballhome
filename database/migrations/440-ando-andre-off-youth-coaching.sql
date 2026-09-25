-- 440 — Ando Andre no longer coaches.
--
-- Owner 2026-09-25, looking at the youth coaching list: "remove ando."
-- Ando Andre (person 22494, coaches 49) held a live team_coaches row on
-- all nine active youth teams and nothing else.  Rows are ended, never
-- deleted (same convention as 405/429), so history and past attendance
-- marks keep their coach.
BEGIN;
UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id AND c.person_id = 22494 AND tc.ended_at IS NULL;

DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 22494 AND tc.ended_at IS NULL;
    IF n <> 0 THEN
        RAISE EXCEPTION 'migration 440: Ando still has % live coach rows', n;
    END IF;
END $$;
COMMIT;
