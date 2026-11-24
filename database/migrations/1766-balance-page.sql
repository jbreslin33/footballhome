-- 1766 (2026-11-23): ⚖️ Balance — the year in one table, pulled from the four fact pages.
--
-- Owner 2026-11-23: "so now do we need a balance for the year that pulls from
-- all these?"  #balance: money in (member dues → Groups, grants / sponsors /
-- rentals → Other income) less money out (Competitions, Club-wide,
-- LeagueApps' fees) = the balance before the grant; then the grant, "at end
-- as needed up to 50k to break even" (owner 11/23) = the balance of the year.
-- Every line is the Operating Budget's own model (_budgetModel) regrouped by
-- page; only the grant differs — there it counts up to the costs it may pay
-- for, here only as much as the shortfall needs.  Menu row + wording.

BEGIN;

UPDATE menu_pages SET sort_order = sort_order + 1 WHERE group_code = 'money' AND code IN ('groups', 'other-income', 'competitions', 'club-wide', 'invoices');
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('balance', 'money', 'Balance', '⚖️', 'admin', 4, '{balance}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — balance: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('title',           'bl_title',   'Balance', 1000),
    ('note',            'bl_note',    'The whole year in one place: money in less money out. Each line is the total of its own page — tap it to see the facts behind it. The grant comes last, only as much as is needed to break even.', 1001),
    ('money in',        'bl_in',      'MONEY IN', 1002),
    ('money out',       'bl_out',     'MONEY OUT', 1003),
    ('dues line',       'bl_dues',    'Member dues', 1004),
    ('other income',    'bl_other_in','Other income', 1005),
    ('competitions',    'bl_comps',   'Competitions', 1006),
    ('club-wide',       'bl_club',    'Club-wide', 1007),
    ('other costs',     'bl_other_out','Other costs', 1008),
    ('balance row',     'bl_balance', 'BALANCE FOR THE YEAR', 1009),
    ('per month',       'bl_month',   '{amount} a month', 1010),
    ('grant used',      'bl_grant_used', 'Grant used — as needed, up to {award}', 1011),
    ('grant left',      'bl_grant_left', '{left} of the grant not needed', 1012),
    ('grant limit',     'bl_grant_limit','The grant may only pay for {covers} of this year''s costs (what it was given for).', 1013),
    ('members needed',  'bl_members_needed', 'To need no grant: about {more} more paying members ({paying} now), each bringing {per} in a full year after fees.', 1014),
    ('no grant needed', 'bl_no_grant',   'The year pays for itself without the grant.', 1015)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('1766-balance-page.sql') ON CONFLICT DO NOTHING;
COMMIT;
