-- 386 — What a standby player reads once Not Going took them off the
-- game's alternates (the opt-out mig 385 promised).
--
-- Owner 2026-09-19: "make not going drop them from alternates
-- automatically."  The RSVP save returns this line; #game-center shows
-- it under the availability buttons.  Token: {child} (parent tier).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', v.label, 'squad_notice', v.tier, NULL, v.body, v.sort_order
  FROM (VALUES
    ('Standby — taken off', 'standby_dropped_adult', 28,
     'You''re off standby for this game — enjoy your plans. If that changes, tell a coach.'),
    ('Standby — taken off, parent', 'standby_dropped_parent', 29,
     '{child} is off standby for this game — enjoy your plans. If that changes, tell a coach.')
  ) AS v(label, tier, sort_order, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'squad_notice' AND t.tier = v.tier);
