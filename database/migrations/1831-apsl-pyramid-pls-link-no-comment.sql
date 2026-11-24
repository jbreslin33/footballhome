-- 1831 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the box between
-- the pro leagues and the APSL is the Professional League Standards link
-- and nothing else (owner: "also take out my editorializing in the
-- standards. just put the standards there lol as a link with no comment").
-- The two paragraphs of comment (migs 1788–1797) are deleted.
BEGIN;
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier IN ('path_pro_note', 'path_pro_bridge');
COMMIT;
