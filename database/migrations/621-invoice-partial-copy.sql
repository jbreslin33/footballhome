-- 621 (2026-10-20) — Invoice check-off: faster ✓/✗ and a 🟡 partial state.
--
-- Owner: "invoice needs to be easier to set that i was not there. so
-- easier to turn green or red. but also to turn yellow if there for
-- partial and put the hours of partial."
--
-- Code in the same commit: the 📅 chip's main zone cycles ✓ worked → ✗
-- not there → unanswered in single taps; a 🟡 zone on the chip (and a 🟡
-- button on every list row) opens a small hours box — the day then bills
-- that flat amount and reads yellow wherever it appears.  'partial' is a
-- derived state (a flat-hours day row below the event's own hours), no
-- schema change.  This migration only adds the client copy.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — partial mark tooltip', 'invoices', 'partial_tip', NULL,
       'There for part of it — enter the hours worked', 40, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'partial_tip');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — chip cycle tooltip', 'invoices', 'cycle_tip', NULL,
       'tap cycles: ✓ worked → ✗ not there → unanswered', 41, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'cycle_tip');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — partial hours placeholder', 'invoices', 'partial_ph', NULL,
       'hours', 42, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'partial_ph');
