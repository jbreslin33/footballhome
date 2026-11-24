-- 1788 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": above the APSL
-- sit the professional leagues (owner: "show that above the apsl its pro?
-- USL League one, MLS NEXT PRO, then usl champ, then mls").  One row per
-- U.S. Soccer professional division, top first: body = 'label|league;league'.
-- The note says the truth of the step: no promotion on results from the
-- APSL — a club is admitted.  Words only (public page: is_public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — pathway: pro heading', 'path_pro_title', 'Above the APSL — the professional leagues', 116),
  ('APSL pyramid — pathway: pro note',    'path_pro_note',  'No promotion on results from the APSL: a club turns professional by meeting U.S. Soccer''s standards and being admitted by the league.', 117),
  ('APSL pyramid — pathway: pro tier 1',  'path_pro_1',     'Division I|MLS', 118),
  ('APSL pyramid — pathway: pro tier 2',  'path_pro_2',     'Division II|USL Championship', 119),
  ('APSL pyramid — pathway: pro tier 3',  'path_pro_3',     'Division III|USL League One;MLS NEXT Pro', 120),
  -- the Show on screen pill that hides / shows them (owner: "we can have show pro toggle?")
  ('APSL pyramid — feature: pro leagues', 'feature_pro',    'Pro leagues above the APSL', 121)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
COMMIT;
