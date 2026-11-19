-- 1580 (2026-11-19) — 🔺 #apsl-pyramid tied together as one story.
-- Owner 2026-11-19: "that includes the whole of #apsl-pyramid make it all
-- tied together and tell a story and easily navigable".
-- One header bar on every view: the views as numbered chapters in story
-- order, and a plain sentence (with the numbers) on what each one shows.
-- Words only (the order lives in apsl-pyramid.js).
BEGIN;
UPDATE message_templates m SET body = v.b
  FROM (VALUES
    ('view_flow',     '① The pyramid'),
    ('view_map',      '② Where they play'),
    ('view_path',     '③ How a club climbs'),
    ('view_tables',   '④ This season'),
    ('view_forecast', '⑤ What happens next'),
    ('view_growth',   '⑥ How it grew'),
    ('view_present',  '▶ Slideshow')
  ) AS v(t, b)
 WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('story_view_flow',     'Pyramid — caption: the pyramid ({confs} {leagues} {clubs} {teams} {states})', 'American soccer usually has no promotion or relegation. The APSL does: {confs} conferences on top, local leagues beneath feeding them — {clubs} clubs, {teams} teams, {states} states. Finish top of your league and you can move up; finish bottom and you can drop. The arrows show who moves where.', 480),
    ('story_view_map',      'Pyramid — caption: where they play ({confs} {clubs} {states})',              'Every conference is a region you can drive across on a matchday. Each coloured area is one of the {confs} conferences; the dots are the {clubs} clubs where they play, across {states} states.', 481),
    ('story_view_path',     'Pyramid — caption: how a club climbs',                                     'Pick any club and see its way up: every league it plays in and each step from there to the top of the pyramid.', 482),
    ('story_view_tables',   'Pyramid — caption: this season ({teams})',                                 'Every table in the pyramid right now — {teams} teams — with the places that win promotion, the playoffs and the drop marked.', 483),
    ('story_view_forecast', 'Pyramid — caption: what happens next',                                     'The rest of the season, played out 10,000 times by computer: who wins, who goes up, who goes down — for the whole country, one conference, or any single team.', 484),
    ('story_view_growth',   'Pyramid — caption: how it grew ({leagues} {teams})',                       'How the pyramid has grown season by season — today {leagues} leagues and {teams} teams.', 485),
    ('story_view_present',  'Pyramid — caption: slideshow',                                             'The whole story as a slideshow, one conference at a time — made for a big screen.', 486)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
