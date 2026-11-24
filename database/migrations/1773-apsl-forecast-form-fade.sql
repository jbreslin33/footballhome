-- 1773 (2026-11-23) — #apsl 📈 Forecast: games past the window fade.
-- Owner 11/23 "if set to last 3 games it counts those full or pretty full
-- but then diminishing more after" → "have a diminish slider that gives
-- diff diminish rates": the last N games / weeks count in full (mig 1772);
-- each one further back counts form_fade_pct % of the one after it.
-- 0 = a clean cut (nothing before the window), 100 = no fade at all.
-- Default 50: the next game back counts half, the one before it a quarter.
-- The page's second slider shows it as how much each one back loses —
-- 0% ("one that is 0 diminish", the older games in full too) … 100% (a
-- clean cut), in tens.
BEGIN;

ALTER TABLE pyramid_forecast_policies
  ADD COLUMN IF NOT EXISTS form_fade_pct integer NOT NULL DEFAULT 50 CHECK (form_fade_pct BETWEEN 0 AND 100);
COMMENT ON COLUMN pyramid_forecast_policies.form_fade_pct IS
  'Recent form: each game / week past form_window counts this % of the one after it. 0 = a clean cut, 100 = no fade.';

UPDATE message_templates SET body = 'Every team''s last {n} games count in full'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_games';
UPDATE message_templates SET body = 'Games from the last {n} wk count in full'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_weeks';
UPDATE message_templates SET body = 'Top slider: how many count in full (far right = the whole season). Bottom slider: how fast the older ones fade (left = not at all, right = gone). Let go to replay the season.'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_form_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c.category, v.l, 'apsl_pyramid', v.t, NULL, v.b, v.o, true, c.client_side, c.is_public
  FROM (VALUES
    ('fc_fade_games', 'Forecast — fade slider: games ({pct})', 'Before that, each game back counts {pct}% less than the one after it', 334),
    ('fc_fade_weeks', 'Forecast — fade slider: weeks ({pct})', 'Before that, each week back counts {pct}% less than the one after it', 334),
    ('fc_fade_none',  'Forecast — fade slider: clean cut',     'Before that, nothing counts (100% — a clean cut)', 334),
    ('fc_fade_full',  'Forecast — fade slider: no fade',       'Before that, every game still counts in full (0% — no fade)', 334)
  ) AS v(t, l, b, o)
 CROSS JOIN (SELECT category, client_side, is_public FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'fc_how') c
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
