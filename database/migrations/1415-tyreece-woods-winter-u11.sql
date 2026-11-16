-- 1415 (2026-11-16): Tyreece Woods (person 22636) moves from the ❄️ U9 winter
-- team (945, Mon/Wed/Fri 4:45 PM) to the ❄️ U11 winter team (946, Mon/Wed/Fri
-- 5:45 PM). Owner: "move tyreece woods to u11 Winter" + "he needs the 5:45pm
-- slot". Same as the ⚽ "Move here" pill: the old row is closed (removed_at +
-- admin_remove) and the new one copies its flags (plain Active, as every
-- winter youth row since mig 1413). He keeps his fall U10 (913) row.

UPDATE team_persons
   SET removed_at = now(), removed_reason = 'admin_remove'
 WHERE person_id = 22636 AND team_id = 945 AND removed_at IS NULL;

INSERT INTO team_persons (team_id, person_id, on_roster, invite_only, call_in, squad_status_id)
SELECT 946, 22636, false, false, false, NULL
 WHERE NOT EXISTS (SELECT 1 FROM team_persons
                    WHERE team_id = 946 AND person_id = 22636 AND removed_at IS NULL);
