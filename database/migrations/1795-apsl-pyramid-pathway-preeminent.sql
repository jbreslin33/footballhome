-- 1795 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the note's last
-- words are "the preeminent sport" (owner's word; mig 1791 read his typo
-- as "premier").  Words only.
BEGIN;
UPDATE message_templates
   SET body = replace(body, 'the premier sport in the country', 'the preeminent sport in the country')
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_note';
COMMIT;
