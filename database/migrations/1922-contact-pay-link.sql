-- 1922 (2026-11-25) — 💳 Pay link: a standard message in every 📇 Contact
-- popup (SectionContact), for all sections.
-- Owner, after a parent asked for the link to pay: "we dont' want over due
-- notice harsh just here pay here" … "in player profile popup" … "it needs
-- to be standard possible message in contact for all right?"
-- Just the LeagueApps dashboard link ({form:la_dashboard}, club_forms) —
-- no amount, no months behind, no warnings (those stay on #tuition's ✉️/💬).
-- Tier parent = a youth player's parent ({child} named); adult = the player.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT v.category, v.label, v.kind, v.tier, v.subject, v.body, v.sort_order, true
  FROM (VALUES
    ('Contact', '📇 Contact: pay link message label', 'contact_popup', 'msg_pay_link', NULL,
     '💳 Pay link', 1367),
    ('System', 'Pay link email — to a youth player''s parent', 'pay_link_email', 'parent',
     'Lighthouse 1893[[ — paying for {child}]]',
     E'Hi[[ {first}]],\n\nHere''s the link to pay[[ for {child}]]: {form:la_dashboard}\n\nLog in with the LeagueApps account you registered with — your balance and the pay button are right there.\n\nThanks,\nLighthouse 1893', 226),
    ('System', 'Pay link email — to the player', 'pay_link_email', 'adult',
     'Lighthouse 1893 — pay link',
     E'Hi[[ {first}]],\n\nHere''s the link to pay: {form:la_dashboard}\n\nLog in with the LeagueApps account you registered with — your balance and the pay button are right there.\n\nThanks,\nLighthouse 1893', 227),
    ('System', 'Pay link text — to a youth player''s parent', 'pay_link_sms', 'parent', NULL,
     'Hi[[ {first}]], here''s the link to pay[[ for {child}]]: {form:la_dashboard} Log in with your LeagueApps account — the balance and pay button are right there. Thanks! Lighthouse 1893', 228),
    ('System', 'Pay link text — to the player', 'pay_link_sms', 'adult', NULL,
     'Hi[[ {first}]], here''s the link to pay: {form:la_dashboard} Log in with your LeagueApps account — the balance and pay button are right there. Thanks! Lighthouse 1893', 229)
  ) AS v(category, label, kind, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
