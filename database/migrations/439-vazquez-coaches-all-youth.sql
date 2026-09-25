-- 439 — Joseph Vazquez coaches every youth team.
--
-- Owner 2026-09-25: "for vazquez it should show COACH for youth stuff
-- and STAFF for mens and womens stuff" … "all youth teams for vazquez".
--
-- The role pill on #my (migration 438) follows team_coaches: coaching a
-- team tagged on the event reads COACH, club staff (430) reads STAFF.
-- Joseph (person 22277) had no coaches row at all, so every card on his
-- page said STAFF.  A coaches row plus one live team_coaches row per
-- active youth team (club_sections Boys = 3, Girls = 4) fixes that; his
-- club_staff row stays, so Men's and Women's keep reading STAFF.
-- Same shape as 429 (no coach_role_id).
BEGIN;
INSERT INTO coaches (person_id)
SELECT 22277
 WHERE NOT EXISTS (SELECT 1 FROM coaches WHERE person_id = 22277);

INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.id
  FROM teams t, coaches c
 WHERE c.person_id = 22277
   AND t.is_active
   AND t.club_section_id IN (3, 4)
   AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                    WHERE tc.team_id = t.id AND tc.coach_id = c.id AND tc.ended_at IS NULL);

DO $$
DECLARE want INT; have INT;
BEGIN
    SELECT count(*) INTO want FROM teams WHERE is_active AND club_section_id IN (3, 4);
    SELECT count(*) INTO have
      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 22277 AND tc.ended_at IS NULL
       AND tc.team_id IN (SELECT id FROM teams WHERE is_active AND club_section_id IN (3, 4));
    IF have <> want THEN
        RAISE EXCEPTION 'migration 439: Joseph coaches % of % youth teams', have, want;
    END IF;
END $$;
COMMIT;
