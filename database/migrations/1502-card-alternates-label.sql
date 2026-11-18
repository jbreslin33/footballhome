-- 1502 (2026-11-18) — Live game card: under the substitutes, – No response,
-- ✗ Not going, then 🔁 Alternates (owner 11/18 "we need not responded on
-- graphic and not going … obviously this goes under substitutes … also we
-- need alternates … under subs put no response, then not going then
-- alternates").  No response / Not going reuse sec_noresp / sec_notgoing;
-- this is the alternates heading (sec_alt "🔁 Alt" is the short card pill).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Live card — alternates heading', 'event_center', 'card_alternates', NULL, '🔁 Alternates', 900, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'card_alternates');
