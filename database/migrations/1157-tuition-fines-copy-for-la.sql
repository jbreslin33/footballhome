-- 1157 (2026-11-07) — #payments (Tuition): copy a billing cycle's fines as
-- text for the LeagueApps invoice description.
-- Owner: "on tuition page i need these in "copy" form to dump into the desc
-- section when i add to invoice as fines" — and the cycle is "first friday
-- of oct to first fri of nov" (the October cycle = Oct 2 – Nov 5 in 2026),
-- not the calendar month the fines boxes group by.  The button sits in each
-- month's fines panel on the card; the words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Tuition', l, 'tuition_bill', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('fines_desc_button', 'Fines panel — copy-for-LA button ({month} {from} {to} {total})',
                          '📋 Copy {month} fines for LA ({from}–{to}) · {total}', 810),
    ('fines_desc_header', 'LA invoice description — first part ({month} {from} {to} {total})',
                          '{month} fines {from}–{to}: {total}', 811),
    ('fines_desc_kind',   'LA invoice description — one line per fine kind ({count} {label} {amount} {dates})',
                          '{count}× {label} {amount} ({dates})', 812),
    ('fines_desc_copied', 'Toast after copying ({month})',
                          '{month} fines copied — paste into the LA invoice description.', 813)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tuition_bill' AND m.tier = v.t);
