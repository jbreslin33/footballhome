-- 098-rename-purgatory-to-dues-owed.sql
--
-- Rename the admin-managed team 910 from "Purgatory" to "Dues Owed" and
-- update the mens roster board column label accordingly.  Completes the
-- 2026-07-06 vocabulary sweep (auto-computed `delinquencyState` was
-- already renamed 'purgatory' → 'dues_owed' in commit 36f37b13; this
-- migration finishes the job for the manual admin column).
--
-- The word "purgatory" is retired from the app entirely — user directive
-- 2026-07-06: "rename all purgatory stuff to dues owed".
--
-- Idempotent by design (safe to re-run).

-- Mens (team 910 + its roster_columns row)
UPDATE teams
   SET name       = 'Dues Owed (Admin)',
       updated_at = now()
 WHERE id   = 910
   AND name = 'Purgatory (Admin)';

UPDATE roster_columns
   SET label       = '🚨 Dues Owed',
       short_label = 'DUES',
       updated_at  = now()
 WHERE team_id     = 910
   AND label       = '🚨 Purgatory';

-- Boys (team 915 + its roster_columns row)
UPDATE teams
   SET name       = 'Dues Owed (Boys)',
       updated_at = now()
 WHERE id   = 915
   AND name = 'Purgatory (Boys)';

UPDATE roster_columns
   SET label       = '🚨 Dues Owed',
       short_label = 'DUES',
       updated_at  = now()
 WHERE team_id     = 915
   AND label       = '🚨 Purgatory';
