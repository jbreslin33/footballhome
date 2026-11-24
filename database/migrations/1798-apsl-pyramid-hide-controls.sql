-- 1798 (2026-11-24) — 🔺 #apsl-pyramid is a display page: one button folds
-- the pill rows away (owner: "since this is a display section … we need a
-- way to hide the menus right?" · "yes build it").  ▴ hides the View /
-- Conferences / Show rows, the caption and the site's top bar; ▾ brings
-- them back; full screen starts folded.  The two button labels (public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — hide the pill rows', 'bar_hide', '▴ Hide controls', 32),
  ('APSL pyramid — show the pill rows', 'bar_show', '▾ Controls', 33)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
COMMIT;
