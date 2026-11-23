-- 1707 (2026-11-23) — 👥 MEMBERS card, MONTH BY MONTH: the whole budget year
-- (owner: "show month by month of since aug right? with accurate number of
-- paying members etc. so its full 12 month").  The months already lived are
-- real (members at the month's end, people whose tuition landed in it, what
-- they paid); the rest is the plan.  Wording only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — members card: real months header', 'pb_m_months_real', 'REAL', 996),
    ('Finances — members card: plan months header', 'pb_m_months_plan', 'PLAN', 997),
    ('Finances — members card: month grid note', 'pb_m_months_note', 'Real = members at the end of the month, people whose tuition landed in it, and what they paid. * this month so far. Plan = your numbers above.', 998)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
