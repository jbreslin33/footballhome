-- 1787 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": under a team's
-- way up, what is below it (owner: "also show what is below them … in
-- feeders etc") — every table that feeds its table, level by level.
-- Words only (public page: is_public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — pathway: below', 'apsl_pyramid', 'path_below', 'Below {table} — {n} table(s) feeding it', 115, true, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'path_below');
COMMIT;
