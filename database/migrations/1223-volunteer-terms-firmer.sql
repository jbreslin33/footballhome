-- 1223: 🙋 Volunteer commitment, firmer and shorter (owner 2026-11-10:
-- "Must be on time. We can ...actually get you paid." → use the new one).
-- The #my card's terms and both dues-notice lines.

BEGIN;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';

UPDATE message_templates SET body =
  'Out of work? You can volunteer one evening a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my. You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';

UPDATE message_templates SET body =
  'Out of work? Volunteer one evening a week instead — pick one day ({days}) at https://footballhome.org/#my. You must be on time every week and let us know ahead if you can''t make it. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
