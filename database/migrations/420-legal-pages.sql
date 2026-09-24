-- 420 — Privacy policy + terms pages (footballhome.org/privacy, /terms).
--
-- Owner 2026-09-24: the Twilio A2P 10DLC campaign (the last step before
-- Football Home can text anyone, starting with the "Lighthouse not
-- confirmed locked" alert) requires a public privacy policy URL and a
-- terms URL that name the program, say message/data rates may apply,
-- give the message frequency and a support contact, and show HELP and
-- STOP in bold.  Neither page existed (both URLs fell through to the
-- SPA), which is what stalled the registration in 2025.
--
-- No wording in the frontend (owner: "all messages in db").  These rows
-- are served by GET /api/public/program-copy (is_public) and rendered by
-- frontend/legal.html through LighthouseProgramInfo.buildPublicPage().
-- Same ### / - / **bold** markup as the programme rows (migration 370).
-- Change the wording by migration.
CREATE OR REPLACE FUNCTION pg_temp.add_legal_tpl(p_kind text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
  SELECT 'System', p_label, p_kind, 'all', NULL, p_body, p_sort, true, false, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = 'all');
$$;

SELECT pg_temp.add_legal_tpl('legal_privacy', 'Legal — privacy policy (footballhome.org/privacy)',
E'### Privacy policy\nFootball Home is the club app of Lighthouse 1893 Soccer Club in Philadelphia. This page says what we collect from members who use it and what we do with it.\n\n### What we collect\n- Your name, email address and mobile number, entered by you or your parent when you register with the club.\n- Your team, schedule RSVPs, attendance and dues status, so the club can run its programs.\n- If you turn on notifications, the browser''s push subscription so we can reach you.\n\n### How we use it\n- To run the club: schedules, game and practice reminders, roster and dues notices.\n- To send the text messages you have agreed to receive, such as reminders and alerts for club staff.\n\n### What we do not do\n- We do not sell or rent your information.\n- No mobile information will be shared with third parties or affiliates for marketing or promotional purposes.\n- Text-message opt-in data and consent are never shared with any third party. They are used only to send you the club messages you asked for.\n\n### Text messages\n- Message frequency varies with the season. Expect a few messages a week at most.\n- Message and data rates may apply.\n- Reply **STOP** to stop receiving texts. Reply **HELP** for help.\n\n### Your choices\nAsk us to correct or delete your information, or to stop texting you, at soccer@lighthouse1893.org.',
500);

SELECT pg_temp.add_legal_tpl('legal_terms', 'Legal — terms and conditions (footballhome.org/terms)',
E'### Terms and conditions\nFootball Home is run by Lighthouse 1893 Soccer Club for its members and their families. Using the app or receiving its messages means you accept these terms.\n\n### The Football Home text-message program\n- **Program name:** Football Home club alerts, from Lighthouse 1893 Soccer Club.\n- **What we send:** game and practice reminders, schedule changes, roster and dues notices, and alerts for club staff, for example that a facility has not been confirmed locked.\n- **How you opt in:** you give your mobile number and agree to text messages when you register with the club, or a club admin adds you at your request. You can also text START to (215) 769-9197.\n- **Message frequency:** varies with the season, usually a few messages a week and more around game days.\n- **Message and data rates may apply.**\n- **To stop:** reply **STOP** to any message. You will get one final confirmation and no further texts.\n- **For help:** reply **HELP** to any message, or email soccer@lighthouse1893.org.\n- Carriers are not liable for delayed or undelivered messages.\n\n### Your account\n- Keep your login private and tell us if you think someone else has used it.\n- Information you enter must be your own, or that of a child you are the parent or guardian of.\n\n### Changes\nWe may update these terms. The current version is always at footballhome.org/terms.\n\nContact: Lighthouse 1893 Soccer Club, soccer@lighthouse1893.org.',
501);

DROP FUNCTION pg_temp.add_legal_tpl(text, text, text, int);
