-- 536 (2026-10-06) — #payments dues notices: the $70 line, said softer.
-- Owner: "lets change 70+ message of owed to softer. that 'This could
-- lead shortly to not being eligible for practice and games..' ... 'or
-- even release from team roster' ... change it everywhere that mess is
-- sent".  The ✉️ / 💬 notice no longer tells anyone they ARE not
-- eligible: at or over the line it says what this could lead to, and the
-- two tiers under the line describe the line the same way.  Wording
-- only — the line itself (dues_policies) and what #my shows a blocked
-- member (kind my_dues) are untouched.
UPDATE message_templates SET updated_at = now(), body =
  E'Hi {first},\n\nYou''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard}\n\n[[Your next month posts {deadline}. ]]Reaching {pause_amount} owed[[ (for you that would be {pause_date})]] could lead shortly to not being eligible for practice and games, or even release from the team roster. Even {partial_amounts} shows us you''re still active — pay what you can.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard}\n\n[[Your next month posts {deadline}, which puts you at {pause_amount} owed. That could lead shortly to not being eligible for practice and games, or even release from the team roster — pay at least {keep_active_amount} before then to stay under it. ]]Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment email — at/over the line (could lose eligibility)',
  subject = '{club} — dues {months_label} behind, please pay', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. This could lead shortly to not being eligible for practice and games, or even release from the team roster.\n\nPlease pay here[[ — at least {min_payment} brings you back under {pause_amount}]]: {form:la_dashboard}\n[[Your next month posts {deadline}. ]]Even {partial_amounts} shows us you''re still active — pay what you can.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_3' AND is_active;

UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard}[[ Next month posts {deadline}.]] Reaching {pause_amount} owed[[ (for you that would be {pause_date})]] could lead shortly to not being eligible for practice and games, or even release from the team roster. Even {partial_amounts} shows us you''re still active.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard}[[ Next month posts {deadline}, which puts you at {pause_amount} owed. That could lead shortly to not being eligible for practice and games, or even release from the team roster — pay at least {keep_active_amount} before then to stay under it.]] Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment text — at/over the line (could lose eligibility)', body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. This could lead shortly to not being eligible for practice and games, or even release from the team roster. Please pay here[[ — at least {min_payment} brings you back under {pause_amount}]]: {form:la_dashboard}[[ Next month posts {deadline}.]] Even {partial_amounts} shows us you''re still active — pay what you can.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_3' AND is_active;
