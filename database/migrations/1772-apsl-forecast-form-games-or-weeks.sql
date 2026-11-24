-- 1772 (2026-11-23) — #apsl 📈 Forecast: recent form = a window of games
-- or weeks.  Owner 11/23 "the slider should allow for setting to weeks of
-- games" → "toggle for games or weeks and default to games" → "so everyones
-- last 3 games e.g.": the ratings are built from each team's own last N
-- games, or from the games of the last N weeks — not a fading weight
-- (migs 1767, 1771's half-life goes).  The slider runs 1 … what has been
-- played; its far end = the whole season.
--   form_unit    'games' (each team's own last N) | 'weeks'
--   form_window  N; NULL = the whole season
-- Default: everyone's last 6 games.
BEGIN;

ALTER TABLE pyramid_forecast_policies
  DROP COLUMN IF EXISTS form_half_life_days,
  DROP COLUMN IF EXISTS form_slider_max_weeks,
  ADD COLUMN IF NOT EXISTS form_unit   text NOT NULL DEFAULT 'games' CHECK (form_unit IN ('games', 'weeks')),
  ADD COLUMN IF NOT EXISTS form_window integer CHECK (form_window > 0);
COMMENT ON COLUMN pyramid_forecast_policies.form_unit IS
  'Recent form: games = each team''s own last form_window games; weeks = games in the last form_window weeks.';
COMMENT ON COLUMN pyramid_forecast_policies.form_window IS
  'Recent form: how many games / weeks the ratings are built from. NULL = the whole season.';
UPDATE pyramid_forecast_policies SET form_unit = 'games', form_window = 6;

DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier IN ('fc_form', 'fc_form_off');
UPDATE message_templates SET body = '📅 Recent form — rate teams on their last…'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_label';
UPDATE message_templates SET body = 'Only games from the last {n} wk count', label = 'Forecast — recent form slider: weeks ({n})'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_weeks';
UPDATE message_templates SET body = 'Left = only the latest games (a fresh start, jumpy). Far right = the whole season. Let go to replay the season.'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c.category, v.l, 'apsl_pyramid', v.t, NULL, v.b, v.o, true, c.client_side, c.is_public
  FROM (VALUES
    ('fc_form_games',      'Forecast — recent form slider: games ({n})', 'Every team''s last {n} games count', 334),
    ('fc_form_all',        'Forecast — recent form slider: whole season', 'The whole season counts', 334),
    ('fc_form_unit_games', 'Forecast — recent form toggle: games',        'Games', 334),
    ('fc_form_unit_weeks', 'Forecast — recent form toggle: weeks',        'Weeks', 334)
  ) AS v(t, l, b, o)
 CROSS JOIN (SELECT category, client_side, is_public FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'fc_how') c
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
