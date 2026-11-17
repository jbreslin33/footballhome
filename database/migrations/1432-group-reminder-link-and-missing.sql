-- 1432 (2026-11-17) — Group RSVP reminders (📣 Remind all, every section)
-- carry a real Football Home link and say what's missing.  Owner: "women
-- remind no response needs footballhome.org link lol. i know when we email
-- all we can't send personal link but for all teams an email remind all
-- needs to contain what they are missing right and at least link to fh".
--
-- The bodies had the bare text "footballhome.org" (no scheme, so not a
-- link in every client).  {link} is now a full URL from the backend
-- (RsvpBoardController::handleRemindEvent): the event's own page
-- (/#event/<id>) for one event, the site for the whole-week message.
-- Still no magic token — a group message never carries one.
-- The whole-week message lists the open events again ({events}, dropped
-- for length in mig 685).  Event Center now also gets "Who's in": the
-- section comes from the unanswered players' teams when none is named.

UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('group_adult',
     'Hi all, still need your RSVP for {event}
Answer here: {link}
Your teammates and coaches are waiting on your response so we can plan.[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_parent',
     'Hi all, your player still needs to RSVP for {event}
Answer here: {link}
The other players, parents and coaches on the team are waiting on your response so we can plan.[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_week_adult',
     'Hi all, RSVPs still open (answer any you haven''t):
{events}
Answer here: {link}
Your teammates and coaches are waiting on your response so we can plan.[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_week_parent',
     'Hi all, your player still has RSVPs open (answer any you haven''t):
{events}
Answer here: {link}
The other players, parents and coaches on the team are waiting on your response so we can plan.[[ Who''s in: {roll_call}]] - {sender}')
  ) AS v(t, b)
 WHERE message_templates.kind = 'rsvp_reminder' AND message_templates.tier = v.t;
