-- 1373 (2026-11-14) — Event Center under admin "View as" is read-only.
--
-- The open event and its attendance now load AS the viewed person
-- (?asPersonId on GET /api/calendar/events/:id and …/attendance), so the
-- page shows exactly their tier.  Writes still run as the real account, so
-- an answer or a mark made there would land on the admin, not on them —
-- the screen refuses every write while View as is on and says why.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'View as — writes refused (read-only)', 'event_center', 'view_as_read_only', NULL,
       '👀 View as is read-only — stop viewing as {name} to change anything here.', 1326, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'view_as_read_only');
