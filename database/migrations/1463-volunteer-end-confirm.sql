-- 1463 (2026-11-18) — 🙋 #payments: 🛑 End volunteer takes two taps (mig 1461
-- ledger panel; no browser confirm dialogs).  The second tap's label.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', '#payments: end a volunteer — confirm', 'volunteer_shift', 'end_confirm', NULL,
       'Tap again to end', 47, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'volunteer_shift' AND m.tier = 'end_confirm');
