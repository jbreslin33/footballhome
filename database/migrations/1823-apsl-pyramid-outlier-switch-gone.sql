-- 1823 (2026-11-24) — 🔺 #apsl-pyramid: the flow chart's one "Show on
-- screen" switch goes (owner: "clutter: Show on screen / Lines from outlier
-- teams (a table that feeds two conferences)").  The lines are always
-- drawn; the pill's label row is deleted with it.
BEGIN;
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'feature_outliers';
COMMIT;
