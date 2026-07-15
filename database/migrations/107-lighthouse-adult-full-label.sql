-- Migration 107: restore 'League' suffix on both Lighthouse League
-- roster board columns.
--
-- Migration 106 shortened the labels to '🏰 Lighthouse Adult' /
-- '🏰 Lighthouse Youth', but the operator found the truncated form
-- confusing ("Adult *what*?" — reads like a category, not a league
-- name).  Restore the full 'League' suffix on both.
--
--   team 122 (mens)  '🏰 Lighthouse Adult' → '🏰 Lighthouse Adult League'
--   team 911 (boys)  '🏰 Lighthouse Youth' → '🏰 Lighthouse Youth League'
--
-- short_label columns stay 'LL Adult' / 'LL Youth' — space-constrained.
-- Idempotent: same UPDATEs are safe to re-run.

BEGIN;

UPDATE roster_columns
   SET label = '🏰 Lighthouse Adult League'
 WHERE team_id = 122
   AND domain  = 'mens';

UPDATE roster_columns
   SET label = '🏰 Lighthouse Youth League'
 WHERE team_id = 911
   AND domain  = 'boys';

COMMIT;
