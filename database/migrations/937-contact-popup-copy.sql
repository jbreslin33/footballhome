-- Contact popup words (owner 11/2: "contact popup should now be one stop
-- shop for contacting").  Read through MessageCopy, kind contact_popup.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', v.l, 'contact_popup', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('button',           'Button on every screen',                'CONTACT', 1300),
    ('title',            'Popup title ({name})',                  '📇 Contact {name}', 1301),
    ('who',              'WHO heading',                           'WHO', 1302),
    ('message',          'MESSAGE heading',                       'MESSAGE', 1303),
    ('words',            'WORDS heading',                         'WORDS', 1304),
    ('how',              'SEND BY heading',                       'SEND BY', 1305),
    ('send',             'Send button',                           'Send', 1306),
    ('sending',          'While sending',                         'Sending…', 1307),
    ('call',             'Call button',                           '📞 Call', 1308),
    ('save',             'Save contact button',                   '👤 Save contact', 1309),
    ('via_email',        'Send type — email',                     '✉ Email', 1310),
    ('via_relay',        'Send type — FH Texter',                 '📱 FH Texter', 1311),
    ('via_text',         'Send type — regular text',              '💬 Regular text', 1312),
    ('via_club',         'Send type — club text',                 '🏢 Club text', 1313),
    ('msg_hello',        'Message — plain hello',                 '💬 Message', 1314),
    ('msg_invite',       'Message — Football Home invite',        '📣 Invite to Football Home', 1315),
    ('msg_signin',       'Message — sign-in link',                '🔗 Sign-in link', 1316),
    ('msg_welcome',      'Message — welcome',                     '👋 Welcome', 1317),
    ('msg_register',     'Message — Women''s TeamSnap register',  '📝 Register', 1318),
    ('built_on_send',    'Words box for server-built messages',   'Written when you send, with their own sign-in link.', 1319),
    ('why_no_email',     'Why not — no email',                    'No email on file', 1320),
    ('why_no_phone',     'Why not — no mobile',                   'No mobile number on file', 1321),
    ('why_stopped',      'Why not — replied STOP',                'They replied STOP', 1322),
    ('why_unpaired',     'Why not — FH Texter not set up',        'FH Texter is not set up', 1323),
    ('why_offline',      'Why not — phone offline',               'Your phone is offline', 1324),
    ('why_cap',          'Why not — day''s cap used',             'Today''s limit is used', 1325),
    ('why_not_opted_in', 'Why not — not opted in',                'Not opted in to club texts', 1326),
    ('opened_email',     'Result — email opened',                 '✓ Email opened', 1327),
    ('opened_text',      'Result — text opened',                  '✓ Text opened', 1328),
    ('sent_club',        'Result — club text sent',               '✓ Sent from the club number', 1329),
    ('sent_relay',       'Result — queued to FH Texter',          '✓ Sent to your phone to send', 1330)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_popup' AND m.tier = v.t);
