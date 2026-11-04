-- 1054: Tyreece Woods (person 22636) → winter U10 ACTIVE (owner 2026-11-04:
-- "move tyreece woods to u10 active").  He was ACTIVE on winter U9 (945,
-- mig 1052); off U9, on U10 (942) with On Roster by hand (as mig 1050) so
-- the youth rule keeps the full spot.  Fall unchanged (fall U10, on its list).

BEGIN;

UPDATE team_persons SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', 942, 'mig', 1054)
 WHERE team_id = 945 AND person_id = 22636 AND removed_at IS NULL;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT 942, 22636, (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22636 AND first_name = 'Tyreece' AND last_name = 'Woods')
   AND NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 942 AND person_id = 22636 AND removed_at IS NULL);

COMMIT;
