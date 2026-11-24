-- 1786 (2026-11-24) — 🔺 #apsl-pyramid: the Conferences row gets a None pill
-- beside All (owner: "have a select all and deselect all").  Each
-- conference pill switches on/off on its own; All lights every one, None
-- clears them, so one tap on None then a conference shows it alone.
-- Words only (public page: is_public).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — None pill', 'apsl_pyramid', 'pill_none', 'None', 31, true, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'pill_none');
COMMIT;
