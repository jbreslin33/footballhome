-- 1770 (2026-11-23) — #apsl 📈 Forecast: a 1-week recent-form level.
-- Owner 11/23 "and for the heck of a a 1 week lol for volatility and to sim
-- if it was fresh start": a game's weight halves every 7 days — close to
-- only the latest games counting (mig 1767's pyramid_forecast_form_levels).
BEGIN;

INSERT INTO pyramid_forecast_form_levels (half_life_days, label, is_recommended, sort_order)
SELECT 7, 'Fresh start — 1 week', false, 70
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_forecast_form_levels f WHERE f.half_life_days = 7);

COMMIT;
