-- Contact popup: words for #leads and for a number that takes no texts.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', v.l, 'contact_popup', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('msg_first_touch', 'Message — lead touch 1',          '👋 Touch 1', 1340),
    ('why_no_text',     'Why not — number takes no texts', 'This number does not take texts', 1341)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_popup' AND m.tier = v.t);
