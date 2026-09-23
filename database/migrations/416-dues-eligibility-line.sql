-- 416 — Dues eligibility: 2 full months behind = not eligible for games and practices.
--
-- Owner 2026-09-23: "we say 2 full months behind is the pause threshold.
-- so that if they can bring it under $70 then they are safe … it may
-- encourage a partial payment to get them used to paying again … we should
-- say no longer eligible for games and practices instead of paused …
-- show they are not eligible in their my page due to balance … pay at
-- least x here to be eligible again … youth same rule".
--
-- Policy (dues_policies, migration 401/414): pause_after_months is now
-- counted in FULL months — floor(owed / rate), not ceil — and the row in
-- force says 2, so the line is $70 owed.  At or over it a member (youth
-- included; the child's balance, the parent's page) is not eligible for
-- games and practices: #my says so on every event with a pay link, the
-- RSVP endpoints refuse a yes, Game Center flags them.  Under it, eligible.
-- The 2026-09-23 row is this morning's (migration 414); corrected in place
-- the same day rather than adding a second row for the same date.
UPDATE dues_policies SET pause_after_months = 2
 WHERE club_id = 134 AND club_section_id IS NULL AND effective_from = DATE '2026-09-23';
COMMENT ON COLUMN dues_policies.pause_after_months IS
  'FULL months behind (floor(owed / monthly_dues_usd)) at which a member is no longer eligible for games and practices; the line in dollars is this × the rate.';

-- The member's dues balance today: what LA says is owed minus paid on
-- their open membership(s) (the sync keeps both, migration 270); 0 when
-- they hold none.  A youth's balance sits on the child's own person row.
CREATE OR REPLACE FUNCTION fh_dues_balance_usd(p_person_id int)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT COALESCE(SUM(GREATEST(0, m.la_amount_owed_cents - m.la_amount_paid_cents)), 0) / 100.0
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
   WHERE m.person_id = p_person_id AND m.ended_at IS NULL
     AND lp.variant IN ('active', 'inactive')
$$;

-- The line in dollars: pause months × the monthly rate.
CREATE OR REPLACE FUNCTION fh_dues_line_usd(p_club_id int, p_club_section_id int DEFAULT NULL)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT fh_dues_pause_after_months(p_club_id, p_club_section_id) * fh_monthly_dues_usd(p_club_id, p_club_section_id)
$$;

-- Eligible for games and practices on dues: balance under the line.
-- NULL policy → eligible (never lock people out on a missing row).
CREATE OR REPLACE FUNCTION fh_dues_eligible(p_person_id int, p_club_id int DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(fh_dues_balance_usd(p_person_id) < fh_dues_line_usd(p_club_id), true)
$$;

-- The least to pay now to get back under the line, whole dollars
-- ($70 owed → $1, $104 → $35); 0 when already under.
CREATE OR REPLACE FUNCTION fh_dues_min_payment_usd(p_person_id int, p_club_id int DEFAULT 134)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT GREATEST(0, CEIL(fh_dues_balance_usd(p_person_id) - fh_dues_line_usd(p_club_id) + 0.01))
$$;

-- ── Dues notices (#payments): three tiers by full months ──────────────
--   behind_1  under a month owed        gentle
--   behind_2  1 full month              firm — the next posting crosses the line
--   behind_3  at / over the line        not eligible for games and practices
-- Tokens: {amount} "$70.00", {months_label} "1 full month", {pause_amount}
-- "$70.00", {keep_active_amount} least to stay under the line after the
-- next posting (tier 2), {min_payment} least to get under it now (tier 3),
-- {partial_amounts}, {deadline}, {pause_date}.  [[ … ]] drops on an empty token.
UPDATE message_templates SET updated_at = now(), label = 'Payment email — under a month owed (gentle)',
  subject = '{club} — dues owed', body =
  E'Hi {first},\n\nYou''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard}\n\n[[Your next month posts {deadline}. ]]At {pause_amount} owed you''re no longer eligible for games and practices[[ — for you that would be {pause_date}]]. Even {partial_amounts} shows us you''re still active — pay what you can.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment email — 1 full month behind (firm)',
  subject = '{club} — dues {months_label} behind, action needed', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard}\n\n[[At {pause_amount} owed you''re no longer eligible for games and practices. Your next month posts {deadline}, which puts you there — pay at least {keep_active_amount} before then and you stay eligible. ]]Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment email — at/over the line (not eligible)',
  subject = '{club} — not eligible for games and practices, dues {months_label} behind', body =
  E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. At {pause_amount} owed you''re no longer eligible for games and practices, and your page says so.\n\nPay here and you''re eligible again[[ — at least {min_payment} gets you under the line]]: {form:la_dashboard}\n[[Your next month posts {deadline}, so you''ll need to be under {pause_amount} after that too. ]]Even {partial_amounts} keeps you in the habit; silence, and we''ll assume you''ve moved on.\n\nThanks,\nTreasurer, Lighthouse 1893'
 WHERE kind = 'payment_notice_email' AND tier = 'behind_3' AND is_active;

UPDATE message_templates SET updated_at = now(), label = 'Payment text — under a month owed (gentle)', body =
  'Hi {first}, you''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard}[[ Next month posts {deadline}.]] At {pause_amount} owed you''re no longer eligible for games and practices[[ — for you that would be {pause_date}]]. Even {partial_amounts} shows us you''re still active.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_1' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment text — 1 full month behind (firm)', body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard}[[ At {pause_amount} owed you''re no longer eligible for games and practices. Next month posts {deadline}, which puts you there — pay at least {keep_active_amount} before then and you stay eligible.]] Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_2' AND is_active;
UPDATE message_templates SET updated_at = now(), label = 'Payment text — at/over the line (not eligible)', body =
  'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. At {pause_amount} owed you''re no longer eligible for games and practices, and your page says so. Pay here and you''re eligible again[[ — at least {min_payment} gets you under the line]]: {form:la_dashboard}[[ Next month posts {deadline}, so you''ll need to be under {pause_amount} after that too.]] Even {partial_amounts} keeps you in the habit; silence, and we''ll assume you''ve moved on.'
 WHERE kind = 'payment_notice_sms' AND tier = 'behind_3' AND is_active;

-- ── #my, RSVP refusal, Game Center flag ───────────────────────────────
-- Tokens: {amount} balance, {min_payment}, {pause_amount}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My — dues banner (not eligible)', 'my_dues', 'banner', NULL,
       'Dues {amount} owed — not eligible for games and practices. Pay at least {min_payment} to be eligible again.', 1, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'banner');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My — dues banner button', 'my_dues', 'banner_button', NULL, 'Pay here', 2, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'banner_button');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My — event pill (not eligible, replaces RSVP)', 'my_dues', 'pill', NULL,
       'Pay at least {min_payment} here to be eligible again', 3, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'pill');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Game Center — player flag (not eligible, dues)', 'my_dues', 'lineup_flag', NULL,
       'Not eligible — dues', 4, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'lineup_flag');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'RSVP refused — not eligible on dues (server)', 'my_dues', 'rsvp_refused', NULL,
       'Not eligible for games and practices — pay at least {min_payment} to be eligible again.', 5, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'rsvp_refused');
