-- 1569 (2026-11-19) — The 📣 RSVP reminder in an event's Contact popup says
-- what it does.  Owner: "where is the one for that event? tat is better right?
-- because then … after the take care of that popup the rest that are not
-- ansewredd?"  It already was that one: sent from an event (fh_event_id) the
-- words lead with that event and the link opens the roll call on it
-- (?e=<event>&more=1), highlighted, the rest of their unanswered week below.
-- The old name "RSVP reminder (every unanswered event this week)" hid that.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Contact', 'Contact popup: RSVP reminder sent from an event ({event})', 'contact_menu', 'what_remind_event',
       '📣 RSVP reminder — {event} first, then the rest they owe', 900, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = 'what_remind_event');
