-- Migration 106: relabel the two Lighthouse League columns so the Club
-- Rosters master board can visually distinguish them.
--
-- Before this migration both LL rows in roster_columns rendered as
-- '🏰 Lighthouse League' with short_label='LL' — on the stacked
-- Club Rosters view (Adult + Youth on one page) the two columns look
-- identical and coaches lost track of which one they were dropping a
-- player into.  Migration 105 already renamed teams.name to
-- 'Lighthouse Adult League' / 'Lighthouse Youth League'; this
-- migration mirrors that split into the column labels the roster
-- boards actually render.
--
-- Team 122 = mens LL (adult).  Team 911 = boys LL (youth).
-- Idempotent: only rewrites the fields; ON CONFLICT is unnecessary
-- because we're updating existing rows in place.

BEGIN;

UPDATE roster_columns
   SET label       = '🏰 Lighthouse Adult',
       short_label = 'LL Adult'
 WHERE team_id = 122
   AND domain  = 'mens';

UPDATE roster_columns
   SET label       = '🏰 Lighthouse Youth',
       short_label = 'LL Youth'
 WHERE team_id = 911
   AND domain  = 'boys';

COMMIT;
