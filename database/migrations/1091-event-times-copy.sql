-- 1091: Arrival · Warmup · Kickoff on every event, #my and Event Center
-- (owner 2026-11-05: "we need arrival time, warmup time and kickoff time on
-- my and event center for all events! if its practice just time of event
-- as arrival is fine").  EventLabels.times(ev) builds the line; words here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event times', v.label, 'event_times', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Arrival time ({time})', 'arrival', 'Arrival {time}', 10),
    ('Warmup time ({time})',  'warmup',  'Warmup {time}',  20),
    ('Kickoff time ({time})', 'kickoff', 'Kickoff {time}', 30)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_times' AND m.tier = v.tier);
