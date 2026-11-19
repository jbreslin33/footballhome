-- 1512 (2026-11-18) — Staff Calendar, piece by piece (2): the player's
-- ‹ This week · range › bar for coaches and admins too; Week · Month and
-- the date picker move into ☰ (like Games · Practices · Pickup · All).
-- Month view gets the same bar: ‹ This month · November 2026 ›.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar — the current month',       'mo_this',  'This month · {range}', 1412),
    ('Calendar — next month',              'mo_next',  'Next month · {range}', 1413),
    ('Calendar — last month',              'mo_last',  'Last month · {range}', 1414),
    ('Calendar — jump back to this month', 'mo_back',  'Back to this month',   1415),
    ('Calendar ☰ — go to a date',          'cal_goto', '📆 Go to a date…',     1416)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
