-- 530 (2026-10-06) — #rsvps: a "Who" row of pills narrows the board to
-- players, coaches or staff (owner: "can we add coaches pill to rsvps
-- page (reminders)").  The words live here; the roles themselves come
-- from the board rows (role / week_events[].role, mig 438 wording).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'rsvp_board_who', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('all',    'RSVP Reminders — Who pill: everybody on the board', 'Everyone', 740),
    ('player', 'RSVP Reminders — Who pill: rostered players',       'Players',  741),
    ('coach',  'RSVP Reminders — Who pill: coaches of a board team','Coaches',  742),
    ('staff',  'RSVP Reminders — Who pill: club staff (mig 430)',   'Staff',    743)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'rsvp_board_who' AND m.tier = v.t);
