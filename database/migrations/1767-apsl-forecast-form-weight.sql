-- 1767 (2026-11-23) — #apsl 📈 Forecast: recent games can count more.
-- Owner 11/23, after 1-2 v Sewell and 1-2 v Heritage ("why didn't the what
-- happens next pick this up"): every played game counted the same, so two
-- close losses barely moved a side that had lost 9-0 and 8-0 in September.
--
-- pyramid_forecast_policies.form_half_life_days: a game's weight in the
-- ratings halves every that many days before the latest game played
-- (Dixon & Coles 1997 §4.4).  NULL = every game the same.
--
-- Owner 11/23 "deploy but allow to turn on or off and diff recency levels?
-- like from recommended and up or down from that": the default is 60 days
-- (the recommended level) and pyramid_forecast_form_levels lists the levels
-- the page offers as 📅 pills — off, lighter, recommended, stronger.  A
-- level is a row; the page reads them from the forecast itself.
BEGIN;

ALTER TABLE pyramid_forecast_policies
  ADD COLUMN IF NOT EXISTS form_half_life_days numeric CHECK (form_half_life_days > 0);
COMMENT ON COLUMN pyramid_forecast_policies.form_half_life_days IS
  'Ratings: a game''s weight halves every this many days before the latest game played. NULL = every game the same.';

UPDATE pyramid_forecast_policies SET form_half_life_days = 60 WHERE form_half_life_days IS NULL;

CREATE TABLE IF NOT EXISTS pyramid_forecast_form_levels (
    id             serial PRIMARY KEY,
    half_life_days numeric CHECK (half_life_days > 0),   -- NULL = every game the same (off)
    label          text NOT NULL,
    is_recommended boolean NOT NULL DEFAULT false,
    sort_order     integer NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS pyramid_forecast_form_levels_days_key ON pyramid_forecast_form_levels (COALESCE(half_life_days, 0));
COMMENT ON TABLE pyramid_forecast_form_levels IS
  '#apsl 📈 Forecast: the recent-form levels the page offers (mig 1767). half_life_days NULL = off.';

INSERT INTO pyramid_forecast_form_levels (half_life_days, label, is_recommended, sort_order)
SELECT v.d, v.l, v.r, v.o
  FROM (VALUES
    (NULL::numeric, 'Off — all games equal',       false, 10),
    (90,            'Light — 90 days',             false, 20),
    (60,            '⭐ Recommended — 60 days',     true,  30),
    (30,            'Strong — 30 days',            false, 40)
  ) AS v(d, l, r, o)
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_forecast_form_levels);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c.category, v.l, 'apsl_pyramid', v.t, NULL, v.b, v.o, true, c.client_side, c.is_public
  FROM (VALUES
    ('fc_form',       'Forecast — recent games count more ({days})', 'Recent games count more: a game from {days} days ago counts half.', 334),
    ('fc_form_label', 'Forecast — recent form pills: label',         '📅 Recent form counts more:', 334)
  ) AS v(t, l, b, o)
 CROSS JOIN (SELECT category, client_side, is_public FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'fc_how') c
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
