-- 101-liga2-mens-selection.sql (2026-07-07)
--
-- User directive: "we don't have liga 2 on gui yet. you can add it."
--
-- Liga 2 (team_id=121) was seeded in migration 061 without a
-- `mutex_group` and with `max_roster=0` (which caused the "over-full"
-- chip to fire at any player count).  Adding it to the same
-- `mens-selection` mutex group as APSL + Liga 1 makes the roster
-- selector radio-button-style: assigning a player to Liga 2 auto-
-- removes them from APSL / Liga 1 (and vice versa), same guarantee
-- the coach already relies on for APSL <-> Liga 1.
--
-- Colour swapped from #0891b2 (identical to Liga 1) to #14b8a6 (teal)
-- so the two divisions are visually distinguishable on the board.
--
-- Cap of 35 mirrors Liga 1.  If a Liga 2 gameday ever fields fewer
-- than 35 the coach can lower it via roster_columns directly.
--
-- Idempotent: safe to re-apply.

UPDATE roster_columns
   SET mutex_group = 'mens-selection',
       max_roster  = 35,
       color       = '#14b8a6',
       archived_at = NULL,
       updated_at  = now()
 WHERE team_id     = 121
   AND domain      = 'mens';
