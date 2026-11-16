-- 1410 (2026-11-16) — 💵 Men's money: a competitions subtotal, and the
-- club-wide share shown against the whole club.
-- Owner: "still confused with the men. there should be a total OUT before
-- mens general fee shares. we need the general total like in parens for whole
-- club then the mens share for context."
-- Page only (FinancesScreen._menMoneyHtml): "Money out — competitions" after
-- the competition bands; the club-wide band names the whole club's total and
-- Men's %, each club-wide line as (whole club) × % = Men's share. Words only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: out competitions', 'pm_out_comps', 'Money out — competitions', 408),
    ('Finances — men''s money: share of club', 'pm_share_club', 'Share of club-wide costs (whole club {total}) — Men''s {pct}', 409)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
