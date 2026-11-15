-- 1383 (2026-11-14) — Cash Flow Forecast: a Total dues subtotal under the
-- per-section dues rows. Owner 2026-11-14: "can we show total dues on cash
-- flow udner the clubs? or is that not standard?"

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', 'Finances — Cash Flow Forecast: total dues', 'finances', 'cf_dues_total', 'Total dues', true, 272, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = 'cf_dues_total');
