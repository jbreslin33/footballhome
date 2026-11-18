-- 1477 (2026-11-18) — 🚦 Dues box: "Pay now OR Volunteer".  Owner 11/18:
-- "Pay now OR Volunteer".  The dues box reads
--   ⛔ Overdue dues $70   [Pay now ›] or [🙋 Volunteer ›]
-- (Volunteer only for someone who can volunteer — mig 1461).  The joining word:
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Status band — between two choices in a box', 'event_center', 'or_word', NULL, 'or', 1406, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'or_word');
