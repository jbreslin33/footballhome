-- 🎶 Barn Night's own "not answered" line on the calendar tile (owner 11/19
-- "don't put set your avail the coach is counting on it lol").  The tile looks
-- for event_center me_status_none_<kind> (spaces → _) before the generic
-- me_status_none; a fine still wins (me_status_none_fine).
INSERT INTO message_templates (category, label, kind, tier, body, is_active, client_side)
SELECT 'Event Center', 'Calendar tile: Barn Night not answered', 'event_center', 'me_status_none_barn_night',
       '🎶 Coming to Barn Night?', true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'me_status_none_barn_night');
