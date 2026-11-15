-- 1378 (2026-11-14) — #finances Budget + Budget vs Actual back to the standard
-- nonprofit order (replaces mig 1376's two layers).
--
-- Owner 2026-11-14: "so why does it say we are over budget by 17,437 if we have
-- 50k in grants lol" … "oh you apply grants after." … "is that normal" … "is it
-- standard now? all of it?" — the two layers put a dues-only gap first and it
-- read as the bottom line. Standard: Revenue first, grouped earned (dues, CASA
-- rental) and contributed (grants, sponsors), then Expenses, then one Net
-- surplus / (deficit); plus the usual self-sufficiency line (earned revenue ÷
-- expenses). Lighthouse holding all the money stays in the page notes.
BEGIN;

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('plan_revenue',     'Revenue'),
    ('plan_rev_total',   'Total revenue'),
    ('plan_expenses',    'Expenses'),
    ('plan_exp_total',   'Total expenses'),
    ('plan_net_surplus', 'Net surplus'),
    ('plan_net_deficit', 'Net deficit'),
    ('plan_rev_grant',   'Grant — {label} (restricted to {purpose})'),
    ('plan_rev_grant_multi', 'Grant — {label} (restricted)'),
    ('plan_rev_sponsor', 'Sponsor — {label}'),
    ('plan_rev_rental',  'CASA field rental'),
    ('var_net',          'Net surplus / (deficit)'),
    ('plan_note', 'The operating budget for the year (Aug 1 – Jul 31), in the standard nonprofit order: revenue, expenses, net surplus. Soccer is a Lighthouse program — Lighthouse receives all the money (LeagueApps dues, CASA rental, grants, sponsors) and pays soccer''s invoices; every line here is soccer''s share. Earned revenue = dues (paying members × dues × 12) and CASA rental (bookings on the calendar); contributed = grants (restricted to their purpose) and sponsors. Expenses are rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines. Options (Liga 2, Temple 7s) are not in the budget. * = assumed.'),
    ('var_note', 'This budget year''s Budget beside what really happened, through {through} ({months} closed months). Budget to date = the year''s budget × {months}/12, so seasonal costs (league dues paid up front) can run ahead early in the year. Variance: + is good — revenue above budget, expenses below it. Tap a line to see what was paid.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

DELETE FROM message_templates WHERE kind = 'finances' AND tier IN ('plan_dues_net', 'plan_credits', 'plan_credits_none', 'plan_credits_total');

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: earned revenue group', 'plan_rev_earned', 'Earned', 212),
    ('Finances — Budget: contributed revenue group', 'plan_rev_contributed', 'Contributed', 213),
    ('Finances — Budget: self-sufficiency ({pct})', 'plan_self_sufficiency', 'Self-sufficiency: earned revenue (dues + CASA rental) covers {pct} of expenses; grants and sponsors cover the rest.', 214)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
