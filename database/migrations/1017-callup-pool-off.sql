-- 1017: no ⭐ CALL-UP POOL on the Team pill until the owner names who is
-- in it (2026-11-03: "take all out of call up pool until i tell you who
-- to put in there … its obvious who is in pool if they are on APSL
-- official or reserve official (shown with label on their card)").
-- The folded team (APSL Reserves) still has no Team-pill column; every
-- one of its men is also on APSL or Liga 1 and shows there with 📋 chips.

BEGIN;
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'roster_sheet' AND tier = 'board_callup_pool_h';
COMMENT ON COLUMN teams.team_pill_fold_into_id IS
  'mig 1010/1017: #teams Team pill shows no column for this team (its men show in their other columns with list chips). Roster pill unaffected.';
COMMIT;
