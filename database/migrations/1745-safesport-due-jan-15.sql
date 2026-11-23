-- 1745 (2026-11-23) — SafeSport is due January 15, 2027 (games resume in
-- February).  Owner: "Lets give them till jan 15th?"
UPDATE onboarding_steps
   SET how = replace(how, 'This must be done before games resume in February,',
                          'This must be done by January 15 (games resume in February),')
 WHERE code = 'safesport' AND how NOT LIKE '%by January 15%';
UPDATE message_templates
   SET body = replace(body, 'It must be done before games resume in February,', 'It must be done by January 15 (games resume in February),')
 WHERE kind = 'onboarding' AND tier = 'intro_player';
UPDATE message_templates
   SET body = replace(body, 'due before games resume in February,', 'due January 15 (games resume in February),')
 WHERE kind = 'onboarding' AND tier = 'player_note';
