-- Owner 2026-11-06: "smooth it so we are under 2000 even if we have to smooth
-- over more invoices".  Hours and each period's own ref fees stay put; every
-- one-off/plan line spreads forward.  Nothing is copied or dropped: a plan's
-- payment taken off a sheet is issued again by the plan on the next sheet
-- created (Invoice::createNumbered → openPlans, next_no = highest payment on
-- any sheet + 1); plain lines become 2-payment plans with the same total.
--
--   2026.22  hours $956 + refs $985                         = $1,941.00
--   2026.23  hours + refs + Refs paid deleted games $200
--            + Youth u8,u10,u12 6 of 6 $200 (moved from .22)   ≈ $1,848 projected
--   2026.24  hours + refs + APSL dues 15 of 16 + ITC 6 of 6
--            + payment 1 of 2 of everything below            ≈ $1,812 projected
--   2026.25  hours + refs + APSL dues 16 of 16 + payment 2 of 2 ≈ $1,536 projected
--   2-payment plans (1 on .24, 2 on .25): Field rental $209, Lighthouse Badge
--   Logos $252.11, CASA Player Registrations $507.90, CASA Liga 1 League
--   payment $250.19 (existing plans restart at payment 1), Field Paint
--   $122.21, Youth Shirt $10.54, Women's ref fee $94.42 (new plans).
BEGIN;

UPDATE invoice_lines SET invoice_id = 24
 WHERE id = 80 AND invoice_id = 20 AND plan_id = 8 AND installment_no = 6;

INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total, budget_line_id)
SELECT 1, l.category, l.description, l.amount, 2, true, l.budget_line_id
  FROM invoice_lines l
 WHERE l.plan_id IS NULL
   AND ((l.id = 83 AND l.invoice_id = 20 AND l.amount = 10.54)
     OR (l.id = 93 AND l.invoice_id = 20 AND l.amount = 94.42)
     OR (l.id = 87 AND l.invoice_id = 24 AND l.amount = 122.21));
DELETE FROM invoice_lines
 WHERE plan_id IS NULL
   AND ((id = 83 AND invoice_id = 20) OR (id = 93 AND invoice_id = 20) OR (id = 87 AND invoice_id = 24))
   AND EXISTS (SELECT 1 FROM invoice_installment_plans p
                WHERE p.issuer_id = 1 AND p.description = invoice_lines.description
                  AND p.total_amount = invoice_lines.amount AND p.installment_count = 2
                  AND NOT EXISTS (SELECT 1 FROM invoice_lines x WHERE x.plan_id = p.id));

DELETE FROM invoice_lines WHERE invoice_id = 20 AND id = 81 AND plan_id = 12 AND installment_no = 15;
DELETE FROM invoice_lines WHERE invoice_id = 20 AND id = 79 AND plan_id = 7  AND installment_no = 6;
DELETE FROM invoice_lines WHERE invoice_id = 24 AND plan_id IN (13, 14, 16, 17) AND installment_no = 1
   AND id IN (82, 95, 84, 86);

UPDATE invoices SET updated_at = now() WHERE id IN (20, 24);
COMMIT;
