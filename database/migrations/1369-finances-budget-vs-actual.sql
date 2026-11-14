-- 1369 (2026-11-14) — #finances: ⚖️ Budget vs Actual, the variance report.
--
-- Owner 2026-11-14 "yes" to starting it, after "just the standard industry
-- standard for non profits": the next standard report after the operating
-- budget. Each Budget line for this budget year beside the money that really
-- came in and went out, through the last closed month. Budget to date = year
-- budget × closed months / 12; variance favourable when positive (revenue
-- above budget, expenses below it). Wording only — the page computes it from
-- /api/finances/expenses + /api/finances/cash-flow.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: Budget vs Actual', 'pill_variance', '⚖️ Budget vs Actual', 175),
    ('Finances — Budget vs Actual: title', 'var_title', 'Budget vs Actual', 176),
    ('Finances — Budget vs Actual: note ({through}, {months})', 'var_note',
     'This budget year''s Budget beside the money that really came in and went out, through {through} ({months} closed months). Budget to date = the year''s budget × {months}/12, so seasonal costs (league dues paid up front) can run ahead early in the year. Variance: + is good — revenue above budget, expenses below it. Tap a line to see what was paid.', 177),
    ('Finances — Budget vs Actual: columns', 'var_columns', 'Line|Year budget|Budget to date|Actual to date|Variance|Used', 178),
    ('Finances — Budget vs Actual: money not in the budget ({label})', 'var_unbudgeted', '{label} (not in the budget)', 179),
    ('Finances — Budget vs Actual: net row', 'var_net', 'Net surplus / (deficit)', 180),
    ('Finances — Budget vs Actual: nothing paid on a line', 'var_no_actual', 'Nothing paid yet.', 181),
    ('Finances — Budget vs Actual: no closed month', 'var_no_months', 'No month has closed yet in this budget year.', 182),
    ('Finances — Budget vs Actual: dues are net ({pct})', 'var_dues_net', 'Dues actual is what LeagueApps paid out after its fees (it keeps about {pct}); the budget counts dues in full.', 183)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
