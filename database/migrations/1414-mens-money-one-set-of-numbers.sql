-- 1414 (2026-11-16) — 💵 Men's money: one set of numbers.
-- Owner "yes" to: the Programs summary row for Men's shows the 💵 table's
-- Whole year (was the programs model: dues $17,786 v the table's $18,048),
-- and a later year's paying men per plan season can be typed on the table
-- again (the only program input the table reads — competitions come from the
-- fee plans, coaching / kits from the Men's budget lines). Words only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: players edit', 'pm_players_edit', 'Paying men per season', 415)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
