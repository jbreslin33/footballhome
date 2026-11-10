-- 1213: dues notices talk about the amount due now, nothing else.
--
-- Drops from every payment notice (email + text, all six tiers, both the
-- release and selection policies):
--   "Next month posts {deadline}[, which puts you at {pause_amount} owed]."
--   "The balance must be paid in full."  (added by 1212)
-- Each notice already says what's owed ({amount}) and links to pay it.
-- Behind_2 (release policy, 286/289) lost its release warning with the
-- deadline sentence, so it now says it the same way behind_3 does.
-- Behind_1's "Reaching {pause_amount} owed (… {pause_date}) could lead
-- shortly to release" is untouched.

BEGIN;

-- behind_2 release: deadline sentence carried the release warning.
UPDATE message_templates SET body = replace(body,
  '[[Your next month posts {deadline}, which puts you at {pause_amount} owed. That could lead shortly to release from the team roster. ]]',
  'This could lead shortly to release from the team roster. '),
  updated_at = now() WHERE id = 286;
UPDATE message_templates SET body = replace(body,
  '[[ Next month posts {deadline}, which puts you at {pause_amount} owed. That could lead shortly to release from the team roster.]]',
  ' This could lead shortly to release from the team roster.'),
  updated_at = now() WHERE id = 289;

-- Every other "next month posts" bracket, and the paid-in-full line.
UPDATE message_templates
   SET body = regexp_replace(
                regexp_replace(
                  regexp_replace(
                    regexp_replace(body,
                      '\[\[ ?(Your next|Next) month posts \{deadline\}[^\]]*\]\]', '', 'g'),
                    ' ?The balance must be paid in full\.', '', 'g'),
                  '[ ]+(\n|$)', '\1', 'g'),          -- trailing spaces
                '\n{3,}', E'\n\n', 'g'),            -- emptied lines
       updated_at = now()
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND is_active;

DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE is_active
     AND kind IN ('payment_notice_email', 'payment_notice_sms', 'my_dues')
     AND concat_ws(' ', subject, body, html_body)
         ~* '(\{deadline\}|next month|paid in full|plan|partial|pay what you can|at least)';
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1213: next-month / plan / partial wording still in dues copy ids %', bad;
  END IF;
END $$;

COMMIT;
