-- 099-boys-roster-caps.sql (2026-07-06)
--
-- Sets max_roster caps on the boys roster columns so the roster board
-- renders "count/max" (e.g. 7/12) instead of just "count".  Mens
-- APSL(35) and Liga 1(120) are already capped at 35 via migration 084.
--
-- User directive 2026-07-06: "for roster sizes on roster pages we need
-- x/12 for u8 and u10, x/16 for u12, and for apsl and liga 1 x/35".
--
-- Idempotent: uses UPDATE ... WHERE max_roster IS DISTINCT FROM $target
-- so re-running is a no-op after the first apply.

UPDATE roster_columns
   SET max_roster = 12,
       updated_at = now()
 WHERE team_id = 912
   AND (max_roster IS NULL OR max_roster <> 12);

UPDATE roster_columns
   SET max_roster = 12,
       updated_at = now()
 WHERE team_id = 913
   AND (max_roster IS NULL OR max_roster <> 12);

UPDATE roster_columns
   SET max_roster = 16,
       updated_at = now()
 WHERE team_id = 914
   AND (max_roster IS NULL OR max_roster <> 16);
