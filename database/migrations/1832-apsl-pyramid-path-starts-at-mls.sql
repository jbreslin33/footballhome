-- 1832 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs" starts at the
-- top of the game: no heading over the pro leagues (owner: "the top of
-- that page should just be mls").  The heading's row is deleted.
BEGIN;
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_title';
COMMIT;
