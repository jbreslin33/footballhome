-- Owner 2026-11-06: "bring other stuff back so it has balance of categories
-- and spread them all out. its ok to spread out refs as long as we track it.
-- so on next refs its x of x but we simply add on any new refs and spread."
--
-- Rule: a sheet carries its own hours whole; everything else rides in 2
-- payments, this sheet and the next.  Refs too: a period's games stay on the
-- sheet that billed them (ref_fee_payments → that line), the line is payment
-- 1 of 2 of a plan whose total = the games, payment 2 lands on the next
-- sheet; Expenses::syncRefLine re-sums every payment when a game changes.
--
--   invoice_issuers.ref_split_payments  N > 1 = a new Referees line starts
--                                       as payment 1 of N (James = 2)
--   invoice_installment_plans.starts_invoice_year/number
--                                       first sheet a plan may land on
--
-- Rebuild of James's sheets (projected; refs of open periods split as above):
--   2026.22 $1,809.83  hours $956 · Referees 1 of 2 $492.50 · APSL 15 of 16
--           $183.75 · CASA Liga 1 1 of 2 $125.10 · Women's ref 1 of 2 $47.21
--           · Youth Shirt 1 of 2 $5.27
--   2026.23 ≈$1,814  hours $473 · Referees (.22) 2 of 2 $492.50 · its own refs
--           1 of 2 (~$487.50) · APSL 16 of 16 · CASA Liga 1 2 of 2 · Women's
--           ref 2 of 2 · Youth Shirt 2 of 2
--   2026.24 ≈$1,668  hours · refs (.23) 2 of 2 · own refs 1 of 2 · Youth 6 of 6
--           · Refs paid deleted games 1 of 2 · Field Paint, Badge Logos, Field
--           rental 1 of 2
--   2026.25 ≈$1,525  hours · refs 2 of 2 + own 1 of 2 · deleted-games refs,
--           Field Paint, Badge Logos, Field rental 2 of 2 · ITC 6 of 6 · CASA
--           Player Registrations 1 of 2 (2 of 2 on 2026.26)
BEGIN;

ALTER TABLE invoice_issuers ADD COLUMN IF NOT EXISTS ref_split_payments smallint NOT NULL DEFAULT 1
    CHECK (ref_split_payments BETWEEN 1 AND 6);
COMMENT ON COLUMN invoice_issuers.ref_split_payments IS
  'mig 1135: N > 1 = a sheet''s new Referees line is payment 1 of N; the rest land on the next sheets.';
UPDATE invoice_issuers SET ref_split_payments = 2 WHERE id = 1;

ALTER TABLE invoice_installment_plans
    ADD COLUMN IF NOT EXISTS starts_invoice_year int,
    ADD COLUMN IF NOT EXISTS starts_invoice_number int;
COMMENT ON COLUMN invoice_installment_plans.starts_invoice_number IS
  'mig 1135: first sheet (year/number) this plan may land on; NULL = the next one created.';

-- 2026.22 Referees (10 games, $985): payment 1 of 2 here, 2 of 2 on 2026.23.
WITH pl AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total)
  SELECT 1, 'referees', l.description, l.amount, 2, true FROM invoice_lines l
   WHERE l.id = 92 AND l.invoice_id = 20 AND l.plan_id IS NULL AND l.amount = 985.00
  RETURNING id, description)
, upd AS (UPDATE invoice_lines SET plan_id = pl.id, installment_no = 1, rate = 492.50, amount = 492.50 FROM pl WHERE invoice_lines.id = 92 RETURNING pl.id, pl.description)
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order)
SELECT 24, 'referees', upd.description, 1, 492.50, 492.50, upd.id, 2, 40 FROM upd;

-- Payments placed by hand on the two sheets that already exist
-- (plan, sheet, payment no, amount, sort).
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order, budget_line_id)
SELECT v.inv, p.category, p.description, 1, v.amt, v.amt, p.id, v.k, v.so, p.budget_line_id
  FROM (VALUES (12, 20, 15, 183.75, 10), (12, 24, 16, 183.75, 10),   -- APSL League Dues
               (17, 20,  1, 125.10, 11), (17, 24,  2, 125.09, 11),   -- CASA Liga 1 League payment
               (19, 20,  1,  47.21, 41), (19, 24,  2,  47.21, 41),   -- Women's ref fee
               (18, 20,  1,   5.27, 20), (18, 24,  2,   5.27, 20))   -- Youth Shirt
       AS v(plan, inv, k, amt, so)
  JOIN invoice_installment_plans p ON p.id = v.plan AND p.issuer_id = 1
 WHERE NOT EXISTS (SELECT 1 FROM invoice_lines x WHERE x.plan_id = v.plan AND x.installment_no = v.k);

-- Youth u8,u10,u12 6 of 6 off 2026.23: plan 8 issues it on 2026.24.
DELETE FROM invoice_lines WHERE id = 80 AND invoice_id = 24 AND plan_id = 8 AND installment_no = 6;

-- Refs paid, deleted games $200 → 2 payments from 2026.24.
INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total, starts_invoice_year, starts_invoice_number)
SELECT 1, l.category, l.description, l.amount, 2, true, 2026, 24 FROM invoice_lines l
 WHERE l.id = 94 AND l.invoice_id = 24 AND l.plan_id IS NULL AND l.amount = 200.00;
DELETE FROM invoice_lines WHERE id = 94 AND invoice_id = 24 AND plan_id IS NULL
   AND EXISTS (SELECT 1 FROM invoice_installment_plans WHERE issuer_id = 1 AND description = 'Refs paid, deleted games' AND total_amount = 200.00);

-- Field Paint, Badge Logos, Field rental: 1 of 2 on 2026.24 (already 0 used).
UPDATE invoice_installment_plans SET starts_invoice_year = 2026, starts_invoice_number = 24 WHERE id IN (13, 14, 20) AND issuer_id = 1;
-- ITC 6 of 6 and CASA Player Registrations wait for 2026.25.
UPDATE invoice_installment_plans SET starts_invoice_year = 2026, starts_invoice_number = 25 WHERE id IN (7, 16) AND issuer_id = 1;

UPDATE invoices SET updated_at = now() WHERE id IN (20, 24);
COMMIT;
