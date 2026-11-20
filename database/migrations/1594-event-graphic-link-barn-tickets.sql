-- 🎟 An event graphic can link somewhere (owner 11/19 "have the graphic got
-- this link to buy tickets"): fh_event_graphics.link_url — tapping the flyer
-- (calendar tile or event page) opens it.  No link → the event page opens the
-- picture full size, the tile opens the event, as before.
ALTER TABLE fh_event_graphics ADD COLUMN IF NOT EXISTS link_url text;

-- Barn Night Fri Nov 20 → its Eventbrite tickets page.
UPDATE fh_event_graphics
   SET link_url = 'https://www.eventbrite.com/e/the-lighthouse-friday-nights-the-barn-november-20th-tickets-2004078370354?aff=oddtdtcreator'
 WHERE fh_event_id = 75824080 AND club_file_id = 54;

-- The hover / long-press hint on a linked graphic.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, client_side)
SELECT 'Event Center', 'Event graphic link hint', 'event_center', 'graphic_link', 'Tap for tickets', true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'graphic_link');
