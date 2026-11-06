-- Owner 11/6: on James's 2026.22 (invoice id 20) the three CASA player lines
-- become one "CASA Player Registrations" line: Add fees $216.24 + Registration
-- fees $97.22 + $25.80 = $339.26.  Total unchanged ($3,429.99).  Line 84 is
-- kept (re-described + re-summed), 85 and 88 go.  2026.23's CASA Player Add
-- fees (1 of 2 plan, line 96) is untouched.
UPDATE invoice_lines
   SET description = 'CASA Player Registrations',
       quantity = 1, rate = 339.26, amount = 339.26
 WHERE id = 84 AND invoice_id = 20 AND amount = 216.24;

DELETE FROM invoice_lines
 WHERE invoice_id = 20 AND id IN (85, 88)
   AND description = 'CASA Player Registration fees'
   AND EXISTS (SELECT 1 FROM invoice_lines WHERE id = 84 AND amount = 339.26);
