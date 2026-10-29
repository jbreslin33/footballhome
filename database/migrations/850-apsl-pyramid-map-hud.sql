-- 850 (2026-10-29) — #apsl-pyramid USA map: full screen, data as a HUD,
-- a conference's pyramid as an overlay with a transparency slider.
--
-- Owner 2026-10-29: "i want map full screen and the data as hud. when you
-- click a conference it comes up as overlay over map. again full screen …
-- the overlay should have transparency dial … or slider."
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('map_full',       'APSL pyramid — map: full screen',        '⛶ Full screen', 106),
    ('map_exit_full',  'APSL pyramid — map: leave full screen',  '⛶ Exit full screen', 107),
    ('map_opacity',    'APSL pyramid — map: overlay slider',     'See-through', 108),
    ('map_close',      'APSL pyramid — map: close overlay',      '✕', 109),
    ('map_dot_apsl',   'APSL pyramid — map legend: APSL club',   'Club with an APSL team', 115),
    ('map_dot_feeder', 'APSL pyramid — map legend: feeder club', 'Feeder club', 116),
    ('map_dot_approx', 'APSL pyramid — map legend: no address',  'At its league (no address)', 117)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
