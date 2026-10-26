-- 721 (2026-10-26) — APSL League Dues instalments back on James's sheets
-- (owner: "we stopped at 13 of 16. lets put it back on for 14 this invoice
-- then 15 and 16 next two. APSL League Dues … $2100").  $2,940 in 16 = $183.75 each (owner: "183.75 EACH INSTANCE"; = the #finances APSL row);
-- 1–13 were billed before the app's history (2026.17), so the plan starts
-- with 14 on 2026.21 and openPlans() carries 15 and 16 onto the next two.
DO $$
DECLARE pid int;
BEGIN
  IF EXISTS (SELECT 1 FROM invoice_installment_plans WHERE issuer_id = 1 AND description = 'APSL League Dues') THEN RETURN; END IF;
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total)
  VALUES (1, 'league_dues', 'APSL League Dues', 2940.00, 16, false) RETURNING id INTO pid;
  INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order)
  SELECT v.id, 'league_dues', 'APSL League Dues', 1, 183.75, 183.75, pid, 14, 4
    FROM invoices v
   WHERE v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 21 AND NOT v.is_final;
  UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 21;
END $$;
