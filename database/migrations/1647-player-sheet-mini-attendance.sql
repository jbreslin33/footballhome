-- 1647 (2026-11-21) — ✅ Mini attendance on the ⋯ player sheet.
--
-- Owner: "we need to be able to take role of no response as sometimes they
-- show up lol. same with not going. it should have a mini attenance also in
-- the popup for that day and all days really but that event should default
-- to along with other options as normal of the player card."
--
-- The sheet carries the roll itself, above every tab: an event picker (the
-- event it was opened from first, then the person's other days — GET
-- /api/person-sheet/attendance) and Present / Absent / Late / Excused.  So a
-- – No response or ✗ Not going name tapped on an event opens straight on
-- his roll.  These are its words.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('att_label',      'Player sheet — mini attendance heading',              '✅ Attendance', 110),
    ('att_event_tip',  'Player sheet — mini attendance event picker tip',     'Which day — this event first, then their other days', 111),
    ('att_clear_tip',  'Player sheet — mini attendance, tap the lit one',     '{status} — tap to clear', 112),
    ('att_not_open',   'Player sheet — mini attendance before the day',       'The roll opens on the day.', 113),
    ('att_failed',     'Player sheet — mini attendance did not save',         'Could not save attendance', 114)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'player_sheet' AND m.tier = v.tier);

COMMIT;
