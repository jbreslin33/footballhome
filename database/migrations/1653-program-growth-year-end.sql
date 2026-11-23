-- 1653 (2026-11-23) — 🧮 Program budgets: beside the "New members a month"
-- box, where that number lands by the end of the year.  Owner: "i need to
-- the box to show next to it what that number would do by july end right so
-- i can see if it goes over 70?"  Full roster = the last plan season's
-- teams × roster size (Men's: 2 × 35 = 70).

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — program budgets: members by year end ({to}, {to_month})', 'pb_growth_end', '→ {to} members by the end of {to_month}', 951),
    ('Finances — program budgets: over a full roster ({over}, {full})', 'pb_growth_over', '{over} over the full {full} (reserves)', 952),
    ('Finances — program budgets: under a full roster ({left}, {full})', 'pb_growth_under', '{left} short of the full {full}', 953),
    ('Finances — program budgets: exactly a full roster ({full})', 'pb_growth_full', 'the full {full}', 954)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
