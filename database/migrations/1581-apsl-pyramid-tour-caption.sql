-- 1581 (2026-11-19) — 🔺 #apsl-pyramid: the Presentation view is a fly-
-- around tour (pyramid-present-view.js), so its chapter label and caption
-- say so.  Words only.
BEGIN;
UPDATE message_templates SET body = '▶ Guided tour' WHERE kind = 'apsl_pyramid' AND tier = 'view_present';
UPDATE message_templates SET body = 'Fly around the whole pyramid: tap any box to zoom in, tap a coloured row to see where those teams go, or press Play for a guided tour — the overview, then each conference and the leagues feeding it.'
 WHERE kind = 'apsl_pyramid' AND tier = 'story_view_present';
COMMIT;
