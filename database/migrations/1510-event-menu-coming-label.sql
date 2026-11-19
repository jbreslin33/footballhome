-- 1510: ☰ name for the people list on an opened event.
--
-- Since 11/18 everything under an event's graphic goes into ☰, each item
-- named by its panel's heading.  The people list (going / no response /
-- invites …) had no heading of its own, so ☰ showed its first button,
-- "💬 64" (the text-everyone count).  The panel now names itself.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', '☰ menu: the people list on an event', 'event_center', 'menu_coming', NULL, '👥 Who''s coming', 1210, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'menu_coming');
