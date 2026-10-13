-- 581: 2026.20's two Referees lines become one, in shorthand.
--
-- Owner 2026-10-13: "it was showing on 2 lines still" (the 4-game add beat
-- the one-line deploy by ten minutes) and "short hand it like: APSL, Liga1,
-- u8,u10".  Line 70 also billed $530 for "8" games — refLineFor matched
-- each pick against its coaching policy too (fixed in code; the payments
-- themselves recorded the correct 4 referee fees, $395).  Fold line 70's
-- payments into line 60, drop line 70, and rebuild line 60 the way
-- Expenses::syncRefLine now does: league labels only, ×N on a repeat.

BEGIN;

UPDATE ref_fee_payments SET invoice_line_id = 60 WHERE invoice_line_id = 70;
DELETE FROM invoice_lines WHERE id = 70 AND category = 'referees';

UPDATE invoice_lines l
   SET quantity = p.n, amount = p.total, description = 'Referees — ' || p.games
  FROM (SELECT SUM(g.n) AS n, SUM(g.total) AS total,
               string_agg(g.lbl || CASE WHEN g.n > 1 THEN ' ×' || g.n ELSE '' END,
                          ', ' ORDER BY g.so, g.lbl) AS games
          FROM (SELECT regexp_replace(pol.label, '^Parks & Rec ', '') AS lbl,
                       COUNT(*) AS n, SUM(rp.amount_usd) AS total, MIN(pol.sort_order) AS so
                  FROM ref_fee_payments rp
                  JOIN ref_fee_policies pol ON pol.id = rp.policy_id
                 WHERE rp.invoice_line_id = 60
                 GROUP BY 1) g) p
 WHERE l.id = 60 AND l.category = 'referees' AND p.n > 0;

COMMIT;
