-- 1923 (2026-11-25) — 📇 Contact: three pay tones on every popup.
-- Owner: "just the amount due and how far behind simple?" … "in contact
-- multiple 'tones'?" → picked: 💳 Pay link (mig 1922, link only) ·
-- 💳 Balance (amount + how far behind, friendly) · ⚠️ Past due (firmer).
-- "dont say 2nd notice right?" — none of them numbers a notice.
-- Balance / Past due show only when the player owes (PersonStanding dues).
-- {amount} "$35", {months_label} "1 month" / "2 months"; parent tier names
-- {child}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT v.category, v.label, v.kind, v.tier, v.subject, v.body, v.sort_order, true
  FROM (VALUES
    ('Contact', '📇 Contact: balance message label', 'contact_popup', 'msg_pay_balance', NULL, '💳 Balance', 1368),
    ('Contact', '📇 Contact: past-due message label', 'contact_popup', 'msg_pay_past_due', NULL, '⚠️ Past due', 1369),

    ('System', 'Balance email — to a youth player''s parent', 'pay_balance_email', 'parent',
     'Lighthouse 1893[[ — {child}''s balance]]',
     E'Hi[[ {first}]],\n\n[[{child}''s ]]balance is {amount}[[ ({months_label})]]. You can pay here: {form:la_dashboard}\n\nLog in with the LeagueApps account you registered with — the pay button is right there.\n\nThanks,\nLighthouse 1893', 230),
    ('System', 'Balance email — to the player', 'pay_balance_email', 'adult',
     'Lighthouse 1893 — your balance',
     E'Hi[[ {first}]],\n\nYour balance is {amount}[[ ({months_label})]]. You can pay here: {form:la_dashboard}\n\nLog in with the LeagueApps account you registered with — the pay button is right there.\n\nThanks,\nLighthouse 1893', 231),
    ('System', 'Balance text — to a youth player''s parent', 'pay_balance_sms', 'parent', NULL,
     'Hi[[ {first}]], [[{child}''s ]]balance is {amount}[[ ({months_label})]]. Pay here: {form:la_dashboard} Thanks! Lighthouse 1893', 232),
    ('System', 'Balance text — to the player', 'pay_balance_sms', 'adult', NULL,
     'Hi[[ {first}]], your balance is {amount}[[ ({months_label})]]. Pay here: {form:la_dashboard} Thanks! Lighthouse 1893', 233),

    ('System', 'Past-due email — to a youth player''s parent', 'pay_past_due_email', 'parent',
     'Lighthouse 1893[[ — {child}''s dues are past due]]',
     E'Hi[[ {first}]],\n\n[[{child}''s ]]dues are past due: {amount}[[ ({months_label} behind)]]. Please pay here: {form:la_dashboard}\n\nDues keep the club running — fields, referees, league fees and coaches. Players whose dues stay unpaid can be dropped from the program.\n\nQuestions about the account? Just reply.\n\nThanks,\nLighthouse 1893', 234),
    ('System', 'Past-due email — to the player', 'pay_past_due_email', 'adult',
     'Lighthouse 1893 — dues past due',
     E'Hi[[ {first}]],\n\nYour dues are past due: {amount}[[ ({months_label} behind)]]. Please pay here: {form:la_dashboard}\n\nDues keep the club running — fields, referees, league fees and coaches. Players whose dues stay unpaid can be dropped from the program.\n\nQuestions about the account? Just reply.\n\nThanks,\nLighthouse 1893', 235),
    ('System', 'Past-due text — to a youth player''s parent', 'pay_past_due_sms', 'parent', NULL,
     'Hi[[ {first}]], [[{child}''s ]]dues are past due: {amount}[[ ({months_label} behind)]]. Please pay here: {form:la_dashboard} Players whose dues stay unpaid can be dropped from the program. Questions? Just reply. Lighthouse 1893', 236),
    ('System', 'Past-due text — to the player', 'pay_past_due_sms', 'adult', NULL,
     'Hi[[ {first}]], your dues are past due: {amount}[[ ({months_label} behind)]]. Please pay here: {form:la_dashboard} Players whose dues stay unpaid can be dropped from the program. Questions? Just reply. Lighthouse 1893', 237),

    ('System', 'Pay tones: how far behind — one month', 'pay_months', 'one', NULL, '1 month', 238),
    ('System', 'Pay tones: how far behind — {n} months', 'pay_months', 'many', NULL, '{n} months', 239)
  ) AS v(category, label, kind, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
