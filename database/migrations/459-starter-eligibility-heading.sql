-- 459 — "Starter Eligibility" heading + rollout-length explainer (owner
-- 2026-09-26: "should it have before it Starter Eligibility? … it needs
-- more explanation at least at roll out then we can shorten it after a
-- few weeks").  Wording only; shorten by editing these rows later.
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('eligibility', 'card_heading', 'Game Center — Starter Eligibility card heading',
  'Starter Eligibility', 0);

UPDATE message_templates SET body = 'Starter Eligibility — everyone'
 WHERE kind = 'eligibility' AND tier = 'roster_heading';

UPDATE message_templates SET body =
  'To start a game you need {needed} of the last {lookback} practices. Attendance is taken at every practice, so you never have to do the math — this card does it for you. A Going RSVP counts as projected (yellow) until you attend and are marked present; only then does it count (green). Short? Tap Going on a practice below and it will show what that gets you.'
 WHERE kind = 'eligibility' AND tier = 'rule';

UPDATE message_templates SET body =
  'This game is on or right after a weekday game, so the window is wider than usual: the last {lookback} practices before {cutoff} plus every practice since, all the way to kickoff. You still need {needed}. That is why you will see more than {lookback} practices counted below — more chances to make your {needed}.'
 WHERE kind = 'eligibility' AND tier = 'rule_extended';
