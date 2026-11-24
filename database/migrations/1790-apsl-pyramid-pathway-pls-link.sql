-- 1790 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the step from
-- the APSL to a pro league is U.S. Soccer's Professional League Standards
-- (owner: "show link to pls. show that advancement to pro league a club
-- just needs to meet the us soccer pls").  The note says so and a link row
-- (body = 'label|url') opens U.S. Soccer's own PLS page.  Words only.
BEGIN;
UPDATE message_templates
   SET body = 'No promotion on results: to advance to a pro league a club needs to meet U.S. Soccer''s Professional League Standards (PLS) for that division and join a league sanctioned at it.'
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_note';
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — pathway: PLS link', 'apsl_pyramid', 'path_pro_link',
       '📄 U.S. Soccer Professional League Standards ↗|https://www.ussoccer.com/organization-members-directory/pro-league-standards', 122, true, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_link');
COMMIT;
