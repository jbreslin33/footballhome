-- 845 (2026-10-29) — #apsl-pyramid "Club pathway" view: copy.
--
-- Owner 2026-10-29: "ok continue with pyramid" — the next greyed view pill.
-- Pick a club; each of its teams' routes up the promoting links to the
-- APSL, drawn from PyramidModel.upRoutes() with the flow chart's tables.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('path_search', 'APSL pyramid — pathway: search box',   'Type a club…', 110),
    ('path_pick',   'APSL pyramid — pathway: none picked',  'Pick a club to see its way up the pyramid', 111),
    ('path_team',   'APSL pyramid — pathway: a team',       '{table} · {steps} step(s) up to the APSL', 112),
    ('path_apsl',   'APSL pyramid — pathway: APSL team',    '{table} — in the APSL', 113),
    ('path_none',   'APSL pyramid — pathway: no route',     '{table} — no way up mirrored yet', 114)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
