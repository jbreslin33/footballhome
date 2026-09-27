-- 463 — Fines in the per-player RSVP reminder (owner 2026-09-27: "on
-- rsvp reminders where we list missing rsvp we should list fine rules at
-- bottom and list any they were fined for" — "we don't want players
-- surprised").  The reminder's adult body gains a {fines} token inside
-- [[ ]], filled by the backend from fine_kinds/fine_policies (mig 460)
-- and fh_person_fines(); it is empty, and the section drops, for anyone
-- whose section has no rates.  Parents' reminders are untouched.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — fines heading', 'rsvp_reminder_fines', 'heading', NULL, 'Team fines (added to your tuition on the first Friday of the next month):', 1
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder_fines' AND tier = 'heading');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — one rule', 'rsvp_reminder_fines', 'rule', NULL, '• {label}: {amount}', 2
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder_fines' AND tier = 'rule');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — heading over the player''s fines', 'rsvp_reminder_fines', 'fined_heading', NULL, 'Your fines so far:', 3
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder_fines' AND tier = 'fined_heading');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — one fine', 'rsvp_reminder_fines', 'fined', NULL, '• {when} {event} — {label}: {amount}', 4
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder_fines' AND tier = 'fined');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — no fines yet', 'rsvp_reminder_fines', 'none', NULL, 'You have no fines so far.', 5
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder_fines' AND tier = 'none');

-- The adult reminder: fines block above the sign-off.
UPDATE message_templates
   SET body = replace(body, E'\n\n— {sender}', E'[[\n\n{fines}]]\n\n— {sender}'), updated_at = now()
 WHERE kind = 'rsvp_reminder' AND tier = 'adult' AND is_active AND body NOT LIKE '%{fines}%';
