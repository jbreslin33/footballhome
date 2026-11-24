-- 1771 (2026-11-23) — #apsl 📈 Forecast: recent form is a weeks slider.
-- Owner 11/23 "just have slider bar for weeks" (after asking for 3-week,
-- 2-week and 1-week levels on top of mig 1767's four pills): the 📅 pills
-- and their table go; the page gets one slider — how many weeks until a
-- game counts half, 1 … form_slider_max_weeks, one more notch = off.
-- The default becomes a whole number of weeks: 60 days → 8 weeks (56).
BEGIN;

DROP TABLE IF EXISTS pyramid_forecast_form_levels;

ALTER TABLE pyramid_forecast_policies
  ADD COLUMN IF NOT EXISTS form_slider_max_weeks integer NOT NULL DEFAULT 13 CHECK (form_slider_max_weeks BETWEEN 1 AND 52);
COMMENT ON COLUMN pyramid_forecast_policies.form_slider_max_weeks IS
  'The 📅 recent-form slider runs from 1 week to this many; one notch past it = every game the same.';
UPDATE pyramid_forecast_policies SET form_half_life_days = 56 WHERE form_half_life_days = 60;

UPDATE message_templates SET body = '📅 Recent form — drag: how fast older games fade', label = 'Forecast — recent form slider: title'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_label';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c.category, v.l, 'apsl_pyramid', v.t, NULL, v.b, v.o, true, c.client_side, c.is_public
  FROM (VALUES
    ('fc_form_weeks', 'Forecast — recent form slider: value ({weeks})', 'A game counts half as much every {weeks} wk older it is', 334),
    ('fc_form_off',   'Forecast — recent form slider: off',             'Off — every game counts the same', 334),
    ('fc_form_reset', 'Forecast — recent form slider: reset',           '↺ ⭐ Recommended', 334),
    ('fc_form_hint',  'Forecast — recent form slider: hint',            'Left = only the latest games matter (a fresh start, jumpy). Right = the whole season counts the same. Let go to replay the season.', 334)
  ) AS v(t, l, b, o)
 CROSS JOIN (SELECT category, client_side, is_public FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'fc_how') c
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
