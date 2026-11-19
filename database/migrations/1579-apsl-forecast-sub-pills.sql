-- 1579 (2026-11-19) — 📈 #apsl Forecast: one screen per pill.
-- Owner 2026-11-19: "big thing is also not this giant scroll each pill
-- should do one thing well right? … so scrolling is not really needed".
-- Matchups by week, the predicted table as Odds / Points per place, the
-- feeders' "All" pill = who comes up.  Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_week_week',     'Forecast — matchups pill: this week',          'This week', 470),
    ('fc_week_next',     'Forecast — matchups pill: next week',          'Next week', 471),
    ('fc_week_later',    'Forecast — matchups pill: later',              'Later', 472),
    ('fc_week_tbs',      'Forecast — matchups pill: not scheduled yet',  'Not scheduled yet', 473),
    ('fc_tview_odds',    'Forecast — table pill: odds',                  'Odds', 474),
    ('fc_tview_points',  'Forecast — table pill: points per place',      'Points each place needs', 475),
    ('story_col_feeder', 'Forecast — column: feeder league',             'League', 476)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
UPDATE message_templates SET body = 'Who comes up' WHERE kind = 'apsl_pyramid' AND tier = 'story_all_feeders';
COMMIT;
