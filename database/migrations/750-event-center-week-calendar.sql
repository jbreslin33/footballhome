-- 750: Event Center is a Monday–Sunday week calendar (owner 2026-10-27:
-- "a calendar is best … one source of data … cal with pills to populate
-- cal"; "clicking a card opens that event to view and edit").  The type
-- pills fill it, Games included; the day-pill card list and the pill
-- strips are gone.  Copy for screens/event-center.js.
UPDATE message_templates
   SET body = 'The week — pick a type, then tap an event to open it'
 WHERE kind = 'event_center' AND tier = 'list_sub';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('this_week',  'Week calendar — back to this week',                 'This week', 1217),
    ('not_posted', 'Week calendar — tile of an event not released yet', 'not posted yet', 1218)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
