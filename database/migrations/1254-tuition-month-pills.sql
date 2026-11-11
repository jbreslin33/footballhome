-- 1254: #payments (Tuition) month pills (owner 2026-11-11: "i want to see
-- previous months pills or stats").  [Nov so far] [Oct] [Sep] [Aug] — the
-- budget year's months (budget_years.starts_on), newest first.  A past
-- month switches the stats box to that month's money (collected less
-- refunds, refunds, payments; club time) and the list to ✅ Paid in
-- <month> / ❌ Didn't pay in <month>.  Past paid-up / overdue status is not
-- stored, so a past month shows only who paid.  Backend: members rows carry
-- yearTransactions + the payload budgetYearStart.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.l, 'payments_overview', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Tuition — this month''s pill ({month})',        'month_pill_current',   '{month} so far',           1256),
    ('Tuition — past month: paid section ({month})',  'month_paid_section',   '✅ PAID IN {month}',        1257),
    ('Tuition — past month: unpaid section ({month})','month_unpaid_section', '❌ DIDN''T PAY IN {month}', 1258),
    ('Tuition — past month stats: money row',         'month_row_money',      'MONEY IN',                 1259),
    ('Tuition — past month stats: collected',         'month_collected',      '💰 Collected',             1260),
    ('Tuition — past month stats: refunds',           'month_refunds',        'Refunds',                  1261),
    ('Tuition — past month stats: payments',          'month_payments',       'Payments',                 1262),
    ('Tuition — past month stats: players row',       'month_row_players',    'PLAYERS',                  1263),
    ('Tuition — past month stats: paid',              'month_paid',           '✅ Paid',                  1264),
    ('Tuition — past month stats: didn''t pay',       'month_unpaid',         '❌ Didn''t pay',            1265)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'payments_overview' AND m.tier = v.t);
