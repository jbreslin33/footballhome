-- 1359 (2026-11-13) — paid ads are not a club cost (owner: "if you take out
-- ads. i will be paying them myselef").  The Meta year-round ads ($175/week,
-- mig 1358) are paid by the owner personally, so the budget line comes off
-- the Budget page / Year plan / #cash-flow.  Row kept, switched off, so the
-- history and the Advertising category stay.
BEGIN;
UPDATE budget_lines
   SET is_active = false,
       note = note || ' · Paid by the owner personally, not the club (owner 2026-11-13, mig 1359)'
 WHERE category = 'advertising' AND budget_year_id = 1 AND is_active;
COMMIT;
