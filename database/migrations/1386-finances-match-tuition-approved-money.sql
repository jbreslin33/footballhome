-- 1386 (2026-11-14) — #finances matches #tuition, and both count only approved
-- money.
--
-- Owner 2026-11-14: "dues still look off from what you show on tuition page"
-- → "ok make finances match tuition … also make sure it matches what we
-- actually got approved via bank right?" → "or like you said cc goes through
-- right away?"
--
-- • Approved money: a card charge counts at once; a bank (ACH) payment counts
--   once LeagueApps has paid it out (raw.bankTransferId). Until then it is
--   ⏳ pending on #tuition and noted on the Statement of Activities.
-- • #finances dues = LeagueApps money before its fees (as #tuition), less the
--   fines part (FinesCollected, #tuition's rule) — Fines is its own revenue
--   line and LeagueApps fees its own expense (Budget: at LA's actual rate).

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('soa_dues_paid', 'Dues (paid through LeagueApps)'),
    ('var_dues_net', 'Dues are LeagueApps payments before its fees, less fines — as on #tuition; LeagueApps fees (about {pct}) are their own expense. Bank payments count once deposited.'),
    ('plan_rev_dues_unit', 'collected so far (before LeagueApps fees, less fines) + the last 3 months'' average × the months left'),
    ('sfp_note', 'What soccer owns and owes, club-wide. Soccer is a Lighthouse program with no bank account of its own: Lighthouse receives all the money and pays soccer''s invoices, so cash is what Lighthouse holds for soccer — approved money received since soccer''s books began on Aug 1 (cards at once, bank payments once deposited) after LeagueApps fees, minus invoices paid (paid once final). Grants promised for later years are receivable at their full amount (not discounted). Net assets with donor restrictions = grant money not yet spent on what it may pay for, including later years'' installments.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT v.cat, v.label, v.kind, v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances', 'Finances — fines (revenue line)', 'finances', 'soa_fines', 'Fines', 278),
    ('Finances', 'Finances — LeagueApps fees (expense line)', 'finances', 'soa_la_fees', 'LeagueApps fees', 279),
    ('Finances', 'Finances — Budget: LeagueApps fees unit', 'finances', 'plan_la_fees_unit', 'what LeagueApps keeps, at its actual rate', 280),
    ('Finances', 'Finances — SOA: bank payments not yet deposited ({amount})', 'finances', 'soa_pending', '{amount} in bank payments counts once LeagueApps deposits it (card payments count at once).', 281),
    ('Payments', 'Tuition — row: bank payments not deposited yet', 'payments_overview', 'split_row_pending', 'BANK PAYMENTS NOT DEPOSITED YET', 900),
    ('Payments', 'Tuition — cell: pending bank payments', 'payments_overview', 'split_pending', '⏳ Pending', 901)
  ) AS v(cat, label, kind, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = v.kind AND t.tier = v.tier);
