-- 675 (2026-10-24) — 📲 Text's sub-options: the default is picked for
-- you, the others stay one tap away for that one message.  Owner: "why
-- not option on James Breslin to text from my pohone lol" → "it should
-- default to one but still allow the other right?" → "like a sub option.
-- like we have text, email, call. then inside each option it has sub
-- option and defaults to default but allows radio button to change it
-- for that message?" → "this seems more elegant?"
--
-- Contact sheet HOW = 📲 Text / ✉ Email / 📞 Call.  Under Text:
--   ◉ Club number   ○ My phone — FH Texter   ○ My phone — copy & paste
-- pre-selected by mig 673's rule (opted in → club, else FH Texter, else
-- paste); one that can't work is greyed with its reason.  The route
-- lines mig 673 printed beside "📲 Text" are retired.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'contact_menu', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('via_club',  'Text sub-option — club number',              '📲 Club number (215) 769-9197', 987),
    ('via_relay', 'Text sub-option — FH Texter ({device})',     '📱 My phone — FH Texter sends it ({device})', 988),
    ('via_paste', 'Text sub-option — copy & paste',             '💬 My phone — copy & paste', 989)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = v.t);

UPDATE message_templates SET is_active = false
 WHERE kind = 'contact_menu' AND tier IN ('route_club', 'route_relay', 'route_manual', 'how_phone', 'how_club');
