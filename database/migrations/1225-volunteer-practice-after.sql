-- 1225: 🙋 Volunteer copy says men's practice is right after (owner
-- 2026-11-10: "we have to mention that players can then go to practice
-- right after coaching").  Men practice Wed / Fri at 7 PM, right after the
-- 5–7 PM youth evening; Monday has no men's practice, so the words say
-- "on men's practice nights".

BEGIN;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once the club approves your day, it shows on your Football Home page under 📋 Coach — you''ll RSVP to those practices like any coach. On men''s practice nights, our practice starts right after at 7 PM, so you go straight from coaching to your own practice. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift}, every week — your practices are on this page under 📋 Coach. Be there on time, and let us know ahead of time if you can''t make it. On men''s practice nights you go straight from coaching to our practice at 7 PM.'
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
UPDATE message_templates SET body =
  'Out of work? You can volunteer one evening a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my. You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. On men''s practice nights you go straight from coaching to our practice at 7 PM. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body =
  'Out of work? Volunteer one evening a week instead — pick one day ({days}) at https://footballhome.org/#my. You must be on time every week and let us know ahead if you can''t make it. On practice nights you go straight from coaching to our 7 PM practice. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
