-- 1744 (2026-11-23) — SafeSport: the removal is temporary, and why.  Owner:
-- "Or players will be removed from rosters." → "temporaraliy so we can add
-- players under 18".
UPDATE onboarding_steps
   SET how = replace(how, 'or you will be removed from the roster.',
                          'or you will be temporarily removed from the roster until it is — every adult on the roster has to have it so we can add players under 18.')
 WHERE code = 'safesport' AND how NOT LIKE '%temporarily removed%';
UPDATE message_templates
   SET body = 'One thing every men''s player has to do: SafeSport training. It must be done before games resume in February, or you will be temporarily removed from the roster until it is — every adult on the roster has to have it so we can add players under 18. Take the course, upload your certificate, done.'
 WHERE kind = 'onboarding' AND tier = 'intro_player';
UPDATE message_templates
   SET body = 'Every men''s player 18 or older, automatically — due before games resume in February, or they come off the roster temporarily (so we can add players under 18). Uploaded = 🟡; tap the chip to see the certificate and mark it ✅ Checked.'
 WHERE kind = 'onboarding' AND tier = 'player_note';
