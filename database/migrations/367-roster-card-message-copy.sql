-- 367 — Roster-card and member-card messages, moved into the DB (pass 2).
--
-- Owner 2026-09-17: "we need all messages in db no hard code not even for
-- nudges".  Migration 366 covered what the backend writes; these are the
-- messages the BROWSER drafts when an admin/coach taps a button on a card:
--
--   dues_sms / dues_email            💸 PAY on the Boys/Girls/Men's boards and
--                                    #youth-roster
--   payment_notice_email / _sms      #payments  Reminder · Firm · Final
--   contact_email / contact_sms      CONTACT popover openers
--   fh_invite_email / fh_invite_sms  Men's INVITE (sign in with Google)
--   onboarding                       #members 📣 Onboarding
--   womens_register                  Women's REGISTER (TeamSnap)
--   bulk_subject                     default subject of the bulk composer
--
-- They are served to signed-in staff by GET /api/messages/templates/copy
-- and filled by frontend/js/lib/message-copy.js, which implements the same
-- syntax as the backend MessageCopy model (migration 366): {token},
-- [[optional section]], kind='fallback' words, and {form:<code>} links
-- (resolved server-side before the copy leaves the backend).
--
-- What changed in the wording, on purpose:
--   • "July dues" → "{month} dues" (the literal month had gone stale).
--   • The "starting Aug 7 LeagueApps will auto-charge…" heads-up is kept
--     as its own row (dues_note / autocharge_headsup) but INACTIVE — the
--     date has passed.  (Dropped entirely by migration 368.)
--   • Men's copy no longer promises "pickups" (owner: men are all
--     practice now).

-- Which rows the browser may load.  Backend-only copy (password reset,
-- push payloads, magic links) stays false.
ALTER TABLE message_templates ADD COLUMN IF NOT EXISTS client_side boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN message_templates.client_side IS
  'true = served to signed-in staff by GET /api/messages/templates/copy and rendered in the browser (frontend/js/lib/message-copy.js). Migration 367.';

UPDATE message_templates SET client_side = true
 WHERE kind IN ('fallback', 'sms_link_hint') AND NOT client_side;

-- Links these messages point at.
INSERT INTO club_forms (club_id, code, label, url) VALUES
  (134, 'la_dashboard',               'LeagueApps member dashboard (pay dues / update card)',
        'https://lighthouse1893.leagueapps.com/dashboard'),
  (134, 'womens_league_registration', 'Women''s league registration + dues (TeamSnap)',
        'https://registration.teamsnap.com/form/71486')
ON CONFLICT (club_id, code) DO NOTHING;

CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text,
                                                  p_subject text, p_body text, p_sort int,
                                                  p_active boolean DEFAULT true)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort, p_active, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- ── 💸 PAY — dues ───────────────────────────────────────────────────────
-- Tokens: {first} recipient, {child}, {amount} "$35", {month} "September",
-- {reg_date} "Sep 3", {days_remain}, {cycle_days}, {note} (the dues_note
-- block below, empty while it is inactive).
SELECT pg_temp.add_client_tpl('dues_sms', 'parent', 'Dues text — parent', NULL,
  'Hi[[ {first}]], gentle reminder from Lighthouse 1893 — {child}''s {month} dues ({amount}) are still outstanding on LeagueApps. When you get a moment please log in and pay, and while you''re in there please make sure a valid card is saved on file: {form:la_dashboard}.[[ {note}]] Thanks so much!',
  200);
SELECT pg_temp.add_client_tpl('dues_sms', 'parent_prorate', 'Dues text — parent, prorated first month', NULL,
  'Hi[[ {first}]], welcome to Lighthouse 1893! Since {child}''s registration came in on {reg_date} (mid-cycle), {month} dues are prorated for the {days_remain} of {cycle_days} days remaining — {amount} for {month}. Gentle reminder to log in and pay {amount} on LeagueApps when you get a moment: {form:la_dashboard}.[[ {note}]] Thanks so much!',
  201);
SELECT pg_temp.add_client_tpl('dues_email', 'parent', 'Dues email — parent',
  'Lighthouse 1893 — quick note about {child}''s dues',
  E'Hi[[ {first}]],\n\nGentle reminder from Lighthouse 1893 — {child}''s {month} dues ({amount}) are still outstanding on LeagueApps.\n\nWhen you get a moment please log in and pay, and while you''re in there please make sure a valid card is saved on file:\n{form:la_dashboard}\n\n[[{note}\n\n]]Thanks so much,\nLighthouse 1893',
  202);
SELECT pg_temp.add_client_tpl('dues_email', 'parent_prorate', 'Dues email — parent, prorated first month',
  'Lighthouse 1893 — quick note about {child}''s dues',
  E'Hi[[ {first}]],\n\nWelcome to Lighthouse 1893! Since {child}''s registration came in on {reg_date} (mid-cycle), {month} dues are prorated for the {days_remain} of {cycle_days} days remaining in the cycle.\n\nBalance for {month}:  {amount}.\n\nGentle reminder to log in and pay {amount} on LeagueApps when you get a moment:\n{form:la_dashboard}\n\n[[{note}\n\n]]Thanks so much,\nLighthouse 1893',
  203);
