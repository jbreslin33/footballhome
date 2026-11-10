-- 1220: youth dues notices rewritten to the industry-standard parent notice.
--
-- The release-policy tiers (285-290) go to youth only (mig 1152; Men and
-- Women get *_selection). They are sent to the LA contact — the parent —
-- while {first} is the player, so the old "Hi {first}, you're behind on
-- dues" greeted the kid and read like the parent's own membership.
--
-- Every notice now carries the standard steps:
--   1 friendly opener (assumes it was missed)   2 the child's name ({first}'s)
--   3 amount owed / how far past due            4 one pay link
--   5 why dues matter                           6 the consequence
--   7 "questions? reply"                        8 escalation by tier:
--     behind_1 reminder, behind_2 second notice, behind_3 final notice.
-- Consequence is the real one for youth: dropped from the program (no
-- practice/game block exists — mig 1152). No payment-plan or partial
-- wording (mig 1211-1213): LA members can only pay the full balance.

BEGIN;

-- ── Emails ────────────────────────────────────────────────────────────
UPDATE message_templates SET
  subject = '{club} — dues reminder for {first}',
  body = E'Hi,\n\nJust a friendly reminder that {first}''s Lighthouse 1893 dues are past due[[ ({amount} owed)]]. You can pay here: {form:la_dashboard}\n\nDues keep the club running — fields, referees, league fees and coaches for every player. Players whose dues stay unpaid can be dropped from the program.\n\nQuestions about the account? Just reply to this email.\n\nThanks,\nTreasurer, Lighthouse 1893',
  updated_at = now()
WHERE id = 285;

UPDATE message_templates SET
  subject = '{club} — second notice: {first}''s dues',
  body = E'Hi,\n\nThis is a second notice that {first}''s Lighthouse 1893 dues are {months_label} past due[[ ({amount} owed)]]. Please pay here: {form:la_dashboard}\n\nDues keep the club running — fields, referees, league fees and coaches for every player. Players whose dues stay unpaid can be dropped from the program.\n\nQuestions about the account? Just reply to this email.\n\nThanks,\nTreasurer, Lighthouse 1893',
  updated_at = now()
WHERE id = 286;

UPDATE message_templates SET
  subject = '{club} — final notice: {first}''s dues',
  body = E'Hi,\n\nThis is a final notice that {first}''s Lighthouse 1893 dues are {months_label} past due[[ ({amount} owed)]]. Please pay here: {form:la_dashboard}\n\nDues keep the club running — fields, referees, league fees and coaches for every player. If the account isn''t brought up to date, {first} may be dropped from the program.\n\nQuestions about the account? Just reply to this email.\n\nThanks,\nTreasurer, Lighthouse 1893',
  updated_at = now()
WHERE id = 287;

-- ── Texts ─────────────────────────────────────────────────────────────
UPDATE message_templates SET
  body = 'Hi, a friendly reminder from Lighthouse 1893: {first}''s dues are past due[[ ({amount} owed)]]. Pay here: {form:la_dashboard} Dues keep the club running — fields, referees, league fees and coaches. Players whose dues stay unpaid can be dropped from the program. Questions? Just reply.',
  updated_at = now()
WHERE id = 288;

UPDATE message_templates SET
  body = 'Hi, second notice from Lighthouse 1893: {first}''s dues are {months_label} past due[[ ({amount} owed)]]. Pay here: {form:la_dashboard} Dues keep the club running — fields, referees, league fees and coaches. Players whose dues stay unpaid can be dropped from the program. Questions? Just reply.',
  updated_at = now()
WHERE id = 289;

UPDATE message_templates SET
  body = 'Hi, final notice from Lighthouse 1893: {first}''s dues are {months_label} past due[[ ({amount} owed)]]. Pay here: {form:la_dashboard} Dues keep the club running — fields, referees, league fees and coaches. If the account isn''t brought up to date, {first} may be dropped from the program. Questions? Just reply.',
  updated_at = now()
WHERE id = 290;

DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE id IN (285, 286, 287, 288, 289, 290)
     AND (body !~ '\{first\}''s' OR body !~ '\{form:la_dashboard\}' OR body !~* 'reply'
          OR body !~ 'keep the club running' OR body !~ 'dropped from the program'
          OR body ~* '(plan|partial|pay what you can|at least|next month|\{deadline\})');
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1220: youth notice missing a standard step for ids %', bad;
  END IF;
END $$;

COMMIT;
