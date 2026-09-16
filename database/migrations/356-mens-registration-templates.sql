-- 356 — Men's league registration nudges move out of mens-roster.js and
-- into message_templates.
--
-- Owner 2026-09-16: "we need to change the liga 1 and apsl reg links to
-- say friday 3pm is deadline … actually we should say we need to submit
-- by Friday so players need to submit right away so we can check its
-- correct and notify league and have time in case its rejected" and then
-- "this should be in db not hard coded."
--
-- Until now MensRosterScreen.REGISTRATION_PRESETS held the subject/body
-- for the 📋 Liga1/APSL Reg and 📋 APSL Reg SMS/EMAIL buttons on every
-- Mens card, so every deadline change was a frontend deploy.  These two
-- rows are the same copy as DB data: kind='registration' marks them as
-- per-card nudges (the Messages screen lists every active template, so
-- 'registration' is also how it can tell them apart from broadcast copy),
-- label is the button text, subject/body are what the compose link is
-- pre-filled with, sort_order is button order.  Body is one paragraph —
-- sms: and Gmail-compose hrefs carry it verbatim.
--
-- GET /api/messages/templates?category=Men's Club&kind=registration
-- (kind filter added alongside this migration) is what the board reads.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
VALUES
(
    'Men''s Club',
    'Liga1/APSL Reg',
    'registration',
    'card',
    'IMPORTANT!!! Liga 1 & APSL Registration — submit RIGHT AWAY (club deadline to league is Friday 3:00 PM)',
    'IMPORTANT!!! The club must submit your registration to the league by FRIDAY 3:00 PM or you CANNOT play this Sunday and will have to wait until next week. '
    'Please fill this out RIGHT AWAY — we need time to check it is correct, notify the league, and fix and resubmit it if the league rejects it. Do not wait until Friday. '
    'To be eligible for Liga 1 & APSL games this needs to be filled out — it captures the information needed for the APSL roster too. '
    'Make sure head shot is just head and no hat or sunglasses and facing forward: '
    'https://casasoccerleagues.sportngin.com/register/form/229198682',
    0
),
(
    'Men''s Club',
    'APSL Reg',
    'registration',
    'card',
    'IMPORTANT!!! APSL Registration — submit RIGHT AWAY (club deadline to league is Friday 3:00 PM)',
    'IMPORTANT!!! The club must submit your registration to the league by FRIDAY 3:00 PM or you CANNOT play this Sunday and will have to wait until next week. '
    'Please fill this out RIGHT AWAY — we need time to check it is correct, notify the league, and fix and resubmit it if the league rejects it. Do not wait until Friday. '
    'To be eligible for APSL games this needs to be filled out. '
    'Make sure head shot is just head and no hat or sunglasses and facing forward: '
    'https://forms.gle/fki5wPqJk1x2fT9D7',
    1
);

-- Guard: exactly the two Mens registration buttons, in order, each
-- carrying its form link.  The controller matches category the same
-- way (alnum-only, lowercased), so the guard does too.
DO $$
DECLARE n INT; missing TEXT;
BEGIN
    SELECT count(*) INTO n
      FROM message_templates
     WHERE kind = 'registration' AND is_active
       AND lower(regexp_replace(category, '[^[:alnum:]]+', '', 'g')) = 'mensclub';
    IF n <> 2 THEN
        RAISE EXCEPTION 'expected 2 active Mens registration templates, found %', n;
    END IF;
    SELECT string_agg(label, ', ') INTO missing
      FROM message_templates
     WHERE kind = 'registration' AND is_active
       AND (body NOT LIKE '%https://%' OR subject IS NULL OR subject = '');
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'registration template without a link or subject: %', missing;
    END IF;
END $$;

COMMIT;
