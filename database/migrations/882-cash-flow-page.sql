-- 882 (2026-10-30) — #cash-flow: LeagueApps money in against invoices out.
--
-- Owner: "do an analysis for all soccer program of money coming in and
-- projected to come in" … "use la money coming in and all invoices going
-- out" … "can we make this a page on fh? in the financial section?"
--
-- person_payments is the whole Lighthouse LeagueApps site (basketball, camps,
-- flag football, food trucks), so soccer has to be named: la_soccer_programs
-- is that list, one group label per program.  A new soccer program in
-- LeagueApps needs a row here; until it has one the page warns about it.

CREATE TABLE IF NOT EXISTS la_soccer_programs (
    la_program_id BIGINT PRIMARY KEY,
    group_label   TEXT NOT NULL,
    sort_order    INT  NOT NULL DEFAULT 100
);
COMMENT ON TABLE la_soccer_programs IS
    'mig 882: the LeagueApps programs that are soccer, grouped for #cash-flow. person_payments covers every Lighthouse program; this names the soccer ones.';

-- The memberships, from their own table.
INSERT INTO la_soccer_programs (la_program_id, group_label, sort_order)
SELECT lp.program_id,
       CASE lp.category WHEN 'men' THEN 'Men''s' WHEN 'women' THEN 'Women''s' WHEN 'boys' THEN 'Boys' WHEN 'girls' THEN 'Girls' END
       || CASE lp.variant WHEN 'active' THEN ' membership' WHEN 'pickup' THEN ' pickup' ELSE ' inactive' END,
       CASE lp.category WHEN 'men' THEN 10 WHEN 'women' THEN 20 WHEN 'boys' THEN 30 WHEN 'girls' THEN 40 END
       + CASE lp.variant WHEN 'active' THEN 0 WHEN 'pickup' THEN 1 ELSE 2 END
  FROM leagueapps_programs lp
ON CONFLICT (la_program_id) DO NOTHING;

-- The earlier programs, by name, from the payments themselves.
INSERT INTO la_soccer_programs (la_program_id, group_label, sort_order)
SELECT DISTINCT ON (pp.la_program_id) pp.la_program_id,
       CASE WHEN pp.program_name ~* 'women'                                  THEN 'Earlier women''s programs'
            WHEN pp.program_name ~* 'jersey'                                 THEN 'Jerseys'
            WHEN pp.program_name ~* 'youth|in house|elites|pros|indoor|travel team|U13 player' THEN 'Earlier youth programs'
            ELSE 'Earlier men''s programs' END,
       CASE WHEN pp.program_name ~* 'women'                                  THEN 60
            WHEN pp.program_name ~* 'jersey'                                 THEN 80
            WHEN pp.program_name ~* 'youth|in house|elites|pros|indoor|travel team|U13 player' THEN 70
            ELSE 50 END
  FROM person_payments pp
 WHERE (pp.program_name ~* 'soccer|travel team|youth u13 player registration|apsl|casa')
   AND pp.program_name !~* 'food|vendor'
 ORDER BY pp.la_program_id
ON CONFLICT (la_program_id) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Finances', l, 'cash_flow', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',    'Role picker tile',                    'Money In & Out', 1),
    ('tile_sub',      'Role picker tile, second line',       'LeagueApps money in against invoices out, month by month and what is ahead', 2),
    ('title',         'Page title',                          '💵 Money In & Out', 3),
    ('subtitle',      'Under the page title',                'Soccer only. LeagueApps money in against invoices out.', 4),
    ('pill_paid_up',  'Projection pill',                     'Members current in dues', 5),
    ('pill_paying',   'Projection pill',                     'Every paying member', 6),
    ('card_since',    'Strip card ({month})',                'Since invoices began ({month})', 7),
    ('card_ahead',    'Strip card ({n} months)',             'Next {n} months, projected', 8),
    ('card_owed',     'Strip card',                          'Owed to the club now', 9),
    ('in',            'Money in',                            'In', 10),
    ('out',           'Money out',                           'Out', 11),
    ('net',           'In minus out',                        'Net', 12),
    ('running',       'Running total',                       'Running', 13),
    ('month',         'Month column',                        'Month', 14),
    ('so_far',        'This month''s row',                   'so far', 15),
    ('projected',     'A projected row',                     'projected', 16),
    ('months_title',  'Month table heading',                 'Month by month', 17),
    ('months_note',   'Month table note ({month})',          'Money in is what LeagueApps paid out after its fees, less refunds. Money out is every invoice, drafts included, by invoice date, plus the #finances projection ahead. Invoices only start in {month}, so earlier months show money in with nothing against it. Running starts from zero at the top row: it is not a bank balance.', 18),
    ('ahead_note',    'Projection note ({rate}, {fee})',     'Ahead: members × {rate} a month, less {fee}% LeagueApps fees (last 12 months). Pickup memberships are not projected. The season''s money out does not fall evenly, so read months together.', 19),
    ('programs_title','Programs heading',                    'Money in by program', 20),
    ('program',       'Program column',                      'Program', 21),
    ('last_12',       'Last 12 months column',               'Last 12 months', 22),
    ('this_year',     'This calendar year column',           'This year', 23),
    ('invoices_title','Invoices heading',                    'Invoices by category', 24),
    ('category',      'Category column',                     'Category', 25),
    ('final',         'Final invoices column',               'Final', 26),
    ('draft',         'Draft invoices column',               'Draft', 27),
    ('total',         'Total column',                        'Total', 28),
    ('unmapped',      'Warning ({names})',                   '⚠ Not counted yet, soccer-looking programs with recent money: {names}. Add them to la_soccer_programs.', 29),
    ('untied',        'Warning ({amount})',                  '⚠ {amount} of invoices are not tied to a budget line or a game, so the projected money out may still count them. Pick "counts toward" on each line on #invoices and this goes away.', 30)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cash_flow' AND m.tier = v.t);
