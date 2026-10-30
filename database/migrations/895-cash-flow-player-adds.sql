-- 895 (2026-10-30) — #cash-flow: spring player adds.
--
-- Owner: "add in 15 more player adds to main apsl at $40 each spread out
-- equally into may. add in 15 more reserves at $5 each spread till may. add 15
-- player adds to liga 1 at $25 each spread till may."  Seven even months,
-- November to May; May takes the rounding so each total lands exact.

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT to_char(m, 'YYYY-MM'), v.label,
       CASE WHEN m = DATE '2027-05-01' THEN v.total - ROUND(v.total / 7, 2) * 6 ELSE ROUND(v.total / 7, 2) END
  FROM (VALUES ('APSL player adds, 15 at $40', 600.00),
               ('Reserves player adds, 15 at $5', 75.00),
               ('Liga 1 player adds, 15 at $25', 375.00)) AS v(label, total)
 CROSS JOIN generate_series(DATE '2026-11-01', DATE '2027-05-01', interval '1 month') AS m
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.label = v.label AND p.ym = to_char(m, 'YYYY-MM'));
