-- 482 (2026-09-28) — A public text-alert sign-up page, footballhome.org/sms.
-- Twilio rejected the A2P 10DLC campaign again on 2026-09-24 (error 30909:
-- "issues verifying the Call to Action").  The message flow said people
-- opt in "on the registration form", which the reviewer cannot see (it is
-- LeagueApps, behind an account).  Carriers want a consent form they can
-- open: brand name, message types, frequency, rates, STOP/HELP, privacy
-- and terms links, and an un-ticked consent box.  /sms is that page; the
-- campaign's message flow now points at it.  Each sign-up is kept here as
-- proof of consent, with the exact consent wording the person ticked.
CREATE TABLE IF NOT EXISTS sms_opt_ins (
    id            SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    phone         TEXT NOT NULL,             -- as typed
    phone_digits  TEXT NOT NULL,             -- digits only, for matching
    consent_text  TEXT NOT NULL,             -- the checkbox wording at the time
    consented_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip            TEXT,
    user_agent    TEXT,
    source        TEXT NOT NULL DEFAULT 'web:/sms',
    person_id     INTEGER REFERENCES persons(id) ON DELETE SET NULL   -- matched later, by phone
);
CREATE INDEX IF NOT EXISTS sms_opt_ins_phone_idx ON sms_opt_ins (phone_digits, consented_at DESC);
COMMENT ON TABLE sms_opt_ins IS 'Text-alert consents from footballhome.org/sms (mig 482): proof of opt-in for the Twilio A2P campaign.';

-- Page copy: served by GET /api/public/program-copy (is_public), rendered by sms.html.
CREATE OR REPLACE FUNCTION pg_temp.add_sms_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
  SELECT 'System', p_label, 'legal_sms', p_tier, NULL, p_body, p_sort, true, false, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'legal_sms' AND tier = p_tier);
$$;
SELECT pg_temp.add_sms_tpl('all', 'SMS sign-up page — body (footballhome.org/sms)',
'### Football Home text alerts
Lighthouse 1893 Soccer Club sends its club text messages through Football Home, the club app. Sign up below to receive them, or text START to (215) 769-9197.

### What you will receive
- Game and practice reminders and schedule changes for your team or your child''s team.
- Roster and dues notices.
- For club staff: alerts such as a facility not being confirmed locked after the last practice.

### The details
- **Message frequency:** varies with the season, usually a few messages a week and more around game days.
- **Message and data rates may apply.**
- Reply **STOP** to any message to stop. Reply **HELP** for help, or email soccer@lighthouse1893.org.
- Consent is not a condition of membership or of any purchase.
- Your mobile number and consent are never shared with third parties or affiliates for marketing or promotional purposes.', 1);
SELECT pg_temp.add_sms_tpl('form_title', 'SMS sign-up page — form heading', 'Sign up for text alerts', 2);
SELECT pg_temp.add_sms_tpl('name_label', 'SMS sign-up page — name field label', 'Your name', 3);
SELECT pg_temp.add_sms_tpl('phone_label', 'SMS sign-up page — mobile field label', 'Mobile number', 4);
SELECT pg_temp.add_sms_tpl('consent', 'SMS sign-up page — consent checkbox (un-ticked by default)',
'I agree to receive text messages from Football Home (Lighthouse 1893 Soccer Club) at the mobile number above: game and practice reminders, schedule changes, roster and dues notices, and club staff alerts. Message frequency varies. Message and data rates may apply. Reply STOP to cancel, HELP for help. Consent is not a condition of membership or purchase. See our Privacy policy and Terms and conditions.', 5);
SELECT pg_temp.add_sms_tpl('button', 'SMS sign-up page — submit button', 'Sign me up', 6);
SELECT pg_temp.add_sms_tpl('need_consent', 'SMS sign-up page — consent box not ticked', 'Please tick the box to agree to text messages.', 7);
SELECT pg_temp.add_sms_tpl('need_phone', 'SMS sign-up page — mobile number missing or not 10 digits', 'Enter a 10-digit US mobile number.', 8);
SELECT pg_temp.add_sms_tpl('thanks', 'SMS sign-up page — after a successful sign-up', 'Thanks, {name} — you are signed up for Football Home text alerts at {phone}. Reply STOP to any message to stop.', 9);
SELECT pg_temp.add_sms_tpl('error', 'SMS sign-up page — server error', 'Something went wrong. Please try again, or text START to (215) 769-9197.', 10);

-- The terms page now names the sign-up page as the way in.
UPDATE message_templates
   SET body = replace(body,
       '- **How you opt in:** you give your mobile number and agree to text messages when you register with the club, or a club admin adds you at your request. You can also text START to (215) 769-9197.',
       '- **How you opt in:** sign up at footballhome.org/sms, where you enter your mobile number and tick the consent box, or text START to (215) 769-9197. Club staff opt in the same way. Consent is not a condition of membership or purchase.')
 WHERE kind = 'legal_terms' AND tier = 'all';
