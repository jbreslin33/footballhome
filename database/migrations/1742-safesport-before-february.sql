-- 1742 (2026-11-23) — SafeSport: say the deadline.  Owner: "it needs to say
-- this must be done before games resume in February."
UPDATE onboarding_steps
   SET how = E'⏰ This must be done before games resume in February.\n' || how
 WHERE code = 'safesport' AND how NOT LIKE '%before games resume in February%';
UPDATE message_templates
   SET body = 'One thing every men''s player has to do: SafeSport training. It must be done before games resume in February. Take the course, upload your certificate, done.'
 WHERE kind = 'onboarding' AND tier = 'intro_player';
UPDATE message_templates
   SET body = 'Every men''s player 18 or older, automatically — due before games resume in February. Uploaded = 🟡; tap the chip to see the certificate and mark it ✅ Checked.'
 WHERE kind = 'onboarding' AND tier = 'player_note';
