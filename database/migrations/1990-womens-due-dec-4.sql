-- Migration 1990: every Women's member is due Friday 2026-12-04.
-- Owner 11/27: "move all women to due dec 4th". Covers open memberships on
-- the Women's active + inactive programs (5039340, 5114228). The Women's
-- pickup program (5064686) is left alone — its one row is a man.
BEGIN;
UPDATE person_la_memberships
   SET next_due_at         = '2026-12-04'::timestamptz,
       next_due_source     = 'operator_override',
       next_due_updated_at = now(),
       next_due_note       = 'All Women moved to Dec 4 (owner 11/27)'
 WHERE ended_at IS NULL
   AND la_program_id IN (5039340, 5114228);
COMMIT;
