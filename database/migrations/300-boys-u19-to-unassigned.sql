-- 300 — Return the boys players parked on U19 to Unassigned.
--
-- Why (2026-08-25, owner: "i got a new u13 member for boys. it reminded
-- me that those kids are not showing on #teams screen … move all players
-- not on u6,u8,u10,u12 to unassigned so i can see them all").
--
-- The boys board (#teams, BoysRoster::run) renders one column per team
-- with `board_sort_order IS NOT NULL AND is_active = true`
-- (MensTeamColumns::loadAll). Team 932 "U19" was created 2026-08-12 with
-- a sort order but is_active = false, so its column never draws.
--
-- That alone would be harmless, except for the suppression rule at
-- BoysRoster.cpp:610 (added 2026-07-08 to keep pickup-only members out of
-- the draft view): a player whose only assignments are to off-view teams
-- is skipped entirely rather than falling back to Unassigned. So the six
-- players assigned to U19 on 2026-08-13 are in neither place — no column
-- shows them, and Unassigned suppresses them. They are invisible on the
-- board while still holding a live team_persons row.
--
-- Closing those rows is what "move to unassigned" means here: Unassigned
-- is not a team, it is the absence of an active assignment to a board
-- column, so there is no destination row to write.
--
-- Written as a rule rather than six ids: every active assignment to a
-- boys team that is not one of the four columns the club actually runs
-- (U6 931, U8 912, U10 913, U12 914). Today that matches exactly the six
-- U19 rows — teams 910/911/916/917/927/928/929 already have no active
-- rows — but the rule is the thing the owner asked for, and it stays
-- correct if another off-view boys team collects assignments later.
--
-- Reversible: the rows are closed, not deleted, and carry a distinct
-- removed_reason so they can be found and reopened.
UPDATE team_persons tp
   SET removed_at     = NOW(),
       removed_reason = 'off_board_column_to_unassigned'
  FROM teams t
 WHERE t.id = tp.team_id
   AND t.gender_category = 'boys'
   AND tp.removed_at IS NULL
   AND t.id NOT IN (931, 912, 913, 914);
