-- 1173: Game Center takes attendance (owner 2026-11-07: "we should be able
-- to take attendance from event center … for games and practices").
-- Practices already carry P/A/L/E on every Event Center card; a game opens
-- in Game Center, whose cards now carry the same row for the game's
-- coaches and club admins, from game day on.  This is the word in front
-- of the four buttons.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Game card — attendance row label', 'event_center', 'attendance_label', NULL, 'Attendance', 1220, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'attendance_label');
