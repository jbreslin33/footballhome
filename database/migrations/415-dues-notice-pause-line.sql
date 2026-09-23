-- 415 — Dues notices name the pause line and the least to pay to stay under it.
--
-- Owner 2026-09-23: "maybe we need a threshold amount that makes a paused
-- membership. like bring it down to under $70 so membership is not
-- paused. so by bringing this month to under $35 when oct 2nd hits you
-- will be safely under the $70 2months behind threshold. but can you
-- clean it up lol".
--
-- Cleaned up: membership pauses at {pause_amount} owed (pause months ×
-- rate, $105).  Months behind is ceil(owed / rate), so a member stays
-- active through the next rollover only if they carry at most
-- (pause months − 2) × rate ($35) into it.  {keep_active_amount} is what
-- that takes now (owed − $35; $70 behind → pay $35), '' when the next
-- month can't pause them, so its [[ … ]] drops.  Both tokens come from
-- dues_policies via the screen (payments.js _pauseLine); no number here.
-- {partial_amounts} (migration 414) stays as the "show us you're active"
-- floor.  Subjects unchanged.
UPDATE message_templates SET updated_at = now(), body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Please pay now: {form:la_dashboard}\n\n[[Your next month posts {deadline}. ]][[Membership pauses at {pause_amount} owed — for you that would be {pause_date}. ]]Can''t clear it at once? Even {partial_amounts} shows us you''re still active — pay what you can.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]] and this needs sorting out. Pay here: {form:la_dashboard}\n\n[[Membership pauses at {pause_amount} owed. Your next month posts {deadline} — pay at least {keep_active_amount} before then and you stay active. ]]Can''t clear it at once? Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Membership pauses at {pause_amount} owed, so per club policy yours is paused and your spot is on hold.\n\nTo reactivate, pay in full here: {form:la_dashboard}\n[[Can''t clear it at once? Pay at least {keep_active_amount} now — that gets you back under the line and keeps you there when the next month posts {deadline} — and reply with a plan. ]]Even {partial_amounts} tells us you''re still with us; silence, and we''ll assume you''ve moved on.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_3' AND is_active;

UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Please pay now: {form:la_dashboard}[[ Next month posts {deadline}.]][[ Membership pauses at {pause_amount} owed — for you that would be {pause_date}.]] Can''t clear it at once? Even {partial_amounts} shows us you''re still active.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]] and this needs sorting out. Pay here: {form:la_dashboard}[[ Membership pauses at {pause_amount} owed. Next month posts {deadline} — pay at least {keep_active_amount} before then and you stay active.]] Can''t clear it at once? Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount})]]. Membership pauses at {pause_amount} owed, so per club policy yours is paused and your spot is on hold. To reactivate, pay in full: {form:la_dashboard}[[ Can''t clear it at once? Pay at least {keep_active_amount} now — back under the line and still there when next month posts {deadline} — and reply with a plan.]] Even {partial_amounts} tells us you''re still with us; silence, and we''ll assume you''ve moved on.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_3' AND is_active;
