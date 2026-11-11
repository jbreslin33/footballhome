-- 1273 (2026-11-11) — Event Center: 👤 Mine section (everything #my shows).
--
-- Owner 2026-11-11: "do we need my? i think they should be taken to event
-- center" / "we can put the stuff from my page … into event center
-- 'personal' section" / "bring it all and i can ask for edits after" /
-- "just put it in sep section but visible".  The whole #my page (MyScreen)
-- now draws in its own section at the top of #event-center, above the
-- club calendar.  #my itself stays until the last step (then redirects).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Event Center', 'Event Center — personal section title (the #my page)', 'event_center', 'mine_title', NULL, '👤 Mine', 900, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'mine_title');
