-- 1605 (2026-11-20) — The 📅 Calendar tile's grey count is 🪑 Reserves,
-- not 💤 inactive.
--
-- Owner 11/20: "there should be no inactive right? isn't it all reserves
-- now for all teams?"  The tile counts ev.inactive, which since mig 1530
-- is the event's unanswered Reserves (nobody holds a real Inactive
-- status), yet it still read "💤 12 inactive" on the men's tiles.

BEGIN;

UPDATE message_templates
   SET body = '🪑 {n} reserves', label = 'Calendar tile: unanswered Reserves count ({n})'
 WHERE kind = 'event_center' AND tier = 'tile_inactive';

COMMIT;
