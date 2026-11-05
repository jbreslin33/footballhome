-- 🎟 Call-up rides the one 📇 Contact popup (owner 2026-11-05: "why is the
-- call up not just the contact card with call up message selected. we were
-- supposed to consolidate contacts to that one button").  Game Center's
-- 🎟 Call-ups section and Event Center's Invites pill drop their own
-- 💬 / 📧 / 🔗 buttons; each row opens the popup with the call-up
-- preselected, and sending it creates the invite (fh_event_invites, the
-- only way a call-up sees the game) before the words go out.  The old 🔗
-- copy-link button becomes a 📋 Copy send type in the popup.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', v.l, 'contact_popup', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('msg_callup',        'Message — call up to this game (creates the invite)', '🎟 Call up to this game', 1344),
    ('msg_callup_resend', 'Message — re-send an open call-up',                   '🎟 Call-up (re-send)', 1345),
    ('via_copy',          'Send type — copy the words',                          '📋 Copy', 1346),
    ('copied',            'Result — words copied',                               '✓ Copied — paste it anywhere', 1347)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_popup' AND m.tier = v.t);
