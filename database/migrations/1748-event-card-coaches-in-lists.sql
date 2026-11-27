-- 1748 (2026-11-23) — Practice / pickup card: coaches in every list.
-- Owner: "card for practice is totally confising and missing coaches".
-- The card named only the coaches who said Going, under the Going count.
-- Now (EventScreen._teamCardHtml / _cardOutHtml) Going, No response and
-- Not going each end with their own "Coaches: …" line and count both:
-- "0 players and 2 coaches going", "– No response (15 players and 3
-- coaches)". Count words = mig 1747's rows. Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Practice card — going total with coaches ({count})', 'event_center', 'card_total_both', NULL, '{count} going', 1241, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'card_total_both');
