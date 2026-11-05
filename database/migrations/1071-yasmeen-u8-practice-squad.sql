-- 1071: Yasmeen Turner (22743) → Practice Squad on fall U8 (912) (owner
-- 2026-11-05: "move yasmeen to practice squad as its too late to add
-- her").  Needs Docs and not on the U8 league list, so by U8's
-- games_need_roster rule she belongs there, but her row predates the
-- rule and was never moved — she could still see and answer games.  Now
-- U8 games reach the 11 ACTIVE; she keeps practices and can be called up
-- per game (🎟).

BEGIN;

UPDATE team_persons
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'practice_squad'),
       invite_only = true, call_in = false
 WHERE team_id = 912 AND removed_at IS NULL AND person_id = 22743;

COMMIT;
