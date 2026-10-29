-- 842 (2026-10-29) — #apsl-pyramid "Presentation" view: copy.
--
-- Owner 2026-10-29: "ok next view is like a prezi type view … make sure
-- they all draw from same source these are just views."  The view flies a
-- camera over the same flow chart (PyramidModel → PyramidFlowView); these
-- are its words.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('view_present',  'APSL pyramid — view pill: presentation',   'Presentation', 80),
    ('present_play',  'APSL pyramid — presentation: play',        '▶ Play', 90),
    ('present_pause', 'APSL pyramid — presentation: pause',       '⏸ Pause', 91),
    ('present_fit',   'APSL pyramid — presentation: whole view',  '⤢ Whole pyramid', 92),
    ('present_full',  'APSL pyramid — presentation: full screen', '⛶ Full screen', 93),
    ('present_level', 'APSL pyramid — presentation: tour step',   '{conference} · feeders, level {level}', 94),
    ('present_hint',  'APSL pyramid — presentation: how to',      'Click a box to fly in · click a coloured row to follow it · scroll or pinch to zoom · drag to pan · ← → to step', 95)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
