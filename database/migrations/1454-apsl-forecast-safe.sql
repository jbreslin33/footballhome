-- 1454 (2026-11-17) — 📈 #apsl Forecast: ✅ Safe column (owner "why not have
-- chance of finishing totally safe in the table on site which is 6th
-- place"): the chance of finishing above every place that moves a team
-- down (relegation playoff included). Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'Forecast — column: safe (above every relegation place)', 'apsl_pyramid', 'fc_col_safe', NULL, '✅ Safe', 373, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'fc_col_safe');
COMMIT;
