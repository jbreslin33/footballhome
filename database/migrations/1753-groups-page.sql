-- 1753 (2026-11-23): 👥 Groups — its own page in the Money menu.
--
-- Owner 2026-11-23: "we can have hard groups. men, women, u8 … these are
-- immutable and cannot share … this is where dues come from … can this be at
-- same level as tuition and fines etc? … groups is total focused on money
-- coming in from groups … or not coming in like dead beats … member dues
-- based … no grants etc … it should not have liga 1 etc just 'human' groups".
--
-- #groups: one pill per group (the programs of 🧮 Program budgets, mig 1639 —
-- a member counted once) and a Total pill at the end.  A group's page is its
-- MEMBERS card only: paying, owe and not paying, don't pay, tuition month by
-- month.  No costs, no competitions, no grants — those stay on #finances
-- 🧮 Program budgets and #competitions.  Menu row + wording; no numbers change.

BEGIN;

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('groups', 'money', 'Groups', '👥', 'admin', 4, '{groups}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — groups: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('title',                 'gr_title',       'Groups', 960),
    ('note',                  'gr_note',        'Member dues by group: who is paying and who is not. Every member is in one group only.', 961),
    ('total pill',            'pb_total',       'Total', 962),
    ('none',                  'gr_none',        'No members expected.', 963),
    ('column: group',         'gr_col_group',   'Group', 964),
    ('column: paying',        'gr_col_paid',    'Paying now', 965),
    ('column: not paying',    'gr_col_behind',  'Owe, not paying', 966),
    ('column: free',          'gr_col_free',    'Don''t pay', 967),
    ('column: all',           'gr_col_all',     'All members', 968),
    ('column: tuition',       'gr_col_tuition', 'Tuition for the year', 969)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('1753-groups-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
