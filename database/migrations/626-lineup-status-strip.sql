-- 626 (2026-10-21) — Lineup status strip: last change + last DB sync.
--
-- Owner: "we should have a last changed label yellow or red or green to
-- be consistent. so it goes and gets it from db of course … a timestamp
-- of last lineup change would help players know at a glance if
-- something was changed … last change made label and last sync with db
-- right?"
--
-- Code in the same commit: every lineup save stamps
-- match_lineup_metadata.updated_at (even formation-less saves) and the
-- lineup GET serves it as lineupChangedAt, so players and coaches both
-- see when the lineup last moved — DB truth, never the browser's local
-- state (the 10/21 silent-save bug made the screen lie for a day).
-- The Game Center strip shows: Last change <stamp> · DB <state>, where
-- state is 🟡 saving/syncing, green ✓ synced <time>, red when a save or
-- sync failed (with the server's reason).  This migration adds the
-- strip's wording (never hardcode copy).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — last change', 'lineup_status', 'last_change', NULL,
       'Last change {when}', 70, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'last_change');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — never changed', 'lineup_status', 'no_change', NULL,
       'No lineup saved yet', 71, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'no_change');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — synced', 'lineup_status', 'synced', NULL,
       'DB ✓ {when}', 72, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'synced');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — saving', 'lineup_status', 'saving', NULL,
       'saving…', 73, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'saving');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — save failed', 'lineup_status', 'save_fail', NULL,
       'NOT SAVED — the board still shows {when}. {reason}', 74, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'save_fail');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Lineup status — sync failed', 'lineup_status', 'sync_fail', NULL,
       'sync failed — retrying', 75, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_status' AND tier = 'sync_fail');
