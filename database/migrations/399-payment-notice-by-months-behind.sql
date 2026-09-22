-- 399 — #payments: one dues reminder per channel, worded by months behind.
--
-- Owner 2026-09-22: "the messages for overdue reminders for money need to
-- just say the amount and months … it should just be 1 button and then you
-- calculate how behind and the message is crafted accordingly. $35 due is
-- an acceptable reminder, $70 due is a problem and $105 due we basically
-- are cutting them."
--
-- The screen picks the tier from months behind (LA outstanding balance /
-- monthly dues, migration 270): 1 → behind_1, 2 → behind_2, 3+ → behind_3.
-- Tokens: {first}, {club}, {amount} "$70.00", {months} "2",
-- {months_label} "2 months".  [[ … ]] drops when the amount is unknown.
-- The old Reminder / Firm / Final tiers are retired (is_active = false).

CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text,
                                                  p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- ── email ──────────────────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('payment_notice_email', 'behind_1', 'Payment email — 1 month behind (gentle)',
  '{club} — dues reminder',
  E'Hi {first},\n\nGentle reminder from Lighthouse 1893 — you''re {months_label} behind on dues[[ ({amount})]].\n\nWhen you get a moment, please pay here: {form:la_dashboard}\n\nThanks,\nTreasurer, Lighthouse 1893', 210);
SELECT pg_temp.add_client_tpl('payment_notice_email', 'behind_2', 'Payment email — 2 months behind (firm)',
  '{club} — dues {months_label} behind',
  E'Hi {first},\n\nYou''re now {months_label} behind on dues[[ ({amount})]]. Please pay this week: {form:la_dashboard}\n\nPer club policy a third unpaid month pauses your membership until dues are paid in full.\n\nThanks,\nTreasurer, Lighthouse 1893', 211);
SELECT pg_temp.add_client_tpl('payment_notice_email', 'behind_3', 'Payment email — 3+ months behind (paused)',
  '{club} — membership paused, dues {months_label} behind',
  E'Hi {first},\n\nYou''re {months_label} behind on dues[[ ({amount})]]. Per club policy your membership is paused and your spot is on hold until dues are paid in full.\n\nTo reactivate, pay here: {form:la_dashboard}\n\nThanks,\nTreasurer, Lighthouse 1893', 212);

-- ── text ───────────────────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'behind_1', 'Payment text — 1 month behind (gentle)', NULL,
  'Hi {first}, gentle reminder from Lighthouse 1893 — you''re {months_label} behind on dues[[ ({amount})]]. Please pay when you get a moment: {form:la_dashboard}. Thanks!', 214);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'behind_2', 'Payment text — 2 months behind (firm)', NULL,
  'Hi {first}, you''re now {months_label} behind on dues[[ ({amount})]]. Please pay this week: {form:la_dashboard}. Per club policy a third unpaid month pauses your membership.', 215);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'behind_3', 'Payment text — 3+ months behind (paused)', NULL,
  'Hi {first}, you''re {months_label} behind on dues[[ ({amount})]]. Per club policy your membership is paused until dues are paid in full. To reactivate, pay here: {form:la_dashboard}', 216);

-- ── button labels ──────────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('payment_notice_button', 'email', 'Payment button — email', NULL,
  '✉️ [[{amount} · ]]{months_label}', 218);
SELECT pg_temp.add_client_tpl('payment_notice_button', 'sms', 'Payment button — text', NULL,
  '💬 [[{amount} · ]]{months_label}', 219);

-- ── retire the hand-picked tiers ───────────────────────────────────────
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms')
   AND tier IN ('reminder', 'firm', 'firm_dated', 'final');
