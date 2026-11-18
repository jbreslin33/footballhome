-- 1476 (2026-11-18) — 🚦 Status band: chat is a 💬 button, not a box.
-- Owner 11/18: "not sure where to put chat lol" → "make chat the 💬 button —
-- i just think we need like a blinking button to read unread messages right?"
-- → "it should say x unread too".
--
-- 💬 at the band's right end; with unread messages it turns red, reads
-- "💬 3 unread" and pulses until the chat is opened (no pulse for anyone who
-- asked their device to reduce motion).  Tap → the chat popup.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Status band — chat button, unread',  'chat_btn_unread', '{n} unread', 1404),
    ('Status band — chat button (label)',  'chat_btn',        'Chat',       1405)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