SELECT pg_temp.add_client_tpl('dues_sms', 'adult', 'Dues text — player (card didn''t clear)', NULL,
  'Hi[[ {first}]], gentle reminder from Lighthouse 1893 — your {month} dues ({amount}) didn''t clear on the card on file. Usually just an expired or declined card. When you get a moment, please log in and pay or update your card: {form:la_dashboard}. Thanks!',
  204);
SELECT pg_temp.add_client_tpl('dues_sms', 'adult_prorate', 'Dues text — player, prorated first month', NULL,
  'Hi[[ {first}]], welcome to Lighthouse 1893! Since you registered on {reg_date} (mid-cycle), your {month} dues are prorated for the {days_remain} of {cycle_days} days remaining — {amount} for {month}. Looks like the card on file didn''t clear — usually just an expired or declined card. Gentle reminder to log in and pay {amount} or update your card on file when you get a moment: {form:la_dashboard}. Thanks!',
  205);
SELECT pg_temp.add_client_tpl('dues_sms', 'parent_past_due', 'Dues text — parent, past due (#youth-roster)', NULL,
  'Hi[[ {first}]], gentle reminder — {child}''s dues ({amount}) are showing as past due on LeagueApps. To cut down on admin work it really helps if there''s a valid card on file so LeagueApps can auto-charge each month. LeagueApps has emailed you a pay link, or log in and pay / update your card here: {form:la_dashboard} Thanks so much!',
  206);
SELECT pg_temp.add_client_tpl('dues_note', 'autocharge_headsup', 'Dues — auto-charge heads-up (inactive: the Aug 7 date has passed)', NULL,
  'Heads-up: starting Aug 7 LeagueApps will auto-charge the $35 monthly dues to the card on file. Right now as a courtesy we''re asking parents to pay manually so the charge doesn''t come as a surprise.',
  207, false);
SELECT pg_temp.add_client_tpl('fallback', 'amount', 'Fallback — dues amount unknown', NULL, 'monthly dues', 107);

-- ── #payments — Reminder · Firm · Final ────────────────────────────────
-- Tokens: {first}, {club} LA programme name, {link} = {form:la_dashboard},
-- {owed} "July and August", {deadline} "Friday, October 2", {next_month},
-- {months_behind}.  'firm_dated' is used when the dates are known.
SELECT pg_temp.add_client_tpl('payment_notice_email', 'reminder', 'Payment email — reminder',
  '{club} — payment reminder',
  E'Hi {first},\n\nPlease make your payment as soon as possible. You can pay here: {form:la_dashboard}\n\nThanks,\nTreasurer, Lighthouse 1893', 210);
SELECT pg_temp.add_client_tpl('payment_notice_email', 'firm_dated', 'Payment email — firm, with dates',
  '{club} — overdue payment',
  E'Hi {first},\n\nYou still owe dues for {owed}. Starting {deadline}, {next_month} will also come due — at that point you''ll be {months_behind} months behind, and per club policy your membership will be paused until dues are paid in full.\n\nPlease make your payment before {deadline} using this link: {form:la_dashboard}\n\nThanks,\nTreasurer, Lighthouse 1893', 211);
SELECT pg_temp.add_client_tpl('payment_notice_email', 'firm', 'Payment email — firm',
  '{club} — overdue payment',
  E'Hi {first},\n\nYour membership payment is still outstanding. Please make your payment by the end of today using this link: {form:la_dashboard}\n\nIf payment is not received soon, your membership may be paused and your spot may be released.\n\nThanks,\nTreasurer, Lighthouse 1893', 212);
SELECT pg_temp.add_client_tpl('payment_notice_email', 'final', 'Payment email — final (membership paused)',
  '{club} — membership paused',
  E'Hi {first},\n\nYour membership has been paused due to unpaid dues. Your spot is on hold until payment is received in full.\n\nTo reactivate, please make your payment using this link: {form:la_dashboard}\n\nThanks,\nTreasurer, Lighthouse 1893', 213);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'reminder', 'Payment text — reminder', NULL,
  'Hi {first}, please make your payment as soon as possible. You can pay here: {form:la_dashboard}', 214);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'firm_dated', 'Payment text — firm, with dates', NULL,
  'Hi {first}, you owe dues for {owed}. Starting {deadline} you''ll be {months_behind} months behind and your membership will be paused per club policy. Please pay before then: {form:la_dashboard}', 215);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'firm', 'Payment text — firm', NULL,
  'Hi {first}, your membership payment is still outstanding. Please make your payment by the end of today here: {form:la_dashboard}', 216);
