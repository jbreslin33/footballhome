-- 1511: ☰ gets 🎭 Exit view-as while an admin views as someone.
--
-- Owner 11/18: "on phone i am still elegbe and there is no exit view as at
-- top".  On a phone the top stack scrolls away and the Calendar scrolls to
-- the NOW line, so the orange bar was off-screen.  The bar now pins to the
-- bottom there, and ☰ lists the way out first.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', '☰ menu — exit view-as (admins viewing as someone)', 'event_center', 'qlink_exit_view_as', NULL, '🎭 Exit view-as', 1411, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'qlink_exit_view_as');
