-- 417 — #my dues copy: "INELIGIBLE FOR GAMES & PRACTICE due to overdue tuition".
--
-- Owner 2026-09-23: "it should show in RED INELIGBLE FOR GAMES & PRACTICE
-- due to over due tuition. Pay atleast x to be eligible again."  The red
-- is the screen's; the words are these rows (kind my_dues, migration 416).
UPDATE message_templates SET updated_at = now(),
  body = 'INELIGIBLE FOR GAMES & PRACTICE due to overdue tuition ({amount} owed). Pay at least {min_payment} to be eligible again.'
 WHERE kind = 'my_dues' AND tier = 'banner';
UPDATE message_templates SET updated_at = now(),
  body = 'INELIGIBLE — pay at least {min_payment} here to be eligible again'
 WHERE kind = 'my_dues' AND tier = 'pill';
UPDATE message_templates SET updated_at = now(),
  body = 'Ineligible — overdue tuition'
 WHERE kind = 'my_dues' AND tier = 'lineup_flag';
UPDATE message_templates SET updated_at = now(),
  body = 'Ineligible for games & practice due to overdue tuition. Pay at least {min_payment} to be eligible again.'
 WHERE kind = 'my_dues' AND tier = 'rsvp_refused';
