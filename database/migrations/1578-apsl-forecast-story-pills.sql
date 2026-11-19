-- 1578 (2026-11-19) — 📖 #apsl Forecast as a presentation: scope + section
-- pills, plain-English stories with numbers.
--
-- Owner 2026-11-19: "i should be able to focus on all conf. or one conf. or
-- 1 team in conf. it should tell a story and use numbers. it should be
-- understandable to gen pop" + "too much right now on one pill we need more
-- pills. matchup pills for all or 1 team etc. standings predictions thus
-- relegation spots and percents. feeder focus so feeders should have pills
-- … its really a presentation to show how awesome this is and unique in us
-- soccer" + "looks like a hot mess right now".
--
-- Scope: 🇺🇸 All conferences / one conference / one team (🔎 search, or
-- tap). Sections: 📖 Story · 📊 Table · 🎯 Matchups · ⬇⬆ Up & down ·
-- 🪜 Feeders (a pill per feeder). Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_all',                 'Forecast — scope pill: every conference',      '🇺🇸 All conferences', 430),
    ('fc_sec_story',           'Forecast — section pill: story',               '📖 Story', 431),
    ('fc_sec_table',           'Forecast — section pill: predicted table',     '📊 Predicted table', 432),
    ('fc_sec_games',           'Forecast — section pill: matchups',            '🎯 Matchups', 433),
    ('fc_sec_updown',          'Forecast — section pill: up & down',           '⬇⬆ Up & down', 434),
    ('fc_sec_feeders',         'Forecast — section pill: feeders',             '🪜 Feeders', 435),
    ('story_nat_title',        'Story — national title',                       '🇺🇸 The APSL season, played out 10,000 times', 436),
    ('story_nat_head',         'Story — national headline ({confs} {teams} {left} {down})', '{confs} conferences, {teams} teams, {left} games still to play. Our computer plays every one of them, 10,000 times over. Across the country, about {down} teams are expected to be relegated this season.', 437),
    ('story_how',              'Story — how it works ({sims})',                'How it works: each team gets an attack and a defence rating from its results so far (adjusted for who it played). Every remaining game is then simulated with those ratings — {sims} full seasons. A percentage is simply how often something happened in those seasons.', 438),
    ('story_nat_tap',          'Story — national: tap a conference',           'Tap a conference for its story.', 439),
    ('story_card_fav',         'Story — card: favourite ({team} {pct})',       '🏆 Favourite: {team} ({pct} to finish top)', 440),
    ('story_card_risk',        'Story — card: most at risk ({team} {pct})',    '💀 Most at risk: {team} ({pct} to go down)', 441),
    ('story_card_safe',        'Story — card: nobody at risk',                 '✅ Nobody is in real danger of going down', 442),
    ('story_card_spots',       'Story — card: relegation spots ({down} {teams})', '⬇ {down} of {teams} go down this season', 443),
    ('story_conf_size',        'Story — conference size ({conf} {teams} {groups} {played} {left})', '{conf}: {teams} teams, {played} games played, {left} to go.', 444),
    ('story_conf_fav',         'Story — conference favourite ({team} {group} {pct})', '🏆 {team} are favourites to win {group} — {pct} of the simulated seasons.', 445),
    ('story_conf_fav_sure',    'Story — conference winner all but certain ({team} {group} {pct})', '🏆 {team} have {group} all but won ({pct}).', 446),
    ('story_conf_playoff',     'Story — likely playoff sides ({list})',        '🎟 Likeliest to reach the playoffs: {list}.', 447),
    ('story_conf_spots',       'Story — relegation spots ({down} {teams} {pct})', '⬇ This season {down} of the {teams} teams go down — {pct} of the conference.', 448),
    ('story_conf_nobody',      'Story — nobody goes down',                     '✅ Nobody goes down here this season.', 449),
    ('story_conf_doomed',      'Story — teams almost surely down ({list})',    '💀 Almost surely going down: {list}.', 450),
    ('story_conf_risk',        'Story — teams at risk ({list})',               '⚠️ Still in danger: {list}.', 451),
    ('story_conf_up',          'Story — likeliest to come up ({list} {spots})', '⬆ From the leagues below ({spots} spots), likeliest to come up: {list}.', 452),
    ('story_team_now',         'Story — team today ({team} {pos} {group} {pts} {p} {w} {d} {l} {left})', '{team} are {pos} in {group}: {pts} points from {p} games ({w} won, {d} drawn, {l} lost), {left} still to play.', 453),
    ('story_team_odds',        'Story — team odds ({sims} {first} {playoff} {safe} {down})', 'Across {sims} simulated seasons they finish top {first} of the time, reach the playoffs {playoff}, stay clear of every relegation place {safe} and go down {down}.', 454),
    ('story_team_odds_nodown', 'Story — team odds, no relegation ({sims} {first} {playoff})', 'Across {sims} simulated seasons they finish top {first} of the time and reach the playoffs {playoff}.', 455),
    ('story_team_likely',      'Story — team likeliest finish ({pos} {pct} {xpts})', 'Their likeliest finish is {pos} ({pct}), on about {xpts} points.', 456),
    ('story_team_next',        'Story — team next game ({opp} {where} {when} {win} {draw} {lose} {score})', 'Next: {opp} ({where}, {when}). Win {win} · draw {draw} · lose {lose}. Likeliest score {score}.', 457),
    ('story_home',             'Story — at home',                              'home', 458),
    ('story_away',             'Story — away',                                 'away', 459),
    ('story_feeder',           'Story — focused feeder team ({team} {feeder} {pts} {p} {champ} {auto} {up} {conf})', '🔎 {team} play in {feeder}: {pts} points from {p} games. Chance to win their league {champ}, to win the automatic spot {auto}, to reach {conf} in all {up}.', 460),
    ('story_feeder_skip',      'Story — focused feeder team not eligible ({team} {feeder} {why})', '🔎 {team} ({feeder}) can''t be promoted: {why}.', 461),
    ('story_no_games',         'Story — no games left',                        'No games left to play.', 462),
    ('story_all_games',        'Story — every conference: next games ({n})',   'The next {n} scheduled games across the country, with each side''s chances.', 463),
    ('story_col_conf',         'Story — column: conference',                   'Conference', 464),
    ('story_col_likely_down',  'Story — column: likely relegated',             'Likely down (chance)', 465),
    ('story_danger_title',     'Story — heading: who goes down',               '💀 Who goes down — every team by its chance', 466),
    ('story_all_feeders',      'Story — feeder pill: all feeders',             'All feeders', 467)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
