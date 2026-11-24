-- 1779 (2026-11-23): Balance — the break-even facts, one a line.
--
-- Owner 2026-11-23: "so really for 104 more members its really like 75 or so
-- real paying ones right?" → "lets post the facts on the balance that its
-- like x more members needed and x full paying etc".  The paragraph under
-- the grant (migs 1768, 1775) becomes fact rows: members needed paying the
-- way members pay now, the same money in fully paying members, what each
-- brings, the share of the full rate really collected, who owes dues now,
-- and the split by practice slot.  Wording only — the numbers are the page's.

BEGIN;
DELETE FROM message_templates
 WHERE kind = 'finances' AND tier IN ('bl_members_needed', 'bl_members_now', 'bl_members_owe', 'bl_members_split');
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance fact: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('heading',                         'bl_f_title',         'To break even without the grant', 1014),
    ('members needed',                  'bl_f_more',          'More members needed — paying the way members pay now', 1015),
    ('members needed, note',            'bl_f_more_note',     'No other new costs than a kit each.', 1016),
    ('the same in full payers',         'bl_f_full',          'The same money as this many members paying in full', 1017),
    ('a member brings',                 'bl_f_per',           'What a member brings a year now', 1018),
    ('a member brings, note',           'bl_f_per_note',      '{per} really collected after fees, less a {kit} kit', 1019),
    ('a full payer brings',             'bl_f_per_full',      'What a member paying in full brings', 1020),
    ('a full payer brings, note',       'bl_f_per_full_note', '{full} a year, {after} after fees, less a {kit} kit', 1021),
    ('share of the full rate',          'bl_f_rate',          'Dues really collected, of the full rate', 1022),
    ('who owes now',                    'bl_f_now',           'Members who owe dues now', 1023),
    ('who owes now, note',              'bl_f_now_note',      '{paid} paid up, {behind} behind', 1024),
    ('by practice slot',                'bl_f_split',         'The members needed, by practice slot', 1025)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);
INSERT INTO schema_migrations (filename) VALUES ('1779-balance-break-even-facts.sql') ON CONFLICT DO NOTHING;
COMMIT;
