-- 1466 (2026-11-18) — 📅 Calendar: 💬 Chat and ⚖️ Fines up top, one line each.
-- Owner 11/18: "should we show the chat up top and the fines? i think so
-- right just make them smaller?"
--
-- They moved out of 👤 Mine (under the calendar) to just below the notices,
-- folded to a bar: chat = its newest message, fines = this period's total
-- (red when anything is owed).  Tap a bar → the full chat / fines panel.
-- No fines bar for anyone without rates (parents, women, youth).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar top bar — chat',              'top_chat',       '💬 Chat',                    1350),
    ('Calendar top bar — fines',             'top_fines',      '⚖️ Fines',                   1351),
    ('Calendar top bar — no fines',          'top_fines_none', 'None — keep it that way',   1352)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
