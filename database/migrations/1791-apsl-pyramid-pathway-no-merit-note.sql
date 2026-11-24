-- 1791 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the note over
-- the pro leagues says it plainly (owner: "unfortunately in the us there is
-- no advancement to pro leagues based on sporting merit. Hopefully US
-- Soccer fixes this as it will improve soccer in the US and make it truly
-- the peoples game and premier sport in the us").  Words only.
BEGIN;
UPDATE message_templates
   SET body = 'Unfortunately, in the U.S. there is no advancement to the pro leagues based on sporting merit. Today a club moves up only by meeting U.S. Soccer''s Professional League Standards (PLS) and joining a league sanctioned at that division. Hopefully U.S. Soccer fixes this — it would improve soccer in the U.S. and make it truly the people''s game and the premier sport in the country.'
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_note';
COMMIT;
