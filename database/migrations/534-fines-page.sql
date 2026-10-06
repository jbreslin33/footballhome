-- 534 (2026-10-06) — #fines: the Men's fines on a page of their own.
-- Owner: "we need a fines section. does it get its own or inside
-- finances. i think its own."  Nothing new is stored: the page reads the
-- same derived fines as the #payments boxes (fh_person_fines, mig 460)
-- for everyone on a team whose section has a rate in force, rolled up by
-- month and by player, with where each month's posting to LeagueApps
-- stands.  The words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Fines', l, 'fines', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',   'Picker tile — title',                       'Fines', 780),
    ('tile_sub',     'Picker tile — line under the title',        'Men''s fines — missed RSVPs and no-shows by month, who owes what, what is on LeagueApps', 781),
    ('title',        'Page title',                                '💸 Fines', 782),
    ('subtitle',     'Page subtitle',                             'Worked out from each player''s RSVPs and attendance against the rules below — nothing is typed in; a corrected RSVP or attendance mark corrects the fine. A month''s fines go on LeagueApps with the next month''s dues on its first Friday.', 783),
    ('month_all',    'Month pill — every month',                  'All months', 784),
    ('rules_title',  'Rules box title',                           'The rules', 785),
    ('rules_note',   'Rules box note ({section} {since})',        '{section} only, in effect since {since}. Change a rate by migration (fine_policies).', 786),
    ('empty',        'No fines in the picked month',              'No fines {month}.', 787),
    ('so_far',       'Current month tag',                         'so far', 788),
    ('posted',       'Posting state — on LeagueApps',             'on LA {date}', 789),
    ('not_posted',   'Posting state — first Friday passed, no charge', 'NOT ON LA', 790),
    ('due',          'Posting state — post on first Friday',      'post {date}', 791),
    ('drift',        'Posting state — a different amount was posted', 'LA has {amount}', 792),
    ('no_shows_note','Why the no-show rows are empty',            'No-show fines need attendance marked on #attendance after the event; with none marked, only missed RSVPs are fined.', 793)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'fines' AND m.tier = v.t);
