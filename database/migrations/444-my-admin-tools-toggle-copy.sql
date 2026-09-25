-- 444 (2026-09-25) — owner: "for admin extra functionality to text and
-- email we should hide that by default and have a toggle to show it at
-- top of page so it don't clutter my screen".  The toggle's words.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'my_admin_tools', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('on',  'My page — admin tools toggle, shown',  'Admin tools on — text & email everyone on an event',  740),
    ('off', 'My page — admin tools toggle, hidden', 'Admin tools off',                                      741)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_admin_tools' AND m.tier = v.t);
