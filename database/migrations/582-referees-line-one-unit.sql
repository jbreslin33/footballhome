-- 582: the Referees line is ONE item — units 1, rate = the lot.
--
-- Owner 2026-10-13: "the rate would be 835 since its all one 'Ref' item.
-- and units is 1. right?"  Like every other expense line (1 × rate =
-- amount); the ×N in the description already says how many games.

BEGIN;

UPDATE invoice_lines
   SET quantity = 1, rate = amount
 WHERE category = 'referees';

COMMIT;