SELECT pg_temp.add_client_tpl('payment_notice_sms', 'final', 'Payment text — final (membership paused)', NULL,
  'Hi {first}, your membership has been paused due to unpaid dues. To reactivate, please pay in full here: {form:la_dashboard}', 217);
SELECT pg_temp.add_client_tpl('fallback', 'club', 'Fallback — member has no programme name', NULL, 'Lighthouse 1893', 108);

-- ── CONTACT openers ────────────────────────────────────────────────────
-- The admin types the rest; this is only the greeting line.
SELECT pg_temp.add_client_tpl('contact_email', 'parent', 'Contact email opener — parent (Boys/Girls)',
  'Lighthouse 1893[[ — {child}]]', E'Hi {first},\n\nThis is Lighthouse 1893[[ regarding {child}]].\n\n', 220);
SELECT pg_temp.add_client_tpl('contact_sms', 'parent', 'Contact text opener — parent (Boys/Girls)', NULL,
  'Hi[[ {first}]], this is Lighthouse 1893[[ regarding {child}]].', 221);
SELECT pg_temp.add_client_tpl('contact_email', 'adult', 'Contact email opener — player (Men''s)',
  'Lighthouse 1893 Men''s', E'Hi[[ {first}]],\n\nThis is your Lighthouse 1893 coach.\n\n', 222);
SELECT pg_temp.add_client_tpl('contact_sms', 'adult', 'Contact text opener — player (Men''s)', NULL,
  'Hi[[ {first}]], this is Lighthouse 1893 coach.', 223);
SELECT pg_temp.add_client_tpl('contact_email', 'parent_coach', 'Contact email opener — parent (#youth-roster)',
  'Lighthouse 1893 — about {child}', E'Hi[[ {first}]],\n\nThis is your Lighthouse 1893 coach reaching out about {child}.\n\n', 224);
SELECT pg_temp.add_client_tpl('contact_sms', 'parent_coach', 'Contact text opener — parent (#youth-roster)', NULL,
  'Hi[[ {first}]], this is Lighthouse 1893 coach about {child}.', 225);

-- ── Men's INVITE ───────────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('fh_invite_email', 'adult', 'Football Home invite email — player',
  'Football Home — Lighthouse 1893 weekly RSVPs',
  E'Hi {first},\n\nLighthouse 1893 posts each week''s schedule at https://footballhome.org so we have a clearer picture of who''s coming.\n\nHead to https://footballhome.org and sign in with the same Google account you use for LeagueApps (or set a password on the sign-in page). From your home screen you''ll see this week''s practices and games and can RSVP YES / NO to all of them in one tap.\n\nYou can also set default availability by day-of-week + event type so the page auto-fills going forward.\n\n— Lighthouse Soccer', 230);
SELECT pg_temp.add_client_tpl('fh_invite_sms', 'adult', 'Football Home invite text — player', NULL,
  'Hey {first} — Lighthouse 1893 is using https://footballhome.org for weekly RSVPs. Log in with the Google account you use for LeagueApps (or set a password) to see this week''s practices and games and RSVP YES / NO to all of them. Thanks!', 231);

-- ── #members 📣 Onboarding (same text for email and SMS) ───────────────
SELECT pg_temp.add_client_tpl('onboarding', 'no_account', 'Onboarding — has not signed in yet',
  'Welcome to the club — join us on FootballHome',
  E'Hey {first},\n\nWelcome to the club! This is where practices and games are listed: FootballHome.\n\nPlease go to https://footballhome.org and tap "Sign in with Google" (5 seconds, uses your Gmail), then set your availability accurately for the week.\n\nPlease reply and let me know you got this so I know I have the right contact info for you.\n\n--James Breslin Soccer Director at Lighthouse', 240);
SELECT pg_temp.add_client_tpl('onboarding', 'has_account', 'Onboarding — has an account, first visit',
  'Welcome to the club — set your availability on FootballHome',
  E'Hey {first},\n\nWelcome to the club! This is where practices and games are listed: FootballHome.\n\nYou''re already set up — please log in at https://footballhome.org and set your availability accurately for the week.\n\nPlease reply and let me know you got this so I know I have the right contact info for you.\n\n--James Breslin Soccer Director at Lighthouse', 241);

-- ── Women's REGISTER ───────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('womens_register', 'adult', 'Women''s league registration ask',
  'Lighthouse 1893 Women''s — register for the league and pay dues',
  E'Hi[[ {first}]] — to get on the Lighthouse 1893 women''s roster this season, please register for the league and pay dues on TeamSnap here:\n\n{form:womens_league_registration}\n\nOnce that''s done we''ll put you on the official roster. Thanks!\n\n— Lighthouse Soccer', 250);

-- ── Bulk composer ──────────────────────────────────────────────────────
SELECT pg_temp.add_client_tpl('bulk_subject', 'default', 'Bulk composer — default email subject',
  'Lighthouse 1893 — {scope}', '-', 260);
