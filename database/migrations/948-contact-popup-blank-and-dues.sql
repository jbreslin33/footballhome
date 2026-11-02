-- Contact popup: the blank message and the youth dues reminder's label.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', v.l, 'contact_popup', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('msg_blank', 'Message — blank, the sender''s own words', '✏️ Blank', 1342),
    ('msg_dues',  'Message — dues reminder',                  '💸 Dues', 1343)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_popup' AND m.tier = v.t);
