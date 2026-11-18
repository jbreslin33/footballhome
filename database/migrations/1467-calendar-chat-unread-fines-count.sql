-- 1467 (2026-11-18) — 📅 Calendar top bars, richer one-liners.  Owner 11/18:
-- "the chat can have like part of last message and then number of unread
-- messages and timestamp of last one. then its expandable on click right?
-- same with fines. show like total then allow for expansion?"
--
-- 💬 Chat: newest message (cut to fit) · 🔴 {n} new · its time.  Unread =
-- newer than the newest one seen on this device; opening the chat reads all.
-- ⚖️ Fines: total · how many.  Tap either bar → the full panel.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar top bar — unread chat count', 'top_chat_unread', '{n} new',            1353),
    ('Calendar top bar — one fine',          'top_fines_one',   '{amount} · 1 fine',    1354),
    ('Calendar top bar — several fines',     'top_fines_many',  '{amount} · {n} fines', 1355)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
