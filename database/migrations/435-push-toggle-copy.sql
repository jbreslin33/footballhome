-- ─────────────────────────────────────────────────────────────────────
-- 435-push-toggle-copy.sql (2026-09-25)
--
-- Owner: "thin toggle that says next to it 'Game & Practice Reminders
-- On' or '...Off' depending on toggle" — replacing the push opt-in
-- banner on #my / #calendar (PushOptIn.js).  The wording is here, read
-- by the page through /api/messages/templates/copy (client_side rows).
--
-- What a push actually is today: a coach's RSVP reminder for a game or
-- practice, and chat posts.  Subscriptions are per device/browser.
-- ─────────────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'push_toggle', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('on',        'Push toggle — reminders on (this device)',            'Game & Practice Reminders On',  710),
    ('off',       'Push toggle — reminders off (this device)',           'Game & Practice Reminders Off', 711),
    ('busy',      'Push toggle — while turning on/off',                  'Game & Practice Reminders …',   712),
    ('blocked',   'Push toggle — browser has notifications blocked',     'Reminders blocked — allow notifications for footballhome.org in your browser settings', 713),
    ('ios',       'Push toggle — iPhone Safari, not yet on Home Screen', 'Game & Practice Reminders Off — add to Home Screen first', 714),
    ('ios_howto', 'Push toggle — iPhone how-to',                         'In Safari tap Share (the box with the arrow) → Add to Home Screen, open Football Home from there, then flip this on.', 715),
    ('hint',      'Push toggle — what you get, shown once on',           'On this device: a ping when a coach sends you an RSVP reminder for a game or practice, and for chat posts.', 716)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'push_toggle' AND m.tier = v.t);
