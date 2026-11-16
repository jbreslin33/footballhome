-- 1402 (2026-11-16) — #tuition cards show the last 2 payments (owner: "on
-- tuition screen i need to see last payments for players. at least last 2
-- amount and date"). Words only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Payments', v.label, 'payments_overview', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Tuition card — last payments', 'card_last_payments', 'Last paid:', 900),
    ('Tuition card — no payments', 'card_no_payments', 'No payments on record', 901),
    ('Tuition card — bank not deposited', 'card_pending_title', 'Bank payment — not deposited yet', 902)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'payments_overview' AND t.tier = v.tier);
