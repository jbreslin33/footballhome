-- 441 — James Breslin coaches the three Travel teams again.
--
-- Owner 2026-09-25: "why am i staff for travel. i should be coach".
-- Migration 405 (09-22, "we just need me as mens coach") ended James's
-- rows on every youth team, so the role pill (438) reads STAFF on
-- U8/U10/U12 Travel via club_staff (430).  Reopen Travel only (912, 913,
-- 914); the Intramural rows stay ended.  Same shape as 429.
BEGIN;
INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t, coaches c
 WHERE c.person_id = 1
   AND t.id IN (912, 913, 914)
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 1 AND tc.ended_at IS NULL AND tc.team_id IN (912, 913, 914);
    IF n <> 3 THEN
        RAISE EXCEPTION 'migration 441: James coaches % of 3 Travel teams', n;
    END IF;
END $$;
COMMIT;
