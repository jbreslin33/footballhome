-- 1072: Yasmeen Turner (22743) U8 (912) Roster status Needs Docs → Not on
-- Roster, to match mig 1071's Practice Squad.  On a games_need_roster
-- team Needs Docs counts as "plays" (paperwork in progress), so the
-- trigger would have put her back on games the next time her status was
-- touched.  Not on Roster keeps her Practice Squad by the rule itself.

BEGIN;

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'not_on_roster')
 WHERE team_id = 912 AND removed_at IS NULL AND person_id = 22743;

COMMIT;
