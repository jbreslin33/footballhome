-- 380 — RSVP board: one reminder to everybody who has not answered an event.
--
-- #rsvps reminds one player at a time, each message carrying that
-- player's magic link.  With an event picked in the "Unanswered for:"
-- filter (or a next-game tile tapped) the board now also offers ONE group
-- text / BCC email to everyone still owing an answer for that event.
--
-- A group message never carries a magic link (a token is one person's
-- sign-in), so the copy points at footballhome.org instead.  Tokens:
-- {event} the event line ("Sun Sep 20, 3:00 PM — Game vs Oaklyn"),
-- {sender} the admin's first name.  tier group_adult = Men / Women,
-- group_parent = Boys / Girls (the recipients are the parents).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — group, adults', 'rsvp_reminder', 'group_adult',
       'Lighthouse 1893 — please set your availability',
       E'Hi all — you''re getting this because your availability isn''t set yet for:\n'
       '• {event}\n\n'
       'Please answer at https://footballhome.org — Going or Not Going, it takes ten seconds.\n\n'
       'Not sure yet? Set Not Going — you can change it any time. Setting availability for every event is a team rule.\n\n'
       '— {sender}, Lighthouse 1893',
       13
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'group_adult');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — group, parents', 'rsvp_reminder', 'group_parent',
       'Lighthouse 1893 — please set your player''s availability',
       E'Hi all — you''re getting this because your player''s availability isn''t set yet for:\n'
       '• {event}\n\n'
       'Please answer at https://footballhome.org — Going or Not Going, it takes ten seconds.\n\n'
       'Not sure yet? Set Not Going — you can change it any time. It lets the coaches plan the session.\n\n'
       '— {sender}, Lighthouse 1893',
       14
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'group_parent');

-- The card's "Last reminded" tells a group message from a personal one.
ALTER TABLE rsvp_reminders ADD COLUMN IF NOT EXISTS is_group boolean NOT NULL DEFAULT false;
