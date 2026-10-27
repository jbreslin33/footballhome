-- 759: #casa-scores becomes pill based.
--
-- Owner 2026-10-27: "i click casa button from roles. then i click
-- commisioner. then i click score games. then it is pill based. show all
-- (whole season past and future), show past games not scored (this is the
-- money one) — on there is where i can check status of our server side
-- program that auto finds scores … it should give detailed report, then a
-- pill for scored games, etc".
--
-- Pills: Not scored (default) · Upcoming · Scored · Postponed · Whole season.
-- The Not scored pill carries the auto-check report: each run of
-- scripts/casa-insta-scores.js (mig 749) and every post it read, with what
-- it made of it.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'CASA', l, 'casa', t, NULL, b, o, true, true
  FROM (VALUES
    ('scores_pill_waiting',  'CASA scores — pill: played, no score yet',        'Not scored',    70),
    ('scores_pill_upcoming', 'CASA scores — pill: games still to play',         'Upcoming',      71),
    ('scores_pill_scored',   'CASA scores — pill: games with a score',          'Scored',        72),
    ('scores_pill_off',      'CASA scores — pill: postponed / called off',      'Postponed',     73),
    ('scores_pill_all',      'CASA scores — pill: every game of the season',    'Whole season',  74),
    ('scores_upcoming_none', 'CASA scores — Upcoming pill, nothing left',       'No games left to play.', 75),
    ('scores_off_none',      'CASA scores — Postponed pill, none',              'Nothing postponed.', 76),
    ('insta_report_title',   'CASA scores — the auto-check report heading',     '🤖 Auto-check report', 77),
    ('insta_report_hint',    'CASA scores — what the auto-check report is',     'The server reads each club''s Instagram on its own (Sun 6 PM & 11:59 PM, Mon 6 AM & noon, Tue–Sat noon) — every post from game day to 3 days after. A score it finds shows on the game card; it never enters anything on SportsEngine.', 78),
    ('insta_report_runs',    'CASA scores — report: the runs table heading',    'Last runs', 79),
    ('insta_report_posts',   'CASA scores — report: the posts read heading ({n})', 'Posts read, last 10 days · {n}', 80),
    ('insta_report_never',   'CASA scores — report: no run yet',                'The auto-check hasn''t run yet.', 81),
    ('insta_matches_se',     'CASA scores — report: an Instagram score agrees with SportsEngine', '✓ matches SportsEngine', 82),
    ('insta_differs_se',     'CASA scores — report: an Instagram score disagrees ({home} {away})', '⚠ SportsEngine has {home} – {away}', 83)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'casa' AND m.tier = v.t);
