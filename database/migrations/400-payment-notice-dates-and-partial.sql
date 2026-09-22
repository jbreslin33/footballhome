-- 400 — #payments dues notices: firmer, ask for at least a partial payment,
-- and name the dates.
--
-- Owner 2026-09-22: "we need to say it will be paused at 3 months and give
-- the date … first friday can be calculated right? also i think its too
-- soft in general … you must submit at least a partial payment or
-- something about partial so we know they are active".
--
-- New tokens (screen computes them from next_due_at / the upcoming
-- first-Friday rollover):
--   {deadline}   next first-Friday due date          "Friday, October 2"
--   {pause_date} the first Friday they reach 3 months "Friday, November 6"
-- Both sit inside [[ … ]] so the sentence drops when a date is unknown.

UPDATE message_templates SET updated_at = now(), subject = '{club} — dues {months_label} behind', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Please pay now — or at least make a partial payment so we know you''re still active: {form:la_dashboard}\n\n[[Your next month comes due {deadline}. ]][[Members 3 months behind are paused per club policy — for you that would be {pause_date}.]]\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_1';
UPDATE message_templates SET updated_at = now(), subject = '{club} — dues {months_label} behind, action needed', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]] and this needs sorting out. Pay now, or at least make a partial payment so we know you''re still active: {form:la_dashboard}\n\n[[On {pause_date} you''ll be 3 months behind and your membership is paused per club policy — please pay before then.]]\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_2';
UPDATE message_templates SET updated_at = now(), subject = '{club} — membership paused, dues {months_label} behind', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Per club policy your membership is now paused and your spot is on hold.\n\nTo reactivate, pay in full here: {form:la_dashboard}\nIf you can''t clear it at once, make a partial payment and reply with a plan — otherwise we''ll assume you''ve moved on.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_3';

UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Please pay now — or at least a partial payment so we know you''re still active: {form:la_dashboard}[[ Next month comes due {deadline}.]][[ Members 3 months behind are paused — for you that would be {pause_date}.]]'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_1';
UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]] and this needs sorting out. Pay now, or at least a partial payment so we know you''re still active: {form:la_dashboard}[[ On {pause_date} you''ll be 3 months behind and your membership is paused per club policy.]]'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_2';
UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Per club policy your membership is now paused and your spot is on hold. To reactivate, pay in full here: {form:la_dashboard} If you can''t clear it at once, make a partial payment and reply with a plan — otherwise we''ll assume you''ve moved on.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_3';
