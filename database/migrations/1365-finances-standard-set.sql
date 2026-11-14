-- 1365 (2026-11-14) — #finances: the standard set.
--
-- Owner: "make it Standard. then we can add my special requests after we see if
-- the standard non profit stuff holds it already … lets be standard".
--
-- Pills renamed to the usual nonprofit names: Budget (operating budget: Revenue,
-- Expenses by category, Net surplus / deficit), Actuals (was Money in & out),
-- Cash forecast (was Expenses), Members (was Summary), Break-even (was At
-- capacity), Scenarios (was Playground).  The Revenue pill is gone — revenue
-- is the top of the Budget now.  Next: Budget vs Actual.
BEGIN;

UPDATE message_templates SET body = v.body
  FROM (VALUES
    ('pill_plan',       '📋 Budget'),
    ('pill_money',      '💵 Actuals'),
    ('pill_expenses',   '🗓 Cash forecast'),
    ('pill_summary',    '👥 Members'),
    ('pill_capacity',   '🎯 Break-even'),
    ('pill_playground', '🧪 Scenarios'),
    ('plan_title',      '📋 Budget — the operating budget for the year'),
    ('plan_note',       'Revenue, expenses and the net result for the budget year (Aug 1 – Jul 31). Expenses are rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines. * = assumed. When money moves is on Cash forecast; what really happened is on Actuals.'),
    ('plan_club_share', 'Share of club-wide costs — {pct} ({active} of {all} paying members)'),
    ('pg_title',        '🧪 Scenarios — can we scale?')
  ) AS v(tier, body)
 WHERE message_templates.kind = 'finances' AND message_templates.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: Revenue heading', 'plan_revenue', 'Revenue', 160),
    ('Finances — Budget: dues line ({section})', 'plan_rev_dues', 'Dues — {section}', 161),
    ('Finances — Budget: dues unit', 'plan_rev_dues_unit', 'paying members × dues a month × 12 months', 162),
    ('Finances — Budget: grant line', 'plan_rev_grant', 'Grant', 163),
    ('Finances — Budget: no revenue on a team pill', 'plan_rev_none', 'No dues on a team — dues are pooled per section', 164),
    ('Finances — Budget: total revenue', 'plan_rev_total', 'Total revenue', 165),
    ('Finances — Budget: Expenses heading', 'plan_expenses', 'Expenses', 166),
    ('Finances — Budget: total expenses', 'plan_exp_total', 'Total expenses', 167),
    ('Finances — Budget: net surplus', 'plan_net_surplus', 'Net surplus', 168),
    ('Finances — Budget: net deficit', 'plan_net_deficit', 'Net deficit', 169),
    ('Finances — Budget: net per month', 'plan_net_month', 'Per month', 170),
    ('Finances — Budget: kits per new player unit', 'plan_unit_new_member', 'new players (joined this year + open roster spots)', 171),
    ('Finances — Scenarios: new-player kits ({n}, {total})', 'pg_kits_base', 'Kits for {n} new players: {total} (players you add here get one too)', 172)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
