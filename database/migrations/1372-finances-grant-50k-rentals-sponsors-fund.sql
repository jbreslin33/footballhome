-- 1372 (2026-11-14) — #finances: $50k grant a year, CASA rentals + sponsors in
-- the Budget, and the 🏦 Soccer fund statement.
--
-- Owner 2026-11-14:
--   "Lets add in 50k in grant per year for next 3 years this year is one of them."
--   "those grants are targeted for refs, coacches and equipment"
--   "all money that goes in comes in via league apps OR is a grant OR is CASA
--    Rental that soccer club handles so we count that as money soccer earned.
--    same with sponsor it would got to lighthouse but not directly to soccer
--    but we need to budget credit for it. all expenses should be listed in
--    invoices."
--   "invoices paid when final, casa always pays"
--
-- 1. Grants: one $50k award per budget year 2026-27 → 2028-29, status awarded,
--    restricted to coaches, referees and equipment (no split given, so one line
--    with purpose NULL — split it into per-purpose rows if the owner gives
--    one). Replaces the nine 'prospect' rows from 11/13 (coaches $15k, refs
--    $5k, equipment $10k a year) so the same grant is not listed twice; no
--    income_receipts pointed at them.
-- 2. Budget revenue now also counts CASA field rentals (calendar bookings in
--    the year, $75/h, field_rental_policies) and sponsorships (income_awards
--    kind 'sponsorship', awarded/received). Received money = income_receipts
--    (dated) or the whole award once marked received.
-- 3. 🏦 Soccer fund pill: statement of financial position, club-wide. Soccer
--    has no bank account of its own (Lighthouse holds the money), so cash =
--    earned since Aug 1 (LA net + rentals + grants/sponsors received) −
--    invoices paid (final); plus dues owed, awards not yet paid, refundable
--    bonds; less invoices still draft.
BEGIN;

DELETE FROM income_awards
 WHERE kind = 'grant' AND status = 'prospect' AND source_name = 'Soccer grant (3 years)'
   AND NOT EXISTS (SELECT 1 FROM income_receipts r WHERE r.award_id = income_awards.id);

INSERT INTO income_awards (club_id, kind, source_name, label, amount_usd, status, budget_year_id, purpose, note)
SELECT 134, 'grant', 'Soccer grant (3 years)', 'Coaches, referees and equipment', 50000, 'awarded', y.id, NULL,
       'Owner 2026-11-14: $50k a year for 3 years, this year one of them; targeted for refs, coaches and equipment'
  FROM budget_years y
 WHERE y.label IN ('2026-27', '2027-28', '2028-29')
   AND NOT EXISTS (SELECT 1 FROM income_awards a WHERE a.budget_year_id = y.id AND a.kind = 'grant' AND a.amount_usd = 50000);

UPDATE message_templates SET body = 'Revenue, expenses and the net result for the budget year (Aug 1 – Jul 31). Dues = paying members × dues × 12; grants and sponsors awarded or received count as revenue (grants restricted to their purpose); field rentals = CASA bookings on the calendar. Expenses are rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines. Options (Liga 2, Temple 7s) are not in the budget. * = assumed. When money moves is on Cash forecast; what really happened is on Actuals.'
 WHERE kind = 'finances' AND tier = 'plan_note';

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — Budget: grant with several purposes ({label})', 'plan_rev_grant_multi', 'Grant (restricted) — {label}', 184),
    ('Finances — Budget: sponsor line ({label})', 'plan_rev_sponsor', 'Sponsor — {label}', 185),
    ('Finances — Budget: field rental income', 'plan_rev_rental', 'Field rental income (CASA)', 186),
    ('Finances — Budget: field rental unit', 'plan_rev_rental_unit', 'bookings on the calendar', 187),
    ('Finances — pill: Soccer fund', 'pill_fund', '🏦 Soccer fund', 188),
    ('Finances — Soccer fund: title', 'fund_title', 'Soccer fund', 189),
    ('Finances — Soccer fund: as of ({date})', 'fund_asof', 'as of {date}', 190),
    ('Finances — Soccer fund: note', 'fund_note', 'What soccer has and owes, club-wide (statement of financial position). Soccer has no bank account of its own — Lighthouse holds its money — so its cash is everything earned since Aug 1 (LeagueApps dues after fees, CASA rentals, grants and sponsors received) minus invoices paid. An invoice counts as paid once it is final. Grant money is restricted to its purpose. Tap the first line to see how it adds up.', 191),
    ('Finances — Soccer fund: assets heading', 'fund_has', 'What soccer has', 192),
    ('Finances — Soccer fund: cash', 'fund_cash', 'Money Lighthouse holds for soccer', 193),
    ('Finances — Soccer fund: dues in', 'fund_cash_dues', 'Dues in (LeagueApps, after its fees)', 194),
    ('Finances — Soccer fund: rentals in', 'fund_cash_rental', 'CASA field rentals', 195),
    ('Finances — Soccer fund: other money in', 'fund_cash_other', 'Other money in', 196),
    ('Finances — Soccer fund: grants + sponsors received', 'fund_cash_awards', 'Grants and sponsors received', 197),
    ('Finances — Soccer fund: invoices paid', 'fund_cash_paid', 'Invoices paid (final)', 198),
    ('Finances — Soccer fund: cash below zero ({amount})', 'fund_cash_neg', 'Below zero: Lighthouse has fronted soccer {amount} so far.', 199),
    ('Finances — Soccer fund: dues owed', 'fund_dues_owed', 'Dues members owe', 200),
    ('Finances — Soccer fund: awards owed', 'fund_awards_owed', 'Grants and sponsors awarded, not paid yet', 201),
    ('Finances — Soccer fund: deposits', 'fund_deposits', 'Refundable deposits (bonds)', 202),
    ('Finances — Soccer fund: assets total', 'fund_assets_total', 'Total soccer has', 203),
    ('Finances — Soccer fund: liabilities heading', 'fund_owes', 'What soccer owes', 204),
    ('Finances — Soccer fund: draft invoices', 'fund_drafts', 'Invoices not final yet', 205),
    ('Finances — Soccer fund: liabilities total', 'fund_liab_total', 'Total soccer owes', 206),
    ('Finances — Soccer fund: net assets', 'fund_net', 'Net assets (has − owes)', 207)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
