-- 1376 (2026-11-14) — #finances Budget + Budget vs Actual in two layers.
--
-- Owner 2026-11-14: "do you understand that soccer is part of lighthouse. they
-- have other programs. lh sends me money that i invoice to lh … we will never
-- physically see the casa or grant money" → "yes do the two layers. la goes to
-- lh too".
--
-- Lighthouse holds ALL the money (LeagueApps dues, grants, CASA rental,
-- sponsors) and pays soccer's invoices. Layer 1: soccer's own dues against its
-- costs — "over budget" on dues alone is expected. Layer 2: the credits
-- Lighthouse adds for soccer (grants, sponsors, CASA rental), and what is left
-- after them. Wording only; no number changes.
BEGIN;

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('plan_revenue',     'Dues — soccer''s own money (paid through LeagueApps to Lighthouse)'),
    ('plan_rev_total',   'Total dues'),
    ('plan_expenses',    'Costs — invoiced to Lighthouse'),
    ('plan_exp_total',   'Total costs'),
    ('plan_net_surplus', 'Left after credits'),
    ('plan_net_deficit', 'Short after credits'),
    ('plan_rev_grant',   'Grant credit — {label} (restricted to {purpose})'),
    ('plan_rev_grant_multi', 'Grant credit — {label} (restricted)'),
    ('plan_rev_sponsor', 'Sponsor credit — {label}'),
    ('plan_rev_rental',  'CASA field rental credit'),
    ('var_net',          'Left after credits'),
    ('plan_note', 'Soccer is a Lighthouse program: Lighthouse holds all the money (LeagueApps dues, grants, CASA rental, sponsors) and pays soccer''s invoices. First layer: soccer''s own dues (paying members × dues × 12) against its costs (rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines) — running over on dues alone is expected. Second layer: the credits Lighthouse adds for soccer — grants (restricted to their purpose), sponsors, and CASA rental (bookings on the calendar) — and what is left after them. Options (Liga 2, Temple 7s) are not in the budget. * = assumed. When money moves is on Cash forecast; what really happened is on Actuals.'),
    ('var_note', 'This budget year''s Budget beside what really happened, through {through} ({months} closed months), in the same two layers: soccer''s dues against its costs, then the Lighthouse credits. Budget to date = the year''s budget × {months}/12, so seasonal costs (league dues paid up front) can run ahead early in the year. Variance: + is good — dues or credits above budget, costs below it. Tap a line to see what was paid.'),
    ('fund_note', 'What soccer has and owes, club-wide (statement of financial position). Soccer is a Lighthouse program with no bank account of its own: Lighthouse receives everything (LeagueApps dues after fees, CASA rental, grants, sponsors) and pays soccer''s invoices, so soccer''s cash is what Lighthouse holds for it — everything credited since Aug 1 minus invoices paid. An invoice counts as paid once it is final. Grant money is restricted to its purpose. Tap the first line to see how it adds up.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: dues minus costs (layer 1)', 'plan_dues_net', 'Dues minus costs (over budget on dues alone when negative)', 208),
    ('Finances — Budget: credits heading (layer 2)', 'plan_credits', 'Lighthouse credits — money Lighthouse holds for soccer', 209),
    ('Finances — Budget: no credits', 'plan_credits_none', 'No credits this year', 210),
    ('Finances — Budget: credits total', 'plan_credits_total', 'Total credits', 211)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
