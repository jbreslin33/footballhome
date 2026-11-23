-- 1668 (2026-11-23) — 🧮 Program budgets: the 👥 MEMBERS section as a clear
-- card.  Owner: "we need the members section better" → "it needs to be more
-- clear" (picked: today vs end-of-July table on top, month-by-month under it).
-- Three parts: TODAY beside BY THE END OF <month>; his numbers as labelled
-- boxes; every month ahead (all members, paying, tuition).  Wording only —
-- the numbers are mig 1650 / 1656's.

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — members card: today column', 'pb_m_col_today', 'TODAY', 973),
    ('Finances — members card: year-end column ({month})', 'pb_m_col_end', 'BY THE END OF {month}', 974),
    ('Finances — members card: paying row', 'pb_m_row_paid', 'Paying', 975),
    ('Finances — members card: paying at year end ({pct}, {owing})', 'pb_m_row_paid_end', '{pct}% of {owing} who owe', 976),
    ('Finances — members card: owe, not paying row', 'pb_m_row_behind', 'Owe tuition, not paying', 977),
    ('Finances — members card: non-paying row', 'pb_m_row_free', 'Volunteers and others who don''t pay', 978),
    ('Finances — members card: total row', 'pb_m_row_total', 'ALL MEMBERS', 979),
    ('Finances — members card: on a roster row', 'pb_m_row_roster', 'On a league roster', 980),
    ('Finances — members card: roster size ({full})', 'pb_m_row_roster_of', 'of {full}', 981),
    ('Finances — members card: no roster spot row', 'pb_m_row_nospot', 'No roster spot', 982),
    ('Finances — members card: over a full roster ({n})', 'pb_m_row_over', '{n} of them because the roster is full (reserves)', 983),
    ('Finances — members card: your numbers heading', 'pb_m_yours', 'YOUR NUMBERS — change any box; an empty box uses today''s real count (grey)', 984),
    ('Finances — members card: box moves money', 'pb_m_hint_money', 'moves the money', 985),
    ('Finances — members card: share who pay, recent ({recent})', 'pb_m_hint_collect', 'moves the money · last 3 months {recent}%', 986),
    ('Finances — members card: box is head count', 'pb_m_hint_heads', 'head count only', 987),
    ('Finances — members card: month by month heading', 'pb_m_months', 'MONTH BY MONTH', 988),
    ('Finances — members card: months total column', 'pb_m_months_total', 'Total', 989),
    ('Finances — members card: all members month row', 'pb_m_row_total_lc', 'All members', 990),
    ('Finances — members card: tuition month row ({dues})', 'pb_m_row_tuition', 'Tuition ({dues} each)', 991)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

UPDATE message_templates SET body = 'Volunteers on a roster' WHERE kind = 'finances' AND tier = 'pb_m_free_roster';
UPDATE message_templates SET body = 'Owe tuition, kept off the roster (casual)' WHERE kind = 'finances' AND tier = 'pb_m_off';

-- the first cut's notes (mig 1653 / 1656) are no longer on the page
DELETE FROM message_templates WHERE kind = 'finances'
   AND tier IN ('pb_growth_end', 'pb_growth_over', 'pb_growth_under', 'pb_growth_full', 'pb_m_today', 'pb_m_collect_note', 'pb_m_collect_end',
                'pb_m_free_note', 'pb_m_roster_note', 'pb_m_end', 'pb_m_end_all', 'pb_m_end_roster', 'pb_m_end_roster_open', 'pb_m_end_open', 'pb_m_end_over', 'pb_m_end_off');

-- TODAY uses the Tuition page's own statuses (current / overdue / 🩹 injured /
-- volunteer) so the two pages show the same people — owner: "according to
-- tuition page there are 43 current. 8 vols, 10 overdue".
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — members card: paying row, top table', 'pb_m_row_paid_now', 'Paying (current on tuition)', 992),
    ('Finances — members card: not paying today ({overdue}, {injured})', 'pb_m_row_behind_now', '{overdue} overdue, {injured} injured', 993)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
