-- 677 (2026-10-24) — Blank (my own words) can go through FH Texter: the
-- contact sheet shows a message box under 📲 Text → My phone — FH
-- Texter, and Send queues exactly what was typed.  Owner: "why cant i do
-- blank my words and text via my phone and texter app?" → "it says
-- weeird copy and past" → "why cant it allow for a text box?"
--
-- Blank now defaults to FH Texter when the phone is online; the
-- fallback's wording says what it does instead of "copy & paste".

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'contact_menu', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('blank_placeholder', 'Blank via FH Texter — message box hint', 'Type your message — your phone sends it', 990),
    ('blank_empty',       'Blank via FH Texter — nothing typed',    'Type a message first', 991)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = v.t);

UPDATE message_templates SET body = '💬 My phone — I''ll send it in Messages myself'
 WHERE kind = 'contact_menu' AND tier = 'via_paste';

UPDATE message_templates SET is_active = false
 WHERE kind = 'contact_menu' AND tier = 'manual_why_blank';
