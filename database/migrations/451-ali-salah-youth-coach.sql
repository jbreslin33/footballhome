-- 451 (2026-09-25) — Ali Salah Alshami coaches every youth team.
-- Owner: "add ali salah to youth coaches".  Person 3509 (APSL player,
-- renamed in 410/411) had no coaches row.  Same shape as 439: a coaches
-- row plus one live team_coaches row per active youth team (Boys 3 /
-- Girls 4).  His APSL roster row stays, so his cards read COACH on youth
-- and PLAYER on Men's (mig 438).
BEGIN;
INSERT INTO coaches (person_id)
SELECT 3509 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 3509);

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t, coaches c
 WHERE c.person_id = 3509 AND t.is_active AND t.club_section_id IN (3, 4)
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

DO $$
DECLARE want INT; have INT;
BEGIN
    SELECT count(*) INTO want FROM teams WHERE is_active AND club_section_id IN (3, 4);
    SELECT count(*) INTO have FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 3509 AND tc.ended_at IS NULL
       AND tc.team_id IN (SELECT id FROM teams WHERE is_active AND club_section_id IN (3, 4));
    IF have <> want THEN RAISE EXCEPTION 'migration 451: Ali coaches % of % youth teams', have, want; END IF;
END $$;
COMMIT;
