-- 381 — Game Center: remind the game's No Response players about their
-- whole week, not just the game.
--
-- Owner 2026-09-19: "on game center for the no responses … a group
-- text/email and individual buttons on the player cards for reminders for
-- 'all' rsvps so it catches the practice missing too."
--
-- The individual buttons reuse the personal reminder (kind=rsvp_reminder
-- tier adult|parent, magic link, every unanswered event of the week).
-- The group message goes to everybody who has not answered the game and
-- lists every still-open event of the week any of them owes an answer to
-- — so nobody's list is wrong, it says "any of these".  No magic link in
-- a group message.  Tokens: {events} bulleted event lines, {sender}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — group, whole week, adults', 'rsvp_reminder', 'group_week_adult',
       'Lighthouse 1893 — please set your availability',
       E'Hi all — you''re getting this because your availability isn''t set for the game yet. Please answer every one of these you haven''t already:\n'
       '{events}\n\n'
       'Answer at https://footballhome.org — Going or Not Going, it takes ten seconds.\n\n'
       'Not sure yet? Set Not Going — you can change it any time. Setting availability for every event is a team rule.\n\n'
       '— {sender}, Lighthouse 1893',
       15
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'group_week_adult');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — group, whole week, parents', 'rsvp_reminder', 'group_week_parent',
       'Lighthouse 1893 — please set your player''s availability',
       E'Hi all — you''re getting this because your player''s availability isn''t set for the game yet. Please answer every one of these you haven''t already:\n'
       '{events}\n\n'
       'Answer at https://footballhome.org — Going or Not Going, it takes ten seconds.\n\n'
       'Not sure yet? Set Not Going — you can change it any time. It lets the coaches plan the session.\n\n'
       '— {sender}, Lighthouse 1893',
       16
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'group_week_parent');
