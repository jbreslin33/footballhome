-- 442 — James Breslin is staff, not coach, for the Women's team.
--
-- Owner 2026-09-25: "for tri county i can be staff".  Migration 429
-- (this morning) reopened his Women's (901) coach row so Sunday's game
-- stayed on his page; migration 430 (club_staff) now keeps every team's
-- events on his page anyway, so the row can end and the role pill (438)
-- reads STAFF on Women's / Tri-County cards.  Michael's row stays.
BEGIN;
UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id AND c.person_id = 1 AND tc.team_id = 901 AND tc.ended_at IS NULL;

DO $$
DECLARE n INT; staff INT;
BEGIN
    SELECT count(*) INTO n FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id
     WHERE c.person_id = 1 AND tc.team_id = 901 AND tc.ended_at IS NULL;
    IF n <> 0 THEN RAISE EXCEPTION 'migration 442: James still coaches the Women''s team'; END IF;
    SELECT count(*) INTO staff FROM club_staff WHERE person_id = 1 AND ended_at IS NULL;
    IF staff <> 1 THEN RAISE EXCEPTION 'migration 442: James has no live club_staff row — Women''s events would vanish from his page'; END IF;
END $$;
COMMIT;
