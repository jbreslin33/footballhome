-- 535 (2026-10-06) — #payments (Tuition): the bill a month's fines go on.
-- Owner: "fines should show on the card in tuition screen ... it should
-- work like pro rate. i will then add it to total at end of month. so
-- instead of 35 they will owe 35+. you would then be able to tell i
-- fined them and how much by deducting the diff."  The card already had
-- the month fines boxes; it now also shows the bill itself — this
-- month's (dues + last month's fines, and what LeagueApps holds of it)
-- and next month's so far (dues + this month's fines).  Nothing new is
-- stored; a bill posted above the dues is read back as dues + fines, the
-- fines being the difference (PersonFines).  The words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Tuition', l, 'tuition_bill', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('box_top',        'Bill box — top line ({month})',                           '{month} BILL', 800),
    ('sum',            'Bill box — the sum ({dues} {fines})',                     '{dues} + {fines}', 801),
    ('sum_so_far',     'Next bill box — the sum so far ({dues} {fines})',         '{dues} + {fines} so far', 802),
    ('posted',         'Bill state — all of it is on LeagueApps ({date})',        '✓ {date}', 803),
    ('on_la',          'Bill state — LeagueApps holds another amount ({amount})', '{amount} on LA', 804),
    ('not_posted',     'Bill state — first Friday passed, nothing on LeagueApps', 'NOT POSTED', 805),
    ('post',           'Bill state — post on the first Friday ({date})',          'post {date}', 806),
    ('line',           'Bill line under the fines ({month} {dues} {fines} {fines_month} {total})',
                       '{month} bill: {dues} dues + {fines} {fines_month} fines = {total}', 807),
    ('line_so_far',    'Next bill line under the fines ({month} {dues} {fines} {fines_month} {total} {date})',
                       '{month} bill so far: {dues} dues + {fines} {fines_month} fines = {total} — post {date}', 808),
    ('line_dues_only', 'Bill line when no fines month rides on it ({month} {dues})', '{month} bill: {dues} dues', 809)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tuition_bill' AND m.tier = v.t);
