-- 1485 (2026-11-18) — 📅 in the band for players instead of ← Back.  Owner
-- 11/18: "they need a back button but instead maybe a calendar button at top
-- because that is the only item on their universal menu right?" → "since
-- its only one it just disappears when they are in [the Calendar]".
--
-- PlayerViewer (lib/viewer.js showsCalendarButton / eventBack): 📅 at the
-- band's right end, before 💬 and ☰, on every screen except the Calendar
-- itself; event pages (practice and game) drop ← Back.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Band — the Calendar button (players)', 'event_center', 'band_calendar', NULL, '📅 Calendar', 1419, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'band_calendar');
