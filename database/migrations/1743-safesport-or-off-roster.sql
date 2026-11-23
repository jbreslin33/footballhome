-- 1743 (2026-11-23) — SafeSport: say what happens if it isn't done.  Owner:
-- "it needs to say this must be done before games resume in February." →
-- "Or players will be removed from rosters."
UPDATE onboarding_steps
   SET how = replace(how, '⏰ This must be done before games resume in February.',
                          '⏰ This must be done before games resume in February, or you will be removed from the roster.')
 WHERE code = 'safesport' AND how NOT LIKE '%removed from the roster%';
UPDATE message_templates
   SET body = 'One thing every men''s player has to do: SafeSport training. It must be done before games resume in February, or you will be removed from the roster. Take the course, upload your certificate, done.'
 WHERE kind = 'onboarding' AND tier = 'intro_player';
UPDATE message_templates
   SET body = 'Every men''s player 18 or older, automatically — due before games resume in February, or they come off the roster. Uploaded = 🟡; tap the chip to see the certificate and mark it ✅ Checked.'
 WHERE kind = 'onboarding' AND tier = 'player_note';
