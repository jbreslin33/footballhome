-- 1469 (2026-11-18) — 🚦 Status bar: green or red, no yellow.  Owner 11/18:
-- "fines is green because there is nothing to do about it. but warning
-- they are about to get "new" fine is red right? so really there prob is no
-- yellow just green and red".
--
-- severity is now 'action' (something to do → the bar goes red) or 'info'
-- (a grey chip, the bar stays green):
--   action: unanswered events (soon or later — each can cost a new fine),
--           dues owed / blocked (pay)
--   info:   fines already owed, unread messages, suspended (nothing to do)
BEGIN;

ALTER TABLE status_items DROP CONSTRAINT IF EXISTS status_items_severity_check;
UPDATE status_items SET severity = CASE WHEN code IN ('dues_blocked', 'dues_owed', 'rsvp_soon', 'rsvp_open') THEN 'action' ELSE 'info' END;
ALTER TABLE status_items ADD CONSTRAINT status_items_severity_check CHECK (severity IN ('action', 'info'));
COMMENT ON TABLE status_items IS
  'mig 1468/1469: the Calendar status bar''s items — action = something to do (bar red), info = a grey chip (bar stays green); window_hours = how close an unanswered event reads "soon". Words: message_templates event_center chip_<code>.';

UPDATE message_templates SET body = '⛔ 1 thing needs you', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'status_major_one';
UPDATE message_templates SET body = '⛔ {n} things need you', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'status_major_many';
UPDATE message_templates SET body = '✓ You''re all set', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'status_ok';

COMMIT;
