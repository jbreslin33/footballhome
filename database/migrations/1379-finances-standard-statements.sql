-- 1379 (2026-11-14) — #finances = the standard nonprofit reports, and only those.
--
-- Owner 2026-11-14: "we said if you need to start over do it. it needs to be
-- standard and standard only lol. we can always add custom later."
--
-- Pills: Statement of Financial Position · Statement of Activities · Operating
-- Budget · Budget vs Actual · Cash Flow Forecast.
--   • Soccer fund → Statement of Financial Position (assets, liabilities, net
--     assets without / with donor restrictions).
--   • Actuals (MoneyView money-in/out explorer) → Statement of Activities
--     (revenue and support, released from restrictions, expenses, change in net
--     assets). MoneyView and the old #cash-flow screen are deleted; #cash-flow
--     links land on #finances; its menu page row is removed.
--   • Cash forecast → Cash Flow Forecast (beginning cash, receipts, payments,
--     net cash flow, ending cash).
--   • Budget: the self-sufficiency line (mig 1378) removed — not a standard line.
-- income_awards.purposes: the expense categories an award may pay for (what
-- releases it from restriction); the $50k soccer grant = coaching, referees,
-- equipment. Wording rows nothing reads any more are deleted, root and stem.
BEGIN;

ALTER TABLE income_awards ADD COLUMN IF NOT EXISTS purposes text[];
COMMENT ON COLUMN income_awards.purposes IS 'Expense categories (invoice_line_categories.code) the award may pay for; spending on them releases it from donor restriction (mig 1379). NULL = the single purpose column, or unrestricted.';
UPDATE income_awards SET purposes = ARRAY['labor', 'referees', 'equipment']
 WHERE kind = 'grant' AND source_name = 'Soccer grant (3 years)' AND label = 'Coaches, referees and equipment';

DELETE FROM menu_pages WHERE code = 'cash-flow';

