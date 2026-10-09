-- 548 (2026-10-09) — #dashboard: the admin's front page.
-- Owner: "a live dashboard could be interesting. maybe have cells with
-- important information. like quick dash for rsvps to games and practices
-- to identify trouble spots. payments how many are up to date and late
-- and total collected that month. rosters. how many roster spots out of
-- max are filled. how many uniforms assigned out of players on rosters.
-- leads if any leads not contacted" — "then i could click any cell and go
-- to that page that is already working like go to rsvp reminders tuition
-- etc" — "that would be my front page … make that the top page for all
-- admin. coaches can go to my page to rsvp same with players".
--
-- Nothing new is stored: GET /api/dashboard reads the same models and
-- tables as the pages the cells open (RsvpBoard::weekEvents,
-- PaymentsOverview, person_payments, teams/team_persons,
-- person_uniform_numbers, leads).  The words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',     'Picker tile — title',                         'Dashboard', 800),
    ('tile_sub',       'Picker tile — line under the title',          'The club at a glance — RSVPs, dues, rosters, kit, leads; tap a cell to open its page', 801),
    ('title',          'Page title',                                  '📊 Dashboard', 802),
    ('subtitle',       'Page subtitle',                               'Live from the same boards each cell opens. Tap a cell.', 803),
    ('all_tools',      'Button to the full picker',                   '🧭 All tools', 804),
    ('rsvp_title',     'RSVP cell — title',                           '✅ RSVPs this week', 805),
    ('rsvp_sub',       'RSVP cell — line under the title',            'Released games and practices; players still to answer', 806),
    ('rsvp_sec_M',     'RSVP cell — Men section label',               'Men', 807),
    ('rsvp_sec_W',     'RSVP cell — Women section label',             'Women', 808),
    ('rsvp_sec_B',     'RSVP cell — Boys & girls section label',      'Youth', 809),
    ('rsvp_none',      'RSVP cell — nothing released this week',      'Nothing released yet', 810),
    ('rsvp_clear',     'RSVP cell — everyone answered',               'All answered', 811),
    ('rsvp_trouble',   'RSVP cell — heading over the trouble rows',   'Trouble spots', 812),
    ('rsvp_row',       'RSVP cell — one trouble row ({n} {of} {what})', '{n} of {of} still to answer', 813),
    ('pay_title',      'Payments cell — title',                       '💰 Dues', 814),
    ('pay_sub',        'Payments cell — line under the title',        'Paying members by standing, and what came in this month', 815),
    ('pay_paid_up',    'Payments cell — paid up label',               'Up to date', 816),
    ('pay_behind',     'Payments cell — behind label',                'Behind', 817),
    ('pay_blocked',    'Payments cell — over the line label',         'Over the line', 818),
    ('pay_collected',  'Payments cell — collected label ({month})',   'Collected in {month}', 819),
    ('pay_owed',       'Payments cell — total owed label',            'Owed in all', 820),
    ('roster_title',   'Rosters cell — title',                        '👥 Rosters', 821),
    ('roster_sub',     'Rosters cell — line under the title',         'Spots filled on capped teams; uncapped teams show their count', 822),
    ('roster_full',    'Rosters cell — tag on a full team',           'FULL', 823),
    ('roster_open',    'Rosters cell — open spots line ({n})',        '{n} open', 824),
    ('kit_title',      'Kit cell — title',                            '👕 Uniform numbers', 825),
    ('kit_sub',        'Kit cell — line under the title',             'Players on a roster who have a number', 826),
    ('kit_missing',    'Kit cell — players without a number ({n})',   '{n} without a number', 827),
    ('leads_title',    'Leads cell — title',                          '📋 Leads', 828),
    ('leads_sub',      'Leads cell — line under the title',           'Ad leads nobody has contacted yet', 829),
    ('leads_new',      'Leads cell — not contacted label',            'Not contacted', 830),
    ('leads_active',   'Leads cell — on a running ad ({n})',          '{n} on a running ad', 831),
    ('leads_oldest',   'Leads cell — oldest waiting ({hours})',       'oldest waiting {hours} h', 832),
    ('leads_followup', 'Leads cell — follow-up label',                'Due a follow-up', 833),
    ('leads_clear',    'Leads cell — nothing waiting',                'Everyone contacted', 834),
    ('leads_week',     'Leads cell — new this week label',            'This week', 835),
    ('leads_responded','Leads cell — responded label',                'Responded', 836),
    ('leads_signedup', 'Leads cell — signed up label',                'Signed up', 837),
    ('rsvp_answered',  'RSVP cell — under the big number ({n} {of})',  '{n} / {of} answered', 838),
    ('rsvp_sec_G',     'Kit cell — Girls section label',              'Girls', 839),
    ('updated',        'Footer — when the numbers were read ({time})', 'Read {time}', 840)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);
