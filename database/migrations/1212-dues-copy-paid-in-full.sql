-- 1212: dues are paid in full — no "reply with a plan".
--
-- Follow-up to 1211. A LeagueApps member can only pay the whole balance,
-- so the notices must not invite a payment plan either. The line 1211 left
-- ("If you can't pay it all right now, reply with a plan.") becomes
-- "The balance must be paid in full." on the six notices that carried it
-- (email + text, behind_2 / behind_2_selection / behind_3_selection).

BEGIN;

UPDATE message_templates
   SET body = replace(body,
         'If you can''t pay it all right now, reply with a plan.',
         'The balance must be paid in full.'),
       updated_at = now()
 WHERE id IN (286, 289, 1955, 1956, 1958, 1959);

DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE is_active
     AND kind IN ('payment_notice_email', 'payment_notice_sms', 'my_dues')
     AND concat_ws(' ', subject, body, html_body)
         ~* '(plan|pay what you can|at least|partial|bring it under|\{partial_amounts\}|\{min_payment\}|\{keep_active_amount\})';
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1212: plan/partial wording still in dues copy ids %', bad;
  END IF;
END $$;

COMMIT;
