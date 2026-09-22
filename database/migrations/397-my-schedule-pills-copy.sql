-- 397 — Wording for the My Schedule pills (#my).
--
-- Owner 2026-09-21: "instead of separate schedule button we can have pills
-- on my page for player/parent. it says this week, all, games only,
-- practice only" — future events show read-only until their week opens.
-- client_side rows, read through MessageCopy like every other label.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule pill — this week', 'my_schedule', 'pill_week', NULL, 'This week', 1, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'pill_week');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule pill — all', 'my_schedule', 'pill_all', NULL, 'All', 2, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'pill_all');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule pill — games only', 'my_schedule', 'pill_games', NULL, 'Games only', 3, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'pill_games');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule pill — practices only', 'my_schedule', 'pill_practices', NULL, 'Practices only', 4, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'pill_practices');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule — future event, RSVP not open yet', 'my_schedule', 'rsvp_opens', NULL, 'RSVP opens {when}', 5, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'rsvp_opens');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule — note over the future list', 'my_schedule', 'future_note', NULL, 'Future dates can change. You can RSVP once a week opens.', 6, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'future_note');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule — nothing in the future list', 'my_schedule', 'future_empty', NULL, 'Nothing on the calendar yet.', 7, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'future_empty');
