-- 1419 (2026-11-16) — 💵 Men's money: pick any mix of seasons.
-- Owner: "for finances programs. it should allow all to be clicked fall,
-- spring. like click all four to show them all".
-- Page only (FinancesScreen._menMoneyHtml): Whole year clears; each season
-- pill toggles; every picked season is its own column, a Total column when
-- more than one. Words only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: total column', 'pm_col_total', 'Total', 416)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
