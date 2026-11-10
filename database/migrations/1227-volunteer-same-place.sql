-- 1227: 🙋 Volunteer convenience in the owner's words (2026-11-10: "right
-- after and at same place totally on time for practice. super
-- convenient").  Monday has no men's practice, so "on men's practice nights".

BEGIN;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once the club approves your day, it shows on your Football Home page under 📋 Coach — you''ll RSVP to those practices like any coach. Super convenient: on men''s practice nights our practice is right after, at the same field — help with the kids 5–7 and you''re already there, totally on time for practice at 7. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift}, every week — your practices are on this page under 📋 Coach. Be there on time, and let us know ahead of time if you can''t make it. On men''s practice nights our practice is right after at the same field — you''re already there, on time for 7.'
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
UPDATE message_templates SET body =
  'Out of work? You can volunteer one evening a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my. You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Super convenient: on men''s practice nights our practice is right after, at the same field — help with the kids 5–7 and you''re already there, totally on time for practice at 7. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body =
  'Out of work? Volunteer one evening a week instead — pick one day ({days}) at https://footballhome.org/#my. You must be on time every week and let us know ahead if you can''t make it. Super convenient: our practice is right after at the same field — coach the kids 5–7 and you''re on time for 7. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
