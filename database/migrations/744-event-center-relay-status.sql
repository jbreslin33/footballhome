-- 744: what the phone reported back for an FH Texter reminder, on the
-- Event Center card (owner 2026-10-26: "can it send back success?").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('relay_queued',    'FH Texter reminder — waiting on the phone',     '📱 queued on the phone…', 1211),
    ('relay_sent_at',   'FH Texter reminder — sent ({time})',           '📱 sent {time}, waiting for delivery…', 1212),
    ('relay_delivered', 'FH Texter reminder — delivered ({time})',      '📱 delivered {time} ✓', 1213),
    ('relay_failed',    'FH Texter reminder — failed ({error})',        '📱 FAILED — {error}', 1214),
    ('relay_opened',    'Link in the reminder first opened ({time})',   'opened {time} 👀', 1215)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
