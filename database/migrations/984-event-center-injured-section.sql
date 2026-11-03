-- 984: Event Center's player cards get a 🩹 Injured group (owner
-- 2026-11-03: "why is mars showing to rsvp. he should be on injured cat").
-- An open injury with no answer of his own reads as Injured, never No
-- response, and the Remind-all bar leaves him out — the rule #my already
-- follows (mig 510).  An explicit answer still wins the grouping.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Section — injured, no answer (fold)', 'event_center', 'sec_injured', NULL, '🩹 Injured', 1210, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'sec_injured');