DELETE FROM message_templates WHERE kind = 'cash_flow';
DELETE FROM message_templates WHERE kind = 'finances' AND tier IN (
    'budget_settled_hint','capacity_club_covers','capacity_spare','cash_note','cash_title','expand_hint','expenses_title',
    'fund_asof','fund_assets_total','fund_awards_owed','fund_cash','fund_cash_awards','fund_cash_dues','fund_cash_neg',
    'fund_cash_other','fund_cash_paid','fund_cash_rental','fund_deposits','fund_drafts','fund_dues_owed','fund_has',
    'fund_liab_total','fund_net','fund_note','fund_owes','fund_title','games_invoiced','games_played','pg_club_columns',
    'pg_section_coaches','pill_expenses','pill_fund','pill_money','pill_revenue','plan_grants_share','plan_payments',
    'plan_rosters_note','plan_self_sufficiency','plan_total','plan_total_after_grants','row_dues','row_in','row_net',
    'row_out','usual_hours');

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('title',        '📈 Finances'),
    ('subtitle',     'The standard nonprofit financial reports for soccer, a Lighthouse program. Billing stays on Tuition.'),
    ('pill_plan',    '📋 Operating Budget'),
    ('pill_variance','⚖️ Budget vs Actual'),
    ('plan_title',   'Operating Budget')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: Statement of Financial Position', 'pill_position', '🏦 Statement of Financial Position', 220),
    ('Finances — pill: Statement of Activities', 'pill_activities', '📊 Statement of Activities', 221),
    ('Finances — pill: Cash Flow Forecast', 'pill_forecast', '🗓 Cash Flow Forecast', 222),
    ('Finances — Who pills: All', 'pill_all', 'All', 223),
    -- Statement of Financial Position
    ('Finances — SFP: title', 'sfp_title', 'Statement of Financial Position', 230),
    ('Finances — SFP: as of ({date})', 'sfp_asof', 'as of {date}', 231),
    ('Finances — SFP: note', 'sfp_note', 'What soccer owns and owes, club-wide. Soccer is a Lighthouse program with no bank account of its own: Lighthouse receives all the money and pays soccer''s invoices, so cash is what Lighthouse holds for soccer — everything received since soccer''s books began on Aug 1, minus invoices paid (paid once final). Net assets with donor restrictions = grant money not yet spent on what it may pay for.', 232),
    ('Finances — SFP: assets', 'sfp_assets', 'Assets', 233),
    ('Finances — SFP: cash', 'sfp_cash', 'Cash held by Lighthouse for soccer', 234),
    ('Finances — SFP: dues receivable', 'sfp_dues_recv', 'Dues receivable', 235),
    ('Finances — SFP: grants receivable', 'sfp_grants_recv', 'Grants and sponsorships receivable', 236),
    ('Finances — SFP: deposits', 'sfp_deposits', 'Deposits (refundable bonds)', 237),
    ('Finances — SFP: total assets', 'sfp_assets_total', 'Total assets', 238),
    ('Finances — SFP: liabilities', 'sfp_liabilities', 'Liabilities', 239),
    ('Finances — SFP: accounts payable', 'sfp_payable', 'Accounts payable (invoices not final)', 240),
    ('Finances — SFP: total liabilities', 'sfp_liab_total', 'Total liabilities', 241),
    ('Finances — SFP: net assets', 'sfp_net_assets', 'Net assets', 242),
    ('Finances — SFP: net assets without restrictions', 'sfp_net_u', 'Without donor restrictions', 243),
    ('Finances — SFP: net assets with restrictions', 'sfp_net_r', 'With donor restrictions', 244),
    ('Finances — SFP: total net assets', 'sfp_net_total', 'Total net assets', 245),
    ('Finances — SFP: total liabilities and net assets', 'sfp_total', 'Total liabilities and net assets', 246),
    -- Statement of Activities
    ('Finances — SOA: title', 'soa_title', 'Statement of Activities', 250),
    ('Finances — SOA: period ({from}, {to})', 'soa_period', '{from} – {to}', 251),
    ('Finances — SOA: note', 'soa_note', 'Revenue, expenses and the change in net assets since soccer''s books began on Aug 1, club-wide. Expenses are recorded when invoiced; grants and sponsorships when awarded (with donor restrictions when they name what they may pay for); dues when paid through LeagueApps, plus what members owe now. Spending on a grant''s purposes releases that much from restriction.', 252),
    ('Finances — SOA: columns', 'soa_columns', '|Without donor restrictions|With donor restrictions|Total', 253),
    ('Finances — SOA: revenue heading', 'soa_revenue', 'Revenue and support', 254),
    ('Finances — SOA: dues paid', 'soa_dues_paid', 'Dues (paid through LeagueApps, after its fees)', 255),
    ('Finances — SOA: dues owed', 'soa_dues_owed', 'Dues billed, not yet paid', 256),
    ('Finances — SOA: rental', 'soa_rental', 'CASA field rental', 257),
    ('Finances — SOA: other revenue', 'soa_other', 'Other revenue', 258),
    ('Finances — SOA: grants', 'soa_grants', 'Grants', 259),
    ('Finances — SOA: sponsorships', 'soa_sponsors', 'Sponsorships', 260),
    ('Finances — SOA: released', 'soa_released', 'Net assets released from restrictions', 261),
    ('Finances — SOA: total revenue', 'soa_rev_total', 'Total revenue and support', 262),
    ('Finances — SOA: expenses heading', 'soa_expenses', 'Expenses', 263),
    ('Finances — SOA: total expenses', 'soa_exp_total', 'Total expenses', 264),
    ('Finances — SOA: change in net assets', 'soa_change', 'Change in net assets', 265),
    ('Finances — SOA: beginning net assets', 'soa_begin', 'Net assets, beginning of year', 266),
    ('Finances — SOA: ending net assets', 'soa_end', 'Net assets, end of period', 267),
    -- Cash Flow Forecast
    ('Finances — CFF: title', 'cf_title', 'Cash Flow Forecast', 270),
    ('Finances — CFF: note', 'cf_note', 'Cash Lighthouse holds for soccer, month by month, club-wide, starting from zero on Aug 1. Past months are what really moved; this month on is the forecast — dues from members current in dues, CASA bookings on the calendar, grant and sponsor money on the day it arrives, and costs from coaches'' usual hours, game coaching and referees, team fee plans and budget lines.', 271),
    ('Finances — CFF: beginning cash', 'cf_begin', 'Beginning cash', 272),
    ('Finances — CFF: receipts heading', 'cf_receipts', 'Cash receipts', 273),
    ('Finances — CFF: dues ({section})', 'cf_dues', 'Dues — {section}', 274),
    ('Finances — CFF: rental', 'cf_rental', 'CASA field rental', 275),
    ('Finances — CFF: grants and sponsorships', 'cf_awards', 'Grants and sponsorships', 276),
    ('Finances — CFF: total receipts', 'cf_receipts_total', 'Total cash receipts', 277),
    ('Finances — CFF: payments heading', 'cf_payments', 'Cash payments', 278),
    ('Finances — CFF: total payments', 'cf_payments_total', 'Total cash payments', 279),
    ('Finances — CFF: net cash flow', 'cf_net', 'Net cash flow', 280),
    ('Finances — CFF: ending cash', 'cf_end', 'Ending cash', 281)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
