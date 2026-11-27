-- Migration 2190: 🎓 Scholarship — a dues-free status on #tuition.
-- Owner 11/27: the women (and anyone else on a free LA registration who is
-- not a volunteer) "should not count as paid members … would scholarship be
-- way to go?". A membership LA marks NA_FREE ($0 billed) whose person is not
-- a volunteer / injured now reads status 'scholarship' (PersonPayments):
-- own 🎓 section + stats cell, never 🟢 Paid up, no dues notices.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Payments', v.label, 'payments_overview', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Payments — scholarship status label', 'scholarship_label', '🎓 Scholarship', 12),
    ('Payments — scholarship card note',    'scholarship_note',
     'Scholarship: plays free on a $0 LeagueApps registration. Not a paid member — no bills, no notices.', 13)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t
                    WHERE t.kind = 'payments_overview' AND t.tier = v.tier AND t.is_active);
COMMIT;
