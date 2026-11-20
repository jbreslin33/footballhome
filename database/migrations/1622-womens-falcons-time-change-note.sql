-- 1622 (2026-11-20) — Women's game vs Falcons Orange: time-change note.
--
-- Owner 11/20: "need a message on the game event to let women know game
-- time changed. re sync gcal and you will see it."  The gcal re-sync moved
-- Sun Nov 22 from 1:30 PM (the time on the 11/20 RSVP reminders) to
-- 11:30 AM.  The one-game note (event_reminder_notes, mig 1003) rides on
-- every Game reminder for this game — the group text and each player's own.

INSERT INTO event_reminder_notes (fh_event_id, body) VALUES
  (75692377, '⏰ NEW TIME — kickoff moved up from 1:30 PM to 11:30 AM.')
ON CONFLICT (fh_event_id) DO UPDATE SET body = EXCLUDED.body, updated_at = now();
