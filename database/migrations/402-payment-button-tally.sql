-- 402 — #payments dues buttons carry the per-channel send tally.
--
-- Owner 2026-09-22: "tally them separately in db and on button so I can
-- see oh I sent 2 emails and no rsvp response yet so let me try a text".
-- {sent} = how many times this channel was used for this member
-- (pay_reminder_log); the [[ … ]] block drops at zero.
UPDATE message_templates SET updated_at = now(), body = '✉️ [[{amount} · ]]{months_label}[[ · sent ×{sent}]]'
 WHERE kind = 'payment_notice_button' AND tier = 'email';
UPDATE message_templates SET updated_at = now(), body = '💬 [[{amount} · ]]{months_label}[[ · sent ×{sent}]]'
 WHERE kind = 'payment_notice_button' AND tier = 'sms';
