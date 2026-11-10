-- 1211: no partial-payment language in any member communication.
--
-- A member can't pay part of a LeagueApps invoice: the member side only
-- offers the full balance (a partial payment can only be taken by an admin
-- in the LA back office, "partially pay"). So every notice that asked for
-- "Even $5, $10, $15 or $20 … pay what you can", "pay at least $X", or
-- "bring it under $70" sent players to an option that doesn't exist.
--
-- Rewrites:
--   payment_notice_email / _sms behind_1..3 (+ _selection)  285-290, 1954-1959
--     drop the {partial_amounts} sentence, the {keep_active_amount} and
--     {min_payment} asks; "reply with a plan" stays where it was.
--   my_dues banner / pill / rsvp_refused / warning           295, 297, 299, 570
--     "pay at least {min_payment}" → pay the balance.
--   dues_policies.partial_amounts_usd → '{}' on every row, so the token
--     renders empty even if a later copy row brings it back.

BEGIN;

-- ── Emails ────────────────────────────────────────────────────────────
UPDATE message_templates SET body = replace(body,
  ' Even {partial_amounts} shows us you''re still active — pay what you can.', ''),
  updated_at = now() WHERE id = 285;

UPDATE message_templates SET body = replace(replace(body,
  ' — pay at least {keep_active_amount} before then to stay under it. ]]', '. ]]'),
  'Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
  'If you can''t pay it all right now, reply with a plan.'),
  updated_at = now() WHERE id = 286;

UPDATE message_templates SET body = replace(replace(body,
  'Please pay here[[ — at least {min_payment} brings you back under {pause_amount}]]: ', 'Please pay here: '),
  ']]Even {partial_amounts} shows us you''re still active — pay what you can.', ']]'),
  updated_at = now() WHERE id = 287;

UPDATE message_templates SET body = rtrim(replace(body,
  ' Even {partial_amounts} shows us you''re still active — pay what you can.', '')),
  updated_at = now() WHERE id = 1954;

UPDATE message_templates SET body = replace(body,
  ' Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
  ' If you can''t pay it all right now, reply with a plan.'),
  updated_at = now() WHERE id = 1955;

UPDATE message_templates SET body = replace(body,
  ']]Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
  ']]If you can''t pay it all right now, reply with a plan.'),
  updated_at = now() WHERE id = 1956;

-- ── Texts ─────────────────────────────────────────────────────────────
UPDATE message_templates SET body = replace(body,
  ' Even {partial_amounts} shows us you''re still active.', ''),
  updated_at = now() WHERE id IN (288, 1957);

UPDATE message_templates SET body = replace(replace(body,
  ' — pay at least {keep_active_amount} before then to stay under it.]]', '.]]'),
  ' Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
  ' If you can''t pay it all right now, reply with a plan.'),
  updated_at = now() WHERE id IN (289, 1958, 1959);

UPDATE message_templates SET body = replace(replace(body,
  'Please pay here[[ — at least {min_payment} brings you back under {pause_amount}]]: ', 'Please pay here: '),
  ' Even {partial_amounts} shows us you''re still active — pay what you can.', ''),
  updated_at = now() WHERE id = 290;

-- ── #my dues banner / pill / RSVP refusal / warning ───────────────────
UPDATE message_templates SET body = replace(body,
  'Pay at least {min_payment} to be eligible again.', 'Pay your balance to be eligible again.'),
  updated_at = now() WHERE id IN (295, 299);

UPDATE message_templates SET body = replace(body,
  'pay at least {min_payment} here to be eligible again', 'pay your balance here to be eligible again'),
  updated_at = now() WHERE id = 297;

UPDATE message_templates SET body = replace(body,
  'please bring it under {pause_amount} (at least {min_payment}) or', 'please pay it off or'),
  updated_at = now() WHERE id = 570;

-- ── Policy: no partial amounts offered ────────────────────────────────
UPDATE dues_policies SET partial_amounts_usd = '{}';

-- ── Guard: nothing left that asks for part of a balance ───────────────
DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE is_active
     AND concat_ws(' ', subject, body, html_body)
         ~* '(\{partial_amounts\}|\{keep_active_amount\}|\{min_payment\}|pay what you can|at least \{|bring it under)';
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1211: partial-payment copy still in message_templates ids %', bad;
  END IF;
END $$;

COMMIT;
