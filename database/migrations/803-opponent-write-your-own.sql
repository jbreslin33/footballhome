-- 803: ✍️ Write your own — a custom message to another team's coach
-- (owner 2026-10-28: "i need to be able to send custom message to coach of
-- other teams").  A 'custom' tier in the opponent Message dropdown (Game
-- Center 📇 panel and #opponents): picking it opens a box, and the typed
-- text fills {message} — Text / Email / Text all / Email all then send it.
-- Greeting, subject and sign-off stay here as copy.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Opponents', v.l, 'opponent', v.t, v.s, v.b, v.o, true, v.cs, false
  FROM (VALUES
    ('custom', 'Opponent — ✍️ Write your own…', 'Lighthouse 1893 SC — {club}',
     E'Hi {contact_first},\n\n{message}\n\nThanks,\n{sender}\nLighthouse 1893 SC', 0, true),
    ('custom_placeholder', 'Opponent — Write-your-own box placeholder', NULL,
     'Type your message — Hi + their first name goes on top, your name at the bottom.', 0, true)
  ) AS v(t, l, s, b, o, cs)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'opponent' AND m.tier = v.t);

-- Last in the dropdown.
UPDATE message_templates SET sort_order = (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM message_templates
                                            WHERE kind = 'opponent' AND tier <> 'custom')
 WHERE kind = 'opponent' AND tier = 'custom' AND sort_order = 0;
