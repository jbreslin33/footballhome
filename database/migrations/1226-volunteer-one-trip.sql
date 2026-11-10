-- 1226: 🙋 Volunteer copy sells the convenience (owner 2026-11-10: "show
-- the convenience of that") — one trip to the field: help with the youth
-- 5–7, then our practice at 7.  Monday has no men's practice, so still
-- "on men's practice nights".

BEGIN;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once the club approves your day, it shows on your Football Home page under 📋 Coach — you''ll RSVP to those practices like any coach. The easy part: on men''s practice nights it''s one trip to the field — help with the kids 5–7, then walk straight into our practice at 7. No extra drive, no waiting around. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift}, every week — your practices are on this page under 📋 Coach. Be there on time, and let us know ahead of time if you can''t make it. On men''s practice nights it''s one trip: coach 5–7, then straight into our practice at 7.'
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
UPDATE message_templates SET body =
  'Out of work? You can volunteer one evening a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my. You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. It fits right in: on men''s practice nights it''s one trip to the field — help with the kids 5–7, then straight into our practice at 7, no extra drive. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body =
  'Out of work? Volunteer one evening a week instead — pick one day ({days}) at https://footballhome.org/#my. You must be on time every week and let us know ahead if you can''t make it. One trip on practice nights: coach the kids 5–7, then straight into our 7 PM practice. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
