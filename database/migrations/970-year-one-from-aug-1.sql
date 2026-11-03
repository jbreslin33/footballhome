-- 970 (2026-11-03) — Aug 1, 2026 is day one: income and expenses both count
-- from the start of the 2026-27 budget year.
-- Owner 2026-11-03: "so same for income" / "count all income for august going
-- forward. any expenses or invoice before aug 1 we don't worry about now. like
-- pretend 1st year of club".
--   #cash-flow starts at its budget year (was 10/1, mig 887); all Aug–Sep
--   money in already came through the 8 counted programs.
--   budget_lines.paid_before_usd now means "paid before the budget year":
--     APSL: installments 1–13 of 16 (83.75 each) were billed before the
--       app's invoice history (mig 721) → ,388.75 paid before.
--     Liga 1: the owner's 9/29 "paid so far 769.69" included the Aug 29
--       payment plan (25.10 × 2 on 2026.17 / 2026.18, both after Aug 1), so
--       19.49 was paid before and the plan now counts toward the line.
BEGIN;
ALTER TABLE cash_flow_policies ADD COLUMN IF NOT EXISTS budget_year_id INTEGER REFERENCES budget_years(id);
UPDATE cash_flow_policies p SET budget_year_id = y.id, starts_on = y.starts_on
  FROM budget_years y WHERE y.club_id = p.club_id AND y.label = '2026-27' AND p.club_id = 134;
ALTER TABLE cash_flow_policies ALTER COLUMN budget_year_id SET NOT NULL;

UPDATE budget_lines SET paid_before_usd = 2388.75,
       note = '$1,750 club fee − $250 reserve credit + 36 players × $40 (APSL Delaware River fees, mig 965); installments 1–13 paid before Aug 1 (mig 970)'
 WHERE id = 1 AND paid_before_usd = 0;
UPDATE budget_lines SET paid_before_usd = 519.49 WHERE id = 2 AND paid_before_usd = 769.69;
UPDATE invoice_installment_plans SET budget_line_id = 2 WHERE id = 10 AND budget_line_id IS NULL;
COMMIT;
