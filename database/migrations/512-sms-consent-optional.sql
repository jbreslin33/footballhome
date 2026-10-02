-- 512 (2026-10-02) — footballhome.org/sms: the text-message box is optional.
--
-- Twilio rejected the A2P campaign a third time (error 30923, on the
-- message flow): "consent cannot be a required condition for service or
-- transaction completion".  The /sms form (mig 482) had a name, a mobile
-- number and a consent box, and would not submit until the box was ticked
-- — to a reviewer, consent as the condition of completing the form.
--
-- The page is now a club-updates sign-up: name and email, with the mobile
-- number and the un-ticked text-message box both optional.  It submits
-- either way; texts go only to someone who ticked the box.
--
--   club_update_signups   every submission: who, their email, and whether
--                         they also asked for texts
--   sms_opt_ins           unchanged in meaning — a row only when the box
--                         was ticked, with the wording they agreed to;
--                         club_update_signups.sms_opt_in_id points at it

CREATE TABLE IF NOT EXISTS club_update_signups (
    id            SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    email         TEXT NOT NULL,
    phone         TEXT,                      -- as typed, when given
    sms_opt_in_id INTEGER REFERENCES sms_opt_ins(id) ON DELETE SET NULL,   -- NULL = no texts asked for
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip            TEXT,
    user_agent    TEXT,
    source        TEXT NOT NULL DEFAULT 'web:/sms',
    person_id     INTEGER REFERENCES persons(id) ON DELETE SET NULL        -- matched by email
);
CREATE INDEX IF NOT EXISTS club_update_signups_created_idx ON club_update_signups (created_at DESC);
COMMENT ON TABLE club_update_signups IS
  'Sign-ups from footballhome.org/sms (mig 512): name + email for club updates. sms_opt_in_id is set only when the person also ticked the optional text-message box — the consent itself is the sms_opt_ins row.';

-- ── Page copy (kind legal_sms, rendered by sms.html) ─────────────────
CREATE OR REPLACE FUNCTION pg_temp.set_sms_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, updated_at = now()
   WHERE kind = 'legal_sms' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('System', p_label, 'legal_sms', p_tier, NULL, p_body, p_sort, true, false, true);
  END IF;
END $$;

SELECT pg_temp.set_sms_tpl('all', 'Club sign-up page — body (footballhome.org/sms)',
'### Stay in touch with Lighthouse 1893
Leave your name and email below to hear from Lighthouse 1893 Soccer Club: club news, tryouts and schedule changes, through Football Home, the club app.

### Text alerts are optional
You can also choose to get club text messages. Tick the box in the form and add your mobile number, or text START to (215) 769-9197. You can sign up without it: the form works with the box left un-ticked, and then we never text you.

### What the texts are
- Game and practice reminders and schedule changes for your team or your child''s team.
- Roster and dues notices.
- For club staff: alerts such as a facility not being confirmed locked after the last practice.

### The details
- **Message frequency:** varies with the season, usually a few messages a week and more around game days.
- **Message and data rates may apply.**
- Reply **STOP** to any message to stop. Reply **HELP** for help, or email soccer@lighthouse1893.org.
- Agreeing to text messages is optional. It is not a condition of signing up here, of club membership or registration, or of any purchase.
- Your mobile number and consent are never shared with third parties or affiliates for marketing or promotional purposes.', 1);
SELECT pg_temp.set_sms_tpl('form_title',  'Club sign-up page — form heading', 'Sign up for club updates', 2);
SELECT pg_temp.set_sms_tpl('name_label',  'Club sign-up page — name field label', 'Your name', 3);
SELECT pg_temp.set_sms_tpl('email_label', 'Club sign-up page — email field label', 'Email', 4);
SELECT pg_temp.set_sms_tpl('phone_label', 'Club sign-up page — mobile field label', 'Mobile number (optional — only for text alerts)', 5);
SELECT pg_temp.set_sms_tpl('consent', 'Club sign-up page — optional text-message box (un-ticked by default)',
'Optional: I agree to receive text messages from Football Home (Lighthouse 1893 Soccer Club) at the mobile number above: game and practice reminders, schedule changes, roster and dues notices, and club staff alerts. Message frequency varies. Message and data rates may apply. Reply STOP to cancel, HELP for help. Consent is not a condition of signing up, membership or purchase. See our Privacy policy and Terms and conditions.', 6);
SELECT pg_temp.set_sms_tpl('button',     'Club sign-up page — submit button', 'Sign up', 7);
SELECT pg_temp.set_sms_tpl('need_email', 'Club sign-up page — email missing or not an address', 'Enter your email address.', 8);
SELECT pg_temp.set_sms_tpl('need_phone', 'Club sign-up page — text box ticked without a 10-digit mobile number',
  'To get text alerts, enter a 10-digit US mobile number — or un-tick the box to sign up without texts.', 9);
SELECT pg_temp.set_sms_tpl('thanks', 'Club sign-up page — signed up, texts too',
  'Thanks, {name} — you are signed up for club updates at {email} and for Football Home text alerts at {phone}. Reply STOP to any message to stop the texts.', 10);
SELECT pg_temp.set_sms_tpl('thanks_email', 'Club sign-up page — signed up, no texts',
  'Thanks, {name} — you are signed up for club updates at {email}. You did not ask for text alerts, so we will not text you.', 11);
SELECT pg_temp.set_sms_tpl('error', 'Club sign-up page — server error',
  'Something went wrong. Please try again, or email soccer@lighthouse1893.org.', 12);

-- The box no longer has to be ticked, so its nag goes.
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'legal_sms' AND tier = 'need_consent' AND is_active;

-- Terms: how you opt in.
UPDATE message_templates
   SET body = replace(body,
       '- **How you opt in:** sign up at footballhome.org/sms, where you enter your mobile number and tick the consent box, or text START to (215) 769-9197. Club staff opt in the same way. Consent is not a condition of membership or purchase.',
       '- **How you opt in:** on the club sign-up form at footballhome.org/sms, tick the optional text-message box and enter your mobile number, or text START to (215) 769-9197. The form can be sent without ticking the box, and then no texts are sent. Club staff opt in the same way. Consent is optional and is not a condition of signing up, membership or purchase.'),
       updated_at = now()
 WHERE kind = 'legal_terms' AND tier = 'all';
