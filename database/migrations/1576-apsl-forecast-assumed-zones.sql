-- 1576 (2026-11-19) — 📈 #apsl Forecast: say when the relegation places are
-- assumed.  A one-table conference the league marks no relegation places for
-- takes them from its size (mig 1575 pyramid_relegation_size_rules; owner
-- 11/19 "assume 1 relegation spot for all other apsl confs" / "12 and 1.5 …
-- if 11 then no relegation").  Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'Forecast — relegation places assumed from the conference size', 'apsl_pyramid', 'fc_zones_assumed', NULL,
       'The league marks no relegation places on this table, so they are assumed from its size (see Up and down below).', 426, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'fc_zones_assumed');
COMMIT;
