-- 1849 (2026-11-24) — 🔺 #apsl-pyramid: "Spin the pyramid" — the whole game as a shape you turn —
-- and the FIFA Club World Cup on top.
--
-- Owner: "is a flat 2d view the best way to show all of this? i feel like a spinning pyramind
-- would be way to go? or multi sided shape. each side is a 'league'. so like at the 1st level
-- club world cup by itself, 2nd level concacaf champtions lieague by itself. then mls by
-- itself at 3rd … then we could spin the shape and zoom in or out and see the standings and
-- the togglles to show or hide concacadf or fifa club world cup could change it like if we
-- toggled them off mls would move upt to 1st level".
--
-- The view is frontend/js/components/pyramid-shape-view.js (PyramidShapeView).  Its top level
-- needs the Club World Cup: tier -1, reached by results (no standards box), its field read
-- like the Champions Cup's (ESPN's team list for the edition, 'fifa.cwc').  Each cup has its
-- own pill under ☰ Show on screen.
INSERT INTO pro_league_tiers (tier, label, by_standards, beside_pyramid)
VALUES (-1, 'World cup of clubs — the continental champions qualify', false, false)
ON CONFLICT (tier) DO NOTHING;

INSERT INTO pro_leagues (tier, name, sort_order, feed_system, feed_locator, refresh_hours, calendar, website_url)
VALUES (-1, 'FIFA Club World Cup', 1, 'espn_teams', 'fifa.cwc', 24, 'fifa', 'https://www.fifa.com/en/tournaments/mens/club-world-cup')
ON CONFLICT (name) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order + v.n, true, true, m.is_public
  FROM message_templates m
  JOIN (VALUES
    (1, 'View: the pyramid as a shape you turn', 'view_shape', '🔺 Spin the pyramid'),
    (2, 'Spin view: how to use it', 'shape_hint', 'Drag to spin · drag up or down to slide · scroll or ± to zoom · tap a side to bring it round and open its tables'),
    (3, 'Spin view: level number on a side ({n})', 'shape_level', 'Level {n}'),
    (4, 'Spin view: close the side panel', 'shape_close', '✕ Close'),
    (5, 'Spin view: turn to the side on the left', 'shape_prev', 'Turn left'),
    (6, 'Spin view: turn to the side on the right', 'shape_next', 'Turn right'),
    (7, 'Caption under the views: the spin view', 'story_view_shape', 'The whole game as one shape: a level per step, a side per league. A league you switch off leaves and everything below moves up.')
  ) AS v(n, label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'view_flow'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);
