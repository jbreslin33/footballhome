-- 894 (2026-10-30) — #cash-flow: the APSL balance, paid off weekly.
--
-- Owner: "apsl payments for league remaining: 2230.00 assume it paid weekly on
-- mondays of 250.00 until balance is paid."  From Monday Nov 2: five payments
-- in November ($1,250), then three more and a last $230 on Dec 28 ($980).

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2026-11', 'APSL league balance, $250 Mondays × 5', 1250.00),
               ('2026-12', 'APSL league balance, $250 Mondays × 3 and last $230', 980.00)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
