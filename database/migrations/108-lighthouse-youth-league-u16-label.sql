-- Migration 108: restore 'U16' qualifier on team 911's roster board
-- label now that three Lighthouse Youth League age brackets are in
-- play (U8=916, U12=917, U16=911).
--
-- Migration 107 dropped 'U16' from the label when we thought the
-- youth team was a single flat bucket.  The board now shows three
-- Lighthouse Youth League columns; without the age qualifier the
-- U16 column reads as 'the' Lighthouse Youth League while U8 / U12
-- read as narrower buckets — misleading.
--
-- Idempotent: WHERE clause pins the exact row.

BEGIN;

UPDATE roster_columns
   SET label = '🏰 Lighthouse Youth League U16'
 WHERE team_id = 911
   AND domain  = 'boys';

COMMIT;
