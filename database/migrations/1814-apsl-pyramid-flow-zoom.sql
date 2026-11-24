-- 1814 (2026-11-24) — 🔺 #apsl-pyramid flow chart zooms (owner: "the
-- pyramid needs to allow zoom in and out").  − / % / + / Fit buttons in the
-- chart's corner; the mouse wheel, a pinch and the + − 0 keys do the same.  The Fit
-- label and the three button hints (public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — flow chart zoom: fit button', 'zoom_fit', 'Fit', 34),
  ('APSL pyramid — flow chart zoom: − hint', 'zoom_out', 'Zoom out', 35),
  ('APSL pyramid — flow chart zoom: + hint', 'zoom_in', 'Zoom in', 36),
  ('APSL pyramid — flow chart zoom: % hint', 'zoom_reset', 'Back to 100%', 37)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
COMMIT;
