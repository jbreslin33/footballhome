-- 1264 (2026-11-11) — #fines period pills: each tuition period on its own.
--
-- Owner 2026-11-11: "we should show what is owed for each month 1st friday
-- to day before first friday for fines just like tuition" / "show each
-- month separate and allow me to absolve each month separate and thus
-- charge each month separate".  A pill per period (first Friday → day
-- before the next, mig 1207) that had fines, under the section pills; the
-- running one = the normal board.  A finished period: stats for that period
-- only (fined / still owed / paid, players, by kind), cards in 🔴 OWES FOR ·
-- ✅ PAID FOR · 🟢 NO FINES IN that period, each owing card with
-- 🕊 Absolve all of <period>; 🧾 Fines and 🚩 To bill narrow to it too.
-- Frontend only (data already in GET /api/fines).  Words: kind 'fines'.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Fines', v.label, 'fines', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('period_pill_current', 'Period pill — the running period ({period})',            '{period} so far', 160),
    ('period_stats_title',  'Period stats box title ({period})',                     'Stats · {period}', 161),
    ('period_stat_fined',   'Period stats — total fined in the period',              'Fined', 162),
    ('period_stat_owed',    'Period stats — fines from the period still owed',       '🔴 Still owed', 163),
    ('period_stat_paid',    'Period stats — fines from the period paid',             '✅ Paid', 164),
    ('period_stat_paid_n',  'Period stats — players who paid the period',            '✅ Paid', 165),
    ('period_stat_none',    'Period stats — players with no fines in the period',    '🟢 No fines', 166),
    ('period_sec_owes',     'Period section bar — owe this period ({period})',       'OWES FOR {period}', 167),
    ('period_sec_paid',     'Period section bar — paid this period ({period})',      'PAID FOR {period}', 168),
    ('period_sec_none',     'Period section bar — no fines this period ({period})',  'NO FINES IN {period}', 169),
    ('period_paid_hero',    'Period card — paid label',                              'PAID', 170),
    ('period_none_hero',    'Period card — no fines line ({period})',                'No fines in {period}', 171)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'fines' AND t.tier = v.tier);
