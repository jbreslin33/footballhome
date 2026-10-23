-- 659 (2026-10-23) — "Text from my phone" on a desktop.
-- Owner: "i want to be able to text from my android online so i can text
-- from desktop for those not opted into twilio" → paired Google Messages
-- for Web.  It has no supported link that pre-fills a text, so on a
-- desktop every sms: hand-off opens a copy panel (number, message, open
-- Google Messages) instead of a dead sms: link.  frontend/js/lib/desktop-sms.js.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Texts', v.l, 'desktop_sms', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('title',     'Desktop text panel — title',                    '💬 Text from your phone — on this computer', 980),
    ('hint',      'Desktop text panel — how it works',             'Sends from your own number through Google Messages for Web (your Android must be on and online). Copy the number, start a chat, then copy the message.', 981),
    ('to',        'Desktop text panel — recipients heading ({n})',  'To ({n})', 982),
    ('message',   'Desktop text panel — message heading',          'Message', 983),
    ('copy',      'Desktop text panel — copy button',              'Copy', 984),
    ('copy_all',  'Desktop text panel — copy all numbers',         'Copy all', 985),
    ('copied',    'Desktop text panel — copied',                   '✓ copied', 986),
    ('open',      'Desktop text panel — open Google Messages',     'Open Google Messages', 987),
    ('phone_app', 'Desktop text panel — use the phone app instead','Open my texting app instead', 988),
    ('close',     'Desktop text panel — close',                    'Done', 989)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'desktop_sms' AND m.tier = v.t);
