-- 1815 (2026-11-24) — 🔺 #apsl-pyramid is the one public APSL page; a pill
-- in its title row copies its address (owner: "what the link is it should
-- be copy link pill").  The pill's label and its two-second "done" (public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — copy link pill', 'link_copy', '🔗 Copy link', 38),
  ('APSL pyramid — copy link pill, just copied', 'link_copied', '✓ Link copied', 39)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
COMMIT;
