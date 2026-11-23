-- 1738 (2026-11-23) — every group message off an event says where to answer.
-- Owner: "we need the no response email to tell them to goto footballhome.org
-- if its group mess … it says this: Boys Practice · Mon, Nov 23 · 4:00 PM @
-- The Lighthouse … but doesnt tell them to goto fh and set rsvp" + "this
-- needs universal fixing".  A group message can't carry anyone's own sign-in
-- link (one-player reminders do), so {link} is the event's page on
-- footballhome.org.  The – No response group opens with the RSVP ask.
UPDATE message_templates SET body = E'{event}[[ @ {where}]]\nGo to footballhome.org to see it and set your RSVP: {link}\n',
       label = 'Group contact: message opens with ({event} {where} {link})'
 WHERE kind = 'event_center' AND tier = 'group_body';
UPDATE message_templates SET body = E'{game}[[ @ {where}]]\nGo to footballhome.org to see it and set your RSVP: {link}\n',
       label = 'Message everyone: message opens with ({game} {where} {link})'
 WHERE kind = 'game_message' AND tier = 'body';
UPDATE message_templates SET body = 'We''re short for {event}[[ at {where}]]. Can you make it? Go to footballhome.org and answer: {link} — or reply here.',
       label = 'Ask Standby message ({event}, {where}, {link})'
 WHERE kind = 'event_center' AND tier = 'ask_standby_body';
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Event Center', 'Group contact, No response group: message opens with ({event} {where} {link})', 'event_center', 'group_body_noresp',
       E'We still need your RSVP for {event}[[ @ {where}]].\nGo to footballhome.org, sign in and tap Going or Not going: {link}\n', true, 1202, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'group_body_noresp');
