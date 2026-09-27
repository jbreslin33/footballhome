-- 462 — Wording for the fines panel at the top of #my (owner 2026-09-27:
-- "list on their my page the fines in table list at top" and "list the
-- fine rules too at top").  The rules themselves are fine_kinds labels +
-- fine_policies rates (mig 460), read live; these rows are only the
-- frame around them.  client_side rows, read through MessageCopy.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — heading', 'my_fines', 'heading', NULL, 'Fines', 1, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'heading');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — note under the heading', 'my_fines', 'note', NULL, 'Added to your tuition with the next month''s dues on the first Friday. Days you were blocked from RSVPing by overdue tuition are not fined.', 2, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'note');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — rules heading', 'my_fines', 'rules_heading', NULL, 'The rules', 3, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'rules_heading');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — nothing owed', 'my_fines', 'empty', NULL, 'No fines so far.', 4, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'empty');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — month total line', 'my_fines', 'month_total', NULL, '{month} total {amount}', 5, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'month_total');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My fines — in effect since', 'my_fines', 'since', NULL, 'In effect since {since}.', 6, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_fines' AND tier = 'since');
