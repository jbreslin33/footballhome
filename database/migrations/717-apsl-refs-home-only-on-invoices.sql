-- 717 (2026-10-26) — APSL referees are paid at HOME games only (owner:
-- "for apsl we only pay refs at home games so if listed as away then we
-- don't pay. but be careful we do have home games sometimes NOT at
-- lightoue if we need to rent a turf etc").
--
-- Home = the league schedule's home side (league_fixtures.home_club_id =
-- the club), never the venue — so a home game moved to a rented turf still
-- pays.  Since mig 577 the invoice picker offered EVERY game regardless of
-- home_only (home_only now only shapes #finances projections); the new
-- bill_home_only flag is what the picker/auto-add obeys.  APSL on; the
-- other leagues keep today's behaviour until the owner says otherwise.
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS bill_home_only boolean NOT NULL DEFAULT false;
UPDATE ref_fee_policies SET bill_home_only = true WHERE kind = 'referee' AND fixture_league_label = 'APSL';

-- James's 2026.21 (draft) carried two AWAY APSL fees: 10/11 at Real
-- Central NJ, 10/21 at Medford Strikers ($310 each).  Off, line re-summed
-- the way Expenses::syncRefLine does.  (#20's 10/4 at Persepolis is left
-- for the owner: that sheet may already have been sent.)
DELETE FROM ref_fee_payments rp
 USING invoice_lines l, invoices v, league_fixtures f
 WHERE l.id = rp.invoice_line_id AND v.id = l.invoice_id AND NOT v.is_final
   AND v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 21
   AND rp.policy_id IN (SELECT id FROM ref_fee_policies WHERE bill_home_only)
   AND f.id = rp.league_fixture_id AND f.home_club_id IS DISTINCT FROM 134;
UPDATE invoice_lines l
   SET quantity = 1, rate = p.total, amount = p.total, description = 'Referees — ' || p.games
  FROM (SELECT g.line_id, SUM(g.n) AS n, SUM(g.total) AS total,
               string_agg(g.lbl || CASE WHEN g.n > 1 THEN ' ×' || g.n ELSE '' END, ', ' ORDER BY g.so, g.lbl) AS games
          FROM (SELECT rp.invoice_line_id AS line_id, regexp_replace(pol.label, '^Parks & Rec ', '') AS lbl,
                       COUNT(*) AS n, SUM(rp.amount_usd) AS total, MIN(pol.sort_order) AS so
                  FROM ref_fee_payments rp JOIN ref_fee_policies pol ON pol.id = rp.policy_id
                 GROUP BY 1, 2) g GROUP BY g.line_id) p, invoices v
 WHERE l.id = p.line_id AND v.id = l.invoice_id AND NOT v.is_final
   AND v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 21;
UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 21;
