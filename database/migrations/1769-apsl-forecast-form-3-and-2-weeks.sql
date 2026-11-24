-- 1769 (2026-11-23) — #apsl 📈 Forecast: two stronger recent-form levels.
-- Owner 11/23 "add a 3 week recentcy and 2 week": a game's weight halves
-- every 21 days / every 14 days (mig 1767's pyramid_forecast_form_levels —
-- a level is a row; the 📅 pills read them from the forecast).
BEGIN;

INSERT INTO pyramid_forecast_form_levels (half_life_days, label, is_recommended, sort_order)
SELECT v.d, v.l, false, v.o
  FROM (VALUES
    (21::numeric, 'Stronger — 3 weeks',  50),
    (14::numeric, 'Strongest — 2 weeks', 60)
  ) AS v(d, l, o)
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_forecast_form_levels f WHERE f.half_life_days = v.d);

COMMIT;
