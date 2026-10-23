-- Desktop text panel (mig 659) becomes two guided steps.
-- Owner 2026-10-23: "its just opening messages but not pre filing. and
-- now i have original message tab and new one" → "can we pre populate".
-- Google Messages for Web has no pre-fill link, so the panel does the
-- rest in two clicks: copy the number AND open Messages (a small window
-- beside Football Home, the same one every time), then copy the message.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Texts', v.l, 'desktop_sms', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('step1',      'Desktop text panel — step 1 button',  '1 · Copy number & open Messages', 990),
    ('step1_hint', 'Desktop text panel — after step 1',   'In Messages: Start chat → paste (Ctrl+V) → Enter.', 991),
    ('step2',      'Desktop text panel — step 2 button',  '2 · Copy message', 992),
    ('step2_hint', 'Desktop text panel — after step 2',   'Click the message box in Messages → paste (Ctrl+V) → send.', 993),
    ('tabs_hint',  'Desktop text panel — one window note', 'Messages opens in its own small window and reuses it — close any other Messages tab.', 994)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'desktop_sms' AND m.tier = v.t);
UPDATE message_templates SET body = 'Sends from your own number through Google Messages for Web (your Android must be on and online). Google doesn''t allow pre-filling, so it''s two clicks and two pastes.'
 WHERE kind = 'desktop_sms' AND tier = 'hint';
