-- 748: Event Center list — a "now" line between the events that are over
-- and the ones still to come (owner 2026-10-27: "a divider line that shows
-- current time … to separate past events").  {time} = the clock when drawn.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('now_line', 'Event list — the line at the current time ({time})', 'Now · {time}', 1216)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
