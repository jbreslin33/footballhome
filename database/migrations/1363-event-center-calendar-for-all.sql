-- 1363 (2026-11-14) — Event Center slice 2: the week calendar for every tier
-- (docs/event-center-design.md).  Owner: "for me cal grid should be standard
-- with the red line. also we should default the view to the red line like
-- screll down if phone to that spot. we should still show early in week. but
-- have them greyed out."
--
-- Players and parents now get the calendar too (their own + kids' events —
-- the feed was already scoped).  The staff-only [👤 Mine] [📅 Club week] pills
-- (mig 1296) go: one page for everyone.  Person chips filter the week:
-- Everyone · Me · each kid (shown when the feed holds more than your own).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Calendar person chip — everyone', 'event_center', 'person_all', NULL, 'Everyone', 1300, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'person_all');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Calendar person chip — your own events', 'event_center', 'person_me', NULL, 'Me', 1301, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'person_me');

UPDATE message_templates SET is_active = false
 WHERE kind = 'event_center' AND tier IN ('view_mine', 'view_club');
