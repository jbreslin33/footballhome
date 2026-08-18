-- ─────────────────────────────────────────────────────────────────────
-- 290-womens-roster-board-column.sql (2026-08-18)
--
-- Cosmetic-only polish for the new WomensRoster board. Team 901 (Tri
-- County Women) already has gender_category='womens' and
-- board_sort_order=1 set (leftover from the old roster_columns table,
-- folded into `teams` by migration 250) — MensTeamColumns("womens")
-- already picks it up as a board column with zero schema change. This
-- just fills in the presentation fields (label/short_label/color/
-- mutex_group) so its card matches the Boys/Mens columns' styling
-- instead of falling back to the bare team name with no color accent.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

UPDATE teams
   SET short_label = 'Tri Co Women',
       label       = '👩 Tri County Women',
       color       = '#db2777',
       mutex_group = 'womens-selection'
 WHERE id = 901;

COMMIT;
