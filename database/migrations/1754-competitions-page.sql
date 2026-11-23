-- 1754 (2026-11-23): 🏆 Competitions — its own page in the Money menu.
--
-- Owner 2026-11-23: "call it a competition? the individual things … this is
-- where we gather facts? … then u can roll them up as mens ref fees
-- league/tourny fees etc".  #competitions: one pill per paying side, under it
-- one pill per competition it enters and a Total; each competition's page
-- lists its facts (price × how many, roster size), its estimates and its
-- total.  Read-only step: it shows team_fee_plan_lines as stored.
-- Menu row + wording only; no numbers change.

BEGIN;

UPDATE menu_pages SET sort_order = 6 WHERE code = 'invoices' AND group_code = 'money';
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('competitions', 'money', 'Competitions', '🏆', 'admin', 5, '{competitions}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — competitions: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('title',               'cp_title',       'Competitions', 930),
    ('note',                'cp_note',        'What each competition costs. A price or a count the league or vendor has set is a fact; one we are guessing is an estimate. The total is always worked out, never typed.', 931),
    ('none',                'cp_none',        'No competitions entered yet.', 932),
    ('option tag',          'cp_option',      'option', 933),
    ('option note',         'cp_option_note', 'an option — not in the budget', 934),
    ('options left out',    'cp_options_out', 'Not added in (options): {list}', 935),
    ('paid for by',         'cp_paid_by',     'paid for by {side}', 936),
    ('roster size',         'cp_roster',      'Roster size', 937),
    ('players included',    'cp_included',    'Players the entry fee includes', 938),
    ('facts heading',       'cp_facts',       'Facts — set by the league or vendor', 939),
    ('estimates heading',   'cp_estimates',   'Estimates — a price or a count we are guessing', 940),
    ('payments heading',    'cp_payments',    'Payments to the league', 941),
    ('refundable',          'cp_refundable',  '(refundable, not a cost)', 942),
    ('club total heading',  'cp_total_club',  'Every competition, by kind of cost', 943),
    ('side total heading',  'cp_total_side',  '{side} — every competition, by kind of cost', 944),
    ('column: kind',        'cp_col_kind',    'Kind of cost', 945),
    ('column: what',        'cp_col_what',    'What', 946),
    ('column: price',       'cp_col_price',   'Price', 947),
    ('column: per',         'cp_col_per',     'Per', 948),
    ('column: how many',    'cp_col_count',   'How many', 949),
    ('column: amount',      'cp_col_amount',  'Amount', 950),
    ('column: note',        'cp_col_note',    'Note', 951)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

-- 🧮 Program budgets (#finances): a program's teams are one 🏆 Competitions
-- block of its Overview, and its own lines the Own costs block — no pill each.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — program budgets: competitions block', 'finances', 'pb_sub_comp', '🏆 Competitions', 924, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'pb_sub_comp');
DELETE FROM message_templates WHERE kind = 'finances' AND tier = 'pb_sub_own';

INSERT INTO schema_migrations (filename) VALUES ('1754-competitions-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
